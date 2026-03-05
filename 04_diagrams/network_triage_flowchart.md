# Network Triage Flowchart

```

User reports network issue
→ Determine scope (single vs multiple users)
→ Check IP config (ipconfig)
→ 169.254.x.x? → DHCP
→ Valid IP → Ping IP
→ Ping IP works, DNS fails → DNS
→ VPN connected + internal fails → VPN routing
→ Escalate if outside L1 control

```