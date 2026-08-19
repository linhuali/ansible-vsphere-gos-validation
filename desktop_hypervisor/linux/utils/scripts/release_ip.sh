# Copyright 2026 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
#!/bin/sh
IFACE=$(ip -4 route show default 2>/dev/null | awk '{print $5}' | head -n1)
if [ -z "$IFACE" ]; then
  IFACE=$(ip -4 addr show 2>/dev/null | grep "inet " | awk '{print $NF}' | grep -v "^lo$" | head -n1)
fi

if [ -n "$IFACE" ]; then
  echo "[INFO] Found target network interface: $IFACE"
  if command -v nmcli &>/dev/null; then
    echo "[INFO] Using nmcli to disconnect $IFACE..."
    nmcli dev disconnect "$IFACE" || true
  elif command -v dhclient &>/dev/null; then
    echo "[INFO] Using dhclient to release $IFACE..."
    dhclient -r "$IFACE" || /sbin/dhclient -r "$IFACE" || true
  elif command -v networkctl &>/dev/null; then
    echo "[INFO] Using networkctl to reconfigure $IFACE..."
    networkctl reconfigure "$IFACE" || true
  elif command -v wicked &>/dev/null; then
    echo "[INFO] Using wicked to down $IFACE..."
    wicked ifdown "$IFACE" || true
  else
    echo "[WARNING] No supported network management tool found for $IFACE."
  fi
else
  echo "[WARNING] No active network interface or IP address found in Guest VM."
fi
exit 0