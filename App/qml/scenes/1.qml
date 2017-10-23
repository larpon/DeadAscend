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
        name: "level"+sceneName
    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = sounds
        //sfx.add("level"+sceneName,"switch",App.getAsset("sounds/lamp_switch_01.wav"))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(600,150,2000,"up")
        game.showExit(400,550,2100,"up")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                qsTr("Interesting surface"),
                qsTr("Not interesting"),
                qsTr("Not of any use"),
                qsTr("The room is very cold"),
                qsTr("Where is everybody?"),
                qsTr("There's sounds of mumbling zombies"),
                qsTr("Did you hear that?")
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        x: 0; y: 0
        width: 10; height: 10

        name: "chandelier"

        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/chandelier/swing/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "dangle",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                to: { "rdangle":1}
            },
            {
                name: "rdangle",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16],
                to: { "dangle":1},
                reverse: true
            }
        ]

    }

    Area {
        x: 50; y: 275
        width: 61; height: 54

        name: "exit_down"

        onClicked: game.goToScene("0")
    }

    Area {
        x: 0; y: 0
        width: 10; height: 10

        name: "exit_up"

        onClicked: {
            if(isLadderBuilt())
                game.goToScene("2")
            else
                game.setText(qsTr("Need something to reach the hole in the ceiling"))
        }
    }

    Area {
        id: ladderDrop
        x: 0; y: 0
        width: 10; height: 10

        name: "ladder_drop"

        DropSpot {
            x: 60; y: 325
            width: 95; height: 97
            keys: [ "rail_1" , "rail_2", "rung_1", "rung_2", "rung_3", "rung_4", "rung_5", "rung_6" ]

            name: "ladder_drop"

            onDropped: {
                //drop.accept()

                var o = drag.source

                var so
                if(o.name === "rail_1" || o.name === "rail_2") {
                    so = game.getObject("assembled_"+o.name)
                    so.state = "up"
                    sounds.play("move")
                    blacklistObject(o.name)
                } else { // The rungs

                    var ar1 = game.getObject("assembled_rail_1")
                    var ar2 = game.getObject("assembled_rail_2")

                    if(ar1.state === "up" && ar2.state === "up") {
                        so = game.getObject("assembled_"+o.name)
                        so.state = "up"
                        sounds.play("move")
                        blacklistObject(o.name)
                        game.setText(qsTr("Another rung in the rail!"))
                    } else {

                        if((ar1.state === "up" && ar2.state !== "up") || (ar1.state !== "up" && ar2.state === "up")) {
                            game.setText(qsTr("One more rail should be put up. I think"))
                        } else
                            game.setText(qsTr("This could work if there was something to attach to"))
                    }
                }

                if(isLadderBuilt()) {
                    game.showExit(600,150,2000,"up")
                    game.setText(qsTr("YES! Finally we can proceed upwards"))
                }

            }
        }

        onClicked: {
            if(isLadderBuilt()) {
                game.goToScene("2")
                sounds.play("move")
            }
        }

    }

    function isLadderBuilt() {
        var ar1 = game.getObject("assembled_rail_1")
        var ar2 = game.getObject("assembled_rail_2")
        var r1 = game.getObject("assembled_rung_1")
        var r2 = game.getObject("assembled_rung_2")
        var r3 = game.getObject("assembled_rung_3")
        var r4 = game.getObject("assembled_rung_4")
        var r5 = game.getObject("assembled_rung_5")
        var r6 = game.getObject("assembled_rung_5")
        var all = [ar1,ar2,r1,r2,r3,r4,r5,r6]
        var allTrue = false
        if(ar1 && ar2 && r1 && r2 && r3 && r4 && r5 && r6) {
            for(var i in all) {
                var e = all[i]

                allTrue = e.state === "up"

                if(!allTrue)
                    return false
            }
        }
        return allTrue
    }

    Object {
        x: 0; y: 0; z: visible ? 2 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rail_1"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }

    Object {
        x: 0; y: 0; z: visible ? 4 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rail_2"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }

    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_1"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }

    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_2"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }

    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_3"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }
    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_4"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }
    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_5"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
    }
    Object {
        x: 0; y: 0; z: visible ? 3 : -3

        visible: state === "up"

        clickable: false
        draggable: false
        autoInventory: false

        name: "assembled_rung_6"
        itemSource: App.getAsset("sprites/ladder/"+name+".png")
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
