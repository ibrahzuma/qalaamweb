import paramiko
import base64

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def read_migration_b64():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    print("Encoding qalaamweb/hadiths/migrations/0001_initial.py to base64...")
    cmd = "su - {user} -c 'cat qalaamweb/hadiths/migrations/0001_initial.py | base64'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    
    b64_content = stdout.read().decode().replace('\n', '').replace('\r', '')
    if b64_content:
        decoded = base64.b64decode(b64_content).decode('utf-8')
        print("--- DECODED CONTENT START ---")
        print(decoded)
        print("--- DECODED CONTENT END ---")
        
        # Save it locally for the next step
        with open('server_migration_0001.py', 'w', encoding='utf-8') as f:
            f.write(decoded)
    else:
        print("No content received.")
        print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    read_migration_b64()
