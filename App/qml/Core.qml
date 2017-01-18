import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: core

    readonly property bool paused: (pauses.system || pauses.user)

    property alias modes: modes
    property alias colors: colors
    property alias pauses: pauses
    property alias mutes: mutes
    property alias fonts: fonts
    property alias viewport: view.viewport

    readonly property real defaultMargins: Qak.platform.isMobile ? -20 : -10

    Component.onCompleted: {
        onBack(function(){ modes.set('quit') })

        if(Qak.platform.os === "ios") {
            musicPlayer.source = App.getAsset("sounds/bensound-ofeliasdream.aac")
        } else {
            musicPlayer.source = App.getAsset("sounds/bensound-ofeliasdream.mp3")
        }

        musicPlayer.play()

    }

    Component.onDestruction: {
        settings.save()
        musicPlayer.stop()
    }

    Store {
        id: settings
        name: "core"
    }

    QtObject {
        id: pauses
        property bool user: false
        readonly property bool system: App.paused
    }

    QtObject {
        id: mutes

        readonly property bool all: user && system
        readonly property bool some: user || system

        property bool user: false
        readonly property bool system: core.paused || loadingScreen.visible
    }

    QtObject {
        id: colors
        property color black: "#000000"
        property color yellow: "#e2c60f"
    }

    QtObject {
        id: fonts
        property FontLoader standard: FontLoader { source: App.getAsset("fonts/Amatic_SC/AmaticSC-Bold.ttf") }
        property FontLoader sans: FontLoader { source: App.getAsset("fonts/Open_Sans/OpenSans-Regular.ttf") }
    }

    property alias sounds: soundEffects
    SoundBank {
        id: soundEffects

        safePlay: Qak.platform.os === "windows"
        muted: mutes.some
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

    MusicPlayer {
        id: musicPlayer
        volume: 0.55
        muted: core.paused
    }

    Modes {
        id: modes

        Mode {
            name: 'menu'
            onLeave: menuLoader.opacity = 0
            onEnter: {
                menuLoader.opacity = 1
            }
        }

        Mode {
            name: 'game'
            onLeave: {
                gameLoader.opacity = 0
                banner.show()
            }
            onEnter: {
                banner.hide()
                onBack(function(){ modes.set('menu') })
                gameLoader.opacity = 1
            }
        }

        Mode {
            name: 'game-tutorial'
            onLeave: {
                gameLoader.opacity = 0
                banner.show()
            }
            onEnter: {
                banner.hide()
                onBack(function(){ modes.set('menu') })
                gameLoader.opacity = 1
            }
        }

        Mode {
            name: 'credits'
            onLeave: creditsLoader.opacity = 0
            onEnter: {
                onBack(function(){ modes.set('menu') })
                creditsLoader.opacity = 1
            }
        }

        Mode {
            name: 'about'
            onLeave: aboutLoader.opacity = 0
            onEnter: {
                onBack(function(){ modes.set('menu') })
                aboutLoader.opacity = 1
            }
        }

        Mode {
            name: 'end-credits'
            onLeave: creditsLoader.opacity = 0
            onEnter: {
                goBack()
                onBack(function(){ modes.set('menu') })
                creditsLoader.opacity = 1
            }
        }

        Mode {
            name: 'quit'
            onEnter: Qt.quit()
        }

    }

    Connections {
        target: banner
        onLoadedChanged: {
            var m = modes.mode;
            if(m !== "game" && m !== "game-tutorial") {
                banner.show()
            }
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

        Loader {
            id: creditsLoader
            anchors { fill: parent }
            source: 'Credits.qml'
            active: opacity > 0

            visible: status == Loader.Ready && opacity > 0

            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 1000 }
            }
        }

        Loader {
            id: aboutLoader
            anchors { fill: parent }
            source: 'About.qml'
            active: opacity > 0

            visible: status == Loader.Ready && opacity > 0

            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 1000 }
            }
        }

        Rectangle {
            id: loadingScreen

            Timer {
                id: extraTimer
                interval: 2500
                onTriggered: loadingScreen.opacity = 0
            }

            property bool show: menuLoader.opacity < 1 && gameLoader.opacity < 1 && (gameLoader.item && gameLoader.item.ready)

            onShowChanged: {
                if(show)
                    opacity = 1
                else {
                    extraTimer.restart()
                }
            }

            visible: opacity > 0
            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 200 }
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

                    paused: running && !loadingScreen.visible

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

        ConfirmDialog {
            id: adConfirm
            anchors { centerIn: parent }

            text: qsTr("Do you wan't to see an ad?")
            acceptText: qsTr("Yeah sure")
            rejectText: qsTr("Nah")

            onAccepted: {
                interstitial.show()
                state == "hidden"
            }
            onRejected: state == "hidden"
        }
    }

    Timer {
        id: adTimer
        running: true
        interval: 5 * (60*1000) // Minutes
        repeat: true
        onTriggered: {
            //App.log('Show ad?',!interstitial.visible,interstitial.loaded)
            if(!interstitial.visible && interstitial.loaded) {
                adConfirm.state = "shown"
            }
        }
    }

    // Quick and dirty pagestack
    property var backQueue: []
    function goBack() {
        if(backQueue.length > 0) {
            App.debug('Popping from back queue')
            var func = backQueue.pop()
            var t = backQueue
            backQueue = t
            func()
        }
    }

    function onBack(func) {
        App.debug('Pushing to back queue')
        backQueue.push(func)
        var t = backQueue
        backQueue = t
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
                pauses.user = !pauses.user

        }
    }

}
