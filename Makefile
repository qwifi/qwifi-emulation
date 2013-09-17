emulate: build
	killall hostapd || true

	sudo service network-manager stop || true
	sudo service nslcd stop || true
	sudo service aiccu stop || true

	sudo service mysql start || true
	sudo service freeradius start || true

	sudo hostapd hostapd.conf -f hostapd.log -B -d
	sudo ifconfig wlan0 10.0.0.1/8

	sudo service isc-dhcp-server start || true
	sudo service apache2 start || true

	echo "Entered emulation mode."

build:
	sudo apt-get install hostapd apache2 freeradius isc-dhcp-server libqrencode3 libqrencode-dev mysql-server
	sudo bash -c 'echo "manual" > /etc/init/hostapd.override'
	sudo bash -c 'echo "manual" > /etc/init/isc-dhcp-server.override'

	sudo cp -vaur freeradius-conf/* /etc/freeradius/
	sudo chown -R root:freerad /etc/freeradius/*
	sudo cp -vaur dhcpd.conf /etc/dhcp/dhcpd.conf

normal:
	sudo killall hostapd || true
	sudo service freeradius stop || true
	sudo service mysql stop || true
	sudo service isc-dhcp-server stop || true
	sudo service apache2 stop || true

	sudo service network-manager start || true

	echo "Normalization complete"
