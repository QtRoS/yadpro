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

Item {
    id: headerItemRoot

    signal canceled()
    property bool isActive: true

    width: parent.width
    height: isActive ? units.gu(7) : 0

    UbuntuShape {
        color: innerMa.pressed ? "red" : "green"

        anchors {
            fill: parent
            margins: units.gu(1)
        }

        Label {
            width: parent.width - units.gu(1)
            height: units.gu(5)
            visible: headerItemRoot.height
            text: i18n.tr("Active transfer - tap on the file for export or click here to cancel")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 2
            textFormat: Text.PlainText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        MouseArea {
            id: innerMa
            anchors.fill: parent
            onClicked: headerItemRoot.canceled()
        }
    }
}
