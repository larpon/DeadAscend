import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded

    onReadyChanged: {
        elevatorDoor.setActiveSequence('opened-wait-close')
    }

    anchors { fill: parent }

    Store {
        id: store
        name: "level"+sceneNumber

    }

    Connections {
        target: core.sounds
        onLoaded: {
            if(tag === "hum")
                core.sounds.play("hum",core.sounds.infinite)
        }
    }

    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        sfx.add("level"+sceneNumber,"hum",App.getAsset("sounds/low_machine_hum.wav"))

    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(386,280,2000,"down")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                "Nah. Not really interesting",
                "Not of any use",
                "It's actually a bit warm in here",
                "The machines are humming quite a lot - just like downstairs"
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_5"

        clickable: !animating
        stateless: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/elevator_assets/doors/floor_5/move/0001.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "closed",
                frames: [1]
            },
            {
                name: "open",
                frames: [1,2,3,4,5],
                to: { "opened":1 }
            },
            {
                name: "open-show-panel",
                frames: [1,2,3,4,5],
                to: { "opened":1 }
            },
            {
                name: "close",
                frames: [1,2,3,4,5],
                reverse: true,
                to: { "closed":1 }
            },
            {
                name: "opened-wait-close",
                frames: [5],
                reverse: true,
                to: { "close":1 },
                duration: 1000
            },
            {
                name: "opened",
                frames: [5]
            },
        ]

        onClicked: {
            setActiveSequence("open-show-panel")
        }

        onFrame: {
            App.debug(sequenceName, frame )
            if(sequenceName === "open-show-panel" && frame == 5)
                game.elevatorPanel.show = true
        }
    }

    AnimatedArea {

        name: "vent_l"

        stateless: true

        run: true
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/ventilator/wing_1/l/1.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5],
                to: { "run-loop":1 }
            }
        ]
    }

    AnimatedArea {

        name: "vent_r"

        stateless: true

        run: true
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/ventilator/wing_1/r/1.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5],
                to: { "run-loop":1 }
            }
        ]
    }

    // Levers
    AnimatedArea {
        id: leverLL
        name: "lever_ll"

        clickable: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/levers/LL/0001.png")

        state: "up"

        sequences: [
            {
                name: "up",
                frames: [1,2,3,4],
                reverse: true
            },
            {
                name: "down",
                frames: [1,2,3,4]
            }
        ]

        onStateChanged: {
            if(state === "up" || state === "down")
                setActiveSequence(state)
        }

        onClicked: {
            state === "up" ? state = "down" : state = "up"
        }
    }

    AnimatedArea {
        id: leverLR
        name: "lever_lr"

        clickable: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/levers/LR/0001.png")

        state: "up"

        sequences: [
            {
                name: "up",
                frames: [1,2,3,4],
                reverse: true
            },
            {
                name: "down",
                frames: [1,2,3,4]
            }
        ]

        onStateChanged: {
            if(state === "up" || state === "down")
                setActiveSequence(state)
        }

        onClicked: {
            state === "up" ? state = "down" : state = "up"
        }
    }

    AnimatedArea {
        id: leverRL
        name: "lever_rl"

        clickable: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/levers/RL/0001.png")

        state: "up"

        sequences: [
            {
                name: "up",
                frames: [1,2,3,4],
                reverse: true
            },
            {
                name: "down",
                frames: [1,2,3,4]
            }
        ]

        onStateChanged: {
            if(state === "up" || state === "down")
                setActiveSequence(state)
        }

        onClicked: {
            state === "up" ? state = "down" : state = "up"
        }
    }

    AnimatedArea {
        id: leverRR
        name: "lever_rr"

        clickable: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/levers/RR/0001.png")

        state: "up"

        sequences: [
            {
                name: "up",
                frames: [1,2,3,4],
                reverse: true
            },
            {
                name: "down",
                frames: [1,2,3,4]
            }
        ]

        onStateChanged: {
            if(state === "up" || state === "down")
                setActiveSequence(state)
        }

        onClicked: {
            state === "up" ? state = "down" : state = "up"
        }
    }

    // Coils
    Area {
        id: fuelCellCharger
        name: "fuel_cell_charger"

        DropSpot {
            anchors { fill: parent }

            keys: [ "fuel_cell" ]

            name: "fuel_cell_drop"

            onDropped: {

                if(coilLightning.run) {
                    game.setText("Maybe you should turn off the machinery first")
                    return
                }

                if(game.fuelCellCharged) {
                    game.setText("It's already fully charged and ready to go")
                    return
                }

                drop.accept()

                var o = drag.source
                o.x = fuelCellCharger.x+o.halfWidth
                o.y = fuelCellCharger.y
            }
        }

    }




    AnimatedArea {

        name: "coil_bl"

        stateless: true

        visible: run
        run: game.flasksCorrect && leverLL.state === "down"
        paused: !visible || (scene.paused)

        defaultFrameDelay: 100

        source: App.getAsset("sprites/coils/bl/0001.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "run-loop":1 }
            }
        ]
    }

    AnimatedArea {

        name: "coil_br"

        stateless: true

        visible: run
        run: game.flasksCorrect && leverRR.state === "down"
        paused: !visible || (scene.paused)

        defaultFrameDelay: 150

        source: App.getAsset("sprites/coils/br/0001.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "run-loop":1 }
            }
        ]
    }

    AnimatedArea {

        name: "coil_tr"

        stateless: true

        visible: run
        run: game.flasksCorrect && leverRL.state === "down"
        paused: !visible || (scene.paused)

        defaultFrameDelay: 120

        source: App.getAsset("sprites/coils/tr/0001.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "run-loop":1 }
            }
        ]
    }

    AnimatedArea {

        name: "coil_tl"

        stateless: true

        visible: run
        run: game.flasksCorrect && leverLR.state === "down"
        paused: !visible || (scene.paused)

        defaultFrameDelay: 90

        source: App.getAsset("sprites/coils/tl/0001.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "run-loop":1 }
            }
        ]
    }

    AnimatedArea {
        id: coilLightning
        name: "coil_lightning"

        stateless: true

        opacity: run ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        visible: opacity > 0
        run: game.flasksCorrect && leverLR.state === "down" && leverLL.state === "down" && leverRL.state === "down" && leverRR.state === "down"
        paused: !visible || (scene.paused)

        defaultFrameDelay: 90

        source: App.getAsset("sprites/coils/lightning/0001.png")

        sequences: [
            {
                name: "run-loop",
                frames: [1,2,3,4,5,6,7,8,9,10,11,12],
                to: { "run-loop":1 }
            }
        ]

        onRunChanged: {
            if(run && !game.fuelCellCharged) {
                var fc = game.getObject('fuel_cell')
                if(fc && fc.at === "fuel_cell_drop") {
                    fc.z = -1
                    game.setText("It's charging...","...","...")
                    giveFuelCellBackTimer.start()
                }
            }

            if(run && game.fuelCellCharged) {
                var fc = game.getObject('fuel_cell')
                if(fc && fc.at === "fuel_cell_drop") {
                    fc.z = -1
                    // NOTE setting 'leverLL.state = "up"' here will yield statemachine error: <Unknown File>: QML StateGroup: Can't apply a state change as part of a state definition.
                    // Instead we set it later via a Timer
                    setFuelCellBackTimer.start()
                    game.setText("The fuel cell has already finished charging")
                }
            }
        }

        Timer {
            id: giveFuelCellBackTimer
            interval: 3500
            onTriggered: {
                var fc = game.getObject('fuel_cell')
                if(fc && fc.at === "fuel_cell_drop") {
                    fc.z = 0
                    game.fuelCellCharged = true
                    leverLL.state = "up"
                    game.setText("charged!")
                }
            }
        }

        Timer {
            id: setFuelCellBackTimer
            interval: 200
            onTriggered: {
                var fc = game.getObject('fuel_cell')
                if(fc && fc.at === "fuel_cell_drop") {
                    fc.z = 0
                    leverLL.state = "up"
                }
            }
        }

    }

    showForegroundShadow: flaskMixerArea.state !== "on"

    Area {
        id: flaskMixerArea
        stateless: true

        name: "flask_mixer_small"

        onClicked: state === "on" ? state = "off" : state = "on"
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


    Item {
        id: flaskMixerScene
        anchors { fill: parent }
        z: 22

        property bool show: flaskMixerArea.state === "on"

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
            onClicked: flaskMixerArea.state = "off"
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
                onClicked: flaskMixerArea.state = "off"
            }
        }

        Image {
            id: flaskMixer
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/flask_mixer/flask_mixer.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: {
                    var txt = "Hmm... This is not an easy task... "
                    txt += game.flasksFilled ? game.flasksCorrect ? "Some of these still need liquid in them" : "I think everything is ready" : "Something still need to be done here"

                    game.setText(txt)
                }
            }

            property int vGreen: game.flaskMixerGreenLevel
            property int vBlue: game.flaskMixerBlueLevel
            property int vRed: game.flaskMixerRedLevel
            property int vPurple: game.flaskMixerPurpleLevel
            function flaskClick(color) {

                if(game.flasksCorrect) {
                    game.setText("Like the old saying goes...","if it ain't broken...","don't fix it!")
                    return
                }

                var l = 0
                if(color === "green") {
                    l = game.flaskMixerGreenLevel
                    if(l > 0) {
                        vGreen++
                        l = Aid.oscillate(vGreen,1,7)
                        game.flaskMixerGreenLevel = l
                    }
                }

                if(color === "red") {
                    l = game.flaskMixerRedLevel
                    if(l > 0) {
                        vRed++
                        l = Aid.oscillate(vRed,1,7)
                        game.flaskMixerRedLevel = l
                    }
                }

                if(color === "blue") {
                    l = game.flaskMixerBlueLevel
                    if(l > 0) {
                        vBlue++
                        l = Aid.oscillate(vBlue,1,7)
                        game.flaskMixerBlueLevel = l
                    }
                }

                if(color === "purple") {
                    l = game.flaskMixerPurpleLevel
                    if(l > 0) {
                        vPurple++
                        l = Aid.oscillate(vPurple,1,7)
                        game.flaskMixerPurpleLevel = l
                    }
                }
            }

            Image {
                x: 243; y: 66
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/blue_"+level+".png")

                property int level: game.flaskMixerBlueLevel

                MouseArea {
                    anchors { fill: parent }
                    onClicked: flaskMixer.flaskClick("blue")
                }
            }

            Image {
                x: 70; y: 72
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/green_"+level+".png")

                property int level: game.flaskMixerGreenLevel

                MouseArea {
                    anchors { fill: parent }
                    onClicked: flaskMixer.flaskClick("green")
                }
            }

            Image {
                x: 65; y: 403
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/purple_"+level+".png")

                property int level: game.flaskMixerPurpleLevel

                MouseArea {
                    anchors { fill: parent }
                    onClicked: flaskMixer.flaskClick("purple")
                }
            }

            Image {
                x: 250; y: 410
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/wine_red_"+level+".png")

                property int level: game.flaskMixerRedLevel

                MouseArea {
                    anchors { fill: parent }
                    onClicked: flaskMixer.flaskClick("red")
                }
            }

            Image {
                id: centerLight
                x: 149; y: 266
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/center_"+color+".png")

                property string color: game.flasksFilled ? game.flasksCorrect ? "green" : "yellow" : "red"

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        if(centerLight.color === "green")
                            game.setText("Nice green glow. I think everything is ready")
                        if(centerLight.color === "yellow")
                            game.setText("It's got a nice yellow tint to it. There's more work to be done here")
                        if(centerLight.color === "red")
                            game.setText("It's red. Indicating that something is not in it's right state")
                    }
                }
            }
        }


    }


    onObjectDropped: {
        if(object.name === "fuel_cell")
            object.hideInventoryOnDrag = false
    }

    onObjectTravelingToInventory: {
    }

    onObjectDragged: {
        if(object.name === "fuel_cell")
            object.hideInventoryOnDrag = true
    }

    onObjectReturned: {
    }

    onObjectAddedToInventory: {
    }

    onObjectRemovedFromInventory: {
    }

}
