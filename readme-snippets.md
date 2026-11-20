# Paste these into your README

Each line carries its alt text. Keep it when you move the line.

<!-- before-after -->
![Animated illustration, before and after. Before: six cards pile up. Several routers broadcast SSID001 and the device joins whichever is loudest. The device ends up on a nearby router, not the one it belongs to. The OS says connected and nothing says it is the wrong BSSID. The link drops and nothing reconnects it. Someone has to pick the network in Settings again. After a reboot the device only remembers the name. A wipe turns the label to After: an app log runs "await manager.start()", loads SSID001 at aa:bb:cc:00:00:02, requests that BSSID only, joins and verifies it, and ends on connected, isVerified true. Five outcomes appear: pick the router by BSSID from a scan, Android joins only that BSSID, every join is checked and a mismatch is released, the router is saved after the check and restored by start, and a lost link retries at 2, 4, 8, 16, then 30 seconds.](docs/before-after.gif)
