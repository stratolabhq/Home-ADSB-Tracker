#!/usr/bin/env bash
# Install the PlaneFinder client (pfclient).
#
# Sign up at https://planefinder.net/ to get a sharecode first — PlaneFinder
# doesn't publish an apt repo, so grab the current .deb directly. Check
# http://client.planefinder.net/ for the latest filename/version before running
# this if it's been a while since this script was written.

set -euo pipefail

PFCLIENT_DEB_URL="http://client.planefinder.net/pfclient_5.0.162_amd64.deb"

wget -O /tmp/pfclient.deb "$PFCLIENT_DEB_URL"
sudo dpkg -i /tmp/pfclient.deb

sudo systemctl enable pfclient
sudo systemctl start pfclient

echo ""
echo "Done. Check status with: sudo systemctl status pfclient"
echo "Local status page: http://<your-laptop-ip>:30053/"
echo "If the installer didn't prompt for one, set your sharecode and lat/lon in /etc/pfclient-config.json."
