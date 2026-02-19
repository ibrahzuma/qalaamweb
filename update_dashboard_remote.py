import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def update_remote_dashboard():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Pull latest code
    print("Pulling latest code...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && git pull origin main'")

    # 2. Restart services to pick up new app
    print("Restarting Gunicorn...")
    ssh.exec_command("systemctl restart gunicorn")
    
    print("\n--- DASHBOARD UPDATE COMPLETE ---")
    print(f"Check it out at: http://{HOST}/admin-panel/")
    ssh.close()

if __name__ == "__main__":
    update_remote_dashboard()
