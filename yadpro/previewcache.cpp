#include "previewcache.h"
#include <QStandardPaths>
PreviewCache::PreviewCache(QObject *parent) : QObject(parent)
{ }

PreviewCache::~PreviewCache()
{ }

void PreviewCache::slotDownloadDataAvailable()
{
    qint64 dataLen = m_reply->bytesAvailable();
    qint64 written = m_file.write(m_reply->read(dataLen));
    qDebug() << "AVAILABLE" << dataLen << "WRITTEN" << written;
}

void PreviewCache::slotError(QNetworkReply::NetworkError code)
{
    qDebug() << "slotError" << code << m_reply->errorString();
    emit operationFinished("failure");
}

void PreviewCache::slotFinished()
{
    qDebug() << "slotFinished";

    int status = m_reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
    QString location = m_reply->rawHeader("Location");

    m_reply->deleteLater();

    // Check if redirect.
    if (status / 100 == 3 || !location.isEmpty())
    {
        qDebug() << "REDIRECT: " << location;
        makeRequest(location);
    }
    else
    {
        emit operationFinished("success");    
        // qDebug() << "operationFinished";
        m_file.close();

        /* Dequeue only after request finish */
        m_queue.dequeue();

        /* Download next preview from queue */
        requestNextPreview();
    }
}

void PreviewCache::makeRequest(const QString &url)
{
    QUrl reqUrl(url);
    QNetworkRequest req(reqUrl);
    // qDebug() << "  MAKE_REQUEST   " ;

    req.setRawHeader("Authorization", "OAuth " + m_token.toLatin1());

    m_reply = m_manager.get(req);

    connect(m_reply, SIGNAL(readyRead()),
            this, SLOT(slotDownloadDataAvailable()));

    connect(m_reply, SIGNAL(finished()),
            this, SLOT(slotFinished()));

    connect(m_reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));
}

void PreviewCache::requestNextPreview()
{
    if (m_queue.isEmpty())
        return;

    QString preview =  m_queue.head();

    QString md5 = QCryptographicHash::hash(preview.toLatin1(), QCryptographicHash::Md5).toHex();

    QString previewPath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + md5;

    m_file.setFileName(previewPath);
    if (!m_file.open(QIODevice::Truncate | QIODevice::WriteOnly))
    {
        qDebug () << "FILE FOR WRITING OPEN ERROR:" << previewPath;
    }

    makeRequest(preview);
}


QString PreviewCache::getByPreview(const QString &preview,  bool downloadOnMiss)
{
    QString md5 = QCryptographicHash::hash(preview.toLatin1(), QCryptographicHash::Md5).toHex();
    // qDebug() << "---- Preview requested" << md5 << m_token; // << preview;

    QString previewPath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/" + md5;

    /* Return path to preview if only there is not this request in queue */
    QFileInfo fileInfo(previewPath);

    bool isExist = fileInfo.exists();
    bool isOpen = isExist ? (m_file.isOpen() && m_file.fileName() == previewPath) : false;
    bool isEmpty =  isExist ? (fileInfo.size() == 0) : false;

    if (isExist && !isOpen && !isEmpty)
    {
        //qDebug() << "FILE_NAMESTRING: " << previewPath;
        return "file:/" + previewPath;
    }
    else if (downloadOnMiss &&
            (!isExist || (!isOpen && isEmpty)))
    {
        /* Put request in queue */
        m_queue.enqueue(preview);

        /* Our request - only in queue, make request themselves */
        if( m_queue.size() == 1)
            requestNextPreview();
    }

    return QString("");
}

QString PreviewCache::token() const
{
    return m_token;
}

void PreviewCache::setToken(const QString &t)
{
    m_token = t;
    emit tokenChanged();
}


