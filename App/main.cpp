#include "qak.h"

#include "src/fileio.h"
#include "src/fpstext.h"

#include <QtQml>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<FPSText, 1>("FPSText", 1, 0, "FPSText");

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Black Grain");
    app.setOrganizationDomain("blackgrain.dk");
    app.setApplicationName("Dead Ascend");

    #ifdef VERSION
    app.setApplicationVersion(QString(VERSION));
    #endif

    QQmlApplicationEngine engine;

    #ifdef QT_DEBUG
        engine.rootContext()->setContextProperty("debugBuild", QVariant(true));
    #else
        engine.rootContext()->setContextProperty("debugBuild", QVariant(false));
    #endif

    engine.addImportPath("qrc:///");

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
