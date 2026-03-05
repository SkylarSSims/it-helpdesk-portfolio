
RUNBOOK: NO INTERNET – MULTIPLE USERS

PROBLEM
Multiple users report loss of internet connectivity at the same time.

SCOPE & ASSESSMENT
- Confirm number of affected users
- Identify location (floor/building), VLAN, or SSID
- Determine wired vs Wi-Fi impact

LOGIC FLOW
Multiple users affected
→ Same time/location
→ Identify shared dependency (AP, switch, router, ISP)
→ Verify status indicators
→ Escalate

LEVEL 1 RULES
- Do not modify endpoints
- Do not reinstall drivers
- Gather evidence only

ESCALATION PAYLOAD
- Outage start time
- Number of users affected
- Locations / segments
- Wired vs Wi-Fi
- Visible infra status

RESOLUTION
Service restored by Network/ISP team and validated with users.
