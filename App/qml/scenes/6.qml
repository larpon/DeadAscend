import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded

    onReadyChanged: {
        elevatorDoor.setActiveSequence('opened-wait-close')
    }

    anchors { fill: parent }

    property bool officeUnlocked: store.keyCombo1 && store.keyCombo2 && store.keyCombo3 && store.keyCombo4

    Store {
        id: store
        name: "level"+sceneNumber

        property bool keyCombo1: false
        property bool keyCombo2: false
        property bool keyCombo3: false
        property bool keyCombo4: false
    }


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        sfx.add("level"+sceneNumber,"pouring",App.getAsset("sounds/pouring.wav"))

    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(788,220,2000,"down")
        game.showExit(530,130,2100,"up")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                "Nah. Not really interesting",
                "Not of any use",
                "It's actually a bit warm in here"
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_6"

        clickable: !animating
        stateless: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/elevator_assets/doors/floor_6/move/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "closed",
                frames: [1]
            },
            {
                name: "open",
                frames: [1,2,3,4,5],
                to: { "opened":1 }
            },
            {
                name: "open-show-panel",
                frames: [1,2,3,4,5],
                to: { "opened":1 }
            },
            {
                name: "close",
                frames: [1,2,3,4,5],
                reverse: true,
                to: { "closed":1 }
            },
            {
                name: "opened-wait-close",
                frames: [5],
                reverse: true,
                to: { "close":1 },
                duration: 1000
            },
            {
                name: "opened",
                frames: [5]
            },
        ]

        onClicked: {
            setActiveSequence("open-show-panel")
        }

        onFrame: {
            App.debug(sequenceName, frame )
            if(sequenceName === "open-show-panel" && frame == 5)
                game.elevatorPanel.show = true
        }
    }

    showForegroundShadow: officeArea.state !== "on" && keypadArea !== "on"

    Area {
        id: officeArea
        stateless: true

        name: "office_area"

        onClicked: {
            if(scene.officeUnlocked)
                state === "on" ? state = "off" : state = "on"
            else
                game.setText("The door is locked...","The keypad to the right seem to be connected to the door")
        }
    }

    Area {
        id: keypadArea
        stateless: true

        name: "keypad_area"

        onClicked: state === "on" ? state = "off" : state = "on"
    }

    Area {
        stateless: true

        name: "blue_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ 'bottle_blue' ]

            name: "bottle_blue_drop"

            enabled: game.flaskMixerBlueLevel <= 0

            onDropped: {
                drop.accept()

                core.sounds.play("pouring")
                game.setText("The liquid is poured in now")

                game.flaskMixerBlueLevel = 1

                var o = drag.source
                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "purple_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ 'bottle_purple' ]

            name: "bottle_purple_drop"

            enabled: game.flaskMixerPurpleLevel <= 0

            onDropped: {
                drop.accept()

                core.sounds.play("pouring")
                game.setText("All the purple juicy stuff is poured in now")

                game.flaskMixerPurpleLevel = 1

                var o = drag.source
                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "red_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ 'bottle_red' ]

            name: "bottle_red_drop"

            enabled: game.flaskMixerRedLevel <= 0

            onDropped: {
                drop.accept()

                core.sounds.play("pouring")
                game.setText("All the red goo is poured in now")

                game.flaskMixerRedLevel = 1

                var o = drag.source
                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "green_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ 'bottle_green' ]

            name: "bottle_green_drop"

            enabled: game.flaskMixerGreenLevel <= 0

            onDropped: {
                drop.accept()

                core.sounds.play("pouring")
                game.setText("All the contents are poured in")

                game.flaskMixerGreenLevel = 1

                var o = drag.source
                blacklistObject(o.name)
            }

        }
    }

    Connections {
        target: game.elevatorPanel
        onShowChanged: {
            if(game.elevatorPanel.show) {

            } else {
                elevatorDoor.setActiveSequence('close')
            }
        }
    }

    AnimatedArea {

        name: "ventilator_wing"

        stateless: true

        visible: true
        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/ventilator/wing_2/1.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "run",
                frames: [1,2,3],
                to: { "run":1 }
            }
        ]
    }

    Item {
        id: keypadScene
        anchors { fill: parent }
        z: 22

        property bool show: keypadArea.state === "on"

        signal keyClicked(string key)

        onKeyClicked: {
            App.debug(key)
            game.setText(key);
        }

        visible: opacity > 0
        opacity: show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }


        Rectangle {
            anchors { fill: parent }
            color: core.colors.black
            opacity: 0.8
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: keypadArea.state = "off"
        }

        Image {
            anchors {
                top: parent.top
                right: parent.right
            }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("back_button.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: keypadArea.state = "off"
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/keypad/keypad.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: game.setText("A fancy colored keypad")
            }

            // 1
            Area {
                x: 55; y: 70
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("1") }
            }

            // 2
            Area {
                x: 125; y: 62
                width: 60; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("2") }
            }

            // 3
            Area {
                x: 204; y: 62
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("3") }
            }

            // 4
            Area {
                x: 50; y: 145
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("4") }
            }

            // 5
            Area {
                x: 120; y: 141
                width: 58; height: 55
                stateless: true
                onClicked: { keypadScene.keyClicked("5") }
            }

            // 6
            Area {
                x: 198; y: 142
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("6") }
            }

            // 7
            Area {
                x: 55; y: 230
                width: 45; height: 45
                stateless: true
                onClicked: { keypadScene.keyClicked("7") }
            }

            // 8
            Area {
                x: 126; y: 223
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("8") }
            }

            // 9
            Area {
                x: 201; y: 220
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("9") }
            }

            // OK
            Area {
                x: 60; y: 310
                width: 107; height: 59
                stateless: true
                onClicked: { keypadScene.keyClicked("OK") }
            }

            // CLR
            Area {
                x: 195; y: 310
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("CLR") }
            }
        }


    }


    Item {
        id: officeScene
        anchors { fill: parent }
        z: 22

        property bool show: officeArea.state === "on"

        visible: opacity > 0
        opacity: show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/6office.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: game.setText("Hmm...")
            }

            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("scenes/6office_fg_shadow.png")
            }

        }

        MouseArea {
            anchors { fill: parent }
            onClicked: officeArea.state = "off"
        }

        Image {
            anchors {
                top: parent.top
                right: parent.right
            }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("back_button.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: officeArea.state = "off"
            }
        }




    }


    onObjectDropped: {
    }

    onObjectTravelingToInventory: {
    }

    onObjectDragged: {
    }

    onObjectReturned: {
    }

    onObjectAddedToInventory: {
    }

    onObjectRemovedFromInventory: {
    }

}
