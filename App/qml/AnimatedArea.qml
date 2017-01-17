import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

ImageAnimation {
    id: area

    clickable: description !== ""

    visible: running
    running: run

    property bool ready: store.isLoaded && balanced

    property bool run: false
    property string name: ""
    property string description: ""

    property real margins: core.defaultMargins
    onInputChanged: { if(input) input.anchors.margins = margins }
    onMarginsChanged: { if(input) input.anchors.margins = margins }

    property alias store: store
    property bool stateless: name == ""

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
        autoDescription()
    }

    function autoDescription() {
        if(Aid.isString(description) && description !== "")
            game.setText(description)
        if(Aid.isArray(description) && description.length > 0)
            game.setText.apply(this, description)
    }
}
