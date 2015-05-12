import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Content 1.1

import "../utils/JsModule.js" as JS

Page {
    id: root

    property var activeTransfer
    property list<ContentPeer> peers

    function uploadFile(fileToUpload) {
        // console.log("fileToUpload", fileToUpload)
        var shortName = JS.getFileName(fileToUpload)
        // console.log("shortName", shortName)
        var path = bridge.currentFolder
        if (JS.endsWith(path, "/"))
            path = path + shortName
        else path = path + "/" + shortName
        // console.log("path", path)
        bridge.slotUpload(path, fileToUpload)
    }

    ContentPeerPicker {
        visible: parent.visible
        showTitle: true
        handler: ContentHandler.Source
        contentType: ContentType.All

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Single
            root.activeTransfer = peer.request()
        }

        onCancelPressed: {
            pageStack.pop()
        }
    }

    ContentTransferHint {
        anchors.fill: importFeeds
        activeTransfer: importFeeds.activeTransfer
    }

    Connections {
        target: root.activeTransfer
        onStateChanged: {
            console.log("StateChanged: " + root.activeTransfer.state);
            if (root.activeTransfer.state === ContentTransfer.Charged) {
                uploadFile(root.activeTransfer.items[0].url.toString())
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