#!/bin/bash

# Define colors
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
RED='\033[31m'

# Function to display disk usage
disk_usage() {
    echo -e "${CYAN}${BOLD}Disk Usage:${RESET}"
    printf "%-25s %-10s %-10s\n" "Filesystem" "Usage (%)" "Mounted On"
    printf "%s\n" "--------------------------------------------"
    df -h | awk '{print $1 " " $5 " " $6}' | sed -n '1!p' | while read -r line; do
        partition=$(echo $line | awk '{print $1}')
        usage=$(echo $line | awk '{print $2}' | sed 's/%//')
        mount_point=$(echo $line | awk '{print $3}')
        if [ "$usage" -gt 80 ]; then
            printf "%-25s %-10s %-10s\n" "$partition" "${RED}${usage}%${RESET}" "$mount_point"
        else
            printf "%-25s %-10s %-10s\n" "$partition" "${usage}%" "$mount_point"
        fi
    done
    echo
}

# Function to display system load and CPU usage
system_load() {
    echo -e "${CYAN}${BOLD}System Load and CPU Usage:${RESET}"
    printf "%-20s %-10s\n" "Metric" "Value"
    printf "%s\n" "-------------------- ----------"
    load_avg=$(uptime | awk -F'[a-z]:' '{ print $2 }' | sed 's/,//g')
    printf "%-20s %-10s\n" "Load Average" "$load_avg"
    cpu_idle=$(grep 'cpu ' /proc/stat | awk '{print $5}')
    cpu_total=$(grep 'cpu ' /proc/stat | awk '{print $2+$3+$4+$5}')
    cpu_usage=$(echo "scale=2; 100 - ($cpu_idle / $cpu_total * 100)" | bc)
    printf "%-20s %-10s\n" "CPU Usage (%)" "${cpu_usage}%"
    echo
}

# Function to display top 10 most used applications in table format
top_apps() {
    echo -e "${CYAN}${BOLD}Top 10 Most Used Applications:${RESET}"
    printf "%-10s %-20s %-10s %-10s\n" "PID" "COMMAND" "CPU (%)" "MEM (%)"
    printf "%s\n" "--------------------------------------------"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11 | awk 'NR>1 {printf "%-10s %-20s %-10s %-10s\n", $1, $2, $3, $4}'
    echo
}

# Function to display network monitoring
network_monitoring() {
    echo -e "${CYAN}${BOLD}Network Monitoring:${RESET}"
    printf "%-25s %-10s\n" "Metric" "Value"
    printf "%s\n" "------------------------- ----------"
    concurrent_connections=$(netstat -an | grep ':80\|:443' | wc -l)
    printf "%-25s %-10s\n" "Concurrent Connections" "$concurrent_connections"
    iface=$(ip -o link show | awk -F': ' '{print $2}' | head -n 1)
    packet_drops=$(grep "$iface:" /proc/net/dev | awk '{print $2}')
    printf "%-25s %-10s\n" "Packet Drops (Received)" "$packet_drops"
    if [ -z "$iface" ]; then
        echo -e "Network Traffic: No network interface found"
        return
    fi
    rx_before=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx_before=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
    sleep 1
    rx_after=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
    tx_after=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
    if [ "$rx_before" -eq 0 ] || [ "$tx_before" -eq 0 ]; then
        echo -e "Network Traffic: Could not read network interface statistics"
        return
    fi
    rx_mb=$(echo "scale=2; ($rx_after - $rx_before) / 1024 / 1024" | bc)
    tx_mb=$(echo "scale=2; ($tx_after - $tx_before) / 1024 / 1024" | bc)
    printf "%-25s %-10s\n" "Network In (MB)" "${rx_mb}"
    printf "%-25s %-10s\n" "Network Out (MB)" "${tx_mb}"
    echo
}

# Function to display memory usage
memory_usage() {
    echo -e "${CYAN}${BOLD}Memory Usage:${RESET}"
    printf "%-20s %-10s\n" "Metric" "Value"
    printf "%s\n" "-------------------- ----------"
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_free=$(free -h | awk '/^Mem:/ {print $4}')
    swap_total=$(free -h | awk '/^Swap:/ {print $2}')
    swap_used=$(free -h | awk '/^Swap:/ {print $3}')
    swap_free=$(free -h | awk '/^Swap:/ {print $4}')
    printf "%-20s %-10s\n" "Total Memory" "$mem_total"
    printf "%-20s %-10s\n" "Used Memory" "$mem_used"
    printf "%-20s %-10s\n" "Free Memory" "$mem_free"
    printf "%-20s %-10s\n" "Total Swap" "$swap_total"
    printf "%-20s %-10s\n" "Used Swap" "$swap_used"
    printf "%-20s %-10s\n" "Free Swap" "$swap_free"
    echo
}

# Function to display process monitoring
process_monitoring() {
    echo -e "${CYAN}${BOLD}Process Monitoring:${RESET}"
    printf "%-10s %-20s %-10s %-10s\n" "PID" "COMMAND" "MEM (%)" "CPU (%)"
    printf "%s\n" "--------------------------------------------"
    echo -e "Active Processes: $(ps aux | wc -l)"
    echo -e "Top 5 Processes by CPU Usage:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 | awk 'NR>1 {printf "%-10s %-20s %-10s %-10s\n", $1, $2, $4, $3}'
    echo -e "Top 5 Processes by Memory Usage:"
    ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 6 | awk 'NR>1 {printf "%-10s %-20s %-10s %-10s\n", $1, $2, $3, $4}'
    echo
}

# Function to display essential services
service_status() {
    echo -e "${CYAN}${BOLD}Essential Active Services:${RESET}"
    printf "%-30s %-10s\n" "Service" "Status"
    printf "%s\n" "------------------------------ ----------"
    for service in sshd docker nginx iptables; do
        if systemctl is-active --quiet $service; then
            printf "%-30s %-10s\n" "$service" "$(tput setaf 2)Running$(tput sgr0)"
        else
            printf "%-30s %-10s\n" "$service" "$(tput setaf 1)Not Running$(tput sgr0)"
        fi
    done
    echo
}

# Function to display the complete dashboard
complete_dashboard() {
    clear
    top_apps
    disk_usage
    system_load
    memory_usage
    process_monitoring
    network_monitoring
    service_status
}

# Function to display custom dashboard based on argument
custom_dashboard() {
    clear
    case $1 in
        -cpu)
            top_apps
            system_load
            ;;
        -memory)
            memory_usage
            process_monitoring
            ;;
        -network)
            network_monitoring
            ;;
        -disk)
            disk_usage
            ;;
        -services)
            service_status
            ;;
        *)
            echo -e "${CYAN}${BOLD}Usage:${RESET}"
            echo -e "  -cpu       Show CPU and application info"
            echo -e "  -memory    Show memory and process info"
            echo -e "  -network   Show network info"
            echo -e "  -disk      Show disk usage info"
            echo -e "  -services  Show service status info"
            ;;
    esac
}

# Main execution
if [ "$#" -eq 0 ]; then
    while true; do
        complete_dashboard
        sleep 2
    done
else
    while true; do
        custom_dashboard "$1"
        sleep 2
    done
fi

