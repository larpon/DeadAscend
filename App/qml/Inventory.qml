import QtQuick 2.3
import QtQml.Models 2.2

import Qak 1.0
import Qak.QtQuick 2.3

import "."

ObjectStore {
    id: root

    width: 832; height: 124

    name: "inventory"
    key: "name"
    properties: ["itemSource","iconSource"]

    property bool animate: false

    property bool scrollable: true

    ListModel {
        id: visualItems
    }

    DelegateModel {
        id: visualModel
        model: visualItems
        delegate: Entity {
            id: fakeObject
            height: 117
            width: 117

            property string name: key
            property alias keys: fakeDropSpot.keys

            visible: opacity > 0
            opacity: outOfBounds ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 100 }
            }

            draggable: true

            clickable: object !== undefined ? object.clickable : false
            property bool acceptDrops: object !== undefined ? object.acceptDrops : false

            dragger.drag.axis: Drag.YAxis
            onDragStarted: {
                dragger.drag.axis = Drag.XandYAxis
                z = 100
            }
            onDragReturn: dragger.drag.axis = Drag.YAxis
            onDragReturned: {
                z = 0
            }

            onDragAccepted: {
                z = 0
                if(object !== undefined)
                    object.inventoryDragAccepted(mouse,Drag.target)
            }

            Component.onCompleted: {
                makeConnections()
            }
            Drag.source: object
            Drag.keys: object !== undefined ? object.Drag.keys : ['notcombinable']

            property bool outOfBounds: !dragger.returning && !dragging && (x < listView.contentX || x+width-listView.contentX > listView.width)

            function makeConnections() {
                dragRejected.connect(object.dragRejected)
                dragStarted.connect(object.dragStarted)
                dragged.connect(object.dragged)
                dragReturn.connect(object.dragReturn)
                dragEnded.connect(object.dragEnded)
                dragReturned.connect(object.dragReturned)
                clicked.connect(object.clicked)
            }

            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                source: App.getAsset('inv_slot.png')

                width: sourceSize.width
                height: sourceSize.height

                visible: opacity > 0
                opacity: !fakeObject.dragging ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
            }

            Image {
                anchors { centerIn: parent }
                fillMode: Image.PreserveAspectFit

                source: object !== undefined ? dragging ? object.itemSource : object.iconSource : ""

                width: sourceSize.width > 100 ? 100 : sourceSize.width
                height: sourceSize.height > 100 ? 100 : sourceSize.height
            }

            DropSpot {
                id: fakeDropSpot
                anchors { fill: parent }
                enabled: acceptDrops
                keys: object !== undefined ? object.keys : ['notcombinable']
                onDropped: {
                    drop.accept()
                    game.objectCombined(object,drag.source)
                }
            }

        }

    }


    Rectangle  {
        anchors { fill: parent; margins: 10 }
        color: "#cc000000"
        radius: 10
    }

    ListView {
        id: listView
        interactive: root.scrollable
        anchors { fill: parent }
        orientation: ListView.Horizontal
        spacing: 2
        model: visualModel
        snapMode: ListView.SnapToItem
        displayMarginBeginning: 200
        displayMarginEnd: 200
    }


    Item {
        anchors { fill: parent }
        //color: "#835a41"
        //radius: 40
        visible: false

        Image {
            id: left
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            width: 52

            source: App.getAsset('button L.png')

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

        }

    }

    onAdded: {
        App.debug('Inventory','added',object.name) //¤

        core.sounds.play('add')

        if(animate) {

            var arr = function(){
                object.parent = row
                object.at = root.name
                addVisual(object)
                game.objectAddedToInventory(object)
                object.mover.stopped.disconnect(arr)
            }
            object.mover.stopped.connect(arr)

            var ppos = predictPosition()
            object.moveTo(ppos.x,ppos.y)
            animate = false
        } else {
            object.x = 0
            object.y = 0
            object.parent = row
            object.at = root.name
            addVisual(object)
            game.objectAddedToInventory(object)
        }
    }

    onNotAdded: {
        App.debug('Inventory','(not) added',object.name) //¤

        core.sounds.play('add')
        var m = row.mapFromItem(object.parent,object.x,object.y)
        object.parent = row

        if(animate) {
            object.x = m.x
            object.y = m.y
            object.at = root.name

            var arr = function(){
                object.at = root.name
                addVisual(object)
                game.objectAddedToInventory(object)
                object.mover.stopped.disconnect(arr)
            }
            object.mover.stopped.connect(arr)

            var ppos = predictPosition()
            object.moveTo(ppos.x,ppos.y)
            animate = false
        } else {
            object.x = 0
            object.y = 0
            object.at = root.name
            addVisual(object)
            game.objectAddedToInventory(object)
            object.play('onAddedToInventory')
        }
    }

    onRemoved: {
        if(!game.scene) {
            App.warn('Inventory::onRemoved','no scene available')
            return
        }
        object.parent = game.scene.canvas
        removeVisual(object)
        game.objectRemovedFromInventory(root)
        if('play' in object)
            object.play('onRemovedFromInventory')
    }

    function removeVisual(object) {
        for (var i=0; i < visualItems.count; i++) {
            var vo = visualItems.get(i)
            if(vo.key === object.name) {
                visualItems.remove(i)
            }
        }
    }

    function addVisual(object) {
        var found = false
        for (var i=0; i < visualItems.count; i++) {
            var vo = visualItems.get(i)
            if(vo.key === object.name) {
                found = true
                App.debug("Inventory","updating",object.name,"visual reference") //¤
                removeVisual(object)
                visualItems.insert(i,{ key: object.name, object: object })
                break
            }
        }
        if(!found)
            visualItems.append({ key: object.name, object: object })
    }


    function addAnimated(obj) {
        animate = true
        add(obj)
    }

    function predictPosition() {
        return Qt.point(0,660)
    }
}
