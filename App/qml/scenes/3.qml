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

    /**
      peek 1-4
      peek-sniff 5 - 11
      peek-mid 12 - 23

      peek-bl 24 -32

      mid-eat 33 - 40
      bl-sniff 41 - 47
      bl-mid-bl 48 - 67

      bl-hide 68 - 79
      */
    AnimatedArea {

        id: hamster

        clickable: true
        name: 'hamster'

        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/rope/dangle/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "dangle",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { "rdangle":1}
            },
            {
                name: "rdangle",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { "dangle":1},
                reverse: true
            }
        ]

        onClicked: {
            hatch.state = "open then close"
            game.setText('Gravity forces the hatch to close again','Find a way to keep the hatch open')
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "bucket", "bucket_patched", "bucket_full" ]

            name: "rope_dangle"

            onDropped: {
                drop.accept()

                var o = drag.source

                onRope = o.name
                if(o.name === "bucket_full") {
                    rope_dangle.run = false
                    rope_dangle_water.run = true
                    game.destroyObject(onRope)
                    game.blacklistObject(onRope)
                    hatch.state = "open"
                } else {
                    game.destroyObject(onRope)
                    rope_dangle.run = false
                    rope_dangle_bucket.run = true

                    hatch.state = "open then close"
                    game.setText('The bucket is not heavy enough to keep the hatch open. Make it heavier')
                }
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
