#ifndef CPPUTILS_H
#define CPPUTILS_H

#include <QObject>
#include <QQuickItem>
#include <QStandardPaths>
#include <QDir>
#include <QDesktopServices>
#include <QStandardPaths>

class CppUtils : public QObject
{
    Q_OBJECT
public:
    explicit CppUtils(QObject *parent = 0);
    ~CppUtils();

    Q_INVOKABLE void copyToClipboard(const QString& text) const;
    Q_INVOKABLE QString prependWithDownloadsPath(const QString& fileName) const;
    Q_INVOKABLE bool openUrlExternally(const QString& url);

    static QObject *cppUtilsSingletoneProvider(QQmlEngine *engine, QJSEngine *scriptEngine);


signals:

public slots:
};

#endif // CPPUTILS_H
