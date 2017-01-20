TEMPLATE = app

QT += qml quick multimedia
!no_desktop: QT += widgets

CONFIG += c++11

SOURCES += main.cpp \
    src/fpstext.cpp \
    src/fileio.cpp

HEADERS += \
    src/fpstext.h \
    src/fileio.h

# Additional import path used to resolve QML modules in Qt Creator's code model
# QML_IMPORT_PATH =

# Should be included before extensions
# Default rules for deployment.
include(deployment.pri)

# Import Qak
include(../extensions/qak/qak.pri)

# Make these modules of QtFirebase
QTFIREBASE_CONFIG += analytics admob
# include QtFirebase
include(../extensions/QtFirebase/qtfirebase.pri)

PLATFORMS_DIR = $$PWD/platforms

ios: {

    ios_icon.files = $$files($$PLATFORMS_DIR/ios/icons/AppIcon*.png)
#    ios_icon.path = icons
    QMAKE_BUNDLE_DATA += ios_icon

    itunes_icon.files = $$files($$PLATFORMS_DIR/ios/iTunesArtwork*)
#    ios_icon.path = icons
    QMAKE_BUNDLE_DATA += itunes_icon

    app_launch_images.files = $$PLATFORMS_DIR/ios/LauncherScreen.xib $$files($$PWD/platforms/ios/LaunchImage*.png) $$files($$PWD/platforms/ios/splash_*.png)
    QMAKE_BUNDLE_DATA += app_launch_images

    QMAKE_INFO_PLIST = $$PLATFORMS_DIR/ios/Info.plist

    DISTFILES += \
        $$PLATFORMS_DIR/ios/Info.plist
}

android: {
    ANDROID_PACKAGE_SOURCE_DIR = $$PLATFORMS_DIR/android

    DISTFILES += \
        $$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/build.gradle \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/local.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/google-services.json \
        $$ANDROID_PACKAGE_SOURCE_DIR/src/com/blackgrain/android/deadascend/Main.java \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/apptheme.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/strings.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/drawable/splash.xml

}

# make git version available to C++ and QML
VERSION=0.9.0
include(../gitversion.pri)

DISTFILES += \
    TODO.md

RESOURCES += \
    base.qrc \
    json.qrc \
    assets.qrc \
    assets_scenes.qrc \
    assets_sprites.qrc

unix|macx|win32: {
    RESOURCES += \
        music.qrc
}

lupdate_only {
SOURCES = *.qml \
          *.js \
          qml/*.qml \
          qml/*.js
}
