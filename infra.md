# Infrastructure

---

## AWS Account

| Property | Value |
|---|---|
| Account ID | 334877974462 |
| Region | ap-southeast-1 (Singapore) |
| IAM deploy user | `eon-deploy` |
| Deploy user policy | EC2 describe/run/stop/start/terminate, EIP allocate/associate/release, S3 (none currently) |

---

## EC2 Instance

| Property | Value |
|---|---|
| Instance ID | `i-05b9606abc9ed1ef1` |
| Instance type | `t3.micro` (1 vCPU, 1 GB RAM) |
| AMI | Amazon Linux 2023 (latest at deploy time) |
| Key pair | `eon-marketing-aws` → `~/.ssh/eon-marketing-aws.pem` |
| SSH user | `ec2-user` |
| Elastic IP | `47.131.27.213` (permanent) |
| EIP allocation | tagged `eon-marketing-eip` |
| Storage | 30 GB gp3 EBS |
| CPU mode | Unlimited burst (enabled to prevent throttle at 0 credits) |
| Swap | 2 GB `/swapfile`, `vm.swappiness=10`, persisted in `/etc/fstab` |
| App directory | `/home/ec2-user/eon/` |

---

## Security Group

| Name | `eon-marketing-sg` |
|---|---|
| Port 22 | TCP, 0.0.0.0/0 (SSH) |
| Port 9090 | TCP, 0.0.0.0/0 (App) |
| Port 3306 | TCP, 0.0.0.0/0 (MariaDB — **tighten before production handoff**) |

> **Risk:** Port 3306 is currently open to the world. Restrict to the EC2 security group itself (self-referencing rule) before going fully public.

---

## SSH Access

```bash
# Always use Windows OpenSSH (not Git Bash bundled ssh)
/c/Windows/System32/OpenSSH/ssh.exe \
  -o StrictHostKeyChecking=accept-new \
  -i ~/.ssh/eon-marketing-aws.pem \
  ec2-user@47.131.27.213

# SCP
/c/Windows/System32/OpenSSH/scp.exe \
  -i ~/.ssh/eon-marketing-aws.pem \
  <local> ec2-user@47.131.27.213:<remote>
```

---

## AWS CLI

```bash
# Corporate SSL proxy workaround — always pass --no-verify-ssl
aws --no-verify-ssl ec2 describe-instances ...

# Alias defined in aws-deploy.sh:
aws() { command aws --no-verify-ssl "$@" 2>/dev/null; }
```

---

## Docker on EC2

| Property | Value |
|---|---|
| Installation | `dnf install -y docker` (Amazon Linux 2023) |
| Compose plugin | `/usr/local/lib/docker/cli-plugins/docker-compose` |
| Buildx plugin | `/usr/local/lib/docker/cli-plugins/docker-buildx` |
| Run prefix | `sudo docker ...` (ec2-user is not in docker group across SSH sessions) |

---

## Deploy Script

`aws-deploy.sh` — single-file deploy controller.

| Command | Action |
|---|---|
| `./aws-deploy.sh deploy` | Full infra + app first-time deploy |
| `./aws-deploy.sh update` | Build frontend locally, upload, rebuild containers |
| `./aws-deploy.sh status` | Instance + container health |
| `./aws-deploy.sh logs [svc]` | Tail container logs |
| `./aws-deploy.sh ssh` | Open SSH session |
| `./aws-deploy.sh start` | Start stopped instance + re-associate EIP |
| `./aws-deploy.sh stop` | Graceful container stop + EC2 stop |
| `./aws-deploy.sh restart` | Restart containers (no rebuild) |
| `./aws-deploy.sh destroy` | Terminate instance (with confirmation) |

**Prerequisites checked at deploy time:** `aws`, `ssh`, `scp`, `tar`, `curl`, `node`, `npm`

---

## Resource Consumption (steady state)

| Service | RAM |
|---|---|
| MariaDB 11 | ~108 MB |
| Node.js backend | ~32 MB |
| nginx frontend | ~5.5 MB |
| ECS agent | ~17 MB |
| OS + buffers | ~196 MB |
| **Available** | **~411 MB** |
| **Swap (safety)** | **2 GB** |

---

## Backup & Recovery

- **Database:** No automated backups currently. Manual: `sudo docker exec eon_mysql mariadb-dump ...`
- **Uploads:** Stored in Docker named volume `eon_uploads_data`. Not backed up externally.
- **Code:** Git repository at `https://github.com/melvin-akino/product-catalog`

> **Risk:** No automated backup strategy. Recommend AWS Backup or a daily cron snapshot before production handoff.

---

## Cost Estimate (monthly)

| Resource | Cost |
|---|---|
| t3.micro (running 24/7) | ~$8.50 |
| 30 GB gp3 EBS | ~$2.40 |
| Elastic IP (instance running) | $0.00 |
| Data transfer (minimal) | ~$0.50 |
| **Total** | **~$11–12 / month** |

Free tier eligible for the first 12 months (750 hrs t3.micro + 30 GB EBS).
