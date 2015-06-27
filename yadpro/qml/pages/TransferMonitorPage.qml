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

import "../utils/JsModule.js" as JS


Page {
    title: i18n.tr("Simple")
    flickable: null

    ListView {
        id: simpleList

        anchors.fill: parent
        model: transferManager.transferModel
        clip: true

        delegate: ListItem {

            height: units.gu(7.5)
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                    }
                ]
            }
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "stop"
                        visible: model.state != JS.STATE_ERROR && model.state != JS.STATE_FINISHED
                        onTriggered: transferManager.stop(model.index)
                    },
                    Action {
                        iconName: "reload"
                        visible: model.state == JS.STATE_ERROR
                        onTriggered: transferManager.retry(model.index)
                    },
                    Action {
                        iconName: "ok"
                        visible: false && model.state == JS.STATE_FINISHED && model.type == JS.TRANSFER_DOWNLOAD
                    },
                    Action {
                        iconName: "go-to"
                        visible: model.state == JS.STATE_FINISHED && model.type == JS.TRANSFER_DOWNLOAD
                        onTriggered: {
                            pageStack.push(Qt.resolvedUrl("../content/OpenWithPage.qml"),
                                           { "fileUrl" : model.localUrl } )
                        }
                    }
                ]
            }

            Image {
                id: operIcon
                x: units.gu(1)
                y: units.gu(1)

                source: model.type == JS.TRANSFER_DOWNLOAD ? "/img/qml/images/download_c.png" : "/img/qml/images/upload_c.png"
                sourceSize {
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                }
            }

            Label {
                text: model.name
                elide: Text.ElideRight
                maximumLineCount: 1
                textFormat: Text.PlainText
                anchors {
                    left: operIcon.right
                    top: parent.top
                    right: parent.right
                    margins: units.gu(1)
                }
            }

            ProgressBar {
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    right: stateLbl.left
                    margins: units.gu(1)
                }
                height: units.gu(2)
                value: model.progress
                minimumValue: 0
                maximumValue: 100
            }

            Label {
                id: stateLbl
                text: model.state
                textFormat: Text.PlainText
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: units.gu(1)
                }
            }
        }
    } // ListView

//    ListModel {
//        id: transferModel

//        ListElement {
//            name: "Apple"
//            state: "initial"
//            progress: 0
//            type: "download"
//        }
//        ListElement {
//            name: "Orange Orange Orange Orange Orange Orange Orange"
//            state: "urlreceived"
//            progress: 0
//            type: "upload"
//        }
//        ListElement {
//            name: "Banana"
//            state: "inprogress"
//            progress: 50
//            type: "download"
//        }
//        ListElement {
//            name: "Mirror, mirror on the wall, who’s the fairest of them all"
//            state: "finished"
//            progress: 100
//            type: "upload"
//        }
//        ListElement {
//            name: "Mirror's edge"
//            state: "error"
//            progress: 0
//        }
//    }
}
