import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def batch_install():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check RAM first
    _, stdout, _ = ssh.exec_command("free -h")
    print("Initial RAM:")
    print(stdout.read().decode())

    # Install core packages one by one
    packages = ["Django==5.0.1", "gunicorn", "psycopg2-binary", "python-decouple"]
    
    for pkg in packages:
        print(f"Installing {pkg}...")
        cmd = f"su - {APP_USER} -c 'source qalaamweb/venv/bin/activate && pip install {pkg}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    batch_install()
