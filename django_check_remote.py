import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def django_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Run django check to see the real error
    print("Running python manage.py check...")
    cmd = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py check'"
    
    stdin, stdout, stderr = ssh.exec_command(cmd)
    
    print("--- STDOUT ---")
    print(stdout.read().decode())
    print("--- STDERR ---")
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    django_check()
