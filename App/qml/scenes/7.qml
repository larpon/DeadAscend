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

    Store {
        id: store
        name: "level"+sceneNumber

        property bool ropeTied: false

    }


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = sounds
        //sfx.add("level"+sceneNumber,"hum",App.getAsset("sounds/low_machine_hum.wav"))

    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(58,400,2000,"down")
        game.showExit(900,180,2100,"up")
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

        name: "elevator_door_7"

        clickable: !animating
        stateless: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/elevator_assets/doors/floor_7/move/0001.png")

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
            sounds.play("ding")
        }

        onFrame: {
            if(sequenceName === "open-show-panel" && frame == 5) {
                game.elevatorPanel.show = true
                sounds.play("elevator_open")
            }
            if(sequenceName === "close" && frame == 1) {
                sounds.play("elevator_close")
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

    Area {
        name: "window"
        stateless: true
        onClicked: maybeGoTo2()
    }

    Area {
        name: "hook"
        stateless: true
        onClicked: maybeGoTo2()
    }

    Area {
        name: "exit_to_2_left"
        stateless: true

        DropSpot {
            anchors { fill: parent }
            keys: [ 'rope' ]

            name: "rope_drop"

            enabled: !store.ropeTied

            onDropped: {
                drop.accept()

                //sounds.play("pouring")
                game.setText("Brilliant. The rope is firmly tied to the hook")

                store.ropeTied = true

                var o = drag.source
                blacklistObject(o.name)
            }

        }

        onClicked: maybeGoTo2()
    }

    function maybeGoTo2() {
        if(store.ropeTied) {
            game.scene2type = "left"
            game.goToScene("2")
        } else
            game.setText("Hmm... If we tied something to the hook...","...")
    }

    Area {
        name: "rope_tied"
        stateless: true
        visible: store.ropeTied
        onClicked: maybeGoTo2()
    }


    AnimatedArea {

        name: "curtains"

        clickable: true
        stateless: true

        visible: true
        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/curtains/flutter/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "flutter",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17],
                to: { "flutter":1, "pause":2 }
            },
            {
                name: "pause",
                frames: [1],
                to: { "flutter":2, "pause":1 },
                duration: 2000
            }
        ]

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
