import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded && elevatorDoor.ready

    paused: core.paused || miniGamePaused

    onReadyChanged: {

        if(game.helpCalled && !store.miniGameCompleted) {
            miniGameMode = true
            //elevatorDoor.setActiveSequence('close')
            game.setText(" "," ",qsTr("..."),qsTr("Something is wrong"),qsTr("I can feel it"),qsTr("I can hear zombies"),qsTr("A lot of zombies!"))
        }

        elevatorDoor.setActiveSequence('close')
    }

    anchors { fill: parent }

    property bool miniGameMode: false
    property bool miniGamePaused: false
    property int miniGameZombiesKilled: 0

    onMiniGameZombiesKilledChanged: {
        if(miniGameZombiesKilled == 1)
            setText(qsTr("HA! First blood!"))
        if(miniGameZombiesKilled == 10)
            setText(qsTr("Right on!"))
        if(miniGameZombiesKilled == 20)
            setText(qsTr("BOOM baby!"))
        if(miniGameZombiesKilled == 40)
            setText(qsTr("Out of my way!"))
        if(miniGameZombiesKilled == 60)
            setText(qsTr("Oh my..."),qsTr("They keep showing up!"))
        if(miniGameZombiesKilled == 100) {
            miniGameMode = false
            store.miniGameCompleted = true
            setText(qsTr("Take that you creep!"))
        }
    }

    Timer {
        running: store.miniGameCompleted
        interval: 1000
        onTriggered: {
            setText(qsTr("I can hear the chopper in the distance!"))
        }
    }

    Timer {
        id: sendChopperTimer
        running: store.miniGameCompleted
        interval: 4000
        onTriggered: {
            chopperAnimation.start()
            sounds.play("chopper_loop",sounds.infinite)
        }
    }

    Store {
        id: store
        name: "level"+sceneName

        property bool miniGameCompleted: false
    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = sounds
        sfx.add("level"+sceneName,"shotgun",App.getAsset("sounds/shotgun_shot_01.wav"))
        sfx.add("level"+sceneName,"shotgun_load_1",App.getAsset("sounds/shotgun_load_01.wav"))
        sfx.add("level"+sceneName,"shotgun_load_2",App.getAsset("sounds/shotgun_load_02.wav"))
        sfx.add("level"+sceneName,"shotgun_load_3",App.getAsset("sounds/shotgun_load_03.wav"))
        sfx.add("level"+sceneName,"zombie_moan_1",App.getAsset("sounds/zombie_moan_01.wav"))
        sfx.add("level"+sceneName,"zombie_moan_2",App.getAsset("sounds/zombie_moan_02.wav"))
        sfx.add("level"+sceneName,"zombie_moan_3",App.getAsset("sounds/zombie_moan_03.wav"))
        sfx.add("level"+sceneName,"chopper_loop",App.getAsset("sounds/chopper.wav"))

    }

    Component.onDestruction: {
        store.save()

        for(var zid in zombies) {
            zombies[zid].destroy()
        }
    }

    function showExit() {
        game.showExit(515,300,2000,"down")
    }


    // MINI GAME
    property var zombies: ({})
    property int nextZid: 0
    onMiniGameModeChanged: {
        if(miniGameMode) {
            zombieSpawnTimer.start()
        } else
            zombieSpawnTimer.stop()
    }

    Timer {
        id: zombieSpawnTimer
        repeat: true
        interval: 4000
        onTriggered: {

            if(scene.paused)
                return

            nextZid++

            var attrs = {
                x: scene.halfWidth-100,
                y: scene.halfHeight+100,
                zid: nextZid,
                type: "0"+Aid.randomRangeInt(1,4)
            }

            game.incubator.now(zombieComponent, zField, attrs, function(o){
                App.debug('Spawned zombie',o.zid)
                scene.zombies[o.zid] = o
            })

            // Next spawn
            interval = Aid.randomRangeInt(100,600)

            if(nextZid == 14) {
                if(game.inventory.has('shotgun')) {
                    miniGameAlert.state = "shown"
                    scene.miniGamePaused = true
                } else {
                    miniGameAlertNoGun.state = "shown"
                    scene.miniGamePaused = true
                }
            }
        }
    }

    Component {
        id: zombieComponent
        Entity {
            id: tt
            width: 1; height: 1
            property string zid: ""
            property string type: "00"
            z: y > 450 ? y : -3-parseInt(zid)

            signal died()

            paused: scene.paused

            onDied: {
                scene.miniGameZombiesKilled++
                tt.z = -900
            }

            ImageAnimation {
                id: zwalk
                x: 0.5; y: -height
                //anchors.centerIn: parent
                running: true
                visible: running
                paused: !visible || scene.paused

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        sounds.play('shotgun')
                        sounds.play("zombie_moan_3")
                        var m = zwalk.mapToItem(scene,mouse.x,mouse.y)
                        bloodSplat.x = m.x - bloodSplat.halfWidth
                        bloodSplat.y = m.y - bloodSplat.halfHeight
                        bloodSplat.jumpTo('pulse')
                        tt.mover.stop()
                        if(tt.type === "02" || tt.type === "04" )
                            zdie.x = -zwalk.halfWidth
                        zwalk.running = false
                    }
                }
            }

            ImageAnimation {
                id: zdie
                x: 0.5; y: -height
                //anchors.centerIn: parent
                visible: !zwalk.animating
                paused: !visible || scene.paused
                onSequenceNameChanged: {
                    if(sequenceName === "dead")
                        tt.died()
                }
            }

            Component.onCompleted:  {
                var wseqs = []
                var dseqs = []
                if(type === "01") {
                    wseqs.push({
                        name: "walk",
                        frames: [1,2,3,4,5,6,7,8,9,10],
                        to: { "walk":1}
                    })

                    dseqs.push({
                        name: "die",
                        frames: [1,2,3,4,5],
                        to: { "dead":1}
                    })
                    dseqs.push({
                        name: "dead",
                        frames: [5]
                    })
                    zwalk.width = 146
                    zwalk.height = 249
                    zdie.width = 222
                    zdie.height = 242
                }
                if(type === "02") {
                    wseqs.push({
                        name: "walk",
                        frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                        to: { "walk":1}
                    })

                    dseqs.push({
                        name: "die",
                        frames: [1,2,3,4,5,6,7],
                        to: { "dead":1}
                    })
                    dseqs.push({
                        name: "dead",
                        frames: [7]
                    })
                    zwalk.width = 137
                    zwalk.height = 313
                    zdie.width = 265
                    zdie.height = 316
                }
                if(type === "03") {
                    wseqs.push({
                        name: "walk",
                        frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                        to: { "walk":1}
                    })

                    dseqs.push({
                        name: "die",
                        frames: [1,2,3,4,5],
                        to: { "dead":1}
                    })
                    dseqs.push({
                        name: "dead",
                        frames: [5]
                    })
                    zwalk.width = 150
                    zwalk.height = 210
                    zdie.width = 208
                    zdie.height = 160
                }
                if(type === "04") {
                    wseqs.push({
                        name: "walk",
                        frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],
                        to: { "walk":1}
                    })

                    dseqs.push({
                        name: "die",
                        frames: [1,2,3,4,5,6,7],
                        to: { "dead":1}
                    })
                    dseqs.push({
                        name: "dead",
                        frames: [7]
                    })
                    zwalk.width = 113
                    zwalk.height = 285
                    zdie.width = 210
                    zdie.height = 271
                }
                zwalk.sequences = wseqs
                zwalk.source = App.getAsset("sprites/zombies/attack_zombies/"+type+"/walk/0001.png")
                zwalk.defaultFrameDelay = 140
                zwalk.setActiveSequence('walk')

                zdie.sequences = dseqs
                zdie.source = App.getAsset("sprites/zombies/attack_zombies/"+type+"/headless_fall/0001.png")
                zdie.defaultFrameDelay = 140

                var sp = { x: tt.x, y: tt.y }
                var l = !!Math.floor(Math.random() * 2) // NOTE Random bool
                var xm = 0, ym = 0
                for(var i = 0; i <= 10; i++) {



                    if(i == 0) {
                        xm = l ? -180 : 200
                        ym = Aid.randomRangeInt(5,10)
                    } else if(i == 1) {
                        xm += l ? Aid.randomRangeInt(-100,-90) : Aid.randomRangeInt(200,230)
                        ym += Aid.randomRangeInt(5,10)
                    } else {
                        xm += l ? Aid.randomRangeInt(-10,180) : Aid.randomRangeInt(-180,10)
                        ym += Aid.randomRangeInt(100,200)
                    }

                    tt.mover.pushMove(sp.x+xm,sp.y+ym)
                }
                tt.mover.duration = 60000
                tt.mover.startMoving()

            }

        }
    }

    /*
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
    }*/

    Item {
        id: zField
        anchors { fill: parent }

        Area {
            z: -2
            stateless: true

            name: "casing_inside"

        }

        Area {
            z: -1
            stateless: true

            name: "casing"
        }

        Area {
            id: sateliteDish
            name: "satelite_dish"
            stateless: true

            description: qsTr("That's definitely the antenna dish for the radio")

        }

        Area {
            id: sateliteBox
            name: "satelite_box"
            stateless: true

            description: [ qsTr("The box has a socket. It could be something like an external power supply for the antenna"), qsTr("Maybe to give it extra range?") ]
        }

        Area {
            id: sateliteFuelCell
            name: "satelite_fuel_cell"
            stateless: true
            visible: game.fuelCellConnected
            description: [ qsTr("The fuel cell is connected"), qsTr("This should give the radio some extra range") ]
        }


        DropSpot {
            x: sateliteDish.x; y: sateliteDish.y
            width: sateliteFuelCell.x + sateliteFuelCell.width - sateliteDish.x
            height: sateliteFuelCell.y + sateliteFuelCell.height - sateliteDish.y

            keys: [ "fuel_cell" ]

            name: "antenna_drop"

            enabled: !game.fuelCellConnected

            onDropped: {

                sounds.play("tick")

                if(game.fuelCellCharged) {
                    game.fuelCellConnected = true

                    drop.accept()
                    var o = drag.source

                    game.blacklistObject(o.name)
                    game.setText(qsTr("Good work survivour. The antenna is now powered. This should give some extra range"))

                } else {
                    game.setText(qsTr("The fuel cell is out of power. It'll be hard to get it charged under these circumstances"))
                }

            }

        }

        AnimatedArea {

            id: elevatorDoor

            name: "elevator_door_8"

            clickable: !animating
            stateless: true

            visible: true
            run: false
            paused: !visible || (scene.paused)

            source: App.getAsset("sprites/elevator_assets/doors/floor_8/move/0001.png")

            defaultFrameDelay: 100

            sequences: [
                {
                    name: "closed",
                    frames: [1]
                },
                {
                    name: "open",
                    frames: [1,2,3,4,5,6],
                    to: { "opened":1 }
                },
                {
                    name: "open-show-panel",
                    frames: [1,2,3,4,5,6],
                    to: { "opened":1 }
                },
                {
                    name: "close",
                    frames: [1,2,3,4,5,6],
                    reverse: true,
                    to: { "closed":1 }
                },
                {
                    name: "opened-wait-close",
                    frames: [6],
                    reverse: true,
                    to: { "close":1 },
                    duration: 1000
                },
                {
                    name: "opened",
                    frames: [6]
                },
            ]

            onClicked: {
                setActiveSequence("open-show-panel")
                sounds.play("ding")
            }

            onFrame: {
                App.debug(sequenceName, frame )
                if(sequenceName === "open-show-panel" && frame == 4) {
                    game.elevatorPanel.show = true
                    sounds.play("elevator_open")
                }
                if(sequenceName === "close" && frame == 1) {
                    sounds.play("elevator_close")
                }
            }
        }

    }

    SequentialAnimation {
        id: chopperAnimation
        running: false

        NumberAnimation {
            target: chopperRope
            property: "x"
            duration: 6200
            to: scene.width*0.75
        }

        ScriptAction {
            script: {
                game.showExit(750,100,10000,"up")
            }
        }

    }

    SequentialAnimation {
        running: chopperRope.visible
        loops: Animation.Infinite
        NumberAnimation {
            target: chopperRope
            property: "y"
            duration: 2200
            to: -20
        }
        NumberAnimation {
            target: chopperRope
            property: "y"
            duration: 2200
            to: -5
        }
    }

    AnimatedArea {
        id: chopperRope
        name: "rope_dangle_chopper"

        x: -2*width; y: -10
        width: 65; height: 176

        stateless: true
        clickable: true
        visible: store.miniGameCompleted
        run: visible
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/rope/window_dangle/01/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "dangle",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],
                to: { "out": 1 }
            },
            {
                name: "out",
                frames: [18,17,16,15,16,17,18,19],
                to: { "back": 1 }
            },
            {
                name: "back",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],
                reverse: true,
                to: { "dangle": 1 }
            }
        ]

        onClicked: {
            //game.goToScene("end")
            game.setText(qsTr("The end!"))
            core.modes.set("end-credits")
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


    AnimatedArea {
        id: bloodSplat
        width: 250; height: 250

        clickable: false

        visible: animating
        run: false
        paused: (scene.paused)

        source: App.getAsset("sprites/blood/splat/0001.png")

        defaultFrameDelay: 20

        sequences: [
            {
                name: "pulse",
                frames: [7,8,9,7,6,5,4,3,2,1]
            }
        ]
    }


    ConfirmDialog {
        id: miniGameAlert
        anchors { centerIn: parent }

        text: qsTr("The zombies are coming!<br>Furtunately you have your shotgun!<br><br>Tab on the zombies to shot them<br> - SHOOT THEM ALL -")
        acceptText: qsTr("SUCK ON THIS!")
        rejectText: qsTr("EAT LEAD!")

        onAccepted: scene.miniGamePaused = false
        onRejected: scene.miniGamePaused = false
    }

    ConfirmDialog {
        id: miniGameAlertNoGun
        anchors { centerIn: parent }

        text: qsTr("A horde of zombies are coming!<br>You'll need something to protect yourself!<br>See if you can find something in the tower!")
        acceptText: qsTr("YES - OK")
        rejectText: qsTr("YES!")

        onAccepted: { scene.miniGamePaused = false; game.goToScene("7") }
        onRejected: { scene.miniGamePaused = false; game.goToScene("7") }
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
