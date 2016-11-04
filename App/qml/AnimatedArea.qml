import QtQuick 2.0

import Qak 1.0

ImageAnimation {
    id: area

    clickable: description !== ""

    visible: running
    running: run

    property bool ready: store.isLoaded

    property bool run: false
    property string name: ""
    property string description: ""

    property alias store: store
    property bool stateless: false

    function save() {
        if(!stateless)
            store.save()
    }

    function load() {
        store.load()
    }

    Store {
        id: store
        name: area.name !== "" ? "area/"+area.name : ""

        property alias _x: area.x
        property alias _y: area.y
        property alias _state: area.state
        property alias run: area.run
        property alias description: area.description
    }

    Component.onCompleted: load()
    Component.onDestruction: save()

    onClicked: {
        if(description !== "")
            game.setText(description)
    }
}
