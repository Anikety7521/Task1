# System Monitoring Dashboard Script

This script provides a terminal-based dashboard to monitor various system metrics including disk usage, CPU usage, memory usage, network activity, process status, and essential services.

## Features

- **Disk Usage**: Shows the disk usage percentage and highlights partitions using more than 80% of space.
- **System Load and CPU Usage**: Displays system load averages and CPU usage percentage.
- **Top 10 Most Used Applications**: Lists the top 10 applications consuming the most CPU and memory.
- **Network Monitoring**: Provides metrics on concurrent connections, packet drops, and network traffic (in and out).
- **Memory Usage**: Displays total, used, and free memory, along with swap memory statistics.
- **Process Monitoring**: Shows the number of active processes and the top 5 processes by CPU and memory usage.
- **Essential Active Services**: Monitors the status of essential services like SSH, Docker, Nginx, and Iptables.

## Usage

### Complete Dashboard

To display the complete dashboard with all metrics, run the script without any arguments:

```bash
./monitoring.sh
The dashboard will refresh every 2 seconds.

Custom Dashboard
To display a specific section of the dashboard, use one of the following arguments:

CPU and Application Info:
./monitoring.shh -cpu


Displays CPU usage and the top 10 most used applications.

Memory and Process Info:
./monitoring.shh -memory

Shows memory usage and the top 5 processes by CPU and memory usage.

Network Info:
./monitoring.shh -network

Provides network metrics including concurrent connections, packet drops, and network traffic.

Disk Usage Info:
./monitoring.shh -disk

Displays disk usage information.

Service Status Info:
./monitoring.shh -services

Shows the status of essential services.

Requirements
The script assumes a Linux environment with standard tools available (df, awk, ps, netstat, ip, free, grep, bc, etc.).
tput is used for color formatting; ensure it's installed on your system.
Notes
Ensure you have the necessary permissions to execute the script and access system metrics.
The script may need adjustments based on your specific system configuration or requirements.
