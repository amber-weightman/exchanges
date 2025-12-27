# Context Summary

This repository is a **learning lab project** designed to help develop practical skills relevant to working with complex telephone exchange systems (e.g. NSW Government).

## High-level goals

* Provide a **preconfigured Linux server environment** ready for immediate login and experimentation
* Focus on **operating, understanding, and extending** an existing system rather than learning installation from first principles
* Build skills that are:

  * directly transferable to a work context
  * reinforced through practical, motivating side projects

## Non-negotiables

* **Operating system:** SUSE Linux Server
* **Telephony context (work-related):** Mitel MiVoice MX-ONE (enterprise PABX)

  * We are **not installing real Mitel software**
  * Licensing and access make that infeasible for home use
  * The aim is to learn **transferable VoIP/SIP concepts**, not Mitel-specific tooling

## Learning approach

* Start simple and incremental
* Prefer **documentation + small scripts** over complex automation
* Treat the initial setup as a **reference implementation**
* Success indicators:

  * inspect running services
  * read logs
  * restart services
  * modify configs
  * query databases
  * experiment safely

## Planned project phases

### Phase 1 — Linux fundamentals

* SUSE Linux Server running as a **local VM**
* SSH access, users, permissions
* Package management (`zypper`)
* systemd services
* firewall basics
* logs and troubleshooting
* All setup steps documented clearly

### Phase 2A — Databases

* **PostgreSQL** as the primary database [UNLESS ANOTHER DB IS CONFIRMED TO BE MORE APPLICABLE IN A SPECIFIC WORK CONTEXT]
* SQL learning is a key goal
* Initial project: a **relational cocktail recipe database**

  * schema + seed data
  * example queries
  * basic backup/restore
* This is both a fun personal project and relevant to real-world systems
* PostgreSQL is chosen because it is commonly used in Mitel-adjacent tooling (e.g. reporting / call history systems), but this project is independent of Mitel itself

### Phase 2B — Media server

* Personal media server (e.g. **Plex Media Server**)
* Runs on the same SUSE server
* Intended to eventually live on a **physical home machine**, but can start in a VM
* Focus is on:

  * storage
  * permissions
  * networking
* Media files themselves are not part of version control

### Phase 3 — VoIP lab

* Learning VoIP fundamentals relevant to Mitel MX-ONE **conceptually**
* Use an **open SIP PBX (e.g. Asterisk)** as a learning analogue
* Goals are conceptual understanding:

  * extensions
  * call routing
  * voicemail
  * call logs
* This phase is explicitly **deferred** until Linux and database confidence is established

## Tooling and conventions

* Repo managed in **VS Code**
* Shell scripts for setup (`bash`)
* Clear README and human-readable docs
* Prefer:

  * clarity over cleverness
  * small scripts with comments explaining *why*
  * idempotent setup steps where practical
* Avoid hardcoded secrets; use environment variables or local untracked files

## What NOT to optimise for

* High availability, redundancy, or enterprise hardening
* Perfect automation or production readiness
* Replicating Mitel systems directly

## Key principle

This project is about **learning how systems behave once they already exist**, not about mastering installers or enterprise vendor tooling. The value is in understanding, operating, and extending a realistic server environment.
