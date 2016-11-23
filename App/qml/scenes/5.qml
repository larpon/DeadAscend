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

        clickable: true
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


    AnimatedArea {

        name: "lever_ll"

        clickable: true
        stateless: true

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

        name: "lever_lr"

        clickable: true
        stateless: true

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

        name: "lever_rl"

        clickable: true
        stateless: true

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

        name: "lever_rr"

        clickable: true
        stateless: true

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
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/flask_mixer/flask_mixer.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: game.setText("Hmm... This is not an easy task")
            }

            Image {
                x: 243; y: 66
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/blue_"+level+".png")

                property int level: game.flaskMixerBlueLevel

                MouseArea {
                    anchors { fill: parent }
                    onClicked: game.setText("It's got a nice blue tint to it")
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
                    onClicked: game.setText("It's got a nice green tint to it")
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
                    onClicked: game.setText("It's got a nice purple tint to it")
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
                    onClicked: game.setText("It's got a nice redwine tint to it")
                }
            }

            Image {
                x: 149; y: 266
                fillMode: Image.PreserveAspectFit
                width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/flask_mixer_levels/center_"+color+".png")

                property string color: game.flasksFilled ? game.flasksCorrect ? "yellow" : "green" : "red"

                MouseArea {
                    anchors { fill: parent }
                    onClicked: game.setText("It's got a nice green tint to it")
                }
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
