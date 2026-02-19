import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def run_manual_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Check migrations again but more detail
    print("\n--- DETAILED MIGRATIONS ---")
    cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py migrate --list'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())

    # 2. Check TEMPLATES path in settings
    print("\n--- TEMPLATES SETTING ---")
    cmd = "su - {user} -c \"cd qalaamweb && grep -A 10 'TEMPLATES =' islamweb_clone/settings.py\"".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())

    # 3. Try to run check
    print("\n--- RUNNING django-admin check ---")
    cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py check'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    run_manual_check()
