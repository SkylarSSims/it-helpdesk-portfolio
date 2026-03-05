
HOME LAB NETWORK & SERVICES BLUEPRINT

PURPOSE
Document the design, addressing, segmentation, and services of a small home lab network to demonstrate real-world IT networking and documentation skills.

ROLES & SEGMENTATION
- User devices (laptops, phones)
- Lab/Server devices
- Admin/Infrastructure devices

Segmentation is documented by purpose to control blast radius and enable future growth.

IP ADDRESSING PLAN
Network: 192.168.10.0/24

- 192.168.10.1     Router / Default Gateway
- 192.168.10.10-29 Infrastructure (router, switch mgmt, AP)
- 192.168.10.30-49 Servers / Lab services
- 192.168.10.100-199 DHCP scope for user devices

Static or DHCP-reserved IPs are used for infrastructure and services.

DHCP
- Router provides DHCP
- Scope: 192.168.10.100-199
- Gateway: 192.168.10.1
- DNS: Local router or internal DNS service

DNS
- Hostnames resolve to internal IPs
- Supports services such as file server access

INTERNAL SERVICES
- File server accessible to user devices
Dependencies:
- IP addressing
- DNS resolution
- Network reachability

NETWORK DIAGRAM (LOGICAL)
Internet
  |
Router (192.168.10.1)
  |
Switch
  |-- User Devices (DHCP)
  |-- Lab Server (Static)
  |-- Admin Devices

DESIGN PRINCIPLES
- Predictability over performance tuning
- Clarity over complexity
- Document intent before implementation

SICP x HtDP SNAPSHOT
State Space:
{roles, IP ranges, services, dependencies}

Invariants:
- Infrastructure addresses are stable
- Roles define segmentation
- Design precedes configuration

Shape:
Stable graph of dependent services over shared network substrate
