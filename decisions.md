# Architecture Decision Records (ADRs)

---

## ADR-001 — MariaDB 11 over MySQL 8

**Status:** Accepted (2026-06-10)
**Context:** t3.micro has 1 GB RAM. MySQL 8 consumed ~380 MB at idle, leaving ~167 MB available — dangerously low.
**Decision:** Replace `mysql:8.0` with `mariadb:11`. Drop-in replacement; mysql2 driver is fully compatible. Saves ~180 MB RAM (MariaDB idles at ~108 MB).
**Migration:** `ALTER TABLE products MODIFY specifications LONGTEXT` run live. Data volume destroyed and re-seeded.
**Consequences:** `MARIADB_ROOT_PASSWORD` env var used instead of `MYSQL_ROOT_PASSWORD`. Healthcheck uses `healthcheck.sh --connect --innodb_initialized`.

---

## ADR-002 — Frontend built locally, never on EC2

**Status:** Accepted (2026-06-10)
**Context:** Vite build + all three containers starting simultaneously caused OOM kills on t3.micro. SSH became unresponsive.
**Decision:** Run `npm run build` on the developer's machine. Ship only `dist/`. Frontend `Dockerfile` is nginx-only (single stage, no Node).
**Consequences:** Node.js and npm must be installed on the deploy machine. `aws-deploy.sh` enforces this via prerequisite checks.
**Applies to all future projects on t3.micro or smaller.**

---

## ADR-003 — 2 GB swap on EC2

**Status:** Accepted (2026-06-10)
**Context:** t3.micro has no swap by default. Any RAM spike (e.g. `npm install`, container rebuild) would OOM-kill processes including sshd.
**Decision:** Add `/swapfile` 2 GB, `vm.swappiness=10`, persisted in `/etc/fstab`.
**Consequences:** Swap is a safety net, not a primary memory source. swappiness=10 means kernel only swaps when RAM is nearly exhausted.

---

## ADR-004 — Sequential container startup

**Status:** Accepted (2026-06-10)
**Context:** `docker compose up --build -d` starts all containers simultaneously, spiking RAM.
**Decision:** Start mysql first, wait for `healthy`, start backend, wait for `healthy`, start frontend. This is encoded in `aws-deploy.sh` and manually enforced.
**Consequences:** Slower first-boot (~90s total). Safer on memory-constrained hosts.

---

## ADR-005 — JWT in localStorage (not HttpOnly cookies)

**Status:** Accepted (initial design)
**Context:** SPA with Vue Router. Simple admin panel for a single trusted operator.
**Decision:** JWT stored in localStorage. Acceptable for a closed admin panel where the operator is the only user.
**Risk:** XSS could exfiltrate the token. Acceptable given the low attack surface and that the admin panel is not public-facing.
**Future:** If the user base grows, migrate to HttpOnly cookie + CSRF token.

---

## ADR-006 — Specifications stored as LONGTEXT HTML (not JSON)

**Status:** Accepted (2026-06-11)
**Context:** Admins needed formatted specifications (lists, bold, headings). JSON key-value was rigid and unformatted.
**Decision:** Store HTML string from Quill WYSIWYG editor. Column type changed from `JSON` to `LONGTEXT`.
**Backward compatibility:** Public product view detects legacy JSON objects and renders them as a key-value table. HTML strings render via `v-html`.
**Consequences:** No server-side sanitization of HTML currently. Acceptable: only authenticated admins write to this field.

---

## ADR-007 — Single EC2 instance (no load balancer, no RDS)

**Status:** Accepted (initial design)
**Context:** Small project, single client. Cost constraint is free tier / minimal.
**Decision:** All tiers on one t3.micro with Docker Compose. No RDS, no ALB, no ECS.
**Risk:** Single point of failure. Acceptable for this project size.
**Future:** If uptime SLA is required, migrate DB to RDS and add ALB + second instance.

---

## ADR-009 — nginx ^~ modifier on /uploads/ location

**Status:** Accepted (2026-06-11)
**Context:** nginx regex location `~* \.(jpg|png|gif|...)$` has higher priority than a plain prefix location `/uploads/`. Upload requests like `/uploads/photo.jpg` matched the regex and were served from nginx's own static directory (where they don't exist), returning 404 instead of proxying to the backend.
**Decision:** Add `^~` modifier: `location ^~ /uploads/ { proxy_pass http://backend:3000; }`. The `^~` modifier tells nginx to skip all regex evaluation when this prefix matches — ensuring upload requests always reach the backend.
**Rule:** Any nginx config with both a file-extension regex cache block AND a proxy location must use `^~` on the proxy location to prevent regex override.

---

## ADR-008 — Elastic IP assigned permanently

**Status:** Accepted
**Context:** EC2 public IP changes on stop/start. The app needs a stable address.
**Decision:** Allocate one Elastic IP tagged `eon-marketing-eip` and associate with the instance. Re-associate on every `start` command in `aws-deploy.sh`.
**Cost:** $0 while the instance is running. Charged ~$0.005/hr if instance is stopped.
