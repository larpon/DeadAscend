import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: area

    property bool clickable: true
    property bool round: false
    property bool ready: store.isLoaded

    property string name: ""
    property var description: ""

    property string itemSource: ""

    property alias store: store
    property bool stateless: false

    signal clicked(variant mouse)


    function save() {
        if(!stateless && name !== "")
            store.save()
    }

    function load() {
        store.load()
    }

    Image {
        visible: itemSource !== ""
        anchors { fill: parent }
        source: itemSource
    }

    MouseArea {
        id: rect
        anchors { fill: parent }
        enabled: clickable && !round

        onClicked: area.clicked(mouse)
    }

    RoundMouseArea {
        id: rnd
        anchors { fill: parent }
        enabled: clickable && round

        onClicked: area.clicked(mouse)
    }

    DebugVisual { enabled: clickable && (rect.enabled || rnd.enabled) }

    Store {
        id: store
        name: area.name !== "" ? "area/"+area.name : ""

        property alias _x: area.x
        property alias _y: area.y
        property alias _state: area.state
        property alias round: area.round
        property alias description: area.description
    }

    Component.onCompleted: load()
    Component.onDestruction: save()

    onClicked: {
        autoDescription()
    }

    function autoDescription() {
        if(Aid.isString(description) && description !== "")
            game.setText(description)
        if(Aid.isArray(description) && description.length > 0)
            game.setText.apply(this, description)
    }
}

