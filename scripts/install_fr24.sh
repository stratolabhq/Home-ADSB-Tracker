#!/usr/bin/env bash
# Install the FlightRadar24 feeder (fr24feed)
# Assumes dump1090 is already running and outputting Beast data on port 30005.
#
# Sign up / claim your receiver first at: https://www.flightradar24.com/share-your-data
# The installer will ask for your location and will generate a "sharing key" (radar code)
# for you at the end — keep that private, don't post it publicly.

set -euo pipefail

wget https://repo-feed.flightradar24.com/install_fr24_rpi.sh
sudo bash install_fr24_rpi.sh

echo ""
echo "Done. fr24feed should now be running and pointed at 127.0.0.1:30005."
echo "Check status with: sudo systemctl status fr24feed"
echo "View your stats at: https://www.flightradar24.com/account/feed-stats"
