import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

import "."

ObjectStore {
    id: root

    width: img.width; height: img.height

    name: "inventory"
    key: "name"
    properties: ["itemSource","iconSource"]

    property bool animate: false

    Image {
        id: img
        source: App.getAsset('inventory.png')
    }

    onAdded: {
        App.debug('Inventory','added',object.name)

        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.moveTo(0,0)
            animate = false
        } else {
            object.x = 0
            object.y = 0
        }
        object.at = root.name
    }

    onNotAdded: {
        App.debug('Inventory','added',object.name)

        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.moveTo(0,0)
            animate = false
        } else {
            object.x = 0
            object.y = 0
        }
        object.at = root.name
    }

    onRemoved: {
        object.parent = game
    }

    Item {
        id: row
        anchors { fill: parent }
    }

    function addAnimated(obj) {
        animate = true
        add(obj)
    }

}
