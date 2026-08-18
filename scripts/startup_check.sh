#!/usr/bin/env bash
# Quick health check — run this after any reboot to confirm the whole
# tracker stack (dongle, decoder, and all feeders) came back up correctly.

echo "== 1. RTL-SDR dongle detected? =="
lsusb | grep -i rtl || echo "  ❌ No RTL-SDR device found!"

echo ""
echo "== 2. dump1090 decoder status =="
sudo systemctl status dump1090-mutability --no-pager | head -5
echo "  Last few log lines:"
tail -5 /var/log/dump1090-mutability.log 2>/dev/null

echo ""
echo "== 3. Feeder connections on port 30005 =="
sudo netstat -t | grep 30005 || echo "  ⚠️  No feeders currently connected to port 30005"

echo ""
echo "== 4. FlightRadar24 (fr24feed) =="
sudo journalctl -u fr24feed -n 5 --no-pager 2>/dev/null || echo "  ⚠️  fr24feed not installed/running"

echo ""
echo "== 5. PlaneFinder (pfclient) =="
sudo systemctl status pfclient --no-pager 2>/dev/null | grep -E "Active|●" || echo "  ⚠️  pfclient not found/running"

echo ""
echo "== 6. ADS-B Exchange =="
sudo systemctl status adsbexchange-feed adsbexchange-mlat --no-pager 2>/dev/null | grep -E "Active|●" || echo "  ⚠️  ADS-B Exchange services not found"

echo ""
echo "== Done. Open http://<your-laptop-ip>/dump1090/ to see the live map. =="
