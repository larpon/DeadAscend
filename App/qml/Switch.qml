import QtQuick 2.0

import Qak 1.0

import "."

Item {
    id: that

    property bool active: false

    width: switchImage.width
    height: switchImage.height

    /*
    property int autoFlipStateAfter: 0
    property bool autoFlip: false

    Timer {
        running: autoFlip
        interval: autoFlipStateAfter
        onTriggered: {
            active = !active
        }
    }
    */

    property string onSource: ''
    property string offSource: ''

    function resolveSource(active) {
        if(active)
            return onSource
        else
            return offSource
    }

    Image {
        id: switchImage

        fillMode: Image.PreserveAspectFit
        source: resolveSource(active)
    }

    MouseArea {
        anchors { fill: parent }
        onClicked: {
            active = !active
        }
    }

}
