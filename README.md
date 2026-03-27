# Gmail MCP — Multi-Account

A Gmail MCP server that actually supports multiple accounts. Fork of the archived [GongRzhe/Gmail-MCP-Server](https://github.com/GongRzhe/Gmail-MCP-Server) with two fixes the original never shipped:

1. **Token refresh persistence** — refreshed OAuth tokens are saved back to disk. Without this, each account silently loses auth after the first token expiry.
2. **Account isolation** — each server instance knows which account it is via `GMAIL_ACCOUNT_NAME`. The MCP server name becomes `gmail-personal`, `gmail-business`, etc. instead of all four showing as `gmail`.

Works with Claude Desktop, Cursor, or any MCP-compatible client.

---

## Setup

### 1. Google Cloud credentials

You need a `gcp-oauth.keys.json` for each account — or one shared OAuth app with separate tokens. The simplest approach: one Google Cloud project, one OAuth client, one `gcp-oauth.keys.json` file used by all accounts.

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project → Enable the Gmail API
3. Create OAuth 2.0 credentials (Desktop app type)
4. Download as `gcp-oauth.keys.json`

### 2. Create per-account directories

```bash
mkdir -p ~/.gmail-personal ~/.gmail-business ~/.gmail-newsletter ~/.gmail-payments
```

Copy your `gcp-oauth.keys.json` into each:

```bash
cp gcp-oauth.keys.json ~/.gmail-personal/
cp gcp-oauth.keys.json ~/.gmail-business/
# repeat for each account
```

### 3. Run setup for each account

One command per account. It opens a browser, you sign in with the right Google account, and it creates everything automatically.

```bash
# The second argument is where your downloaded keys file is right now.
# It gets copied into ~/.gmail-personal/ — Downloads is not used after this.
npx gmail-mcp-multiauth setup personal ~/Downloads/gcp-oauth.keys.json
npx gmail-mcp-multiauth setup work     ~/Downloads/gcp-oauth.keys.json
npx gmail-mcp-multiauth setup client   ~/Downloads/gcp-oauth.keys.json
```

After each command, these files exist in their own folder:
```
~/.gmail-personal/
  gcp-oauth.keys.json   ← copied from your download
  credentials.json      ← written after you authenticate
  start-mcp.sh          ← generated, ready to use
```

The setup command also prints the exact JSON block to paste into your MCP config.

### 4. Add to your MCP config

**Cursor** (`~/.cursor/mcp.json`) or **Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "gmail-personal": {
      "command": "/Users/YOUR_NAME/.gmail-personal/start-mcp.sh",
      "args": []
    },
    "gmail-business": {
      "command": "/Users/YOUR_NAME/.gmail-business/start-mcp.sh",
      "args": []
    }
  }
}
```

Restart your client. Each account shows up as a separate MCP server with its own name.

---

## Environment variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `GMAIL_OAUTH_PATH` | Yes | `~/.gmail-mcp/gcp-oauth.keys.json` | Path to your OAuth client keys |
| `GMAIL_CREDENTIALS_PATH` | Yes | `~/.gmail-mcp/credentials.json` | Where tokens are stored/refreshed |
| `GMAIL_ACCOUNT_NAME` | No | `default` | Label for this account (e.g. `personal`, `work`) |

---

## What it can do

- Send, draft, read, search emails
- Attachments (send and download)
- Label management (create, update, delete, list)
- Gmail filters
- Batch operations (mark read, move, delete)
- HTML emails

---

## Single-account setup

If you only need one account, skip the wrapper scripts and configure directly:

```json
{
  "mcpServers": {
    "gmail": {
      "command": "npx",
      "args": ["-y", "@jessicaoy89/gmail-mcp"],
      "env": {
        "GMAIL_OAUTH_PATH": "/Users/YOU/.gmail/gcp-oauth.keys.json",
        "GMAIL_CREDENTIALS_PATH": "/Users/YOU/.gmail/credentials.json",
        "GMAIL_ACCOUNT_NAME": "main"
      }
    }
  }
}
```

---

## Credit

Originally built by [GongRzhe](https://github.com/GongRzhe). Forked and maintained here after the original was archived in March 2026.
