emulate:
	#sudo service freeradius start
	killall hostapd || true

	sudo service network-manager stop || true

	sudo hostapd hostapd.conf -f hostapd.log -B -d
	sudo ifconfig wlan0 10.0.0.1/8
	echo "Entered emulation mode."

	sudo service isc-dhcp-server start || true

build:
	sudo apt-get install hostapd apache2 freeradius isc-dhcp-server libqrencode3 libqrencode-dev
	sudo bash -c 'echo "manual" > /etc/init/apache2.override'
	sudo bash -c 'echo "manual" > /etc/init/hostapd.override'
	sudo bash -c 'echo "manual" > /etc/init/freeradius.override'
	sudo bash -c 'echo "manual" > /etc/init/isc-dhcp-server.override'

normal:
	sudo service freeradius stop || true
	sudo service isc-dhcp-server stop || true
	sudo killall hostapd || true

	sudo service network-manager start || true

	echo "Normalization complete"
