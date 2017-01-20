#include "qak.h"

#include "qtfirebase.h"

#if defined(QTFIREBASE_BUILD_ALL) || defined(QTFIREBASE_BUILD_ANALYTICS)
#include "src/qtfirebaseanalytics.h"
# endif // QTFIREBASE_BUILD_ANALYTICS

#if defined(QTFIREBASE_BUILD_ALL) || defined(QTFIREBASE_BUILD_ADMOB)
#include "src/qtfirebaseadmob.h"
# endif // QTFIREBASE_BUILD_ADMOB


#include "src/fileio.h"
#include "src/fpstext.h"

#include <QtQml>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<FPSText, 1>("FPSText", 1, 0, "FPSText");

    #if defined(QTFIREBASE_BUILD_ALL) || defined(QTFIREBASE_BUILD_ANALYTICS)
    qmlRegisterType<QtFirebaseAnalytics>("QtFirebase", 1, 0, "Analytics");
    #endif

    #if defined(QTFIREBASE_BUILD_ALL) || defined(QTFIREBASE_BUILD_ADMOB)
    qmlRegisterType<QtFirebaseAdMob>("QtFirebase", 1, 0, "AdMob");
    qmlRegisterType<QtFirebaseAdMobRequest>("QtFirebase", 1, 0, "AdMobRequest");
    qmlRegisterType<QtFirebaseAdMobBanner>("QtFirebase", 1, 0, "AdMobBanner");
    qmlRegisterType<QtFirebaseAdMobInterstitial>("QtFirebase", 1, 0, "AdMobInterstitial");
    #endif

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Black Grain");
    app.setOrganizationDomain("blackgrain.dk");
    app.setApplicationName("Dead Ascend");

    #ifdef VERSION
    //app.setApplicationVersion(QString(VERSION));
    #endif

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("version", QString(VERSION));
    engine.rootContext()->setContextProperty("gitVersion", QString(GIT_VERSION));

    #ifdef QT_DEBUG
        engine.rootContext()->setContextProperty("debugBuild", QVariant(true));
    #else
        engine.rootContext()->setContextProperty("debugBuild", QVariant(false));
    #endif

    #ifdef QTFIREBASE_BUILD_ADMOB
        engine.rootContext()->setContextProperty("adBuild", QVariant(true));
    #else
        engine.rootContext()->setContextProperty("adBuild", QVariant(false));
    #endif

    engine.addImportPath("qrc:///");

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
