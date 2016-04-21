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

Rectangle {
    id: previewNotificationRoot

    opacity: previewCache.isBusy ? 1 : 0
    color: "#80000000"
    anchors {
        right: parent.right
        left: parent.left
        bottom: parent.bottom
    }
    height: units.gu(2.5)

    Label {
        id: someLabel
        text: i18n.tr("Downloading previews...")
        color: "white"
        anchors.centerIn: parent
        SequentialAnimation {
            loops: Animation.Infinite
            running: previewNotificationRoot.opacity == 1
            UbuntuNumberAnimation { target: someLabel; property: "opacity"; to: 0.4; easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.SlowDuration }
            UbuntuNumberAnimation { target: someLabel; property: "opacity"; to: 1; easing: UbuntuAnimation.StandardEasing; duration: UbuntuAnimation.SlowDuration }
        }
    }

    Behavior on opacity { UbuntuNumberAnimation {} }
}
