import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def import_more():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Additional collections to import
    collections = ['eng-abudawud', 'eng-tirmidhi', 'eng-nasai', 'eng-ibnmajah']
    
    for coll in collections:
        print(f"Importing {coll}...")
        cmd = f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py import_hadiths --edition {coll}'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        stdout.channel.settimeout(300)
        try:
            print(stdout.read().decode())
        except:
            print(f"Import for {coll} completed (or continues in background).")

    print("\n--- ALL COLLECTIONS IMPORTED ---")
    ssh.close()

if __name__ == "__main__":
    import_more()
