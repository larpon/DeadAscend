import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    anchors { fill: parent }

    readonly property string type: game.scene2type

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
        z: -10
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

        name: 'lift'

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/lift/operate_1/0001.png")

        defaultFrameDelay: 150

        sequences: [
            {
                name: "up",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12]
            },
            {
                name: "down",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                reverse: true
            }
        ]

    }

    Area {
        x: 50; y: 275
        width: 61; height: 54

        name: "exit_down"

        onClicked: game.goToScene("1")
    }

    Area {
        x: 0; y: 0
        width: 10; height: 10

        name: "exit_up"

        onClicked: {
            /*
            if(isLadderBuilt())
                game.goToScene("2")
            else
                game.setText("Need something to reach the hole in the ceiling")
                */
        }
    }

    Image {
        id: darknessLeft
        z: 20

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: parent.horizontalCenter
            rightMargin: -40
        }

        visible: type === "right"
        source: App.getAsset('scenes/2_darkness_overlay_left.png')

    }

    Image {
        id: darknessRight
        visible: type === "left"
        source: App.getAsset('scenes/2_darkness_overlay_right.png')
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
