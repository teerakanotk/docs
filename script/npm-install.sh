#!/bin/bash

# Define log file path for detailed output
LOG_FILE="/tmp/npm_install_$(date +%Y%m%d%H%M%S).log"

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
execute_step 0 "sudo apt-get update && sudo apt-get upgrade -y"
execute_step 1 "sudo apt install -y curl docker.io docker-compose"
execute_step 2 "mkdir npm && cd npm && touch docker-compose.yml"
execute_step 3 "sudo nano docker-compose.yml"
