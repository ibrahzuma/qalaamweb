import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def force_refresh_migrations():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Delete existing migrations in hadiths app
    print("Deleting old migrations in 'hadiths' app on server...")
    del_cmd = "su - {user} -c 'rm qalaamweb/hadiths/migrations/0[0-9]*.py'".format(user=APP_USER)
    ssh.exec_command(del_cmd)

    # 2. Run makemigrations
    print("Running makemigrations...")
    make_cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py makemigrations hadiths'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(make_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    # 3. Read the new 0001_initial.py
    print("Reading new 0001_initial.py...")
    read_cmd = "su - {user} -c 'cat qalaamweb/hadiths/migrations/0001_initial.py | base64'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(read_cmd)
    b64 = stdout.read().decode().replace('\n', '').replace('\r', '')
    
    if b64:
        import base64
        decoded = base64.b64decode(b64).decode('utf-8')
        print("--- DECODED MIGRATION START ---")
        print(decoded)
        print("--- DECODED MIGRATION END ---")
        
        with open('fresh_migration_0001.py', 'w', encoding='utf-8') as f:
            f.write(decoded)
    else:
        print("Failed to read new migration.")

    ssh.close()

if __name__ == "__main__":
    force_refresh_migrations()
