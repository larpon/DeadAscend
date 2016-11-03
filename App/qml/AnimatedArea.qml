import QtQuick 2.0

import Qak 1.0

ImageAnimation {
    id: area

    clickable: description !== ""

    visible: running
    running: run

    property bool run: false
    property string name: ""
    property string description: ""

    Store {
        id: store
        name: area.name !== "" ? "area/"+area.name : ""

        property alias _x: area.x
        property alias _y: area.y
        property alias _state: area.state
        property alias run: area.run
        property alias description: area.description
    }

    Component.onCompleted: store.load()
    Component.onDestruction: store.save()

    onClicked: {
        if(description !== "")
            game.setText(description)
    }
}
