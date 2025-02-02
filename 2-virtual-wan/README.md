
# Virtual WAN <!-- omit from toc -->

Contents
<!-- TOC -->
- [1. Virtual WAN - Single Region](#1-virtual-wan---single-region)
- [2. Virtual WAN - Dual Region](#2-virtual-wan---dual-region)
- [3. Secured Virtual WAN - Single Region](#3-secured-virtual-wan---single-region)
- [4. Secured Virtual WAN - Dual Region](#4-secured-virtual-wan---dual-region)
<!-- /TOC -->

Terraform codes in this collection cover different hub and spoke network patterns using Virtual WAN.

## 1. Virtual WAN - Single Region

[**Terraform Code**](./1-vwan-single-region/)

Deploy a single-region Virtual WAN (Vwan) topology to observe traffic routing patterns. Learn about traffic routing patterns, [hybrid DNS](https://learn.microsoft.com/en-us/azure/dns/private-resolver-hybrid-dns) resolution, [connecting NVA](https://learn.microsoft.com/en-us/azure/virtual-wan/scenario-bgp-peering-hub) into the virtual hub, and [PrivateLink Services](https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview) access to IaaS, [PrivateLink](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) access to PaaS services.

![Virtual WAN (Single Region)](../images/scenarios/2-1-vwan-single-region.png)

## 2. Virtual WAN - Dual Region

[**Terraform Code**](./2-vwan-dual-region/)

Deploy a dual-region Virtual WAN (Vwan) topology to observe traffic routing patterns. Learn about multi-region traffic routing patterns, [hybrid DNS](https://learn.microsoft.com/en-us/azure/dns/private-resolver-hybrid-dns) resolution, [connecting NVA](https://learn.microsoft.com/en-us/azure/virtual-wan/scenario-bgp-peering-hub) into the virtual hubs, and [PrivateLink Services](https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview) access to IaaS, [PrivateLink](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) access to PaaS services.

![Virtual WAN (Dual Region)](../images/scenarios/2-2-vwan-dual-region.png)

## 3. Secured Virtual WAN - Single Region

[**Terraform Code**](./3-vwan-sec-single-region/)

Deploy a single-region Secured Virtual WAN (Vwan) topology to observe traffic routing patterns. [Routing Intent](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies) feature is enabled to allow traffic inspection through the Azure firewall in the virtual hub. Learn about traffic routing patterns, routing intent [security policies](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies), [hybrid DNS](https://learn.microsoft.com/en-us/azure/dns/private-resolver-hybrid-dns) resolution, NVA integration into the virtual hub, and [PrivateLink Services](https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview) access to IaaS, [PrivateLink](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) access to PaaS services.

![Secured Virtual WAN (Single Region)](../images/scenarios/2-3-vwan-sec-single-region.png)

## 4. Secured Virtual WAN - Dual Region

[**Terraform Code**](./4-vwan-sec-dual-region/)

Deploy a dual-region Secured Virtual WAN (Vwan) topology to observe traffic routing patterns. [Routing Intent](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies) feature is enabled to allow traffic inspection through the Azure firewalls in the virtual hubs. Learn about multi-region traffic routing patterns, routing intent [security policies](https://learn.microsoft.com/en-us/azure/virtual-wan/how-to-routing-policies), [hybrid DNS](https://learn.microsoft.com/en-us/azure/dns/private-resolver-hybrid-dns) resolution, [connecting NVA](https://learn.microsoft.com/en-us/azure/virtual-wan/scenario-bgp-peering-hub) into the virtual hubs, and [PrivateLink Services](https://learn.microsoft.com/en-us/azure/private-link/private-link-service-overview) access to IaaS, [PrivateLink](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview) access to PaaS services.

![Secured Virtual WAN (Dual Region)](../images/scenarios/2-4-vwan-sec-dual-region.png)
