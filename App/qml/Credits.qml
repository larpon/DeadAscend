import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."

Rectangle {
    id: credits

    anchors { fill: parent }
    color: "black"

    TextButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
        }

        //: Menu back button
        text: qsTr("BACK")

        font.pixelSize: 35

        onClicked: core.goBack();
    }

    Text {
        id: text
        anchors { centerIn: parent }
        horizontalAlignment: Text.AlignHCenter
        color: core.colors.yellow
        style: Text.Outline; styleColor: core.colors.black
        font { family: core.fonts.standard.name; capitalization: Font.MixedCase }
        font.pixelSize: 60
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }
    }

    SequentialAnimation {
        id: showAnimation
        running: true

        PauseAnimation {
            duration: 1000
        }

        ScriptAction {
            script: {
                text.text = 'Dead Ascend'
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 3000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Released, Ported & Open Sourced<br>
                by<br>
                Black Grain Games
                ")
                text.opacity = 1
            }
        }
        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Original story, idea & puzzles<br>
                Lars Pontoppidan & Stinus Petersen
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Engine, Graphics, Sound Effects & Scripting<br>
                Lars Pontoppidan
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Spanish translation<br>
                Sara Gutiérrez<br>Enrique Mora Gil
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Danish translation<br>
                Lars Pontoppidan
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Music<br>
                \"Ofelia's Dream\"<br>
                Royalty Free Music from Bensound
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                Open Source Components<br>
                <br>
                Qt (qt.io)<br>
                Qak (github.com/Larpon/qak)<br>
                QtFirebase (github.com/Larpon/QtFirebase)
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 9000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("
                More games & info<br>
                http://games.blackgrain.dk
                ")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction {
            script: {
                text.text = qsTr("Thank you for playing")
                text.opacity = 1
            }
        }

        PauseAnimation {
            duration: 6000
        }

        ScriptAction {
            script: {
                text.opacity = 0
            }
        }

        PauseAnimation {
            duration: 2000
        }
        ScriptAction {
            script: {
                core.goBack();
            }
        }
    }
}
