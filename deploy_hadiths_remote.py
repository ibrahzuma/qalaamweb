import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def deploy_hadiths():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Pull latest code
    print("Pulling latest code...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && git pull origin main'")

    # 2. Run migrations
    print("Running migrations...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py migrate'")

    # 3. Import major collections (Bukhari and Muslim) in English
    collections = ['eng-bukhari', 'eng-muslim']
    for coll in collections:
        print(f"Importing {coll} (this may take a few minutes)...")
        # We use a longer timeout for the import as it fetches thousands of hadiths
        cmd = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py import_hadiths --edition {coll}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        # We don't want to wait forever if it's too slow, but we want to see progress
        # For now, let's just trigger it. In a real scenario we might run it in background.
        stdout.channel.settimeout(300)
        try:
            print(stdout.read().decode())
        except:
            print(f"Timed out or finished in background for {coll}")

    # 4. Restart services to pick up new app
    print("Restarting Gunicorn...")
    ssh.exec_command("systemctl restart gunicorn")
    
    print("\n--- HADITH DEPLOYMENT COMPLETE ---")
    print(f"Check it out at: http://{HOST}/hadiths/")
    ssh.close()

if __name__ == "__main__":
    deploy_hadiths()
