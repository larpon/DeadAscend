import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.3

import ".."
import "."

Base {
    id: scene

    ready: store.isLoaded

    onReadyChanged: {
        elevatorDoor.setActiveSequence("opened-wait-close")
    }

    anchors { fill: parent }

    property bool officeUnlocked: store.keyCombo1 && store.keyCombo2 && store.keyCombo3 && store.keyCombo4

    Store {
        id: store
        name: "level"+sceneName

        property bool keyCombo1: false
        property bool keyCombo2: false
        property bool keyCombo3: false
        property bool keyCombo4: false

        property bool chargingPaperRDropped: false

        property bool fuelCellHasSpawned: false
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
        sfx.add("level"+sceneName,"pouring",App.getAsset("sounds/pouring.wav"))
        sfx.add("level"+sceneName,"key_tap",App.getAsset("sounds/key_tap.wav"))
        sfx.add("level"+sceneName,"beep",App.getAsset("sounds/beep.wav"))
        sfx.add("level"+sceneName,"beep_wrong",App.getAsset("sounds/beep_wrong.wav"))

        sfx.add("level"+sceneName,"radio_loop",App.getAsset("sounds/radio_silence_loop.wav"))
        sfx.add("level"+sceneName,"radio_seek",App.getAsset("sounds/radio_seek.wav"))
        sfx.add("level"+sceneName,"paper_fiddle",App.getAsset("sounds/paper_fiddle.wav"))

        sfx.add("level"+sceneName,"hum",App.getAsset("sounds/low_machine_hum.wav"))
    }

    Component.onDestruction: {
        store.save()
    }

    function showExit() {
        game.showExit(788,220,2000,"down")
        game.showExit(530,130,2100,"up")
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: {
            var a = [
                qsTr("Nah. Not really interesting"),
                qsTr("Not of any use"),
                qsTr("It's actually a bit warm in here")
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_6"

        clickable: !animating
        stateless: true

        visible: true
        run: false
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/elevator_assets/doors/floor_6/move/0001.png")

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
            sounds.play("ding")
        }

        onFrame: {
            if(sequenceName === "open-show-panel" && frame == 5) {
                game.elevatorPanel.show = true
                sounds.play("elevator_open")
            }
            if(sequenceName === "close" && frame == 1) {
                sounds.play("elevator_close")
            }
        }
    }

    showForegroundShadow: officeArea.state !== "on" && keypadArea !== "on"

    Area {
        id: officeArea
        stateless: true

        name: "office_area"

        onClicked: {
            if(scene.officeUnlocked)
                state === "on" ? state = "off" : state = "on"
            else
                game.setText(qsTr("The door is locked..."),qsTr("The keypad to the right seem to be connected to the door"))
        }
    }

    Area {
        id: keypadArea
        stateless: true

        name: "keypad_area"

        onClicked: state === "on" ? state = "off" : state = "on"
    }

    Area {
        stateless: true

        name: "blue_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ "bottle_blue", "bottle_purple", "bottle_green", "bottle_red" ]

            name: "bottle_blue_drop"

            onDropped: {

                if(game.flaskMixerBlueLevel > 0) {
                    setText(qsTr("There's already poured liquid in this"))
                    return
                }

                var o = drag.source

                if(o.name !== "bottle_blue") {
                    setText(qsTr("... better not put %1 liquid in a blue pipe").arg(o.name.replace("bottle_","")))
                    return
                }

                drop.accept()

                sounds.play("pouring")
                game.setText(qsTr("The liquid is poured in now"))

                game.flaskMixerBlueLevel = 1

                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "purple_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ "bottle_blue", "bottle_purple", "bottle_green", "bottle_red" ]

            name: "bottle_purple_drop"

            onDropped: {

                if(game.flaskMixerPurpleLevel > 0) {
                    setText(qsTr("There's already poured liquid in this"))
                    return
                }

                var o = drag.source

                if(o.name !== "bottle_purple") {
                    setText(qsTr("... better not put %1 liquid in a purple pipe").arg(o.name.replace("bottle_","")))
                    return
                }

                drop.accept()

                sounds.play("pouring")
                game.setText(qsTr("All the purple juicy stuff is poured in now"))

                game.flaskMixerPurpleLevel = 2

                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "red_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ "bottle_blue", "bottle_purple", "bottle_green", "bottle_red" ]

            name: "bottle_red_drop"

            onDropped: {

                if(game.flaskMixerRedLevel > 0) {
                    setText(qsTr("There's already poured liquid in this"))
                    return
                }

                var o = drag.source

                if(o.name !== "bottle_red") {
                    setText(qsTr("... better not put %1 liquid in a red-ish pipe").arg(o.name.replace("bottle_","")))
                    return
                }

                drop.accept()

                sounds.play("pouring")
                game.setText(qsTr("All the red goo is poured in now"))

                game.flaskMixerRedLevel = 1

                blacklistObject(o.name)
            }

        }
    }

    Area {
        stateless: true

        name: "green_pipe"

        DropSpot {
            anchors { fill: parent }
            keys: [ "bottle_blue", "bottle_purple", "bottle_green", "bottle_red" ]

            name: "bottle_green_drop"

            onDropped: {

                if(game.flaskMixerGreenLevel > 0) {
                    setText(qsTr("There's already poured liquid in this"))
                    return
                }

                var o = drag.source

                if(o.name !== "bottle_green") {
                    setText(qsTr("... better not put %1 liquid in a green pipe").arg(o.name.replace("bottle_","")))
                    return
                }

                drop.accept()

                sounds.play("pouring")
                game.setText(qsTr("..."),qsTr("All the contents are poured in"))

                game.flaskMixerGreenLevel = 4

                blacklistObject(o.name)
            }

        }
    }

    Connections {
        target: game.elevatorPanel
        onShowChanged: {
            if(game.elevatorPanel.show) {

            } else {
                elevatorDoor.setActiveSequence("close")
            }
        }
    }

    AnimatedArea {

        name: "ventilator_wing"

        stateless: true

        visible: true
        run: true
        paused: !visible || (scene.paused)

        source: App.getAsset("sprites/ventilator/wing_2/1.png")

        defaultFrameDelay: 100

        sequences: [
            {
                name: "run",
                frames: [1,2,3],
                to: { "run":1 }
            }
        ]
    }

    Item {
        id: keypadScene
        anchors { fill: parent }
        z: 22

        property bool show: keypadArea.state === "on"

        signal keyClicked(string key)


        property string buffer: "0000"

        onKeyClicked: {
            App.debug(key)
            sounds.play("key_tap")
            if(key === "CLR") {
                buffer = "0000"
            } else if(key === "OK") {

                if(!store.keyCombo1) {
                    if(buffer === "0563") {
                        store.keyCombo1 = true
                        blinkGreenAnimation.indicator = kpi1
                        var p3 = game.getObject('painting3')
                        if(p3 && game.inventory.has(p3))
                            game.blacklistObject('painting3')
                    } else
                        blinkRedAnimation.indicator = kpi1
                } else if(!store.keyCombo2) {
                    if(buffer === "0037") {
                        store.keyCombo2 = true
                        blinkGreenAnimation.indicator = kpi2
                        var p4 = game.getObject('painting4')
                        if(p4 && game.inventory.has(p4))
                            game.blacklistObject('painting4')
                    } else
                        blinkRedAnimation.indicator = kpi2
                } else if(!store.keyCombo3) {
                    if(buffer === "0099") {
                        store.keyCombo3 = true
                        blinkGreenAnimation.indicator = kpi3
                        var p1 = game.getObject('painting1')
                        if(p1 && game.inventory.has(p1))
                            game.blacklistObject('painting1')
                    } else
                        blinkRedAnimation.indicator = kpi3
                } else if(!store.keyCombo4) {
                    if(buffer === "0318") {
                        store.keyCombo4 = true
                        blinkGreenAnimation.indicator = kpi4
                        var p2 = game.getObject('painting2')
                        if(p2 && game.inventory.has(p2))
                            game.blacklistObject('painting2')
                    } else
                        blinkRedAnimation.indicator = kpi4
                }

                if(scene.officeUnlocked)
                    game.setText(qsTr("It's open!"))

                buffer = "0000"
            } else {
                var sb = buffer.split("")
                sb.push(key)
                sb.shift()
                buffer = sb.join("")
            }
            App.debug(buffer)
            display.text = buffer
        }

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
            onClicked: keypadArea.state = "off"
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
                onClicked: keypadArea.state = "off"
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/keypad/keypad.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: game.setText(qsTr("A fancy colored keypad"))
            }

            SequentialAnimation {
                id: blinkRedAnimation

                running: indicator !== undefined

                property var indicator
                ScriptAction {
                    script: {
                        blinkRedAnimation.indicator.state = "red"
                    }
                }

                SequentialAnimation {
                    loops: 6
                    PauseAnimation { duration: 300 }
                    NumberAnimation { target: blinkRedAnimation.indicator; property: "opacity"; duration: 100; from: 0; to: 1 }
                    PauseAnimation { duration: 20 }
                    NumberAnimation { target: blinkRedAnimation.indicator; property: "opacity"; duration: 40; from: 1; to: 0 }
                }

                NumberAnimation { target: blinkRedAnimation.indicator; property: "opacity"; duration: 100; from: 0; to: 1 }

                ScriptAction {
                    script: {
                        blinkRedAnimation.indicator.state = "red"
                        game.setText(qsTr("..."),qsTr("not the right key combination"))
                        sounds.play("beep_wrong")
                    }
                }
            }

            SequentialAnimation {
                id: blinkGreenAnimation

                running: indicator !== undefined

                property var indicator
                ScriptAction {
                    script: {
                        blinkGreenAnimation.indicator.state = "green"
                        sounds.play("beep")
                    }
                }

                SequentialAnimation {
                    loops: 6
                    PauseAnimation { duration: 300 }
                    NumberAnimation { target: blinkGreenAnimation.indicator; property: "opacity"; duration: 100; from: 0; to: 1 }
                    PauseAnimation { duration: 20 }
                    NumberAnimation { target: blinkGreenAnimation.indicator; property: "opacity"; duration: 40; from: 1; to: 0 }
                }

                NumberAnimation { target: blinkGreenAnimation.indicator; property: "opacity"; duration: 100; from: 0; to: 1 }

                ScriptAction {
                    script: {
                        blinkGreenAnimation.indicator.state = "green"
                        if(scene.officeUnlocked) {
                            sounds.play("tick")
                            game.setText(qsTr("Open Sesame!"))
                        } else
                            game.setText(qsTr("Green lights are good lights!"))

                    }
                }
            }

            Image {
                x: 75
                source: App.getAsset("sprites/keypad_assets/indicators/0/off.png")
                Image {
                    id: kpi0
                    state: scene.officeUnlocked ? "green" : "red"
                    source: App.getAsset("sprites/keypad_assets/indicators/0/"+state+".png")

                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite

                        PauseAnimation { duration: 300 }
                        NumberAnimation { target: kpi0; property: "opacity"; duration: 100; from: 0; to: 1 }
                        PauseAnimation { duration: 20 }
                        NumberAnimation { target: kpi0; property: "opacity"; duration: 40; from: 1; to: 0 }
                    }
                }
            }

            Image {
                x: 120; y: -4
                source: App.getAsset("sprites/keypad_assets/indicators/1/off.png")
                Image {
                    id: kpi1
                    state: store.keyCombo1 ? "green" : "red"
                    source: App.getAsset("sprites/keypad_assets/indicators/1/"+state+".png")
                }
            }

            Image {
                x: 140; y: -2
                source: App.getAsset("sprites/keypad_assets/indicators/2/off.png")
                Image {
                    id: kpi2
                    state: store.keyCombo2 ? "green" : "red"
                    source: App.getAsset("sprites/keypad_assets/indicators/2/"+state+".png")
                }
            }

            Image {
                x: 163; y: -5
                source: App.getAsset("sprites/keypad_assets/indicators/3/off.png")
                Image {
                    id: kpi3
                    state: store.keyCombo3 ? "green" : "red"
                    source: App.getAsset("sprites/keypad_assets/indicators/3/"+state+".png")
                }
            }

            Image {
                x: 183; y: -5
                source: App.getAsset("sprites/keypad_assets/indicators/4/off.png")
                Image {
                    id: kpi4
                    state: store.keyCombo4 ? "green" : "red"
                    source: App.getAsset("sprites/keypad_assets/indicators/4/"+state+".png")
                }
            }

            Row {
                id: display
                x: 307; y: 78
                property string text: "0000"
                spacing: 10
                Repeater {
                    model: display.text.length
                    Image {
                        source: App.getAsset("sprites/keypad_assets/digits/" + (display.text.charCodeAt(index)-48) + ".png")
                    }
                }
            }

            // 1
            Area {
                x: 55; y: 70
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("1") }
            }

            // 2
            Area {
                x: 125; y: 62
                width: 60; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("2") }
            }

            // 3
            Area {
                x: 204; y: 62
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("3") }
            }

            // 4
            Area {
                x: 50; y: 145
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("4") }
            }

            // 5
            Area {
                x: 120; y: 141
                width: 58; height: 55
                stateless: true
                onClicked: { keypadScene.keyClicked("5") }
            }

            // 6
            Area {
                x: 198; y: 142
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("6") }
            }

            // 7
            Area {
                x: 55; y: 230
                width: 45; height: 45
                stateless: true
                onClicked: { keypadScene.keyClicked("7") }
            }

            // 8
            Area {
                x: 126; y: 223
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("8") }
            }

            // 9
            Area {
                x: 201; y: 220
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("9") }
            }

            // OK
            Area {
                x: 60; y: 310
                width: 107; height: 59
                stateless: true
                onClicked: { keypadScene.keyClicked("OK") }
            }

            // CLR
            Area {
                x: 195; y: 310
                width: 50; height: 50
                stateless: true
                onClicked: { keypadScene.keyClicked("CLR") }
            }
        }


    }


    Item {
        id: officeScene
        anchors { fill: parent }
        z: 22

        property bool show: officeArea.state === "on"

        onShowChanged: {
            if(show)
                sounds.play("radio_loop",sounds.infinite)
            else
                sounds.stop("radio_loop")
        }

        visible: opacity > 0
        opacity: show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/6office.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: officeArea.state = "off"
            }

            Area {
                x: 298; y: 35
                width: 589; height: 625
                description: qsTr("...")
            }

            Area {
                x: 387; y: 37
                width: 24; height: 317
                description: [ qsTr("This must be the cable for the antenna"),qsTr("It leads to the roof") ]
            }


            Area {
                x: 567; y: 93
                width: 303; height: 514
                description: qsTr("A fairly large bookcase. Very square")
            }

            Area {
                x: 290; y:344
                width: 249; height: 199

                itemSource: App.getAsset("sprites/radio/radio.png")

                onClicked: {
                    sounds.play("radio_seek")

                    if(!game.helpCalled) {
                        if(game.fuelCellConnected) {
                            game.helpCalled = true
                            game.setText(qsTr("YES! THERE'S OTHER SURVIVORS ON THE RADIO"),qsTr("HALLO!? CAN YOU HEAR ME!?"),qsTr("radio: *Loud and clear, over*"),
                            qsTr("COME GET ME AT THE TOWER"),qsTr("radio: *We're sending a chopper, over*"),qsTr("AWESOME!, OVER!"),qsTr("..."),qsTr("Woohoo - they are coming for me!"),qsTr("I'll better hurry to the roof and wait for the chopper"))
                        } else
                            game.setText(qsTr("There's only noise..."),qsTr("The indicator for \"LONG RANGE\" is off"),qsTr("You'd need a powered antenna to call for help"),qsTr("More problems than solutions I guess"))
                    } else
                        game.setText(qsTr("Help is on the way - I better get to the roof!"))
                }
            }

            Area {
                x: 644; y: 238
                width: 52; height: 88
                description: qsTr("A fine lava lamp. It's not working")
            }

            Area {
                x: 779; y: 193
                width: 80; height: 118
                description: qsTr("A frontpage from the newspaper when the apocalypse got real")
            }

            Area {
                x: 584; y: 401
                width: 167; height: 149
                description: qsTr("Books, books, books. I'm looking for a good time")
            }

            Area {
                x: 593; y: 325
                width: 163; height: 115
                description: qsTr("A shelf full of books")
            }

            Area {
                x: 707; y: 304
                width: 59; height: 44
                description: qsTr("A small pile of very uninteresting papers")
            }

            Area {
                id: fuelCellArea
                x: 610; y: 150
                width: 86; height: 77

                visible: !store.fuelCellHasSpawned

                itemSource: App.getAsset("sprites/fuel_cell/fuel_cell.png")

                onClicked: {

                    var object = {
                        name: "fuel_cell",
                        type: "Object",
                        x: 610,
                        y: 150,
                        scene: sceneName,
                        description: qsTr("A fuel cell"),
                        itemSource: App.getAsset("sprites/fuel_cell/fuel_cell.png")
                    }
                    game.spawnObject(object,function(o){
                        store.fuelCellHasSpawned = true
                        game.inventory.addAnimated(o)
                    })
                }
            }

            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("scenes/6office_fg_shadow.png")
            }

            Area {
                id: chargingPaper
                x: 426; y:150
                width: cpil.width; height: cpil.height

                transformOrigin: Item.TopLeft
                scale: 0.18
                Behavior on scale {
                    NumberAnimation { duration: 400 }
                }
                Behavior on rotation {
                    NumberAnimation { duration: 400 }
                }
                Behavior on y {
                    NumberAnimation { duration: 400 }
                }

                DropSpot {
                    anchors { fill: parent }
                    keys: [ "charging_paper_r" ]

                    name: "charging_paper_r_drop"

                    enabled: !store.chargingPaperRDropped

                    onDropped: {
                        drop.accept()

                        sounds.play("paper_fiddle")
                        game.setText(qsTr("The two pieces fit perfectly together"))

                        store.chargingPaperRDropped = true

                        var o = drag.source
                        blacklistObject(o.name)
                    }
                }


                Image {
                    id: cpil
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    mipmap: true
                    source: App.getAsset("sprites/charging_paper/charging_paper_L.png")
                }

                Image {
                    id: cpir
                    anchors {
                        left: cpil.right
                        bottom: cpil.bottom
                        bottomMargin: -70
                        leftMargin: -190
                    }

                    visible: store.chargingPaperRDropped

                    mipmap: true
                    source: App.getAsset("sprites/charging_paper/charging_paper_R.png")
                }

                onClicked: {
                    sounds.play("paper_fiddle")
                    scale = scale > 0.18 ? 0.18 : 1
                    rotation = rotation > 0 ? 0 : 45
                    y = y < 150 ? 150 : -90
                }
            }

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
                onClicked: officeArea.state = "off"
            }
        }


    }


    onObjectDropped: {
    }

    onObjectTravelingToInventory: {
    }

    onObjectDragged: {
        if(object.name === "bottle_red")
            object.hideInventoryOnDrag = true
    }

    onObjectReturned: {
    }

    onObjectAddedToInventory: {
    }

    onObjectRemovedFromInventory: {
    }

}
