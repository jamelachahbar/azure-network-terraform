Section: IOS configuration

crypto ikev2 proposal AZURE-IKE-PROPOSAL
encryption aes-cbc-256
integrity sha1
group 2
!
crypto ikev2 policy AZURE-IKE-PROFILE
proposal AZURE-IKE-PROPOSAL
match address local 10.30.1.9
!
crypto ikev2 keyring AZURE-KEYRING
peer 20.166.203.25
address 20.166.203.25
pre-shared-key changeme
peer 20.166.203.226
address 20.166.203.226
pre-shared-key changeme
peer 10.10.1.9
address 10.10.1.9
pre-shared-key changeme
!
crypto ikev2 profile AZURE-IKE-PROPOSAL
match address local 10.30.1.9
match identity remote address 20.166.203.25 255.255.255.255
match identity remote address 20.166.203.226 255.255.255.255
match identity remote address 10.10.1.9 255.255.255.255
authentication remote pre-share
authentication local pre-share
keyring local AZURE-KEYRING
lifetime 28800
dpd 10 5 on-demand
!
crypto ipsec transform-set AZURE-IPSEC-TRANSFORM-SET esp-gcm 256
mode tunnel
!
crypto ipsec profile AZURE-IPSEC-PROFILE
set transform-set AZURE-IPSEC-TRANSFORM-SET
set ikev2-profile AZURE-IKE-PROPOSAL
set security-association lifetime seconds 3600
!
interface Tunnel0
ip address 10.30.30.1 255.255.255.252
tunnel mode ipsec ipv4
ip tcp adjust-mss 1350
tunnel source 10.30.1.9
tunnel destination 20.166.203.25
tunnel protection ipsec profile AZURE-IPSEC-PROFILE
!
interface Tunnel1
ip address 10.30.30.5 255.255.255.252
tunnel mode ipsec ipv4
ip tcp adjust-mss 1350
tunnel source 10.30.1.9
tunnel destination 20.166.203.226
tunnel protection ipsec profile AZURE-IPSEC-PROFILE
!
interface Tunnel2
ip address 10.30.30.9 255.255.255.252
tunnel mode ipsec ipv4
ip tcp adjust-mss 1350
tunnel source 10.30.1.9
tunnel destination 10.10.1.9
tunnel protection ipsec profile AZURE-IPSEC-PROFILE
!
interface Loopback0
ip address 192.168.30.30 255.255.255.255
!
ip access-list extended NAT-ACL
permit ip 10.30.0.0 0.0.0.255 any
interface GigabitEthernet2
ip nat inside
interface GigabitEthernet1
ip nat outside
exit
ip nat inside source list NAT-ACL interface GigabitEthernet1 overload
!
ip route 0.0.0.0 0.0.0.0 10.30.1.1
ip route 192.168.22.12 255.255.255.255 Tunnel0
ip route 192.168.22.13 255.255.255.255 Tunnel1
ip route 192.168.10.10 255.255.255.255 Tunnel2
ip route 10.30.0.0 255.255.255.0 10.30.2.1
!
route-map ONPREM permit 100
match ip address prefix-list all
set as-path prepend 65003 65003 65003
route-map AZURE permit 110
match ip address prefix-list all
!
router bgp 65003
bgp router-id 192.168.30.30
neighbor 192.168.22.12 remote-as 65515
neighbor 192.168.22.12 ebgp-multihop 255
neighbor 192.168.22.12 soft-reconfiguration inbound
neighbor 192.168.22.12 update-source Loopback0
neighbor 192.168.22.12 route-map AZURE out
neighbor 192.168.22.13 remote-as 65515
neighbor 192.168.22.13 ebgp-multihop 255
neighbor 192.168.22.13 soft-reconfiguration inbound
neighbor 192.168.22.13 update-source Loopback0
neighbor 192.168.22.13 route-map AZURE out
neighbor 192.168.10.10 remote-as 65001
neighbor 192.168.10.10 ebgp-multihop 255
neighbor 192.168.10.10 soft-reconfiguration inbound
neighbor 192.168.10.10 update-source Loopback0
neighbor 192.168.10.10 route-map ONPREM out
network 10.30.0.0 mask 255.255.255.0
