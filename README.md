[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/agentrq-1?utm_medium=integration&utm_source=button&utm_campaign=agentrq)

# AgentRQ on Railway

One-click Railway template for [AgentRQ](https://github.com/agentrq/agentrq) **0.17.4**, the open-source (AGPL-3.0) human-in-the-loop task manager for AI coding agents: create tasks in a web app, let Claude Code, Codex, Gemini CLI or Cursor pick them up over MCP, and answer their questions and permission requests in real time.

## What it deploys

| Service | What it does |
|---|---|
| `AgentRQ` | Web app, API and MCP server on port 2026. Built from this repo's `Dockerfile`, which pins `agentrq/agentrq:0.17.4@sha256:de038f632cad3783e0f4c03624c4ad8e60dd667230dc9292ef2c6eb70f7d1357`. Health check `/readyz`. Volume at `/_storage` (attachments, skills, Pano docs, hooks). |
| `Postgres` | Railway's PostgreSQL, on its own volume. AgentRQ migrates its schema on start. |

The upstream image is built `FROM scratch` and runs as `nobody`, which can't write to a Railway volume. The `Dockerfile` copies its single static binary onto a pinned Alpine 3.22.8 base; `start.sh` makes the volume writable, then runs AgentRQ as `nobody`. Any unexpected stop exits non-zero, so Railway's restart policy brings it back. Measured on Railway with a 0.5 GB / 1 vCPU limit: about 20 MB of anonymous memory and 7 threads at idle, so it fits the Free plan.

## Variables

| Variable | Value | Notes |
|---|---|---|
| `AGENTRQ_AUTH_ROOT_ACCESS_TOKEN` | generated | Sign in with it at your Railway URL; also opens `/admin`. |
| `AGENTRQ_AUTH_JWT_SECRET` | generated | Signs sessions and MCP tokens. |
| `AGENTRQ_AUTH_WORKSPACE_TOKEN_KEY` | generated, 32 chars | Encrypts stored settings. Don't change it after the first start. |
| `AGENTRQ_BASE_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Change it if you add a custom domain. |
| `AGENTRQ_POSTGRES_*` | references to `Postgres` | Database connection over the private network. |
| `PORT` | `2026` | |

Fixed in `start.sh` (override with a variable if you need to): `ENV=production`, root sign-in on, built-in TLS off, empty `AGENTRQ_DOMAIN` so MCP URLs are path-based (`https://YOUR-DOMAIN/mcp/WORKSPACE-ID`; upstream's `WORKSPACE.mcp.DOMAIN` URLs need wildcard DNS), Railway's proxy trusted for client addresses, `MONOFLAKE_NODE=1`, and `GOMEMLIMIT` at 80% of the service's memory limit.

On first start AgentRQ copies its settings into the database; from then on change them at `/admin/config` (Google, GitHub or OAuth2 sign-in, SMTP, Slack, web push). Those optional features are left out of the template.

## After deploy

1. Copy `AGENTRQ_AUTH_ROOT_ACCESS_TOKEN` from the `AgentRQ` service's Variables tab.
2. Open the Railway URL and sign in with it.
3. Create a workspace and copy its MCP config from the workspace settings into your agent.

## Updates

Every service except Postgres builds from this repo. When a new AgentRQ version is pinned on `main`, Railway shows deployers an update notice; read `CHANGELOG.md` first (breaking changes are listed first) and apply it when ready. Upstream tags images on Docker Hub as `X.Y.Z`.

## Licence

AgentRQ is AGPL-3.0 ([source](https://github.com/agentrq/agentrq/tree/v0.17.4)). This wrapper only repackages the official image; no commercial-licence parts are used.
