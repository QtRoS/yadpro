import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.1

import "contenttyperesolver.js" as ContentTypeResolver

Page {
    id: root
    title: i18n.tr("Open with")

    property var activeTransfer
    property string fileUrl

    Component.onCompleted: {
        var contentType = ContentTypeResolver.resolveContentType(fileUrl)
        //console.log("Resolved contenttype: " + contentType)
        peerPicker.contentType = contentType
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    function __exportItemsWhenPossible(url) {
        //console.log("__exportItemsWhenPossible", root.activeTransfer.state, url)
        if (root.activeTransfer.state === ContentTransfer.InProgress) {
            root.activeTransfer.items = [ resultComponent.createObject(root, {"url": url}) ]
            root.activeTransfer.state = ContentTransfer.Charged
        }
    }

    ContentPeerPicker {
        id: peerPicker
        showTitle: false

        // Type of handler: Source, Destination, or Share
        handler: ContentHandler.Destination
        contentType: ContentType.Pictures

        onPeerSelected: {
            root.activeTransfer = peer.request()
            root.__exportItemsWhenPossible(root.fileUrl)
            pageStack.pop()
        }

        onCancelPressed: {
            pageStack.pop();
        }
    }

    Connections {
        target: root.activeTransfer ? root.activeTransfer : null
        onStateChanged: {
            //console.log("curTransfer StateChanged: " + root.activeTransfer.state);
            __exportItemsWhenPossible(root.fileUrl)
        }
    }
}
