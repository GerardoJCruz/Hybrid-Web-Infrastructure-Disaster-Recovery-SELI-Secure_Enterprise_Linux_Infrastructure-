# Stage 9: Cloud Gateway (Nginx Reverse Proxy).

## Goal: Transform the AWS EC2 instance from a simple tunnel endpoint into a professional Reverse Proxy. 
## Instead of users accessing the site on port like 8080, they will access it on standard Web Port (80). 
## AWS Nginx will "mask" the local private infrastructure, providing security and a professional front-end. 

To configure Nginx on the AWS cloud-sentinel-01 to act as a traffic director:
- User Request: A user hits http://<AWS_PUBLIC_IP>.
- Nginx Action: AWS Nginx receives the request and "proxies" it through the SSH tunnel to localhost:8080
- Result: The user sees the local web content, but their connection ends at AWS. Local IP remains private. 

## Steps Execution.

1. Install Nginx on AWS. 
2. Configure the Reverse Proxy. 
	Indicate to Nginx to forward traffic to the tunnel port (8080) previously established.
3. SELinux Adjustment (Crucial Step)
	For Linux Systems with SELinux enabled, it may block Nginx from connecting to the network port 8080. 

## Verification: Key points to guarantee stage was successful

- The Public Browser Test: From another device (desk computer, laptop, tablet or phone with connection to internet), open a browser and enter your AWS Public IP.
- The Log Verification:Check the Nginx access logs on AWS to see your request arriving. 
- The "Hidden IP" check: Check the logs on your local web-prod-01. You should see the request coming from 127.0.0.1 (the tunnel), not from the external device's public IP. 
 

