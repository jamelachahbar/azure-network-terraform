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
%{ for target in TARGETS ~}
%{~ if try(target.ping, true) ~}
%{~ if try(target.ip, "") != "" ~}
echo "${target.name} - ${target.ip} -\$(timeout 3 ping -qc2 -W1 ${target.ip} 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
%{ endif ~}
%{ endif ~}
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/ping-ip

# ping-dns

cat <<EOF > /usr/local/bin/ping-dns
echo -e "\n ping dns ...\n"
%{ for target in TARGETS ~}
%{~ if try(target.ping, true) ~}
%{~ if try(target.ip, "") != "" ~}
echo "${target.dns} - \$(timeout 3 dig +short ${target.dns} | tail -n1) -\$(timeout 3 ping -qc2 -W1 ${target.dns} 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "\$5" ms":"NA") }')"
%{ endif ~}
%{ endif ~}
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/ping-dns

# curl-ip

cat <<EOF > /usr/local/bin/curl-ip
echo -e "\n curl ip ...\n"
%{ for target in TARGETS ~}
%{~ if try(target.ip, "") != "" ~}
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%%{http_code} (%%{time_total}s) - %%{remote_ip}" -s -o /dev/null ${target.ip}) - ${target.name} (${target.ip})"
%{ endif ~}
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/curl-ip

# curl-dns

cat <<EOF > /usr/local/bin/curl-dns
echo -e "\n curl dns ...\n"
%{ for target in TARGETS ~}
echo  "\$(timeout 4 curl -kL --max-time 2.0 -H 'Cache-Control: no-cache' -w "%%{http_code} (%%{time_total}s) - %%{remote_ip}" -s -o /dev/null ${target.dns}) - ${target.dns}"
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/curl-dns

# trace-ip

cat <<EOF > /usr/local/bin/trace-ip
echo -e "\n trace ip ...\n"
%{ for target in TARGETS ~}
%{~ if try(target.ping, true) ~}
%{~ if try(target.ip, "") != "" ~}
echo -e "\n${target.name}"
echo -e "-------------------------------------"
timeout 9 tracepath ${target.ip}
%{ endif ~}
%{ endif ~}
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/trace-ip

%{~ if try(ENABLE_TRAFFIC_GEN, false) ~}
# light-traffic generator

%{ if TARGETS_LIGHT_TRAFFIC_GEN != [] ~}
cat <<EOF > /usr/local/bin/light-traffic
%{ for target in TARGETS_LIGHT_TRAFFIC_GEN ~}
%{~ if try(target.probe, false) ~}
nping -c 3 --${try(target.protocol, "tcp")} -p ${try(target.port, "80")} ${target.dns} > /dev/null 2>&1
%{ endif ~}
%{ endfor ~}
EOF
chmod a+x /usr/local/bin/light-traffic
%{ endif ~}

# heavy-traffic generator

%{ if TARGETS_HEAVY_TRAFFIC_GEN != [] ~}
cat <<EOF > /usr/local/bin/heavy-traffic
#! /bin/bash
i=0
while [ \$i -lt 4 ]; do
  %{ for target in TARGETS_HEAVY_TRAFFIC_GEN ~}
  ab -n \$1 -c \$2 ${target} > /dev/null 2>&1
  %{ endfor ~}
  let i=i+1
  sleep 2
done
EOF
chmod a+x /usr/local/bin/heavy-traffic
%{ endif ~}

# crontab for traffic generators

cat <<EOF > /tmp/crontab.txt
%{ if TARGETS_LIGHT_TRAFFIC_GEN != [] ~}
*/1 * * * * /usr/local/bin/light-traffic 2>&1 > /dev/null
%{ endif ~}
%{ if TARGETS_HEAVY_TRAFFIC_GEN != [] ~}
*/1 * * * * /usr/local/bin/heavy-traffic 50 1 2>&1 > /dev/null
*/2 * * * * /usr/local/bin/heavy-traffic 8 2 2>&1 > /dev/null
*/3 * * * * /usr/local/bin/heavy-traffic 20 4 2>&1 > /dev/null
*/5 * * * * /usr/local/bin/heavy-traffic 15 2 2>&1 > /dev/null
%{ endif ~}
EOF
crontab /tmp/crontab.txt
%{ endif ~}
