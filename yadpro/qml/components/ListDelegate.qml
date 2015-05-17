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
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../utils/JsModule.js" as JS

ListItem.Subtitled {
    id: rootDelRect

    property bool isPublished
    signal contextMenuRequested(var selItem)

    height: units.gu(7)
    width: parent.width

    Image {
        visible: isPublished
        asynchronous: true
        sourceSize.width: units.gu(2) // iconSize
        sourceSize.height: units.gu(2) // iconSize
        source: "/img/qml/images/shared3.png"

        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -units.gu(0.5)
            right: parent.right
        }
    }

    onPressAndHold: rootDelRect.contextMenuRequested(model)
}
