import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def check_pip():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check if pip is running
    cmd = "ps aux | grep pip"
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print("--- PIP PROCESSES ---")
    print(stdout.read().decode())
    
    # Check RAM again
    cmd_mem = "free -h"
    _, stdout_mem, _ = ssh.exec_command(cmd_mem)
    print("--- MEMORY ---")
    print(stdout_mem.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_pip()
