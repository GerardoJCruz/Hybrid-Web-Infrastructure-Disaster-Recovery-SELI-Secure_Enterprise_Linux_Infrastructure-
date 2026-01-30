#Stage 8: The Tunnel Bridge (SSH Reverse Tunneling) 

## The Goal: Use an SSH Reverse Tunnel to create an encrypted, outbound link from the local lab to AWS, effectively "punching a hole" through the router without opening any dangerous ports on the local firewall. 
- Traffic Hitting Port 8080 on AWS EC2 will be "tunneled" down to Port 80 to the local Web Server. 
- Persistence: Use systemd to ensure that if the internet blips or the server reboots, the tunnel autoamtically reconnects. 

## Steps Execution

1. Prepare the "Handshake" (Local to Cloud)
First, local web server needs to be able to log into AWS without a password prompt using SSH Keys. 
	- On web-prod-01 (Local VM): Copy the AWS .pem key onto the VM using SCP or just copy-paste the text into a new file. 
	- Test the manual connection.

2. Configure SSH Gateway Port (On AWS EC2)
By default, AWS won't let tunnels bind to public interface. 
	- Change the line ```GatewayPorts yes``` on /etc/ssh/sshd_config
	- Restart SSH on AWS

3. Create the Persistent Tunel (On Local VM)
	- Create a systemd service so the tunnel starts on boot. 
 	- Configure the file. (Configuration added in /scripts/local)

4. Start and Enable the tunnel. 

## Verification: Key points to guarantee stage was successful
- On cloud-sentinel-01 (AWS) run: ``netstat -tuln | grep 8080``
- Cloud-to-local Test: Try to fetch the local website
 
