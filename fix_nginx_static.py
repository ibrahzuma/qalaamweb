import paramiko

HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'

def fix_nginx_static():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. Update Nginx Config with 'alias /home/django-user/qalaamweb/staticfiles/;'
    nginx_conf = f"""server {{
    listen 80;
    server_name {HOST};

    location = /favicon.ico {{ access_log off; log_not_found off; }}
    location /static/ {{
        alias /home/{APP_USER}/qalaamweb/staticfiles/;
    }}

    location /media/ {{
        alias /home/{APP_USER}/qalaamweb/media/;
    }}

    location / {{
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }}
}}"""
    
    # Write the file directly using echo/tee to avoid escaping issues in SSH
    # Actually, using sftp is cleaner if I'm doing a whole block
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/sites-available/qalaamweb', 'w') as f:
        f.write(nginx_conf)
    sftp.close()

    # 2. Test and Restart Nginx
    print("Testing Nginx config...")
    _, stdout, stderr = ssh.exec_command("nginx -t")
    print(stdout.read().decode())
    print(stderr.read().decode())

    print("Restarting Nginx...")
    ssh.exec_command("systemctl restart nginx")

    # 3. Ensure permissions are correct on the staticfiles dir
    print("Setting permissions...")
    ssh.exec_command(f"chown -R {APP_USER}:www-data /home/{APP_USER}/qalaamweb/staticfiles")
    ssh.exec_command(f"chmod -R 755 /home/{APP_USER}/qalaamweb/staticfiles")
    
    # 4. Re-run collectstatic just in case
    print("Re-running collectstatic...")
    ssh.exec_command(f"su - {APP_USER} -c 'cd qalaamweb && source venv/bin/activate && python manage.py collectstatic --noinput'")

    print("Cleanup complete.")
    ssh.close()

if __name__ == "__main__":
    fix_nginx_static()
