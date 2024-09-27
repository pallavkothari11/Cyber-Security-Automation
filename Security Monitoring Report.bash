#!/bin/bash

# Slack Webhook URL
SLACK_WEBHOOK_URL="Slack API String"

# Date of monitoring
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to send messages to Slack
send_to_slack() {
  local message=$1
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${message}\"}" ${SLACK_WEBHOOK_URL}
}

# Function to check log and send report to Slack
check_and_report() {
  local description=$1
  local log_file=$2
  local search_pattern=$3

  # Run the search pattern on the log file
  local matches=$(grep "${search_pattern}" ${log_file})

  if [[ ! -z "${matches}" ]]; then
    send_to_slack "Security Alert - ${description}:\n\`\`\`${matches}\`\`\`"
  fi
}

# 1. Unauthorized Access Detection
check_and_report "Unauthorized access attempts (failed logins)" "/var/log/auth.log" "Failed password"

# 2. Root Privilege Escalation
check_and_report "Root privilege escalation attempts (sudo/su usage)" "/var/log/auth.log" "sudo|su"

# 3. Failed Login Attempts
check_and_report "Failed login attempts" "/var/log/auth.log" "authentication failure"

# 4. New User or Group Creation
check_and_report "New user or group creation" "/var/log/auth.log" "useradd|groupadd"

# 5. Changes to Critical Files
check_and_report "Changes to critical system files (/etc/passwd, /etc/shadow)" "/var/log/audit/audit.log" "/etc/passwd|/etc/shadow"

# 6. Suspicious Network Activity
check_and_report "Suspicious network activity" "/var/log/syslog" "Deny|DROP"

# 7. Kernel Module Loading
check_and_report "Kernel module loading events" "/var/log/kern.log" "module inserted"

# 8. Sudo Misuse
check_and_report "Suspicious sudo activity" "/var/log/auth.log" "sudo: .*incorrect password attempt"

# 9. Suspicious SSH Key Manipulation
check_and_report "Suspicious SSH key manipulation" "/var/log/auth.log" "authorized_keys"

# 10. Service Restarts or Stops
check_and_report "Unexpected service restarts or stops" "/var/log/syslog" "Stopping|Stopped|Started"

# Additional Use Cases
# (Add more based on the patterns and logs for the other use cases as necessary)

# Report completion to Slack
send_to_slack "Security monitoring report completed at ${DATE}."

exit 0
