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
import Ubuntu.PerformanceMetrics 0.1

import "./pages"
import "./components"

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "yadpro"

    useDeprecatedToolbar: false
    
    width: units.gu(100)
    height: units.gu(75)

    headerColor: "#3a2c32"
    backgroundColor: "#875864"
    footerColor: "#9b616c"

    PageStack {
        id: pageStack

        Component.onCompleted: {
            push(loginPage)
        }

        onCurrentPageChanged: {
            if (currentPage != null) {
                console.log("PageStack onCurrentPageChanged", currentPage.title)
                if (currentPage.reloadPageContent)
                    currentPage.reloadPageContent()

//                if (currentPage != localFsPage)
//                                localFsPage.clearModel()
            }
        }

        LoginPage {
            id: loginPage

//            onAuthPassed: {
//                pageStack.pop(loginPage)
//                pageStack.push(folderView)
//                bridge.slotMoveToFolder("/")
//            }

            onAuthPassed: {
                console.log("TOKEN", token)

                optKeep.token = token
                previewCache.token = token
                networkManager.token = token

                pageStack.pop(loginPage)
                pageStack.push(folderView)

                bridge.yadApi.accessToken = token
                bridge.slotMoveToFolder("/")
            }
        }

        FolderView {
            id: folderView
        }

        OptionsPage {
            id: optionsPage
        }
    }

    OptKeep {
        id: optKeep
    }

    Bridge {
        id: bridge
    }
}
