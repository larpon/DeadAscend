import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded && elevatorDoor.ready && treadmill.ready

    onReadyChanged: {
        if(store.treadmillRunning) {
            treadmill.setActiveSequence('run')
            treadmill.run = true

            elevatorDoor.setActiveSequence('opened-wait-close')
        }


    }

    anchors { fill: parent }

    Store {
        id: store
        name: "level"+sceneName

        property bool beachBallRemoved: false
        property bool rockingHorseRemoved: false
        property bool skiLeftRemoved: false
        property bool skiRightRemoved: false
        property bool popBaseRemoved: false
        property bool popTopRemoved: false
        property bool scooterRemoved: false

        property bool cableConnected: false

        property bool treadmillRunning: false
    }


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = sounds
        sfx.add("level"+sceneName,"light_drag",App.getAsset("sounds/light_drag_01.wav"))
        sfx.add("level"+sceneName,"rattle_loop",App.getAsset("sounds/rattle_loop.wav"))

    }

    Component.onDestruction: {
        store.save()
    }

    Connections {
        target: sounds
        onLoaded: {
            if(tag === "rattle_loop" && store.treadmillRunning)
                sounds.play("rattle_loop",sounds.infinite)
        }
    }

    function showExit() {
        game.showExit(888,300,2000,"down")
        game.showExit(560,280,2100,"up")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                "Nah. Not really interesting",
                "Not of any use",
                "It's actually a bit warm in here",
                "There's almost too quiet..."
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    Area {
        stateless: true

        name: "exit_down_4"

        onClicked: game.goToScene("3")
    }

    AnimatedArea {

        name: "clock_arms"

        stateless: true

        run: true
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/clock/broken_arms/0001.png")

        sequences: [
            {
                name: "tick",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33],
                to: { "wait":1 }
            },
            {
                name: "wait",
                frames: [1],
                to: { "tick":1 },
                duration: 3000
            }
        ]


    }

    Area {
        stateless: true

        visible: store.cableConnected
        name: "cable_treadmill"

        onClicked: game.setText(qsTr("It's now connecting the treadmill with the battery - good thinking!"))
    }

    AnimatedArea {
        id: treadmill
        name: "treadmill"

        clickable: true
        stateless: true
        visible: true

        run: false
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/treadmill/move/01.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4],
                to: { "run":1 }
            },
            {
                name: "single spin",
                frames: [1,2,3,4,1,2,3,4,1,2,3,4],
            }
        ]

        onClicked: {
            if(store.treadmillRunning && store.cableConnected) {
                game.setText(qsTr("The elevator is now: Zombie Hamster Powered..."),qsTr("That's... really..."),qsTr("... really... weird"))
            } else if(store.treadmillRunning && !store.cableConnected) {
                game.setText(qsTr("There should be a way to connect the treadmill to the motor somehow"))
            } else if(store.scooterRemoved) {
                setActiveSequence("single spin")
                sounds.play("rattle_loop")
                running = true
                game.setText(qsTr("Maybe this treadmill could actually power the elevator"),qsTr("It's just a matter of finding something powerfull enough to run it"))
            } else
                game.setText(qsTr("It can't move with all this junk in front of it"))
        }

        DropSpot {

            enabled: !store.treadmillRunning
            anchors { fill: parent }

            keys: [ "zombie_hamster" ]

            name: "treadmill_drop"

            onDropped: {
                store.treadmillRunning = true
                sounds.play("rattle_loop",sounds.infinite)
                treadmill.setActiveSequence('run')
                treadmill.run = true
                drop.accept()
                var o = drag.source
                game.blacklistObject(o.name)
            }
        }

        AnimatedArea {
            x: 10; y: 110
            width: 144; height: 126
            run: store.treadmillRunning
            paused: !visible || (scene.paused)

            rotation: 10

            defaultFrameDelay: 40

            source: App.getAsset("sprites/hamster/zombie_hamster_run/0001.png")

            sequences: [
                {
                    name: "run",
                    frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                    to: { "run":1 }
                }
            ]
        }

    }

    Area {
        name: "scooter"

        visible: !store.scooterRemoved
        onClicked: {
            if(!store.popBaseRemoved)
                game.setText(qsTr("It's stuck behind the popcorn machine"))
            else {
                mover.moveTo(-width,y+100)
                sounds.play("move")
            }
        }
        mover.onStopped: store.scooterRemoved = true
    }

    Area {
        name: "popcorn_machine_base"

        visible: !store.popBaseRemoved
        onClicked: {
            if(!store.popTopRemoved)
                game.setText(qsTr("The wheels on this is rusted in place. The glass top is making it too heavy to move."))
            else {
                mover.moveTo(-width,y+100)
                sounds.play("light_drag")
            }
        }
        mover.onStopped: store.popBaseRemoved = true
    }

    Area {
        name: "popcorn_machine_top"

        visible: !store.popTopRemoved
        onClicked: {
            if(!store.skiRightRemoved || !store.skiLeftRemoved)
                //: Skies the ones you put on and ski down a slope with :)
                game.setText(qsTr("The skies are in the way"))
            else {
                mover.moveTo(x,-height)
                sounds.play("add")
            }
        }
        mover.onStopped: store.popTopRemoved = true
    }

    Area {
        name: "ski_left"

        visible: !store.skiLeftRemoved
        onClicked: {
            if(!store.rockingHorseRemoved)
                game.setText(qsTr("The rocking horse is in the way"))
            else {
                mover.moveTo(-width,y)
                sounds.play("add")
            }
        }
        mover.onStopped: store.skiLeftRemoved = true
    }

    Area {
        name: "ski_right"

        visible: !store.skiRightRemoved
        onClicked: {
            if(!store.beachBallRemoved)
                game.setText(qsTr("The beach ball is in the way"))
            else {
                mover.moveTo(-width,y+30)
                sounds.play("add")
            }
        }
        mover.onStopped: store.skiRightRemoved = true
    }

    Area {
        name: "rocking_horse"

        visible: !store.rockingHorseRemoved
        onClicked: {
            mover.moveTo(-width,y+height)
            sounds.play("move")
        }
        mover.onStopped: store.rockingHorseRemoved = true
    }

    Area {
        name: "beach_ball"

        visible: !store.beachBallRemoved
        onClicked: {
            mover.moveTo(-width,scene.height+height)
            sounds.play("add")
        }
        mover.onStopped: store.beachBallRemoved = true
    }


    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_4"

        clickable: !animating
        stateless: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/elevator_assets/doors/floor_4/move/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "closed",
                frames: [1]
            },
            {
                name: "open",
                frames: [1,2,3,4],
                to: { "opened":1 }
            },
            {
                name: "open-show-panel",
                frames: [1,2,3,4],
                to: { "opened":1 }
            },
            {
                name: "close",
                frames: [1,2,3,4],
                reverse: true,
                to: { "closed":1 }
            },
            {
                name: "opened-wait-close",
                frames: [4],
                reverse: true,
                to: { "close":1 },
                duration: 1000
            },
            {
                name: "opened",
                frames: [4]
            },
        ]

        onClicked: {
            if(store.treadmillRunning && store.cableConnected) {
                setActiveSequence("open-show-panel")
                sounds.play("ding")
            } else
                game.setText(qsTr("The elevator needs power to operate."))
        }

        onFrame: {
            //App.debug(sequenceName, frame )
            if(sequenceName === "open-show-panel" && frame == 4) {
                game.elevatorPanel.show = true
                sounds.play("elevator_open")
            }
            if(sequenceName === "close" && frame == 1) {
                sounds.play("elevator_close")
            }
        }
    }

    DropSpot {
        x: 144; y: 296
        width: 341; height: 213
        keys: [ 'cable_generator' ]

        name: "cable_drop"

        enabled: store.scooterRemoved && !(store.treadmillRunning && store.cableConnected)

        onDropped: {
            drop.accept()

            sounds.play("tick_soft")
            game.setText(qsTr("It's now connecting the treadmill with the battery - good thinking!"))

            store.cableConnected = true
            var o = drag.source
            blacklistObject(o.name)
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

    onObjectClicked: {
        if(object.name === "open_sack" || object.name === "sacks") {
            if(game.inventory.has('grain')) {
                object.description = qsTr('No need for more grain')
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
