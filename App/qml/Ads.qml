import QtQuick 2.0

import QtFirebase 1.0

Item {
    id: ads

    anchors.fill: parent

    property alias banner: banner
    property alias interstitial: interstitial

    signal adLoaded(string type)
    signal adLoading(string type)
    signal adVisibleChanged(string type, bool visible)

    function bannerVisible(visibility) {
        banner.visible = visibility
    }

    function interstitialVisible(visibility) {
        interstitial.visible = visibility
    }

    function interstitialIsLoaded() {
        return interstitial.loaded
    }

    AdMob {
        appId: Qt.platform.os == "android" ? "ca-app-pub-6606648560678905~8027290070" : "ca-app-pub-6606648560678905~9364422479"

        testDevices: [
            "01987FA9D5F5CEC3542F54FB2DDC89F6"
        ]
    }

    AdMobBanner {
        id: banner
        adUnitId: Qt.platform.os == "android" ? "ca-app-pub-6606648560678905/9504023277" : "ca-app-pub-6606648560678905/1841155673"

        visible: loaded

        width: 320
        height: 50

        request: AdMobRequest {}

        onReadyChanged: if(ready) load()

        onError: {
            // TODO
        }

        onLoadedChanged: {
            if(loaded)
                adLoaded('banner')
        }

        onLoading: adLoading('banner')

        onVisibleChanged: {
            adVisibleChanged('banner',visible)
        }

    }

    AdMobInterstitial {
        id: interstitial
        adUnitId: Qt.platform.os == "android" ? "ca-app-pub-6606648560678905/1980756471" : "ca-app-pub-6606648560678905/1701554870"

        request: AdMobRequest {}

        onReadyChanged: if(ready) load()

        onClosed: load()

        onError: {
            // TODO
        }

        onVisibleChanged: adVisibleChanged('interstitial',visible)

        onLoadedChanged: {
            if(loaded)
                adLoaded('interstitial')
        }

        onLoading: adLoading('interstitial')
    }

}
