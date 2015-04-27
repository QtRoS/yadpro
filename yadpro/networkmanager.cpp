#include "networkmanager.h"

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent),
      m_reply(NULL)
{

}

NetworkManager::~NetworkManager()
{

}

bool NetworkManager::download(const QString &url, const QString& localFile)
{
    if (m_file.isOpen())
        m_file.close();

    qDebug() << "DOWNLOAD FILE NAME: " << localFile;

    m_file.setFileName(localFile);
    if (!m_file.open(QIODevice::Truncate | QIODevice::WriteOnly))
    {
        qDebug () << "FILE FOR WRITING OPEN ERROR:" << localFile;
        return false;
    }

    makeRequest(url);

    return true;
}

void NetworkManager::upload(const QString &url)
{
    Q_UNUSED(url)
}

void NetworkManager::abort()
{
    if (m_reply)
    {
        m_reply->abort();
    }
}

const QString &NetworkManager::token() const
{
    return m_token;
}

void NetworkManager::setToken(const QString &t)
{
    m_token = t;  
}

void NetworkManager::slotDownloadProgress(qint64 get, qint64 total)
{
    qDebug() << "DOWNLOAD PROGRESS" << get << total;
    emit operationProgress(get, total);
}

void NetworkManager::slotUploadProgress(qint64 sent, qint64 total)
{
    emit operationProgress(sent, total);
}

void NetworkManager::slotDownloadDataAvailable()
{
    if (m_reply == NULL)
    {
        qDebug() << "OMG REPLY IS NULL";
        return;
    }

    qint64 dataLen = m_reply->bytesAvailable();
    m_file.write(m_reply->read(dataLen));
}

void NetworkManager::slotError(QNetworkReply::NetworkError code)
{
    qDebug() << "slotError" << code;
    emit operationFinished("failure");
    cleanup();
}

void NetworkManager::slotFinished()
{
    qDebug() << "slotFinished";
    // qDebug() << m_reply->rawHeaderPairs();

    int status = m_reply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
    QString location = m_reply->rawHeader("Location");
    // REDIRECT.
    if (status / 100 == 3 || !location.isEmpty())
    {
        qDebug() << "REDIRECT: " << location;
        cleanup(true);
        makeRequest(location);
    }
    else
    {
        emit operationFinished("success");
        cleanup();
    }
}

void NetworkManager::cleanup(bool soft)
{
    if (!soft && m_file.isOpen())
        m_file.close();

    disconnect(m_reply, SIGNAL(downloadProgress(qint64,qint64)),
            this, SLOT(slotDownloadProgress(qint64,qint64)));

    disconnect(m_reply, SIGNAL(readyRead()),
            this, SLOT(slotDownloadDataAvailable()));

    disconnect(m_reply, SIGNAL(finished()),
            this, SLOT(slotFinished()));

    disconnect(m_reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));

    if (m_reply)
        m_reply->deleteLater();
    m_reply = NULL;
}

void NetworkManager::makeRequest(const QString &url)
{
    QUrl reqUrl(url);
    QNetworkRequest req(reqUrl);
    req.setRawHeader("Authorization", "OAuth " + m_token.toLatin1());

    m_reply = m_man.get(req);

    connect(m_reply, SIGNAL(downloadProgress(qint64,qint64)),
            this, SLOT(slotDownloadProgress(qint64,qint64)));

    connect(m_reply, SIGNAL(readyRead()),
            this, SLOT(slotDownloadDataAvailable()));

    connect(m_reply, SIGNAL(finished()),
            this, SLOT(slotFinished()));

    connect(m_reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));
}
