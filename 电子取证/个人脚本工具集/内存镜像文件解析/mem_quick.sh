#!/bin/bash 读dmp
set -euo pipefail

IMG="$1"
PID="${2:-}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="mem_report_${TIMESTAMP}"
mkdir -p "$OUTDIR"

# 1. sha256
sha256sum "$IMG" > "$OUTDIR/$(basename $IMG).sha256"

# 2. 列进程（找 PID）
echo "[*] listing processes..."
vol -f "$IMG" windows.pslist.PsList > "$OUTDIR/pslist.txt" 2>&1

# 3. lsadump -> 查 DefaultPassword / LSA secrets
echo "[*] running lsadump..."
vol -f "$IMG" windows.lsadump.Lsadump > "$OUTDIR/lsadump.txt" 2>&1
grep -n -E 'DefaultPassword|DefaultUserName|LsaSecret|DPAPI' "$OUTDIR/lsadump.txt" > "$OUTDIR/lsadump_hits.txt" || true

# 4. hashdump（NTLM/hash）
echo "[*] extracting hashes (hashdump)..."
vol -f "$IMG" windows.hashdump.Hashdump > "$OUTDIR/hashdump.txt" 2>&1 || true

# 5. vadregexscan: email/token 搜索（如果提供 PID 则限定 PID）
PAT="[A-Za-z0-9._%+\-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
if [ -n "$PID" ]; then
  echo "[*] VadRegExScan for PID $PID ..."
  vol -f "$IMG" windows.vadregexscan.VadRegExScan --pid "$PID" --pattern "$PAT" > "$OUTDIR/vad_email_pid${PID}.txt" 2>&1 || true
else
  echo "[*] VadRegExScan for all processes (may be slow)..."
  vol -f "$IMG" windows.vadregexscan.VadRegExScan --pattern "$PAT" > "$OUTDIR/vad_email_all.txt" 2>&1 || true
fi

# 6. 生成 commands.txt 与哈希
echo "vol -f $IMG windows.pslist.PsList" > "$OUTDIR/commands.txt"
echo "vol -f $IMG windows.lsadump.Lsadump" >> "$OUTDIR/commands.txt"
echo "vol -f $IMG windows.hashdump.Hashdump" >> "$OUTDIR/commands.txt"
if [ -n "$PID" ]; then
  echo "vol -f $IMG windows.vadregexscan.VadRegExScan --pid $PID --pattern '$PAT'" >> "$OUTDIR/commands.txt"
else
  echo "vol -f $IMG windows.vadregexscan.VadRegExScan --pattern '$PAT'" >> "$OUTDIR/commands.txt"
fi
sha256sum "$OUTDIR/commands.txt" > "$OUTDIR/commands.txt.sha256"

echo "[*] done. Results in $OUTDIR"
