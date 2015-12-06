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

import "../utils/JsModule.js" as JS

Dialog {
    id: dialogItself

    title: i18n.tr("Save to disk")
    text: i18n.tr("Please, enter URL of public resource in text field below")

    function showDialog() {
        urlTextField.forceActiveFocus()
        dialogItself.show()
    }

    TextField {
        id: urlTextField

        placeholderText: i18n.tr("URL of public resource")
    }

    Button {
        text: i18n.tr("Save")
        onClicked: {
            bridge.slotSaveToDisk(urlTextField)
            dialogItself.hide()
        }
    }

    Button {
        text: i18n.tr("Cancel")
        //gradient: UbuntuColors.greyGradient
        onClicked: {
            dialogItself.hide()
        }
    }
}
