import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded && lift.balanced

    anchors { fill: parent }

    readonly property string type: game.scene2type
    property bool fuseDropped: false
    property bool cabinetOpened: false
    property bool emptyCannulaTaken: false
    property int coinsUsed: 0

    Store {
        id: store
        name: "level"+sceneNumber

        property alias fuseDropped: scene.fuseDropped
        property alias cabinetOpened: scene.cabinetOpened
        property alias emptyCannulaTaken: scene.emptyCannulaTaken
        property alias coinsUsed: scene.coinsUsed
    }


    Component {
        id: objectComponent
        Object {

        }
    }

    Component.onCompleted: {
        store.load()

        if(!emptyCannulaTaken) {
            var object = {
                name: "cannula",
                x: 160,
                y: 300,
                itemSource: App.getAsset("sprites/cannula/cannula_empty.png"),
                description: "An empty cannula. Not very helpful when empty...",
                at: sceneNumber

            }

            incubator.now(objectComponent, cannulaSpawn, object, function(o){})

        }

        showExit()

        var sfx = core.sounds
        //sfx.add("level"+sceneNumber,"lift_motor",App.getAsset("sounds/lift_motor_01.wav"))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        if(type == "right") {
            game.showExit(600,0,2000,"up")
            game.showExit(700,550,2100,"down")
        }

        if(type == "left") {
            game.showExit(150,210,2100,"down")
        }
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                "Not very interesting",
                "Not of any use",
                "It's cold in here",
                "I wonder where everybody is?",
                "There's faint sounds of mumbling zombies"
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    // RIGHT SIDE


    AnimatedArea {

        name: "rope_dangle_window"

        stateless: true
        clickable: true
        visible: type === "left"
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
            game.goToScene("7")
            game.scene2type = "right"
        }

    }


    Item {
        x: 110; y: 50; z: 1

        visible: hasFlypaper()

        function hasFlypaper() {
            var fp = game.getObject('flypaper')
            return (fp !== undefined && !game.isBlacklisted('flypaper') && fp.scene === "2")
        }

        ImageAnimation {

            x: 1; y: 5
            width: 17; height: 15

            paused: !visible || (scene.paused)

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

            x: 12; y: 6
            width: 21; height: 5

            paused: !visible || (scene.paused)

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

            x: 0; y: 0
            width: 17; height: 13

            paused: !visible || (scene.paused)

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

            x: 12; y: 16
            width: 21; height: 5

            paused: !visible || (scene.paused)

            source: App.getAsset("sprites/flies/cycle_2/0001.png")

            defaultFrameDelay: 100

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

            x: 0; y: 6
            width: 17; height: 13

            paused: !visible || (scene.paused)

            source: App.getAsset("sprites/flies/cycle_1/0001.png")

            defaultFrameDelay: 140

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



    }


    // LEFT SIDE

    AnimatedArea {
        id: lift
        x: 0; y: 0
        width: 10; height: 10

        name: "lift"

        clickable: true
        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/lift/operate_1/0001.png")

        defaultFrameDelay: 150

        readonly property bool isUp: state === "up"
        property bool changeLevel: false

        state: "down"
        onSequenceChanged: {
            if(!sequence)
                return
            state = sequence.name
        }


        sequences: [
            {
                name: "down",
                frames: [1]
            },
            {
                name: "up",
                frames: [12]
            },
            {
                name: "go_up",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "up":1 }
            },
            {
                name: "go_down",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "down":1 },
                reverse: true
            }
        ]

        onFrame: {
            if(!fuseDropped)
                return
            if(sequenceName === "up" && frame === 12 && changeLevel) {
                changeLevel = false
                game.goToScene("3")
            }

        }

        function up() {
            if(!fuseDropped) {
                game.setText("It seems like it need a fuse to work")
                return
            }
            core.sounds.play("lift_motor")
            changeLevel = true
            game.setText("Going up!")
            setActiveSequence("go_up")
        }

        function down() {
            if(!fuseDropped) {
                game.setText("It seems like it need a fuse to work")
                return
            }
            core.sounds.play("lift_motor")
            game.setText("Going down!")
            setActiveSequence("go_down")
        }

        onReadyChanged: {
            if(game.previousScene === "3") {
                setActiveSequence("go_down")
            }
        }

        onClicked: {
            if(!fuseDropped) {
                core.sounds.play("tick")
                game.setText("This lift could get you further up. But it's not working?")
                return
            }
            lift.up()
        }

    }

    Area {

        name: "exit_down"

        onClicked: game.goToScene("1")
    }

    Area {
        id: controlPanelSmall

        enabled: type === "right"

        name: "control_panel_small"

        onClicked: {
            state === "on" ? state = "off" : state = "on"
        }
    }

    Area {
        id: cabinetArea

        enabled: type === "right"

        name: "cabinet_area"

        onClicked: {
            state === "on" ? state = "off" : state = "on"
        }
    }

    Area {
        id: cabinetDoorUp

        stateless: true
        visible: !cabinetOpened

        name: "cabinet_door_up"
    }

    Area {
        id: cabinetDoorDown

        stateless: true
        visible: cabinetOpened

        name: "cabinet_door_down"
    }

    Object {
        name: "fuse_small"
        visible: fuseDropped
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
        source: App.getAsset("scenes/2_darkness_overlay_left.png")

        MouseArea {
            anchors { fill: parent }
            onClicked: game.setText("It's hard to make out what is behind the wall")
        }

    }

    Image {
        id: darknessRight
        z: 20

        anchors {
            left: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            leftMargin: -20
        }

        visible: type === "left"
        source: App.getAsset("scenes/2_darkness_overlay_right.png")

        MouseArea {
            anchors { fill: parent }
            onClicked: game.setText("The lift must be on the other side of this wall")
        }
    }

    showForegroundShadow: !panelScene.show && !cabinetScene.show

    Item {
        id: panelScene
        anchors { fill: parent }
        z: 22

        property bool show: type === "right" && controlPanelSmall.state === "on"

        visible: opacity > 0
        opacity: show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: controlPanelSmall.state = "off"
        }

        Rectangle {
            anchors { fill: parent }
            color: core.colors.black
            opacity: 0.7
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
                onClicked: controlPanelSmall.state = "off"
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/lift_panel/lift_panel.png")

            MouseArea {
                anchors { fill: parent }

            }

            DropSpot {
                x: 295; y: 42
                width: 402; height: 315
                keys: [ "fuse" ]

                name: "fuse_drop"

                enabled: !fuseDropped

                onDropped: {
                    drop.accept()

                    fuseDropped = true
                    core.sounds.play("tick_soft")
                    game.setText("It fits perfectly!")
                    var o = drag.source
                    blacklistObject(o.name)
                }
            }

            Image {
                x: 310; y: 82
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/fuse/zoom.png")
                visible: fuseDropped
                MouseArea {
                    anchors { fill: parent }
                    onClicked: game.setText("It fits perfectly in the socket!")
                }
            }

            Area {
                x: 36; y: 36
                width: 100; height: 100

                round: true
                stateless: true

                name: "lift_up"

                onClicked: {
                    core.sounds.play("tick_soft")
                    if(!fuseDropped) {
                        game.setText("It seems like it need a fuse to work")
                        return
                    }

                    if(!lift.isUp) {
                        controlPanelSmall.state = "off"
                        lift.up()
                    } else
                        game.setText("The lift is already up")

                }
            }

            Area {
                x: 34; y: 208
                width: 100; height: 100

                round: true
                stateless: true

                name: "lift_down"

                onClicked: {
                    core.sounds.play("tick_soft")
                    if(!fuseDropped) {
                        game.setText("It seems like it need a fuse to work")
                        return
                    }

                    if(lift.isUp) {
                        controlPanelSmall.state = "off"
                        lift.down()
                    } else
                        game.setText("The lift is already down")
                }
            }
        }

    }

    Item {
        id: cabinetScene
        anchors { fill: parent }
        z: 22

        property bool show: type === "right" && cabinetArea.state === "on"

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
            onClicked: cabinetArea.state = "off"
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
                onClicked: cabinetArea.state = "off"
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/medicine_cabinet/notch.png")

            Item {
                id: cannulaSpawn
                anchors { fill: parent }
            }

            Area {
                anchors { centerIn: parent }
                width: cabinetDoor.width; height: cabinetDoor.height
                stateless: true
                visible: !cabinetOpened

                description: "The cabinet door is locked. Cabinets always hold useful stuff!"

                Image {
                    id: cabinetDoor
                    anchors { centerIn: parent }
                    fillMode: Image.PreserveAspectFit
                    width: sourceSize.width; height: sourceSize.height
                    source: App.getAsset("sprites/medicine_cabinet/door.png")


                    Area {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 23
                        width: 40; height: 70
                        stateless: true

                        description: "A keyhole"

                    }

                }

                SequentialAnimation {
                    id: doorFallAnimation
                    running: false

                    ParallelAnimation {
                        NumberAnimation {
                            target: cabinetDoor
                            property: "y"
                            duration: 700
                            easing.type: Easing.InOutQuad
                            to: 2000
                        }

                        NumberAnimation {
                            target: cabinetDoorUp
                            property: "y"
                            duration: 700
                            easing.type: Easing.InOutQuad
                            to: 2000
                        }
                    }


                    ScriptAction {
                        script: {
                            cabinetOpened = true
                        }
                    }
                }
            }


            Area {

                x: 38; y: parent.halfHeight - halfHeight
                width: hinge.width; height: hinge.height
                stateless: true

                visible: coinsUsed <= 1

                description: [ "A hinge holding the door", "If there's no keys to be found - maybe this can be removed somehow" ]

                Image {
                    id: hinge

                    fillMode: Image.PreserveAspectFit
                    width: 66; height: 169
                    source: App.getAsset("sprites/medicine_cabinet/hinge.png")

                    Area {
                        x: 32; y: 18
                        width: topScrewImage.width; height: topScrewImage.height

                        visible: coinsUsed <= 0
                        stateless: true

                        description: "A mighty fine screw"

                        Image {
                            id: topScrewImage

                            fillMode: Image.PreserveAspectFit
                            width: sourceSize.width; height: sourceSize.height
                            source: App.getAsset("sprites/medicine_cabinet/screw_top.png")
                        }
                    }

                    Area {
                        x: 36; y: parent.height - 46
                        width: bottomScrewImage.width; height: bottomScrewImage.height

                        visible: coinsUsed <= 1
                        stateless: true

                        description: "A mighty fine screw"

                        Image {
                            id: bottomScrewImage
                            fillMode: Image.PreserveAspectFit
                            width: sourceSize.width; height: sourceSize.height
                            source: App.getAsset("sprites/medicine_cabinet/screw_bottom.png")

                        }
                    }

                    SequentialAnimation {
                        id: hingeFallAnimation
                        running: false
                        NumberAnimation {
                            target: hinge
                            property: "y"
                            duration: 700
                            easing.type: Easing.InOutQuad
                            to: 2000
                        }

                        ScriptAction {
                            script: {
                                doorFallAnimation.running = true
                            }
                        }
                    }

                }

                DropSpot {
                    anchors { fill: parent }
                    keys: [ "coin" ]

                    name: "coin_drop"

                    enabled: coinsUsed <= 1

                    onDropped: {

                        core.sounds.play("tick_soft")
                        game.setText("That's "+coinsUsed === 0 ? "one":"both" +" screw down!")

                        coinsUsed++

                        if(coinsUsed > 1) {
                            hingeFallAnimation.running = true
                            drop.accept()
                            var o = drag.source
                            blacklistObject(o.name)
                            game.setText("Off you go hinge!")
                        }
                    }
                }
            }


            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                source: App.getAsset("scenes/medicine_cabinet/fg_shadow.png")
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
        if(object.name === "cannula")
            scene.emptyCannulaTaken = true

        if(object.name === "charging_paper_r") {
            object.itemSource = App.getAsset("sprites/charging_paper/charging_paper_R.png")
        }

    }

    onObjectRemovedFromInventory: {
    }

}