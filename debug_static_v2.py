import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def debug_static():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Check settings.py for STATIC_ROOT
    print("--- Settings STATIC_ROOT ---")
    cmd_settings = f"grep 'STATIC_ROOT' /home/{APP_USER}/qalaamweb/islamweb_clone/settings.py"
    _, stdout, _ = ssh.exec_command(cmd_settings)
    print(stdout.read().decode())

    # 2. Check Nginx for static location
    print("--- Nginx Static Config ---")
    _, stdout, _ = ssh.exec_command("cat /etc/nginx/sites-available/qalaamweb")
    print(stdout.read().decode())

    # 3. Re-run collectstatic explicitly
    print("--- Re-running Collectstatic ---")
    cmd_collect = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py collectstatic --noinput'"
    _, stdout, stderr = ssh.exec_command(cmd_collect)
    print(stdout.read().decode())
    print(stderr.read().decode())

    # 4. Check directory after collectstatic
    print("--- Files in static/admin/css ---")
    _, stdout, _ = ssh.exec_command(f"ls -R /home/{APP_USER}/qalaamweb/static/admin/css")
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    debug_static()
