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

        if(animate) {
            object.x = m.x
            object.y = m.y

            var arr = function(){
                object.at = root.name
                arrange()
                game.objectAddedToInventory(object)
                object.mover.stopped.disconnect(arr)
            }
            object.mover.stopped.connect(arr)

            var ppos = predictPosition()
            object.moveTo(ppos.x,0)
            animate = false
        } else {
            object.x = 0
            object.y = 0
            object.at = root.name
            arrange()
            game.objectAddedToInventory(object)
        }
    }

    onNotAdded: {
        App.debug('Inventory','added',object.name)

        core.sounds.play('add')
        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.at = root.name

            var arr = function(){
                object.at = root.name
                arrange()
                game.objectAddedToInventory(object)
                object.mover.stopped.disconnect(arr)
            }
            object.mover.stopped.connect(arr)

            var ppos = predictPosition()
            object.moveTo(ppos.x,0)
            animate = false
        } else {
            object.x = 0
            object.y = 0
            object.at = root.name
            arrange()
            game.objectAddedToInventory(object)
            object.play('onAddedToInventory')
        }
    }

    onRemoved: {
        object.parent = game.scene.canvas
        arrange()
        game.objectRemovedFromInventory(root)
        object.play('onRemovedFromInventory')
    }

    function addAnimated(obj) {
        animate = true
        add(obj)
    }

    function arrange() {

        var i, c = 0
        for(i in row.children) {
            var o = row.children[i]
            if('name' in o) {
                o.x = c * 117
                c++
            }
        }
    }

    function predictPosition() {

        var i, c = 0
        for(i in row.children) {
            var o = row.children[i]
            if('name' in o) {
                c++
            }
        }
        return Qt.point((c * 117) - 117,0)
    }
}
