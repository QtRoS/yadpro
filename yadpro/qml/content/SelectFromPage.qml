import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Content 1.1

import "../utils/JsModule.js" as JS

Page {
    id: root

    property var activeTransfer
    property list<ContentPeer> peers

    property var selectionCallback

//    function uploadFile(fileToUpload) {
//        // console.log("fileToUpload", fileToUpload)
//        var shortName = JS.getFileName(fileToUpload)
//        // console.log("shortName", shortName)
//        var path = JS.combinePath(bridge.currentFolder, shortName)
//        // console.log("path", path)
//        bridge.slotUpload(path, fileToUpload)
//    }

    function finishSelection(filesToUpload) {
        console.log(" finishSelection ", filesToUpload.length, selectionCallback)
        if (selectionCallback)
            selectionCallback(filesToUpload)
    }

    ContentPeerPicker {
        visible: parent.visible
        showTitle: true
        handler: ContentHandler.Source
        contentType: ContentType.All

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Multiple
            root.activeTransfer = peer.request()
        }

        onCancelPressed: {
            pageStack.pop()
        }
    }

    ContentTransferHint {
        anchors.fill: root
        activeTransfer: root.activeTransfer
    }

    Connections {
        target: root.activeTransfer ? root.activeTransfer : null
        onStateChanged: {
            console.log("StateChanged: " + root.activeTransfer.state);
            if (root.activeTransfer.state === ContentTransfer.Charged) {
                var fileUrls = []
                var items = root.activeTransfer.items
                for (var i = 0; i < items.length; i++)
                    fileUrls.push(items[i].url.toString())
                finishSelection(fileUrls)
                pageStack.pop()
            }
        }
    }

//        Connections {
//            target: ContentHub
//            onImportRequested: {
//                console.log ("Import requested: " + transfer.state);
//                root.activeTransfer = transfer
//                if (root.activeTransfer.state === ContentTransfer.Charged)
//                    root.importItems = root.activeTransfer.items
//            }
//        }
} // Page
