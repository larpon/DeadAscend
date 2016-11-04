import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded

    anchors { fill: parent }

    Store {
        id: store
        name: "level"+sceneNumber

    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        //sfx.add('level'+sceneNumber,'switch',App.getAsset('sounds/lamp_switch_01.wav'))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(600,100,2000,'down')
        game.showExit(400,10,2100,'up')
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                'Test 3'
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {
        id: lift
        x: 0; y: 0
        width: 10; height: 10

        name: 'lift_3'

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/lift/operate_2/0001.png")

        defaultFrameDelay: 150

        readonly property bool isUp: state === "up"
        property bool changeLevel: false

        state: "up"
        onSequenceChanged: {
            if(!sequence)
                return
            state = sequence.name
        }


        sequences: [
            {
                name: "up",
                frames: [1]
            },
            {
                name: "go_up",
                frames: [1,2,3,4,5,6],
                to: { 'up':1 },
                reverse: true
            },
            {
                name: "down",
                frames: [6]
            },
            {
                name: "go_down",
                frames: [1,2,3,4,5,6],
                to: { 'down':1 }
            }
        ]

        onFrame: {
            if(sequenceName === "down" && frame === 6 && changeLevel) {
                changeLevel = false
                game.goToScene("2")
            }

        }

        function up() {
            game.setText("Going up!")
            setActiveSequence("go_up")
        }

        function down() {
            changeLevel = true
            game.setText("Going down!")
            setActiveSequence("go_down")
        }

        onReadyChanged: {
            setActiveSequence("up")
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: {
                lift.down()
            }
        }
    }

    Area {
        x: 50; y: 275
        width: 61; height: 54

        stateless: true

        name: "exit_down_3"

        onClicked: lift.down()
    }

    Area {
        x: 0; y: 0
        width: 10; height: 10

        stateless: true

        name: "exit_up_3"

        onClicked: {
            //game.goToScene("4")
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
