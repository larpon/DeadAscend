import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: core

    property alias modes: modes
    property alias colors: colors
    property alias fonts: fonts
    property alias viewport: view.viewport

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

        safePlay: Qak.platform.os === "windows"
        //muted: core.muted
        //volume: volumes.sfx

        Component.onCompleted: {
            add('add',App.getAsset('sounds/generic_add.wav'))
            add('move',App.getAsset('sounds/generic_move.wav'))
            add('tick',App.getAsset('sounds/generic_tick.wav'))
            add('tick_soft',App.getAsset('sounds/inventory_01.wav'))
            add('tap',App.getAsset('sounds/key_tap.wav'))
            // NOTE Added globally so it plays between scene loads!
            add('lift_motor',App.getAsset('sounds/lift_motor_01.wav'))

            add('elevator_open',App.getAsset('sounds/elevator_doors_open.wav'))
            add('elevator_close',App.getAsset('sounds/elevator_doors_close.wav'))
            add('ding',App.getAsset('sounds/ding_01.wav'))

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
        id: view
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
                NumberAnimation { duration: 1000 }
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
            opacity: menuLoader.opacity < 1 && gameLoader.opacity < 1 && (gameLoader.item && gameLoader.item.ready) ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 00 }
            }
            readonly property bool fullyVisible: opacity >= 1

            anchors { fill: parent }
            color: colors.black

            Image {
                id: lsImage
                x: parent.halfWidth - halfWidth; y: parent.halfHeight - halfHeight
                source: App.getAsset('load.png')

                SequentialAnimation on y {
                    loops: Animation.Infinite

                    paused: running && App.paused && !loadingScreen.visible

                    running: true

                    // Move from minHeight to maxHeight in 300ms, using the OutExpo easing function
                    NumberAnimation {
                        from: lsImage.y; to: lsImage.y - 30
                        easing.type: Easing.InCubic; duration: 500
                    }

                    // Then move back to minHeight in 1 second, using the OutBounce easing function
                    NumberAnimation {
                        from: lsImage.y - 30; to: lsImage.y
                        easing.type: Easing.OutCubic; duration: 500
                    }

                }
            }

        }

        // TODO Remove on release
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

    Store {
        id: settings
        name: "core"
    }

    function reset(type) {
        type = type || ""
        if(type === "") {
            settings.clearAll()
            Qak.resource.clearDataPath()
        }
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
