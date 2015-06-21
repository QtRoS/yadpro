/*
    YaD - unofficial Yandex.Disk client for Ubuntu Phone.
    Copyright (C) 2015  Roman Shchekin aka QtRoS

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/
*/

import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 0.1 as ListItem

import Ubuntu.Content 1.1

import "../utils/JsModule.js" as JS
import "../components" as MyComponents
import "../popups"

Page {
    id: folderView

    property bool isCurOperIsCopy: false
    property string fileToMoveOrCopy: ""
    property var selectedItem: null

    visible: false
    title: JS.isRootPath(bridge.currentFolder) ? i18n.tr("My Disk") : JS.decorateTitle(bridge.currentFolder)

    Component.onCompleted: {
        optKeep.useGridViewChanged.connect(viewChanged)
        viewChanged()
    }

    // --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
    property QtObject exportContext: QtObject {
        property var transfer: null
        readonly property Item visualParent: folderView
    }

    Connections {
        target: ContentHub
        onExportRequested: {
            console.log("---- CONTENT REQUEST:", JSON.stringify(transfer))
            exportContext.transfer = transfer

            // Scroll to top (user will be able to see tip).
            var curView = optKeep.useGridView ? gridView : simpleList
            curView.positionViewAtBeginning()
        }
    }

    property bool isTransferInProgress: exportContext.transfer != null

    function cancelTransfer() {
        if (exportContext.transfer) {
            exportContext.transfer.state = ContentTransfer.Aborted
            exportContext.transfer = null
        }
    }

    // --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==

    function viewChanged() {
        var v = optKeep.useGridView
        simpleList.visible = !v
        simpleList.model = (!v)? bridge.folderModel : undefined
        gridView.visible = v
        gridView.model = (v)? bridge.folderModel : undefined
        flickable = v ?  null : simpleList
        scrollbar.flickable = v ? gridView : simpleList
    }

    function showInfoBanner(text, title, iconSource) {
        PopupUtils.open(Qt.resolvedUrl("../popups/InfoBanner.qml"),
                        null, { "text" : text, "title" : title} )
    }

    function showTransferDialog(displayName, localName, isDownload) {
        var cntx = isTransferInProgress ? exportContext : null
        PopupUtils.open(Qt.resolvedUrl("../popups/TransferDialog.qml"), null,
                        { "displayName" : displayName,
                            "isDownload" : isDownload,
                            "localName" : localName,
                            "transferContext" : cntx
                        })
    }

    head.actions: [
        Action {
            property bool modeIsRefresh: !bridge.isBusy
            iconName: modeIsRefresh ? "reload" : "close"
            onTriggered: {
                if (modeIsRefresh)
                    bridge.slotUpdate()
                else bridge.slotAbort()
            }
        },
        Action {
            iconName: "edit"
            onTriggered: {
                PopupUtils.open(mainMenuComponent, null)
            }
        }
    ]
    head.backAction: Action {
        visible: !JS.isRootPath(bridge.currentFolder)
        iconName: "back"
        onTriggered: {
            bridge.slotOneLevelBack()
        }
    }

    Component {
        id: mainMenuComponent

        ActionSelectionPopover {
            id: mainMenuPopover

            actions: ActionList {
                id: popoverActionsList

                //                Action {
                //                    text: "TEST"
                //                    onTriggered: {
                //                        var downloadedFileUrl = "file:///home/phablet/.cache/yadpro/YaD/m_45tt1982.jpg"

                //                        if (downloadedFileUrl.indexOf("file") !== 0)
                //                            downloadedFileUrl = "file://" + downloadedFileUrl

                //                        console.log("OPEN", downloadedFileUrl)
                //                        pageStack.push(Qt.resolvedUrl("../content/OpenWithPage.qml"),
                //                                       { "fileUrl" : downloadedFileUrl } )
                //                    }
                //                }

                Action  {
                    text: i18n.tr("Upload...")
                    onTriggered: {
                        selectionCallback(["/home/qtros/shorts.png", "/home/qtros/shorts2.png"])
                        // TODO
                        //pageStack.push(Qt.resolvedUrl("../content/SelectFromPage.qml"),
                        //               { "selectionCallback" : selectionCallback } )
                    }

                    function selectionCallback(filesToUpload) {
                        for (var f in filesToUpload)
                            console.log(filesToUpload[f])
                        transferManager.addUpload(filesToUpload)
                    }
                }

                Action  {
                    text: i18n.tr("Create new folder...")
                    onTriggered: PopupUtils.open(Qt.resolvedUrl("../popups/CreateFolderDialog.qml"))
                }

                Action  {
                    text: i18n.tr("Paste")
                    onTriggered: {

                        if (fileToMoveOrCopy == "") {
                            showInfoBanner(i18n.tr("Please use Copy or Move context menu items to select file"),
                                           i18n.tr("Nothing to paste"),
                                           "/img/qml/images/fail.png")
                            return
                        }

                        var path = folderView.fileToMoveOrCopy
                        var shortFn = JS.getFileName(folderView.fileToMoveOrCopy)

                        var newName = JS.combinePath(bridge.currentFolder, shortFn)
                        if (folderView.isCurOperIsCopy)
                            bridge.slotCopyFile(path, newName)
                        else {
                            bridge.slotRenameFile(path, newName)
                            fileToMoveOrCopy = ""
                        }
                    }
                }

                Action  {
                    text: i18n.tr("Home folder")
                    onTriggered: {
                        if (!JS.isRootPath(bridge.currentFolder))
                            bridge.slotMoveToFolder("/")
                    }
                }

                Action  {
                    text: i18n.tr("Save to disk...")
                    enabled: false
                    onTriggered: {
                        saveToDiskDialog.showDialog()
                    }
                }

                Action {
                    text: i18n.tr("Disk information...")
                    enabled: true
                    onTriggered: {
                        bridge.slotGetDiskInfo()
                    }
                }

                Action {
                    text: i18n.tr("Explore trash...")
                    enabled: true
                    onTriggered: {
                        pageStack.push(Qt.resolvedUrl("./TrashView.qml"), { } )
                    }
                }

                Action {
                    text: i18n.tr("Options...")
                    onTriggered: {
                        optionsPage.updateInfoFromOptions()
                        pageStack.push(optionsPage)
                    }
                }

                Action {
                    text: i18n.tr("Sign out...")
                    onTriggered: PopupUtils.open(Qt.resolvedUrl("../popups/SignOutDialog.qml"))
                }

                Action {
                    text: i18n.tr("About...")
                    onTriggered: PopupUtils.open(Qt.resolvedUrl("../popups/AboutDialog.qml"))
                }
            } // ActionList
        } // ActionSelectionPopover
    }

    Component {
        id: contextMenuComponent

        ActionSelectionPopover {
            id: contextMenuPopover

            Component.onCompleted: {
                var actionArray = []

                var actionComp = Qt.createComponent(Qt.resolvedUrl("../components/ActionWithCallback.qml"))

                var action = actionComp.createObject(contextMenuPopover)
                action.text = isTransferInProgress ? i18n.tr("Export...") : i18n.tr("Download...")
                action.callback = download
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Rename...")
                action.callback = rename
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Copy")
                action.callback = copy
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Move")
                action.callback = move
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Remove")
                action.callback = remove
                actionArray.push(action)

                if (selectedItem.isPublished) {
                    action = actionComp.createObject(contextMenuPopover)
                    action.text = i18n.tr("Unpublish")
                    action.callback = unpublish
                    actionArray.push(action)

                    action = actionComp.createObject(contextMenuPopover)
                    action.text = i18n.tr("Copy public URL")
                    action.callback = copyUrl
                    actionArray.push(action)
                } else {
                    action = actionComp.createObject(contextMenuPopover)
                    action.text = i18n.tr("Publish")
                    action.callback = publish
                    actionArray.push(action)
                }

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Details...")
                action.callback = properties
                actionArray.push(action)

                actions = actionArray
            }

            function rename() {
                PopupUtils.open(Qt.resolvedUrl("../popups/RenameDialog.qml"))
            }

            function download() {
                // TODO BUG
                //bridge.slotDownload(selectedItem.href, selectedItem.displayName)
                transferManager.addDownload([selectedItem.href])
            }

            function copy() {
                folderView.isCurOperIsCopy = true
                folderView.fileToMoveOrCopy = folderView.selectedItem.href
            }

            function move() {
                folderView.isCurOperIsCopy = false
                folderView.fileToMoveOrCopy = folderView.selectedItem.href
            }

            function remove() {
                PopupUtils.open(Qt.resolvedUrl("../popups/DeleteDialog.qml"), null,
                                { "text" : selectedItem.displayName,
                                    "title" : selectedItem.isFolder ?
                                                  i18n.tr("Really want to delete folder? (It may take a while)") : i18n.tr("Really want to delete file?")
                                })
            }

            function publish() {
                bridge.slotPublish(folderView.selectedItem.href)
            }

            function unpublish() {
                bridge.slotUnpublish(folderView.selectedItem.href)
            }

            function copyUrl() {
                var mimeData = Clipboard.newData()
                mimeData.data = selectedItem.publicUrl
                Clipboard.push(mimeData)
            }

            function properties() {
                var itm = selectedItem
                var formatStr = "Name: %1\nType: %2\nLast modified: %3\nCreation date: %4\nSize: %5\nMime: %6\nPublished: %7\n"
                var res = formatStr.arg(itm.displayName)
                .arg(itm.isFolder ? "Folder" : "File")
                .arg(JS.decorateDate(itm.lastModif))
                .arg(JS.decorateDate(itm.creationDate))
                .arg(JS.decorateFileSize(itm.contentLen))
                .arg(itm.contentType)
                .arg(itm.isPublished ? i18n.tr("Yes") : i18n.tr("No"))
                // console.log("FILE INFO: ", res)

                showInfoBanner(res, i18n.tr("Details"))
            }
        } // ActionSelectionPopover
    }

    ListView {
        id: simpleList

        anchors.fill: parent
        model: bridge.folderModel

        header: MyComponents.FolderViewHeader {
            isActive: isTransferInProgress
            onCanceled: cancelTransfer()
        }

        delegate: MyComponents.ListDelegate {

            text: model.displayName
            iconSource: model.iconSource
            isPublished: model.isPublished
            subText: JS.decorateFileSize(model.contentLen)  + (optKeep.showFileTime ? JS.decorateDate(model.lastModif, ", %1") : "")


            onContextMenuRequested: {
                selectedItem = selItem
                simpleList.currentIndex = selItem.index
                PopupUtils.open(contextMenuComponent, simpleList.currentItem)
            }

            onClicked: {
                simpleList.currentIndex = index
                if (isFolder)
                    bridge.slotMoveToFolder(model.displayName)
                else if (isTransferInProgress) {
                    selectedItem = model
                    bridge.slotDownload(selectedItem.href, selectedItem.displayName)
                }
            }
        }
    } // ListView

    GridView {
        id: gridView

        header: MyComponents.FolderViewHeader {
            isActive: isTransferInProgress
            onCanceled: cancelTransfer()
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: parent.width - parent.width % cellWidth
        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: units.gu(13)
        cellHeight: units.gu(14)

        model: folderModel
        focus: true
        clip: true

        delegate: MyComponents.GridDelegate {
            text: model.displayName
            iconSource: model.iconSource
            isPublished: model.isPublished

            onPressed: gridView.currentIndex = index

            onClicked: {
                if (isFolder)
                    bridge.slotMoveToFolder(model.displayName)
                else if (isTransferInProgress) {
                    selectedItem = model
                    bridge.slotDownload(selectedItem.href, selectedItem.displayName)
                }
            }

            onContextMenuRequested: {
                selectedItem = model
                // gridView.currentIndex = selectedItem.index
                PopupUtils.open(contextMenuComponent, gridView.currentItem)
            }
        } // Delegate
    } // GridView

    Item {
        id: scrollbar
        property Item flickable: simpleList
        anchors.right: parent.right
        height: parent.height
        width: units.gu(0.5)
        clip: true
        Rectangle {
            y: scrollbar.flickable.visibleArea.yPosition * scrollbar.flickable.height
            width: parent.width
            height: scrollbar.flickable.visibleArea.heightRatio * scrollbar.flickable.height
            color: "#44ffffff"
        }
    }

    Label {
        id: emptyListLabel

        z: 5
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -units.gu(5)
        text: i18n.tr("Empty folder")
        opacity: 0.25
        fontSize: "x-large"
        visible: bridge.folderModel.count == 0
    } // Label

    ActivityIndicator{
        running: bridge.isBusy
        visible: bridge.isBusy
        anchors.centerIn: parent
    }

    //    MyComponents.MiniProgressBar {
    //        id: miniProgress

    //        anchors {
    //            bottom: parent.bottom
    //            left: parent.left
    //            right: parent.right
    //        }
    //    }

    MyComponents.PreviewNotificationBar { }

    Connections {
        target: bridge
        onJobDone: {
            if (jobResult.isError) {
                showInfoBanner(JSON.stringify(jobResult),
                               i18n.tr("An error has occurred"))
            } else {
                if (jobResult.code == "diskInformation") {
                    var r = jobResult.response
                    var message = i18n.tr("Total space: %1\nUsed space: %2\nTrash size: %3")
                    .arg(JS.decorateFileSize(r.total_space))
                    .arg(JS.decorateFileSize(r.used_space))
                    .arg(JS.decorateFileSize(r.trash_size))

                    showInfoBanner(message, i18n.tr("Disk information"))
                }
//                else if (jobResult.code == "download" && jobResult.shouldShowTransferDialog) {
//                    showTransferDialog(selectedItem.displayName, jobResult.localName, true)
//                } else if (jobResult.code == "upload" && jobResult.shouldShowTransferDialog) {
//                    showTransferDialog(jobResult.localName /* TODO */, jobResult.localName, false)
//                }
            } // else
        } // jobDone

        // onOperationProgress: miniProgress.progress = progress
    }
}
