import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import "."
import "menus"

Item {
    id: game

    anchors { fill: parent }

    paused: core.paused
    onPausedChanged: {
        App.debug('Game',paused ? 'paused' : 'continued') //¤
        if(paused) {

            store.save()
        }

    }

    property bool ready: (scene && scene.ready)

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
    property string previousScene: ""
    property Item scene: sceneLoader.item
    property var sceneData

    property var dynamicLoaded: ({})
    property var objectBlacklist: ({})
    property var objectSpawnlist: ({})
    property var staticObjects: ({})

    property string scene2type: "right"
    property int flaskMixerBlueLevel: 0
    property int flaskMixerPurpleLevel: 0
    property int flaskMixerGreenLevel: 0
    property int flaskMixerRedLevel: 0

    property bool fuelCellCharged: false
    property bool fuelCellConnected: false

    property bool helpCalled: false

    readonly property bool flasksFilled: flaskMixerBlueLevel > 0 && flaskMixerPurpleLevel > 0 && flaskMixerGreenLevel > 0 && flaskMixerRedLevel > 0
    readonly property bool flasksCorrect: flaskMixerBlueLevel == 6 && flaskMixerPurpleLevel == 1 && flaskMixerGreenLevel == 1 && flaskMixerRedLevel == 4
    onFlasksCorrectChanged: if(flasksCorrect) setText(qsTr("All systems... GO!"))

    property bool button8dropped: false

    property alias elevatorPanel: elevatorPanel

    function getObject(name) {
        if(name in dynamicLoaded)
            return dynamicLoaded[name]

        var found = false
        var fObject
        if(scene && 'canvas' in scene) {
            Aid.loopChildren(scene.canvas,function(object) {
                if(found)
                    return

                if('name' in object && object.name === name) {
                    found = true
                    fObject = object
                }
            })
        }
        return fObject
    }

    function isObjectDynamic(name) {
        return (name in dynamicLoaded)
    }

    function isObjectStatic(name) {
        var found = false
        var fObject
        if(scene && 'canvas' in scene) {
            Aid.loopChildren(scene.canvas,function(object) {
                if(found)
                    return

                if('name' in object && object.name === name) {
                    found = true
                    fObject = object
                }
            })
        }
        return found
    }

    function hasObjectExisted(name) {
        return isBlacklisted(name) || getObject(name) !== undefined
    }

    function destroyObject(name) {
        if(name in dynamicLoaded) {
            var o = dynamicLoaded[name]
            o.removeFromInventory()
            o.destroy()
            dynamicLoaded[name] = undefined
        }
    }

    function blacklistObject(name) {
        objectBlacklist[name] = true
        if(isObjectDynamic(name))
            destroyObject(name)
    }

    function unblacklistObject(name) {
        objectBlacklist[name] = false
    }

    function isBlacklisted(name) {
        if(name in objectBlacklist) {
            return (objectBlacklist[name] === true)
        }
        return false
    }

    function clearDynamicallyLoaded() {
        App.debug('clearDynamicallyLoaded','Starting') //¤
        var i, o
        for(i in dynamicLoaded) {
            if(dynamicLoaded[i]) {
                o = dynamicLoaded[i]

                if(o === undefined) {
                    App.warn('clearDynamicallyLoaded','object is undefined. Skipping...')
                    continue
                }

                if(!(o.name)) {
                    App.warn('clearDynamicallyLoaded','object seem invalid. Skipping...')
                    continue
                }

                if(!isBlacklisted(o.name) && Aid.qtypeof(o) === "Object" && !o.inInventory && ('stateless' in o && !o.stateless)) {
                    var name = o.name
                    objectSpawnlist[name] = name
                }

                App.debug('clearDynamicallyLoaded','destroying',o.name) //¤
                o.destroy()
            }
        }
        dynamicLoaded = {}
        App.debug('clearDynamicallyLoaded','Cleared dynamically loaded objects') //¤
    }

    property alias inventory: inventory

    readonly property bool canLoadScene: opacity > 0 && store.isLoaded && inventory.isLoaded && sceneLoader.active && sceneLoader.status === Loader.Ready
    onCanLoadSceneChanged: {
        if(canLoadScene) {
            loadScene()
        }
    }

    Component.onCompleted: {

        if(core.modes.mode.name === "game" && currentScene == "Tutorial") {
            App.debug("Correcting currentScene var") //¤
            previousScene = ""
            currentScene = "0"
        }

        store.load()

        if(core.modes.mode.name === "game-tutorial") {
            App.debug("Going into tutorial mode") //¤
            previousScene = currentScene
            currentScene = "Tutorial"
            inventory.name = "inventoryTutorial"
            inventory.persistent = false
        }

        inventory.load()
    }

    Component.onDestruction: {
        if(currentScene == "Tutorial") {
            currentScene = previousScene
            inventory.clear()
        }
        clearDynamicallyLoaded()

        save()
    }

    function save() {
        inventory.save()
        store.save()
    }

    signal objectReady(var object)
    signal objectDragged(var object)
    signal objectDropped(var object)
    signal objectCombined(var object, var otherObject)
    signal objectClicked(var object)
    signal objectReturned(var object)
    signal objectTravelingToInventory(var object)
    signal objectAddedToInventory(var object)
    signal objectRemovedFromInventory(var object)

    JSONReader {
        id: jsonReader
    }

    Statistics {
        id: sessionStatistics
    }

    Store {
        id: store
        name: "game"

        property alias currentScene: game.currentScene
        property alias objectBlacklist: game.objectBlacklist
        property alias objectSpawnlist: game.objectSpawnlist
        property alias scene2type: game.scene2type

        property alias flaskMixerBlueLevel: game.flaskMixerBlueLevel
        property alias flaskMixerPurpleLevel: game.flaskMixerPurpleLevel
        property alias flaskMixerGreenLevel: game.flaskMixerGreenLevel
        property alias flaskMixerRedLevel: game.flaskMixerRedLevel

        property alias button8dropped: game.button8dropped

        property alias fuelCellCharged: game.fuelCellCharged
        property alias fuelCellConnected: game.fuelCellConnected

        property alias helpCalled: game.helpCalled
    }

    Modes {
        id: modes

        Mode {
            name: 'in-game'
            onEnter: sceneLoader.opacity = 1
            onLeave: sceneLoader.opacity = 0
        }

    }

    function goToScene(scene) {
        loadingScreen.show = true
        previousScene = currentScene
        clearDynamicallyLoaded()
        sceneLoader.active = false
        sceneLoadDelayed.scene = scene
        sceneLoadDelayed.restart()
    }

    readonly property bool sceneUnloaded: !sceneLoader.active || !sceneLoader.status === Loader.Ready
    onSceneUnloadedChanged: {
        if(sceneUnloaded) {
            App.debug('Scene unloaded',currentScene) //¤
            if(currentScene == "Tutorial") {
                inventory.clear()
            }
            clearDynamicallyLoaded()
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

            if(!('__read' in object)) {

                if('properties' in object) {
                    Aid.extend(object,object.properties)
                    // NOTE using delete will hit QTBUG-62666
                    //delete object.properties
                    //delete object.propertytypes

                }

                if('type' in object) {

                    if(object.type !== "Area") {
                        // NOTE FIX tileset - tiled coordinates are origin Bottom Left
                        object.y = object.y-object.height
                    } else {
                        // NOTE fix areas using tileset images - ah maaan
                        if("tileId" in object) {
                            object.y = object.y-object.height
                        }
                    }

                    if(object.type === "Object") {
                        // NOTE set scene the object is spawned on
                        object.scene = game.currentScene
                    }
                }


                if('combines' in object) {
                    object.keys = JSON.parse(object.combines)
                    // NOTE using delete will hit QTBUG-62666
                    //delete object.combines
                }

                if("tileId" in object && 'image' in tiles[object.tileId]) {
                    object.itemSource = App.getAsset(tiles[object.tileId].image.replace("../",''))
                    // NOTE using delete will hit QTBUG-62666
                    //delete object.tileId
                }

                if("ellipse" in object) {
                    // NOTE using delete will hit QTBUG-62666
                    //delete object.ellipse
                }

                if("sounds" in object && !Aid.isObject(object.sounds)) {
                    var sounds = JSON.parse(object.sounds)
                    for(var tag in sounds) {
                        sounds[tag] = App.getAsset(sounds[tag])
                    }

                    object.sounds = sounds
                }

                if("soundMap" in object && !Aid.isObject(object.soundMap)) {
                    object.soundMap = JSON.parse(object.soundMap)
                }

                if("description" in object && Aid.startsWith(object.description,"[\n")) {
                    object.description = JSON.parse(object.description)
                }

                object.__read = true
            }
        }

        initializeObjects(objects)

        //App.debug(App.serialize(objects))

        loadingScreen.show = false
    }

    function initializeObjects(objects) {

        staticObjects = {}

        var i, fromScene = {}, component
        Aid.loopChildren(scene.canvas,function(object) {
            if('name' in object) {
                if(isBlacklisted(object.name)) {
                    App.debug('Object',object.name,'is blacklisted. Hidding...') //¤
                    object.visible = false
                    return
                }

                staticObjects[object.name] = object
            }
        })

        for(i in objects) {
            var object = objects[i]
            if(object.name in staticObjects) {
                var staticObject = staticObjects[object.name]

                // NOTE Object already has a state saved on disk - skip setting values
                if(Aid.qtypeof(staticObject) === "Object" && staticObject.store.existOnDisk()) {
                    App.debug('Static object',staticObject.name,'already has a state saved on disk. Skipping...') //¤
                    continue
                }

                App.debug('Correcting static object',staticObject.name,'from scene data') //¤
                setProperties(staticObject,object,true)


            } else {
                fromScene[object.name] = true
                spawnObject(object)
            }
        }

        // NOTE go through inventory and spawn any objects from other scenes
        var ic = inventory.contents, object

        for(i in ic) {
            object = ic[i]

            if(isBlacklisted(object.name)) {
                App.debug('Object',object.name,'is blacklisted. Skipping...') //¤
                continue
            }

            if(!fromScene[object.name]) {
                var attrs = {
                    'name': object.name,
                }
                if('itemSource' in object)
                    attrs.itemSource = object.itemSource

                component = objectComponent

                App.debug('Spawning dynamic object from INVENTORY',attrs.name) //¤
                Incubate.now(component, scene.canvas, attrs, function(o){
                    App.debug('Spawned dynamic INVENTORY object',o.name,o) //¤
                    inventory.add(o)

                    dynamicLoaded[o.name] = o
                })
            }
        }

        // NOTE go through loose objects and spawn
        var os = objectSpawnlist
        for(var name in os) {

            if(isBlacklisted(name)) {
                App.debug('Object',name,'is blacklisted. Skipping...') //¤
                continue
            }

            if(!fromScene[name]) {
                var attrs = {
                    'name': name,
                }

                component = objectComponent

                App.debug('SPAWNED Dynamic object',attrs.name,'prepared') //¤
                Incubate.now(component, scene.canvas, attrs, function(o){
                    App.debug('SPAWNED Dynamic object',o.name,o.draggable,o.z) //¤

                    if(o.scene !== currentScene) {
                        App.debug("I'm not currently here. Bye",o.name) //¤
                        o.destroy()
                        return
                    }

                    dynamicLoaded[o.name] = o

                })
            }

        }
    }

    function spawnObject(object,onSpawned) {

        if(isBlacklisted(object.name)) {
            App.debug('Object',object.name,'is blacklisted. Not spawning...') //¤
            return
        }

        if(!('type' in object)) {
            App.warn("No TYPE attribute in",object.name,"Skipping...")
            return
        }

        if(!(object.type === "Object" || object.type === "Area")) {
            App.warn(object.type,"is not a supported OBJECT spawn type",object.name,"Skipping...")
            return
        }

        var attrs = { }
        setProperties(attrs,object)

        var component = objectComponent
        if(object.type === "Area")
            component = areaComponent

        Incubate.now(component, scene.canvas, attrs, function(o){
            App.debug('Spawned dynamic object',o.name,o) //¤
            if(inventory.has(o)) {
                inventory.add(o)
            }
            dynamicLoaded[o.name] = o
            if (typeof onSpawned === "function") {
                onSpawned(o)
            }
        })
    }

    function setProperties(to,from,onlySetIfExist) {
        var excludes = ['id','gid','__read','visible']
        for(var p in from) {
            if(excludes.indexOf(p) > -1)
                continue

            if(onlySetIfExist) {
                if(p in to) {
                    to[p] = from[p]
                    //App.debug('Property e',p,'from',from.name)
                }
            } else {
                to[p] = from[p]
                //App.debug('Property',p,'from',from.name)
            }

        }
    }

    Component {
        id: objectComponent
        Object {

        }
    }

    Component {
        id: areaComponent
        Area {

        }
    }

//    Rectangle {
//        anchors { fill: parent }
//        color: "black"
//    }

    // NOTE Hack to fix a stupid design error - leading to some unexpected scene loads
    //
    Timer {
        running: sceneLoader.active
        interval: 1000
        onTriggered: {
            App.debug('FIX setting',sceneLoader.source,'to','scenes/'+game.currentScene+'.qml') //¤
            sceneLoader.source = 'scenes/'+game.currentScene+'.qml'
        }
    }

    Timer {
        id: sceneLoadDelayed
        interval: 500
        property string scene: ""
        onTriggered: {
            game.currentScene = scene
            sceneLoader.active = true
        }
    }

    Loader {
        id: sceneLoader
        anchors { fill: parent }

        source: ""

        active: opacity > 0
        onActiveChanged: {
            if(!active)
                source = ""
        }

        visible: status == Loader.Ready && opacity > 0

        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 1500 }
        }

    }


    Entity {
        id: elevatorPanel

        anchors { fill: parent }

        property bool show: false

        visible: opacity > 0
        opacity: show ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        Rectangle {
            anchors { fill: parent }
            color: core.colors.black
            opacity: 0.8
        }

        MouseArea {
            anchors { fill: parent }
            onClicked: elevatorPanel.show = false
        }

        Image {
            anchors {
                top: parent.top
                right: parent.right
            }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("back_button.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: elevatorPanel.show = false
            }
        }

        Image {
            anchors { centerIn: parent }
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width; height: sourceSize.height
            source: App.getAsset("scenes/elevator_panel/elevator_panel.png")

            MouseArea {
                anchors { fill: parent }
                onClicked: {
                    core.sounds.play('tick')
                    var a = [
                        qsTr("It's clear that the panel is almost completly broken"),
                        qsTr("Luckily the elevator still works - thanks to Mr. Hamster")
                    ]
                    game.setText(Aid.randomFromArray(a))
                }
            }

            Image {
                x: 516; y: 385
                width: 88; height: 66
                fillMode: Image.PreserveAspectFit
                //width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/buttons/button_03/button_03.png")

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        core.sounds.play('tap')
                        if(currentScene != "4") {
                            elevatorPanel.show = false
                            goToScene("4")
                        } else
                            setText(qsTr("You're already at this floor"))
                    }
                }
            }

            Image {
                x: 510; y: 295
                width: 88; height: 66
                fillMode: Image.PreserveAspectFit
                //width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/buttons/button_03/button_03.png")

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        core.sounds.play('tap')
                        if(currentScene != "5") {
                            elevatorPanel.show = false
                            goToScene("5")
                        } else
                            setText(qsTr("You're already at this floor"))
                    }
                }
            }

            Image {
                x: 510; y: 215
                width: 88; height: 66
                fillMode: Image.PreserveAspectFit
                //width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/buttons/button_03/button_03.png")

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        core.sounds.play('tap')
                        if(currentScene != "6") {
                            elevatorPanel.show = false
                            goToScene("6")
                        } else
                            setText(qsTr("You're already at this floor"))
                    }
                }
            }

            Image {
                x: 501; y: 135
                width: 88; height: 66
                fillMode: Image.PreserveAspectFit
                //width: sourceSize.width; height: sourceSize.height
                source: App.getAsset("sprites/buttons/button_03/button_03.png")

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        core.sounds.play('tap')
                        if(currentScene != "7") {
                            elevatorPanel.show = false
                            goToScene("7")
                        } else
                            setText(qsTr("You're already at this floor"))
                    }
                }
            }

            Area {
                stateless: true
                description: [ qsTr("This particular socket is special"), qsTr("It's clear that a button is missing above all the other buttons") ]
                x: 501; y: 60
                width: 88; height: 66

                visible: !button8dropped
            }

            Image {
                x: 501; y: 60
                width: 88; height: 66

                visible: button8dropped

                fillMode: Image.PreserveAspectFit

                source: App.getAsset("sprites/buttons/button_03/button_03.png")

                MouseArea {
                    anchors { fill: parent }
                    onClicked: {
                        core.sounds.play('tap')
                        if(currentScene != "8") {
                            elevatorPanel.show = false
                            goToScene("8")
                        } else
                            setText(qsTr("You're already at this floor"))
                    }
                }
            }


            DropSpot {
                anchors { fill: parent }

                keys: [ "button_8" ]

                name: "button_drop"

                enabled: !button8dropped

                onDropped: {
                    drop.accept()

                    blacklistObject(drag.source.name)
                    button8dropped = true

                    setText(qsTr("Miraculously - it fits. Must be your lucky day!"))
                }
            }

            Image {
                anchors { fill: parent }
                fillMode: Image.PreserveAspectFit
                source: App.getAsset("scenes/elevator_panel/fg_shadow.png")
            }

        }

    }

    /*
    MouseArea {
        id: glslm
        anchors { fill: parent }
        hoverEnabled: true

        property var screenCoords: mapToItem(core,mouseX,mouseY)
        propagateComposedEvents: true
    }


    ShaderEffectSource {
        id: theSource
        sourceItem: sceneLoader
    }

    ShaderEffect {
        id: glsl
        //https://www.shadertoy.com/view/Mlt3Df
        //https://github.com/bh/cool-old-term/blob/master/app/PreprocessedTerminal.qml#L362
        //http://stackoverflow.com/questions/40515921/qt-qml-spotlights-effect/
        width: sceneLoader.width
        height: sceneLoader.height
        property var source: theSource
        property real radius: 0.25
        property size mouse: Qt.size(glslm.screenCoords.x,core.height-glslm.screenCoords.y)
        property size resolution: Qt.size(core.width, core.height)
        onLogChanged: console.log('Shader',log)
        fragmentShader: "
            uniform highp float radius;
            uniform sampler2D source;
            uniform highp vec2 mouse;
            varying highp vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;
            uniform highp vec2 resolution;

            void main() {

                mediump float vecLength = length( ( gl_FragCoord.xy / resolution.x ) - ( mouse.xy / resolution.x ) );

                if( vecLength <= radius )
                {
                    gl_FragColor = texture2D( source, qt_TexCoord0.xy ) * smoothstep( radius, 0.0, vecLength );
                }
                else
                {
                   gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
                }

            }
        "

        Item {
            id: wobbleSlider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 40
            property real value: bar.x / (foo.width - bar.width)
            Item {
                id: foo
                width: parent.width - 4
                height: 6
                anchors.centerIn: parent

                Rectangle {
                    height: parent.height
                    anchors.left: parent.left
                    anchors.right: bar.horizontalCenter
                    color: "blue"
                    radius: 3
                }
                Rectangle {
                    height: parent.height
                    anchors.left: bar.horizontalCenter
                    anchors.right: parent.right
                    color: "gray"
                    radius: 3
                }
                Rectangle {
                    anchors { fill: parent }
                    color: "transparent"
                    radius: 3
                    border.width: 2
                    border.color: "black"
                }

                Rectangle {
                    id: bar
                    x: parent.width/20
                    y: -7
                    width: 20
                    height: 20
                    radius: 15
                    color: "white"
                    border.width: 2
                    border.color: "black"
                    MouseArea {
                        anchors { fill: parent }
                        drag.target: parent
                        drag.axis: Drag.XAxis
                        drag.minimumX: 0
                        drag.maximumX: foo.width - parent.width
                    }
                }
            }
        }
    }
    */

    Image {
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        source: App.getAsset('menu_button.png')
        MouseArea {
            anchors { fill: parent }
            onClicked: core.pauses.user = !core.pauses.user
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
        DropSpot {
            anchors { fill: parent }
            keys: [ "inventory" ]
            name: "inventory"
            onDropped: {
                var o = drag.source
                if(o._at === "inventory")
                    return
                drop.accept()
                o.addToInventory()
            }
        }
    }

    Inventory {
        id: inventory

        paused: game.paused

        scrollable: length > 7

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        property bool show: false
        readonly property bool _show: show && !paused

        on_ShowChanged: core.sounds.play('tick_soft')

        onRemoved: {
            if(length == 1)
                show = false
        }

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
        messages.show = false
        var wpm = 160
        messages.queue = []
        for (var i = 0; i < arguments.length; i++) {
            var wc = arguments[i].split(' ').length
            if(wc <= 2)
                wc = 3
            var showFor = Math.round((wc/wpm)*60*1000)
            messages.queue.push( {
                                    'show': showFor,
                                    'msg':arguments[i],
                                    'of': '('+(i+1)+'/'+arguments.length+')'
                                });
            if(i == 0)
                autoHideTextTimer.interval = showFor
        }
        // Make sure the banner stay away when text is shown
        application.banner.hide()
        messages.show = true
        autoHideTextTimer.restart()
    }

    Image {
        id: messages

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        source: App.getAsset('messagebox.png')

        enabled: _show

        property bool show: false
        readonly property bool _show: show && !game.paused

        property var queue: ([])

        Timer {
            id: autoHideTextTimer
            running: false
            repeat: true
            triggeredOnStart: true
            interval: 3000
            onTriggered: {
                var queue = messages.queue
                if(queue.length > 0) {
                    var o = queue.shift()
                    messageText.text = o.msg
                    if(o.of !== '(1/1)')
                        messageOfText.text = o.of
                    autoHideTextTimer.interval = o.show
                } else {
                    messages.show = false
                    messageText.text = ""
                    messageOfText.text = ""
                    autoHideTextTimer.stop()
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

            onLineLaidOut: {
                messages.height = messageText.height + 20
            }
            /*
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
            */

        }

        Text {
            id: messageOfText

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 10
            }

            color: core.colors.yellow
            style: Text.Outline; styleColor: core.colors.black
            font { family: core.fonts.standard.name; }
            font.pixelSize: 30
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
                App.debug('messages cleared') //¤
                messages.show = false
                messageText.text = ""
                messageOfText.text = ""
                messages.queue = []
            }
        }
    }

    Component {
        id: exitComponent
        Image {
            id: exit
            x: -width; y: -height
            width: 179; height: 173
            source: App.getAsset('exit_button.png')

            property alias delay: exitTimer.interval

            visible: opacity > 0
            opacity: 0
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }

            onOpacityChanged: {
                if(opacity == 0) {
                    exit.destroy()
                }
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

            Component.onDestruction: App.debug('Exit sign is out') //¤
        }
    }

    function showExit(x,y,delay,direction) {

        var attrs = {
            x: x,
            y: y,
            delay: delay,
            opacity: 1
        }

        Incubate.now(exitComponent, game, attrs)
    }

    // Global object combinations
    onObjectCombined: {
        if(object.name === "bucket" && otherObject.name === "bubblegum") {
            combineBucketWithGum(object,otherObject)
        }

        if(object.name === "bubblegum" && otherObject.name === "bucket") {
            combineBucketWithGum(otherObject,object)
        }
    }

    function combineBucketWithGum(bucket,gum) {

        // NOTE these sounds are loaded by scene 0!
        // This is because the sounds on the objects e.g. "generic" will be unloaded
        // This could be fixed by having a "destroyLater" or "blacklistNowDestroyLater" function
        core.sounds.play("gum")
        core.sounds.play("bucket")

        var object = {
            name: "bucket_patched",
            type: "Object",
            x: bucket.x,
            y: bucket.y,
            z: bucket.z,
            sounds: bucket.sounds,
            soundMap: bucket.soundMap,
            description: qsTr("The bucket is patched. No holes!"),
            scene: currentScene,
            itemSource: bucket.itemSource,
        }

        var animate = !bucket.inInventory

        blacklistObject(bucket.name)
        blacklistObject(gum.name)

        game.spawnObject(object,function(o){
            if(animate)
                game.inventory.addAnimated(o)
            else
                game.inventory.add(o)
        })

        setText(qsTr('There we go. A patched bucket!'))
    }


    Pause {
        id: pauseLoader
        anchors { fill: parent }
        //source: 'menus/Pause.qml'
        enabled: opacity > 0

        visible: opacity > 0

        opacity: game.paused ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Rectangle {
        id: loadingScreen

        z: 100

        Timer {
            id: extraTimer
            interval: 1000
            onTriggered: loadingScreen.opacity = 0
        }

        property bool show: false

        onShowChanged: {
            if(show)
                opacity = 1
            else {
                extraTimer.restart()
            }
        }

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
        readonly property bool fullyVisible: opacity >= 1

        anchors { fill: parent }
        color: colors.black

        Image {
            id: loadingImage
            x: parent.halfWidth - halfWidth; y: parent.halfHeight - halfHeight
            source: App.getAsset('load.png')

            SequentialAnimation on y {
                loops: Animation.Infinite

                paused: running && !loadingScreen.visible

                running: true

                // Move from minHeight to maxHeight in 300ms, using the OutExpo easing function
                NumberAnimation {
                    from: loadingImage.y; to: loadingImage.y - 30
                    easing.type: Easing.InCubic; duration: 500
                }

                // Then move back to minHeight in 1 second, using the OutBounce easing function
                NumberAnimation {
                    from: loadingImage.y - 30; to: loadingImage.y
                    easing.type: Easing.OutCubic; duration: 500
                }

            }
        }

    }

}
