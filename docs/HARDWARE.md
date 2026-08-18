# Hardware Reference

## SDR dongle
- **RTL-SDR Blog V3** (RTL2832U + R820T tuner)
- Max gain: 49.6 dB (set `GAIN="max"` in dump1090 config to let it auto-select)
- No external power or hub needed — antenna connects directly to the dongle

## Antenna
- 1090MHz ADS-B fiberglass antenna, 6dBi gain, omnidirectional
- N-type female connector, comes with a 10m N-male → SMA-male coax cable
- **Placement matters more than anything else in this build.** Mount it as high as possible with a clear view of open sky — near a window is fine to start, outside/on a roof is better. Metal roofing, nearby buildings, and hills will all shrink your range.

## Compute
- Any laptop or PC capable of running Ubuntu 24.04 — this project runs comfortably on hardware from the 2012–2014 era (e.g. a ThinkPad X230-class machine). CPU/RAM usage from `dump1090` + three feeder clients is minimal.
- Runs headless — no monitor needed after initial setup (SSH in, or plug in a monitor only for the OS install).

## Key ports (all local, on your machine)
| Port | Purpose |
|---|---|
| `80` | Web map — served by lighttpd at `/dump1090/` (dump1090's built-in live map) |
| `30005` | Beast-format output — this is what all three feeders connect to |
| `30001` | Raw input (rarely needed) |
| `30003` | SBS/BaseStation format output |
| `8754` | FlightRadar24 (fr24feed) local status page |
| `30053` | PlaneFinder (pfclient) local status page |

## dump1090 config essentials (`/etc/default/dump1090-mutability`)
```
GAIN="max"
RAW_OUTPUT_PORT="0"    # disable to avoid a zombie-socket issue on port 30002
```
