import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def batch_install_all():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Read the requirements from the server
    print("Reading requirements.txt from server...")
    _, stdout, _ = ssh.exec_command(f"cat /home/{APP_USER}/qalaamweb/requirements.txt")
    lines = stdout.read().decode().splitlines()
    packages = [line.strip() for line in lines if line.strip() and not line.startswith('#')]

    # 2. Install in batches of 10
    batch_size = 10
    for i in range(0, len(packages), batch_size):
        batch = packages[i:i+batch_size]
        pkg_str = " ".join(batch)
        print(f"Installing batch {i//batch_size + 1}/{len(packages)//batch_size + 1}: {pkg_str[:50]}...")
        cmd = f"su - {APP_USER} -c 'source qalaamweb/venv/bin/activate && pip install {pkg_str}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        stdout.read() # Consume to wait for completion
        print(f"Batch {i//batch_size + 1} finished.")

    # 3. Final Restart
    print("Restarting services...")
    ssh.exec_command("systemctl restart gunicorn")
    ssh.exec_command("systemctl restart nginx")
    
    ssh.close()

if __name__ == "__main__":
    batch_install_all()
