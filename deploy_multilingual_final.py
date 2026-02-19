import paramiko
import time

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def deploy_multilingual():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Force pull new code
    print("Force pulling latest code from GitHub...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && git fetch --all && git reset --hard origin/main'")
    time.sleep(5)

    # 2. Re-migrate hadiths (Fresh start for the new schema)
    print("Resetting Hadith tables and running migrations...")
    # Using a shell script to drop tables directly in sqlite to ensure a clean state
    drop_cmd = "su - {user} -c \"cd qalaamweb && sqlite3 db.sqlite3 'DROP TABLE IF EXISTS hadiths_hadith; DROP TABLE IF EXISTS hadiths_hadithedition; DELETE FROM django_migrations WHERE app=\'hadiths\';'\"".format(user=APP_USER)
    ssh.exec_command(drop_cmd)
    
    migrate_cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py migrate'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(migrate_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    # 3. Re-import Bukhari and Muslim with BOTH Arabic and English
    collections = [
        ('bukhari', ['ara-bukhari', 'eng-bukhari']),
        ('muslim', ['ara-muslim', 'eng-muslim']),
    ]
    
    for coll_slug, editions in collections:
        for edition in editions:
            print(f"Importing {edition} into {coll_slug}...")
            import_cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py import_hadiths --collection {coll} --edition {ed}'".format(
                user=APP_USER, coll=coll_slug, ed=edition
            )
            stdin, stdout, stderr = ssh.exec_command(import_cmd)
            # We print status every few hadiths in the script, so let's just wait for the end
            print(stdout.read().decode())

    # 4. Restart Gunicorn
    print("Restarting Gunicorn...")
    ssh.exec_command("systemctl restart gunicorn")
    
    print("\n--- MULTILINGUAL DEPLOYMENT COMPLETE ---")
    print(f"URL: http://{HOST}/hadiths/")
    ssh.close()

if __name__ == "__main__":
    deploy_multilingual()
