## Stage 3: Identity & Access Control

# The Goal: 
To establish a secure user hierarchy. Create dadicated administrative group, assign the admin user, and configure sudo (SuperUser Do)
so that all administrative actions are logged and authorized. 

1.  Create the Administrative Group.
	- Group name: labadmins
2.  Assign Admin user to Group.
3.  Configure sudoers Permissions
4.  Set Security Policy: Password Policy
	- PASS_MAX_DAYS 90
	- PASS_MIN_DAYS 1
	- PASS_WARN_AGE 7

# Verification: 
To confirm Stage 3 is successful: 
- Verify group appears in the Admin list. 
- If group appeas asks for Admin password and returns root
- Audit Check

# Potential Troubleshooting Stage 3

- "User is not in the sudoers file": This happens when the visudo edit is not saved corectly. Log in as root (Using su -) to fix it. 
- Group already exists: This means the command was accidentally run twice. 
