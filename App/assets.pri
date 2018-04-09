ASSETS_OUT=$$OUT_PWD
android: {
    ASSETS_OUT=$$ANDROID_PACKAGE_SOURCE_DIR/assets
}

assetsTarget.target = assets
assetsTarget.depends = $$PWD/assets.qrc
assetsTarget.commands = $$[QT_HOST_BINS]/rcc -binary -no-compress -o $$ASSETS_OUT/assets.rcc $$PWD/assets.qrc # For multiple commands add: $$escape_expand(\n\t) <command> or && <command>

!ios: {
    #assetsTarget.depends += $$PWD/music.qrc
    assetsTarget.commands += $$PWD/music.qrc
}

Q_COMPRESS_PNG_FILES.name = COMPRESS_PNG_FILES
Q_COMPRESS_PNG_FILES.value = NO
QMAKE_MAC_XCODE_SETTINGS += Q_COMPRESS_PNG_FILES

Q_STRIP_PNG_TEXT.name = STRIP_PNG_TEXT
Q_STRIP_PNG_TEXT.value = NO
QMAKE_MAC_XCODE_SETTINGS += Q_STRIP_PNG_TEXT

ios: {
    # Copy icons to app sandbox root folder
    deployAssets.files += $$files($$PLATFORMS_DIR/ios/icons/AppIcon*.png)
    deployAssets.files += $$files($$PLATFORMS_DIR/ios/iTunesArtwork*)

    # Copy native launcher .xib file and splash_screen files
    deployAssets.files += $$PLATFORMS_DIR/ios/LauncherScreen.xib $$files($$PWD/platforms/ios/LaunchImage*.png)
    deployAssets.files += $$files($$PWD/platforms/ios/splash_*.png)

    # Copy music
    deployAssets.files += $$files($$PWD/assets/sounds/bensound-ofeliasdream.aac)

    QMAKE_BUNDLE_DATA += deployAssets
}


macos|ios: {
    # General assets
    deployment.files += $$ASSETS_OUT/assets.rcc

    #deployment.path =
    QMAKE_BUNDLE_DATA += deployment
}
QMAKE_EXTRA_TARGETS += assetsTarget

!isEmpty(ASSETS_DIR) {
    message("Binary will look for assets in $$ASSETS_DIR")
    DEFINES += ASSETS_DIR=\\\"$$ASSETS_DIR\\\"

    assetInstall.CONFIG += no_check_exist # Generated at build time, so don't check it's existence
    assetInstall.path = $$ASSETS_DIR
    assetInstall.files = $$ASSETS_OUT/assets.rcc
    INSTALLS += assetInstall

}

OTHER_FILES += \
    assets.qrc \
    music.qrc \
