import QtQuick 2.0

import Qak 1.0

Item {
    id: area

    property bool round: false

    property string name: ''

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
        name: area.name !== '' ? "area/"+area.name : ''

        property alias _x: area.x
        property alias _y: area.y
        property alias state: area.state
        property alias round: area.round
    }

    Component.onCompleted: store.load()
    Component.onDestruction: store.save()
}

