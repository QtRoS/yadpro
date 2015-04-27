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
    id: dialogItself

    title: i18n.tr("Create folder")
    text: i18n.tr("Enter name for new folder")

    function showDialog() {
        newFolderNameTextField.text = ""
        newFolderNameTextField.forceActiveFocus()
        dialogItself.show()
    }

    TextField {
        id: newFolderNameTextField

        placeholderText: i18n.tr("Folder name")
    }

    Button {
        text: i18n.tr("Ok")
        onClicked: {
            var folderName = newFolderNameTextField.text

            if (folderName == "")
                return

            var curDir = bridge.currentFolder;
            if (!JS.endsWith(curDir, "/"))
                curDir += "/";
            bridge.slotCreateFolder(curDir + folderName)
            dialogItself.hide()
        }
    }

    Button {
        text: i18n.tr("Cancel")
        gradient: UbuntuColors.greyGradient
        onClicked: {
            dialogItself.hide()
        }
    }
}
