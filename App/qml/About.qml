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

        text: qsTr('Dead Ascend')+' © <font size="1">'+qsTr('2016-2017')+' <a href="http://games.blackgrain.dk">Black Grain</a></font><br>'+
        qsTr('Version %1 (%2), Qak %3 (%4), QtFirebase %5 (%6), Qt %7').arg(version).arg(gitVersion).arg(qakVersion).arg(qakGitVersion).arg(qtFirebaseVersion).arg(qtFirebaseGitVersion).arg(qtVersion)+'<br>
        <p>
            '+qsTr('An open source game utilizing the cross-platform <a href="https://www.qt.io/">Qt</a> project.')+'<br>'+
            qsTr('Game and project source code can be found on <a href="https://github.com/Larpon/DeadAscend">GitHub</a>')+'
        </p>

        <p>'+
            qsTr('The game serves as a showcase and example of how you can build a cross-platform game with Qt.<br>
            The source code for the game engine is ~<b>97%</b> QML (including some Javascript) and ~3% C++.')+'<br>
            <br>'+
            qsTr('The game uses the following open source projects:')+'
            <ul>
                <li>'+
                //: It's the project titel and subtitles (catch phrases) in English - I have no idea if these should be translated?
                qsTr('<a href="https://github.com/Larpon/qak">Qak</a> - QML Aid Kit')+'</li>
                <li>'+qsTr('<a href="https://github.com/Larpon/QtFirebase">QtFirebase</a> - an effort to bring the Google Firebase C++ SDK to Qt')+'</li>
            </ul>'+
            qsTr('The game uses the following fonts:')+'
            <ul>
                <li><a href="https://fonts.google.com/specimen/Amatic+SC">Amatic SC</a></li>
                <li><a href="https://fonts.google.com/specimen/Open+Sans?selection.family=Open+Sans">Open Sans</a></li>
            </ul>'+
            qsTr('Music:')+'
            <ul>
                <li>'+
                //: It's what he'd like the credits to be - I'm not sure this should be translated?
                qsTr('<a href="http://www.bensound.com">Bensound royalty free music</a>'+'</li>
            </ul>
        </p>')
        + privacyText

        property string privacyText: (adBuild || debugBuild) ?
         '<p>
             '+qsTr('<b>Why does the game have ads and collect analytical data?</b>')+'<br>
             '+qsTr('For 2 purposes:')+'
             <ol>
                 <li>'+qsTr('Shows developers example use of the open source <a href="https://github.com/Larpon/QtFirebase">QtFirebase</a> project.')+'</li>
                 <li>'+qsTr('Supports our work at <a href="http://games.blackgrain.dk">Black Grain Games</a>.')+'</li>
             </ol>
             '+qsTr('See our <a href="//blackgrain.dk/privacy.html">privacy policy</a> for info on how we handle the data.')+'
         </p>' : ''
    }

}
