import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def read_migration_full():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Find the 0002 file
    stdin, stdout, stderr = ssh.exec_command(f"ls qalaamweb/hadiths/migrations/")
    files = stdout.read().decode().splitlines()
    target = [f for f in files if f.startswith('0002')][0]
    
    print(f"Reading {target}...")
    stdin, stdout, stderr = ssh.exec_command(f"cat qalaamweb/hadiths/migrations/{target}")
    content = stdout.read().decode()
    print("--- START CONTENT ---")
    print(content)
    print("--- END CONTENT ---")

    ssh.close()

if __name__ == "__main__":
    read_migration_full()
