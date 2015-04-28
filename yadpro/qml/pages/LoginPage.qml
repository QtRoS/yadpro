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
import Ubuntu.Web 0.2
import "../"


Page {
    id: pageItself

    signal authPassed(string token)

    property bool testRequestInProgress: false

    title: i18n.tr("Log in")
    flickable: null

    function logout() {
        showWebview("https://passport.yandex.ru/")
        optKeep.setToken("")
    }

    function login() {
        var token = optKeep.token

        if (token) {
            /* Making test request. */
            testYadApi.accessToken = token
            testYadApi.getMetaData()

            testRequestInProgress = true
        } else {
            showWebview(bridge.yadApi.generateTokenRequestUrl())
        }
    }

    function showWebview(url) {
        tokenWebView.url = url
        tokenWebView.visible = true
    }

    head.actions: [
        Action {
            iconName: "go-to"
            onTriggered: if (!testRequestInProgress) login()
        }
    ]

    Component.onCompleted: login()

    YadApi {
        id: testYadApi

        onResponseReceived: {
            testRequestInProgress = false
            if (!resObj.isError) {
                authPassed(testYadApi.accessToken)
            } else {
                showWebview(bridge.yadApi.generateTokenRequestUrl())
            }
        }
    }

    WebView {
        id: tokenWebView

        anchors.fill: parent
        visible: false
        onUrlChanged: {
            var url_string = url.toString()
            console.log("url_string", url_string)
            if (url_string.indexOf("https://oauth.yandex.ru/authorize") == 0) {
                // SKIP
            } else if (url_string.indexOf("https://oauth.yandex.ru/verification_code") == 0) {
                var match = /access_token=([a-z0-9]+).*expires_in=(\d+)/.exec(url_string)
                if (match.length >= 2) {
                    authPassed(match[1])
                }
            }
        }
    } // WebView

    ActivityIndicator {
        anchors.centerIn: parent
        running: testRequestInProgress
    }
}
