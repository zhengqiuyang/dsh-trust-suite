#!/usr/bin/env bash
# Install the whole dsh-trust-suite family into a dsh profile.
# Usage: ./install.sh [profile]   (default: web)
#
# Installs each plugin directly from git (prebuilt lib/, no allowBuilds
# needed). Once the family is published to npm, `dsh plugin add
# dsh-trust-suite` will replace this script with a one-liner.
set -euo pipefail
profile="${1:-web}"
for p in dsh-read-guard dsh-pr-gate dsh-attest-chain dsh-mcp-test \
         dsh-janitor dsh-egress-gate dsh-prompt-drift dsh-freeze; do
  echo "== $p"
  dsh plugin --profile "$profile" add "github:zhengqiuyang/$p"
done
echo "All eight trust plugins installed into profile '$profile'."
