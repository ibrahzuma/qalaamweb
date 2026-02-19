import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def grep_server_migration():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    print("Checking for 'HadithBook' in server's 0001_initial.py...")
    cmd = "su - {user} -c 'grep \"HadithBook\" qalaamweb/hadiths/migrations/0001_initial.py'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    output = stdout.read().decode().strip()
    print(f"Grep output: '{output}'")

    ssh.close()

if __name__ == "__main__":
    grep_server_migration()
