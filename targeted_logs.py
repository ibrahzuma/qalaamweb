import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def targeted_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Full Nginx Error Log
    print("\n--- NGINX ERROR LOG (Full last 50) ---")
    stdin, stdout, stderr = ssh.exec_command("tail -n 50 /var/log/nginx/error.log")
    print(stdout.read().decode())

    # 2. Gunicorn error logs (stdout/stderr)
    print("\n--- GUNICORN ERROR LOG (Journalctl -u gunicorn) ---")
    stdin, stdout, stderr = ssh.exec_command("journalctl -u gunicorn --since '10 minutes ago' --no-pager")
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    targeted_logs()
