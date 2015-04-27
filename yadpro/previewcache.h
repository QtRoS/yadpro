#ifndef PREVIEWCACHE_H
#define PREVIEWCACHE_H

#include <QObject>
#include <QDebug>
#include <QQueue>
#include <QCryptographicHash>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QFileInfo>
#include <QDir>

/* TODO
 * 1. Create a queue of requests.
 * 2. Download previews one by one from queue via m_manager.
 * 3. Save previews in QStandardPaths::CacheLocation with md5 based name.
 * 4. Use hash<url, md5> to speedup md5 getByPreview.
 */

class PreviewCache : public QObject
{
    Q_OBJECT
public:
    explicit PreviewCache(QObject *parent = 0);
    ~PreviewCache();

    Q_PROPERTY(QString token READ token WRITE setToken NOTIFY tokenChanged)
    Q_INVOKABLE QString getByPreview(const QString& preview, bool downloadOnMiss = true);

public:
    QString token() const;
    void setToken(const QString& t);

signals:
    void operationProgress(qint64 current, qint64 total);
    void operationFinished(const QString& status);
    void tokenChanged();


public slots:

private slots:
    void slotDownloadDataAvailable();
    void slotError(QNetworkReply::NetworkError code);
    void slotFinished();



private:
    void makeRequest(const QString& url);

    void requestNextPreview();

    QNetworkAccessManager m_manager;

    QString m_token;


    QFile m_file;
    QNetworkReply* m_reply;
    QQueue<QString> m_queue;

};

#endif // PREVIEWCACHE_H
