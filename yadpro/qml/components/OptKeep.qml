import QtQuick 2.4
import Qt.labs.settings 1.0

QtObject {

    property bool showFileTime
    property bool useGridView
    property bool showTransferManager
    property bool downloadPreviews
    property bool useExternalDownloader
    property string sortOrder
    property string token

    Component.onCompleted: {
        showFileTime = getShowFileTime()
        useGridView = getUseGridView()
        showTransferManager = getShowTransferManager()
        sortOrder = getSortOrder()
        token = getToken()
        downloadPreviews = getDownloadPreviews()
        useExternalDownloader = getUseExternalDownloader()
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

    onUseExternalDownloaderChanged: {
        setUseExternalDownloader(useExternalDownloader)
    }

    function getUseGridView() {
        return settings.useGridView
    }

    function setUseGridView(value) {
        if (!value)
            value = ""
        var cont = settings
        cont.useGridView = value

    }

    function getShowFileTime() {
        return settings.showFileTime
    }

    function setShowFileTime(value) {
        if (!value)
            value = ""
        var cont = settings
        cont.showFileTime = value

    }

    function getShowTransferManager() {
        return settings.showTransferManager
    }

    function setShowTransferManager(value) {
        if (!value)
            value = ""
        var cont = settings
        cont.showTransferManager = value

    }

    function getSortOrder() {
        return settings.sortOrder
    }

    function setSortOrder(value) {
        var cont = settings
        cont.sortOrder = value

    }

    function getToken() {
        return settings.token
    }

    function setToken(value) {
        var cont = settings
        cont.token = value

    }

    function getDownloadPreviews() {
        return settings.downloadPreviews
    }

    function setDownloadPreviews(value) {
        var cont = settings
        cont.downloadPreviews = value

    }

    function getUseExternalDownloader() {
        return settings.useExternalDownloader
    }

    function setUseExternalDownloader(value) {
        var cont = settings
        cont.useExternalDownloader = value
    }


    property Settings settings: Settings {
        property bool showFileTime: true
        property bool useGridView: true
        property bool showTransferManager: true
        property bool downloadPreviews: true
        property bool useExternalDownloader: false
        property string sortOrder: "name"
        property string token: ""
    }
}

