import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def check_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check Gunicorn logs
    print("Capturing Gunicorn logs...")
    _, stdout, _ = ssh.exec_command("journalctl -u gunicorn --no-pager | tail -n 30")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_logs()
