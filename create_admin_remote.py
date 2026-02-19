import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def create_admin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Create superuser using manage.py shell
    # Username: admin_new, Password: allahu(SW)@1
    username = "admin_new"
    email = "admin@example.com"
    password = "allahu(SW)@1"
    
    cmd = f"su - {APP_USER} -c \"cd qalaamweb && source venv/bin/activate && python manage.py shell -c \\\"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='{username}').delete(); User.objects.create_superuser('{username}', '{email}', '{password}')\\\"\""
    
    print(f"Creating superuser {username}...")
    _, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    create_admin()
