import QtQuick 2.0

import Qak 1.0

Item {
    id: area

    property bool round: false
    property bool ready: store.isLoaded

    property string name: ""
    property string description: ""

    property alias store: store
    property bool stateless: false

    signal clicked(variant mouse)


    function save() {
        if(!stateless)
            store.save()
    }

    function load() {
        store.load()
    }

    MouseArea {
        id: rect
        anchors { fill: parent }
        enabled: !round

        onClicked: area.clicked(mouse)
    }

    RoundMouseArea {
        id: rnd
        anchors { fill: parent }
        enabled: round

        onClicked: area.clicked(mouse)
    }

    DebugVisual { enabled: rect.enabled }

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
        if(description !== "")
            game.setText(description)
    }

}

