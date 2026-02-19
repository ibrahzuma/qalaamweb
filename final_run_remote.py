import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def final_run():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Try to install the rest (maybe it works now that core is there)
    print("Installing remaining requirements...")
    cmd_install = f"su - {APP_USER} -c 'source qalaamweb/venv/bin/activate && pip install -r qalaamweb/requirements.txt'"
    ssh.exec_command(cmd_install) # We don't wait indefinitely, just fire it
    
    # 2. Check gunicorn status after a small delay
    import time
    time.sleep(10)
    
    print("Checking Gunicorn error logs...")
    _, stdout, _ = ssh.exec_command("journalctl -u gunicorn --no-pager | tail -n 20")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    final_run()
