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
import Ubuntu.Content 1.1
import Ubuntu.Components.Popups 1.3

Dialog {
    id: rootDialog

    property string displayName
    property string localName
    property bool isDownload: false
    property bool isFinished: false

    property var transferContext: null

    title: isDownload? i18n.tr("Downloading") : i18n.tr("Uploading")

    function stopDialog() {
        if (!isFinished)
            networkManager.abort()

        rootDialog.hide()
    }

    function startDialog() {
        isFinished = false
        progressBar.value = 0

        rootDialog.open()
    }

    function progressChanged(current, total) {
        if (total === -1)
            progressBar.indeterminate = true
        else progressBar.indeterminate = false

        progressBar.value = total ? current / total : 0
        // console.log(" --- PROGRESS ", current, total, progressBar.value)
    }

    ProgressBar {
        id: progressBar

        minimumValue: 0
        value: 0
    }

    Button {
        id: openButton

        visible: isDownload
        enabled: isFinished

        text: transferContext ? i18n.tr("Select") : i18n.tr("Open")
        color: UbuntuColors.green
        onClicked: {
            var downloadedFileUrl = localName

            if (downloadedFileUrl.indexOf("file") !== 0)
                downloadedFileUrl = "file://" + downloadedFileUrl

            console.log("TRANFSER DIALOG URL", downloadedFileUrl, transferContext ? "Export" : "Download")

            if (transferContext) {
                var res = fileSelectorResultComponent.createObject(transferContext.visualParent, {"url": downloadedFileUrl})

                transferContext.transfer.items = [res]
                transferContext.transfer.state = ContentTransfer.Charged

                transferContext.transfer = null
            } else {
                pageStack.push(Qt.resolvedUrl("../content/OpenWithPage.qml"),
                               { "fileUrl" : downloadedFileUrl } )
            }

            rootDialog.stopDialog()
        }
    }

    Button {
        text: isFinished ? i18n.tr("Close") : i18n.tr("Cancel");
        color: UbuntuColors.red
        onClicked: {
            stopDialog()
        }
    }

    Connections {
        target: networkManager

        onOperationProgress: progressChanged(current, total)
        onOperationFinished:  {
            isFinished = true
            if (!isDownload) {
                stopDialog()
                bridge.slotUpdate()
            }
        }
    }

    Component {
        id: fileSelectorResultComponent
        ContentItem { }
    }

}

