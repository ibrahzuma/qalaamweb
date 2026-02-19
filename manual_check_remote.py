import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def manual_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Run gunicorn manually for 5 seconds and capture output
    print("Running Gunicorn manually to find the crash reason...")
    cmd = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && gunicorn islamweb_clone.wsgi:application'"
    
    stdin, stdout, stderr = ssh.exec_command(cmd, timeout=10)
    
    try:
        print("--- STDOUT ---")
        print(stdout.read().decode())
    except:
        pass
        
    try:
        print("--- STDERR ---")
        print(stderr.read().decode())
    except:
        pass
    
    ssh.close()

if __name__ == "__main__":
    manual_check()
