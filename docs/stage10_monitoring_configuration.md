# Stage 10: Monitoring and Disasterr Recovery (DR)

## Goal: Automate a backup of the local logs to the AWS Cloud and create a "Heartbeat" Script. 

- Backup: Sync local logs from sec-monitor-01 to cloud-sentinel-01. 
- Monitor: A script on AWS that checks if the tunnel is alive. 

## Steps Execution

1. Off-site Backup Automation
	Use rsync to move logs from local monitor to the cloud. 
2. The "Heartbeat" monitor
	Create a script to check the tunnel and run every 5 minutes. 

## Verification: Key points to guarantee stage was successful
1. Manual Backup: Run cloud_log_backup.sh and verify the file appears in the AWS ~/backups/ folder.
2. Failure Simulation: On the local web-prod-01 server, run sudo systemctl stop reverse-ssh-tunnel. Wait 5 minutes, then check /var/log/tunnel_monitor.log on AWS. It should show the alert. 
