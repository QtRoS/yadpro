import QtQuick 2.4
import U1db 1.0 as U1db

QtObject {

    property bool showFileTime
    property bool useGridView
    property bool showTransferManager
    property bool downloadPreviews
    property string sortOrder
    property string token

    Component.onCompleted: {
        showFileTime = getShowFileTime()
        useGridView = getUseGridView()
        showTransferManager = getShowTransferManager()
        sortOrder = getSortOrder()
        token = getToken()
        downloadPreviews = getDownloadPreviews()
    }

    onShowFileTimeChanged: {
        setShowFileTime(showFileTime)
    }

    onUseGridViewChanged: {
        setUseGridView(useGridView)
    }

    onShowTransferManagerChanged: {
        setShowTransferManager(showTransferManager)
    }

    onSortOrderChanged: {
        setSortOrder(sortOrder)
    }

    onTokenChanged: {
        setToken(token)
    }

    onDownloadPreviewsChanged: {
        setDownloadPreviews(downloadPreviews)
    }

    function getUseGridView() {
        return settingsDocument.contents.useGridView
    }

    function setUseGridView(value) {
        if (!value)
            value = ""
        var cont = settingsDocument.contents
        cont.useGridView = value
        settingsDocument.contents = cont
    }

    function getShowFileTime() {
        return settingsDocument.contents.showFileTime
    }

    function setShowFileTime(value) {
        if (!value)
            value = ""
        var cont = settingsDocument.contents
        cont.showFileTime = value
        settingsDocument.contents = cont
    }

    function getShowTransferManager() {
        return settingsDocument.contents.showTransferManager
    }

    function setShowTransferManager(value) {
        if (!value)
            value = ""
        var cont = settingsDocument.contents
        cont.showTransferManager = value
        settingsDocument.contents = cont
    }

    function getSortOrder() {
        return settingsDocument.contents.sortOrder
    }

    function setSortOrder(value) {
        var cont = settingsDocument.contents
        cont.sortOrder = value
        settingsDocument.contents = cont
    }

    function getToken() {
        return settingsDocument.contents.token
    }

    function setToken(value) {
        var cont = settingsDocument.contents
        cont.token = value
        settingsDocument.contents = cont
    }

    function getDownloadPreviews() {
        return settingsDocument.contents.downloadPreviews
    }

    function setDownloadPreviews(value) {
        var cont = settingsDocument.contents
        cont.downloadPreviews = value
        settingsDocument.contents = cont
    }

    property var db: U1db.Database {
            id: settingsDataBase
            path: "ShortsSettings"
        }

    property var document: U1db.Document {
        id: settingsDocument
        database: settingsDataBase
        docId: 'settingsDocument'
        create: true
        defaults: { "showFileTime" : true, "useGridView" : true, "token" : "",
                    "showTransferManager" : true, "sortOrder" : "name", "downloadPreviews" : true }
    }
}

//import QtQuick 2.4
//import "../utils/DataBase.js" as DB

///* New interface for options.
// * Currently it is just facade on DB logic.
// */
//Item {

//    property bool showFileTime
//    property bool useGridView
//    property bool downloadInBrowser
//    property string sortOrder

//    Component.onCompleted: {
//        showFileTime = getShowFileTime()
//        useGridView = getUseGridView()
//        downloadInBrowser = getDownloadInBrowser()
//        sortOrder = getSortOrder()
//    }

//    onShowFileTimeChanged: {
//        setShowFileTime(showFileTime)
//    }

//    onUseGridViewChanged: {
//        setUseGridView(useGridView)
//    }

//    onDownloadInBrowserChanged: {
//        setDownloadInBrowser(downloadInBrowser)
//    }

//    onSortOrderChanged: {
//        setSortOrder(sortOrder)
//    }

//    function getUseGridView() {
//        return DB.getValue("useGridView")
//    }

//    function setUseGridView(value) {
//        if (!value)
//            value = ""
//        DB.setValue("useGridView", value)
//    }

//    function getShowFileTime() {
//        return DB.getValue("showFileTime")
//    }

//    function setShowFileTime(value) {
//        if (!value)
//            value = ""
//        DB.setValue("showFileTime", value)
//    }

//    function getDownloadInBrowser() {
//        return DB.getValue("downloadInBrowser")
//    }

//    function setDownloadInBrowser(value) {
//        if (!value)
//            value = ""
//        DB.setValue("downloadInBrowser", value)
//    }

//    function getSortOrder() {
//        return DB.getValue("sortOrder")
//    }

//    function setSortOrder(value) {
//        DB.setValue("sortOrder", value)
//    }

//    function token() {
//        return DB.getValue("token")
//    }

//    function setToken(value) {
//        DB.setValue("token", value)
//    }
//} // QtObject

