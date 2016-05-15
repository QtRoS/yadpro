import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.1

import "../pages"

import "../utils/JsModule.js" as JS

AdaptivePage {
    id: root

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Import")
    }

    property var activeTransfer
    property list<ContentPeer> peers

    property var selectionCallback

    function finishSelection(filesToUpload) {
        // console.log("finishSelection", filesToUpload, selectionCallback)
        if (selectionCallback)
            selectionCallback(filesToUpload)
        else predecessor.addTransfer(filesToUpload, true)
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
            pageStack.pop(root)
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
                pageStack.pop(root)

                var fileUrls = []
                for (var i = 0; i < root.activeTransfer.items.length; i++)
                    fileUrls.push(root.activeTransfer.items[i].url.toString())

                finishSelection(fileUrls)
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
