/*
    YaD - unofficial Yandex.Disk client.
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

import "../utils/JsModule.js" as JS

Rectangle {
    id: rootDelRect

    signal pressed
    signal clicked(var mouse)
    signal contextMenuRequested()

    property alias text: lblDisplayName.text
    property alias iconSource: imageIcon.source
    property bool isPublished

    color: delegateMouseArea.pressed? "#88dddddd" : "#00000000"
    width: units.gu(13)
    height: units.gu(14)

    Image {
        visible: isPublished
        asynchronous: true
        sourceSize.width: units.gu(2) // iconSize
        sourceSize.height: units.gu(2) // iconSize
        source: "/img/qml/images/shared3.png"
        x: units.gu(0.5)
        y: units.gu(1)
    }

    Image {
        id: imageIcon
        asynchronous: true

        sourceSize.width: units.gu(6) // iconSize
        sourceSize.height: units.gu(6) // iconSize

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }
    }

    Label {
        id: lblDisplayName

        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        width: parent.width - units.gu(1)
        height: units.gu(5)
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 2
        textFormat: Text.PlainText
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    MouseArea {
        id: delegateMouseArea

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: rootDelRect.pressed()
        onClicked: rootDelRect.clicked(mouse)
        onPressAndHold: rootDelRect.contextMenuRequested()
    }
} // Delegate
