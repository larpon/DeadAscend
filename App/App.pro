TEMPLATE = app

QT += qml quick multimedia
#!no_desktop: QT += widgets

CONFIG += c++11

SOURCES += main.cpp \
    src/fpstext.cpp \
    src/fileio.cpp \
    src/languageswitcher.cpp

HEADERS += \
    src/fpstext.h \
    src/fileio.h \
    src/languageswitcher.h

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH +=

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

    # Copy icons to app sandbox root folder
    deployment.files += $$files($$PLATFORMS_DIR/ios/icons/AppIcon*.png)
    deployment.files += $$files($$PLATFORMS_DIR/ios/iTunesArtwork*)

    # Copy native launcher .xib file and splash_screen files
    deployment.files += $$PLATFORMS_DIR/ios/LauncherScreen.xib $$files($$PWD/platforms/ios/LaunchImage*.png)
    deployment.files += $$files($$PWD/platforms/ios/splash_*.png)

    QMAKE_INFO_PLIST = $$PLATFORMS_DIR/ios/Info.plist

    DISTFILES += \
        $$PLATFORMS_DIR/ios/Info.plist \
        $$PLATFORMS_DIR/ios/GoogleService-Info.plist

    # Copy music
    deployment.files += $$files($$PWD/assets/sounds/bensound-ofeliasdream.aac)

    # Add extra make target entry
    # Remeber to actually run it: (custom step in QtCreator)
    # run from ${buildDir}/App
    # /usr/bin/make assets
    assetsTarget.target = assets
    assetsTarget.depends = $$PWD/assets.qrc
    assetsTarget.commands = $$[QT_HOST_BINS]/rcc -binary -no-compress $$PWD/assets.qrc -o $$OUT_PWD/assets.rcc
    QMAKE_EXTRA_TARGETS += assetsTarget

    deployment.files += $$OUT_PWD/assets.rcc
#   PRE_TARGETDEPS += assets # Doesn't work with iOS?

    # You must deploy your own service file from your Firebase console
    deployment.files += $$PLATFORMS_DIR/ios/GoogleService-Info.plist
    #deployment.path =
    QMAKE_BUNDLE_DATA += deployment
}

android: {
    ANDROID_PACKAGE_SOURCE_DIR = $$PLATFORMS_DIR/android

    DISTFILES += \
        $$ANDROID_PACKAGE_SOURCE_DIR/AndroidManifest.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/build.gradle \
        $$ANDROID_PACKAGE_SOURCE_DIR/gradle.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/local.properties \
        $$ANDROID_PACKAGE_SOURCE_DIR/google-services.json \ # You must deploy your own services file from your Firebase console
        $$ANDROID_PACKAGE_SOURCE_DIR/src/com/blackgrain/android/deadascend/Main.java \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/apptheme.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/values/strings.xml \
        $$ANDROID_PACKAGE_SOURCE_DIR/res/drawable/splash.xml

}

# make git version available to C++ and QML
VERSION=1.0.2
include(../gitversion.pri)

DISTFILES += \
    TODO.md

RESOURCES += \
    base.qrc \
    json.qrc \
    translations.qrc

!ios: {
    RESOURCES += \
        assets.qrc
}

!ios: {
    RESOURCES += \
        music.qrc
}

lupdate_only {
SOURCES = *.qml \
          *.js \
          translations/*.qml \
          qml/*.qml \
          qml/*.js
}

TRANSLATIONS += \
    $$PWD/translations/DeadAscend.ts \
    $$PWD/translations/DeadAscend_en.ts \
    $$PWD/translations/DeadAscend_es.ts \
    $$PWD/translations/DeadAscend_da.ts
