#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>

#include "cpputils.h"
#include "networkmanager.h"
#include "previewcache.h"

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

//    static QTranslator translator;
//    if (QLocale::system().name().startsWith(QStringLiteral("ru")))
//    {
//        if( translator.load("lang/languages/lang_ru.qm", ":/") )
//        {
//            if (app.installTranslator(&translator))
//                qDebug() << "Translation file loaded";
//        }
//    }

    QQuickView view;
    QQmlEngine* eng = view.engine();
    qmlRegisterSingletonType<CppUtils>("YaD.CppUtils", 1, 0, "CppUtils", CppUtils::cppUtilsSingletoneProvider);
    eng->rootContext()->setContextProperty("networkManager", new NetworkManager());
    eng->rootContext()->setContextProperty("previewCache", new PreviewCache());
    view.setSource(QUrl(QStringLiteral("qrc:///qml/YaD.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
