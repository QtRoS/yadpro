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

AdaptivePage {
    id: pageItself

    property bool preventSave: false

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Options")
    }

    visible: false

    Component.onCompleted: updateInfoFromOptions()

    function updateInfoFromOptions() {
        pageItself.preventSave = true

        chbShowTransferManager.checked = optKeep.showTransferManager
        swUseGridView.checked = optKeep.useGridView
        swShowFileTime.checked = optKeep.showFileTime
        swDownloadPreviews.checked = optKeep.downloadPreviews
        isSortOrder.selectItemByValue(optKeep.sortOrder)

        pageItself.preventSave = false
    }

    Column {
        id: contentColumn

        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ListItem.Standard {
            id: gridListItem

            text: i18n.tr("Use grid")
            width: parent.width
            control: Switch {
                id: swUseGridView

                anchors.right: parent.right

                onCheckedChanged: {
                    if (pageItself.preventSave)
                        return

                    optKeep.useGridView = checked
                }
            }
        }

        ListItem.Standard {
            id: fileTimeListItem

            text: i18n.tr("Show file time (in list)")
            width: parent.width
            control: Switch {
                id: swShowFileTime

                anchors.right: parent.right

                onCheckedChanged: {
                    if (pageItself.preventSave)
                        return

                    optKeep.showFileTime = checked
                }
            }
        }

        ListItem.Standard {
            id: downloadPreviewsListItem

            text: i18n.tr("Download previews")
            width: parent.width
            control: Switch {
                id: swDownloadPreviews

                anchors.right: parent.right

                onCheckedChanged: {
                    if (pageItself.preventSave)
                        return

                    optKeep.downloadPreviews = checked
                }
            }
        }

        ListItem.Standard {
            id: useDefListItem

            text: i18n.tr("Show transfers automatically")
            width: parent.width
            control: Switch {
                id: chbShowTransferManager

                anchors.right: parent.right

                onCheckedChanged: {
                    if (pageItself.preventSave)
                        return

                    optKeep.showTransferManager = checked
                }
            }
        }

        ListItem.ItemSelector {
            id: isSortOrder

            function selectItemByValue(val) {
                selectedIndex = modelArray.indexOf(val)
            }

            text: i18n.tr("Sort order")
            property var modelArray: [i18n.tr("name"),
                i18n.tr("created"),
                i18n.tr("modified"),
                i18n.tr("size"),
                i18n.tr("path")]
            model: modelArray
            onSelectedIndexChanged: {
                if (pageItself.preventSave)
                    return

                optKeep.sortOrder = modelArray[selectedIndex]
            }
        }
    } // Column
}
