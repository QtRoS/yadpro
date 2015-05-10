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

Dialog {
    id: rootDialog

    property string displayName
    property string localName
    property bool isDownload: false
    property bool isFinished: false

    title: isDownload? qsTr("Downloading") : qsTr("Uploading")

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

        progressBar.value = current / total
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

        text: i18n.tr("Open")
        onClicked: {
            var downloadedFileUrl = localName

            if (downloadedFileUrl.indexOf("file") !== 0)
                downloadedFileUrl = "file://" + downloadedFileUrl

            console.log("OPEN", downloadedFileUrl)
            pageStack.push(Qt.resolvedUrl("../content/OpenWithPage.qml"),
                           { "fileUrl" : downloadedFileUrl } )

            rootDialog.stopDialog()
        }
    }

    Button {
        text: isFinished ? i18n.tr("Close") : i18n.tr("Cancel");
        gradient: UbuntuColors.greyGradient
        onClicked: {
            stopDialog()
        }
    }

    Connections {
        target: networkManager

        onOperationProgress: progressChanged(current, total)
        onOperationFinished: isFinished = true
    }

}

