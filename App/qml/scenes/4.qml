import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded && elevatorDoor.ready

    onReadyChanged: {

    }

    anchors { fill: parent }

    Store {
        id: store
        name: "level"+sceneNumber

        property bool beachBallRemoved: false
        property bool rockingHorseRemoved: false
        property bool skiLeftRemoved: false
        property bool skiRightRemoved: false
        property bool popBaseRemoved: false
        property bool popTopRemoved: false
        property bool scooterRemoved: false
    }


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        //sfx.add("level"+sceneNumber,"hum",App.getAsset("sounds/low_machine_hum.wav"))

    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(888,300,2000,"down")
        //game.showExit(400,10,2100,"up")
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

    AnimatedArea {

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
            if(store.scooterRemoved) {
                setActiveSequence("single spin")
                running = true
                game.setText("Maybe this treadmill could actually power the elevator","It's just a matter of finding something powerfull enough to run it")
            } else
                game.setText("It can't move with all this junk in front of it")
        }

    }


    Area {
        name: "scooter"

        visible: !store.scooterRemoved
        onClicked: {
            if(!store.popBaseRemoved)
                game.setText("It's stuck behind the popcorn machine")
            else
                mover.moveTo(-width,y+100)
        }
        mover.onStopped: store.scooterRemoved = true
    }

    Area {
        name: "popcorn_machine_base"

        visible: !store.popBaseRemoved
        onClicked: {
            if(!store.popTopRemoved)
                game.setText("The wheels on this is rusted in place. The glass top is making it too heavy to move.")
            else
                mover.moveTo(-width,y+100)
        }
        mover.onStopped: store.popBaseRemoved = true
    }

    Area {
        name: "popcorn_machine_top"

        visible: !store.popTopRemoved
        onClicked: {
            if(!store.skiRightRemoved || !store.skiLeftRemoved)
                game.setText("The skies are in the way")
            else
                mover.moveTo(x,-height)
        }
        mover.onStopped: store.popTopRemoved = true
    }

    Area {
        name: "ski_left"

        visible: !store.skiLeftRemoved
        onClicked: {
            if(!store.rockingHorseRemoved)
                game.setText("The rocking horse is in the way")
            else
                mover.moveTo(-width,y)
        }
        mover.onStopped: store.skiLeftRemoved = true
    }

    Area {
        name: "ski_right"

        visible: !store.skiRightRemoved
        onClicked: {
            if(!store.beachBallRemoved)
                game.setText("The beach ball is in the way")
            else
                mover.moveTo(-width,y+30)
        }
        mover.onStopped: store.skiRightRemoved = true
    }

    Area {
        name: "rocking_horse"

        visible: !store.rockingHorseRemoved
        onClicked: {
            mover.moveTo(-width,y+height)
        }
        mover.onStopped: store.rockingHorseRemoved = true
    }

    Area {
        name: "beach_ball"

        visible: !store.beachBallRemoved
        onClicked: {
            mover.moveTo(-width,scene.height+height)
        }
        mover.onStopped: store.beachBallRemoved = true
    }


    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_4"

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
                name: "close",
                frames: [1,2,3,4],
                reverse: true,
                to: { "closed":1 }
            },
            {
                name: "opened",
                frames: [4]
            },
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
