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

    CONFIG += resources_big

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
        $$PLATFORMS_DIR/ios/Info.plist \
        $$PLATFORMS_DIR/ios/GoogleService-Info.plist

    #RCC_BINARY_SOURCES += \
    #    $$PWD/assets.qrc

    # You must deploy your Google Play config file
    deployment.files = $$PLATFORMS_DIR/ios/GoogleService-Info.plist $$RCC_BINARY_SOURCES
    deployment.path =
    QMAKE_BUNDLE_DATA += deployment
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
VERSION=1.0.0
include(../gitversion.pri)

DISTFILES += \
    TODO.md

RESOURCES += \
    base.qrc \
    json.qrc

unix|macx|win32|android|ios: {
    RESOURCES += \
        assets.qrc
}

unix|macx|win32: {
    RESOURCES += \
        music.qrc
}

!isEmpty(RCC_BINARY_SOURCES) {
    asset_builder.commands = $$[QT_HOST_BINS]/rcc -binary ${QMAKE_FILE_IN} -o ${QMAKE_FILE_OUT} -no-compress
    asset_builder.depend_command = $$[QT_HOST_BINS]/rcc -list $$QMAKE_RESOURCE_FLAGS ${QMAKE_FILE_IN}
    asset_builder.input = RCC_BINARY_SOURCES
    asset_builder.output = $$OUT_PWD/${QMAKE_FILE_IN_BASE}.qrb
    asset_builder.CONFIG += no_link target_predeps
    QMAKE_EXTRA_COMPILERS += asset_builder
}

lupdate_only {
SOURCES = *.qml \
          *.js \
          qml/*.qml \
          qml/*.js
}
