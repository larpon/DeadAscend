import QtQuick 2.0
import Qak.QtQuick 2.0

import ".."

Item {
    id: pause
    anchors { fill: parent }

    paused: !App.paused
    onPausedChanged: App.debug('Paused',paused ? 'paused' : 'continued')

    Item {
        anchors { fill: parent }

        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }

        Component.onCompleted: {
            opacity = 1
        }


        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            TextButton {
                anchors.horizontalCenter: parent.horizontalCenter
                allUppercase: true
                text: qsTr("Resume")
                onClicked: game.userPaused = false
            }

            TextButton {
                anchors.horizontalCenter: parent.horizontalCenter
                allUppercase: true
                text: qsTr("Menu")
                onClicked: core.modes.set('menu')
            }

            TextButton {
                anchors.horizontalCenter: parent.horizontalCenter
                allUppercase: true
                text: qsTr("Exit")
                onClicked: core.modes.set('quit')
            }

        }

    }


}
