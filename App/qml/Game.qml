import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: game

    anchors { fill: parent }

    paused: App.paused || userPaused
    onPausedChanged: { App.debug('Game',paused ? 'paused' : 'continued') }

    property bool userPaused: false

    visible: opacity > 0
    opacity: o(game.parent)
    Behavior on opacity {
        NumberAnimation { duration: 300 }
    }

    function o(p) {
        if(p && 'opacity' in p) {
            if(p.opacity >= 1)
                return 1
        }
        return 0
    }

    property string currentScene: "0"
    property var sceneData
    property var incubator: Incubator.get()
    property var dynamicLoaded: ({})
    function getObject(name) {
        if(name in dynamicLoaded)
            return dynamicLoaded[name]
    }

    property alias inventory: inventory

    readonly property bool canLoadScene: opacity > 0 && store.isLoaded && inventory.isLoaded && sceneLoader.active
    onCanLoadSceneChanged: if(canLoadScene) loadScene()

    Component.onCompleted: {
        store.load()
        inventory.load()
    }

    Component.onDestruction: {

        for(var i in dynamicLoaded) {
            dynamicLoaded[i].destroy()
        }
        dynamicLoaded = {}

        inventory.save()
        store.save()

    }

    JSONReader {
        id: jsonReader
    }

    Store {
        id: store
        name: "game"

        property alias currentScene: game.currentScene

    }

    Modes {
        id: modes

        Mode {
            name: 'in-game'
            onEnter: sceneLoader.opacity = 1
            onLeave: sceneLoader.opacity = 0
        }

        Mode {
            name: 'pause'
            when: game.paused
            onEnter: onBack(function(){ App.paused = false })
            onLeave: goBack()
        }

    }


    function loadScene() {
        if(!sceneData)
            sceneData = jsonReader.read(App.getAsset('scenes/scenes.json'))

        var layers = sceneData['layers']
        var tilesets = sceneData['tilesets']

        var i, objects, tiles
        for(i in layers) {
            var layer = layers[i]
            if('type' in layer && layer.type === "objectgroup" && 'name' in layer && layer.name === game.currentScene) {
                objects = layer.objects
                break;
            }
        }
        for(i in tilesets) {
            var tileset = tilesets[i]
            if('name' in tileset && tileset.name === game.currentScene) {
                tiles = tileset.tiles
                break;
            }
        }

        for(i in objects) {
            var object = objects[i]

            if('type' in object) {
                if(object.type !== "MouseArea") {
                    // NOTE FIX tiled coordinates are origin Bottom Left
                    object.y = object.y-object.height
                }
            }

            if('properties' in object) {
                Aid.extend(object,object.properties)
                object.properties = undefined
                object.propertytypes = undefined
            }

            if("tileId" in object && 'image' in tiles[object.tileId]) {
                object.itemSource = App.getAsset(tiles[object.tileId].image.replace("../",''))
            }
        }

        initializeObjects(objects)
        //App.debug(App.serialize(objects))
    }

    function initializeObjects(objects) {

        var i, staticObjects = {}, fromScene = {}
        Aid.loopChildren(sceneLoader.item,function(object) {
            if('name' in object) {
                staticObjects[object.name] = object
            }
        })

        for(i in objects) {
            var object = objects[i]
            if(object.name in staticObjects) {
                var staticObject = staticObjects[object.name]
                App.debug('Static object',staticObject.name)
                staticObject.x = object.x
                staticObject.y = object.y
                staticObject.width = object.width
                staticObject.height = object.height
            } else {
                var attrs = {
                    'name': object.name,
                    'x':object.x,
                    'y':object.y,
                    'width': object.width,
                    'height': object.height
                }
                if('itemSource' in object)
                    attrs.itemSource = object.itemSource

                var component = objectComponent

                var notObjectWarn = ''
                if(!('type' in object) || object.type !== "Object")
                    notObjectWarn = "WARNING: NOT OBJECT TYPE"

                App.debug('Dynamic object',attrs.name,'prepared',notObjectWarn)

                fromScene[object.name] = true

                incubator.now(component, sceneLoader.item, attrs, function(o){
                    App.debug('Dynamic object',o.name,o)
                    if(inventory.has(o)) {
                        inventory.add(o)
                    }
                    dynamicLoaded[o.name] = o
                })
            }
        }

        // NOTE go through rest of inventory and spawn any objects from other scenes
        var ic = inventory.contents
        for(i in ic) {
            object = ic[i]

            if(!fromScene[object.name]) {
                var attrs = {
                    'name': object.name,
                }
                if('itemSource' in object)
                    attrs.itemSource = object.itemSource

                component = objectComponent

                App.debug('INVENTORY Dynamic object',attrs.name,'prepared')
                incubator.now(component, sceneLoader.item, attrs, function(o){
                    App.debug('INVENTORY Dynamic object',o.name,o)
                    inventory.add(o)

                    dynamicLoaded[o.name] = o
                })
            }

        }
    }

    Component {
        id: objectComponent
        Object {

        }
    }

    Loader {
        id: pauseLoader
        anchors { fill: parent }
        source: 'menus/Pause.qml'
        active: opacity > 0

        visible: status == Loader.Ready && opacity > 0

        opacity: game.paused ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Loader {
        id: sceneLoader
        anchors { fill: parent }

        source: 'scenes/'+currentScene+'.qml'

        active: opacity > 0

        visible: status == Loader.Ready && opacity > 0

        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 1500 }
        }

    }

    Image {
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        source: App.getAsset('menu_button.png')
        MouseArea {
            anchors { fill: parent }
            onClicked: userPaused = !userPaused
        }
    }

    Image {
        anchors {
            left: parent.left
            bottom: parent.bottom
        }
        source: App.getAsset('inv_button.png')
        MouseArea {
            anchors { fill: parent }
            onClicked: inventory.show = !inventory.show
        }
        DropArea {
            anchors { fill: parent }
            keys: [ "inventory" ]
            onDropped: {
                drag.source.addToInventory()
            }
        }
    }

    Inventory {
        id: inventory

        paused: game.paused

        property bool show: false
        readonly property bool _show: show && !paused

        on_ShowChanged: core.sounds.play('generic')

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

        states: [
            State {
                name: "shown"; when: inventory._show
                AnchorChanges {
                    target: inventory
                    anchors.top: undefined
                    anchors.bottom: game.bottom
                }
            },
            State {
                name: "hidden"; when: !inventory._show
                AnchorChanges {
                    target: inventory
                    anchors.top: game.bottom
                    anchors.bottom: undefined
                }
            }
        ]

        transitions: Transition {
            from: "hidden"; to: "shown"; reversible: true
            AnchorAnimation { duration: 150 }
        }

    }

    function setText(txt) {
        var wpm = 160
        messages.queue = []
        for (var i = 0; i < arguments.length; i++) {
            var wc = arguments[i].split(' ').length;
            messages.queue.push( {
                                    'show': Math.round((wc/wpm)*60*1000),
                                    'msg':arguments[i]
                                });
        }
        messages.show = true
    }

    Image {
        id: messages

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        source: App.getAsset('messagebox.png')


        property bool show: false
        readonly property bool _show: show && !game.paused

        property var queue: ([])

        Timer {
            id: autoHideTextTimer
            running: messages.show
            repeat: true
            triggeredOnStart: true
            interval: 3000
            onTriggered: {
                var queue = messages.queue
                if(queue.length > 0) {
                    var o = queue.shift()
                    autoHideTextTimer.interval = o.show
                    messageText.text = o.msg
                } else {
                    messages.show = false
                    messageText.text = ""
                }
            }

        }


        Text {
            id: messageText

            anchors.centerIn: parent

            color: core.colors.yellow
            style: Text.Outline; styleColor: core.colors.black
            font { family: core.fonts.standard.name; }
            font.pixelSize: 40

            /*
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
            */

        }


        states: [
            State {
                name: "shown"; when: messages._show
                AnchorChanges {
                    target: messages
                    anchors.top: game.top
                    anchors.bottom: undefined
                }
            },
            State {
                name: "hidden"; when: !messages._show
                AnchorChanges {
                    target: messages
                    anchors.top: undefined
                    anchors.bottom: game.top
                }
            }
        ]

        transitions: Transition {
            from: "hidden"; to: "shown"; reversible: true
            AnchorAnimation { duration: 150 }
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: {
                messages.show = false
                messageText.text = ""
                messages.queue = []
            }
        }
    }

    Image {
        id: exit
        x: -width; y: -height
        width: 179; height: 173
        source: App.getAsset('exit_button.png')

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        SequentialAnimation {
            running: exit.visible
            loops: Animation.Infinite
            NumberAnimation {
                target: exit
                property: "y"
                to: exit.y - 20
                duration: 800
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                target: exit
                property: "y"
                to: exit.y + 10
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }

        Timer {
            id: exitTimer
            running: exit.visible
            interval: 3000
            onTriggered: exit.opacity = 0
        }
    }

    function showExit(x,y,delay,direction) {
        exit.x = x - exit.halfWidth
        exit.y = y - exit.halfHeight
        exitTimer.interval = delay
        exit.opacity = 1
    }
}
