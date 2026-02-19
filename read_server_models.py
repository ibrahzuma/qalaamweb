import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def read_server_models():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    print("Reading qalaamweb/hadiths/models.py...")
    stdin, stdout, stderr = ssh.exec_command("su - {user} -c 'cat qalaamweb/hadiths/models.py'".format(user=APP_USER))
    content = stdout.read().decode()
    print("--- START CONTENT ---")
    print(content)
    print("--- END CONTENT ---")

    ssh.close()

if __name__ == "__main__":
    read_server_models()
