import QtQuick 2.0
import QtQuick.Window 2.0

import Qak 1.0
import Qak.QtQuick 2.0

Rectangle {
    id: editMode

    anchors { fill: parent }

    enabled: false

    visible: enabled

    border.color: colors.yellow
    border.width: 4

    color: "transparent"

    property var rect
    property point spawnPoint: Qt.point(0,0)

    function spawnRect(x,y) {
        spawnPoint.x = x
        spawnPoint.y = y
        rect = Qt.createQmlObject('import QtQuick 2.0; Rectangle { x: '+x+'; y: '+y+'; color: "transparent"; border.color: "red"; width: 0; height: 0}',
                                           editMode,
                                           "dynamicRect");
    }

    MouseArea {
        anchors { fill: parent }
        enabled: editMode.enabled

        onPressed: {
            outputWindow.visible = false
            editMode.spawnRect(mouse.x,mouse.y)
        }

        onPositionChanged: {
            if(editMode.rect) {
                var dX = mouse.x - editMode.spawnPoint.x
                var dY = mouse.y - editMode.spawnPoint.y

                if(dX >= 0)
                    editMode.rect.width = dX
                else {
                    editMode.rect.x = mouse.x
                    editMode.rect.width = editMode.spawnPoint.x - mouse.x
                }

                if(dY >= 0)
                    editMode.rect.height = dY
                else {
                    editMode.rect.y = mouse.y
                    editMode.rect.height = editMode.spawnPoint.y - mouse.y
                }
            }
        }

        onReleased: {

            outputWindow.visible = true
            outputWindow.genItem(rect)

            editMode.rect.destroy()
            editMode.rect = undefined
        }
    }

    Window {
        id: outputWindow

        visible: false

        width: 300; height: 400

        function genItem(obj) {
            var txt = "\
Item {\n\
    x: "+Math.round(obj.x)+"; y: "+Math.round(obj.y)+"\n\
    width: "+Math.round(obj.width)+"; height: "+Math.round(obj.height)+"\n\
    \n\
}"
            textEdit.text = txt
        }

        TextEdit {
            id: textEdit
            anchors { fill: parent }
            text: ""
        }
    }
}
