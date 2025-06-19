#!/bin/bash

# Zabbix server
# Date: 2025-06-18
# Zabbix Version: 7.0 LTS
# Database: PostgreSQL 17
# Web Server: Nginx

# Define log file path for detailed output
LOG_FILE="/tmp/zabbix_install_$(date +%Y%m%d%H%M%S).log"

STEPS=(
    "Update and install package requirement"
    "Set locale variables to en_US.UTF8"
    "Install Zabbix repository"
    "Install Zabbix server, frontend, agent2"
    "Install Zabbix agent2 plugins"
    "Install Postgresql database"
    "Create initial database"
    "Configure Zabbix Server"
    "Remove default nginx page"
    "Restart and enable services"
)

function execute_step() {
    local step_index="$1"
    local command="$2"
    local allow_failure=${3:-false}
    local step_name="${STEPS[$step_index]}" # Get the descriptive name of the step

    # Display current name of step on console
    echo "- $step_name..."

    # Log the step header and the command being executed to the detailed log file
    echo "=============================================" >>"$LOG_FILE"
    echo "- $step_name" >>"$LOG_FILE"
    echo "- Command: $command" >>"$LOG_FILE"
    echo "=============================================" >>"$LOG_FILE"
    echo "" >>"$LOG_FILE"

    # Execute the command. Redirect all stdout and stderr to the log file.
    # This prevents the command's verbose output from cluttering the terminal
    # and interfering with the checklist UI.
    if eval "$command" >>"$LOG_FILE" 2>&1; then
        return 0 # Indicate success
    else
        # If command fails, update checklist item to 'FAILED' status
        update_checklist_item "$step_index" 3
        if [ "$allow_failure" = false ]; then
            # If failure is not allowed, print error message to console and exit
            echo ""
            echo "============================================="
            echo "Error: Step '$step_name' failed! Please check the log file ($LOG_FILE) for details."
            echo "============================================="
            exit 1 # Exit the script with an error code
        fi
        return 1 # Indicate failure
    fi
}

# --- Main Script Execution Starts Here ---

echo "========================================================"
echo "Starting Zabbix Server 7.0 LTS installation"
echo "Detailed installation: $LOG_FILE"
echo "========================================================"

echo ""

# --- Execute Installation Steps ---
# Call execute_step for each phase of the installation, passing the step index, command, and allow_failure if needed.

execute_step 0 "sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get install -y gnupg gnupg1 gnupg2"

execute_step 1 "sudo sed -i 's/^# \\(en_US\\.UTF-8 UTF-8\\)$/\\1/' /etc/locale.gen && sudo locale-gen && sudo update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8"

execute_step 2 "wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu22.04_all.deb -O zabbix-release_latest_7.0+ubuntu22.04_all.deb && sudo dpkg -i zabbix-release_latest_7.0+ubuntu22.04_all.deb && sudo apt-get update -y && sudo rm zabbix-release_latest_7.0+ubuntu22.04_all.deb"

execute_step 3 "sudo apt-get install -y zabbix-server-pgsql zabbix-frontend-php php8.1-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2"

execute_step 4 "sudo apt-get install -y zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql"

execute_step 5 "sudo apt-get install -y postgresql-common && echo | sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh && sudo apt-get install -y postgresql-17"

# --- Create initial PostgreSQL database for Zabbix ---
ZABBIX_DB="zabbix"
ZABBIX_USER="zabbix"
# Generate a strong, random password for the Zabbix database user
# Uses /dev/urandom for randomness, 'tr' to filter for alphanumeric characters and underscore,
# and 'head -c 22' to get a 22-character string.
ZABBIX_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9#@ | head -c 22)
echo "ZABBIX_PASSWORD: $ZABBIX_PASSWORD" >>"$LOG_FILE" # Also log the password for later reference

execute_step 6 "sudo -u postgres psql -c \"CREATE USER $ZABBIX_USER WITH ENCRYPTED PASSWORD '$ZABBIX_PASSWORD';\" && sudo -u postgres createdb -O \"$ZABBIX_USER\" -E Unicode -T template0 \"$ZABBIX_DB\" && sudo zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u $ZABBIX_USER psql $ZABBIX_DB"

execute_step 7 "sudo sed -i \"s/^# DBHost=.*/DBHost=localhost/\" /etc/zabbix/zabbix_server.conf &&  sudo sed -i \"s/^# DBPassword=.*/DBPassword=$ZABBIX_PASSWORD/\" /etc/zabbix/zabbix_server.conf"

execute_step 8 "sudo rm -f /etc/nginx/sites-enabled/default && sudo rm -f /etc/nginx/sites-available/default"

execute_step 9 "sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.1-fpm && sudo systemctl enable zabbix-server zabbix-agent2 nginx php8.1-fpm"

echo ""

echo "========================================================"
echo "- Access the Zabbix frontend via your web browser"
echo "http://$(hostname -I | awk '{print $1}')/"
echo ""
echo "- Zabbix database connection credentials"
echo "User: $ZABBIX_USER"
echo "password: $ZABBIX_PASSWORD"
echo ""
echo "- Default Zabbix frontend login credentials"
echo "Username: Admin"
echo "Password: zabbix"
echo ""
echo "Please change the default passwords after the first login"
echo "========================================================"
