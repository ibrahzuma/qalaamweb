import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def fetch_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Fetch last 50 lines of gunicorn logs or syslog if gunicorn logs to syslog
    print("Fetching last 50 lines of syslog (Django/Gunicorn errors)...")
    stdin, stdout, stderr = ssh.exec_command("journalctl -u gunicorn -n 50 --no-pager")
    print("--- SYSLOG / GUNICORN OUTPUT ---")
    print(stdout.read().decode())
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    fetch_logs()
