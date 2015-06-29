import QtQuick 2.4
import YaD.CppUtils 1.0
import "utils/JsModule.js" as JS

Item {
    id: transferManagerRoot

    property ListModel transferModel: ListModel { }

    function addUpload(urls) {
        for (var i = 0; i < urls.length; i++) {
            var obj = { "type" : JS.TRANSFER_UPLOAD, "url" : urls[i],
                "state" : JS.STATE_INITIAL, "operationUrl" : "",
                "name" : JS.getFileName(urls[i]), "progress" : 0 }
            transferModel.insert(0, obj)
        }

        d.doUploadStep()
    }

    function addDownload(urls) {
        for (var i = 0; i < urls.length; i++) {
            var obj = { "type" : JS.TRANSFER_DOWNLOAD, "url" : urls[i],
                "state" : JS.STATE_INITIAL, "operationUrl" : "", "localUrl" : "",
                "name" : JS.getFileName(urls[i]), "progress" : 0 }
            transferModel.insert(0, obj)
        }

        d.doDownloadStep()
    }

    function retry(i) {
        if (i >= transferModel.count)
            return

        var itm = transferModel.get(i)
        itm.state = JS.STATE_INITIAL
        if (itm.type == JS.TRANSFER_DOWNLOAD)
            d.doDownloadStep()
        else d.doUploadStep()
    }

    function stop(i) {
        if (i >= transferModel.count)
            return

        var itm = transferModel.get(i)

        if (itm.type == JS.TRANSFER_DOWNLOAD) {
            if (itm.state === JS.STATE_INPROGRESS)
                networkManager.abortDownload()
            itm.state = JS.STATE_ERROR
            d.doDownloadStep()
        } else {
            if (itm.state === JS.STATE_INPROGRESS)
                networkManager.abortUpload()
            itm.state = JS.STATE_ERROR
            d.doUploadStep()
        }
    }

    function remove(i) {
        stop(i)
        transferModel.remove(i, 1)
    }

    property QtObject d: QtObject {

        property var currentUpload: null
        property var currentDownload: null

        function doUploadStep() {
            // Check if we should pick next task.
            if (!currentUpload || currentUpload.state === JS.STATE_FINISHED ||
                    currentUpload.state === JS.STATE_ERROR) {
                currentUpload = getNextUpload()

                // Nothing to do.
                if (!currentUpload)
                    return
            }

            switch (currentUpload.state)
            {
            case JS.STATE_INITIAL:
                var shortName = JS.getFileName(currentUpload.url)
                var path = JS.combinePath(bridge.currentFolder, shortName)
                bridge.slotUpload(path/*, currentUpload.url*/)
                break;
            case JS.STATE_URLRECEIVED:
                var isSucces = networkManager.upload(currentUpload.operationUrl, currentUpload.url)
                if (!isSucces) {
                    changeUploadState(JS.STATE_ERROR)
                    return
                }
                changeUploadState(JS.STATE_INPROGRESS)
                break;
            case JS.STATE_INPROGRESS:
                break;
            case JS.STATE_FINISHED:
                doUploadStep()
                break;
            case JS.STATE_ERROR:
                break;
            }
            console.log(" -=-=-= UPLOAD STATE", currentUpload.state)
        }

        function doDownloadStep() {
            // Check if we should pick next task.
            if (!currentDownload || currentDownload.state === JS.STATE_FINISHED ||
                    currentDownload.state === JS.STATE_ERROR) {
                currentDownload = getNextDownload()
                console.log(JSON.stringify(currentDownload))

                // Nothing to do.
                if (!currentDownload)
                    return
            }

            switch (currentDownload.state)
            {
            case JS.STATE_INITIAL:
                bridge.slotDownload(/*path,*/ currentDownload.url)
                break;
            case JS.STATE_URLRECEIVED:
                var shortName = JS.getFileName(currentDownload.url)
                currentDownload.localUrl = CppUtils.prependWithDownloadsPath(shortName)
                var isSucces = networkManager.download(currentDownload.operationUrl, currentDownload.localUrl)
                if (!isSucces) {
                    changeDownloadState(JS.STATE_ERROR)
                    return
                }
                changeDownloadState(JS.STATE_INPROGRESS)
                break;
            case JS.STATE_INPROGRESS:
                break;
            case JS.STATE_FINISHED:
                doDownloadStep()
                break;
            case JS.STATE_ERROR:
                break;
            }
        }

        function getNextUpload() {
            for (var i = 0; i < transferModel.count; i++) {
                var itm = transferModel.get(i)
                if (itm.type === JS.TRANSFER_UPLOAD && itm.state === JS.STATE_INITIAL)
                    return itm
            }
        }

        function getNextDownload() {
            for (var i = 0; i < transferModel.count; i++) {
                var itm = transferModel.get(i)
                if (itm.type === JS.TRANSFER_DOWNLOAD && itm.state === JS.STATE_INITIAL)
                    return itm
            }
        }

        function changeUploadState(state) {
            if (currentUpload) {
                currentUpload.state = state
                doUploadStep()
            }
        }

        function changeDownloadState(state) {
            if (currentDownload) {
                currentDownload.state = state
                doDownloadStep()
            }
        }
    } // QtrObject d

    Connections {
        target: bridge
        onJobDone: {
            if (jobResult.code == "download") {
                if (jobResult.isError) {
                    d.changeDownloadState(JS.STATE_ERROR)
                } else {
                    d.currentDownload.operationUrl = jobResult.href
                    d.changeDownloadState(JS.STATE_URLRECEIVED)
                }
            } else if (jobResult.code == "upload") {
                if (jobResult.isError) {
                    d.changeUploadState(JS.STATE_ERROR)
                } else {
                    d.currentUpload.operationUrl = jobResult.href
                    d.changeUploadState(JS.STATE_URLRECEIVED)
                }
            }
        } // jobDone
    }

    Connections {
        target: networkManager

        onDownloadOperationProgress: {
            //console.log("onDownloadOperationProgress", current, total)
            if (d.currentDownload.progress != 100.0 && total == 0)
                d.currentDownload.progress = 100.0
            else d.currentDownload.progress = 100.0 * current / total
        }
        onDownloadOperationFinished: {
            if (status === "success")
                d.changeDownloadState(JS.STATE_FINISHED)
            else d.changeDownloadState(JS.STATE_ERROR)
        }
        onUploadOperationProgress: {
            //console.log("onUploadOperationProgress", current, total)
            if (d.currentUpload.progress != 100.0 && total == 0)
                d.currentUpload.progress = 100.0
            else d.currentUpload.progress = 100.0 * current / total
        }
        onUploadOperationFinished: {
            if (status === "success")
                d.changeUploadState(JS.STATE_FINISHED)
            else d.changeUploadState(JS.STATE_ERROR)
        }
    }
}
