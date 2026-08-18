# Troubleshooting

Real issues encountered running this setup on Ubuntu 24.04 (Noble), and the exact fixes that worked.

---

## RTL-SDR dongle "wedges" on boot or reboot

**Symptom:** dump1090 log shows `No supported RTLSDR devices found` or `No data received from the dongle for a long time, it may have wedged`.

**Quick fix:**
```bash
sudo systemctl stop dump1090-mutability
sudo usbreset <bus:device or vendor:product ID, e.g. 0bda:2838>
sleep 3
sudo systemctl start dump1090-mutability
```
Find your dongle's vendor:product ID with `lsusb | grep -i rtl`.

**Permanent fix:** add a `usbreset` call to the dump1090 init script (`/etc/init.d/dump1090-mutability`) inside the `do_start()` function, right before `start-stop-daemon`:
```bash
/usr/bin/usbreset <vendor:product> 2>/dev/null || true
sleep 2
```

**Also add this to GRUB** to stop USB power management from suspending the dongle:
```bash
sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.autosuspend=-1"
sudo update-grub
```

---

## "Address already in use" on ports 30002 / 30005

**Symptom:** `Error opening the listening port 30002/30005: bind: Address already in use` after a crash or reboot — a leftover "zombie" socket.

**Fix:**
```bash
sudo ss -K sport = :30005
sudo ss -K sport = :30002
```

**Prevent it entirely:** if you don't use the raw output port, disable it in `/etc/default/dump1090-mutability`:
```
RAW_OUTPUT_PORT="0"
```

---

## ADS-B Exchange MLAT fails with `ModuleNotFoundError: No module named 'asyncore'`

**Cause:** Python 3.12 removed the built-in `asyncore`/`asynchat` modules, which `mlat-client` still depends on.

**Fix:**
```bash
sudo <path-to-adsbexchange-venv>/bin/pip install pyasyncore pyasynchat
sudo systemctl restart adsbexchange-mlat
```

---

## General debugging checklist

```bash
# Is the dongle detected at all?
lsusb | grep -i rtl

# Is the decoder running and receiving data?
sudo systemctl status dump1090-mutability
tail -20 /var/log/dump1090-mutability.log

# Are the feeders actually connected to the decoder?
sudo netstat -t | grep 30005

# FlightRadar24 feeder logs
sudo journalctl -u fr24feed -n 20 --no-pager

# PlaneFinder feeder status
sudo systemctl status pfclient
sudo tail -20 /var/log/pfclient/error.log

# ADS-B Exchange feeder status
sudo systemctl status adsbexchange-feed adsbexchange-mlat
```

If nothing shows up on the map at `http://<your-laptop-ip>/dump1090/` after a few minutes, it's almost always one of: antenna not connected, dongle not detected (`lsusb`), or the service isn't running — check those three first.
