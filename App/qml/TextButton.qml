import QtQuick 2.0

import Qak 1.0

import "."

Item {
    id: item

    property bool bounce: false
    property bool jumpOnClick: true
    property bool panicClickSafety: false
    property int panicClickReset: 1000
    property bool allUppercase: false

    property int clicks: 0

    property alias font: text.font
    property alias text: text.text

    signal clicked

    width: text.width
    height: text.height

    Timer {
        id: panicClickResetTimer
        interval: panicClickReset
        onTriggered: item.clicks = 0
    }

    // TODO improve someday
    Text {
        id: textShadow
        anchors.centerIn: parent
        anchors.leftMargin: -5
        color: core.colors.black
        style: Text.Outline; styleColor: core.colors.black
        font { family: core.fonts.standard.name; bold: true; letterSpacing: 0.3; capitalization: allUppercase ? Font.AllUppercase : Font.MixedCase }
        font.pixelSize: text.font.pixelSize + 0.002
        scale: text.scale
        text: text.text
        opacity: 0.15
    }

    Text {
        id: text
        color: core.colors.yellow
        style: Text.Outline; styleColor: core.colors.black
        font { family: core.fonts.standard.name; capitalization: allUppercase ? Font.AllUppercase : Font.MixedCase }
        font.pixelSize: 90

        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        SequentialAnimation {
            id: jumpAnimation
            property real scale: 0
            ScriptAction {
                script: {
                    jumpAnimation.scale = text.scale
                    text.scale = 1.2
                }
            }

            PauseAnimation {
                duration: 350
            }

            ScriptAction {
                script: {
                    item.clicked()
                }
            }

            ScriptAction {
                script: {
                    text.scale = jumpAnimation.scale
                    if(!panicClickSafety)
                        item.clicks = 0
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            clicks++

            if(panicClickSafety && clicks > 1) {
                panicClickResetTimer.restart()
                return
            }

            if(jumpOnClick)
                jumpAnimation.restart()
            else
                parent.clicked()

            if(panicClickSafety)
                panicClickResetTimer.restart()
        }
    }

    // Animate the y property. Setting loops to Animation.Infinite makes the
    // animation repeat indefinitely, otherwise it would only run once.
    SequentialAnimation on y {
        loops: Animation.Infinite

        paused: running && App.paused

        running: bounce

        // Move from minHeight to maxHeight in 300ms, using the OutExpo easing function
        NumberAnimation {
            from: item.y; to: item.y - 20
            easing.type: Easing.OutExpo; duration: 300
        }

        // Then move back to minHeight in 1 second, using the OutBounce easing function
        NumberAnimation {
            from: item.y - 20; to: item.y
            easing.type: Easing.OutBounce; duration: 1000
        }

        // Then pause for 500ms
        PauseAnimation { duration: 1000 }
    }

    //Behavior on x { enabled: true; SpringAnimation { spring: 3; damping: 0.3; mass: 1.0 } }
    //Behavior on y { enabled: true; SpringAnimation { spring: 3; damping: 0.3; mass: 1.0 } }
}
