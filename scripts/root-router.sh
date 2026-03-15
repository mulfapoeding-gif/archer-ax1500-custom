#!/bin/bash
# One-click root script for Archer AX1500

set -e

ROUTER_IP="${1:-192.168.0.1}"
ADMIN_PASS="${2:-admin}"

echo "========================================"
echo "  Archer AX1500 One-Click Root"
echo "========================================"
echo ""
echo "Router: $ROUTER_IP"
echo "Password: $ADMIN_PASS"
echo ""
read -p "Continue? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Cancelled"
    exit 1
fi

# Run exploit
cd "$(dirname "$0")/../exploits"
./run-exploit.sh "$ROUTER_IP" "$ADMIN_PASS"
