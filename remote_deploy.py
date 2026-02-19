import paramiko
import time

# Server Credentials
HOST = '45.56.67.208'
USER = 'root'
PASS = 'allahu(SW)@1'
APP_USER = 'django-user'
APP_PASS = 'allahu(SW)@1' # Reusing for simplicity, change if desired
REPO_URL = 'https://github.com/ibrahzuma/qalaamweb.git'
SECRET_KEY = 'django-insecure-@8z_t0-^2!%*7d1&)+$3k#vx-p9w)6y(m!5u_q=0+*^4n9#r2l'

def run_commands(ssh, commands):
    for cmd in commands:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        exit_status = stdout.channel.recv_exit_status()
        if exit_status != 0:
            print(f"Error executing {cmd}:")
            print(stderr.read().decode())
        else:
            print(stdout.read().decode())

def main():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print(f"Connecting to {HOST}...")
    try:
        ssh.connect(HOST, username=USER, password=PASS)
    except Exception as e:
        print(f"Connection failed: {e}")
        return

    # 1. System Preparation (as root)
    root_setup = [
        "apt update",
        "apt install -y python3-pip python3-venv nginx git curl pkg-config libcairo2-dev",
        f"id -u {APP_USER} >/dev/null 2>&1 || adduser --disabled-password --gecos '' {APP_USER}",
        f"echo '{APP_USER}:{APP_PASS}' | chpasswd",
        f"usermod -aG sudo {APP_USER}"
    ]
    run_commands(ssh, root_setup)

    # 2. Project Setup (as django-user)
    # We switch to django-user for the rest
    app_setup_cmd = f"""
    su - {APP_USER} << 'EOF'
    [ -d qalaamweb ] && rm -rf qalaamweb
    git clone {REPO_URL}
    cd qalaamweb
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install gunicorn
    
    # Create .env
    echo "DEBUG=False" > .env
    echo "SECRET_KEY={SECRET_KEY}" >> .env
    echo "ALLOWED_HOSTS={HOST}" >> .env
    
    # Django commands
    python manage.py migrate
    python manage.py collectstatic --noinput
    EOF
    """
    run_commands(ssh, [app_setup_cmd])

    # 3. Gunicorn & Nginx (as root)
    services_setup = [
        # Gunicorn Socket
        "printf '[Unit]\\nDescription=gunicorn socket\\n\\n[Socket]\\nListenStream=/run/gunicorn.sock\\n\\n[Install]\\nWantedBy=sockets.target' | tee /etc/systemd/system/gunicorn.socket",
        # Gunicorn Service
        f"printf '[Unit]\\nDescription=gunicorn daemon\\nRequires=gunicorn.socket\\nAfter=network.target\\n\\n[Service]\\nUser={APP_USER}\\nGroup=www-data\\nWorkingDirectory=/home/{APP_USER}/qalaamweb\\nExecStart=/home/{APP_USER}/qalaamweb/venv/bin/gunicorn --access-logfile - --workers 3 --bind unix:/run/gunicorn.sock islamweb_clone.wsgi:application\\n\\n[Install]\\nWantedBy=multi-user.target' | tee /etc/systemd/system/gunicorn.service",
        "systemctl start gunicorn.socket",
        "systemctl enable gunicorn.socket",
        # Nginx Config
        f"printf 'server {{\\n    listen 80;\\n    server_name {HOST};\\n\\n    location = /favicon.ico {{ access_log off; log_not_found off; }}\\n    location /static/ {{\\n        root /home/{APP_USER}/qalaamweb;\\n    }}\\n\\n    location /media/ {{\\n        root /home/{APP_USER}/qalaamweb;\\n    }}\\n\\n    location / {{\\n        include proxy_params;\\n        proxy_pass http://unix:/run/gunicorn.sock;\\n    }}\\n}}' | tee /etc/nginx/sites-available/qalaamweb",
        "ln -sf /etc/nginx/sites-available/qalaamweb /etc/nginx/sites-enabled",
        "nginx -t && systemctl restart nginx"
    ]
    run_commands(ssh, services_setup)

    print("\n--- DEPLOYMENT COMPLETE ---")
    print(f"Your site should be live at: http://{HOST}")
    ssh.close()

if __name__ == "__main__":
    main()
