#include "cpputils.h"

#include <QClipboard>
#include <QGuiApplication>

CppUtils::CppUtils(QObject *parent) : QObject(parent)
{

}

CppUtils::~CppUtils()
{

}

void CppUtils::copyToClipboard(const QString& text) const
{
    QGuiApplication::clipboard()->setText(text);
}

QString CppUtils::prependWithDownloadsPath(const QString &fileName) const
{
    QString dirName = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/YaD"; // TODO DownloadLocation
    qDebug() << "DOWNLOAD DIR" << dirName;
    if (!QDir(dirName).exists() && !QDir().mkdir(dirName))
    {
        qDebug() << "CAN'T CREATE DIRECTORY";
        return fileName;
    }

    return QDir::cleanPath(dirName + QDir::separator() + fileName);
}

bool CppUtils::openUrlExternally(const QString &url)
{
    return QDesktopServices::openUrl(QUrl(url));
}

QObject *CppUtils::cppUtilsSingletoneProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    CppUtils *cu = new CppUtils();
    return cu;
}

