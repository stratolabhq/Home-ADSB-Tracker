#!/usr/bin/env bash
# Verify the live machine's state against what README.md / docs/HARDWARE.md /
# docs/TROUBLESHOOTING.md claim. Run this on the tracker box itself (or over SSH).
#
# Deliberately does NOT print feeder UUIDs/keys, lat/long, or full config file
# dumps — only pass/fail against the specific values the docs assert, since
# output from this script may end up pasted somewhere public.

PASS=0
WARN=0
FAIL=0

pass() { printf '  \xe2\x9c\x85 %s\n' "$1"; PASS=$((PASS+1)); }
warn() { printf '  \xe2\x9a\xa0\xef\xb8\x8f  %s\n' "$1"; WARN=$((WARN+1)); }
fail() { printf '  \xe2\x9d\x8c %s\n' "$1"; FAIL=$((FAIL+1)); }

echo "== 1. RTL-SDR dongle detected =="
if lsusb | grep -qi rtl; then
  pass "RTL-SDR device present: $(lsusb | grep -i rtl | head -1 | sed -E 's/^Bus [0-9]+ Device [0-9]+: //')"
else
  fail "No RTL-SDR device found on the USB bus (docs assume one is always connected)"
fi

echo
echo "== 2. dump1090-mutability decoder =="
if systemctl is-active --quiet dump1090-mutability; then
  pass "dump1090-mutability service is active"
else
  fail "dump1090-mutability service is NOT active (docs assume it's always running)"
fi

CONF=/etc/default/dump1090-mutability
if [ -r "$CONF" ]; then
  GAIN=$(grep -E '^GAIN=' "$CONF" | cut -d'"' -f2)
  RAW=$(grep -E '^RAW_OUTPUT_PORT=' "$CONF" | cut -d'"' -f2)
  BIND=$(grep -E '^NET_BIND_ADDRESS=' "$CONF" | cut -d'"' -f2)

  [ "$GAIN" = "max" ] && pass 'GAIN="max" (matches docs)' \
    || warn "GAIN is \"$GAIN\" — docs say GAIN=\"max\""

  [ "$RAW" = "0" ] && pass 'RAW_OUTPUT_PORT="0" (matches docs, avoids the zombie-socket issue)' \
    || warn "RAW_OUTPUT_PORT is \"$RAW\" — docs say it should be \"0\" to avoid the TROUBLESHOOTING.md zombie-socket issue"

  if [ "$BIND" = "127.0.0.1" ] || [ -z "$BIND" ]; then
    pass "NET_BIND_ADDRESS is localhost-only (feeders on this box can still reach 30005)"
  else
    warn "NET_BIND_ADDRESS is \"$BIND\" — dump1090's Beast/SBS ports are reachable from other hosts on the network, docs don't mention this"
  fi
else
  fail "Can't read $CONF (are you running this with sudo?)"
fi

echo
echo "== 3. Web map location (docs claim http://<host>/dump1090/ on port 80) =="
if curl -sfI http://localhost/dump1090/ >/dev/null 2>&1; then
  pass "Web map reachable at http://<host>/dump1090/ on port 80, matches docs"
elif curl -sf -o /dev/null http://localhost:8080/; then
  fail "Web map is on :8080, not port 80 at /dump1090/ as the docs now claim — docs need updating (or this reverted)"
else
  fail "Web map not found on port 80 at /dump1090/ or on :8080 — check lighttpd and the dump1090-mutability lighttpd conf"
fi

echo
echo "== 4. FlightRadar24 (fr24feed) =="
if systemctl is-active --quiet fr24feed; then
  pass "fr24feed service is active"
else
  fail "fr24feed service is NOT active"
fi
if ss -tln 2>/dev/null | grep -q ':8754'; then
  pass "fr24feed status page listening on :8754, matches docs"
else
  warn "Nothing listening on :8754 — fr24feed status page may be unreachable"
fi

echo
echo "== 5. PlaneFinder (pfclient) =="
if systemctl is-active --quiet pfclient; then
  pass "pfclient service is active"
else
  fail "pfclient service is NOT active"
fi
if ss -tln 2>/dev/null | grep -q ':30053'; then
  pass "PlaneFinder local status page listening on :30053, matches docs"
else
  warn "Nothing listening on :30053 — PlaneFinder local status page may be unreachable"
fi

echo
echo "== 6. ADS-B Exchange =="
for svc in adsbexchange-feed adsbexchange-mlat; do
  if systemctl is-active --quiet "$svc"; then
    pass "$svc is active"
  else
    fail "$svc is NOT active"
  fi
done
if command -v adsbexchange-showurl >/dev/null 2>&1; then
  pass "adsbexchange-showurl is available (run it directly to get your stats URL — not printed here, it contains your feeder UUID)"
else
  warn "adsbexchange-showurl not found on PATH"
fi

echo
echo "== 7. Undocumented feeders / services check =="
KNOWN='dump1090|fr24feed|adsbexchange|lighttpd|docker|pfclient|planefinder'
EXTRA=$(systemctl list-units --type=service --state=running --no-legend 2>/dev/null \
  | awk '{print $1}' \
  | grep -Ei 'feed|adsb|planefinder|pfclient|radarbox|opensky|flightaware' \
  | grep -Evi "$KNOWN")
if [ -n "$EXTRA" ]; then
  warn "Services running that look flight-tracking-related but aren't mentioned in the docs:"
  echo "$EXTRA" | sed 's/^/      - /'
else
  pass "No unexpected flight-tracking services found beyond what the docs describe"
fi

echo
echo "======================================"
echo "  $PASS passed, $WARN warnings, $FAIL failed"
echo "======================================"
[ "$FAIL" -eq 0 ]
