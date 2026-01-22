#!/bin/bash
# Configure sec-monitor-01 to recieve logs
#Targe: sec-monitor-01

configure_rsyslog_receiver() {
	CONF="/etc/rsyslog.d/10-udp-receiver.conf"
	
	sudo tee "$CONF" > /dev/null <<EOF
module(load="imudp")
input(type="imudp" port="514")
EOF
	fi 

	sudo rsyslogd -N1
	sudo systemctl restart rsyslog
}

configure_rsyslog_receiver

echo "ryslog configured successfuly. "
