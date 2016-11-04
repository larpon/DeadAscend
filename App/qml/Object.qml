import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

import "."

Entity {
    id: root

    width: image.width
    height: image.height

    clickable: !mover.moving
    draggable: !mover.moving
    source: itemSource

    property alias store: store
    property bool stateless: false

    property bool ready: store.isLoaded
    property bool autoInventory: true
    property bool acceptDrops: false

    property string itemSource: ''
    property string iconSource: guessIcon(itemSource)

    property string name: ""
    property string description: ""
    property string scene: ""
    property string at: ""
    property string _at: ""
    property int _z: 0

    property alias keys: dropSpot.keys

    Drag.keys: [ 'inventory', name ]

    onReadyChanged: {
        if(ready)
            game.objectReady(root)
    }

    onDragStarted: {
        if(at === "dragged") // Panic click prevention
            return
        _at = at
        at = "dragged"
        _z = z
        z = 1
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
        z = _z
        scene = game.currentScene
        game.objectDropped(root)
    }

    onDragReturned: {
        at = _at
        z = _z
        game.objectReturned(root)
    }

    function removeFromInventory() {
        if(game.inventory.has(root)) {
            mover.duration = 0
            game.inventory.remove(root)
        }
    }

    function addToInventory() {
        if(!game.inventory.has(root)) {
            dragReturnAnimation.complete()
            mover.duration = 500
            game.inventory.addAnimated(root)
            game.objectTravelingToInventory(root)
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
        property alias _z: root.z
        property alias _width: root.width
        property alias _height: root.height
        property alias _state: root.state
        property alias description: root.description
        property alias at: root.at
        property alias scene: root.scene
        property alias itemSource: root.itemSource
        property alias acceptDrops: root.acceptDrops
        property alias keys: root.keys

    }

    Component.onCompleted: load()
    Component.onDestruction: save()

    function save() {
        if(!stateless)
            store.save()
    }

    function load() {
        store.load()
    }

    function guessIcon(path) {
        var basename = path.split(/[\\/]/).pop()
        var bns = basename.split('.')
        var ext = bns.pop()
        var icon = bns.join('.')+'_icon.'+ext

        // Rail & rung hack
        if(path.indexOf("rail_") !== -1)
            icon = 'rail_icon.'+ext
        if(path.indexOf("rung_") !== -1)
            icon = 'rung_icon.'+ext

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

        width: sourceSize.width
        height: sourceSize.height

        Image {
            id: iconImage
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: root.adaptiveSource

            width: (inInventory && fitInventory) ? 96 : sourceSize.width
            height: (inInventory && fitInventory) ? 96 : sourceSize.height
        }
    }

    Image {
        id: image
        visible: !invImage.visible
        fillMode: Image.PreserveAspectFit
        source: root.adaptiveSource

        width: (inInventory && fitInventory) ? 96 : sourceSize.width
        height: (inInventory && fitInventory) ? 96 : sourceSize.height
    }

    onClicked: {
        if(!inInventory && autoInventory)
            addToInventory()
        game.objectClicked(root)

        if(description !== "")
            game.setText(description)
    }

    DropSpot {
        id: dropSpot
        anchors { fill: parent }
        enabled: acceptDrops
        keys: ['notcombinable']
        onDropped: {
            drop.accept()
            game.objectCombined(root,drag.source)
        }
    }

    function dump() {
        console.log(name)
        for(var i in root) {
            if(!Aid.isFunction(root[i]))
                console.log(i,':',root[i])
        }
    }

}
