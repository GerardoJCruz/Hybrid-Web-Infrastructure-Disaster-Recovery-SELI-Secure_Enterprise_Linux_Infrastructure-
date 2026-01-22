# Service Deployment (Nginx & Centralized Logging)

## The Goal:

To install the primary services	and establish the "North-South"	data flow.

- web-prod-01: Will host a web server (Nginx)
- Sec-monitor-01: Will act as Central Log Collector using rsyslog.
- Objective: Every time	someone	accesses the website or	tries to log in	the Web server,	that event should be sent across the network to	the Monitor server.

## Steps Execution

1. Web Server Setup: web-prod-01.
- Install Nginx.
- Enable and Start Nginx.
- Create the Landing Page.
The Web Server will deploy a CSS, JS & HTML project of mine hosted in GitHub. I'll shared the link and feel free to use it too:	https://github.com/GerardoJCruz/coffe-gc
2. Configure Central Log Receiver: sec-monitor-01.
We need	to tell	the Debian server to listen for	logs coming from other machines	over the network.
- Edit rsyslog config.
- Uncomment the	lines that enable UDP reception.
- Restart the service
3. Configure Log Forwarding: web-prod-01
- Create a forwarding rule.
- Point to your Static IP previously configured.
- Restart the service.

## The verification: Key points to guarantee stage 4 was successful

To confirm this	stage was successful, you must see "Remote" logs	appearing on your Monitor server.

- Test the Web Server: From your Host, open a browser and go to	[http://192.168.56.19](http://192.168.56.19/). You should see "System Online"
- Test the Log Flow: Us the command `tail` on the sec-monitor-01 server and the command `logger` and a message like 'Test_log' to "watch" the incoming logs. If you see testing message.
