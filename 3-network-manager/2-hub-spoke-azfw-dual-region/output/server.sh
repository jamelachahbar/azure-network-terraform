#! /bin/bash

apt update
apt install -y python3-pip python3-dev tcpdump dnsutils net-tools nmap apache2-utils

# web server #
pip3 install Flask requests

mkdir /var/flaskapp
mkdir /var/flaskapp/flaskapp
mkdir /var/flaskapp/flaskapp/static
mkdir /var/flaskapp/flaskapp/templates

cat <<EOF > /var/flaskapp/flaskapp/__init__.py
import socket
from flask import Flask, request
app = Flask(__name__)

@app.route("/")
def default():
    hostname = socket.gethostname()
    address = socket.gethostbyname(hostname)
    data_dict = {}
    data_dict['Hostname'] = hostname
    data_dict['Local-IP'] = address
    data_dict['Remote-IP'] = request.remote_addr
    data_dict['Headers'] = dict(request.headers)
    return data_dict

@app.route("/path1")
def path1():
    hostname = socket.gethostname()
    address = socket.gethostbyname(hostname)
    data_dict = {}
    data_dict['app'] = 'PATH1-APP'
    data_dict['Hostname'] = hostname
    data_dict['Local-IP'] = address
    data_dict['Remote-IP'] = request.remote_addr
    data_dict['Headers'] = dict(request.headers)
    return data_dict

@app.route("/path2")
def path2():
    hostname = socket.gethostname()
    address = socket.gethostbyname(hostname)
    data_dict = {}
    data_dict['app'] = 'PATH2-APP'
    data_dict['Hostname'] = hostname
    data_dict['Local-IP'] = address
    data_dict['Remote-IP'] = request.remote_addr
    data_dict['Headers'] = dict(request.headers)
    return data_dict

if __name__ == "__main__":
    app.run(host= '0.0.0.0', port=80, debug = True)
EOF

cat <<EOF > /etc/systemd/system/flaskapp.service
[Unit]
Description=Script for flaskapp service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /var/flaskapp/flaskapp/__init__.py
ExecStop=/usr/bin/pkill -f /var/flaskapp/flaskapp/__init__.py
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flaskapp.service
systemctl start flaskapp.service

# test scripts
#-----------------------------------

# ping-ip

