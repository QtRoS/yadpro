#include <QStandardPaths>
#include "previewcache.h"

Q_LOGGING_CATEGORY(PrevCache, "PreviewCache")

PreviewCache::PreviewCache(QObject *parent) :
    QObject(parent),
    m_isBusy(false),
    m_reply(0)
{ }

PreviewCache::~PreviewCache()
{ }

QString PreviewCache::getByPreview(const QString &preview,  bool downloadOnMiss)
{
    // --------------- First (and fastest) way - hash ---------------- //

    bool contains = m_hash.contains(preview);
    if (contains)
    {
        QString ret = m_hash[preview];
        if (!ret.isEmpty())
            return QStringLiteral("file:/") + cacheLocation() + QDir::separator() + ret;
    }

    // --------------- Second way - file                    ---------------- //

    QString md5 = QCryptographicHash::hash(preview.toLatin1(), QCryptographicHash::Md5).toHex();
    QString previewPath = cacheLocation() + QDir::separator() + md5;

    QFileInfo fi(previewPath);
    if (fi.exists() && fi.size() > 0 )
    {
        m_hash[preview] = md5;
        return QStringLiteral("file:/") + previewPath;
    }

    // --------------- Last way - network                   ---------------- //

    if (!contains && downloadOnMiss)
    {
        m_hash[preview] = QStringLiteral("");
        m_queue.enqueue(QueueItem(preview, previewPath));

        if (!m_isBusy)
            downloadNext();
    }

    return QString("");
}

void PreviewCache::slotDownloadDataAvailable()
{
    qint64 dataLen = m_reply->bytesAvailable();
    qint64 written = m_file.write(m_reply->read(dataLen));
    qCDebug(PrevCache) << "Downloading" << QFileInfo(m_file).fileName() << "available" << dataLen << "written" << written;
}

void PreviewCache::makeRequest(const QString &url)
{
    QUrl reqUrl(url);
    QNetworkRequest req(reqUrl);

    req.setRawHeader("Authorization", "OAuth " + m_token.toLatin1());
    m_reply = m_manager.get(req);

    connect(m_reply, SIGNAL(readyRead()),
            this, SLOT(slotDownloadDataAvailable()));

    connect(m_reply, SIGNAL(finished()),
            this, SLOT(slotFinished()));

    connect(m_reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));
}

void PreviewCache::downloadNext()
{
    if (m_queue.isEmpty())
    {
        setIsBusy(false);
        return;
    }

    setIsBusy(true);

    QueueItem item = m_queue.dequeue();

    m_file.setFileName(item.localPath);
    if (!m_file.open(QIODevice::Truncate | QIODevice::WriteOnly))
        qCWarning(PrevCache) << "File '" + item.localPath + "' can't be opened:" << m_file.errorString() << m_file.error();

    makeRequest(item.url);
}

QString PreviewCache::cacheLocation() const
{
    static QString cacheLocation;

    if (cacheLocation.isEmpty())
    {
        cacheLocation = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + QStringLiteral("/Previews");

        if (!QDir(cacheLocation).exists() && !QDir().mkdir(cacheLocation))
            qCCritical(PrevCache) << "Can't create directory for previews:" << cacheLocation;
        else qCDebug(PrevCache) << "Cache location:" << cacheLocation;
    }

    return cacheLocation;
}

void PreviewCache::slotError(QNetworkReply::NetworkError code)
{
    qCWarning(PrevCache) << "Download error:" << code << m_reply->errorString();
}

void PreviewCache::slotFinished()
{
    int status = m_reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
    QString location = m_reply->rawHeader("Location");

    m_reply->deleteLater();

    // Check if redirect.
    if (status / 100 == 3 || !location.isEmpty())
    {
        qCDebug(PrevCache) << "Redirected: " << location;
        makeRequest(location);
    }
    else
    {
        m_file.close();
        downloadNext();
    }
}

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- //

QString PreviewCache::token() const
{
    return m_token;
}

bool PreviewCache::isBusy() const
{
    return m_isBusy;
}

void PreviewCache::setToken(const QString &t)
{
    m_token = t;
    emit tokenChanged();
}

void PreviewCache::setIsBusy(bool v)
{
    m_isBusy = v;
    emit isBusyChanged();
}
