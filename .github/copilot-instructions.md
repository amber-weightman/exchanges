---
description: 'General Copilot instructions'
applyTo: '**'
---

# Copilot Instructions

## Purpose
This repo is a learning lab for a SUSE Linux server used to build and operate a small set of home/server services. The project is designed to be simple, engaging, and repeatable.

Primary goals:
- Learn how to set up and configure a SUSE Linux server (operate, inspect, troubleshoot, extend)
- Build confidence with databases and SQL via a fun “cocktail recipes” relational database
- Setup a home media server (Plex) to serve media to devices on the local network
- Later, explore VoIP fundamentals in a lab environment

## Non-negotiables
- OS: SUSE Linux Server
- VoIP reference system (conceptual target): Mitel MiVoice MX-ONE (work context)
  - We will learn transferable concepts using an open SIP PBX in the lab (not Mitel itself)

## Anticipated Tech Stack
Core:
- SUSE Linux Server (VM first; later possibly physical machine)
- Git + VS Code
- Shell scripts for repeatable setup (bash), plus README documentation

Database:
- PostgreSQL
- SQL migration scripts in `postgres/` (schema + seed data)
- Optional: pgAdmin (local) or psql CLI

Media server:
- Plex Media Server (likely via packages or Snap if appropriate)

VoIP lab (later):
- Asterisk (or similar SIP PBX) for learning concepts (extensions, voicemail, call routing)
- Softphone clients for testing (e.g., Zoiper/Linphone) — not required until the VoIP phase
- Optional future: voicemail audio capture + transcription + notifications (email/SMS)

## Repo Conventions
- Prefer small scripts with clear names (e.g., `setup/01-base-system.sh`)
- Keep steps readable over clever
- Add comments explaining WHY a step exists (not just what it does)
- Avoid hardcoding secrets (passwords, API keys, SIP credentials); use env vars or local untracked files
- Write docs for a learner: include “how to check it worked” and “how to troubleshoot” sections

## Copilot Guidance
When suggesting code or commands:
- Assume SUSE Linux (zypper, systemd, firewalld)
- Prefer idempotent scripts when practical (safe to rerun)
- Prefer Postgres defaults unless there’s a strong reason to change
- Include verification commands (e.g., `systemctl status ...`, `ss -tulpn`, `psql ...`)
- Keep suggestions minimal and incremental; avoid introducing new tools unless needed

## Directory Outline
- `README.md` — overview + how to use this repo
- `scripts/setup/` — server setup scripts and notes
- `postgres/` — schema.sql, seed-data.sql, example queries, exercises
- `doc/` — common commands, troubleshooting, backup/restore notes, other documentation

## Querying Documentation

### Microsoft Documentation

Use `microsoft-learn` MCP tools for VS Code APIs, Azure, .NET, TypeScript, and other Microsoft technologies Available tools:
- `microsoft_docs_fetch` - Complete documentation pages
- `microsoft_docs_search` - Search across Microsoft Learn
- `microsoft_code_sample_search` - Find code examples

### Context7 Documentation

Use `context7` MCP tools for general library documentation (React, Node packages, frameworks). Available tools:
- `resolve-library-id` - Find library's Context7 ID
- `get-library-docs` - Fetch documentation and code examples

Use these when instruction files don't cover a scenario or you need current information.