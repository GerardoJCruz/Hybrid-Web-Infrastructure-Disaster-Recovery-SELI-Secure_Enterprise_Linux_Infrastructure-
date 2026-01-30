# Stage 7: AWS Provisioning

## Goal: Set up a Cloud Sentinel. Configure a Security Group (Firewall) to ensure that only local lab can talk to the new server.

## Sentinel Server:

- Instance Type: t3.micro (Free Tier Eligible)
- OS: Amazon Linux 2023 (AL2023).
- Security Posture: Strict Whitelisting. Configure the AWS firewall to block the entire world execpt for our specific IP address.
- Name: cloud-sentinel-01

## Steps execution:

1. Launch the EC2 instance.
- Launch Instance.
- Name it: "cloud-sentinel-01".
- Create a new key pair named "lab-cloud-key". Save it and securely.
2. Configure The Security Grout (The Cloud Firewall).
Define the Inbound Rules.
- SSH (Port 22): "Source" to "My IP". (This allows only a computer from our IP to manage the server).
- Custom TCP (Port 2222): Set "Source" to "My IP". (This is use for tunneling)
- HTTP (Port 80): Set "Source" to "Anywhere" (0.0.0.0/0). (External web site visit through this port).
3. Initial Cloud Hardening.
Connect to the server via SSH from your device's terminal.
- Set Correct permissions for the downloaded key.
- Connect to the EC2.
- Update the system.
- Set Hostname.
- Install Essential Tools.

## Verification: Key points to guarantee stage was successful

1. SSH Success: Successfully log in to the EC2 from your own device's terminal.
2. Hostname Check: Runt `hostname` on the EC2. Out put should be "cloud-sentinel-01"
3. Security Audit:
- Ping from the personal device the EC2 Public IP.
- Confirm that only "My IP" is allowed in the Security Group settings.
