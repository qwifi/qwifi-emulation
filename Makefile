emulate: update-config
	killall hostapd || true

	sudo service network-manager stop || true
	sudo service nslcd stop || true
	sudo service aiccu stop || true

	sudo service mysql restart
	sudo service freeradius restart

	sudo hostapd hostapd.conf -B
	sudo ifconfig wlan0 10.0.0.1/8

	sudo service isc-dhcp-server restart
	sudo service apache2 restart

	echo "Entered emulation mode."

setup: pyqrencode
	sudo apt-get install hostapd apache2 freeradius freeradius-mysql isc-dhcp-server libqrencode3 libqrencode-dev mysql-server libapache2-mod-wsgi
	sudo bash -c 'echo "manual" > /etc/init/hostapd.override'
	sudo bash -c 'echo "manual" > /etc/init/isc-dhcp-server.override'

	sudo service mysql restart
	sudo mysql -p -u root < freeradius.sql || true
	sudo mysql -p -u root radius < freeradius-conf/sql/mysql/schema.sql || true
	sudo service mysql stop

pyqrencode:
	sudo apt-get install git python-dev
	git clone https://github.com/bitly/pyqrencode.git /tmp/pyqrencode || true
	cd /tmp/pyqrencode && sudo python setup.py install

update-config:
	sudo cp -vaur freeradius-conf/* /etc/freeradius/
	sudo chown -R root:freerad /etc/freeradius/*
	sudo cp -vaur dhcpd.conf /etc/dhcp/dhcpd.conf

normal:
	sudo killall hostapd || true
	sudo service freeradius stop || true
	sudo service mysql stop || true
	sudo service isc-dhcp-server stop || true
	sudo service apache2 stop || true

	sudo service network-manager restart

	echo "Normalization complete"
