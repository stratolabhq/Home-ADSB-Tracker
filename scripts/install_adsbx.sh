#!/usr/bin/env bash
# Install the ADS-B Exchange feeder + MLAT client + stats page.
# The installers will prompt for your location and generate a feeder UUID —
# keep that UUID private, it's tied to your stats page.

set -euo pipefail

# Feeder
wget -O /tmp/axfeed.sh https://www.adsbexchange.com/feed.sh
sudo bash /tmp/axfeed.sh

# Local stats page (optional but handy)
curl -L -o /tmp/axstats.sh https://adsbexchange.com/stats.sh
sudo bash /tmp/axstats.sh

echo ""
echo "Done. Check status with:"
echo "  sudo systemctl status adsbexchange-feed adsbexchange-mlat"
echo ""
echo "NOTE: If MLAT fails with 'ModuleNotFoundError: No module named asyncore'"
echo "(common on Python 3.12 / Ubuntu 24.04), run:"
echo "  sudo <adsbexchange-venv-path>/bin/pip install pyasyncore pyasynchat"
echo "  sudo systemctl restart adsbexchange-mlat"
echo ""
echo "View your stats at: https://www.adsbexchange.com/api/feeders/?feed=<your-uuid>"
