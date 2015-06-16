import QtQuick 2.4

import "utils/JsModule.js" as JS

BaseBridge {
    id: bridgeObject

    Component.onCompleted: currentFolder = JS.TRASH_ROOT_PATH

    /* Path '/' is equivalent to 'trash:/' .*/
    function slotMoveToFolder(folder) {
        if (isBusy)
            return

        if (folder === "/")
            folder = JS.TRASH_ROOT_PATH

        var tgt = JS.isRootPath(folder) ? folder : JS.combinePath(currentFolder, folder)

        var t = yadApi.trashGetMetadata(tgt, {"sort" : optKeep.sortOrder})
        __addTask(t)
    }

    function slotOneLevelBack() {
        if (JS.isRootPath(currentFolder) || isBusy)
            return

        var slashIndex = currentFolder.lastIndexOf("/")
        var targetPath = currentFolder.substring(0, slashIndex)

        __addTask(yadApi.trashGetMetadata(targetPath, {"sort" : optKeep.sortOrder}))
    }

    function slotUpdate() {
        __addTask(yadApi.trashGetMetadata(currentFolder, {"sort" : optKeep.sortOrder}))
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

    function slotRemove(path) {
        __addTask(yadApi.trashRemove(path))
    }

    function slotRestore(path) {
        __addTask(yadApi.trashRestore(path))
    }

    property QtObject yadApi: YadApi {
        id: yadApi

        onResponseReceived: {

            __removeTask(resObj.task)

            if (code != "trashMetadata")
                console.log(JSON.stringify(resObj.response))

            var jobResult = { "isError" : resObj.isError, "response" : resObj.response, "code" : code }

            if (resObj.isError) {
                jobDone(jobResult)
                return
            }

            switch (code)
            {
            case "trashMetadata":
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
            case "trashRemove":
            case "trashRestore":
                __addTask(yadApi.trashGetMetadata(currentFolder, {"sort" : optKeep.sortOrder}))
                break;
            } // switch

            jobDone(jobResult)
        }
    } // API
}
