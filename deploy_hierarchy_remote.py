import paramiko
import time

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def deploy_hierarchy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Pull latest code
    print("Pulling hierarchical changes...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && git pull origin main'")
    time.sleep(5)

    # 2. Reset Hadith tables for clean schema migration
    print("Resetting Hadith tables...")
    drop_cmd = "su - {user} -c \"cd qalaamweb && sqlite3 db.sqlite3 'DROP TABLE IF EXISTS hadiths_hadith; DROP TABLE IF EXISTS hadiths_hadithbook; DROP TABLE IF EXISTS hadiths_hadithedition; DROP TABLE IF EXISTS hadiths_hadithcollection; DELETE FROM django_migrations WHERE app=\'hadiths\';'\"".format(user=APP_USER)
    ssh.exec_command(drop_cmd)
    
    print("Running migrations...")
    migrate_cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py migrate'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(migrate_cmd)
    print(stdout.read().decode())

    # 3. Re-import Bukhari and Muslim with Hierarchical Support
    collections = [
        ('bukhari', ['ara-bukhari', 'eng-bukhari']),
        ('muslim', ['ara-muslim', 'eng-muslim']),
    ]
    
    for coll_slug, editions in collections:
        for edition in editions:
            print(f"Importing {edition} into {coll_slug} (Hierarchical)...")
            import_cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py import_hadiths --collection {coll} --edition {ed}'".format(
                user=APP_USER, coll=coll_slug, ed=edition
            )
            stdin, stdout, stderr = ssh.exec_command(import_cmd)
            stdout.channel.settimeout(300)
            print(stdout.read().decode())

    # 4. Restart Gunicorn
    print("Restarting Gunicorn...")
    ssh.exec_command("systemctl restart gunicorn")
    
    print("\n--- HIERARCHICAL NAVIGATION DEPLOYED ---")
    print(f"URL: http://{HOST}/hadiths/")
    ssh.close()

if __name__ == "__main__":
    deploy_hierarchy()
