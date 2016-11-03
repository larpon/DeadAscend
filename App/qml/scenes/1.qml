import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

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
        game.showExit(600,150,2000,'up')
        game.showExit(400,550,2100,'up')
    }

    MouseArea {
        anchors { fill: parent }
        onClicked: {
            var a = [
                'Test'
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        x: 0; y: 0
        width: 10; height: 10

        name: 'chandelier'

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
