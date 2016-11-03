import QtQuick 2.0
import Qak 1.0

Item {
    id: statistics

    property string name: ''
    readonly property string __name: name === "" ? '' : "/"+name

    property bool store: false
    property alias isLoaded: privateMembers.isLoaded

    visible: false

    signal error(string error)

    Store {
        id: privateMembers

        name: "statistics"+statistics.__name

        property var keys: ({})
    }

    Component.onCompleted: if(store) privateMembers.load()
    Component.onDestruction: if(store) privateMembers.save()

    function dump() {
        var keys = privateMembers.keys
        var t = ""
        for(var key in keys) {
            t += key + '=' + keys[key] + "\n"
        }
        console.debug('Statistics dump:\n',t)
    }

    function reset() {
        privateMembers.keys = {}
    }

    function set(key,value) {
        privateMembers.keys[key] = value
    }

    function get(key,defaultValue) {
        if(key in privateMembers.keys)
            return privateMembers.keys[key]
        return defaultValue
    }

    function add(key,value) {
        var keys = privateMembers.keys
        if(!(key in keys)) {
            set(key,value)
            return
        }
        keys[key] += value
    }

    function collect(key,value) {
        var keys = privateMembers.keys
        if(!(key in keys))
            set(key,[])
        if( Object.prototype.toString.call( keys[key] ) === '[object Array]' )
            keys[key].push(value)
        else
            error('Value for key "'+key+'" is not an array')
    }

    function getData() {
        return privateMembers.keys
    }

}
