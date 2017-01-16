import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: inventory

    property bool persistent: true

    property var key: "key"
    property var properties: []

    readonly property int length: contents.length
    property var contents: []

    property alias name: store.name

    signal added(var object)
    signal notAdded(var object)
    signal removed(var object)
    signal notRemoved(var object)
    signal updated()
    signal cleared()

    Store {
        id: store

        property alias contents: inventory.contents

    }
    property alias isLoaded: store.isLoaded
    function load() { store.load() }
    function save() { if(persistent) store.save() }

    function add(obj) {
        if(has(obj)) {
            App.debug('ObjectStore',obj[key],'already in store. Skipping...')
            notAdded(obj)
            return
        }

        var k = key+''
        var o = {}
        o[k] = obj[key]

        for(var i in properties) {
            var prop = properties[i]
            o[prop] = obj[prop]
        }

        App.debug('ObjectStore','adding',obj[key])
        contents.push(o)
        added(obj)
        var t = contents
        contents = t
        updated()
    }

    function has(obj) {

        var okey = obj
        if(Aid.isObject(obj) && key in obj)
            okey = obj[key]

        for(var i in contents) {
            var ob = contents[i]
            if(ob[key] === okey)
                return true
        }
        return false
    }

    function remove(obj) {

        var okey = obj
        if(Aid.isObject(obj) && key in obj)
            okey = obj[key]

        var r = -1
        for(var i in contents) {
            var o = contents[i]
            if(o[key] === okey) {
                r = i
                break
            }
        }
        if(r >= 0) {
            App.debug('ObjectStore','removing',obj[key])
            contents.splice(r, 1)
            removed(obj)
            var t = contents
            contents = t
            updated()
        } else
            notRemoved(obj)

    }

    function clear() {

        App.debug('ObjectStore','clear',name)
        for(var i in contents) {
            var o = contents[i]
            App.debug('ObjectStore','removing',o.name)
            contents.splice(i, 1)
            removed(o)
            var t = contents
            contents = t
            updated()
        }
        cleared()
    }

}
