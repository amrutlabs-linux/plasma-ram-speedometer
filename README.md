# RAM Speedometer

An analog car-speedometer style KDE Plasma 6 widget that shows live RAM usage.

The widget reads memory usage from the Plasma 6 `org.kde.ksysguard.sensors`
API (sensors `memory/physical/used` and `memory/physical/total`, served by
the `ksystemstats` daemon) — no root access or extra services required on a
standard Plasma 6 install.

## Prerequisites

- KDE Plasma 6
- `kpackagetool6` (ships with Plasma 6 / `kpackage` tooling)

## Install

```bash
./install.sh
```

The script installs the package, or updates it if it is already installed.

Manual equivalent:

```bash
kpackagetool6 --type Plasma/Applet -i ./ram-speedometer   # first install
kpackagetool6 --type Plasma/Applet -u ./ram-speedometer   # upgrade
```

After installing, restart Plasma Shell so the widget shows up:

```bash
systemctl --user restart plasma-plasmashell.service
# or: plasmashell --replace &
```

## Usage

Right-click the desktop or a panel → **Add Widgets…** → search for
**RAM Speedometer** → drag it onto the desktop or panel.

Right-click the widget → **Configure RAM Speedometer…** to adjust:

| Option | Default | Description |
|---|---|---|
| `refreshInterval` | 1000 ms | How often RAM usage is polled (200–10000 ms). |
| `elevatedStart` | 60 % | Usage percentage where the elevated (amber) zone begins. |
| `redlineStart` | 80 % | Usage percentage where the redline (red) zone begins. |
| `smoothingDuration` | 800 ms | Needle animation smoothing duration (0–3000 ms; 0 disables). |
| `needleColor` | `#e8443a` | Color of the gauge needle. |
| `elevatedColor` | `#d8a03c` | Color of the elevated (amber) zone arc. |
| `redlineColor` | `#d8352c` | Color of the redline (red) zone arc. |
| `faceColor` | `#111318` | Color of the gauge face. |
| `textColor` | `#e8eaed` | Color of text and tick marks. |
