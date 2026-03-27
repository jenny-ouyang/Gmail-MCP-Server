#!/bin/bash
# Usage: ./setup-account.sh <account-name> [path-to-gcp-oauth.keys.json]
# Example: ./setup-account.sh personal ~/Downloads/gcp-oauth.keys.json

ACCOUNT="${1}"
OAUTH_SOURCE="${2}"

if [ -z "$ACCOUNT" ]; then
  echo "Usage: $0 <account-name> [path-to-gcp-oauth.keys.json]"
  echo "Example: $0 personal ~/Downloads/gcp-oauth.keys.json"
  exit 1
fi

ACCOUNT_DIR="$HOME/.gmail-${ACCOUNT}"
OAUTH_PATH="${ACCOUNT_DIR}/gcp-oauth.keys.json"
CREDENTIALS_PATH="${ACCOUNT_DIR}/credentials.json"

# Create account directory
mkdir -p "$ACCOUNT_DIR"

# Copy OAuth keys if provided
if [ -n "$OAUTH_SOURCE" ]; then
  cp "$OAUTH_SOURCE" "$OAUTH_PATH"
  echo "Copied OAuth keys to $OAUTH_PATH"
elif [ ! -f "$OAUTH_PATH" ]; then
  echo "Error: No gcp-oauth.keys.json found at $OAUTH_PATH"
  echo "Either provide a path as the second argument, or place it there manually."
  exit 1
fi

# Run auth flow
echo ""
echo "Opening browser to authenticate Gmail account: $ACCOUNT"
echo "Sign in with the correct Google account when the browser opens."
echo ""
GMAIL_OAUTH_PATH="$OAUTH_PATH" \
GMAIL_CREDENTIALS_PATH="$CREDENTIALS_PATH" \
node "$(dirname "$0")/dist/index.js" auth

if [ ! -f "$CREDENTIALS_PATH" ]; then
  echo "Auth failed — credentials.json was not created."
  exit 1
fi

# Write start-mcp.sh
cat > "${ACCOUNT_DIR}/start-mcp.sh" << SCRIPT
#!/bin/bash
export GMAIL_OAUTH_PATH=${OAUTH_PATH}
export GMAIL_CREDENTIALS_PATH=${CREDENTIALS_PATH}
export GMAIL_ACCOUNT_NAME=${ACCOUNT}
exec node $(dirname "$0")/dist/index.js
SCRIPT
chmod +x "${ACCOUNT_DIR}/start-mcp.sh"

echo ""
echo "Done! Account '$ACCOUNT' is ready."
echo ""
echo "Add this to your MCP config (Cursor: ~/.cursor/mcp.json or Claude Desktop config):"
echo ""
echo "  \"gmail-${ACCOUNT}\": {"
echo "    \"command\": \"${ACCOUNT_DIR}/start-mcp.sh\","
echo "    \"args\": []"
echo "  }"
echo ""
