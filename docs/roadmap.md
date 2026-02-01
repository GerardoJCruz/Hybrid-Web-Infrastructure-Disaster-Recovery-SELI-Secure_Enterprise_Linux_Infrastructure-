# Roadmap

This is the big picture of the roadmap used to develop this project successfully from the beggining to the end. The pourpuse of this specific document is give you a general idea of the two main phases and the small stages taken in this project, starting with the local lab configuration in the first phase and moving to the cloud integration in the second phase. 

Project Local Infrastructure: 

- Host (Physical Device): AlmaLinux 9.7
- Web-prod-01: AlmaLinux 10.1
- Log-monitor-01: Debian 13.2

Isolated Network: 

- IPv4 Address: 192.168.56.0
- IPv4 Network Mask: 255.255.255.0

Phase 1: Local Infrastructure (On-Prem)

Stage 1: Base OS Deployment (AlmaLinux & Ubuntu Minimal installs).

Stage 2: Identity & Access Control (Users, Groups, Sudoers).

Stage 3: Network Hardening (Static IPs, Hostnames, SSH Keys, Port Changes).

Stage 4: Service Deployment (Nginx Web Server & Centralized rsyslog).

Stage 5: Local Defense (Firewalld/UFW & Fail2ban).

Pillar 2: Hybrid Integration (Cloud)

Stage 6: AWS Provisioning (EC2, Security Groups, IAM).

Stage 7: The Tunnel Bridge (SSH Reverse Tunneling & Persistence).

Stage 8: Cloud Gateway (AWS Nginx Proxy & Public Exposure).

Stage 9: Monitoring & DR (Off-site Backups & Uptime Alerts).
