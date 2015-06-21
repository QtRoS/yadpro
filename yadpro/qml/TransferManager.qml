import QtQuick 2.4
import YaD.CppUtils 1.0
import "utils/JsModule.js" as JS

Item {
    id: transferManagerRoot

    property ListModel transferModel: ListModel { }

    function addUpload(urls) {
        for (var i = 0; i < urls.length; i++) {
            var obj = { "type" : JS.TRANSFER_UPLOAD, "url" : urls[i],
                "state" : JS.STATE_INITIAL, "operationUrl" : "" }
            transferModel.insert(0, obj)
        }

        d.doUploadStep()
    }

    function addDownload(urls) {
        for (var i = 0; i < urls.length; i++) {
            var obj = { "type" : JS.TRANSFER_DOWNLOAD, "url" : urls[i],
                "state" : JS.STATE_INITIAL }
            transferModel.insert(0, obj)
        }

        d.doDownloadStep()
    }

    property QtObject d: QtObject {

        property var currentUpload: null
        property var currentDownload: null

        function doUploadStep() {
            // Check if we should pick next task.
            if (!currentUpload || currentUpload.state === JS.STATE_FINISHED) {
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
        }

        function doDownloadStep() {
            // Check if we should pick next task.
            if (!currentDownload || currentDownload.state === JS.STATE_FINISHED) {
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
                var fullFileName = CppUtils.prependWithDownloadsPath(shortName)
                var isSucces = networkManager.download(currentDownload.operationUrl, fullFileName)
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
                d.currentDownload.operationUrl = jobResult.href
                d.changeDownloadState(JS.STATE_URLRECEIVED)
            } else if (jobResult.code == "upload") {
                d.currentUpload.operationUrl = jobResult.href
                d.changeUploadState(JS.STATE_URLRECEIVED)
            }
        } // jobDone
    }

    Connections {
        target: networkManager

        onOperationProgress: console.log("PROGRESS", current, total)
        onOperationFinished:  d.changeUploadState(JS.STATE_FINISHED)
    }
}
