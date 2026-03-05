# Runbook: No Internet / Slow Internet

**Audience:** Level 1 Help Desk / Desktop Support  
**Goal:** Restore connectivity or escalate with clear evidence.

---

## Symptoms (What the user reports / what you observe)
- Websites time out or load extremely slowly
- Wi-Fi/Ethernet shows “Connected” but no browsing
- VPN disconnects frequently (may be symptom, not root cause)
- Multiple users in the same area report similar issues (scope indicator)

## Likely Causes (most common first)
1. User device is not actually connected (Wi-Fi disconnected, cable loose, airplane mode)
2. Local network issue (bad cable/port, weak Wi-Fi signal, AP issue)
3. DHCP failure (no valid lease; APIPA 169.254.x.x)
4. DNS resolution issue (IP works, names fail)
5. Captive portal / network access control block
6. Upstream outage (router/ISP) or broader network incident

---

## Resolution Steps (Level 1)

### 1) Confirm scope (fast)
- Ask: “Is it only you, or are others nearby affected?”
- If **multiple users** are affected, note location and time, then jump to **Escalation Criteria**.

### 2) Physical / connection check
- Ethernet: verify cable seated, link light on NIC/switch port; try a known-good cable/port if available.
- Wi-Fi: verify correct SSID; toggle Wi-Fi off/on; move closer to AP if signal is weak.
- Confirm device is not in airplane mode.

### 3) Capture network state (Windows)
Run:
```powershell
ipconfig /all
```
Record:
- IPv4 address, subnet mask
- Default gateway
- DNS servers
- DHCP enabled (Yes/No)

### 4) If APIPA (169.254.x.x) or no default gateway (DHCP suspect)
Attempt lease renewal:
```powershell
ipconfig /release
ipconfig /renew
```
If renewal fails:
- Restart the network adapter (Device Manager or network settings) and retry.
- If still failing and others are impacted, escalate.

### 5) Connectivity isolation tests (no DNS first)
Test external IP:
```powershell
ping 8.8.8.8
```

Interpretation:
- **Fail:** likely routing/local network issue (gateway, Wi-Fi, switch/AP, ISP) → continue to step 6.
- **Success:** IP path works → proceed to DNS test.

### 6) DNS test (name resolution)
```powershell
ping google.com
```
- If **ping 8.8.8.8 succeeds** but **ping google.com fails**: DNS is likely the issue.

Remediate:
```powershell
ipconfig /flushdns
```
Then retest `ping google.com`.

Optional (only if symptoms persist):
```powershell
netsh winsock reset
```
Reboot required after Winsock reset.

### 7) Gateway and local path checks (if external IP ping fails)
- Ping default gateway (from `ipconfig /all`):
```powershell
ping <default_gateway_ip>
```
Interpretation:
- **Gateway ping fails:** local link/Wi-Fi/AP/switch issue. Try cable/port, reconnect Wi-Fi, adapter reset.
- **Gateway ping succeeds but external fails:** upstream routing/ISP/AP issue; document and escalate.

### 8) Captive portal / NAC quick check (if on guest/corp Wi-Fi)
- Open a browser to a non-HTTPS site (if policy allows) to trigger captive portal.
- If captive portal appears, authenticate and retest browsing.

---

## Validation (confirm the fix)
- User can open 2-3 different websites
- `ping 8.8.8.8` and `ping google.com` succeed
- If relevant: VPN reconnects and stays stable for several minutes

## Evidence to record in the ticket
- Scope: single user vs multiple users
- Output snippets: `ipconfig /all`, ping results
- Exact error messages and timestamps
- Location (floor/room) and connection type (Wi-Fi SSID or Ethernet)

## Escalation Criteria (stop Level 1 here)
Escalate to Network / SysAdmin when:
- Multiple users are affected (suspected AP/switch/router/ISP incident)
- DHCP renewal consistently fails (especially across multiple devices)
- Gateway unreachable after basic physical/Wi-Fi checks
- DNS appears broken for multiple users or across a site
- You suspect a security/NAC block or policy enforcement issue

---

**Last updated:** 2026-02-18
