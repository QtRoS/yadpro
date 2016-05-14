#ifndef PREVIEWCACHE_H
#define PREVIEWCACHE_H

#include <QQueue>
#include <QCryptographicHash>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QHash>
#include <QFileInfo>
#include <QDir>
#include <QLoggingCategory>

Q_DECLARE_LOGGING_CATEGORY(PrevCache)

struct QueueItem
{
public:
    QueueItem(const QString& u, const QString& p)
    {
        url = u;
        localPath = p;
    }

    QString url;
    QString localPath;
};

class PreviewCache : public QObject
{
    Q_OBJECT
public:
    explicit PreviewCache(QObject *parent = 0);
    ~PreviewCache();

    Q_PROPERTY(QString token READ token WRITE setToken NOTIFY tokenChanged)
    Q_PROPERTY(bool isBusy READ isBusy WRITE setIsBusy NOTIFY isBusyChanged)
    Q_INVOKABLE QString getByPreview(const QString& preview, bool downloadOnMiss = true);

public:
    QString token() const;
    bool isBusy() const;
    void setToken(const QString& t);
    void setIsBusy(bool v);

signals:
    void operationProgress(qint64 current, qint64 total);
    void tokenChanged();
    void isBusyChanged();

private slots:
    void slotDownloadDataAvailable();
    void slotError(QNetworkReply::NetworkError code);
    void slotFinished();

private:
    void makeRequest(const QString& url);
    void downloadNext();
    QString cacheLocation() const;

    QNetworkAccessManager m_manager;
    QString m_token;

    QHash<QString, QString> m_hash; // <PreviewUrl, MD5>
    bool m_isBusy;

    QFile m_file;
    QNetworkReply* m_reply;
    QQueue<QueueItem> m_queue;
};



#endif // PREVIEWCACHE_H
