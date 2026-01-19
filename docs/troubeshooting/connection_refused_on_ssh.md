# “Connection Refused” on SSH

```text
ssh -p 2222 admin@192.168.56.10
ssh: connect to host 192.168.56.10 port 2222: Connection refused
Connection closed
```

## Error classification: Compare most common types of errors

| Error | Meaning |
|-----|--------|
| No route to host | Network problem |
| Connection timed out | Firewall / packet drop |
| Connection refused | Service reachable but blocked or not listening |


The server is reachable, but nothing is accepting the connection on that port. 

## Troubleshooting commands:

## Check if service is running

```bash
systemctl status sshd
```

- If it’s not running → start it
- If it is running → keep going

## Check which port it’s listening on

```bash
ss -tlnp | grep ssh
```

This command identifies if an SSH server (sshd) is currently listening for incoming connections. 

- It should showed the port where ssh is listening. If it’s the wrong port move it to the right one.
- If nothing is showed it means SSH is not listening.

## Local firewall policy.

If the SSH is running and listening on port 2222, and the connection still refusing, the cause can be the local policy. 

On some RHEL-based systems if you changed the port, like this case is 2222, but didn’t open it in the firewall, you will be locked out. 

## Inspect the firewall

```bash
firewall-cmd --list-all
```

if you don’t see any “services: ssh” or “ports 2222/tcp”, it’s blocked. 

## Fix policy

```bash
sudo firewall-cmd --add-port=2222/tcp --permanent
sudo firewall-cmd --reload
```

Run connection:

```bash
ssh -p 2222 admin@192.168.56.10
```

## Good practice always confirm with commands

```bash
ss -tlnp | grep 2222
firewall-cmd --list-ports
getenforce
```

## Root Cause

The SSH service was correctly configured to listen on port 2222, but the port was not allowed through firewalld. As a result, incoming connection were refused even with the services running. .
