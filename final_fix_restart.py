import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def final_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Pull and install
    print("Pulling latest code and completing installation...")
    cmd_pull = f"su - {APP_USER} -c 'cd qalaamweb && git pull origin main && source venv/bin/activate && pip install -r requirements.txt'"
    stdin, stdout, stderr = ssh.exec_command(cmd_pull)
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 2. Restart services
    print("Restarting services...")
    cmds_restart = [
        "systemctl stop gunicorn", # Stop first to ensure clean boot
        "systemctl start gunicorn.socket",
        "systemctl start gunicorn.service",
        "systemctl restart nginx",
        "chmod 755 /home/django-user" # Ensure Nginx has access
    ]
    for cmd in cmds_restart:
        ssh.exec_command(cmd)
    
    print("\n--- DEPLOYMENT SHOULD BE FIXED ---")
    print(f"Visit: http://{HOST}")
    ssh.close()

if __name__ == "__main__":
    final_fix()
