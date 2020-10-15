#!/bin/bash

clear
echo "----------------------------Homeware LAN-------------------------------"
echo "Follow this assistant in order to configure your Homeware installation."

read -r -p "Do you want to start? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        echo
        echo "Cloning the respository."
        echo "---------------------------------------------"
        cd /usr/share
        sudo apt-get update
        sudo apt install git
        sudo git clone https://github.com/kikeelectronico/Homeware-LAN.git
        cd Homeware-LAN
        git checkout develop
        cd ../
        sudo chmod -R 777 Homeware-LAN
        cd Homeware-LAN
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "Installing Homeware-LAN and its dependencies."
        echo "---------------------------------------------"
        sudo apt install python3-pip
        sudo pip3 install install -r requirements.txt
        sudo apt install nginx
        sudo apt install software-properties-common
        sudo apt install certbot
        sudo apt install curl
        sudo apt install mosquitto mosquitto-clients
        sudo apt install redis-server
        # echo
        # read -r -p "Press enter to continue." e
        # clear
        # echo "Intall the database."
        # echo "---------------------------------------------"
        # mkdir redis
        # cd redis
        # wget http://download.redis.io/redis-stable.tar.gz
        # tar xvzf redis-stable.tar.gz
        # cd redis-stable
        # make
        # sudo make install
        # cd ../../
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "Intall the new services."
        echo "---------------------------------------------"
        sudo cp configuration_templates/homeware.service /lib/systemd/system/
        sudo cp configuration_templates/homewareMQTT.service /lib/systemd/system/
        sudo cp configuration_templates/homewareTasks.service /lib/systemd/system/
        sudo cp configuration_templates/homewareRedis.service /lib/systemd/system/

        sudo systemctl enable homewareMQTT
        sudo systemctl enable homewareTasks
        sudo systemctl enable homewareRedis
        sudo systemctl enable homeware

        sudo systemctl start homewareRedis
        sudo systemctl start homeware
        sudo systemctl start homewareMQTT
        sudo systemctl start homewareTasks
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "User configuration."
        echo "---------------------------------------------"
        read -r -p "Admin user: " user
        echo $user
        read -r -p "Admin password: " password
        echo $password
        curl -d '{"user":"'$user'", "pass":"'$password'"}' -H "Content-Type: application/json" -X POST http://localhost:5001/api/user/set/
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "DDNS."
        echo "---------------------------------------------"
        echo "If you have a dinamic IP, you should use a DDNS provider"
        echo "The process depend on the provider you choose. For example, you can use https://my.noip.com as the provider"
        echo
        echo "Create an account at no-ip."
        echo "Go to Dynamic DNS and create a new Hostname."
        echo
        echo "\t1 - Choose a unique Hostname."
        echo "\t2 - Select DNS Host (A)."
        echo "\t3 - Fill the IPv4 Address with your WAN/public IP. You can get it from https://www.whatismyip.com/what-is-my-public-ip-address/"
        echo
        echo "When the installation will be completed you must configure the DDNS data from the Settings section on Homeware."
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "Nginx and your hostname."
        echo "---------------------------------------------"
        read -r -p "Type your DDNS Hostname (ecample: yourdomain.ddns.com ):" hostname
        cd bash
        sudo sh confignginx.sh $hostname
        cd ../
        curl -X GET http://localhost:5001/api/settings/domain/$hostname/
        echo
        read -r -p "Press enter to continue." e
        clear
        ip=$(hostname -I)
        echo "Ports."
        echo "---------------------------------------------"
        echo "Open your router config web page, look for 'Port Forwarding' and create the following rules."
        echo "Port 80:"
        echo "\tProtocol: TCP"
        echo "\tWAN start port: 80"
        echo "\tWAN end port: 80"
        echo "\tLAN start port: 80"
        echo "\tLAN end port: 80"
        echo "\tLAN host IP: $ip"
        echo
        echo "Port 443:"
        echo "\tProtocol: TCP"
        echo "\tWAN start port: 443"
        echo "\tWAN end port: 443"
        echo "\tLAN start port: 443"
        echo "\tLAN end port: 433"
        echo "\tLAN host IP: $ip"
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "SSL certificate."
        echo "---------------------------------------------"
        echo "Google needs to comunicate with the Raspberry Pi via HTTPS, so we need a SSL certicate for Homeware."
        echo
        echo "Follow the Certbot instructions. When Certbot ask you about redirecting http to https, enable it."
        sudo certbot --nginx
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "Google."
        echo "---------------------------------------------"
        echo "Google needs to know where Homeware is."
        echo "Follow the instructions on this wiki https://github.com/kikeelectronico/Homeware-LAN/wiki/Connect-Homeware-LAN-with-Google"
        echo "During the process you will use the following Client Information. You will be able to change it from the Settings page in the future."
        echo ""
        echo "\tClient ID: 123"
        echo "\tClient Secret: 456"
        echo "\tAuthorization URL: https://$hostname/auth/"
        echo "\tToken URL: https://$hostname/token/"
        echo "\tFulfillment URL: https://$hostname/smarthome/"
        curl -X GET http://localhost:5001/api/settings/setAssistantDone/
        echo
        read -r -p "Press enter to continue." e
        clear
        echo "Done."
        echo "---------------------------------------------"
        echo "Homeware is ready for you. Visit $hostname"


        ;;
    *)
        echo "Ok."
        ;;
esac
