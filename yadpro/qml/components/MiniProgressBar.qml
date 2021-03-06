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

Item {
    id: miniProgressRoot

    property int progress: 0

    height: units.gu(0.5)
    onProgressChanged: {
        if (progress >= 100)
            opacity = 0
        else if (progress > 0)
            opacity = 1
    }

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width / 100 * progress
        color: UbuntuColors.orange
    }

    Behavior on opacity { UbuntuNumberAnimation {} }
}
