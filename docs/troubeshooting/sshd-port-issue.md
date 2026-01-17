# **sshd-port-issue**

```bash
## Issue: sshd failed to restart after changing SSH port

### Error
```

Bind to port 2222 failed: Permission denied

fatal: Cannot bind any address

```bash
### Cause
On some Linux (RHEL-based), **SELinux** blocks SSH from biding to non-standard ports by default

### Diagnosis
```bash 
journalctl -xeu sshd.service
```

Confirmed SELinux enforcement:

```bash
getenforce
```

Resolution

Allows SSH to use port 2222:

```bash
sudo dnf install policycoreutils-python-utils -y 
sudo semanage port -a -t ssh_port_t -p tcp 2222
sudo systemctl restart sshd
```

Result started successfully on port 2222.
