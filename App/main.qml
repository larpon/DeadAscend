import QtQuick 2.0

import Qak 1.0

import "qml"

Application {
    id: application
    title: qsTr('Dead Ascend (%1x%2)').arg(width).arg(height)

    visible: false

    width: 1100/1.2
    height: 660/1.2

    color: "white"

    Component.onCompleted: {
        application.screenMode = Qak.platform.isMobile ? 'full' : 'windowed'

        if(App.dbg) {
            application.visible = true
            launcher.visible = true
            back.opacity = 0
        } else {
            if(Qak.platform.isDesktop) {
                application.visible = true
                back.opacity = 1
            } else
                startTimer.start()
        }
    }

    Loader {
        id: launcher
        visible: false
        anchors.fill: parent
        sourceComponent: coreComponent
        focus: true
    }

    Component {
        id: coreComponent
        Core {
            anchors.fill: parent
        }
    }

    View {
        id: view
        visible: back.opacity > 0

        anchors.fill: parent

        mattes: true
        mattesColor: "black"

        viewport.fillMode: Image.PreserveAspectFit
        viewport.width: 1100
        viewport.height: 660

        Item {
            id: back
            anchors.fill: parent
            //color: "white"

            opacity: 0.99

            Behavior on opacity {
                NumberAnimation { duration: 1500 }
            }

            Image {
                id: publisherImage
                width: parent.width * 0.8
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: back.opacity > 0 ? App.getAsset('presents.png') : ''

                Behavior on opacity {
                    NumberAnimation { duration: 500 }
                }
            }

            Image {
                id: studioImage
                opacity: 0
                width: parent.width * 0.8
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: back.opacity > 0 ? App.getAsset('games logo.png') : ''

                Behavior on opacity {
                    NumberAnimation { duration: 1000 }
                }
            }

            Timer {
                id: crossFadeTimer
                running: back.opacity == 1
                interval: 1000
                onTriggered: {
                    publisherImage.opacity = 0
                    studioImage.opacity = 1
                }
            }
        }

    }

    Timer {
        id: launchTimer
        running: false
        interval: 2000
        repeat: true
        onTriggered: {

            if(launcher.status === Loader.Ready) {
                launcher.visible = true
                back.opacity = 0
                running = false
            }
        }
    }

    Timer {
        id: blackGrainTimer
        running: back.opacity == 1
        interval: 3500
        onTriggered: {
            studioImage.opacity = 0
            launchTimer.start()
        }
    }

    Timer {
        id: startTimer
        interval: 2000
        onTriggered: {
            application.visible = true
            back.opacity = 1
        }
    }

    // NOTE Native ad overlays via QtFirebase
    Loader {
        id: adControl

        anchors.fill: parent

        asynchronous: true
        visible: App.useAds
        active: application.visible && App.useAds

        source: 'qrc:///qml/Ads.qml'

        function bannerVisible(visibility) {
            if(!active)
                return
            item.bannerVisible(visibility)
        }

        function interstitialVisible(visibility) {
            if(!active)
                return
            item.interstitialVisible(visibility)
        }

        function interstitialIsLoaded() {
            if(!active)
                return false
            return item.interstitialIsLoaded()
        }

        /*
        Connections {
            target: adControl.item ? adControl.item.banner : null

            onVisibleChanged: {
                //adControl.item.banner.moveTo(view.viewport.x,view.viewport.y)
            }

        }*/

    }

}
