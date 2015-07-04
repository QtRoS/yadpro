#include "networkmanager.h"

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent),
      m_downloadReply(NULL),
      m_uploadReply(NULL),
      m_downloadError(QNetworkReply::NoError),
      m_uploadError(QNetworkReply::NoError)
{ }

NetworkManager::~NetworkManager()
{ }

bool NetworkManager::download(const QString &url, const QString& localFile)
{
    if (m_downloadReply != NULL)
    {
        qDebug() << "DOWNLAOD ALREADY IN PROGRESS";
        return false;
    }

    if (m_downloadFile.isOpen())
        m_downloadFile.close();

    qDebug() << "DOWNLOAD FILE NAME: " << localFile;

    m_downloadFile.setFileName(localFile);
    if (!m_downloadFile.open(QIODevice::Truncate | QIODevice::WriteOnly))
    {
        qDebug () << "FILE FOR WRITING OPEN ERROR:" << localFile;
        return false;
    }

    makeRequest(url, OpDownload);

    return true;
}

bool NetworkManager::upload(const QString &url, const QString& localFile)
{
    if (m_uploadReply != NULL)
    {
        qDebug() << "UPLOAD ALREADY IN PROGRESS";
        return false;
    }

    if (m_uploadFile.isOpen())
        m_uploadFile.close();

    QString norm = localFile;
    if (norm.startsWith("file://"))
        norm = norm.remove(0, 7);
    qDebug() << "UPLOAD FILE NAME: " << norm;

    m_uploadFile.setFileName(norm);
    if (!m_uploadFile.open(QIODevice::ReadOnly))
    {
        qDebug () << "FILE FOR READING OPEN ERROR:" << norm;
        return false;
    }

    makeRequest(url, OpUpload);

    return true;
}

void NetworkManager::abort()
{
    abortDownload();
    abortUpload();
}

void NetworkManager::abortDownload()
{
    if (m_downloadReply)
        m_downloadReply->abort();
}

void NetworkManager::abortUpload()
{
    if (m_uploadReply)
        m_uploadReply->abort();
}

void NetworkManager::slotDownloadProgress(qint64 get, qint64 total)
{
    qDebug() << "DOWNLOAD PROGRESS" << get << total;
    emit downloadOperationProgress(get, total);
}

void NetworkManager::slotUploadProgress(qint64 sent, qint64 total)
{
    qDebug() << "UPLOAD PROGRESS" << sent << total << "sender" << sender();
    emit uploadOperationProgress(sent, total);
}

void NetworkManager::slotDownloadDataAvailable()
{
    if (!m_downloadReply)
    {
        qDebug() << "OMG REPLY IS NULL";
        return;
    }

    qint64 dataLen = m_downloadReply->bytesAvailable();
    m_downloadFile.write(m_downloadReply->read(dataLen));
}

void NetworkManager::slotDownloadError(QNetworkReply::NetworkError code)
{
    qDebug() << "slotDownloadError" << code;
    m_downloadError = code;
}

void NetworkManager::slotUploadError(QNetworkReply::NetworkError code)
{
    qDebug() << "slotUploadError" << code;
    m_uploadError = code;
}

void NetworkManager::slotDownloadFinished()
{
    qDebug() << "slotDownlaodFinished";
    // qDebug() << m_reply->rawHeaderPairs();

    int status = m_downloadReply->attribute( QNetworkRequest::HttpStatusCodeAttribute ).toInt();
    QString location = m_downloadReply->rawHeader("Location");
    // REDIRECT.
    if (status / 100 == 3 || !location.isEmpty())
    {
        qDebug() << "REDIRECT: " << location;
        cleanup(OpDownload, true);
        makeRequest(location, OpDownload);
    }
    else
    {
        QNetworkReply::NetworkError error = m_downloadError;
        cleanup(OpDownload);

        // In case of aborting do not call finished signal.
        if (error == QNetworkReply::OperationCanceledError)
            return;

        emit downloadOperationFinished(error == QNetworkReply::NoError ? "success" : "failed");
    }
}

void NetworkManager::slotUploadFinished()
{
    qDebug() << "slotUploadFinished";
    // qDebug() << m_reply->rawHeaderPairs();

    QNetworkReply::NetworkError error = m_uploadError;
    cleanup(OpUpload);

    // In case of aborting do not call finished signal.
    if (error == QNetworkReply::OperationCanceledError)
        return;

    emit uploadOperationFinished(error == QNetworkReply::NoError ? "success" : "failed");
}

void NetworkManager::cleanup(Operation operation, bool soft)
{
    if (operation == OpUpload)
    {
        if (!soft && m_uploadFile.isOpen())
            m_uploadFile.close();

        disconnect(m_uploadReply, SIGNAL(uploadProgress(qint64,qint64)),
                this, SLOT(slotUploadProgress(qint64,qint64)));

        disconnect(m_uploadReply, SIGNAL(finished()),
                this, SLOT(slotUploadFinished()));

        disconnect(m_uploadReply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotUploadError(QNetworkReply::NetworkError)));

        if (m_uploadReply)
            m_uploadReply->deleteLater();
        m_uploadReply = NULL;
        m_uploadError = QNetworkReply::NoError;
    }
    else
    {
        if (!soft && m_downloadFile.isOpen())
            m_downloadFile.close();

        disconnect(m_downloadReply, SIGNAL(downloadProgress(qint64,qint64)),
                this, SLOT(slotDownloadProgress(qint64,qint64)));

        disconnect(m_downloadReply, SIGNAL(readyRead()),
                this, SLOT(slotDownloadDataAvailable()));

        disconnect(m_downloadReply, SIGNAL(finished()),
                this, SLOT(slotDownloadFinished()));

        disconnect(m_downloadReply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotDownloadError(QNetworkReply::NetworkError)));

        if (m_downloadReply)
            m_downloadReply->deleteLater();
        m_downloadReply = NULL;
        m_downloadError = QNetworkReply::NoError;
    }
}

void NetworkManager::makeRequest(const QString &url, Operation operation)
{
    QUrl reqUrl(url);
    QNetworkRequest req(reqUrl);
    // req.setRawHeader("Authorization", "OAuth " + m_token.toLatin1());

    if (operation == OpUpload)
    {
        req.setRawHeader("Content-Type", "application/binary");
        req.setRawHeader("Content-Length", (QString::number(m_uploadFile.size()).toLatin1()));
        m_uploadReply = m_man.put(req, &m_uploadFile);

        connect(m_uploadReply, SIGNAL(uploadProgress(qint64,qint64)),
                this, SLOT(slotUploadProgress(qint64,qint64)));

        connect(m_uploadReply, SIGNAL(finished()),
                this, SLOT(slotUploadFinished()));

        connect(m_uploadReply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotUploadError(QNetworkReply::NetworkError)));
    }
    else
    {
        m_downloadReply = m_man.get(req);

        connect(m_downloadReply, SIGNAL(downloadProgress(qint64,qint64)),
                         this, SLOT(slotDownloadProgress(qint64,qint64)));

        connect(m_downloadReply, SIGNAL(readyRead()),
                this, SLOT(slotDownloadDataAvailable()));

        connect(m_downloadReply, SIGNAL(finished()),
                this, SLOT(slotDownloadFinished()));

        connect(m_downloadReply, SIGNAL(error(QNetworkReply::NetworkError)),
                this, SLOT(slotDownloadError(QNetworkReply::NetworkError)));
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
