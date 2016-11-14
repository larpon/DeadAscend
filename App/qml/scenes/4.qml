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


    }


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        //sfx.add('level'+sceneNumber,'hum',App.getAsset('sounds/low_machine_hum.wav'))

    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(888,300,2000,'down')
        //game.showExit(400,10,2100,'up')
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                'Nah. Not really interesting',
                'Not of any use',
                'It\'s actually a bit warm in here',
                'The machines are humming quite a lot'
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

        name: 'clock_arms'

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

        name: 'treadmill'

        stateless: true

        run: true
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/treadmill/move/01.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,1,2,3,4,1,2,3,4,1,2,3,4],
                to: { "wait":1 }
            },
            {
                name: "wait",
                frames: [1],
                to: { "run":1 },
                duration: 3000
            }
        ]


    }



    AnimatedArea {

        id: elevatorDoor

        name: 'elevator_door_4'

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
