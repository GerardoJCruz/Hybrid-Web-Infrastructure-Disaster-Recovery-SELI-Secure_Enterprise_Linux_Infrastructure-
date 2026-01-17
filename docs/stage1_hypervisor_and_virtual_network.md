## Stage 1: Hypervisor & Virtual Networking

## The goal: 
To create the virtual environment on host laptop (AlmaLinux for this project) using KVM. Building a "Dual-homed" network: 
- NAT Adapter: Provides the VMs with internet access (for downloading packages).
- Host-Only Adapter: A private internal "switch" where the VMs talk to each other and your laptop, away from the public internet. 

## Virtual Private Switch Configuration: Generate a new Host-only Network.

- IPv4 Address: 192.168.56.1
- IPv4 Network Mask: 255.255.255.0 
- DHCP Server: uncheck

## Build the VM "Shells":
Create the hardware containers. Do not start installation yet. 

Node 1: web-prod-01
1. Name: web-prod-01
2. Type: Linux | Version: AlmaLinux (64-bit) - (RHEL-based)
3. Network Settings:
	- Adapter 1: Enable. Attached to: NAT
	- Adapter 2: Enable. Attached to: Host-only Adapter

Node 1:	sec-monitor-01
1. Name: sec-monitor-01
2. Type: Linux | Version: Debia (64-bit) 
3. Network Settings:
        - Adapter 1: Enable. Attached to: NAT
        - Adapter 2: Enable. Attached to: Host-only Adapter

