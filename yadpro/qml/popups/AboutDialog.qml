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

import "../popups"

Dialog {
    id: aboutDialog

    property string version: "v2.4.7"
    title: i18n.tr("<font color='#dd4814'>YaD Pro</font>")
    text: i18n.tr("Unofficial <font color='#dd4814'>Ubuntu Phone</font> client of <br><a href='http://disk.yandex.com/'>Yandex.Disk</a> free file storage service<br> developed by Roman Shchekin <br> aka <font color='#dd4814'>QtRoS</font><br>mrqtros@gmail.com<br>") + version

    Item {
        height: units.gu(8)

        UbuntuShape {
            image: Image {
                asynchronous: true
                sourceSize.width: units.gu(8)
                sourceSize.height: units.gu(8)
                source: "/img/qml/images/splashScreen.png"
            }
            width: image.width
            height: image.height
            anchors.centerIn: parent
        }


    }

    Button {
        text: i18n.tr("Ok")
        color: UbuntuColors.green
        onClicked: {
            aboutDialog.hide()
        }
    }
}
