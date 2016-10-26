import QtQuick 2.0
import Qak 1.0

import "."

Item {
    id: core

    property alias modes: modes
    property alias colors: colors
    property alias fonts: fonts

    Component.onCompleted: onBack(function(){ modes.set('quit') })

    QtObject {
        id: colors
        property color black: "#000000"
        property color yellow: "#e2c60f"
    }

    QtObject {
        id: fonts
        property FontLoader standard: FontLoader { source: App.getAsset("fonts/Amatic_SC/AmaticSC-Bold.ttf") }
    }

    property alias sounds: soundEffects
    SoundBank {
        id: soundEffects

        //muted: core.muted
        //volume: volumes.sfx

        Component.onCompleted: {
            add('generic',App.getAsset('sounds/generic_add.wav'))
            add('switch',App.getAsset('sounds/lamp_switch_01.wav'))
            add('light_on',App.getAsset('sounds/light_on.wav'))
            add('drip',App.getAsset('sounds/water_drip_01.wav'))
        }
    }

    Modes {
        id: modes

        Mode {
            name: 'menu'
            onLeave: menuLoader.opacity = 0
            onEnter: menuLoader.opacity = 1
        }

        Mode {
            name: 'game'
            onLeave: gameLoader.opacity = 0
            onEnter: {
                onBack(function(){ modes.set('menu') })
                gameLoader.opacity = 1
            }
        }

        Mode {
            name: 'quit'
            onEnter: Qt.quit()
        }

    }

    View {
        anchors { fill: parent }

        mattes: true
        mattesColor: "black"

        viewport.fillMode: Image.PreserveAspectFit
        viewport.width: 1100
        viewport.height: 660

        Loader {
            id: menuLoader
            anchors { fill: parent }
            source: 'menus/Main.qml'
            active: opacity > 0

            visible: status == Loader.Ready && opacity > 0

            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 1500 }
            }
        }

        Loader {
            id: gameLoader
            anchors { fill: parent }
            source: 'Game.qml'

            active: opacity > 0

            visible: status == Loader.Ready && opacity > 0

            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 1500 }
            }
        }

        Rectangle {
            id: loadingScreen

            visible: opacity > 0
            opacity: menuLoader.opacity < 1 && gameLoader.opacity < 1 ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 500 }
            }
            readonly property bool fullyVisible: opacity >= 1

            anchors { fill: parent }
            color: colors.black
            Image {
                anchors { centerIn: parent }
                source: App.getAsset('load.png')
            }
        }

        EditorOverlay {
            id: editMode
            anchors { fill: parent }
        }
    }

    // Quick and dirty pagestack
    property var backQueue: []
    function goBack() {
        if(backQueue.length > 0) {
            var func = backQueue.pop()
            var t = backQueue
            backQueue = t
            func()
        }
    }

    function onBack(func) {
        backQueue.push(func)
        var t = backQueue
        backQueue = t
    }

    FocusScope {
        anchors { fill: parent }

        focus: true
        Keys.onReleased: {
            App.debug("Got key event",event,event.key)

            var key = event.key

            if (key === Qt.Key_E)
                editMode.enabled = !editMode.enabled

            if (key === Qt.Key_A)
                Qak.doDebug = !Qak.doDebug

            if (key == Qt.Key_Escape || key == Qt.Key_Q)
                modes.set('quit')

            if(key == Qt.Key_Back || key == Qt.Key_Backspace) {
                event.accepted = true
                goBack()
            }

            if (key == Qt.Key_F)
                toggleScreenMode()

            if (key == Qt.Key_G)
                view.viewport.toggleFillMode()

            if (key == Qt.Key_D)
                App.dbg = !App.dbg

            if (App.dbg && key == Qt.Key_S)
                modes.set('game')

            if (key == Qt.Key_P)
                App.paused = !App.paused

        }
    }
}
