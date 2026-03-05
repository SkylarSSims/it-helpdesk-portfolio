
RUNBOOK: PRINTER NOT PRINTING

PROBLEM
User or users report printer not printing.

SCOPE
Determine whether issue affects a single user or multiple users.

LOGIC FLOW
Single user
→ Printer reachable
→ Restart print spooler / clear queue
→ Validate and stop

Multiple users
→ Printer unreachable or queue down
→ Printer/server/network issue
→ Escalate

LEVEL 1 ACTIONS
- Restart local print spooler (single user)
- Verify printer online (multi-user)

ESCALATION DETAILS
- Printer model
- Location
- IP address or queue name
- Outage start time

RESOLUTION
Printing validated with user(s).
