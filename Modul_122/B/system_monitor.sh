#!/bin/bash

# Funktion zur Formatierung und Ausgabe der Systeminformationen
print_system_info() {
    local output=$1
    local now=$(date '+%Y-%m-%d %H:%M:%S')
    local uptime=$(uptime -p)
    local disk_usage=$(df -h / | awk 'NR==2 {print $4}')
    local hostname=$(hostname)
    local ip_address=$(hostname -I | awk '{print $1}')
    local os_name=$(uname -o)
    local os_version=$(uname -r)
    local cpu_model=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo)
    local cpu_cores=$(nproc)
    local mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    local mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    local mem_free=$(free -h | awk '/^Mem:/ {print $4}')

    printf "%-25s %-25s\n" "Timestamp:" "$now"
    printf "%-25s %-25s\n" "System Uptime:" "$uptime"
    printf "%-25s %-25s\n" "Free Disk Space:" "$disk_usage"
    printf "%-25s %-25s\n" "Hostname:" "$hostname"
    printf "%-25s %-25s\n" "IP Address:" "$ip_address"
    printf "%-25s %-25s\n" "OS Name:" "$os_name"
    printf "%-25s %-25s\n" "OS Version:" "$os_version"
    printf "%-25s %-25s\n" "CPU Model:" "$cpu_model"
    printf "%-25s %-25s\n" "CPU Cores:" "$cpu_cores"
    printf "%-25s %-25s\n" "Total Memory:" "$mem_total"
    printf "%-25s %-25s\n" "Used Memory:" "$mem_used"
    printf "%-25s %-25s\n" "Free Memory:" "$mem_free"
    printf "%s\n" "-------------------------------------------"
    
    if [ "$output" == "file" ]; then
        local log_filename=$(date '+%Y-%m')-sys-$(hostname).log
        print_system_info > "$log_filename"
    fi
}

# Überprüfen, ob die Option -f angegeben wurde
if [ "$1" == "-f" ]; then
    print_system_info "file"
else
    print_system_info
fi
