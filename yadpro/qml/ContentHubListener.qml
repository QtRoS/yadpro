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
import Ubuntu.Content 1.1

Item {

    property var exportTransfer: null
    property bool exportTransferActive: exportTransfer != null

    function cancelTransfer() {
        if (exportTransfer) {
            exportTransfer.state = ContentTransfer.Aborted
            exportTransfer = null
        }
    }

    Connections {
        target: ContentHub
        onExportRequested: {
            // console.log("---- CONTENT REQUEST:", JSON.stringify(transfer))
            exportTransfer = transfer
        }
    }
}