import QtQuick 2.0

Item {
    id: mode

    property string name: ''
    property bool when: false

    QtObject {
        id: internal
        property Item backWhen
    }
    onWhenChanged: {
        //console.debug('Mode',name,'when',when)
        if(when) {
            internal.backWhen = mode.parent.mode
            mode.parent.set(name)
        } else
            mode.parent.set(internal.backWhen.name)
    }

    signal enter(var previousMode)
    signal leave

    onLeave: console.debug('Leaving mode',name)
    onEnter: console.debug('Entering mode',name,'from',previousMode.name)
}
