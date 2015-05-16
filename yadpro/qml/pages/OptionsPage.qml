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

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: pageItself

    property bool preventSave: false

    title: i18n.tr("Options")
    visible: false

    function updateInfoFromOptions() {
        pageItself.preventSave = true

        chbDefDir.checked = optKeep.downloadInBrowser
        swUseGridView.checked = optKeep.useGridView
        swShowFileTime.checked = optKeep.showFileTime
        swDownloadPreviews.checked = optKeep.downloadPreviews
        isSortOrder.selectItemByValue(optKeep.sortOrder)

        pageItself.preventSave = false
    }

    Column {
        id: contentColumn

        width: parent.width

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

            text: i18n.tr("Download in browser")
            width: parent.width
            control: Switch {
                id: chbDefDir

                anchors.right: parent.right

                onCheckedChanged: {
                    if (pageItself.preventSave)
                        return

                    optKeep.downloadInBrowser = checked

                    if (checked)
                        PopupUtils.open(compDialog)
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

    Component {
        id: compDialog

        Dialog {
            id: infoDialog

            text: i18n.tr("You should login into Yandex.Disk in browser before use this method")
            Button {
                text: i18n.tr("Ok")
                onClicked: {
                    infoDialog.hide()
                }
            }
        }
    } // Component
}
