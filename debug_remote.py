import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def debug_gunicorn():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Run gunicorn manually as django-user to see the crash error
    cmd = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && gunicorn --check-config islamweb_clone.wsgi:application && gunicorn --bind 0.0.0.0:8001 islamweb_clone.wsgi:application'"
    
    print("Running manual gunicorn debug...")
    stdin, stdout, stderr = ssh.exec_command(cmd, timeout=30)
    
    print("--- STDOUT ---")
    print(stdout.read().decode())
    print("--- STDERR ---")
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    debug_gunicorn()
