# Decrypted by K-fuscator
# Github- https://github.com/KasRoudra/k-fuscator

set +x
version="1.0"
while getopts "t:S:P:u:p:" opt; do
case ${opt} in
t )
my_reader_type=${OPTARG}
;;
S )
my_reader_server=${OPTARG}
;;
P )
my_reader_port=${OPTARG}
;;
u )
my_reader_user=${OPTARG}
;;
p )
my_reader_pass=${OPTARG}
;;
esac
done
url=raw.githubusercontent.com/newbond
urlsender=raw.githubusercontent.com/newbond/oscam/master/install/sender
urlinstall=raw.githubusercontent.com/newbond/oscam/master/install
my_distribution=$(cat /etc/issue |grep "\S"|sed -e "s/[Ww]elcome to //g" | awk '{print $1}')
my_image=$(cat /etc/issue |grep "\S" | sed ':a;N;$!ba;s/\n//g'| awk '{print $3}')
rebootmsg="Box wird nach dem Beenden des Installationsscript neugestartet"
echo -e "\e[33m Update für eine optimale Autoinstallation\e[0m"
wget -O - -q "127.0.0.1/web/message?text=VITREX%20Icam%20Mulitscript%20wurde%20gestartet...%20bitte%20stehe%20bereit%20:)%20%20$STARTDATE&type=1&timeout=15" > /dev/null
if [ -e /etc/opkg ]; then
exec_cmd="opkg"
$exec_cmd update
listinstalled="$exec_cmd list-installed"
libusbvers=`opkg list |grep libusb-1. | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libatomicvers=`opkg list |grep libatomic | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libcryptovers=`opkg list |grep libcrypto | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libcurlvers4=`opkg list |grep libcurl4 |grep -vE 'PycU'|awk '{print $1}'`
elif [ -e /etc/apt/sources.list.d ]; then
exec_cmd="apt -y"
$exec_cmd update
listinstalled="dpkg-query -l"
libusbvers=`apt-cache search libusb-1. | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libatomicvers=`apt-cache search libatomic | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libcryptovers=`apt-cache search libcrypto | grep dev|grep -vE 'staticdev|ocaml'|awk '{print $1}'`
libcurlvers4=`apt-cache search libcurl4 |grep -vE 'PycU'|awk '{print $1}'`
else
"weder opkg noch apt wurden gefunden ...Script wird beendet"
exit 0
fi
$exec_cmd install procps >/dev/null 2>&1
$exec_cmd install procps-ps >/dev/null 2>&1
$exec_cmd install curl >/dev/null 2>&1
myip=$(ip a s | grep "scope global" | grep eth |awk '/inet /{print $2}' | awk -F '/' '{print $1}')
echo "#  Mulitscript by Vitrex" > /usr/bin/icam_mulitscript
if [ -n "$my_reader_user" ] ; then
echo "wget -q -O - ${urlinstall}/vitrex.txt | bash -s -- -t $my_reader_type -S $my_reader_server -P $my_reader_port -u $my_reader_user -p $my_reader_pass " >> /usr/bin/icam_mulitscript
else
echo "wget -q -O - ${urlinstall}/vitrex.txt | bash" >> /usr/bin/icam_mulitscript
fi
echo "" >> /usr/bin/icam_mulitscript
chmod +x /usr/bin/icam_mulitscript
curl -sA "INFO: $my_distribution" https://${urlinstall}/my_version.txt >/dev/null 2>&1
check_backupdir() {
[ -d /backup ] || mkdir /backup
}
wrong_opt() {
echo "Option nicht vorhanden!"
sleep 2
clear
}
install_vitrex_ipk() {
current_installs=$( $listinstalled | grep -E 'softcam|camd'| grep -vE 'camdctrl|crypto|ii' |awk '{print $1}')
for current_install in $current_installs ; do
echo "exit 0" > /var/lib/opkg/info/$current_install.prerm
echo "lösche $current_install"
$exec_cmd --force-remove remove $current_install >/dev/null 2>&1
done
for current_runscript in `ls /etc/init.d/ | grep -i softcam` ; do
rm /etc/init.d/$current_runscript
done
for current_binfile in `ls /usr/bin/ | grep -i osca | grep -vE 'bak'` ; do
rm /usr/bin/$current_binfile
done
if [ -e /etc/apt/sources.list.d  ]; then
echo "Installiert Dummy-deb für Softcam"
curl -sk -Lo /tmp/softcam-vitrex.deb https://${url}/oscam/master/enigma2-softcams-oscam-vitrex_1.1-emu-r0815.deb
dpkg -i /tmp/softcam-vitrex.deb  > /dev/null 2>&1
chmod +x /usr/bin/oscam_vitrex
else
echo "Installiert Dummy-ipk für Softcam"
curl -sk -Lo /tmp/softcam-vitrex.ipk https://${url}/oscam/master/enigma2-softcams-oscam-vitrex_1.1-emu-r0815_all.ipk
$exec_cmd install --force-reinstall /tmp/softcam-vitrex.ipk  > /dev/null 2>&1
chmod +x /usr/bin/oscam_vitrex
fi
first_replace_initscript
/etc/init.d/softcam.oscam_vitrex restart
}
get_ipk_oscam() {
myoscambin="/usr/bin/oscam_vitrex"
my_configpath="/etc/tuxbox/config/"
}
get_old_oscam() {
myoscambin=$(ps xuww | grep -i oscam | grep -vE 'grep|tail' | awk '{print $11}'|uniq)
myoscambinname=$(ps xuww | grep -i oscam | grep -vE 'grep|tail' | awk '{print $11}'|uniq| sed 's?^.*/??')
my_configpath=$(ps axuww | grep oscam | awk -F '-c' '{print $2}'|awk '{print $1}'|grep '\S' |uniq|sed -e 's/ //g')
if [ -z "$my_configpath" ]
then
my_configpath=$(ps xuww | grep -i oscam | awk -F '-bc' '{print $2}' |uniq|sed -e 's/ //g')
fi
case $my_configpath in
onfig-dir*)
my_configpath=$(ps axuww | grep oscam | awk -F 'config-dir ' '{print $2}'|grep '\S' |uniq|awk '{print $1}'|sed -e 's/ //g')
;;
esac
}
kill_oscam() {
for pid in `ps xuww | grep oscam | grep "$myoscambin" | grep -v grep | awk '{print $2}'`; do
kill -9 $pid
done
}
first_replace_initscript() {
update-rc.d -f softcam.oscam remove > /dev/null 2>&1
rm /etc/init.d/softcam* /etc/init.d/cardserver* > /dev/null 2>&1
wget -O /etc/init.d/softcam https://${url}/oscam/master/install/softcam > /dev/null 2>&1
wget -O /etc/init.d/softcam.oscam_vitrex https://${url}/oscam/master/install/softcam.oscam_vitrex > /dev/null 2>&1
wget -O /etc/init.d/softcam.None https://${url}/oscam/master/install/softcam.None > /dev/null 2>&1
wget -O /etc/init.d/cardserver.None https://${url}/oscam/master/install/cardserver.None > /dev/null 2>&1
chmod 755 /etc/init.d/softcam* /etc/init.d/cardserver* > /dev/null 2>&1
chmod +x /etc/init.d/softcam* /etc/init.d/cardserver* > /dev/null 2>&1
update-rc.d -f softcam.oscam_vitrex defaults > /dev/null 2>&1
}
no_initscript() {
for current_runscript in `ls /etc/init.d/ | grep -i softcam` ; do
/etc/init.d/$current_runscript restart > /dev/null 2>&1
update-rc.d -f $current_runscript defaults > /dev/null 2>&1
done
}
first_replace_oscam_vitrex() {
sleep 5
cp ${myoscambin} ${myoscambin}_bak_vitrex
if [ -n "$(uname -m | grep armv7l)" ]; then
_arch=arm
elif [ -n "$(uname -m | grep aarch64)" ]; then
_arch=aarch64
elif [ -n "$(uname -m | grep mips)" ]; then
_arch=mipsel
else
echo -e "\e[31m Leider verfügt dein Gerät nicht über die richtige EMU \e[0m"
exit 1
fi
if [ -z "$icampatch" ] ; then
icampatch=v9
fi
wget -O ${myoscambin} https://${url}/oscam/master/install/oscambin/oscam-svn11715-${_arch}_${icampatch} > /dev/null 2>&1
chmod +x ${myoscambin}
unset icampatch
first_replace_initscript
/etc/init.d/softcam.oscam_vitrex restart > /dev/null 2>&1
}
swap_oscam_vitrex() {
sleep 5
cp ${myoscambin} ${myoscambin}_bak_vitrex #_${zeitvariable}
if [ -n "$(uname -m | grep armv7l)" ]; then
_arch=arm
elif [ -n "$(uname -m | grep aarch64)" ]; then
_arch=aarch64
elif [ -n "$(uname -m | grep mips)" ]; then
_arch=mipsel
else
echo -e "\e[31m Leider verfügt dein Gerät nicht über die richtige EMU \e[0m"
exit 1
fi
if [ -z "$icampatch" ] ; then
icampatch=v9
fi
wget -O ${myoscambin} https://${url}/oscam/master/install/oscambin/oscam-${svn}-${_arch}_${icampatch}${_demux}${_neon} > /dev/null 2>&1
chmod +x ${myoscambin}
unset icampatch
unset neon
unset demux
no_initscript
}
do_reboot() {
echo -e "\e[33m ... GUI wird neugestartet \e[0m"
sleep 3
reboot
}
set_enigma2_settings() {
curl --noproxy '*' --data value="false" "http://127.0.0.1/api/saveconfig?key=config.plugins.fccsetup.activate" > /dev/null 2>&1
curl --noproxy '*' --data value="false" "http://127.0.0.1/api/saveconfig?key=config.streaming.stream_ecm" > /dev/null 2>&1
curl --noproxy '*' --data value="true" "http://127.0.0.1/api/saveconfig?key=config.streaming.descramble" > /dev/null 2>&1
curl --noproxy '*' --data value="false" "http://127.0.0.1/api/saveconfig?key=config.streaming.descramble_client" > /dev/null 2>&1
curl --noproxy '*' --data value="expert" "http://127.0.0.1/api/saveconfig?key=config.usage.setup_level" > /dev/null 2>&1
echo -e "\e[32m gut gemacht ...\e[0m"
sleep 3
}
do_enigma_settings() {
set_enigma2_settings
}
get_oscam_configs() {
readerfile="/etc/tuxbox/config/oscam.server"
mkdir /etc/tuxbox/config/ -p > /dev/null 2>&1
curl -sk -Lo /etc/tuxbox/config/oscam.conf https://${url}/oscam/master/install/configs/oscam.conf > /dev/null 2>&1
curl -sk -Lo /etc/tuxbox/config/oscam.user https://${url}/oscam/master/install/configs/oscam.user > /dev/null 2>&1
curl -sk -Lo /etc/tuxbox/config/oscam.server https://${url}/oscam/master/install/configs/oscam.server > /dev/null 2>&1
curl -sk -Lo /etc/tuxbox/config/SoftCam.Key https://${url}/oscam/master/install/configs/SoftCam.Key > /dev/null 2>&1
curl -sk -Lo /etc/tuxbox/config/oscam.dvbapi https://${url}/oscam/master/install/configs/oscam.dvbapi > /dev/null 2>&1
if [ -n "$my_reader_user" ] ; then
echo ""                                                        >> $readerfile
echo "Einstellungen automatische Installation"                  >> $readerfile
echo "[reader]"                                                 >> $readerfile
echo "label             = vitrex"                             >> $readerfile
echo "protocol          = $my_reader_type"                     >> $readerfile
echo "device            = $my_reader_server,$my_reader_port"   >> $readerfile
echo "user              = $my_reader_user"                     >> $readerfile
echo "password          = $my_reader_pass"                     >> $readerfile
echo "inactivitytimeout = 30"                                   >> $readerfile
echo "group             = 1"                                   >> $readerfile
echo "cccversion        = 2.3.2"                               >> $readerfile
echo "ccckeepalive      = 1"                                   >> $readerfile
echo "audisabled        = 1"                                   >> $readerfile
fi
}
get_bouquets() {
echo ""
echo "Wenn keine Sendersuche durchgeführt wurde oder du keine Lust dazu hast:"
read  -p "Download der lamedb und satellites.xml?    y/n : " bqdl </dev/tty
case $bqdl in
[Yy]*)
autodllame=1
curl -sk -Lo /etc/enigma2/lamedb https://${url}/oscam/master/install/sender/lamedb
curl -sk -Lo /etc/tuxbox/satellites.xml https://${url}/oscam/master/install/sender/satellites.xml
curl -sk -Lo /etc/tuxbox/cables.xml https://${url}/oscam/master/install/sender/cables.xml
FILE=/etc/enigma2/${check_bouquet}
if [ -f "$FILE" ]; then
echo -e "\e[33m Bouquet(s) existiert wohl schon !!!\e[0m"
sleep 5
else
curl -sk https://$urlsender/${bouquet}| bash
curl -s 'http://127.0.0.1/web/servicelistreload?mode=0' > /dev/null 2>&1
curl -s 'http://127.0.0.1/web/servicelistreload?mode=4' > /dev/null 2>&1
fi
weitere_bouquets
;;
*)
FILE=/etc/enigma2/${check_bouquet}
if [ -f "$FILE" ]; then
echo -e "\e[33m  Bouquet(s) existiert wohl schon \e[0m"
sleep 5
else
curl -sk https://$urlsender/${bouquet} | bash
curl -s 'http://127.0.0.1/web/servicelistreload?mode=0' > /dev/null 2>&1
curl -s 'http://127.0.0.1/web/servicelistreload?mode=4' > /dev/null 2>&1
fi
weitere_bouquets
;;
esac
}
replace_bouquets_ip() {
fix_streaming=1
myip=$(ip a s | grep "scope global" | grep eth |awk '/inet /{print $2}' | awk -F '/' '{print $1}')
sed -i "s/127.0.0.1/${myip}/g" /etc/enigma2/*.tv
curl -s 'http://127.0.0.1/web/servicelistreload?mode=0' > /dev/null 2>&1
curl -s 'http://127.0.0.1/web/servicelistreload?mode=4' > /dev/null 2>&1
}
autoupdate_bouquets() {
autoupdate_switch=true
echo "#  Icam Mulitscript by Vitrex" > /usr/bin/icam_autoupdate
echo "curl -sk https://$urlsender/${bouquet} | bash" >> /usr/bin/icam_autoupdate
if [ -z "${fix_streaming}" ]; then
echo ""
echo "---------------------------------------------------"
sleep 2
echo "Die Option "Y" macht nur Sinn, wenn du bereits den Stream Fix mit diesem Script durchgeführt hast!"
read  -p "Benutzt du Stream Fix?    y/n : " aubqstrmfix </dev/tty
case $aubqstrmfix in
[Yy]*)
echo "myip=\$(ip a s | grep 'scope global' | grep eth |awk '/inet /{print \$2}' | awk -F '/' '{print \$1}')" >> /usr/bin/icam_autoupdate
echo 'sed -i "s/127.0.0.1/${myip}/g" /etc/enigma2/*.tv' >> /usr/bin/icam_autoupdate
;;
esac
else
echo "myip=\$(ip a s | grep 'scope global' | grep eth |awk '/inet /{print \$2}' | awk -F '/' '{print \$1}')" >> /usr/bin/icam_autoupdate
echo 'sed -i "s/127.0.0.1/${myip}/g" /etc/enigma2/*.tv' >> /usr/bin/icam_autoupdate
fi
if [ -z "${fix_sound}" ]; then
echo ""
echo "---------------------------------------------------"
sleep 2
echo "Die Option "Y" macht nur Sinn, wenn du bereits den Sound Fix mit diesem Script durchgeführt hast!"
read  -p "Benutzt du Sound Fix?    y/n : " aubqsndfix </dev/tty
case $aubqsndfix in
[Yy]*)
echo "sed -i 's/3a17999\/1/3a17999\/5001/g' /etc/enigma2/*.tv" >> /usr/bin/icam_autoupdate
;;
esac
else
echo "sed -i 's/3a17999\/1/3a17999\/5001/g' /etc/enigma2/*.tv" >> /usr/bin/icam_autoupdate
fi
echo "curl -sko /etc/enigma2/lamedb https://${url}/oscam/master/install/sender/lamedb"                >> /usr/bin/icam_autoupdate
echo "curl -sko /etc/tuxbox/satellites.xml https://${url}/oscam/master/install/sender/satellites.xml" >> /usr/bin/icam_autoupdate
echo "curl -sko /etc/tuxbox/cables.xml https://${url}/oscam/master/install/sender/cables.xml"         >> /usr/bin/icam_autoupdate
echo 'curl -s "http://127.0.0.1/web/servicelistreload?mode=0" > /dev/null 2>&1'>> /usr/bin/icam_autoupdate
echo 'curl -s "http://127.0.0.1/web/servicelistreload?mode=4" > /dev/null 2>&1'>> /usr/bin/icam_autoupdate
echo '' >> /usr/bin/icam_autoupdate
chmod +x /usr/bin/icam_autoupdate
(crontab -l | sed -e '/icam_autoupdate/d') | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/bin/icam_autoupdate ") | crontab -
echo -e "\e[32m alles erledigt ...\e[0m"
sleep 3
}
disable_autoupdate_bouquets() {
autoupdate_switch=false
echo "#  Icam Mulitscript by Vitrex" >  /usr/bin/icam_autoupdate
echo "exit 0" >> /usr/bin/icam_autoupdate
chmod +x /usr/bin/cccamto_autoupdate
}
replace_bouquets_type() {
$exec_cmd install exteplayer3
$exec_cmd install gstplayer
$exec_cmd install enigma2-plugin-systemplugins-serviceapp
curl --noproxy '*' --data value="exteplayer3" "http://127.0.0.1/api/saveconfig?key=config.plugins.serviceapp.servicemp3.player" > /dev/null 2>&1
curl --noproxy '*' --data value="true" "http://127.0.0.1/api/saveconfig?key=config.plugins.serviceapp.servicemp3.replace" > /dev/null 2>&1
sed -i '/config.plugins.serviceapp.servicemp3/d' /etc/enigma2/settings
echo "config.plugins.serviceapp.servicemp3.player=gstplayer" >> /etc/enigma2/settings
echo "config.plugins.serviceapp.servicemp3.replace=true" >> /etc/enigma2/settings
touch /etc/enigma2/serviceapp_replaceservicemp3
sed -i 's/3a17999\/1/3a17999\/5001/g' /etc/enigma2/*.tv
curl -s 'http://127.0.0.1/web/servicelistreload?mode=0' > /dev/null 2>&1
curl -s 'http://127.0.0.1/web/servicelistreload?mode=4' > /dev/null 2>&1
fix_sound=true
reboot=1
}
install_oatv() {
echo ""; echo -e "\e[34m Ein Traum wahr ...\e[0m" ; echo ""
$exec_cmd install $libusbvers  > /dev/null 2>&1
$exec_cmd install $libatomicvers  > /dev/null 2>&1
$exec_cmd install $libcryptovers  > /dev/null 2>&1
$exec_cmd install $libcurlvers4  > /dev/null 2>&1
install_vitrex_ipk
rm /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
ln -s `find /usr/lib/ -name 'libcrypto.so.1*' -type f | head -n 1`  /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
get_old_oscam
kill_oscam
get_oscam_configs
first_replace_oscam_vitrex
set_enigma2_settings
echo ""; echo -e "\e[32m ... Naja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
install_opli() {
echo ""; echo -e "\e[34m Ein Traum wahr ...\e[0m" ; echo ""
$exec_cmd install $libusbvers  > /dev/null 2>&1
$exec_cmd install $libatomicvers  > /dev/null 2>&1
$exec_cmd install $libcryptovers  > /dev/null 2>&1
$exec_cmd install $libcurlvers4  > /dev/null 2>&1
install_vitrex_ipk
rm /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
ln -s `find /usr/lib/ -name 'libcrypto.so.1*' -type f | head -n 1`  /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
get_old_oscam
kill_oscam
get_oscam_configs
first_replace_oscam_vitrex
set_enigma2_settings
echo ""; echo -e "\e[32m ... Na ja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
install_onfr() {
echo ""; echo -e "\e[34m Ein Traum wahr ...\e[0m" ; echo ""
$exec_cmd install $libusbvers  > /dev/null 2>&1
$exec_cmd install $libatomicvers  > /dev/null 2>&1
$exec_cmd install $libcryptovers  > /dev/null 2>&1
$exec_cmd install $libcurlvers4  > /dev/null 2>&1
install_vitrex_ipk
rm /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
ln -s `find /usr/lib/ -name 'libcrypto.so.1*' -type f | head -n 1`  /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
get_old_oscam
kill_oscam
get_oscam_configs
first_replace_oscam_vitrex
set_enigma2_settings
echo ""; echo -e "\e[32m ... Na ja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
install_vti() {
echo ""; echo -e "\e[34m Ein Traum wahr ...\e[0m" ; echo ""
$exec_cmd install $libusbvers  > /dev/null 2>&1
$exec_cmd install $libatomicvers  > /dev/null 2>&1
$exec_cmd install $libcryptovers  > /dev/null 2>&1
$exec_cmd install $libcurlvers4  > /dev/null 2>&1
install_vitrex_ipk
rm /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
ln -s `find /lib/ -name 'libcrypto.so.1*' -type f | head -n 1`  /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
get_old_oscam
kill_oscam
get_oscam_configs
first_replace_oscam_vitrex
set_enigma2_settings
echo ""; echo -e "\e[32m ... Na ja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
install_nn2() {
echo ""; echo -e "\e[34m Ein Traum wahr ...\e[0m" ; echo ""
$exec_cmd install $libusbvers  > /dev/null 2>&1
$exec_cmd install $libatomicvers  > /dev/null 2>&1
$exec_cmd install $libcryptovers  > /dev/null 2>&1
$exec_cmd install $libcurlvers4  > /dev/null 2>&1
install_vitrex_ipk
rm /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
ln -s `find /usr/lib/ -name 'libcrypto.so.1*' -type f | head -n 1`  /usr/lib/libcrypto.so.0.9.8 > /dev/null 2>&1
get_old_oscam
kill_oscam
get_oscam_configs
first_replace_oscam_vitrex
set_enigma2_settings
echo ""; echo -e "\e[32m ... Naja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
install_picons() {
wget -O /tmp/icam_picons.tar https://${url}/oscam/master/install/icam_picons.tar > /dev/null 2>&1
[ -d /usr/share/enigma2/picon ] || mkdir -p /usr/share/enigma2/picon > /dev/null 2>&1
cd /usr/share/enigma2/picon
tar xfv /tmp/icam_picons.tar > /dev/null 2>&1
case $my_distribution in
Dream*)
cp -rfp /picons/piconHD/* /usr/share/enigma2/picon/ > /dev/null 2>&1
rm -rf  /picons/piconHD/
ln -s /usr/share/enigma2/picon/ /picons/piconHD
;;
esac
echo ""; echo -e "\e[32m ... Naja, schick! Wir sind fertig. ;)\e[0m";
sleep 2
}
my_header() {
clear
echo "     \                                                                      "
echo "    __\/__                                                                  "
echo "    \    /     _  _________  _______   _______ ___    __                    "
echo " |\  \  /  /| | ||___   ___||  ____ \ |  _____|\  \  /  /     ___   __  __  "
echo " | \  \/  / | | |    | |    | |____| || |_____  \  \/  /     ( _ / / / / /  "
echo " |  \    /  | | |    | |    |  __  _/ |  _____|  )    (    _  \_\ / /_/ /   "
echo " |   \__/   | | |    | |    | |  \ \  | |_____  /  /\  \  (_)/___)\__,_/    "
echo " \__________/ |_|    |_|    |_|   \_\ |_______|/__/  \__\                   "
echo "                                                         by VITREX-TEAM     "
}
mainmenu() {
my_header
echo -e "\e[32m Super! Es sieht so aus, als ob du $my_image nutzt.\e[0m"
echo -e "\e[33m ######*** Main Menu ***######\e[0m"
echo -e "1) Installiert Icam Oscam             // Neu oder Vorschlaghammermodus ;)"
echo -e "2) Nur die Oscam Bin aktualisieren    // Aktualisiert Oscam Bin bei laufender Softcam"
echo -e "3) Nur Bouquets installieren          // Installiert ICam Bouquets (nach Bedarf auch HD/SD/OE)"
echo -e "4) Installiert ICAM Picons            // Installiert nur ICAM Picons"
echo -e "5) Backup oder Wiederherstellung      // Backup oder Wiederherstellung Oscam"
echo -e "6) Fix Settings                       // Überarbeitet Enigma Einstellungen in /etc/enigma2/settings "
echo -e "7) Fix Streaming-IP                   // Ändert 127.0.0.1 in $myip für Home-Streaming"
echo -e "8) Fix Sound-Problem                  // Ändert den Streaming-Typ ... EXPERIMENTAL"
echo -e "9) Bouquet Autoupdate                 // Aktualisiert Bouquets bei Neustart"
echo -e "0) Ausgang"
read  -p "choose an Option: " main </dev/tty
case $main in
1)
install_first
mainmenu
;;
2)
update_bin
mainmenu
;;
3)
install_bouquets
mainmenu
;;
4)
install_picons
mainmenu
;;
5)
backup_restore
mainmenu
;;
6)
set_enigma2_settings
mainmenu
;;
7)
set_enigma2_settings
replace_bouquets_ip
mainmenu
;;
8)
replace_bouquets_type
set_enigma2_settings
mainmenu
;;
9)
autoupdate_menu
mainmenu
;;
0)
echo "Bye bye."
wget -O - -q "127.0.0.1/web/message?text=Vitrex%20Icam%20Mulitscript%20ist%20%20jetzt%20gestoppt...%20:)%20%20$STARTDATE&type=1&timeout=5" > /dev/null
if [ -n "enigmasettings" ]; then
do_enigma_settings
fi
if [ -n "$reboot" ]; then
wget -O - -q "127.0.0.1/web/message?text=Vitrex%20Icam%20Mulitscript%20startet%20%20deine%20Box%20neu...%20%20$STARTDATE&type=1&timeout=5" > /dev/null
do_reboot
fi
exit 0
;;
*)
wrong_opt
mainmenu
;;
esac
}
install_first() {
my_header
echo -e "\e[32m Super! Es sieht so aus, als ob du $my_image nutzt.\e[0m"
echo -e "\e[33m ######*** Softcam  Menü ***######\e[0m"
echo -e "1) OpenATV         ( $rebootmsg )"
echo -e "2) OpenPLI         ( $rebootmsg )"
echo -e "3) VTI+vuplus      ( $rebootmsg )"
echo -e "4) OpenNFR/HDF     ( $rebootmsg )"
echo -e "5) OpenEight       ( $rebootmsg )"
echo -e "6) OpenVision      ( $rebootmsg )"
echo -e "7) TeamBlue        ( $rebootmsg )"
echo -e "8) Pure2           ( $rebootmsg )"
echo -e "9) DreamOS(NN2)    ( $rebootmsg )"
echo -e "0) Zurück"
read  -p "choose an Option: " stablemenu </dev/tty
case $stablemenu in
1)
if grep -qs -i "openATV" /etc/image-version; then
echo "Box hat OpenATV Image"
flag=stable
reboot=1
install_oatv
install_bouquets
else
echo -e "\e[31m Gewähltes Image OpenATV. Gefundenes Image $my_image!!!\e[0m"
sleep 5
install_first
fi
;;
2)
if grep -qs -i "openpli" /etc/issue; then
echo "Box hat OpenPLI Image"
flag=stable
reboot=1
install_opli
install_bouquets
else
echo -e "\e[31m Gewähltes Image OpenPLI. Gefundenes Image $my_image!!!\e[0m"
sleep 5
install_first
fi
;;
3)
if [ -r /usr/lib/enigma2/python/Plugins/SystemPlugins/VTIPanel ]; then
echo "Box hat VTI Image"
flag=stable
reboot=1
install_vti
install_bouquets
else
echo -e "\e[31m Gewähltes Image VTI. Gefundenes Image $my_image!!!\e[0m"
sleep 5
install_first
fi
;;
4)
if [ -r /usr/lib/enigma2/python/Plugins/Extensions/HDF-Toolbox ]; then
echo "Box hat OpenHDF Image"
flag=stable
reboot=1
install_onfr
install_bouquets
elif grep -qs -i "OpenNFR" /etc/image-version; then
echo "Box hat OpenNFR Image"
flag=stable
reboot=1
install_onfr
install_bouquets
else
echo -e "\e[31m Gewähltes Image OpenNFR/HDF. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
5)
if grep -qs -i "OpenEight" /etc/image-version; then
echo "Box hat OpenEight Image"
flag=stable
reboot=1
install_oatv
install_bouquets
else
echo -e "\e[31m Gewähltes Image OpenEight. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
6)
if grep -qs -i "openvision" /etc/issue; then
echo "Box hat OpenVision Image"
flag=stable
reboot=1
install_oatv
install_bouquets
else
echo -e "\e[31m Gewähltes Image OpenVision. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
7)
if grep -qs -i "teamBlue" /etc/image-version; then
echo "Box hat TeamBlue Image"
flag=stable
reboot=1
install_oatv
install_bouquets
else
echo -e "\e[31m Gewähltes Image TeamBlue. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
8)
if grep -qs -i "PURE2" /etc/image-version; then
echo "Box hat PueE2 Image"
flag=stable
reboot=1
install_opli
install_bouquets
else
echo -e "\e[31m Gewähltes Image PueE2. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
9)
if grep -qs -i "newnigma2" /etc/image-version; then
echo "Box hat Newnigma2 Image"
flag=stable
reboot=1
install_nn2
install_bouquets
else
echo -e "\e[31m Gewähltes Image Newnigma2. Gefundenes Image $my_image!!!\e[0m"
sleep 3
install_first
fi
;;
0)
clear
mainmenu
;;
*)
wrong_opt
install_first
;;
esac
}
update_bin() {
my_header
if [ -n "$(uname -m | grep armv7l)" ]; then  #arm
echo -e "\e[33m ######*** Oscam Binary aktualisieren ***######\e[0m"
echo -e "a) Update Bin 11714   Icam-V7            ( $rebootmsg )"
echo -e "b) Update Bin 11715   Icam-V7            ( $rebootmsg )"
echo -e "c) Update Bin 11715   Icam-V8            ( $rebootmsg )"
echo -e "d) Update Bin 11715   Icam-V8 NEON       ( $rebootmsg )"
echo -e "e) Update Bin 11715   Icam-V9            ( $rebootmsg )"
echo -e "f) Update Bin 11715   Icam-V9 NEON       ( $rebootmsg )"
echo -e "g) Update Bin 11716   Icam-V9            ( $rebootmsg )"
echo -e "h) Update Bin 11718   Icam-V9            ( $rebootmsg )"
echo -e "i) Update Bin 11720   Icam-V9            ( $rebootmsg )"
echo -e "j) Update Bin 11724   Icam-V9            ( $rebootmsg )"
echo -e "0) Zurück"
elif [ -n "$(uname -m | grep aarch64)" ]; then  #aarch
echo -e "\e[33m ######*** Oscam Binary aktualisieren ***######\e[0m"
echo -e "a) Update Bin 11714   Icam-V7            ( $rebootmsg )"
echo -e "b) Update Bin 11715   Icam-V7            ( $rebootmsg )"
echo -e "c) Update Bin 11715   Icam-V8            ( $rebootmsg )"
echo -e "d) Update Bin 11715   Icam-V8 NEON       ( $rebootmsg )"
echo -e "e) Update Bin 11715   Icam-V9            ( $rebootmsg )"
echo -e "f) Update Bin 11715   Icam-V9 NEON       ( $rebootmsg )"
echo -e "g) Update Bin 11716   Icam-V9            ( $rebootmsg )"
echo -e "h) Update Bin 11718   Icam-V9            ( $rebootmsg )"
echo -e "i) Update Bin 11720   Icam-V9            ( $rebootmsg )"
echo -e "j) Update Bin 11724   Icam-V9            ( $rebootmsg )"
echo -e "0) Zurück"
elif [ -n "$(uname -m | grep mips)" ]; then  #mipsel
echo -e "\e[33m ######*** Oscam Binary aktualisieren ***######\e[0m"
echo -e "a) Update Bin 11714   Icam-V7            ( $rebootmsg )"
echo -e "b) Update Bin 11715   Icam-V7            ( $rebootmsg )"
echo -e "c) Update Bin 11715   Icam-V8            ( $rebootmsg )"
echo -e "e) Update Bin 11715   Icam-V9            ( $rebootmsg )"
echo -e "g) Update Bin 11716   Icam-V9            ( $rebootmsg )"
echo -e "h) Update Bin 11718   Icam-V9            ( $rebootmsg )"
echo -e "i) Update Bin 11720   Icam-V9            ( $rebootmsg )"
echo -e "j) Update Bin 11724   Icam-V9            ( $rebootmsg )"
echo -e "0) Zurück"
fi
read  -p "choose an Option: " updatebin </dev/tty
case $updatebin in
a)
flag=stable
reboot=1
svn=svn11714
icampatch=v7
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
b)
flag=testing
reboot=1
svn=svn11715
icampatch=v7
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
c)
flag=testing
reboot=1
svn=svn11715
icampatch=v8
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
d)
flag=testing
reboot=1
svn=svn11715
icampatch=v8
neon="_neon"
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
e)
flag=testing
reboot=1
svn=svn11715
icampatch=v9
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
f)
flag=testing
reboot=1
svn=svn11715
icampatch=v9
neon="_neon"
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
g)
flag=testing
reboot=1
svn=svn11716
icampatch=v9
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
h)
flag=testing
reboot=1
svn=svn11718
icampatch=v9
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
i)
flag=testing
reboot=1
svn=svn11720
icampatch=v9
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
j)
flag=testing
reboot=1
svn=svn11724
icampatch=v9
get_old_oscam
kill_oscam
swap_oscam_vitrex
mainmenu
;;
0)
clear
mainmenu
;;
*)
wrong_opt
update_bin
;;
esac
}
install_bouquets() {
my_header
echo -e "\e[33m ######*** Bouquets  Menü ***######\e[0m"
echo -e "1) Astra Icam Multibouquet"
echo -e "2) Astra Icam Singlebouquet"
echo -e "3) Pyur  Icam Multibouquet"
echo -e "4) Pyur  Icam Singlebouquet"
echo -e "5) Astra HD/SD/OE Bouquets"
echo -e "0) Zurück"
read  -p "choose an Option: " bouquetmenu </dev/tty
case $bouquetmenu in
1)
check_bouquet=userbouquet.skyfilm_astra.tv
bouquet=astra.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
2)
check_bouquet=userbouquet.skyicam_single_astra.tv
bouquet=astra_single.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
3)
check_bouquet=userbouquet.skyfilm_pyur.tv
bouquet=pyur.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
4)
check_bouquet=userbouquet.skyicam_single_pyur.tv
bouquet=pyur_single.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
5)
check_bouquet=userbouquet.hdplus_astra.tv
bouquet=astra_sd_hd_oe.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
0)
clear
mainmenu
;;
*)
wrong_opt
installbouquet
;;
esac
}
weitere_bouquets() {
my_header
echo -e "\e[32m Eine weitere Bouquet installieren? \e[0m"
echo -e "\e[33m ######*** Bouquets  Menü ***######\e[0m"
echo -e "1) Astra Icam Multibouquet"
echo -e "2) Astra Icam Singlebouquet"
echo -e "3) Pyur  Icam Multibouquet"
echo -e "4) Pyur  Icam Singlebouquet"
echo -e "5) Astra HD/SD/OE Bouquets"
echo -e "0) Fertig"
read  -p "choose an Option: " bouquetmenu </dev/tty
case $bouquetmenu in
1)
check_bouquet=userbouquet.skyfilm_astra.tv
bouquet=astra.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
2)
check_bouquet=userbouquet.skyicam_single_astra.tv
bouquet=astra_single.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
3)
check_bouquet=userbouquet.skyfilm_pyur.tv
bouquet=pyur.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
4)
check_bouquet=userbouquet.skyicam_single_pyur.tv
bouquet=pyur_single.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
5)
check_bouquet=userbouquet.hdplus_astra.tv
bouquet=astra_sd_hd_oe.txt
get_bouquets
if [ -z "$autoupdate_switch" ]; then
mainmenu
fi
;;
0)
clear
mainmenu
;;
*)
wrong_opt
installbouquet
;;
esac
}
autoupdate_menu() {
my_header
echo -e "\e[33m ######*** Autoupdate  Menü ***######\e[0m"
echo -e "1) Aktiviere die automatische Aktualisierung von Icam Bouquets"
echo -e "2) Deaktiviere die automatische Aktualisierung von Icam Bouquets"
echo -e "0) Zurück"
read  -p "choose an Option: " autoupdate_menu </dev/tty
case $autoupdate_menu in
1)
install_bouquets
autoupdate_bouquets
sleep 2
mainmenu
;;
2)
disable_autoupdate_bouquets
sleep 2
mainmenu
;;
0)
clear
mainmenu
;;
*)
wrong_opt
backup_restore
;;
esac
}
backup_restore() {
my_header
echo -e "\e[33m ######*** Backup oder Wiederherstellung Menü ***######\e[0m"
echo -e "1) Backup der aktuellen Oscam Bin "
echo -e "2) Wiederherstellung der letzten Oscam Bin     (auto reboot)"
echo -e "3) Backup der aktuellen Config Dateien"
echo -e "4) Wiederherstellung der letzten Config Dateien  (auto reboot)"
echo -e "0) Zurück"
read  -p "choose an Option: " backuprestore </dev/tty
case $backuprestore in
1)
check_backupdir
get_old_oscam
cp ${myoscambin} /backup/${myoscambinname}
echo "...Oscam Bin Backup erstellt"
sleep 2
mainmenu
;;
2)
check_backupdir
get_old_oscam
kill_oscam
if [ -z "$myoscambin" ]
then
echo -e "\e[31Kein laufendes Oscam gefunden ... Bitte starte zuerst Oscam\e[0m"
exit 1
fi
cp /backup/${myoscambinname} /usr/bin/
echo "...Oscam Bin Wiederherstellung erfolgreich"
flag=testing
reboot=1
mainmenu
;;
3)
check_backupdir
my_configdir=$(ps axuww | grep oscam | awk -F '-c' '{print $2}'|awk '{print $2}'|grep '\S' |uniq|sed -e 's/ //g')
files='oscam.conf oscam.user oscam.server oscam.srvid2 oscam.dvbapi'
for file in $files ; do
cp ${my_configdir}/$file /backup/$file
done
echo "...Backup der Oscam Config Dateien erfolgreich"
sleep 2
mainmenu
;;
4)
check_backupdir
get_old_oscam
kill_oscam
files='oscam.conf oscam.user oscam.server oscam.srvid2'
for file in $files ; do
cp /backup/$file ${my_configpath}/$file
done
reboot=1
echo "...Wiederherstellung der Oscam Config Dateien erfolgreich"
sleep 2
mainmenu
;;
0)
clear
mainmenu
;;
*)
wrong_opt
backup_restore
;;
esac
}
mainmenu
