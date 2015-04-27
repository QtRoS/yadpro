/*
    YaD - unofficial Yandex.Disk client for Ubuntu Phone.
    Copyright (C) 2013  Roman Shchekin aka QtRoS

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

import "../utils/JsModule.js" as JS

Dialog {
    id: rootDialog

    property alias fileName: rootDialog.text
    property string downloadedFileUrl: ""
    property bool isDownlaod: true
    property bool isFinished: false
    property real totalLen: 1

    title: isDownlaod? i18n.tr("Downloading") : i18n.tr("Uploading")

    function stopDialog() {

        if (!isFinished) {

            bridge.slotAbort()

            if (isDownlaod) {
                bridge.downloadProgress.disconnect(progressChanged)
            } else {
                bridge.uploadProgress.disconnect(progressChanged)
            }
        }

        rootDialog.hide()
    }

    function finishWithSuccess() {

        if (isDownlaod) {
            bridge.downloadProgress.disconnect(progressChanged)
        } else {
            bridge.uploadProgress.disconnect(progressChanged)
        }
        isFinished = true
    }

    function startDialog() {
        isFinished = false
        progressBar.value = 0

        if (isDownlaod) {
            bridge.downloadProgress.connect(progressChanged)
        } else {
            bridge.uploadProgress.connect(progressChanged)
        }

        rootDialog.show()
    }

    function progressChanged(current, total) {
        if (total !== totalLen)
        {
            totalLen = total
            progressBar.maximumValue = total

            if (total === -1)
                progressBar.indeterminate = true
            else progressBar.indeterminate = false
        }

        progressBar.value = current

        if (current === total)
            finishWithSuccess()
    }


    ProgressBar {
        id: progressBar

        minimumValue: 0
        value: 0
    }

    Button {
        id: openButton

        visible: isDownlaod
        enabled: isFinished

        text: i18n.tr("Open")
        onClicked: {
            console.log("OPEN", downloadedFileUrl)
            if (downloadedFileUrl.indexOf("file") !== 0)
                downloadedFileUrl = "file://" + downloadedFileUrl
            console.log("OPEN", downloadedFileUrl)
            bridge.slotOpenUrl(downloadedFileUrl)
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

}

