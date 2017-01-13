import QtQuick 2.0

import "."

Item {
    id: confirmDialog

    anchors { centerIn: parent }

    width: parent.width * 0.9
    height: parent.height * 0.9

    enabled: state === "shown"

    property alias text: confirmContent.text

    property string acceptText: qsTr("Ok")
    property string rejectText: qsTr("Cancel")

    signal accepted
    signal rejected

    scale: 0

    state: "hidden"
    // State can be shown or hidden
    states: [
        State {
            name: "hidden"
            PropertyChanges { target: confirmDialog; scale: 0 }
        },
        State {
            name: "shown"
            PropertyChanges { target: confirmDialog; scale: 1 }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "shown"
            NumberAnimation { properties: "scale"; easing.type: Easing.OutElastic; duration: 850 }
        },
        Transition {
            from: "shown"
            to: "hidden"
            NumberAnimation { properties: "scale"; easing.type: Easing.InOutQuad; duration: 450 }
        }
    ]


    Rectangle {
        id: content

        color: core.colors.black

        border.color: core.colors.yellow
        border.width: 20

        radius: 40

        width: parent.width
        height: column.height + 80

        Column {
            id: column
            anchors.centerIn: parent

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                id: confirmContent
                text: ""
                color: core.colors.yellow
                style: Text.Outline; styleColor: core.colors.black
                font { family: core.fonts.standard.name }
                font.pixelSize: content.width * 0.05
            }

            Item { width: 1; height: 40 }

            Row {
                id: row

                Item {
                    width: content.width / 2
                    height: children[0].height

                    TextButton {
                        anchors.centerIn: parent
                        text: acceptText
                        font.pixelSize: content.width * 0.07
                    }

                    MouseArea {
                        anchors { fill: parent }
                        onClicked: {
                            confirmDialog.state = "hidden"
                            accepted()
                        }
                    }
                }

                Item {
                    width: content.width / 2
                    height: children[0].height
                    TextButton {
                        anchors.centerIn: parent
                        text: rejectText
                        font.pixelSize: content.width * 0.07
                    }

                    MouseArea {
                        anchors { fill: parent }
                        onClicked: {
                            confirmDialog.state = "hidden"
                            rejected()
                        }
                    }
                }

            }
        }
    }

}
