import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    implicitWidth: 300
    implicitHeight: 300

    Layout.minimumWidth: 120
    Layout.minimumHeight: 120

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Sweep: starts at 135 deg (lower-left), sweeps 270 deg clockwise,
    // open gap at the bottom like a classic instrument cluster.
    readonly property real startAngle: 135
    readonly property real sweepAngle: 270

    // Smoothed value driving the needle; updated from ram.percent.
    property real needlePercent: 0

    Behavior on needlePercent {
        NumberAnimation {
            duration: Plasmoid.configuration.smoothingDuration
            easing.type: Easing.OutCubic
        }
    }

    RamDataSource {
        id: ram
        interval: Plasmoid.configuration.refreshInterval

        onPercentChanged: {
            if (!isNaN(percent)) {
                root.needlePercent = Math.max(0, Math.min(100, percent));
            }
        }
    }

    Item {
        id: gauge
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width

        readonly property real d: width
        readonly property real needleAngle: root.startAngle + root.needlePercent * root.sweepAngle / 100

        // ---- Instrument face, bezel, ticks, zone arcs, glass ----
        Canvas {
            id: face
            anchors.fill: parent

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            Connections {
                target: Plasmoid.configuration
                function onElevatedStartChanged() { face.requestPaint(); }
                function onRedlineStartChanged() { face.requestPaint(); }
                function onNeedleColorChanged() { face.requestPaint(); }
                function onElevatedColorChanged() { face.requestPaint(); }
                function onRedlineColorChanged() { face.requestPaint(); }
                function onFaceColorChanged() { face.requestPaint(); }
                function onFaceOpacityChanged() { face.requestPaint(); }
                function onTextColorChanged() { face.requestPaint(); }
            }

            function deg(d) { return d * Math.PI / 180; }

            // Coerce a config color string into a color and apply an alpha
            function tint(color, alpha) {
                var c = Qt.darker(color, 1.0);
                return Qt.hsla(c.hslHue, c.hslSaturation, c.hslLightness, alpha);
            }

            function zoneArc(ctx, fromP, toP, radius, lineWidth, color) {
                ctx.beginPath();
                ctx.arc(0, 0, radius,
                        deg(root.startAngle + fromP * root.sweepAngle / 100),
                        deg(root.startAngle + toP * root.sweepAngle / 100),
                        false);
                ctx.lineWidth = lineWidth;
                ctx.strokeStyle = color;
                ctx.lineCap = "butt";
                ctx.stroke();
            }

            onPaint: {
                var ctx = getContext("2d");
                var w = width, h = height;
                var d = Math.min(w, h);
                ctx.reset();
                ctx.translate(w / 2, h / 2);

                var R = d / 2 - 1;
                var bezelW = Math.max(6, d * 0.045);
                var faceR = R - bezelW;
                var tickOuter = faceR * 0.94;

                var faceAlpha = (Plasmoid.configuration.faceOpacity !== undefined ? Plasmoid.configuration.faceOpacity : 100) / 100.0;

                if (faceAlpha > 0) {
                    ctx.save();
                    ctx.globalAlpha = faceAlpha;

                    // Metallic outer bezel ring
                    var bezel = ctx.createRadialGradient(0, 0, faceR * 0.8, 0, 0, R);
                    bezel.addColorStop(0.0, "#2b2d33");
                    bezel.addColorStop(0.55, "#585c64");
                    bezel.addColorStop(0.78, "#767b84");
                    bezel.addColorStop(0.92, "#33363c");
                    bezel.addColorStop(1.0, "#16171a");
                    ctx.beginPath();
                    ctx.arc(0, 0, R, 0, Math.PI * 2, false);
                    ctx.fillStyle = bezel;
                    ctx.fill();

                    // Dark radial-gradient instrument face, derived from faceColor
                    var faceColor = Plasmoid.configuration.faceColor;
                    var faceGrad = ctx.createRadialGradient(0, -faceR * 0.3, faceR * 0.1, 0, 0, faceR);
                    faceGrad.addColorStop(0.0, Qt.lighter(faceColor, 2.2));
                    faceGrad.addColorStop(0.55, Qt.lighter(faceColor, 1.3));
                    faceGrad.addColorStop(1.0, Qt.darker(faceColor, 1.5));
                    ctx.beginPath();
                    ctx.arc(0, 0, faceR, 0, Math.PI * 2, false);
                    ctx.fillStyle = faceGrad;
                    ctx.fill();

                    // Inner rim shadow to seat the face into the bezel
                    ctx.beginPath();
                    ctx.arc(0, 0, faceR, 0, Math.PI * 2, false);
                    ctx.lineWidth = Math.max(1, d * 0.006);
                    ctx.strokeStyle = "rgba(0, 0, 0, 0.55)";
                    ctx.stroke();

                    // Subtle glass/reflection highlight near the top
                    ctx.save();
                    ctx.beginPath();
                    ctx.arc(0, 0, faceR, 0, Math.PI * 2, false);
                    ctx.clip();
                    ctx.rotate(deg(-18));
                    var glass = ctx.createLinearGradient(0, -faceR, 0, -faceR * 0.1);
                    glass.addColorStop(0.0, "rgba(255, 255, 255, 0.13)");
                    glass.addColorStop(0.7, "rgba(255, 255, 255, 0.03)");
                    glass.addColorStop(1.0, "rgba(255, 255, 255, 0.0)");
                    ctx.beginPath();
                    ctx.ellipse(0, -faceR * 0.52, faceR * 0.82, faceR * 0.42, 0, 0, Math.PI * 2, false);
                    ctx.fillStyle = glass;
                    ctx.fill();
                    ctx.restore();
                    ctx.restore();
                }

                // Zone color arcs (thin, near the tick ring)
                var elevated = Math.max(0, Math.min(100, Plasmoid.configuration.elevatedStart));
                var redline = Math.max(elevated, Math.min(100, Plasmoid.configuration.redlineStart));
                var zoneR = faceR * 0.865;
                var zoneW = Math.max(2, d * 0.014);
                var textColor = Plasmoid.configuration.textColor;
                var elevatedColor = Plasmoid.configuration.elevatedColor;
                var redlineColor = Plasmoid.configuration.redlineColor;
                zoneArc(ctx, 0, elevated, zoneR, zoneW, tint(Qt.darker(textColor, 1.8), 0.28));
                zoneArc(ctx, elevated, redline, zoneR, zoneW, tint(elevatedColor, 0.75));
                zoneArc(ctx, redline, 100, zoneR, zoneW, tint(redlineColor, 0.85));

                // Tick marks: minor every 2%, major every 10%
                var majorLen = Math.max(6, d * 0.05);
                var minorLen = Math.max(3, d * 0.024);
                for (var p = 0; p <= 100; p += 2) {
                    var major = (p % 10 === 0);
                    var a = deg(root.startAngle + p * root.sweepAngle / 100);
                    var len = major ? majorLen : minorLen;
                    var r0 = tickOuter - len;
                    ctx.beginPath();
                    ctx.moveTo(Math.cos(a) * r0, Math.sin(a) * r0);
                    ctx.lineTo(Math.cos(a) * tickOuter, Math.sin(a) * tickOuter);
                    ctx.lineWidth = major ? Math.max(1.5, d * 0.009) : Math.max(0.75, d * 0.004);
                    ctx.strokeStyle = major ? (p >= redline ? tint(redlineColor, 0.9) : tint(textColor, 0.85))
                                            : tint(Qt.darker(textColor, 1.3), 0.4);
                    ctx.lineCap = "round";
                    ctx.stroke();
                }

                // Numeric labels 0..100
                var labelR = tickOuter - majorLen - Math.max(8, d * 0.05);
                ctx.fillStyle = tint(textColor, 0.85);
                ctx.font = "600 " + Math.max(8, Math.round(d * 0.048)) + "px sans-serif";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                for (var n = 0; n <= 100; n += 10) {
                    var la = deg(root.startAngle + n * root.sweepAngle / 100);
                    ctx.fillStyle = n >= redline ? tint(redlineColor, 0.95) : tint(textColor, 0.85);
                    ctx.fillText(n.toString(), Math.cos(la) * labelR, Math.sin(la) * labelR);
                }
            }
        }

        // ---- Needle (rotated item: shadow duplicate + sharp needle) ----
        Item {
            id: needleItem
            anchors.fill: parent

            transform: Rotation {
                origin.x: needleItem.width / 2
                origin.y: needleItem.height / 2
                angle: gauge.needleAngle
            }

            // Cheap drop shadow: semi-transparent duplicate, offset
            Rectangle {
                x: parent.width / 2 + 1.5
                y: parent.height / 2 - needleW / 2 + 1.5
                width: needleLen
                height: needleW
                radius: needleW / 2
                color: "black"
                opacity: 0.35

                readonly property real needleLen: gauge.d * 0.5 * 0.9 - gauge.d * 0.045
                readonly property real needleW: Math.max(2, gauge.d * 0.011)
            }

            // Needle body pointing right (east); rotation maps it to the dial
            Rectangle {
                id: needle
                x: parent.width / 2
                y: parent.height / 2 - height / 2
                width: gauge.d * 0.5 * 0.9 - gauge.d * 0.045
                height: Math.max(2, gauge.d * 0.011)
                radius: height / 2
                // Accent-colored needle
                color: Plasmoid.configuration.needleColor

                // Bright tip
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.28
                    height: parent.height
                    radius: parent.radius
                    color: Qt.lighter(Plasmoid.configuration.needleColor, 1.4)
                }
            }

            // Counterweight tail
            Rectangle {
                x: parent.width / 2 - width
                y: parent.height / 2 - height / 2
                width: gauge.d * 0.09
                height: Math.max(2.5, gauge.d * 0.013)
                radius: height / 2
                color: Qt.darker(Plasmoid.configuration.needleColor, 1.7)
            }
        }

        // ---- Center hub / cap ----
        Rectangle {
            anchors.centerIn: parent
            width: Math.max(10, gauge.d * 0.1)
            height: width
            radius: width / 2
            color: "#15161a"
            border.color: "#484c55"
            border.width: Math.max(1, gauge.d * 0.006)

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.34
                height: width
                radius: width / 2
                color: Plasmoid.configuration.needleColor
            }
        }

        // ---- Digital readout, lower-center of the face ----
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: gauge.d * 0.13
            spacing: Math.max(0, gauge.d * 0.006)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "R A M"
                color: Qt.darker(Plasmoid.configuration.textColor, 1.8)
                font.pixelSize: Math.max(7, gauge.d * 0.042)
                font.letterSpacing: Math.max(1, gauge.d * 0.012)
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: isNaN(ram.percent) ? "--%" : Math.round(ram.percent) + "%"
                color: Plasmoid.configuration.textColor
                font.pixelSize: Math.max(12, gauge.d * 0.115)
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: gauge.d >= 200
                text: (isNaN(ram.percent) || ram.usedGB === "" || ram.totalGB === "")
                      ? "-- / -- GB"
                      : ram.usedGB + " / " + ram.totalGB + " GB"
                color: Qt.darker(Plasmoid.configuration.textColor, 1.6)
                font.pixelSize: Math.max(8, gauge.d * 0.045)
            }
        }
    }
}
