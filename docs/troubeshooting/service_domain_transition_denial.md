# Troubleshooting SELinux Domain Transitions.

## The Conflict: SELinux "Least privilege"

SELinux (Security-Enhanced Linux) works on the principle that even if you are root, you	shouldn't be allowed to do things that your "role" doesn't require.

- The Actor: systemd (running in the init_t context).
- The Action: Execute /usr/bin/ssh.
- The Target: A	binary labeled ssh_exec_t.

## The Clue: Exit Code 203/EXEC.

- Code 200-242 are internal systemd error codes.
- 203 specifically means: "Tried to start the program told to start, but the operating system said 'No' before the program even started."

## Deduction process;

1. Check Service Status: is it running? No. Does it have an error code? Yes, 203.
2. Verify Path & Permissions: Does /usr/bin/ssh exist? Yes. Is the key file there? Yes. Are permissions 600? Yes.
3. Check the "Killer" (SELinux): If the	file are there and the user is root, but it still can't	"Execute", it's almost always SELinux.
4. Read the Hear of the System: Check `/var/log/audit/audit.log`. Every time SElinux "denies" something, it writes a line there called and AVC (Access Vertor Cache) denail.

## Debugging Process:

Run:

```bash
sudo ausearch -m AVC -ts recent

```

## Reading the AVC Denial.

```bash
type=AVC msg=...: avc: denied { read open } for pid=3541 comm="(ssh)" path="/usr/bin/ssh" scontext=system_u:system_r:init_t:s0 tcontext=system_u:object_r:ssh_exec_t:s0 tclass=file
```

- denied {read open}: The action that was stopped.
- scontext (Source Context): `init_t` this is the “Label” of the process trying to do the action (in this case, systemd).
- tcontext (Target Context): `ssh_exec_t`. This is the “Label” of the file being acted upon (`/usr/bin/ssh`).
- tclass=file: The type of object (a file, not a directory or a socket).

The Logic: SELinux has a rulebook. It looked for a rule that said: “Allow `init_t` to read/open a file labeled `ssh_exec_t`.” It didn’t find that rule, so it killed the process instantly. 

## Tools of the Trade:

Three specific tools were used:

1. Search the Audit logs;

```bash
sudo ausearch -m AVC -ts recent
```
Note: audit2allow can sometimes be too "quiet." You might want to add a line at the end about resetting the audit behavior:
```bash
# Optional: Reset SELinux to standard logging levels
sudo semodule -B
```

To find the exact “denied” message without scrolling through **thousands** of lines. 

2. The “Translator”:

```bash
sudo grep "autossh-tunnel" /var/log/audit/audit.log | audit2allow -M my_ssh_tunnel
```

It reads the “denied” message and automatically writes the code needed to allow it. 

3. The “Installer”:

```bash
sudo semodule -i my_ssh_tunnel.pp
```

It takes the code from `audit2allow` and injects it into the running Linux Kernel. 

With this custom module we give to the SSH tunnel the “VIP” permissions it needs. And therefor we avoid to git init_t permissive permission. 

Note: SELinux troubleshooting is iterative. Once you grant permission to execute the file, you may find new denials for reading the SSH key or accessing the network. 
We repeat the process until all layers are cleared.

4. Restart and custom module works: 

Restart the autossh-tunnel service.

```bash
sudo systemctl restart autossh-tunnel

# Check the status:
sudo systemctl status autossh-tunnel

#Example of ouput: 
● autossh-tunnel.service - Reverse SSH Tunnel to AWS
     Loaded: loaded (/etc/systemd/system/autossh-tunnel.service; enabled; preset: disabled)
     Active: active (running) since Mon 2026-01-26 05:38:34 CST; 10s ago
 Invocation: 15
   Main PID: 5345 (ssh)
      Tasks: 1 (limit: 4241)
     Memory: 1.9M (peak: 2M)
        CPU: 38ms
     CGroup: /system.slice/autossh-tunnel.service
             └─5345 /usr/bin/ssh -NT -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -i /etc/ssh/tunnel_keys/lab-cloud-key.pem -R 8080:localhost:80 ec2-user@<EC2_IP_ADDRESS>

Jan 26 05:38:34 web-prod-01.local systemd[1]: Started autossh-tunnel.service - Reverse SSH Tunnel to AWS.

```

## Check the system is Enforcing global security:

```bash
[admin@web-prod-01 ~]$ getenforce
Enforcing
[admin@web-prod-01 ~]$ sudo semodule -l | grep permissive 
permissivedomains
[admin@web-prod-01 ~]$ sudo semanage permissive -l 

Builtin Permissive Types 

systemd_hibernate_resume_t
powerprofiles_t
systemd_zram_generator_t
systemd_import_generator_t
virtqemud_t
coreos_liveiso_autologin_generator_t
systemd_generic_generator_t
virtvboxd_t
anaconda_generator_t
coreos_boot_mount_generator_t
qgs_t
systemd_nfs_generator_t
switcheroo_control_t
systemd_pcrlock_t
virtstoraged_t
coreos_installer_generator_t
systemd_user_runtimedir_t
systemd_tpm2_generator_t
coreos_sulogin_force_generator_t
virtsecretd_t
systemd_mountfsd_t
tuned_ppd_t
systemd_pcrextend_t
bootupd_t
ktlshd_t
```

## Check the connection from the EC2 instance.

Commands run in EC2 instances to confirm the tunneling is working. 

```bash
# Verify port 8080 is listening. 
[ec2-user@cloud-sentinel-01 ~]$ sudo ss -tulpn | grep :8080
tcp   LISTEN 0      128                            0.0.0.0:8080      0.0.0.0:*    users:(("sshd",pid=603399,fd=8))                           
tcp   LISTEN 0      128                               [::]:8080         [::]:*    users:(("sshd",pid=603399,fd=9))                           

# Fetch the web. 
[ec2-user@cloud-sentinel-01 ~]$ curl http://localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

