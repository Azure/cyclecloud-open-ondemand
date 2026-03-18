#!/bin/bash
# Generate OOD-compliant disk quota JSON for the /shared NFS mount.
# Intended to run every 5 minutes via cron.
# See: https://osc.github.io/ood-documentation/latest/customizations.html#disk-quota-warnings-on-dashboard

MOUNT_PATH="/shared"
OUTPUT_FILE="/etc/ood/config/quota.json"

# Read filesystem stats (1K-block units, matching OOD's expectation of 1 block = 1 KiB)
read -r total_blocks used_blocks <<< "$(df -k --output=size,used "$MOUNT_PATH" | tail -1)"

if [ -z "$total_blocks" ] || [ -z "$used_blocks" ]; then
  exit 1
fi

cat > "$OUTPUT_FILE" <<EOF
{
  "version": 1,
  "timestamp": $(date +%s),
  "quotas": [
    {
      "type": "fileset",
      "user": "",
      "path": "${MOUNT_PATH}",
      "block_usage": 0,
      "total_block_usage": ${used_blocks},
      "block_limit": ${total_blocks},
      "file_usage": 0,
      "total_file_usage": 0,
      "file_limit": 0
    }
  ]
}
EOF
