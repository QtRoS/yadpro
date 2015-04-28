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

// import YadPlugin 1.0 TODO

import "../utils/JsModule.js" as JS

Page {
    id: localFsPage

    visible: false
    title: i18n.tr("Select file")
    flickable: null
    clip: true


    function loadHomeDir() {
        fsModel.slotLoadHomeDirectory()
        fileList.positionViewAtBeginning()
    }

    function clearModel() {
        fsModel.clear()
    }

    function reloadPageContent() {
        tools = localFsTools
    }

    tools: null

    ToolbarItems {
        id: localFsTools

        //opened: true
        //locked: true

        back: ToolbarButton {
            visible: false
            anchors.verticalCenter: parent.verticalCenter
            action: Action {
                // text:  i18n.tr("Cancel")
                iconSource: "/img/qml/images/back.svg"
                onTriggered: {
                    pageStack.pop()
                }
            }
        }

        ToolbarButton {
            id: homeButton

            visible: false
            action: Action {
                // text: "Go to..."
                iconSource: "/img/qml/images/location.svg"
                onTriggered: {
                    PopupUtils.open(placeSelectPopoverComponent, /*homeButton*/null)
                }
            }
        }
    }

    Component {
        id: placeSelectPopoverComponent

        ActionSelectionPopover {
            id: placeSelectPopover

            Component.onCompleted: {
                var actions = []
                for (var i = 0; i < placeModel.count; i++) {
                    var act = customAction.createObject()
                    act.text = placeModel.get(i).textValue
                    act.stdLocationId = placeModel.get(i).intId
                    actions.push(act)
                }
                placeSelectPopover.actions = actions
            }
        } // ActionSelectionPopover
    }

    Component {
        id: customAction

        Action  {
            property int stdLocationId: 8
            onTriggered: {
                fsModel.slotLoadStandardLocation(stdLocationId)
                fileList.positionViewAtBeginning()
            }
        }
    }

    ListModel {
        id: placeModel

        ListElement {
            textValue: "Desktop"
            intId: 0
        }

        ListElement {
            textValue: "Documents"
            intId: 1
        }

        ListElement {
            textValue: "Music"
            intId: 4
        }

        ListElement {
            textValue: "Movies"
            intId: 5
        }

        ListElement {
            textValue: "Pictures"
            intId: 6
        }

        ListElement {
            textValue: "Home"
            intId: 8
        }

        ListElement {
            textValue: "Downloads"
            intId: 14
        }
    }

    ListView {
        id: fileList

        anchors.fill: parent
        model: fsModel

        delegate: ListItem.Standard {
            height: units.gu(7)
            width: parent.width

            progression: model.isFolder
            iconSource: model.isFolder? Qt.resolvedUrl("/img/qml/images/folder.png") : Qt.resolvedUrl(JS.getImageByFileType(model.displayName))
            text: model.displayName

            onClicked: {
                if (isFolder) {
                    fsModel.slotOpenSubDir(model.displayName)
                    fileList.positionViewAtBeginning()
                } else {
                    var fullPath = fsModel.slotCurrentDirectory() + "/" + model.displayName
                    folderView.showTransferDialog(fullPath, false)
                    var res = bridge.slotUploadFile(fullPath)
                    if (!res) {
                        folderView.showErrorMessage(i18n.tr("Error! Can't transfer file!"))
                        folderView.stopTransferDialog()
                    }
                    pageStack.pop()
                }
            }
        }

        Label {
            id: emptyListLabel

            z: 5
            visible: fsModel.entryCount === 0
            anchors.centerIn: parent
            text: i18n.tr("Empty folder")
            opacity: 0.25
            fontSize: "x-large"
        } // Label
    } // ListView

    FsModel {
        id: fsModel
    }
}
