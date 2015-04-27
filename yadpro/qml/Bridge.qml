import QtQuick 2.3
import Ubuntu.DownloadManager 0.1

import "utils/JsModule.js" as JS

QtObject {
    id: bridgeObject

    /*
        This signal emitted when job is done.
        # jobResult
            @ isError
            @ code
            @ response
                !status
                !statusText
     */
    signal jobDone(var jobResult)

    signal operationProgress(int progress)

    /* Temporary storage for all crosstask operations. */
    property var crossTaskStorage: { "localName" : ""}

    property string currentFolder: "/"
    property bool isBusy: taskCount > 0

    property int taskCount: 0
    property var tasks: []

    function slotMoveToFolder(folder) {
        if (isBusy)
            return

        // console.log("slotMoveToFolder", folder)
        var tgt = "/"
        if (folder != "/") {
            if (JS.endsWith(currentFolder, "/"))
                tgt = (currentFolder + folder)
            else tgt = (currentFolder + "/" + folder)
        }

        var t = yadApi.getMetaData(tgt, {"sort" : optKeep.sortOrder})
        __addTask(t)
    }

    function slotOneLevelBack() {
        if (currentFolder == "/" || isBusy)
            return

        var slashIndex = currentFolder.lastIndexOf("/")
        var targetPath = currentFolder.substring(0, slashIndex)

        if (targetPath == "")
            targetPath = "/"

        __addTask(yadApi.getMetaData(targetPath, {"sort" : optKeep.sortOrder}))
    }

    function slotRenameFile(oldName, newName) {
        __addTask(yadApi.moveTo(oldName, newName))
    }

    function slotCopyFile(oldName, newName) {
        __addTask(yadApi.copyTo(oldName, newName))
    }

    function slotCreateFolder(dirName) {
        __addTask(yadApi.createFolder(dirName))
    }

    function slotDelete(entry) {
        __addTask(yadApi.remove(entry))
    }

    function slotUpdate() {
        __addTask(yadApi.getMetaData(currentFolder, {"sort" : optKeep.sortOrder}))
    }

    function slotPublish(path) {
        __addTask(yadApi.publish(path))
    }

    function slotUnpublish(path) {
        __addTask(yadApi.unpublish(path))
    }

    function slotDownload(path, localName) {
        __addTask(yadApi.download(path))
        crossTaskStorage.localName = localName
    }

    function slotSaveToDisk(public_key) {
        __addTask(yadApi.saveToDisk(public_key))
    }

    function slotAbort(code) {
        var i = 0
        while(i < tasks.length) {
            /* If no code passed we should abort all. */
            if (!code || code == tasks[i].code) {
                console.log("ABORTING: ", tasks[i].code, tasks[i].id)
                tasks[i].doc.abort()
                tasks.splice(i, 1)
                continue
            }
            i++
        }

        taskCount = tasks.length
    }

    function slotGetDiskInfo() {
        __addTask(yadApi.diskInformation())
    }

    function __checkPath(path) {
        if (path && path.indexOf("disk:") === 0)
            return path.substr(5)
        else return path
    }

    function __addTask(t) {
        if (!t)
            return
        tasks.push(t)
        taskCount = tasks.length
    }

    function __removeTask(t) {
        for(var i = 0; i < tasks.length; i++) {
            if (tasks[i].id == t.id) {
                tasks.splice(i, 1)
                break
            }
        }
        taskCount = tasks.length
    }

    property QtObject yadApi: YadApi {
        id: yadApi

        onResponseReceived: {

            __removeTask(resObj.task)

            if (code != "metadata")
                console.log(JSON.stringify(resObj.response))

            var jobResult = { "isError" : resObj.isError, "response" : resObj.response, "code" : code }

            if (resObj.isError) {
                jobDone(jobResult)
                return
            }

            switch (code)
            {
            case "metadata":
                var r = resObj.response

                if (!r.path) {
                    console.log("ERROR: ", JSON.stringify(resObj))
                    break
                }

                currentFolder = __checkPath(r.path)

                dirModel.clear()
                var items = r._embedded.items

                var itemsToAppend = []
                for(var i = 0; i < items.length; i++) {
                    var itm = items[i]
                    var o = {
                        /* All entries attributes */
                        "href" : __checkPath(itm.path),
                        "isFolder" : itm.type == "dir",
                        "displayName" : itm.name,
                        "lastModif" : itm.modified,
                        "creationDate" : itm.created,
                        /* Custom attributes */
                        "contentLen" : itm.size ? itm.size : 0,
                        "contentType" : itm.mime_type ? itm.mime_type : "",
                        "publicUrl" : itm.public_url ? itm.public_url : null,
                        "publicKey" : itm.public_key ? itm.public_key : null,
                        "isPublished" : itm.public_key ? true : false,
                        "isSelected" : false,
                        "preview" : itm.preview
                    }

                    if (o.preview)
                        o.preview = previewCache.getByPreview(o.preview)

                    o["iconSource"] = o.isFolder ? "/img/qml/images/folder.png" :
                                                 (o.preview ? o.preview : JS.getImageByFileType(o.displayName))

                    itemsToAppend.push(o)
                }

                dirModel.append(itemsToAppend)

                break;
            case "move":
            case "copy":
            case "create":
            case "delete":
            case "unpublish":
            case "publish":
                __addTask(yadApi.getMetaData(currentFolder, {"sort" : optKeep.sortOrder}))
                break;
            case "download":
            {
                if (resObj.response.href) {

                    if (optKeep.downloadInBrowser) {
                        Qt.openUrlExternally(resObj.response.href)
                    } else {
                        networkManager
//                        var headers = downloader.headers
//                        if (headers)
//                            headers["Authorization"] = "OAuth " + yadApi.accessToken

//                        downloader.download(resObj.response.href)
                    }
                }
            }
            break;
            case "saveToDisk":
            {
                console.assert(false, "Save to disk done") // TODO
            }
            break;
            case "diskInformation":
            {
                //jobDone(resObj.response)
            }
            break;
            } // switch

            jobDone(jobResult)
        }
    } // API

    property ListModel folderModel: ListModel {
        id: dirModel
    }

    property SingleDownload downloader: SingleDownload {
        id: downloader
        onProgressChanged: {
            console.log("downloadInProgress", progress)
            operationProgress(progress)
        }
    }
}


/*

*/
