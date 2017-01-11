import QtQuick 2.0
import Qak.QtQuick 2.0

import ".."

Item {
    id: menu
    anchors { fill: parent }

    paused: App.paused
    onPausedChanged: App.debug('Menu',paused ? 'paused' : 'continued')

    Image {
        id: background
        x: 0; y: -background.height+menu.height
        width: parent.width
        fillMode: Image.PreserveAspectFit
        source: App.getAsset('intro.png')

        SequentialAnimation {
            running: true
            loops: Animation.Infinite
            paused: running && menu.paused

            NumberAnimation {
                target: background
                property: "y"
                duration: 60000
                easing.type: Easing.InOutQuad
                from: -background.height+menu.height
                to: 0
            }
            NumberAnimation {
                target: background
                property: "y"
                duration: 60000
                easing.type: Easing.InOutQuad
                from: 0
                to: -background.height+menu.height
            }

        }
    }

    Item {
        anchors { fill: parent }

        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 600 }
        }

        Component.onCompleted: {
            opacity = 1
        }

        Rectangle {
            width: parent.width
            height: parent.height * 0.7
            anchors.centerIn: parent
            color: core.colors.black
            opacity: 0.8

            TextButton {
                anchors {
                    left: parent.left
                    top: parent.top
                    leftMargin: 20
                    topMargin: 10
                }
                font.pixelSize: 60
                allUppercase: true
                bounce: true
                text: qsTr("About")
                onClicked: core.modes.set('about')
            }

            TextButton {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    leftMargin: 20
                    bottomMargin: 10
                }
                font.pixelSize: 60
                allUppercase: true
                bounce: true
                text: qsTr("Credits")
                onClicked: core.modes.set('credits')
            }

        }

        Item {
            x: 0; y: 0
            width: parent.halfWidth
            height: parent.height

            Image {
                width: parent.width*0.7
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: App.getAsset('logo.png')
            }
        }

        Item {
            x: parent.halfWidth; y: 0
            width: parent.halfWidth
            height: parent.height

            Column {
                spacing: 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    bounce: true
                    text: qsTr("Start")
                    onClicked: core.modes.set('game')
                }

                /* TODO
                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    text: qsTr("Options")
                    onClicked: core.modes.set('menu')
                }
                */

                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    text: qsTr("Reset")
                    onClicked: confirmReset.state = "shown"
                }

            }
        }
    }

    ConfirmDialog {
        id: confirmReset

        text: qsTr("This action will erase all game progress.\nContinue?")

        onAccepted: {
            core.reset()
            state = "hidden"
            resetOkToast.opacity = 1
        }

        onRejected: state = "hidden"
    }

    Rectangle {
        id: resetOkToast

        anchors { centerIn: parent }

        color: core.colors.black

        border.color: core.colors.yellow
        border.width: 10

        radius: 40

        width: parent.width*0.4
        height: parent.height*0.3

        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Text {
            anchors { centerIn: parent }
            text: "Game reset successfully"
            color: core.colors.yellow
            style: Text.Outline; styleColor: core.colors.black
            font { family: core.fonts.standard.name }
            font.pixelSize: 50
        }

        Timer {
            running: resetOkToast.opacity > 0
            interval: 2000
            onTriggered: resetOkToast.opacity = 0
        }

    }

}
