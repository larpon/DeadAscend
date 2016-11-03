import QtQuick 2.0

import Qak 1.0

Item {
    id: area

    property bool round: false
    property bool ready: store.isLoaded

    property string name: ""
    property string description: ""

    signal clicked(variant mouse)

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

    Store {
        id: store
        name: area.name !== "" ? "area/"+area.name : ""

        property alias _x: area.x
        property alias _y: area.y
        property alias _state: area.state
        property alias round: area.round
        property alias description: area.description
    }

    onClicked: {
        if(description !== "")
            game.setText(description)
    }

    Component.onCompleted: store.load()
    Component.onDestruction: store.save()
}

