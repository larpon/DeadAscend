TEMPLATE = app

!android:!ios: {
    TARGET = DeadAscend
}

QT += qml quick multimedia
!no_desktop: QT += widgets

CONFIG += c++11

# This disable generating subdirs for build modes on Windows
# Works with QtCreator qmake builds - but shit with commandline
# See https://bugreports.qt.io/browse/QTCREATORBUG-13807 for solutions
CONFIG -= debug_and_release

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

CONFIG(release, debug|release) {
    QAK_CONFIG += nowarnings
}
# Import Qak
include(../extensions/qak/qak.pri)

# Make these modules of QtFirebase
QTFIREBASE_CONFIG += analytics admob
# include QtFirebase
include(../extensions/QtFirebase/qtfirebase.pri)

PLATFORMS_DIR = $$PWD/platforms

ios: {

    QMAKE_INFO_PLIST = $$PLATFORMS_DIR/ios/Info.plist

    DISTFILES += \
        $$PLATFORMS_DIR/ios/Info.plist \
        $$PLATFORMS_DIR/ios/GoogleService-Info.plist

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

# Adds extra make target entry for assets
# This is to speed up build process and be more memory efficient
# Remember to actually run it: (custom step in QtCreator, "make assetsrcc" from commandline)
# run from ${buildDir}/App
# /usr/bin/make assetsrcc
//include(assets.pri)

# make git version available to C++ and QML
VERSION=1.1.2
include(../gitversion.pri)

DISTFILES += \
    TODO.md

RESOURCES += \
    base.qrc \
    json.qrc \
    translations.qrc \
    assets.qrc \
    music.qrc 

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
    $$PWD/translations/DeadAscend_da.ts \
    $$PWD/translations/DeadAscend_de.ts \
    $$PWD/translations/DeadAscend_nl.ts 
