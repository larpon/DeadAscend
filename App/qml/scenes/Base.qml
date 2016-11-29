import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."

Item {
    id: scene

    anchors { fill: parent }

    paused: App.paused
    onPausedChanged: App.debug('Scene',sceneNumber,paused ? 'paused' : 'continued')

    Component.onCompleted: game.elevatorPanel.show = false

    Component.onDestruction: {
        core.sounds.clear('level'+sceneNumber)
        game.save()
    }

    property bool showForegroundShadow: true

    readonly property string sceneNumber: game.currentScene

    default property alias content: canvas.data
    property alias canvas: canvas
    property SoundBank sounds: core.sounds

    property bool ready: false

    signal objectReady(var object)
    signal objectDragged(var object)
    signal objectDropped(var object)
    signal objectCombined(var object, var otherObject)
    signal objectClicked(var object)
    signal objectReturned(var object)
    signal objectTravelingToInventory(var object)
    signal objectAddedToInventory(var object)
    signal objectRemovedFromInventory(var object)

    Connections {
        target: game
        onObjectReady: { App.debug('Object ready',object.name); objectReady(object)}
        onObjectDropped: { App.debug('Object dropped',object.name); objectDropped(object)}
        onObjectClicked: { App.debug('Object clicked',object.name); objectClicked(object)}
        onObjectTravelingToInventory: { App.debug('Object traveling to inventory',object.name); objectTravelingToInventory(object) }
        onObjectDragged: { App.debug('Object dragged',object.name); objectDragged(object) }
        onObjectReturned: { App.debug('Object returned',object.name);  objectReturned(object) }
        onObjectAddedToInventory: { App.debug('Object added to inventory',object.name);  objectAddedToInventory(object) }
        onObjectRemovedFromInventory: { App.debug('Object removed from inventory',object.name);  objectRemovedFromInventory(object) }
    }

    Image {
        id: background

        fillMode: Image.PreserveAspectFit
        source: App.getAsset('scenes/'+sceneNumber+'.png')

        cache: false
    }

    Item {
        id: canvas
        anchors { fill: parent }


    }

    Image {
        id: foreground

        visible: opacity > 0
        opacity: showForegroundShadow ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 600 }
        }

        cache: false

        anchors { fill: parent }

        fillMode: Image.PreserveAspectFit
        source: App.getAsset('scenes/'+sceneNumber+'_fg_shadow.png')

        SequentialAnimation {
            running: showForegroundShadow
            loops: Animation.Infinite

            paused: running && scene.paused

            NumberAnimation { target: foreground; property: "opacity"; from: 1; to: 0.9; duration: 600 }
            NumberAnimation { target: foreground; property: "opacity"; from: 0.9; to: 1; duration: 800 }
        }

    }

    Rectangle {
        id: fader

        anchors { fill: parent }

        color: core.colors.black

        opacity: ready ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }
    }

}
