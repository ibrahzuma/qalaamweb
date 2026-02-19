import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def generate_and_read_migration():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Makemigrations on server
    print("Generating migrations on server...")
    cmd = "su - {user} -c 'cd qalaamweb && source venv/bin/activate && python manage.py makemigrations hadiths'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())

    # 2. List migrations to find the new one
    print("Listing migrations...")
    cmd = "su - {user} -c 'ls qalaamweb/hadiths/migrations/'".format(user=APP_USER)
    stdin, stdout, stderr = ssh.exec_command(cmd)
    migration_files = stdout.read().decode().splitlines()
    print(f"Migrations on server: {migration_files}")

    new_migration = [f for f in migration_files if f.startswith('0002') or (f.startswith('0001') and f != '0001_initial.py')]
    if not new_migration:
        # Maybe it modified 0001? Or didn't create anything.
        print("No new migration found starting with 0002. Checking for any recent changes.")
        # If I dropped the migration file on server manually before, it might have regenerated 0001.

    for migration in migration_files:
        if migration.endswith('.py') and migration != '__init__.py':
            print(f"\n--- CONTENT OF {migration} ---")
            cmd = "su - {user} -c 'cat qalaamweb/hadiths/migrations/{file}'".format(user=APP_USER, file=migration)
            stdin, stdout, stderr = ssh.exec_command(cmd)
            print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    generate_and_read_migration()
