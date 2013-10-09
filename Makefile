emulate: update-config
	killall hostapd || true

	service network-manager stop || true
	service nslcd stop || true
	service aiccu stop || true

	service mysql restart
	service freeradius restart

	hostapd hostapd.conf -B
	ifconfig wlan0 10.0.0.1/8

	service isc-dhcp-server restart
	service apache2 restart

	echo "Entered emulation mode."

setup: setup-apache setup-pyqrencode setup-freeradius setup-service
	apt-get install hostapd isc-dhcp-server mysql-server python-mysqldb
	bash -c 'echo "manual" > /etc/init/hostapd.override'
	bash -c 'echo "manual" > /etc/init/isc-dhcp-server.override'

	service mysql restart
	mysql -p -u root < freeradius.sql || true
	mysql -p -u root radius < freeradius-conf/sql/mysql/schema.sql || true
	service mysql stop

setup-freeradius:
	apt-get install freeradius freeradius-mysql 
	mkdir -p /etc/freeradius
	cp -vaur freeradius-conf/* /etc/freeradius/
	chown -R root:freerad /etc/freeradius

setup-pyqrencode:
	apt-get install git python-dev libqrencode3 libqrencode-dev python-imaging
	git clone https://github.com/bitly/pyqrencode.git /tmp/pyqrencode || true
	cd /tmp/pyqrencode && python setup.py install

setup-apache:
	apt-get install apache2 libapache2-mod-wsgi
	cp ui/qwifi-site /etc/apache2/sites-available/qwifi
	rm -f /etc/apache2/sites-enabled/000-default
	ln -sf /etc/apache2/sites-available/qwifi /etc/apache2/sites-enabled/000-qwifi

	#copy scripts
	mkdir -p /usr/local/wsgi/scripts/
	#make sure the destination is clean
	rm -rf /usr/local/wsgi/scripts/*
	cp -vaur ui/scripts/* /usr/local/wsgi/scripts/

	#copy templates
	mkdir -p /usr/local/wsgi/templates/
	#make sure the destination is clean
	rm -rf /usr/local/wsgi/templates/*
	cp ui/resources/html/base.txt /usr/local/wsgi/templates/base

	groupadd -f qwifi
	usermod -a -G qwifi www-data

	mkdir -p /var/www/config
	chown www-data:www-data /var/www/config

setup-service:
	apt-get install python-daemon

update-config:
	cp -vaur freeradius-conf/* /etc/freeradius/
	chown -R root:freerad /etc/freeradius/*
	cp -vaur dhcpd.conf /etc/dhcp/dhcpd.conf
	cp -vaur ui/scripts/* /usr/local/wsgi/scripts/

normal:
	killall hostapd || true
	service freeradius stop || true
	service mysql stop || true
	service isc-dhcp-server stop || true
	service apache2 stop || true

	service network-manager restart

	echo "Normalization complete"
