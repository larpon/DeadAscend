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

    }

    Component.onCompleted: {
        store.load()

        if(!aSwitch.active)
            game.setText('The room is pitch dark. You\'re likely to get eaten by a zombie. You better find some light somewhere.','TIP: There\'s a switch in here somewhere')
        else
            game.showExit(600,124,4000,'up')
    }

    Component.onDestruction: store.save()

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

    ImageAnimation {

        x: 75; y: 328
        width: 27; height: 85

        property string name: 'drip'

        paused: (scene.paused)

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

    ImageAnimation {

        id: rope_dangle

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'rope_dangle'

        visible: true
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
    }

    ImageAnimation {

        id: rope_dangle_bucket

        x: 494; y: 107
        width: 65; height: 191

        visible: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/rope/dangle_bucket/0001.png")

        defaultFrameDelay: 150

        property string name: 'rope_dangle_bucket'

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

    ImageAnimation {

        id: rope_dangle_water

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'rope_dangle_water'

        visible: !rope_dangle.visible && !rope_dangle_bucket.visible
        paused: !visible || (scene.paused)

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

    ImageAnimation {

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'bucket_run'

        paused: (scene.paused)

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

    ImageAnimation {

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'bucket_fill'

        paused: (scene.paused)

        defaultFrameDelay: 500

        source: App.getAsset("sprites/water/bucket_fill/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5]
            }
        ]
    }

    ImageAnimation { // TODO

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'pool'

        paused: (scene.paused)

        defaultFrameDelay: 500

        source: App.getAsset("sprites/water/pool/0001.png")

        sequences: [
            {
                name: "run",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
            }
        ]
    }

    ImageAnimation {

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'run'

        paused: (scene.paused)

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

    MouseArea {
        id: fliesAndLight

        property string name: 'light'

        x: 52; y: 104
        width: 112; height: 54

        onClicked: game.setText('The flourescent lights humms faintly - casting a grim light in the room...','Some flies are having a party here as well')
    }

    MouseArea {
        x: 189; y: 180
        width: 95; height: 124

        property string name: 'crack'

        onClicked: game.setText('Just another crack in the wall..')
    }

    RoundMouseArea {
        x: 857; y: 134
        width: 100; height: 149

        property string name: 'crack2'

        onClicked: game.setText('A crack in the wall reveals the bare bricks. Something must have hit it hard')
    }

    MouseArea {
        x: 268; y: 266
        width: 123; height: 125

        property string name: 'woodenPlanks'

        onClicked: game.setText('Some wooden planks')
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

    ImageAnimation {

        x: 494; y: 107
        width: 65; height: 191

        property string name: 'hatch'

        paused: (scene.paused)

        defaultFrameDelay: 150

        source: App.getAsset("sprites/hatch/open/0001.png")

        sequences: [
            {
                name: "open",
                frames: [1,2,3,4,5,6],
                to: { "close":1}
            },
            {
                name: "close",
                frames: [1,2,3,4,5,6],
                to: { "open":1},
                reverse: true
            }
        ]
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

        property string name: 'switch'

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

    DropArea {
        x: 60; y: 325
        width: 95; height: 97
        keys: [ "bucket" ]
        onDropped: {
            drop.accept()
            var o = drag.source

            o.removeFromInventory()
            o.x = x
            o.y = y+10
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
