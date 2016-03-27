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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../utils/JsModule.js" as JS
import "../components" as MyComponents
import "../popups"
import ".."

Page {
    id: trashView

    property var selectedItem: null
    visible: false

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Trash")
    }

    Component.onCompleted: {
        optKeep.useGridViewChanged.connect(viewChanged)
        viewChanged()

        trashBridge.slotMoveToFolder(JS.TRASH_ROOT_PATH)
    }

    function viewChanged() {
        var v = optKeep.useGridView
        simpleList.visible = !v
        simpleList.model = (!v)? trashBridge.folderModel : undefined
        gridView.visible = v
        gridView.model = (v)? trashBridge.folderModel : undefined
        flickable = v ?  null : simpleList
        scrollbar.flickable = v ? gridView : simpleList
    }

    function showInfoBanner(text, title, iconSource) {
        PopupUtils.open(Qt.resolvedUrl("../popups/InfoBanner.qml"),
                        null, { "text" : text, "title" : title} )
    }

    head.actions: [
        Action {
            property bool modeIsRefresh: !trashBridge.isBusy
            iconName: modeIsRefresh ? "reload" : "close"
            onTriggered: {
                if (modeIsRefresh)
                    trashBridge.slotUpdate()
                else trashBridge.slotAbort()
            }
        },
        Action {
            iconName: "edit"
            onTriggered: {
                PopupUtils.open(mainMenuComponent, null)
            }
        }
    ]
//    head.backAction: Action {
//        visible: !JS.isRootPath(trashBridge.currentFolder)
//        iconName: "back"
//        onTriggered: {
//            trashBridge.slotOneLevelBack()
//        }
//    }

    Component {
        id: mainMenuComponent

        ActionSelectionPopover {
            id: mainMenuPopover

            actions: ActionList {
                id: popoverActionsList

                Action  {
                    text: i18n.tr("Empty trash...");
                    onTriggered: trashBridge.slotRemove(JS.TRASH_ROOT_PATH) // TODO DIALOG
                }

                Action  {
                    text: i18n.tr("Home folder (trash)")
                    onTriggered: {
                        if (!JS.isRootPath(trashBridge.currentFolder))
                            trashBridge.slotMoveToFolder("/")
                    }
                }

                Action {
                    text: i18n.tr("One level back")
                    visible: !JS.isRootPath(trashBridge.currentFolder)
                    onTriggered: trashBridge.slotOneLevelBack()
                }

                Action {
                    text: i18n.tr("Options...")
                    onTriggered: {
                        optionsPage.updateInfoFromOptions()
                        pageStack.push(optionsPage)
                    }
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
                action.text = i18n.tr("Remove")
                action.callback = remove
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Restore")
                action.callback = restore
                actionArray.push(action)

                action = actionComp.createObject(contextMenuPopover)
                action.text = i18n.tr("Details...")
                action.callback = properties
                actionArray.push(action)

                actions = actionArray
            }

            function remove() {
                trashBridge.slotRemove(trashView.selectedItem.href)
            }

            function restore() {
                trashBridge.slotRestore(trashView.selectedItem.href)
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
        model: trashBridge.folderModel

        header: MyComponents.ListDelegate {
            property bool isActive: !JS.isRootPath(trashBridge.currentFolder)
            text: ".."
            iconSource: "/img/qml/images/folder.png"
            onClicked: if (isActive) trashBridge.slotOneLevelBack()
            opacity: isActive ? 1 : 0.4
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
                    trashBridge.slotMoveToFolder(model.displayName)
                else if (isTransferInProgress) {
                    selectedItem = model
                    trashBridge.slotDownload(selectedItem.href, selectedItem.displayName)
                }
            }
        }
    } // ListView

    GridView {
        id: gridView

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

//        header: MyComponents.GridDelegate {
//            property bool isActive: !JS.isRootPath(trashBridge.currentFolder)
//            text: ".."
//            iconSource: "/img/qml/images/folder.png"
//            onClicked: if (isActive) trashBridge.slotOneLevelBack()
//            opacity: isActive ? 1 : 0.4
//        }

        delegate: MyComponents.GridDelegate {
            text: model.displayName
            iconSource: model.iconSource
            isPublished: model.isPublished

            onPressed: gridView.currentIndex = index

            onClicked: {
                if (isFolder)
                    trashBridge.slotMoveToFolder(model.displayName)
                else if (isTransferInProgress) {
                    selectedItem = model
                    trashBridge.slotDownload(selectedItem.href, selectedItem.displayName)
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
        visible: trashBridge.folderModel.count == 0
    } // Label

    ActivityIndicator{
        running: trashBridge.isBusy
        visible: trashBridge.isBusy
        anchors.centerIn: parent
    }

    MyComponents.PreviewNotificationBar { }

    Connections {
        target: trashBridge
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
            } // else
        } // jobDone
    }
}
