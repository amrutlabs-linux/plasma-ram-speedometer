import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQuickControls

KCM.SimpleKCM {
    id: page

    property alias cfg_refreshInterval: refreshIntervalSpinBox.value
    property alias cfg_elevatedStart: elevatedStartSpinBox.value
    property alias cfg_redlineStart: redlineStartSpinBox.value
    property alias cfg_smoothingDuration: smoothingDurationSpinBox.value
    property alias cfg_needleColor: needleColorButton.color
    property alias cfg_elevatedColor: elevatedColorButton.color
    property alias cfg_redlineColor: redlineColorButton.color
    property alias cfg_faceColor: faceColorButton.color
    property alias cfg_textColor: textColorButton.color

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: refreshIntervalSpinBox
            Kirigami.FormData.label: i18n("Refresh interval:")
            from: 200
            to: 10000
            stepSize: 100
            textFromValue: function(value) { return i18n("%1 ms", value) }
            valueFromText: function(text) { return parseInt(text) }
        }

        QQC2.SpinBox {
            id: elevatedStartSpinBox
            Kirigami.FormData.label: i18n("Elevated zone starts at:")
            from: 10
            to: 90
            stepSize: 5
            textFromValue: function(value) { return i18n("%1%", value) }
            valueFromText: function(text) { return parseInt(text) }
        }

        QQC2.SpinBox {
            id: redlineStartSpinBox
            Kirigami.FormData.label: i18n("Redline zone starts at:")
            from: 20
            to: 100
            stepSize: 5
            textFromValue: function(value) { return i18n("%1%", value) }
            valueFromText: function(text) { return parseInt(text) }
        }

        QQC2.SpinBox {
            id: smoothingDurationSpinBox
            Kirigami.FormData.label: i18n("Needle smoothing:")
            from: 0
            to: 3000
            stepSize: 100
            textFromValue: function(value) { return i18n("%1 ms", value) }
            valueFromText: function(text) { return parseInt(text) }
        }

        Kirigami.Separator {
            Kirigami.FormData.label: i18n("Colors")
            Kirigami.FormData.isSection: true
        }

        KQuickControls.ColorButton {
            id: needleColorButton
            Kirigami.FormData.label: i18n("Needle:")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: elevatedColorButton
            Kirigami.FormData.label: i18n("Elevated zone:")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: redlineColorButton
            Kirigami.FormData.label: i18n("Redline zone:")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: faceColorButton
            Kirigami.FormData.label: i18n("Gauge face:")
            showAlphaChannel: false
        }

        KQuickControls.ColorButton {
            id: textColorButton
            Kirigami.FormData.label: i18n("Text & ticks:")
            showAlphaChannel: false
        }
    }
}
