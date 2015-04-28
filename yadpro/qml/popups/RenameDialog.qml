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

import "../utils/JsModule.js" as JS

Dialog {
    id: dialogItself

    title: i18n.tr("Rename")
    text: i18n.tr("Enter a new name")

    function showDialog() {
        var value = selectedItem.displayName

        newNameTextField.text = value
        newNameTextField.forceActiveFocus()

        var indOfDot = value.lastIndexOf('.')
        if (indOfDot > 0) {
            newNameTextField.cursorPosition = indOfDot
        } else {
            newNameTextField.cursorPosition = newNameTextField.text.length
        }

        newNameTextField.forceActiveFocus()

        dialogItself.show()
    }

    TextField {
        id: newNameTextField

        placeholderText: i18n.tr("File name")
    }

    Button {
        text: i18n.tr("Ok")
        onClicked: {
            var folderName = newNameTextField.text

            if (folderName == "")
                return

            var curDir = bridge.currentFolder;
            if (!JS.endsWith(curDir, "/"))
                curDir += "/";

            bridge.slotRenameFile(curDir + selectedItem.displayName,
                                  curDir + folderName)

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
