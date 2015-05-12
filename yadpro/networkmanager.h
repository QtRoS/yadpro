#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QDir>
#include <QRegExp>


class NetworkManager : public QObject
{
    Q_OBJECT
public:
    explicit NetworkManager(QObject *parent = 0);
    ~NetworkManager();

    Q_INVOKABLE bool download(const QString& url, const QString& localFile = "");
    Q_INVOKABLE bool upload(const QString& url, const QString& localFile);
    Q_INVOKABLE void abort();

    Q_PROPERTY(QString token READ token WRITE setToken)

    const QString& token() const;
    void setToken(const QString& t);

signals:
    void operationProgress(qint64 current, qint64 total);
    void operationFinished(const QString& status);

private slots:
    /* Slots for QNetworkAccessManager. */
    void slotDownloadProgress(qint64 get, qint64 total);
    void slotUploadProgress(qint64 sent, qint64 total);
    void slotDownloadDataAvailable();
    void slotError(QNetworkReply::NetworkError code);
    void slotFinished();

private:
    void cleanup(bool soft = false);
    void makeRequest(const QString& url, bool isUpload = false);

private:
    QString m_token;

    QNetworkAccessManager m_man;
    QFile m_file;
    QNetworkReply* m_reply;
    bool m_isUpload;
};

#endif // NETWORKMANAGER_H
