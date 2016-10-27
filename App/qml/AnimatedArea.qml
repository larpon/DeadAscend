import QtQuick 2.0

import Qak 1.0

ImageAnimation {
    id: area

    z: running ? 4 : 0

    visible: running
    running: run

    property bool run: false
    property string name: ''

    Store {
        id: store
        name: area.name !== '' ? "area/"+area.name : ''

        property alias _x: area.x
        property alias _y: area.y
        property alias run: area.run
    }

    Component.onCompleted: store.load()
    Component.onDestruction: store.save()
}
