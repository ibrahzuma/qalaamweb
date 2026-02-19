import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def verify_superuser():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check if admin_new exists and is staff/superuser
    print("Checking for user 'admin_new'...")
    check_cmd = "su - {user} -c \"cd qalaamweb && source venv/bin/activate && python manage.py shell -c 'from django.contrib.auth.models import User; u=User.objects.filter(username=\\\"admin_new\\\").first(); print(f\\\"User exists: {u is not None}\\\"); print(f\\\"Is staff: {u.is_staff if u else False}\\\"); print(f\\\"Is superuser: {u.is_superuser if u else False}\\\")'\"".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(check_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    verify_superuser()
