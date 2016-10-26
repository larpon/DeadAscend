import QtQuick 2.0

import Qak 1.0
import Qak.QtQuick 2.0

import "."

Item {
    id: inventory

    property var key: "key"
    property var properties: []

    property var contents: []

    signal added(var object)
    signal removed(var object)
    signal updated()

    Store {
        id: store
        name: "inventory"

        property alias contents: inventory.contents

    }
    property alias isLoaded: store.isLoaded
    function load() { store.load() }
    function save() { store.save() }

    function add(obj) {
        if(has(obj)) {
            App.debug(obj[key],'already in inventory. Skipping')
            return
        }

        var k = key+''
        var o = {}
        o[k] = obj[key]

        for(var i in properties) {
            var prop = properties[i]
            o[prop] = obj[prop]
        }

        App.debug('Adding',obj[key],'to inventory')
        contents.push(o)
        added(obj)
        var t = contents
        contents = t
        updated()
    }

    function has(obj) {
        for(var i in contents) {
            var ob = contents[i]
            if(ob[key] === obj[key])
                return true
        }
        return false
    }

    function remove(obj) {
        for(var i in contents) {
            var o = contents[i]
            if(o[key] == obj[key]) {
                App.debug('Remove',obj)
                contents[i] = undefined
                remove(obj)
                var t = contents
                contents = t
                updated()
                return
            }
        }

    }

}
