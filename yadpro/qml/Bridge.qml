import QtQuick 2.4

import "utils/JsModule.js" as JS
import YaD.CppUtils 1.0

BaseBridge {
    id: bridgeObject

    /* Path '/' is equivalent to 'disk:/'.*/
    function slotMoveToFolder(folder) {
        if (isBusy)
            return

        if (folder === "/")
            folder = JS.ROOT_PATH

        //console.log("slotMoveToFolder", folder)
        var tgt = JS.isRootPath(folder) ? folder : JS.combinePath(currentFolder, folder)

        var t = yadApi.getMetaData(tgt, {"sort" : optKeep.sortOrder})
        __addTask(t)
    }

    function slotOneLevelBack() {
        if (JS.isRootPath(currentFolder) || isBusy)
            return

        var slashIndex = currentFolder.lastIndexOf("/")
        var targetPath = currentFolder.substring(0, slashIndex)

        //console.log("slotOneLevelBack", targetPath)

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

    function slotRemove(entry, permanently) {
        __addTask(yadApi.remove(entry, permanently))
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

    function slotDownload(path, meta) {
        __addTask(yadApi.download(path).setMeta("meta", meta))
    }

    function slotUpload(path) {
        __addTask(yadApi.upload(path))
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

    property QtObject yadApi: YadApi {
        id: yadApi

        onResponseReceived: {

            __removeTask(resObj.task)

            if (code != "metadata")
                console.log("Bridge, onResponseReceived:", JSON.stringify(resObj.response))

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

                currentFolder = r.path
                var downloadOnMiss = optKeep.downloadPreviews

                folderModel.clear()
                var items = r._embedded.items

                var itemsToAppend = []
                for(var i = 0; i < items.length; i++) {
                    var itm = items[i]
                    var o = {
                        /* All entries attributes */
                        "href" : itm.path,
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
                        o.preview = previewCache.getByPreview(o.preview, downloadOnMiss)

                    o["iconSource"] = o.isFolder ? "/img/qml/images/folder.png" :
                                                 (o.preview ? o.preview : JS.getImageByFileType(o.displayName))

                    itemsToAppend.push(o)
                }

                folderModel.append(itemsToAppend)

                break;
            case "move":
            case "copy":
            case "create":
            case "remove":
            case "unpublish":
            case "publish":
                __addTask(yadApi.getMetaData(currentFolder, {"sort" : optKeep.sortOrder}))
                break;
            case "download":
            {
                if (resObj.response.href) {
                    jobResult.href = resObj.response.href
                }
                if (resObj.task.meta) {
                    jobResult.meta = resObj.task.meta
                }
            }
            break;
            case "upload":
            {
                if (resObj.response.href) {
                    jobResult.href = resObj.response.href
                }
            }
            break;
            case "saveToDisk":
            {
                console.assert(false, "Save to disk done") // TODO
            }
            break;
            } // switch

            jobDone(jobResult)
        }
    } // API
}
