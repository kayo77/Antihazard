#!/bin/bash
curl -k --silent -H "Accept: application/xml" -H "Content-Type: application/xml" -X GET https://hazard.mf.gov.pl/api/Register | \
     grep "AdresDomeny" | awk -F "<AdresDomeny>" '{print $2}' | \
     idn2 | awk -F "</adresdomeny>" '{print  "zone \""$1"\" {type master; file \"/etc/bind/hazard.hosts\";};" }'| uniq > /tmp/hazard.zones
 
/usr/sbin/named-checkzone /tmp/hazard.zones /etc/bind/hazard.hosts
if [ $? -eq 0 ]
then
    cp -u --preserve=mode,ownership /tmp/hazard.zones /etc/bind/hazard.zones
    /usr/sbin/rndc reload
    rm /tmp/hazard.zones
else
    echo "ERROR hazard!"
fi
 
curl -k --silent -H "Accept: application/xml" -H "Content-Type: application/xml" -X GET https://hole.cert.pl/domains/domains.xml | \
     grep "AdresDomeny" | awk -F "<AdresDomeny>" '{print $2}' | \
     idn2 | awk -F "</adresdomeny>" '{print  "zone \""$1"\" {type master; file \"/etc/bind/certplbh.hosts\";};" }' | uniq > /tmp/certplbh.zones
/usr/sbin/named-checkzone /tmp/certplbh.zones /etc/bind/certplbh.hosts
if [ $? -eq 0 ]
then
    cp -u --preserve=mode,ownership /tmp/certplbh.zones /etc/bind/certplbh.zones
    /usr/sbin/rndc reload
    rm /tmp/certplbh.zones
else
    echo "ERROR cert!"
fi
