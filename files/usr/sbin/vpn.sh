CADIR=/etc/CA
CACERT=$CADIR/caCert.pem
CAKEY=$CADIR/caKey.pem
SERVERCERT=$CADIR/serverCert.pem
SERVERKEY=$CADIR/serverKey.pem
KEYSIZE=1024
DAYS=1825
P12PASS=openwrt

. /lib/functions/network.sh
network_get_ipaddr wan_ip wan
network_get_ipaddr lan_ip lan

test -x /www/vpn || mkdir /www/vpn

buildca () {
  mkdir -p $CADIR
  ipsec pki --gen --outform pem -s $KEYSIZE > $CAKEY
  ipsec pki --self --lifetime $DAYS --in $CAKEY --dn "CN=OpenWrt CA" --ca --outform pem > $CACERT
  ln -sf $CACERT /www/vpn/CA.pem
  ln -sf $CACERT /etc/ipsec.d/cacerts/
}

builddh () {
  openssl dhparam -out $CADIR/dh.pem $KEYSIZE
}

buildserver () {
  # Create key/cert
  openssl genrsa -out $SERVERKEY $KEYSIZE
  ipsec pki --pub --in $SERVERKEY | ipsec pki --issue --lifetime $DAYS --cacert $CACERT --cakey $CAKEY --dn "CN=$1" --san="$1" --flag serverAuth --flag ikeIntermediate --outform pem > $SERVERCERT
  # Create symlink for key/cert in strongSwan directories
  ln -sf $SERVERKEY /etc/ipsec.d/private/
  ln -sf $SERVERCERT /etc/ipsec.d/certs/
  # Change leftid
  sed -i s/leftid.*/leftid=$1/ /etc/ipsec.conf
}

buildclient () {
  # Create key/cert 
  CLIENTKEY=$CADIR/${1}Key.pem
  CLIENTCERT=$CADIR/${1}Cert.pem
  CLIENTP12=/www/vpn/$1.p12
  openssl genrsa -out $CLIENTKEY $KEYSIZE
  ipsec pki --pub --in $CLIENTKEY | ipsec pki --issue --lifetime $DAYS --cacert $CACERT --cakey $CAKEY --dn "CN=$1" --san "$1" --flag clientAuth --outform pem > $CLIENTCERT
  openssl pkcs12 -export -out /www/vpn/$1.p12 -inkey $CLIENTKEY -in $CLIENTCERT -certfile $CACERT -password pass:$P12PASS
  # Create .ovpn profile
  CA=`cat $CACERT`
  CERT=`awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' $CLIENTCERT`
  KEY=`cat $CLIENTKEY`
  cat /etc/templates/ovpn.template | awk '{gsub("WANIP",x)}1' x="$wan_ip" | awk '{gsub("CA",x)}1' x="$CA" | awk '{gsub("CLIENTCERT",x)}1' x="$CERT" | awk '{gsub("CLIENTKEY",x)}1' x="$KEY" > /www/vpn/$1.ovpn
  # Create iOS profile
  #CERT=$(sed -n '/BEGIN/,/END/p' $CACERT | sed '/BEGIN/d' | sed '/END/d')
  #CLIENTP12B64=$(openssl base64 -in $CLIENTP12)
  #cat /etc/templates/ios-ikev2.template | awk '{gsub("WANIP",x)}1' x="$wan_ip" | awk '{gsub("CLIENTNAME",x)}1' x="$1" | awk '{gsub("P12PASS",x)}1' x="$P12PASS" | awk '{gsub("CLIENTP12B64",x)}1' x="$CLIENTP12B64" | awk '{gsub("CERT",x)}1' x="$CERT" > /www/vpn/$1.mobileconfig
}

clean () {
  rm -f $CADIR/*.pem
  rm -f /www/vpn
  cp /rom/etc/CA/dh.pem $CADIR/
}

case $1 in 
  buildca)
    buildca > /dev/null 2>&1
    echo "CA built in $CADIR."
    echo "Certificate can be downloaded at https://$lan_ip/vpn/caCert.pem"
  ;;
  builddh)
    builddh
    echo "DH created."
  ;;
  buildserver)
    [ ! -z "$2" ] && wan_ip="$2"
    if [ -z "$wan_ip" ]; then
      echo "No WAN IP found and none specified."
      echo "Usage: $0 buildserver my.ddns.com"
      exit 0
    fi
    buildserver $wan_ip >> /tmp/vpn.sh.log 2>&1
    echo "Server certificate for $wan_ip built"
    echo "You should restart ipsec/openvpn/uhttpd as needed"
  ;;
  buildclient)
    if [ -z "$2" ]; then
      echo "No client name specified."
      echo "Usage: $0 buildclient myclient [optional ddns name or wan ip]"
      exit 0
    fi
    [ ! -z "$3" ] && wan_ip="$3"
    if [ -z "$wan_ip" ]; then
      echo "No WAN IP found and none specified."
      echo "Usage: $0 buildclient myclient [optional ddns name or wan ip]"
      exit 0
    fi
    buildclient $2 >> /tmp/vpn.sh.log 2>&1
    echo "OpenVPN profile can be downloaded at https://$lan_ip/vpn/$2.ovpn"
    echo "iOS IKEv2 profile can be downloaded at https://$lan_ip/vpn/$2.mobileconfig"
    echo "PKCS12 certificate bundle can be downloaded at https://$lan_ip/vpn/$2.p12"
  ;;
  clean)
    clean
  ;;
  *)
    echo "Usage: $0 [buildca|builddh|buildserver|buildclient|clean]"
  ;;
esac
