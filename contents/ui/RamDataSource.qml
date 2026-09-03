// SPDX-License-Identifier: GPL-2.0-or-later
//
// RamDataSource.qml — live system RAM statistics via the Plasma 6
// ksysguard sensors API. No root required.

import QtQuick
import org.kde.ksysguard.sensors as Sensors

Item {
    id: ramDataSource

    // Polling interval in milliseconds (the sensors re-fetch at this rate).
    // Settable from the parent, e.g. `interval: Plasmoid.configuration.refreshInterval`.
    property int interval: 1000

    // Internal raw byte values (NaN until the sensors deliver data).
    property real _usedBytes: NaN
    property real _totalBytes: NaN

    // Public read-only API.
    readonly property real percent: {
        if (!isFinite(_usedBytes) || !isFinite(_totalBytes) || _totalBytes <= 0) {
            return NaN;
        }
        return Math.max(0, Math.min(100, (_usedBytes / _totalBytes) * 100));
    }
    readonly property string usedGB: isFinite(_usedBytes)
        ? (_usedBytes / 1073741824).toFixed(1) : ""
    readonly property string totalGB: isFinite(_totalBytes)
        ? (_totalBytes / 1073741824).toFixed(1) : ""

    Sensors.Sensor {
        sensorId: "memory/physical/used"
        updateRateLimit: ramDataSource.interval
        onValueChanged: {
            // The sensor fires with `undefined` before it resolves; ignore those.
            if (value !== undefined && isFinite(value)) {
                ramDataSource._usedBytes = value;
            }
        }
    }

    Sensors.Sensor {
        sensorId: "memory/physical/total"
        updateRateLimit: ramDataSource.interval
        onValueChanged: {
            if (value !== undefined && isFinite(value)) {
                ramDataSource._totalBytes = value;
            }
        }
    }
}
