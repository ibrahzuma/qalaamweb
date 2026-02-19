import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def force_create_admin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Force create/reset admin_new
    print("Resetting 'admin_new' password and superuser status...")
    cmd = "su - {user} -c \"cd qalaamweb && source venv/bin/activate && python manage.py shell -c 'from django.contrib.auth.models import User; u, _ = User.objects.get_or_create(username=\\\"admin_new\\\"); u.set_password(\\\"allahu(SW)@1\\\"); u.is_staff=True; u.is_superuser=True; u.save(); print(\\\"User admin_new ready.\\\")'\"".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    force_create_admin()
