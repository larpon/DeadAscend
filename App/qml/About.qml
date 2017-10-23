import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."

Rectangle {
    id: credits

    anchors { fill: parent }
    color: "black"

    Component.onCompleted: text.opacity = 1

    TextButton {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
        }

        //: Menu back
        text: qsTr("BACK")

        font.pixelSize: 35

        onClicked: core.goBack();
    }

    Text {
        id: text

        anchors {
            top: parent.top
            left: parent.left
            margins: 20
        }

        color: core.colors.yellow
        style: Text.Outline; styleColor: core.colors.black
        font { family: core.fonts.sans.name; capitalization: Font.MixedCase }
        font.pixelSize: 17
        linkColor: "tomato"
        onLinkActivated: Qt.openUrlExternally(link)
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 1000 }
        }

        text: qsTr('
        Dead Ascend © <font size="1">2016-2017 <a href="http://games.blackgrain.dk">Black Grain</a></font><br>
        Version '+version+' ('+gitVersion+')<br>
        <p>
            An open source game utilizing the cross-platform <a href="https://www.qt.io/">Qt</a> project.<br>
            Game and project source code can be found on <a href="https://github.com/Larpon/DeadAscend">GitHub</a>
        </p>

        <p>
            The game serves as a showcase and example of how you can build a cross-platform game with Qt.<br>
            The source code for the game engine is ~<b>97%</b> QML (including some Javascript) and ~3% C++.<br>
            <br>
            The game uses the following open source projects:
            <ul>
                <li><a href="https://github.com/Larpon/qak">Qak</a> - QML Aid Kit</li>
                <li><a href="https://github.com/Larpon/QtFirebase">QtFirebase</a> - an effort to bring the Google Firebase C++ SDK to Qt</li>
            </ul>
            The game uses the following fonts:
            <ul>
                <li><a href="https://fonts.google.com/specimen/Amatic+SC">Amatic SC</a></li>
                <li><a href="https://fonts.google.com/specimen/Open+Sans?selection.family=Open+Sans">Open Sans</a></li>
            </ul>
            Music:
            <ul>
                <li><a href="http://www.bensound.com">Bensound royalty free music</a></li>
            </ul>
        </p>

        <p>
            <b>Why does the game have ads and collect analytical data?</b><br>
            For 2 purposes:
            <ol>
                <li>Shows developers example use of the open source <a href="https://github.com/Larpon/QtFirebase">QtFirebase</a> project.</li>
                <li>Supports our work at <a href="http://games.blackgrain.dk">Black Grain Games</a>.</li>
            </ol>
            See our <a href="//blackgrain.dk/privacy.html">privacy policy</a> for info on how we handle the data.
        </p>
        ')
    }

}
