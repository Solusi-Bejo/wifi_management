# Paste these into your README

Each line carries its alt text. Keep it when you move the line.

<!-- hero -->
![Animated illustration. On the left, the headline "Join one exact router, even when ten share its name". On the right, an app log types "await manager.connectNew(router02)", then shows: scan found 3 routers named SSID001, a request for SSID001 at aa:bb:cc:00:00:02 only, joined aa:bb:cc:00:00:02 and the BSSID matches, saved and app traffic bound to this network. A card lands: pinned to SSID001 at :02, phase connected with isVerified true, stored only after the BSSID check passed, and if the link is lost it retries after 2, 4, 8, 16, then 30 seconds. Footnote: illustration of a typical Android setup, on iOS the join is best effort.](docs/hero.gif)

<!-- before-after -->
![Animated illustration, before and after. Before: six cards pile up. Every bus broadcasts SSID001 and the tablet joins whichever is loudest. The display on bus 12 talks to the router in bus 14, parked next to it. The OS says connected and nothing says it is the wrong BSSID. The link drops at a stop and nobody reconnects it. Someone walks over and picks the network in Settings again. After a reboot the device only remembers the name. A wipe turns the label to After: an app log runs "await manager.start()", loads SSID001 at aa:bb:cc:00:00:02, requests that BSSID only, joins and verifies it, and ends on connected, isVerified true. Five outcomes appear: pick the router by BSSID from a scan, Android joins only that BSSID, every join is checked and a mismatch is released, the router is saved after the check and restored by start, and a lost link retries at 2, 4, 8, 16, then 30 seconds.](docs/before-after.gif)

<!-- how-it-works -->
![Animated diagram of four steps, left to right. 1, scan: ScanWifi on Android, one row per BSSID, strongest signal first. 2, join one BSSID: connectNew with the config, Android uses WifiNetworkSpecifier, iOS joins by SSID. 3, highlighted, verify and save: read the BSSID actually joined, on a mismatch release it and report, on a match save the router. 4, stay on it: app traffic bound to the network on Android, a lost link retries from 2 to 30 seconds, start restores it on the next launch. Below, a loop line: link dropped? WifiManagement retries the stored router, one attempt at a time, until it verifies again.](docs/how-it-works.gif)
