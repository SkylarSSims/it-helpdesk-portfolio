# Secure Notes & Backup Mini-System

**Repo:** `secure-notes-backup`  
**Status:** COUNTED (3-Pass Complete)  
**Goal:** Protect sensitive notes with encryption-at-rest and ensure reliable recovery via tested backups.

---

## 1) Problem Statement
You want a lightweight notes system that:
- Keeps notes **confidential** if a laptop/drive is lost or stolen.
- Keeps notes **available** if files are deleted or a device fails.
- Preserves **integrity** (detect corruption/tampering) during restore.
- Provides a clear, repeatable **recovery procedure**.

---

## 2) Threat Model (What can go wrong?)
### Threats
- **Theft / Lost device:** attacker gets the files/backup media.
- **Accidental deletion:** user deletes notes or a folder.
- **Hardware failure:** disk dies, OS reinstall needed.
- **Corruption / tampering:** files get corrupted, partially copied, or modified.

### Controls (Threat → Control)
- Theft → **Encrypt notes before backup** (confidentiality)
- Deletion / failure → **Backups** (availability)
- Corruption / tampering → **Integrity verification** (hash/verify during restore)
- Operational failure → **Test recovery** (prove the system works)

---

## 3) Core Invariants (Rules you never break)
1. **Encrypt first, then back up.**
2. **Key/passphrase must be separate from data and backups.**
3. A backup is not “real” until a **restore test** succeeds.
4. Recovery steps must be **written and runnable**.

---

## 4) Repository Layout (Recommended)
```text
secure-notes-backup/
  README.md
  notes/                 # plaintext lives here briefly (or not at all)
  vault/                 # encrypted outputs (safe to back up)
  backups/               # backup archives (encrypted data only)
  scripts/
    new_note.sh          # create a note (plaintext → encrypted)
    list_notes.sh        # list encrypted notes
    view_note.sh         # decrypt on demand
    backup_notes.sh      # copy/pack vault → backups with timestamp
    restore_test.sh      # restore + verify + decrypt test
  docs/
    SECURITY_MODEL.md
    RECOVERY.md
    USAGE.md
```

---

## 5) Operational Flow (What you do)
### Create note
- Write note (temporary plaintext)  
- Encrypt to `vault/`  
- Optionally delete plaintext immediately

### Backup
- Package/copy `vault/` to `backups/` with timestamp
- Keep multiple versions (rotation policy)

### Restore Test (Scheduled)
- Restore the latest backup to a temp folder
- Verify integrity (hash/verify)
- Decrypt one known note successfully

---

## 6) Tiny ASCII Flow Sketch
```text
Write note → Encrypt → Store in vault → Backup vault → Restore test → STOP
                 ↑                         |
                 └──────── key separate ───┘
```

---

## 7) Script Specs (Minimal, Resume-Friendly)
> You can implement these in Bash (Linux/WSL) or PowerShell. Use GPG/OpenSSL as preferred.

### `scripts/new_note.sh` (or .ps1)
- Inputs: title, editor text
- Output: encrypted file in `vault/`
- Behavior:
  - writes plaintext to temp
  - encrypts
  - deletes temp

### `scripts/backup_notes.sh`
- Creates timestamped backup (zip/tar) of `vault/`
- Stores into `backups/`
- Optional: keep last N backups

### `scripts/restore_test.sh`
- Restores latest backup into temp directory
- Verifies file counts and/or hashes
- Attempts decrypt of a known file
- Returns success/failure exit code

---

## 8) Recovery Procedure (Print-Ready)
### Scenario: “Laptop died”
1. Install tools (GPG/OpenSSL) on new machine.
2. Retrieve latest backup archive from backup location.
3. Restore archive to `vault/` directory.
4. Verify integrity (hash/verify).
5. Decrypt a known note to confirm success.
6. Resume normal operation (encrypt first, then backup).

### If recovery fails
- If you **cannot decrypt**, check key/passphrase availability (never stored with backups).
- If files are **corrupt**, try an earlier backup version.
- If integrity check fails repeatedly, stop and investigate backup media health.

---

## 9) One-Page Notebook Summary (½–1 page)
This mini-system solves two problems at once: protecting sensitive notes from unauthorized access and ensuring notes can be recovered after loss. Encryption at rest supports confidentiality: even if a laptop or external drive is stolen, the contents remain unreadable without the key. Backups support availability: accidental deletion, disk failure, or OS reinstall should not destroy your data. Integrity is handled by verification during restore so corruption or tampering can be detected.

The key operational invariant is “encrypt first, then back up.” Backups inherit whatever security posture the data has, so encryption must happen before any copying. Another critical invariant is key separation: the passphrase or key cannot live with the encrypted data or on the backup media. If an attacker steals the drive and the key is next to it, encryption becomes decoration.

Finally, backups are not trustworthy until recovery has been tested. A written recovery procedure is part of the deliverable because it converts a backup from a theory into a reliable system. The system’s shape is a simple pipeline: write note → encrypt → store in vault → backup vault → restore test. When you can successfully restore and decrypt a known note from the latest backup, the system is valid and “done.”

---

## 10) SICP × HtDP Snapshot
- **State space:** `{notes, key, encrypted_vault, backups, restore_target}`  
- **Transitions:** `encrypt → backup → restore → verify → decrypt-test`  
- **Invariants:** `key != data`, `encrypt-before-backup`, `restore-tested`  
- **Shape:** **pipeline** (linear flow) with a validation terminal node.
