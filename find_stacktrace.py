import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'

def find_errors():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # Check gunicorn logs for "Traceback"
    print("Searching for 'Traceback' in journalctl...")
    stdin, stdout, stderr = ssh.exec_command("journalctl -u gunicorn --since '1 hour ago' | grep -A 20 'Traceback'")
    print("--- TRACEBACK OUTPUT ---")
    print(stdout.read().decode())
    print(stderr.read().decode())

    # Check database tables
    print("\nChecking database tables...")
    check_db = "su - django-user -c \"cd qalaamweb && sqlite3 db.sqlite3 '.tables'\""
    stdin, stdout, stderr = ssh.exec_command(check_db)
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    find_errors()
