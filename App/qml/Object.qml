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

    visible: !inInventory
    property bool inInventory: false
    property bool fitInventory: false
    onInInventoryChanged: {
        if(inInventory)
            source = iconSource
        else
            source = itemSource
    }

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

    onClicked: game.inventory.add(root,true)

}
