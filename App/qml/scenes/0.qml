import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."

Base {
    id: scene

    ready: store.isLoaded

    property bool bucketPatched: false
    property string onRope: ""

    Store {
        id: store
        name: "level"+sceneNumber

        property alias lightOn: aSwitch.active
        property alias bucketPatched: scene.bucketPatched
        property alias onRope: scene.onRope
    }

    Component.onCompleted: {
        store.load()

        if(!aSwitch.active)
            game.setText("The room is pitch dark. You're likely to get eaten by a zombie. You better find some light somewhere.","TIP: There's a switch in here somewhere")
        else
            showExit()

        var sfx = core.sounds
        sfx.add("level"+sceneNumber,"switch",App.getAsset("sounds/lamp_switch_01.wav"))
        sfx.add("level"+sceneNumber,"light_on",App.getAsset("sounds/light_on.wav"))
        sfx.add("level"+sceneNumber,"drip",App.getAsset("sounds/water_drip_01.wav"))
        sfx.add("level"+sceneNumber,"squeak",App.getAsset("sounds/faucet_sqeak.wav"))
        sfx.add("level"+sceneNumber,"heavy_drag",App.getAsset("sounds/heavy_drag.wav"))
        sfx.add("level"+sceneNumber,"hatch_open",App.getAsset("sounds/hatch_open.wav"))
        sfx.add("level"+sceneNumber,"hatch_close",App.getAsset("sounds/hatch_close.wav"))
        sfx.add("level"+sceneNumber,"water_run_loop",App.getAsset("sounds/water_run_loop_01.wav"))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(500,0,2000,"up")
    }

    MouseArea {
        anchors { fill: parent }
        onClicked: {
            var a = [
                "Interesting surface",
                "Nothing interesting here",
                "Not of any use",
                "A creepy room",
                "A bit greased",
                "Where is everybody?",
                "There's sounds of mumbling zombies",
                "Did you hear that?"
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }


    AnimatedArea {

        id: rope_dangle

        x: 494; y: 107
        width: 65; height: 191

        clickable: true
        name: "rope_dangle"

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
            game.setText("Gravity forces the hatch to close again","Find a way to keep the hatch open")
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
                    game.setText("The bucket is not heavy enough to keep the hatch open. Make it heavier")
                }
            }
        }
    }

    AnimatedArea {

        id: rope_dangle_bucket

        x: 494; y: 107
        width: 65; height: 191

        clickable: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/rope/dangle_bucket/0001.png")

        defaultFrameDelay: 150

        name: "rope_dangle_bucket"

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
            var object = {
                name: onRope,
                type: "Object",
                itemSource: App.getAsset("sprites/bucket/bucket_empty.png")
            }

            game.spawnObject(object,function(o){
                game.inventory.add(o)
                rope_dangle.run = true
                rope_dangle_bucket.run = false
            })

        }

    }

    AnimatedArea {

        id: rope_dangle_water

        x: 494; y: 107
        width: 65; height: 191

        name: "rope_dangle_water"

        clickable: true
        run: false
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

        onClicked: showExit()
    }

    AnimatedArea {

        id: waterPoolAnimation

        x: 494; y: 107; z: -1
        width: 65; height: 191

        running: false
        run: waterRunAnimation.run || (waterBucketRunAnimation.run && !bucketPatched)

        onRunChanged: {
            if(run) {
                running = true
                setActiveSequence("run")
            } else {
                running = true
                setActiveSequence("stop")
            }


        }

        name: "pool"

        paused: !visible || scene.paused

        defaultFrameDelay: 150
        source: App.getAsset("sprites/water/pool/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14],
                to: { "loop": 1}
            },
            {
                name: "loop",
                frames: [15,16,17,18,17,16,15],
                to: { "loop": 1}
            },
            {
                name: "stop",
                frames: [15,16,17,18,19,20,21,22,23,24]
            }
        ]
    }

    AnimatedArea {
        id: waterDripAnimation

        x: 75; y: 328; z: 2
        width: 27; height: 85

        onRunningChanged: {
            if(running) {
                waterRunAnimation.run = false
                waterBucketFillAnimation.run = false
                waterBucketRunAnimation.run = false
            }
        }

        run: true
        name: "drip"

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
            if(sequenceName === "drip" && frame === 4)
                core.sounds.play("drip")
        }
    }

    AnimatedArea {

        id: waterBucketRunAnimation

        x: 494; y: 107; z: 2
        width: 65; height: 191

        onRunningChanged: {
            if(running) {
                waterDripAnimation.run = false
                waterRunAnimation.run = false
            }
        }

        run: false

        name: "bucket_run"

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

        x: 494; y: 107; z: 2
        width: 65; height: 191

        run: false
        name: "bucket_fill"

        paused: !visible || scene.paused

        defaultFrameDelay: 500

        source: App.getAsset("sprites/water/bucket_fill/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5],
                to: { "full":1 }
            },
            {
                name: "full",
                frames: [5]
            }
        ]

        onSequenceChanged: {
            if(!sequence)
                return

            if(sequence.name === "full") {

                faucetHandle.state = "off"

                var bucket = game.getObject("bucket_patched")
                bucket.locked = false
                var object = {
                    name: "bucket_full",
                    type: "Object",
                    x: bucket.x,
                    y: bucket.y,
                    z: bucket.z,
                    sounds: bucket.sounds,
                    soundMap: bucket.soundMap,
                    description: "The bucket is patched. No holes!",
                    itemSource: App.getAsset("sprites/bucket/bucket_full.png")
                }

                game.spawnObject(object,function(o){
                    game.inventory.addAnimated(o)
                    blacklistObject(bucket.name)
                    destroyObject(bucket.name)
                    scene.bucketPatched = true
                })

                setText("A bucket full of water. It's pretty heavy!")
            }
        }
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
        name: "run"

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

        state: "off"

        onClicked: {
            state === "off" ? state = "on" : state = "off"
            core.sounds.play("squeak")
        }

        onStateChanged: resolveState()

        function resolveState() {
            if(state === "on") {
                core.sounds.play("water_run_loop",core.sounds.infinite)
                waterRunAnimation.run = true
            } else {
                core.sounds.stop("water_run_loop")
                waterDripAnimation.run = true
            }
            resolveBucketState()
        }

        onReadyChanged: resolveState()
    }


    Area {
        id: fliesAndLight

        name: "light"

        x: 52; y: 104
        width: 112; height: 54

        onClicked: game.setText("The flourescent lights humms faintly - casting a grim light in the room...","Some flies are having a party here as well")
    }

    Object {
        x: 800; y: 446

        draggable: false
        autoInventory: false

        name: "parasol_base"

        Behavior on x {
            id: parasolBaseXBehaviour
            NumberAnimation { duration: 1400 }
        }

        onStateChanged: {
            if(state === "over") {
                x = 800
            } else {
                x = 800 - width
            }
        }

        onClicked: {
            if(!parasolBaseXBehaviour.animation.running) {
                core.sounds.play("heavy_drag")
                state === "over" ? state = "moved" : state = "over"
            }
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

        clickable: true
        visible: true
        name: "hatch"

        state: "closed"

        onStateChanged: {
            setActiveSequence(state)
        }

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
            if(!sequence)
                return

            if(sequence.name === "open" || sequence.name === "open then close")
                core.sounds.play("hatch_open")
            if(sequence.name === "closed")
                core.sounds.play("hatch_close")

            if(sequence.name !== state)
                state = sequence.name

            if(sequence.name === "open")
                showExit()
        }

        onClicked: {
            if(state === "open")
                game.goToScene("1")
        }
    }

    Image {
        id: darkness
        z: aSwitch.z - 1
        visible: !aSwitch.active
        anchors { fill: parent }

        fillMode: Image.PreserveAspectFit
        source: App.getAsset("scenes/0_darkness.png")

        MouseArea {
            enabled: parent.visible
            anchors { fill: parent }
            onClicked: game.setText("It's too dark to do anything. Better find some light somewhere")
        }
    }

    Switch {
        id: aSwitch
        z: active ? 0 : 10
        x: 1000; y: 303

        name: "switch"

        onActiveChanged: {
            core.sounds.play("switch")
            if(active) {
                game.setText("Lights on")
                core.sounds.play("light_on")
                showExit()
            } else
                game.setText("Lights out")
        }

        onSource: App.getAsset("sprites/buttons/button_01/button_01_down.png")
        offSource: App.getAsset("sprites/buttons/button_01/button_01_up.png")
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
        var o = game.getObject("bucket")
        if(!o)
            o = game.getObject("bucket_patched")

        if(o && o.at === "faucet" && faucetHandle.state === "on") {
            waterBucketRunAnimation.run = true
            if(o.name === "bucket_patched") {
                waterBucketFillAnimation.restart()
                o.locked = true
            } else {
                if(!bucketPatched)
                    game.setText("There's a hole in the bucket. You need to patch the bucket somehow")
            }
        }

    }

    onObjectReady: {
        if(object.name === "bucket" && !object.inInventory)
            resolveBucketState()
    }

    onObjectDropped: {
        if(object.name === "bucket" || object.name === "bucket_patched") {
            faucetHandle.resolveState()

        }
    }

    onObjectTravelingToInventory: {
        if(object.name === "bucket" || object.name === "bucket_patched") {
            faucetHandle.state = "off"
        }
    }

    onObjectDragged: {
        if(object.name === "bucket" || object.name === "bucket_patched") {
            faucetHandle.resolveState()
        }
    }

    onObjectReturned: {
        if((object.name === "bucket" || object.name === "bucket_patched") && object.at === "faucet") {
            faucetHandle.resolveState()
        }
    }

    onObjectAddedToInventory: {
        if(object.name === "bucket" || object.name === "bucket_patched") {
            faucetHandle.resolveState()

            object.dump()
        }
    }

    onObjectRemovedFromInventory: {
        if(object.name === "bucket" || object.name === "bucket_patched") {
            faucetHandle.resolveState()
        }
    }



}
