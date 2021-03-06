emulate: ui sync-config
	service avahi-daemon stop || true
	service network-manager stop || true
	service nslcd stop || true
	service aiccu stop || true

	service freeradius restart

	service hostapd restart
	ifconfig wlan0 10.0.0.1/8

	service isc-dhcp-server restart

	echo "Entered emulation mode."

pi: ui sync-config
	service freeradius restart
	service hostapd restart

ui: sync-ui
	kill `cat /var/run/qwifi.pid` || true
	service mysql restart
	service apache2 restart
	PYTHONPATH=/usr/local/wsgi/resources/python service/src/qwifi.py -c /var/www/config/current

setup: setup-apache setup-pyqrencode setup-freeradius setup-service setup-hostapd
	apt-get install isc-dhcp-server mysql-server python-mysqldb
	bash -c 'echo "manual" > /etc/init/isc-dhcp-server.override'

	service mysql restart
	mysql -p -u root < freeradius.sql || true
	mysql -p -u root radius < freeradius-conf/sql/mysql/schema.sql || true
	service mysql stop

setup-hostapd:
	apt-get install hostapd
	bash -c 'echo "manual" > /etc/init/hostapd.override'
	
	cp -vaur hostapd.conf /etc/hostapd/hostapd.conf
	groupadd -f qwifi
	chown root /etc/hostapd/hostapd.conf
	chgrp qwifi /etc/hostapd/hostapd.conf
	chmod g+w /etc/hostapd/hostapd.conf
	
	cp -vaur hostapd.defaults /etc/default/hostapd

setup-freeradius:
	apt-get install freeradius freeradius-mysql 
	mkdir -p /etc/freeradius
	cp -vaur freeradius-conf/* /etc/freeradius/
	chown -R root:freerad /etc/freeradius

setup-pyqrencode:
	apt-get install git python-dev libqrencode3 libqrencode-dev python-imaging
	git clone https://github.com/bitly/pyqrencode.git /tmp/pyqrencode || true
	cd /tmp/pyqrencode && python setup.py install

setup-apache: sync-ui
	apt-get install apache2 libapache2-mod-wsgi python-pip

	pip install python-dateutil

	cp ui/qwifi-site /etc/apache2/sites-available/qwifi
	rm -f /etc/apache2/sites-enabled/000-default
	ln -sf /etc/apache2/sites-available/qwifi /etc/apache2/sites-enabled/000-qwifi

	groupadd -f qwifi
	usermod -a -G qwifi www-data

	mkdir -p /var/www/config
	mkdir -p /var/www/codes
	chown -R www-data:www-data /var/www

	cp -vaur servicers /etc/sudoers.d/servicers
	chown root:root /etc/sudoers.d/servicers
	chmod 440 /etc/sudoers.d/servicers

setup-service:
	apt-get install python-daemon

sync-config:
	cp -vaur freeradius-conf/* /etc/freeradius/
	chown -R root:freerad /etc/freeradius/*
	cp -vaur dhcpd.conf /etc/dhcp/dhcpd.conf
	
	cp -vaur hostapd.conf /etc/hostapd/hostapd.conf
	groupadd -f qwifi
	chown root /etc/hostapd/hostapd.conf
	chgrp qwifi /etc/hostapd/hostapd.conf
	chmod g+w /etc/hostapd/hostapd.conf

sync-ui:
	#copy scripts
	mkdir -p /usr/local/wsgi/scripts/
	#make sure the destination is clean
	rm -rf /usr/local/wsgi/scripts/*
	cp -vaur ui/scripts/* /usr/local/wsgi/scripts/

	#copy resources
	mkdir -p /usr/local/wsgi/resources/
	#make sure the destination is clean
	rm -rf /usr/local/wsgi/resources/*
	cp -vaur ui/resources/* /usr/local/wsgi/resources/

normal:
	kill `cat /var/run/qwifi.pid` || true
	service hostapd stop || true
	service freeradius stop || true
	service mysql stop || true
	service isc-dhcp-server stop || true
	service apache2 stop || true

	service network-manager restart || true
	service avahi-daemon restart || true

	echo "Normalization complete"
