## Stage 2: Base OS Deployment

This stage ensures:
- Clean OS installs
- Minimal attack surface
- Network connectivity
- SSH availability

## The Goal 
To install the operating systems on both nodes with a "Minimal" footprint
- web-prod-01: AlmaLinux-10.1 (64-bit) (Minimal Install) - Web Production
- sec-monitor-01: Debian Server-13.2 - Security & Monitoring

## AlmaLinux Setup
1. Language: English (United States)
2. Software Selection: Minimal install. (No server with GUI)
3. Network & Host name: 
	- Hostname: web-prod-01.local
	- Ensure Ethernet (NAT) is ON to get an IP for updates. 
4. Root Password: Strong password (Disable root login later)
5. User Creation: Create user named admin (or prefered  name)
6. SSH Setup: Install OpenSSH Server 

## Debian Setup
1. Language: English (United States)
2. Software Selection: Minimal install.	(No server with GUI)
3. Network & Host name:	
        - Hostname: sec-monitor-01.local
        - Ensure Ethernet (NAT)	is ON to get an	IP for updates.	
4. Root Password: Strong password (Disable root login later)
5. User	Creation: Create user named admin (or prefered  name)
6. SSH Setup: Install OpenSSH Server

# Verification Checklist
-Login works with created user
-Internet connectivity (ping google.com)
-No GUI on Servers
-SSH running on Debian (systemctl status ssh)

# Troubleshooting Stage 2

- "Black Screen on Boot": Ensure you "Ejected" the ISO from the VKM settings after the installation finished, otherwise it might try to install again.
- "No Internet": Check the VirtualBox Network settings. Adapter 1 must be NAT. If it still fails, run sudo dhclient inside the VM.
