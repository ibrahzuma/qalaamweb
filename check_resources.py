import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def check_resources():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check RAM and Disk
    cmds = [
        "free -h",
        "df -h",
        "top -bn1 | head -n 10"
    ]
    
    for cmd in cmds:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_resources()
