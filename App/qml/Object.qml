import QtQuick 2.0

import Qak 1.0

import "."

Entity {
    id: root

    //x: 0; y: 0
    //width: inInventory ? invImage.width : image.width
    //height: inInventory ? invImage.height : image.height

    draggable: true
    source: itemSource

    property bool autoInventory: true

    property string itemSource: ''
    property string iconSource: guessIcon(itemSource)

    property string name: ''
    property string at: ''
    property string _at: ''

    Drag.keys: [ 'inventory', name ]

    onDragStarted: {
        _at = at
        at = "dragged"
        game.objectDragged(root)
    }

    /*
    onDragEnded: {
        z = 0
    }
    */

    onDragAccepted: {
        if('name' in Drag.target)
            at = Drag.target.name
        if(at !== 'inventory')
            removeFromInventory()
        game.objectDropped(root)
    }

    onDragReturned: {
        at = _at
        game.objectReturned(root)
    }

    function removeFromInventory() {
        if(game.inventory.has(root)) {
            mover.duration = 0
            game.inventory.remove(root)
            game.objectRemovedFromInventory(root)
        }
    }

    function addToInventory() {
        if(!game.inventory.has(root)) {
            dragReturnAnimation.complete()
            mover.duration = 500
            game.inventory.addAnimated(root)
            game.objectAddedToInventory(root)
        }
    }

    property bool inInventory: at === 'inventory'
    property bool fitInventory: false
    onInInventoryChanged: {
        if(inInventory) {
            source = iconSource
            root.width = invImage.width
            root.height = invImage.height
        } else {
            source = itemSource
            root.width = image.width
            root.height = image.height
        }
    }

    Store {
        id: store
        name: root.name !== '' ? "objects/"+root.name : ''

        property alias _x: root.x
        property alias _y: root.y
        property alias at: root.at
        property alias state: root.state
        //property alias _visible: root.visible
    }

    Component.onCompleted: store.load()
    Component.onDestruction: store.save()

    function guessIcon(path) {
        var basename = path.split(/[\\/]/).pop()
        var bns = basename.split('.')
        var ext = bns.pop()
        var icon = bns.join('.')+'_icon.'+ext

        var guessedPath = path.replace(basename,icon)
        //console.debug('Object resolved',source,'icon',path.replace(basename,icon))
        if(!Qak.resource.exists(guessedPath)) {
            fitInventory = true
            return path
        }

        return path.replace(basename,icon)
    }

    Image {
        id: invImage
        visible: inInventory
        fillMode: Image.PreserveAspectFit
        source: App.getAsset('inv_slot.png')

        width: 117

        Image {
            id: iconImage
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: root.adaptiveSource

            width: (inInventory && fitInventory) ? 96 : sourceSize.width
        }
    }

    Image {
        id: image
        visible: !invImage.visible
        fillMode: Image.PreserveAspectFit
        source: root.adaptiveSource

        width: (inInventory && fitInventory) ? 96 : sourceSize.width
    }

    onClicked: {
        if(!inInventory && autoInventory)
            addToInventory()
    }

    MouseArea {
        anchors { fill: parent }
        enabled: !root.draggable
        onClicked: root.clicked(mouse)
    }

}
