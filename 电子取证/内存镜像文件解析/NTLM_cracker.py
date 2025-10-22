from Crypto.Hash import MD4

# 生成NTLM哈希的函数
def generate_ntlm_hash(password):
    """使用MD4算法生成NTLM哈希"""
    md4_hash = MD4.new()
    md4_hash.update(password.encode('utf-16le'))
    return md4_hash.hexdigest().upper()

# 使用字典（每行一个密码）破解NTLM哈希
def crack_with_wordlist(target_ntlm_hash, wordlist_file_path):
    """从txt字典文件逐行读取密码，计算NTLM并比对目标哈希"""
    normalized_target = target_ntlm_hash.strip().upper()
    try:
        with open(wordlist_file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                candidate = line.rstrip('\n\r')
                if not candidate:
                    continue
                calculated_hash = generate_ntlm_hash(candidate)
                # 如需查看尝试过程，可取消下一行注释
                print(f"尝试: {candidate} -> {calculated_hash}")
                if calculated_hash == normalized_target:
                    return candidate
    except FileNotFoundError:
        print(f"字典文件不存在: {wordlist_file_path}")
    return None

# 目标NTLM哈希
target_hash = "7f21caca5685f10d9e849cc84c340528"

# 字典文件路径（每行一个候选密码）
wordlist_path = "/Users/zhangyuanyi/Downloads/公司首届网络安全培训/实验题/rockyou7.txt"

# 调用字典破解函数
found_password = crack_with_wordlist(target_hash, wordlist_path)

if found_password:
    print(f"成功破解密码: {found_password}")
else:
    print("没有找到密码。")