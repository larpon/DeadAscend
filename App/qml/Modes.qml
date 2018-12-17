import QtQuick 2.0

import "."

Item {
    id: modes

    property Mode mode: Mode { name: 'none' }
    readonly property Mode noMode: Mode { name: 'none' }

    QtObject {
        id: cache
        property var key: 'name'
        property var c: ({})

        function add(mode) {
            App.debug('Adding',mode.name) //¤
            var t = c
            t[mode[key]] = mode
            c = t
        }

        function get(mode) {

            return c[mode]
        }

        function clear() {
            c = {}
        }
    }

    Component.onCompleted: {
        reload()
        mode.enter(noMode)
    }

    /* TODO
    onDataChanged: {

        cache.clear()
        for(var m in modes.data) {
            var child = modes.data[m]
            if(child && ('name' in child))
                cache.add(child)
        }
    }
    */

    function set(mode) {
        mode = cache.get(mode)

        if(modes.mode)
            modes.mode.leave()

        if(mode) {
            mode.enter(modes.mode)
            modes.mode = mode
        } else {
            App.error('Modes','set mode',mode,'not found')
        }
    }

    function reload() {
        cache.clear()

        var first = true

        for(var m in modes.data) {
            var child = modes.data[m]
            if(child && ('name' in child)) {
                cache.add(child)

                if(first) {
                    modes.mode = child
                    first = false
                }
            }
        }
    }

}
