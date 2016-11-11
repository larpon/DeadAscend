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

    Connections {
        target: core.sounds
        onLoaded: {
            if(tag === "hum")
                core.sounds.play('hum',core.sounds.infinite)
        }
    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        sfx.add('level'+sceneNumber,'hum',App.getAsset('sounds/low_machine_hum.wav'))
        sfx.add('level'+sceneNumber,'scribble',App.getAsset('sounds/scribble.wav'))
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
                'Nah. Not really interesting',
                'Not of any use',
                'It\'s actually a bit warm in here',
                'The machines are humming quite a lot'
            ]
            game.setText(Aid.randomFromArray(a))

            hamster.goalSequence = "bl-mid-bl"
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
            core.sounds.play('lift_motor')
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
        x: 815; y: 149
        width: 52; height: 48

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

    /** TODO optimize - many frames are the same - use the power of sequences
      peek 1-4
      peek-sniff 5 - 11
      peek-mid 12 - 23

      peek-bl 24 -32

      mid-eat 33 - 40
      bl-sniff 41 - 47
      bl-mid-bl 48 - 67

      bl-hide 68 - 79
      bl-circle 80 - 99
      */
    AnimatedArea {

        id: hamster

        clickable: true
        name: 'hamster'

        stateless: true

        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/hamster/moves/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "hide", // Starting point
                frames: [1],
                to: { "peek":1, "hide": 1 },
                duration: 1000
            },
            {
                name: "peek",
                frames: [1,2,3,4],
                to: { "peek-r":1, "peek-sniff": 1, "peek-bl":1 },
                duration: 1400
            },
            {
                name: "peek-r",
                frames: [1,2,3,4],
                to: { "hide":1 },
                reverse: true
            },
            {
                name: "peek-sniff",
                frames: [5,6,7,8,9,10,11],
                to: { "peek-r":1, "peek-sniff": 1 }
            },
            {
                name: "peek-mid", // Path to end state
                frames: [12,13,14,15,16,17,18,19,20,21,22,23],
                to: { "mid-eat":1 }
            },
            {
                name: "mid-eat", // End eat state
                frames: [33,34,35,36,37,38,39,40],
                to: { "mid-eat":1 }
            },
            {
                name: "bl", // starting state for all bl
                frames: [32],
                to: { "bl-sniff":1, "bl-mid-bl":1, "bl-hide":1, "bl-circle":1 },
                duration: 2400
            },
            {
                name: "peek-bl", // path to bl state
                frames: [24,25,26,27,28,29,30,31,32],
                to: { "bl":1 }
            },
            {
                name: "bl-sniff",
                frames: [41,42,43,44,45,46,47],
                to: { "bl":1 }
            },
            {
                name: "bl-mid-bl",
                frames: [48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67],
                to: { "bl":1 }
            },
            {
                name: "bl-hide",
                frames: [68,69,70,71,72,73,74,75,76,77,78,79],
                to: { "peek":1 }
            },
            {
                name: "bl-circle",
                frames: [80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99],
                to: { "bl":1 }
            }
        ]

        onSequenceChanged: {
            if(!sequence)
                return
            var n = sequence.name
            if(n === "bl" || n === "peek-bl" || n === "bl-mid-bl" || n === "bl-hide")
                core.sounds.play("scribble")
            if(n === "bl-circle")
                core.sounds.play("scribble",2)
        }

        onClicked: {
            game.setText('Such a cute little critter')
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "cannula" ]

            name: "hamster_drop"

            onDropped: {
                //drop.accept()

                //var o = drag.source

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
