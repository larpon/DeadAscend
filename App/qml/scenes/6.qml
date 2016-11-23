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


    Component.onCompleted: {
        store.load()
        showExit()

        var sfx = core.sounds
        //sfx.add("level"+sceneNumber,"hum",App.getAsset("sounds/low_machine_hum.wav"))

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
                "Nah. Not really interesting",
                "Not of any use",
                "It's actually a bit warm in here"
            ]
            game.setText(Aid.randomFromArray(a))
        }
    }

    AnimatedArea {

        id: elevatorDoor

        name: "elevator_door_6"

        clickable: true
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
        }

        onFrame: {
            App.debug(sequenceName, frame )
            if(sequenceName === "open-show-panel" && frame == 5)
                game.elevatorPanel.show = true
        }
    }

    showForegroundShadow: officeArea.state !== "on"

    Area {
        id: officeArea
        stateless: true

        name: "office_area"

        onClicked: state === "on" ? state = "off" : state = "on"
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

    }

    Area {
        stateless: true

        name: "purple_pipe"

    }

    Area {
        stateless: true

        name: "red_pipe"

    }

    Area {
        stateless: true

        name: "green_pipe"

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
                //onClicked: game.setText("The drawing on the whiteboard is faded - but can still be made out","It looks like a sketch, depicting something involving a syringe and a hamster?")
            }
        }


    }


    Item {
        id: officeScene
        anchors { fill: parent }
        z: 22

        property bool show: officeArea.state === "on"

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
                onClicked: game.setText("Hmm...")
            }

            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("scenes/6office_fg_shadow.png")
            }

        }

        MouseArea {
            anchors { fill: parent }
            onClicked: officeArea.state = "off"
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
    }

    onObjectReturned: {
    }

    onObjectAddedToInventory: {
    }

    onObjectRemovedFromInventory: {
    }

}