cat <<EOF > /usr/local/bin/ping-ip
echo -e "\n ping ip ...\n"
echo "branch1 - 10.10.0.5 -\$(timeout 3 ping -qc2 -W1 10.10.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "hub1    - 10.11.0.5 -\$(timeout 3 ping -qc2 -W1 10.11.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "spoke1  - 10.1.0.5 -\$(timeout 3 ping -qc2 -W1 10.1.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "spoke2  - 10.2.0.5 -\$(timeout 3 ping -qc2 -W1 10.2.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "branch3 - 10.30.0.5 -\$(timeout 3 ping -qc2 -W1 10.30.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "hub2    - 10.22.0.5 -\$(timeout 3 ping -qc2 -W1 10.22.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "spoke4  - 10.4.0.5 -\$(timeout 3 ping -qc2 -W1 10.4.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "spoke5  - 10.5.0.5 -\$(timeout 3 ping -qc2 -W1 10.5.0.5 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "internet - icanhazip.com -\$(timeout 3 ping -qc2 -W1 icanhazip.com 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
EOF
chmod a+x /usr/local/bin/ping-ip

# ping-dns

cat <<EOF > /usr/local/bin/ping-dns
echo -e "\n ping dns ...\n"
echo "vm.branch1.corp - \$(timeout 3 dig +short vm.branch1.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.branch1.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.hub1.we.az.corp - \$(timeout 3 dig +short vm.hub1.we.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.hub1.we.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.spoke1.we.az.corp - \$(timeout 3 dig +short vm.spoke1.we.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.spoke1.we.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.spoke2.we.az.corp - \$(timeout 3 dig +short vm.spoke2.we.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.spoke2.we.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.branch3.corp - \$(timeout 3 dig +short vm.branch3.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.branch3.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.hub2.ne.az.corp - \$(timeout 3 dig +short vm.hub2.ne.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.hub2.ne.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.spoke4.ne.az.corp - \$(timeout 3 dig +short vm.spoke4.ne.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.spoke4.ne.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "vm.spoke5.ne.az.corp - \$(timeout 3 dig +short vm.spoke5.ne.az.corp | tail -n1) -\$(timeout 3 ping -qc2 -W1 vm.spoke5.ne.az.corp 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
echo "icanhazip.com - \$(timeout 3 dig +short icanhazip.com | tail -n1) -\$(timeout 3 ping -qc2 -W1 icanhazip.com 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
EOF
chmod a+x /usr/local/bin/ping-dns

# curl-ip

cat <<EOF > /usr/local/bin/curl-ip
echo -e "\n curl ip ...\n"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.10.0.5) - branch1 (10.10.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.11.0.5) - hub1    (10.11.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.1.0.5) - spoke1  (10.1.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.2.0.5) - spoke2  (10.2.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.3.0.5) - spoke3  (10.3.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.30.0.5) - branch3 (10.30.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.22.0.5) - hub2    (10.22.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.4.0.5) - spoke4  (10.4.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.5.0.5) - spoke5  (10.5.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null 10.6.0.5) - spoke6  (10.6.0.5)"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null icanhazip.com) - internet (icanhazip.com)"
EOF
chmod a+x /usr/local/bin/curl-ip

# curl-dns

cat <<EOF > /usr/local/bin/curl-dns
echo -e "\n curl dns ...\n"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.branch1.corp) - vm.branch1.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.hub1.we.az.corp) - vm.hub1.we.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null spoke3.p.hub1.we.az.corp) - spoke3.p.hub1.we.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke1.we.az.corp) - vm.spoke1.we.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke2.we.az.corp) - vm.spoke2.we.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke3.we.az.corp) - vm.spoke3.we.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.branch3.corp) - vm.branch3.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.hub2.ne.az.corp) - vm.hub2.ne.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null spoke6.p.hub2.ne.az.corp) - spoke6.p.hub2.ne.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke4.ne.az.corp) - vm.spoke4.ne.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke5.ne.az.corp) - vm.spoke5.ne.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null vm.spoke6.ne.az.corp) - vm.spoke6.ne.az.corp"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null icanhazip.com) - icanhazip.com"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null ne32-spoke3-b469.azurewebsites.net) - ne32-spoke3-b469.azurewebsites.net"
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%{http_code} (%{time_total}s) - %{remote_ip}" -s -o /dev/null ne32-spoke6-b469.azurewebsites.net) - ne32-spoke6-b469.azurewebsites.net"
EOF
chmod a+x /usr/local/bin/curl-dns

# trace-ip

cat <<EOF > /usr/local/bin/trace-ip
echo -e "\n trace ip ...\n"
echo -e "\nbranch1"
echo -e "-------------------------------------"
timeout 9 tracepath 10.10.0.5
echo -e "\nhub1   "
echo -e "-------------------------------------"
timeout 9 tracepath 10.11.0.5
echo -e "\nspoke1 "
echo -e "-------------------------------------"
timeout 9 tracepath 10.1.0.5
echo -e "\nspoke2 "
echo -e "-------------------------------------"
timeout 9 tracepath 10.2.0.5
echo -e "\nbranch3"
echo -e "-------------------------------------"
timeout 9 tracepath 10.30.0.5
echo -e "\nhub2   "
echo -e "-------------------------------------"
timeout 9 tracepath 10.22.0.5
echo -e "\nspoke4 "
echo -e "-------------------------------------"
timeout 9 tracepath 10.4.0.5
echo -e "\nspoke5 "
echo -e "-------------------------------------"
timeout 9 tracepath 10.5.0.5
echo -e "\ninternet"
echo -e "-------------------------------------"
timeout 9 tracepath icanhazip.com
EOF
chmod a+x /usr/local/bin/trace-ip
