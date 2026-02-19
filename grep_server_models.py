import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def grep_server_models():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    print("Checking for 'HadithBook' in server's models.py...")
    cmd = "su - {user} -c 'grep \"class HadithBook\" qalaamweb/hadiths/models.py'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    output = stdout.read().decode().strip()
    print(f"Grep output: '{output}'")

    ssh.close()

if __name__ == "__main__":
    grep_server_models()
