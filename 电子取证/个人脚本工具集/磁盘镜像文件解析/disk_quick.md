
# 脚本 A — 磁盘镜像快速检测（`disk_quick.sh`）

保存为 `disk_quick.sh`，随后 `chmod +x disk_quick.sh`，用法 `./disk_quick.sh ide0_disk.vmdk`
（会输出 hashes、strings 扫描、偏移定位、导出 chunk，并生成 report 文件夹）

```bash
#!/bin/bash
set -euo pipefail

IMG="$1"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="disk_report_${TIMESTAMP}"
mkdir -p "$OUTDIR"

# 1. 基本校验（sha256）
echo "[*] computing sha256..."
sha256sum "$IMG" > "$OUTDIR/$(basename $IMG).sha256"
echo "sha256 saved to $OUTDIR/$(basename $IMG).sha256"

# 2. 快速字符串扫描（常见关键词）
echo "[*] strings scan (this may take a while)..."
strings "$IMG" | egrep -n 'IPADDR|BOOTPROTO|ifcfg-|ONBOOT|DEVICE|HWADDR|PASSWORD|DefaultPassword|ssh-rsa|BEGIN RSA PRIVATE KEY' > "$OUTDIR/strings_hits.txt"
wc -l "$OUTDIR/strings_hits.txt"

# 3. 精确字节偏移（用于导出上下文）
echo "[*] locating byte offsets..."
grep -aob -E 'IPADDR=|BOOTPROTO=|ifcfg-|ONBOOT=|DEVICE=|DefaultPassword|BEGIN RSA PRIVATE KEY' "$IMG" > "$OUTDIR/offsets.txt" || true
wc -l "$OUTDIR/offsets.txt"

# 4. 按偏移导出上下文（前后512字节）
mkdir -p "$OUTDIR/chunks"
while IFS=: read -r off match; do
  outbin="$OUTDIR/chunks/chunk_${off}.bin"
  outtxt="$OUTDIR/chunks/chunk_${off}.txt"
  start=$(( off > 512 ? off - 512 : 0 ))
  dd if="$IMG" bs=1 skip=$start count=1024 status=none of="$outbin"
  strings "$outbin" > "$outtxt"
done < "$OUTDIR/offsets.txt" || true

# 5. 试图挂载（可选：需要 root + qemu-nbd）
echo "[*] attempting read-only mount via qemu-nbd (requires root)..."
if command -v qemu-nbd >/dev/null 2>&1; then
  if [ "$(id -u)" -ne 0 ]; then
    echo "  (skipped qemu-nbd mount: need root)"
  else
    modprobe nbd max_part=8 || true
    qemu-nbd -c /dev/nbd0 "$IMG"
    sleep 1
    # 列分区并尝试只读挂载每个分区
    for p in /dev/nbd0p*; do
      mountpoint="$OUTDIR/mnt_${p##*/}"
      mkdir -p "$mountpoint"
      mount -o ro "$p" "$mountpoint" 2>/dev/null && echo "mounted $p -> $mountpoint" || true
      # 如果挂载成功，查找网络脚本
      if mount | grep -q "$mountpoint"; then
         grep -nH -E 'IPADDR|BOOTPROTO|ifcfg-|ONBOOT|DEVICE|HWADDR' "$mountpoint/etc"/* 2>/dev/null || true
      fi
    done
    # cleanup
    for mp in "$OUTDIR"/mnt_*; do [ -d "$mp" ] && umount "$mp" 2>/dev/null || true; done
    qemu-nbd -d /dev/nbd0 || true
  fi
else
  echo "  qemu-nbd not installed; skipping mount step."
fi

# 6. 记录命令（可复现）
echo "sha256sum $IMG" > "$OUTDIR/commands.txt"
echo "strings $IMG | egrep -n 'IPADDR|BOOTPROTO|ifcfg-|ONBOOT|DEVICE|HWADDR|PASSWORD|DefaultPassword|ssh-rsa|BEGIN RSA PRIVATE KEY' > strings_hits.txt" >> "$OUTDIR/commands.txt"
sha256sum "$OUTDIR/commands.txt" > "$OUTDIR/commands.txt.sha256"

echo "[*] done. Results in $OUTDIR"
```

---