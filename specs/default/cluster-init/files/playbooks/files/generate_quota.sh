#!/bin/bash
# Generate OOD-compliant disk quota JSON for the /shared NFS mount.
# Intended to run every 5 minutes via cron.
# See: https://osc.github.io/ood-documentation/latest/customizations.html#disk-quota-warnings-on-dashboard

MOUNT_PATH="/shared"
OUTPUT_FILE="/etc/ood/config/quota.json"

# Block usage (1K-block units, matching OOD's expectation of 1 block = 1 KiB)
read -r total_blocks used_blocks <<< "$(df -k --output=size,used "$MOUNT_PATH" | tail -1)"
# Inode (file count) usage
read -r total_inodes used_inodes <<< "$(df --output=itotal,iused "$MOUNT_PATH" | tail -1)"

if [ -z "$total_blocks" ] || [ -z "$used_blocks" ]; then
  exit 1
fi

# Default inodes to 0 if not available (some NFS servers don't report inodes)
total_inodes=${total_inodes:-0}
used_inodes=${used_inodes:-0}

TIMESTAMP=$(date +%s)

# Build a quota entry for each user with a home directory.
# OOD filters quotas by exact username match, so each user needs their own entry.
QUOTAS=""
FIRST=true
for homedir in /home/*/; do
  username=$(basename "$homedir")
  [ "$username" = "*" ] && continue
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    QUOTAS="${QUOTAS},"
  fi
  QUOTAS="${QUOTAS}
    {
      \"type\": \"user\",
      \"user\": \"${username}\",
      \"path\": \"${MOUNT_PATH}\",
      \"total_block_usage\": ${used_blocks},
      \"block_limit\": ${total_blocks},
      \"total_file_usage\": ${used_inodes},
      \"file_limit\": ${total_inodes}
    }"
done

cat > "$OUTPUT_FILE" <<EOF
{
  "version": 1,
  "timestamp": ${TIMESTAMP},
  "quotas": [${QUOTAS}
  ]
}
EOF
