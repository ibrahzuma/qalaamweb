import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def verify_install():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check venv and pip list
    cmd = f"su - {APP_USER} -c 'ls -R qalaamweb/venv/lib | head -n 20 && . qalaamweb/venv/bin/activate && pip list'"
    
    print("Verifying installation...")
    stdin, stdout, stderr = ssh.exec_command(cmd)
    
    print("--- STDOUT ---")
    print(stdout.read().decode())
    print("--- STDERR ---")
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    verify_install()
