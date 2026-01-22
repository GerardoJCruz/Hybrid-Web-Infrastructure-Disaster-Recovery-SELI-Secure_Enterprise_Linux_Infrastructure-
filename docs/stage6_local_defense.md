# Stage 6: Local Defense (Firewall & Fail2ban)

## The Goal:

To move	from an	"open" system to a Default Deny	posture.

- Firewalls: Only allow	specific traffic (SSH on 2222, Web on 80, Logs on 514).
- Fail2ban: Monitor the	SSH logs previously hardened and ban any IP that fails to log in 3 times.

## Steps Execution

1. Firewall Configuration: web-prod-01.
Remove default services and only allow what is needed (AlmaLinux uses firewalld):
- Start	and enable the firewalld.
- Allow	custom SSH port	and HTTP.
- Remove the default SSH service (port 22) for safety.
- Apply	changes	and verify.
2. Firewall Configuration: sec-monitor-01.
Debian uses ufw:
- Allow	custom SSH and the Log Receiver	port (UDP 514).
- Enable the firewall.
3. Fail2ban Implementation.
Fail2ban works the same	on both	OS. Point to the custom	SSH port.
- Install Fail2ban in AlmaLinux.
- Install Fail2ban in Debian.
4. Configure the SSH jail: Create a local configuration	file (never edit jail.conf directly)

## Verification: Key points to guarantee stage was successful

- Check	Fail2ban Status: Verify	"Currently banned" is 0	and the	port is	2222
- Test Firewall	Connectivity: Run ping from Host to both servers.
<n yourself run: `sudo fail2ban-client set sshd unbanip HOST_IP`.
