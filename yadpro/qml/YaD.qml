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
import Ubuntu.Components.ListItems 1.3 as ListItem

import "./pages"
import "./components"

MainView {
    objectName: "mainView"
    applicationName: "yadpro.mrqtros"
    
    width: units.gu(50)
    height: units.gu(75)

    theme.name: "Ubuntu.Components.Themes.SuruDark"

    AdaptivePageLayout {
        id: pageStack

        function push(page, properties, predecessor) {
            //console.log("push", page, JSON.stringify(properties), predecessor)

            // In case if page is passed as QML file.
            if (typeof page === "string")
                page = Qt.createComponent(page).createObject(pageStack, properties)

            page.predecessor = predecessor ? predecessor : folderView
            pageStack.addPageToCurrentColumn(page.predecessor, page, properties)
            currentPageChangeHandler(page)
        }

        function pop(page) {
            pageStack.removePages(page.predecessor)
            currentPageChangeHandler(page.predecessor)
        }

        anchors.fill: parent
        primaryPage: folderView
        Component.onCompleted: push(loginPage)

        function currentPageChangeHandler(page) {
            if (page) {
                console.log("PageStack onCurrentPageChanged", page.header ? page.header.title : page.title)
                if (page.reloadPageContent)
                    page.reloadPageContent()
            }
        }

        LoginPage {
            id: loginPage

            onAuthPassed: {
                //console.log("TOKEN", token)

                optKeep.token = token
                previewCache.token = token
                networkManager.token = token

                pageStack.pop(loginPage)

                bridge.yadApi.accessToken = token
                trashBridge.yadApi.accessToken = token
                bridge.slotMoveToFolder("/")
            }
        }

        FolderView {
            id: folderView
        }
    }

    OptKeep {
        id: optKeep
    }

    Bridge {
        id: bridge
    }

    TrashBridge {
        id: trashBridge
    }

    TransferManager {
        id: transferManager
    }

    ContentHubListener {
        id: hubListener
    }
}
