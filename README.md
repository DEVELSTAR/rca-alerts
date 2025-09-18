
---

## **2️⃣ `rca-alerts` README**

```markdown
# RCA & Alerts API (Rails)

## Overview
Rails API that:
- Queries ClickHouse rollup metrics
- Detects anomalies (latency spikes, packet loss, endpoint down)
- Stores RCA events in MySQL
- Sends alerts via Slack / Email / Webhook
- Provides API endpoints for dashboard integration

---

## Tech Stack
- Ruby on Rails 8 (API-only)
- MySQL (RCA events storage)
- ClickHouse (metrics storage)
- Slack / Email / Webhook for alerts

---

## Prerequisites
- Ruby >= 3.2
- Rails >= 8
- Node.js + Yarn
- MySQL
- ClickHouse running
- `.env` file with:

```env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX
ALERT_WEBHOOK_URL=https://example.com/webhook
