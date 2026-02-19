import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def check_static():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Check Nginx Config
    print("--- Nginx Config ---")
    _, stdout, _ = ssh.exec_command("cat /etc/nginx/sites-available/qalaamweb")
    print(stdout.read().decode())

    # 2. Check Static Files Directory
    print("--- Static Directory List ---")
    _, stdout, _ = ssh.exec_command(f"ls -F /home/{APP_USER}/qalaamweb/static")
    print(stdout.read().decode())

    # 3. Check Admin Static Files specifically
    print("--- Admin Static Files ---")
    _, stdout, _ = ssh.exec_command(f"ls -F /home/{APP_USER}/qalaamweb/static/admin")
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    check_static()
