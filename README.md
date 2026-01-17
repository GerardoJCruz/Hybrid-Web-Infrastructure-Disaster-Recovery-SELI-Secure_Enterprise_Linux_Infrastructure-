# Project: Secure Enterprise Linux Infrastructure

## Cover concepts:

- Linux File System Structure (FHS): Cross-distro standards.
- User Accounts & RBAC: Managing local vs. remote access.
- Package Management: Operating in DNF (AlmaLinux) and APT (Debian) environments.
- Centralized logging: Using rsyslog to move logs across a network.
- Network Security: Host-Based firewalls and internal network isolation.
- Remote Access: Managing SSH Keys across multiple servers.
- Automation: Bash scripting for health checks and off-site backups.
- Soc Analysis: Forensic investigation of centralized log data.
- Hybrid Cloud Connectivity: Linking Local Machines to Public Cloud (AWS is the cloud provider selected for this project).
- Advance Networking: SSH Tunneling, Port Forwarding, and Reverse Proxies.
- Identity & Access Management (IAM): Managing cloud-native permissions vs. local Linux users.
- Zero-Trust Principles: Restricting access via IP Whitelisting and Security Group.
- Public Service Delivery: Safely exposing a private web service to the internet.

---

## Real-World Problem to Solve.

A min-sized firm requires a high-security, hybrid environment:

- Separation of Duties:  Web services must be separate from security/log monitoring.
- Centralized Visibility: All system logs must be sent to a dedicated “Security Server” so they can’t be deleted by an attacker on the web server.
- Secure Maintenance: Admins must use a specific “Management Station” to access servers.
- Off-site Backups: Backups from the Web server must be moved automatically to the Log server.
- Health Alerts: They system must alert the admin if disk space is low or if a service fails.
- Log Integrity: Security logs must be mirrored to an off-site “Vault” (AWS) so local hardware or physical theft doesn’t lose forensic data.
- External Access: The company website, hosted on a local private server, must be securely accessible to the public via a cloud-based gateway.
- Infrastructure Health: An external observer must monitor the local office’s internet and server connectivity.
- Hybrid Compliance: The Junior Admin must demonstrate they can manage infrastructure across both On-Premise and AWS platforms.

---

## Project Tasks:

### Local Setup:

1. Set up the Multi-node lab (VKM used in this case due its performance, Linux integration and scalability)
    - VM (Web Server):  AlmaLinux. Configure host-name as web-prod-01.
    - VM (Log Server): Debian server. Configure host-name as sec-monitor-01.
    - Network: Network: Set up a Host-Only network or Internal Network so the VMs can talk each other but are isolated from the public internet.
2. Build User & Group Roles (RBAC)
    - Create web-admin on VM 1 and sec-admin on VM 2.
    - Create a shared directory /data/backups on the Log Server.
    - Configure permissions so only the backup-service user can write to the remote backup folder.
3. Secure SSH & Management Access
    - Hardening: Disable password login on both servers.
    - Key Management: Generate SSH keys on your Management Station; distribute them to both VMs.
    - Customization: Change SSH port to 2222 on the Web Server.
    - Sudoers: Configure /etc/sudoers.d/audit-policy to log all sudo commands to the centralized log server.
4. Set up a Monitored Service (Nginx)
    - Install Nginx on the Web Server (web-prod-01).
    - Enable and start the service via systemctl.
    - Service Watchdog: Write a script that checks if Nginx is "Active." If it’s "Inactive," the script restarts it and logs the event to the Log Server.
5. Centralized Log Management (SOC Focus)
    - Rsyslog Config: Configure the Web Server to forward all logs (auth, kern, user) to the Log Server’s IP.
    - Verification: Use journalctl -u postfix or check /var/log/syslog on the Log Server to see real-time events coming from the Web Server.
6. Automatic Remote Backups
    - Script: Create a bash script on the Web Server that tars /var/www/html and uses scp or rsync to move the file to the Log Server.
    - Automation: Set a Cron Job to run this every night at 3:00 AM.
7. Multi-Server Disk Monitoring
    - Use your Disk Monitor Script.
    - Adaptation: Modify the script to not only log locally but to send a "CRITICAL" log message to the remote Log Server if disk usage exceeds 80%.

### Cloud Integration:

1. Set up the Hybrid Architecture
    - Cloud Node: Launch a New EC2 Instance (AL2023) in AWS. Configure as cloud-sentinel-01.
    - The Bridge: Establish an SSH Reverse Tunnel from the Local Log Server to the AWS EC2 instance.
2. Advanced Security & Cloud IAM
    - Security Groups: Configure AWS Security Groups to only allow your home’s Public IP on Port 2222 (SSH).
    - Key Rotation: Use separate SSH keys for Local vs. Cloud environments to prevent "lateral movement" if one key is stolen.
    - IAM Policy: Create a restricted IAM user for the EC2 instance to upload logs to an S3 bucket (optional future step).
3. The "Sentinel" Service (External Monitoring)
    - Uptime Script: Create a Python or Bash script on the EC2 instance that pings your home network's public IP every 5 minutes.
    - Alerting: If the home lab goes offline, the EC2 instance sends an alert via Amazon SES.
4. Public Web Exposure (The Reverse Proxy)
    - Task: Install Nginx on the AWS EC2 instance.
    - Configuration: Set up Nginx as a Reverse Proxy. When a visitor hits the EC2's Public IP, the traffic is routed through the SSH Tunnel to the Local Web Server.
    - Result: Your local website is now live on the internet, but your home IP remains hidden.
5. Off-site Log Mirroring (SOC Forensic Path)
    - Task: Configure rsyslog on the Local Log Server to forward "Critical" level logs to the AWS EC2 instance.
    - Verification: Log into the AWS console and see the local "failed login" attempts appearing in the cloud logs in real-time.
6. Automated Hybrid Backups
    - Task: Create a script that takes the daily .tar.gz backup from the Local Web Server and "pushes" it to the AWS EC2 Cloud Vault.
    - Efficiency: Use rsync with compression to save on AWS data transfer costs.
    

---

## Summary of Steps

### Local steps:

- Launch VMs: Install AlmaLinux & Debian; establish network connectivity (ping test).
- Configure Logging: Enable UDP/TCP reception in rsyslog on the Log Server; point Web Server to it.
- Harden Systems: Set up SSH keys, change ports, and lock down accounts.
- Deploy Services: Install Nginx; create the "Watchdog" restart script.
- Automate: Schedule the remote backup script and disk monitor via Crontab.
- Simulate Attack: Attempt 5 failed logins on the Web Server; use grep on the Log Server to prove the logs were captured remotely.
- Document: Record every troubleshooting step, especially how you handled cross-distro differences (like Debian using /var/log/syslog vs AlmaLinux Linux using journald).

### Cloud Integration steps:

- Provision the AWS EC2 instance; configure Security Groups.
- Establish the secure tunnel between the Local Log Server and AWS.
- Configure the Cloud Proxy to serve the local website to the public.
- Schedule the off-site log mirroring and cloud backups.
- Simulate a local "disaster" (shut down a local VM) and verify that the Cloud Sentinel sends an alert.
