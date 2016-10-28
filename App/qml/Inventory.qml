import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

import "."

ObjectStore {
    id: root

    width: 832; height: 124

    name: "inventory"
    key: "name"
    properties: ["itemSource","iconSource"]

    property bool animate: false

    Item {
        anchors { fill: parent }
        //color: "#835a41"
        //radius: 40

        Image {
            id: left
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            width: 52

            source: App.getAsset('button L.png')

            MouseArea {
                anchors { fill: parent }

            }
        }

        Item {
            id: row
            anchors {
                top: parent.top
                left: left.right
                right: right.left
                bottom: parent.bottom
            }

        }

        Image {
            id: right
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: 52
            source: App.getAsset('button R.png')

            MouseArea {
                anchors { fill: parent }

            }
        }

    }

    onAdded: {
        App.debug('Inventory','added',object.name)

        core.sounds.play('add')
        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        var setX = (contents.length-1)*117
        App.debug('XXXX',setX)
        //var setY = row.children.length()

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.moveTo(setX,0)
            animate = false
        } else {
            object.x = setX
            object.y = 0
        }

        object.at = root.name
    }

    onNotAdded: {
        App.debug('Inventory','added',object.name)

        core.sounds.play('add')
        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        var setX = (contents.length-1)*117
        App.debug('XXXX',setX)
        //var setY = row.children.length()

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.moveTo(setX,0)
            animate = false
        } else {
            object.x = setX
            object.y = 0
        }

        object.at = root.name
    }

    onRemoved: {
        object.parent = game
    }

    function addAnimated(obj) {
        animate = true
        add(obj)
    }

}
