import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def force_restart():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Kill any existing pip or gunicorn hung processes
    print("Cleaning up hung processes...")
    ssh.exec_command("pkill -9 pip")
    ssh.exec_command("pkill -9 gunicorn")
    
    # 2. Restart Gunicorn and Nginx
    print("Restarting Gunicorn and Nginx...")
    ssh.exec_command("systemctl stop gunicorn")
    ssh.exec_command("systemctl start gunicorn.socket")
    ssh.exec_command("systemctl start gunicorn.service")
    ssh.exec_command("systemctl restart nginx")
    ssh.exec_command("chmod 755 /home/django-user")
    
    # 3. Final status check
    print("Checking final status...")
    _, stdout, _ = ssh.exec_command("systemctl status gunicorn --no-pager")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    force_restart()
