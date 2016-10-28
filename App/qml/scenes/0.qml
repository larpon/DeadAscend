import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."

Item {
    id: scene

    anchors { fill: parent }

    paused: App.paused
    onPausedChanged: App.debug('Scene',paused ? 'paused' : 'continued')

    property string sceneNumber: game.currentScene

    Store {
        id: store
        name: "level"+sceneNumber

        property alias lightOn: aSwitch.active

        property bool bucketOnRope: false

    }

    Component.onCompleted: {
        store.load()

        if(!aSwitch.active)
            game.setText('The room is pitch dark. You\'re likely to get eaten by a zombie. You better find some light somewhere.','TIP: There\'s a switch in here somewhere')
        else
            game.showExit(600,124,4000,'up')

        var sfx = core.sounds
        sfx.add('level0','switch',App.getAsset('sounds/lamp_switch_01.wav'))
        sfx.add('level0','light_on',App.getAsset('sounds/light_on.wav'))
        sfx.add('level0','drip',App.getAsset('sounds/water_drip_01.wav'))
        sfx.add('level0','squeak',App.getAsset('sounds/faucet_sqeak.wav'))
        sfx.add('level0','heavy_drag',App.getAsset('sounds/heavy_drag.wav'))
        sfx.add('level0','hatch_open',App.getAsset('sounds/hatch_open.wav'))
        sfx.add('level0','hatch_close',App.getAsset('sounds/hatch_close.wav'))
        sfx.add('level0','water_run_loop',App.getAsset('sounds/water_run_loop_01.wav'))
    }

    Component.onDestruction: {
        store.save()
        core.sounds.clear('level0')
    }

    property bool playWaterSound: faucetHandle.state == "on" || waterRunAnimation.running || waterBucketRunAnimation.running
    onPlayWaterSoundChanged: {
        if(playWaterSound)
            core.sounds.play('water_run_loop',core.sounds.infinite)
        else
            core.sounds.stop('water_run_loop')
    }

    Image {
        id: background

        fillMode: Image.PreserveAspectFit
        source: App.getAsset('scenes/'+sceneNumber+'.png')

    }

    MouseArea {
        anchors { fill: parent }
        onClicked: {
            var a = [
                'Interesting surface',
                'Nothing interesting here',
                'Not of any use',
                'A creepy room',
                'A bit greased',
                'Where is everybody?',
                'There\'s sounds of mumbling zombies',
                'Did you hear that?'
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: rope_dangle

        x: 494; y: 107
        width: 65; height: 191

        name: 'rope_dangle'

        visible: true
        run: visible
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

        MouseArea {
            enabled: parent.visible
            anchors { fill: parent }

            onClicked: {
                hatch.setActiveSequence("open then close")
                game.setText('Gravity forces the hatch to close again','Find a way to keep the hatch open')
            }
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "bucket", "bucket_patched" ]

            name: "rope_dangle"

            onDropped: {
                drop.accept()

                game.destroyObject('bucket')
                rope_dangle.visible = false
                rope_dangle_bucket.visible = true

                hatch.setActiveSequence("open then close")
                game.setText('The bucket is not heavy enough to keep the hatch open. Make it heavier')
            }
        }
    }

    AnimatedArea {

        id: rope_dangle_bucket

        x: 494; y: 107
        width: 65; height: 191

        visible: false
        run: visible
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/rope/dangle_bucket/0001.png")

        defaultFrameDelay: 150

        name: 'rope_dangle_bucket'

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

        MouseArea {
            enabled: parent.visible
            anchors { fill: parent }

            onClicked: {
                var object = {
                    name: 'bucket',
                    itemSource: App.getAsset('sprites/bucket/bucket_empty.png')
                }

                game.spawnObject(object,function(o){
                    game.inventory.add(o)
                    rope_dangle.visible = true
                    rope_dangle_bucket.visible = false
                })

            }
        }
    }

    AnimatedArea {

        id: rope_dangle_water

        x: 494; y: 107
        width: 65; height: 191

        name: 'rope_dangle_water'

        visible: !rope_dangle.visible && !rope_dangle_bucket.visible
        paused: !visible || scene.paused

        source: App.getAsset("sprites/rope/dangle_bucket_water/0001.png")

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
    }

    AnimatedArea {
        id: waterDripAnimation

        x: 75; y: 328
        width: 27; height: 85

        onRunningChanged: {
            if(running) {
                waterRunAnimation.run = false
                waterBucketFillAnimation.run = false
                waterBucketRunAnimation.run = false
            }
        }

        run: true
        name: 'drip'

        paused: !visible || scene.paused

        source: App.getAsset("sprites/water/drip/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "drip",
                frames: [1,2,3,4,5],
                to: { "pause":1 }
            },
            {
                name: "pause",
                frames: [5],
                to: { "drip":1 },
                duration: 2000
            }
        ]

        onFrame: {
            if(sequenceName === 'drip' && frame === 4)
                core.sounds.play('drip')
        }
    }

    AnimatedArea {

        id: waterBucketRunAnimation

        x: 494; y: 107
        width: 65; height: 191

        onRunningChanged: {
            if(running) {
                waterDripAnimation.run = false
                waterRunAnimation.run = false
            }
        }

        run: false

        name: 'bucket_run'

        paused: !visible || scene.paused

        defaultFrameDelay: 150

        source: App.getAsset("sprites/water/bucket_run/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3],
                to: { "run":1}
            }
        ]

    }

    AnimatedArea {
        id: waterBucketFillAnimation
        x: 494; y: 107
        width: 65; height: 191

        run: false
        name: 'bucket_fill'

        paused: !visible || scene.paused

        defaultFrameDelay: 500

        source: App.getAsset("sprites/water/bucket_fill/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5]
            }
        ]
    }

    AnimatedArea {

        id: waterPoolAnimation

        x: 494; y: 107; z: 0
        width: 65; height: 191

        running: false

        run: false

        onRestarted: run = true

        onRunChanged: {
            if(run) {
                running = true

                game.setText("There's a hole in the bucket. You need to patch the bucket somehow")

            } else {
                setActiveSequence('stop')
            }
        }

        name: 'pool'

        paused: !visible || scene.paused

        defaultFrameDelay: 150
        source: App.getAsset("sprites/water/pool/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { 'loop': 1}
            },
            {
                name: "loop",
                frames: [15,16,17,18,17,16,15],
                to: { 'loop': 1}
            },
            {
                name: "stop",
                frames: [15,16,17,18,19,20,21,22,23,24]
            }
        ]
    }

    AnimatedArea {
        id: waterRunAnimation

        x: 494; y: 107
        width: 65; height: 191

        onRunningChanged:  {
            if(running) {
                waterDripAnimation.run = false
                waterBucketFillAnimation.run = false
                waterBucketRunAnimation.run = false
            }
        }

        run: false
        name: 'run'

        paused: !visible || scene.paused

        defaultFrameDelay: 150

        source: App.getAsset("sprites/water/run/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3],
                to: { "run":1}
            }
        ]

    }

    Area {
        id: faucetHandle
        x: 50; y: 275
        width: 61; height: 54

        name: "faucet_handle"

        state: ""

        onClicked: {
            state === "off" ? state = "on" : state = "off"
            core.sounds.play('squeak')
        }

        onStateChanged: resolveState()

        function resolveState() {
            if(state === "on") {
                waterRunAnimation.run = true
            } else {
                waterDripAnimation.run = true
            }
            resolveBucketState()
        }
    }


    Area {
        id: fliesAndLight

        name: 'light'

        x: 52; y: 104
        width: 112; height: 54

        onClicked: game.setText('The flourescent lights humms faintly - casting a grim light in the room...','Some flies are having a party here as well')
    }

    Area {
        x: 189; y: 180
        width: 95; height: 124

        name: 'crack'

        onClicked: game.setText('Just another crack in the wall..')
    }

    Area {
        x: 857; y: 134
        width: 100; height: 149

        name: 'crack2'

        onClicked: game.setText('A crack in the wall reveals the bare bricks. Something must have hit it hard')
    }

    Area {
        x: 268; y: 266
        width: 123; height: 125

        name: 'wooden_planks'

        onClicked: game.setText('Some wooden planks')
    }

    Object {
        x: 800; y: 569

        draggable: false
        autoInventory: false

        name: 'parasol_base'

        mover.duration: 1400

        onStateChanged: {
            if(state === "over") {
                moveTo(800-width,y)
            } else {
                moveTo(800,y)
            }
        }

        onClicked: {
            core.sounds.play('heavy_drag')
            state === "over" ? state = "moved" :  state = "over"
        }

    }


    ImageAnimation {

        x: 98; y: 110
        width: 17; height: 15

        paused: (scene.paused)

        source: App.getAsset("sprites/flies/cycle_3/0001.png")

        defaultFrameDelay: 80

        sequences: [
            {
                name: "buzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { "rbuzz":1}
            },
            {
                name: "rbuzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { "buzz":1},
                reverse: true
            }
        ]
    }

    ImageAnimation {

        x: 98; y: 110
        width: 21; height: 5

        paused: (scene.paused)

        source: App.getAsset("sprites/flies/cycle_2/0001.png")

        defaultFrameDelay: 70

        sequences: [
            {
                name: "buzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
                to: { "rbuzz":1}
            },
            {
                name: "rbuzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
                to: { "buzz":1},
                reverse: true
            }
        ]
    }

    ImageAnimation {

        x: 98; y: 110
        width: 17; height: 13

        paused: (scene.paused)

        source: App.getAsset("sprites/flies/cycle_1/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "buzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "rbuzz":1}
            },
            {
                name: "rbuzz",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "buzz":1},
                reverse: true
            }
        ]
    }

    AnimatedArea {
        id: hatch
        x: 494; y: 107
        width: 118; height: 47

        visible: true
        name: 'hatch'

        state: sequence ? sequence.name : 'closed'

        //paused: (scene.paused)

        defaultFrameDelay: 150

        source: App.getAsset("sprites/hatch/open/0001.png")

        sequences: [
            {
                name: "closed",
                frames: [1,2,3,4,5,6],
                reverse: true
            },
            {
                name: "open",
                frames: [1,2,3,4,5,6]
                //to: { "closed":1}
            },
            {
                name: "open then close",
                frames: [1,2,3,4,5,6],
                to: { "closed":1}
            }
        ]

        onSequenceChanged: {
            if(sequence.name === "open" || sequence.name === "open then close")
                core.sounds.play('hatch_open')
            if(sequence.name === "closed")
                core.sounds.play('hatch_close')
        }
    }

    Image {
        id: darkness
        z: 1
        visible: !aSwitch.active
        anchors { fill: parent }

        fillMode: Image.PreserveAspectFit
        source: App.getAsset('scenes/0_darkness.png')

        MouseArea {
            enabled: parent.visible
            anchors { fill: parent }
            onClicked: game.setText('It\'s too dark to do anything. Better find some light somewhere')
        }
    }

    Switch {
        id: aSwitch
        z: 2
        x: 1000; y: 303

        name: 'switch'

        onActiveChanged: {
            core.sounds.play('switch')
            if(active) {
                game.setText('Lights on')
                core.sounds.play('light_on')
                game.showExit(600,124,2000,'up')
            } else
                game.setText('Lights out')
        }

        onSource: App.getAsset('sprites/buttons/button_01/button_01_down.png')
        offSource: App.getAsset('sprites/buttons/button_01/button_01_up.png')
    }

    DropSpot {
        x: 60; y: 325
        width: 95; height: 97
        keys: [ "bucket" , "bucket_patched" ]

        name: "faucet"

        onDropped: {
            drop.accept()

            var o = drag.source

            o.x = x
            o.y = y+13

        }
    }

    function resolveBucketState() {
        var o = game.getObject('bucket')

        if(o && o.at === "faucet" && faucetHandle.state === "on") {
            waterBucketRunAnimation.run = true
            waterPoolAnimation.restart()
        } else
            waterPoolAnimation.run = false

    }

    Connections {
        target: game

        onObjectDropped: {
            if(object.name === "bucket")
                resolveBucketState()
        }

        onObjectDragged: {
            if(object.name === "bucket") {
                faucetHandle.resolveState()
            }
        }

        onObjectReturned: {
            if(object.name === "bucket" && object.at === "faucet")
                faucetHandle.resolveState()
        }

        onObjectAddedToInventory: {
            if(object.name === "bucket")
                faucetHandle.resolveState()
        }

        onObjectRemovedFromInventory: {
            if(object.name === "bucket")
                faucetHandle.resolveState()
        }
    }


    Image {
        id: foreground
        z: 10
        anchors { fill: parent }

        fillMode: Image.PreserveAspectFit
        source: App.getAsset('scenes/0_fg_shadow.png')

        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            paused: running && scene.paused

            NumberAnimation { target: foreground; property: "opacity"; from: 1; to: 0.9; duration: 600 }
            NumberAnimation { target: foreground; property: "opacity"; from: 0.9; to: 1; duration: 800 }
        }

    }

}
