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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    bounce: true
                    text: qsTr("Start")
                    onClicked: core.modes.set('game')
                }

                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    text: qsTr("Options")
                    onClicked: core.modes.set('menu')
                }

                TextButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    allUppercase: true
                    text: qsTr("About")
                }

            }
        }
    }


}
