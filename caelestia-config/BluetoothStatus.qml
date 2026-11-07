///etc/xdg/quickshell/caelestia/modules/bar/components/status/BluetoothStatus.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

Item {
    id: root

    required property color colour

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    Behavior on implicitHeight {
        Anim {
            type: Anim.DefaultEffects
        }
    }

    ColumnLayout {
        id: layout

        spacing: Tokens.spacing.medium / 2

        // Bluetooth icon
        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: {
                if (!Bluetooth.defaultAdapter?.enabled) // qmllint disable unresolved-type
                    return "bluetooth_disabled";
                if (Bluetooth.devices.values.some(d => d.connected)) // qmllint disable unresolved-type
                    return "bluetooth_connected";
                return "bluetooth";
            }
            color: root.colour
        }

        // Connected bluetooth devices
        Repeater {
            model: ScriptModel {
                values: Bluetooth.devices.values.filter(d => d.state !== BluetoothDeviceState.Disconnected) // qmllint disable unresolved-type
            }

            Item {
                id: device

                required property BluetoothDevice modelData
                readonly property bool showBattery: modelData?.state === BluetoothDeviceState.Connected && (modelData?.batteryAvailable ?? false) // qmllint disable unresolved-type

                Layout.alignment: Qt.AlignHCenter
                implicitWidth: showBattery ? ring.implicitWidth : deviceIcon.implicitWidth
                implicitHeight: showBattery ? ring.implicitHeight : deviceIcon.implicitHeight

                // Battery ring (BlueZ org.bluez.Battery1 via Quickshell.Bluetooth)
                CircularProgress {
                    id: ring

                    anchors.centerIn: parent
                    visible: device.showBattery
                    implicitSize: 26
                    strokeWidth: 2
                    spacing: 0
                    value: device.showBattery ? device.modelData.battery : 0
                    fgColour: device.showBattery && device.modelData.battery < 0.2 ? Colours.palette.m3error : root.colour

                    Behavior on clampedVal {
                        Anim {}
                    }
                }

                MaterialIcon {
                    id: deviceIcon

                    anchors.centerIn: parent
                    animate: true
                    text: Icons.getBluetoothIcon(device.modelData?.icon)
                    color: root.colour
                    fill: 1

                    SequentialAnimation on opacity {
                        running: device.modelData?.state !== BluetoothDeviceState.Connected // qmllint disable unresolved-type
                        alwaysRunToEnd: true
                        loops: Animation.Infinite

                        Anim {
                            from: 1
                            to: 0
                            duration: Tokens.anim.durations.large
                            easing: Tokens.anim.standardAccel
                        }
                        Anim {
                            from: 0
                            to: 1
                            duration: Tokens.anim.durations.large
                            easing: Tokens.anim.standardDecel
                        }
                    }
                }
            }
        }
    }
}
