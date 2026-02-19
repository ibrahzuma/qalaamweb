import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def comprehensive_check():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Nginx Error Logs
    print("\n--- NGINX ERROR LOGS (Last 20) ---")
    stdin, stdout, stderr = ssh.exec_command("tail -n 20 /var/log/nginx/error.log")
    print(stdout.read().decode())

    # 2. Check Migration Status
    print("\n--- DJANGO MIGRATION STATUS ---")
    migrate_status = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py showmigrations hadiths'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(migrate_status)
    print(stdout.read().decode())

    # 3. Check Database Tables with full path
    print("\n--- DATABASE TABLES ---")
    check_db = "su - {user} -c \"cd qalaamweb && /usr/bin/sqlite3 db.sqlite3 '.tables'\"".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(check_db)
    print(stdout.read().decode())

    # 4. Check Hadith Count
    print("\n--- HADITH COUNT ---")
    check_count = "su - {user} -c \"cd qalaamweb && source venv/bin/activate && python manage.py shell -c 'from hadiths.models import Hadith; print(Hadith.objects.count())'\"".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(check_count)
    print(f"Count: {stdout.read().decode().strip()}")
    print(stderr.read().decode())

    ssh.close()

if __name__ == "__main__":
    comprehensive_check()
