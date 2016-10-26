import QtQuick 2.0

import Qak 1.0

Entity {
    id: root

    x: 0; y: 0
    width: image.width; height: image.height

    draggable: true
    source: itemSource

    property string itemSource: ''
    property string iconSource: guessIcon(itemSource)

    property string name: ''

    Drag.keys: [ 'inventory', name ]

    onDragStarted: z = 3
    onDragEnded: z = 0

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
        }
    }

    //visible: !inInventory
    property bool inInventory: false
    property bool fitInventory: false
    onInInventoryChanged: {
        if(inInventory)
            source = iconSource
        else
            source = itemSource
    }

    Store {
        id: store
        name: "objects/"+root.name

        property alias ox: root.x
        property alias oy: root.y
        property alias ovisible: root.visible
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
        id: image
        fillMode: Image.PreserveAspectFit
        source: root.adaptiveSource

        width: (inInventory && fitInventory) ? 96 : sourceSize.width
    }

    onClicked: {
        if(!inInventory)
            addToInventory()
    }

}
