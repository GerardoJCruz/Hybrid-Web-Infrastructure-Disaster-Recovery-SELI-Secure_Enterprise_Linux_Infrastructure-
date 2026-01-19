# Stage 4: Network Hardening

To ensure the servers always have the same address so they can find each other reliably. Also secure the SSH to prevent unauthorized access.

- Internal Subnet: 192.168.56.9/24
- web-prod-01 Static IP: 192.168.56.10
- sec-monitor-01 IP: 192.168.56.20

## Steps executions

- Static IP Configuration (AlmaLinux - web-prod-01)
1. Identify the interface name
2. Configure the static IP
- Static IP Configuration (Debian - sec-monitor-01)
1. Identify the interface name
2. Edit the netplan file - /etc/netplan (the filename varies)
3. Update the file with the corresponding interface and IP.
4. Save and apply changes

## Hostname Resolution

Update the /etc/hosts file for both VMs to allow them to talk via names instead of IPs.

## SSH Hardening

Change the default SSH port to 2222 and disable root login. This applies for both VMs.

## Verification: Key points to guarantee stage 4 was successful

- Ping Testing: execute a ping from web-prod-01 to sec-monitor-01, and sec-monitor-01 to web-prod-01
- SSH Port Testing: establish an SSH connection from Host to web-prod-01 using new port.
