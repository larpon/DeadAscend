import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded && hamster.ready && cageSmash.ready

    onReadyChanged: {

        if(cageHit) {
            hamster.setActiveSequence("cs-hide")
            cageSmash.setActiveSequence("smashed")
        }

        if(hamsterIsZombie)
            hamster.running = false

    }

    anchors { fill: parent }

    property bool zombieHit: false
    property bool cageHit: false
    property bool hamsterCalm: false
    property bool hamsterIsZombie: false

    Store {
        id: store
        name: "level"+sceneName

        property alias zombieHit: scene.zombieHit
        property alias cageHit: scene.cageHit
        property alias hamsterCalm: scene.hamsterCalm
        property alias hamsterIsZombie: scene.hamsterIsZombie

    }


    Connections {
        target: sounds
        onLoaded: {
            if(tag === "hum")
                sounds.play("hum",sounds.infinite)
        }
    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = sounds
        sfx.add("level"+sceneName,"hum",App.getAsset("sounds/low_machine_hum.wav"))
        sfx.add("level"+sceneName,"scribble",App.getAsset("sounds/scribble.wav"))
        sfx.add("level"+sceneName,"zombie_moan_1",App.getAsset("sounds/zombie_moan_01.wav"))
        sfx.add("level"+sceneName,"zombie_moan_2",App.getAsset("sounds/zombie_moan_02.wav"))
        sfx.add("level"+sceneName,"zombie_moan_3",App.getAsset("sounds/zombie_moan_03.wav"))
        sfx.add("level"+sceneName,"crack_smash",App.getAsset("sounds/crack_smash.wav"))
        sfx.add("level"+sceneName,"glass_smash",App.getAsset("sounds/glass_smash.wav"))
        sfx.add("level"+sceneName,"coin_drop",App.getAsset("sounds/coin_drop.wav"))
        sfx.add("level"+sceneName,"paper_fiddle",App.getAsset("sounds/paper_fiddle.wav"))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(600,100,2000,"down")
        game.showExit(400,10,2100,"up")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                qsTr("Nah. Not really interesting"),
                qsTr("Not of any use"),
                qsTr("It's actually a bit warm in here"),
                qsTr("The machines are humming quite a lot")
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: zombieSitting

        clickable: run
        name: "zombie_sitting"

        stateless: true

        run: !zombieHit
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/zombies/sitting_zombie/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "tick1s",
                frames: [1],
                to: { "tick1s":1, "tick1": 1 },
                duration: 2000
            },
            {
                name: "tick1",
                frames: [1,2,3,4,5,4,3,2,1],
                to: { "tick1s":1, "tick2s": 1 }
            },
            {
                name: "tick2s",
                frames: [6],
                to: { "tick2s":1, "tick2": 1, "tick1":1 },
                duration: 2000
            },
            {
                name: "tick2",
                frames: [6,7,8,9,10,11,10,9,8,7,6],
                to: { "tick2s": 1 }
            }
        ]

        onFrame: {
            var giveSound = Aid.randomRangeInt(1,3)
            giveSound = (giveSound === 1)
            if(!giveSound)
                return

            if(frame === 5) {
                sounds.playRandom(["zombie_moan_1","zombie_moan_2"])
            }
            if(frame === 11) {
                sounds.play("zombie_moan_3")
            }
        }

        onClicked: {
            sounds.playRandom(["zombie_moan_1","zombie_moan_2"])
            game.setText(qsTr("It's passive..."),qsTr("Only a few live infected cells relieves some muscle ticks"),qsTr("You should take it out of it's missery"))
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "hammer" ]

            name: "zombie_drop"

            onDropped: {

                sounds.play("zombie_moan_2")
                sounds.play("crack_smash")
                zombieTilting.run = true
                zombieSitting.visible = false

                game.setText(qsTr("Straight in the head"))

                if(!game.getObject("coin")) {
                    var object = {
                        name: "coin",
                        type: "Object",
                        scene: sceneName,
                        description: qsTr("It's a coin. With a very matte finish"),
                        x: 190,
                        y: 300,
                        itemSource: App.getAsset("sprites/coin/coin.png")
                    }

                    game.spawnObject(object,function(o){
                        sounds.play("coin_drop")
                        o.moveTo(60,360)
                    })

                }

                if(cageHit) {
                    drop.accept()
                    var o = drag.source

                    blacklistObject(o.name)

                    game.setText(qsTr("The hammer broke in two. No need to carry that around any more"))

                }

            }
        }

    }

    AnimatedArea {

        id: zombieTilting

        clickable: false
        name: "zombie_tilting"

        stateless: true

        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/zombies/sitting_zombie/tilt/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "tilt",
                frames: [1,2,3,4,5,6,7,8]
            }
        ]

        onFrame: {
            if(frame === 8) {
                // TODO
                zombieHit = true
            }
        }

    }

    AnimatedArea {

        id: zombieTilted

        clickable: run
        name: "zombie_tilted"

        stateless: true

        run: zombieHit
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/zombies/sitting_zombie/tilt/tick/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "tick",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "wait":1 },
                duration: 100
            },
            {
                name: "wait",
                frames: [12],
                to: { "wait":1, "tick":1 },
                duration: 10000
            }

        ]

        onFrame: {
            if(frame === 1) {
                sounds.play("zombie_moan_3")
            }
        }

        onSequenceChanged: {
            if(!sequence)
                return

            if(sequence.name === "wait") {
                sequence.duration = Aid.randomRangeInt(10000,30000)
            }
        }

        onClicked: {
            game.setText(qsTr("He's dead Jim"),qsTr("... or as close as dead as zombies get"))
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "cannula" ]

            name: "zombie_tilted_drop"

            onDropped: {

                var o = drag.source

                var object = {
                    name: "cannula_full",
                    type: "Object",
                    itemSource: App.getAsset("sprites/cannula/cannula_full.png"),
                    description: qsTr("It's full of infested zombie blood"),
                    scene: sceneName
                }

                game.spawnObject(object,function(o){
                    game.inventory.add(o)
                    game.setText(qsTr("It's full of infested zombie blood now!"))
                })

                drop.accept()
                blacklistObject(o.name)
            }
        }

    }

    AnimatedArea {
        id: lift
        x: 0; y: 0
        width: 10; height: 10

        name: "lift_3"

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
                to: { "up":1 },
                reverse: true
            },
            {
                name: "down",
                frames: [6]
            },
            {
                name: "go_down",
                frames: [1,2,3,4,5,6],
                to: { "down":1 }
            }
        ]

        onFrame: {
            if(sequenceName === "down" && frame === 6 && changeLevel) {
                changeLevel = false
                game.goToScene("2")
            }

        }

        function up() {
            game.setText(qsTr("Going up!"))
            setActiveSequence("go_up")
        }

        function down() {
            sounds.play("lift_motor")
            changeLevel = true
            game.setText(qsTr("Going down!"))
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
        stateless: true

        name: "lift_panel_area"

        onClicked: lift.down()
    }

    Area {
        stateless: true
        name: "exit_up_3_1"
        onClicked: {
            game.goToScene("4")
        }
    }
    Area {
        stateless: true
        name: "exit_up_3_2"
        onClicked: {
            game.goToScene("4")
        }
    }
    Area {
        stateless: true
        name: "exit_up_3_3"
        onClicked: {
            game.goToScene("4")
        }
    }
    Area {
        stateless: true
        name: "exit_up_3_4"
        onClicked: {
            game.goToScene("4")
        }
    }

    Area {
        x: 464; y: 395; z: hamster.z - 1
        width: 28; height: 22

        visible: hamsterCalm

        itemSource: App.getAsset("sprites/grain/pile_small.png")
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
        name: "hamster"

        stateless: true

        visible: !hamsterIsZombie
        run: true
        paused: !visible || (scene.paused) || hamsterIsZombie

        source: App.getAsset("sprites/hamster/moves/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "hide", // Starting point
                frames: [1],
                to: { "peek":1, "hide": 1, "cs-hide":0 },
                duration: 1000
            },
            {
                name: "peek",
                frames: [1,2,3,4],
                to: { "peek-out":1 }
            },
            {
                name: "peek-out",
                frames: [4],
                duration: 800,
                to: { "peek-out":5, "peek-r":1, "peek-sniff": 1, "peek-bl":1 }
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
                to: { "mid-eat-pause":2, "mid-eat":1 }
            },
            {
                name: "mid-eat-pause",
                frames: [40],
                to: { "mid-eat":1 },
                duration: 2500
            },
            {
                name: "bl", // starting state for all bl
                frames: [32],
                to: { "bl":2, "bl-sniff":1, "bl-mid-bl":1, "bl-hide":1, "bl-circle":1 },
                duration: 800
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
                to: { "hide":1 }
            },
            {
                name: "bl-circle",
                frames: [80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99],
                to: { "bl":1 }
            },
            {
                name: "cs-hide", // Cage smashed Starting point
                frames: [1],
                to: { "cs-peek":1, "cs-hide": 1 },
                duration: 1000
            },
            {
                name: "cs-peek",
                frames: [1,2,3,4],
                to: { "cs-peek-r":1, "cs-peek-sniff": 1 },
                duration: 400
            },
            {
                name: "cs-peek-r",
                frames: [1,2,3,4],
                to: { "cs-hide":1 },
                reverse: true
            },
            {
                name: "cs-peek-sniff",
                frames: [5,6,7,8,9,10,11],
                to: { "cs-peek-r":1, "cs-peek-sniff": 1 }
            }
        ]

        onSequenceChanged: {
            if(!sequence)
                return
            var n = sequence.name
            if(n === "bl" || n === "peek-bl" || n === "bl-mid-bl" || n === "bl-hide")
                sounds.play("scribble")
            if(n === "bl-circle")
                sounds.play("scribble",2)
            App.debug("Hamster in sequence",sequence.name)
        }

        onClicked: {
            if(hamsterCalm) {
                game.setText(qsTr("The little critter is really calm now. Eating away"),qsTr("Unfortunately it's too small to drive the treadmill upstairs"))
            } else if(cageHit) {
                hamster.goalSequence = "cs-hide"
                game.setText(qsTr("It's scared now the glass is smashed. Maybe it can be lured out of hiding"))
            } else
                game.setText(qsTr("Such a cute little critter"))
        }

        Connections {
            target: scene
            onReadyChanged: {
                if(hamsterCalm)
                    hamster.setActiveSequence("mid-eat")

                if(hamsterIsZombie) {
                    hamster.stop()
                }
            }
        }

    }

    DropSpot {
        x: 400; y: 400
        width: 118; height: 126

        keys: [ "cannula", "cannula_full", "grain" ]

        name: "hamster_drop"

        onDropped: {
            if(cageHit) {
                var o = drag.source

                App.debug('DROPPED',o.name)

                if(!hamsterCalm && o.name === "grain") {
                    hamster.jumpTo('peek-mid')
                    hamsterCalm = true
                    drop.accept()
                    blacklistObject(o.name)
                }

                if(hamsterCalm && o.name === "cannula_full") {
                    var object = {
                        name: "zombie_hamster",
                        type: "Object",
                        x: 400,
                        y: 398,
                        z: hamster.z,
                        itemSource: App.getAsset("sprites/hamster/big_zombie.png"),
                        description: qsTr("... OK. So this is a zombie hamster. It looks pretty strong - but it's hideous"),
                        scene: sceneName
                    }
                    game.spawnObject(object,function(){
                        game.setText(qsTr("What. The..."),qsTr("..."))
                    })
                    scene.hamsterIsZombie = true
                    drop.accept()
                    blacklistObject(o.name)
                }

                if(hamsterCalm && o.name === "cannula") {
                    game.setText(qsTr("Indeed you could inject him with something..."),qsTr("But what?"))
                }

            }
        }
    }

    Area {
        id: glassCage
        x: 0; y: 0
        width: 10; height: 10

        visible: !cageHit

        name: "glass_cage"

        onClicked: {
            hamster.goalSequence = "hide"
            game.setText(qsTr("The hamster looks pretty scared"))
            sounds.play("add")
        }

        DropSpot {
            anchors { fill: parent }

            keys: [ "hammer" ]

            name: "cage_drop"

            onDropped: {

                if(zombieHit) {
                    drop.accept()
                    var o = drag.source

                    blacklistObject(o.name)

                    game.setText(qsTr("The hammer broke in two. No need to carry that around any more"))

                }

                sounds.play("glass_smash")
                cageSmash.setActiveSequence("smash")
                cageSmash.run = true
                glassCage.visible = false
                hamster.goalSequence = "cs-hide"


            }
        }
    }

    Area {
        x: 0; y: 0
        width: 10; height: 10

        clickable: false

        visible: !glassCage.visible || cageHit

        name: "glass_cage_smashed_BG"

    }

    Area {
        x: 0; y: 0
        width: 10; height: 10

        clickable: false

        visible: !glassCage.visible || cageHit

        name: "glass_cage_smashed_FG"

    }

    AnimatedArea {

        id: cageSmash

        //clickable: true
        name: "cage_smash"

        visible: running || cageHit

        stateless: true

        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/glass_cage/smash/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "smashed",
                frames: [20]
            },
            {
                name: "smash",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20],
                to: { "smashed": 1 }
            }
        ]

        onFrame: {
            if(frame === 20) {
                cageHit = true
            }
        }

    }

    Area {
        id: whiteboardArea

        name: "whiteboard_area"

        stateless: true

        onClicked: {
            state === "on" ? state = "off" : state = "on"
        }
    }

    showForegroundShadow: !whiteboardScene.show

    Item {
        id: whiteboardScene
        anchors { fill: parent }
        z: 22

        property bool show: whiteboardArea.state === "on"
        onShowChanged: sounds.play("paper_fiddle")

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
            onClicked: whiteboardArea.state = "off"
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
                onClicked: whiteboardArea.state = "off"
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/whiteboard/whiteboard.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: game.setText(qsTr("The drawing on the whiteboard is faded - but can still be made out"),qsTr("It looks like a sketch, depicting something involving a syringe and a hamster?"))
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
