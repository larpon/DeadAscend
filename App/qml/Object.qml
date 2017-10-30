import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0

import "."

Entity {
    id: root

    width: image.width
    height: image.height

    property real margins: core.defaultMargins
    onInputChanged: { if(input) input.anchors.margins = margins }
    onMarginsChanged: { if(input) input.anchors.margins = margins }

    clickable: !mover.moving
    draggable: !mover.moving
    source: itemSource

    property alias store: store
    property bool stateless: name == ""

    property bool ready: store.isLoaded
    property bool autoInventory: true
    property bool hideInventoryOnDrag: false
    property bool acceptDrops: false
    property bool useFallbackSounds: true

    property string itemSource: ''
    property string iconSource: guessIcon(itemSource)

    property var sounds: ({})
    property var soundMap: ({})

    property string name: ""
    property string description: ""
    property string scene: ""
    property string at: ""
    property string _at: ""
    property int _z: 0

    onAtChanged: App.debug('Object',name,'at',at)
    on_AtChanged: App.debug('Object',name,'came from',_at)

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
        z = 100
        game.objectDragged(root)
        play('onDragged')

        if(hideInventoryOnDrag && _at === "inventory") {
            game.inventory.show = false
        }

    }

    /*
    onDragEnded: {
        z = 0
    }
    */

    signal inventoryDragAccepted(variant mouse, var target)

    onInventoryDragAccepted: {
        if('name' in target)
            at = target.name
        if(at !== 'inventory')
            removeFromInventory()
        z = _z
        scene = game.currentScene
        game.objectDropped(root)
        play('onDropped')
    }

    onDragAccepted: {
        if('name' in Drag.target)
            at = Drag.target.name
        if(at !== 'inventory')
            removeFromInventory()
        z = _z
        scene = game.currentScene
        game.objectDropped(root)
        play('onDropped')
    }

    onDragReturned: {
        at = _at
        z = _z
        game.objectReturned(root)
        play('onReturned')
    }

    function play(tag) {
        if(tag in soundMap)
            tag = soundMap[tag]

        if(tag in sounds)
            core.sounds.play(tag,"object/"+name)
        else {
            if(core.sounds.has(tag))
                core.sounds.play(tag)
            else if(useFallbackSounds)
                core.sounds.play('add')
        }
    }

    function removeFromInventory() {
        if(game.inventory.has(root)) {
            mover.duration = 0
            game.inventory.removeVisual(root)
            game.inventory.remove(root)
        }
    }

    function addToInventory() {
        if(!game.inventory.has(root)) {
            scene = ""
            dragReturnAnimation.complete()
            game.objectTravelingToInventory(root)
            mover.duration = 500
            game.inventory.addAnimated(root)
        }
    }

    property bool fitInventory: false
    property bool inInventory: at === 'inventory'
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
        property alias sounds: root.sounds
        property alias soundMap: root.soundMap
        //property alias hideInventoryOnDrag: root.hideInventoryOnDrag

    }

    Component.onCompleted: {
        load()
        if(Aid.objectSize(sounds) > 0 && name !== "") {
            var sfx = core.sounds
            for(var tag in sounds) {
                sfx.add("object/"+name,tag,sounds[tag])
            }
        }

        // Ugly way to set bigger margins on some particular small objects
        if(name === "coin")
            margins = core.defaultMargins - 20
        if(name === "bubblegum")
            margins = core.defaultMargins - 20

    }
    Component.onDestruction: {
        core.sounds.clear("object/"+name)
        save()
    }

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
        play('onClicked')
        game.objectClicked(root)

        autoDescription()
    }

    function autoDescription() {
        description = App.eTr(description)
        if(Aid.isString(description) && description !== "")
            game.setText(description)
        if(Aid.isArray(description) && description.length > 0)
            game.setText.apply(this, description)
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
