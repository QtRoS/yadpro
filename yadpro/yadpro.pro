TEMPLATE = app
TARGET = yadpro

load(ubuntu-click)

QT += qml quick

SOURCES += main.cpp \
    networkmanager.cpp \
    previewcache.cpp

RESOURCES += yadpro.qrc

OTHER_FILES +=  yadpro.apparmor \
                yadpro.desktop \
                yadpro.png \
                qml/YaD.qml \
                qml/components/ToolbarButton.qml \
                qml/components/GridDelegate.qml \
                qml/components/ListDelegate.qml \
                qml/components/ActionWithCallback.qml \
                qml/components/MiniProgressBar.qml \
                qml/components/OptKeep.qml \
                qml/pages/LoginPage.qml \
                qml/pages/LocalFileSystemPage.qml \
                qml/pages/OptionsPage.qml \
                qml/pages/FolderView.qml \
                qml/popups/CreateFolderDialog.qml \
                qml/popups/SaveToDiskDialog.qml \
                qml/popups/TransferDialog.qml \
                qml/popups/RenameDialog.qml \
                qml/popups/AboutDialog.qml \
                qml/popups/DeleteDialog.qml \
                qml/popups/SignOutDialog.qml \
                qml/YadApi.qml \
                qml/Bridge.qml \
                qml/OptKeep.qml \
                qml/utils/DataBase.js \
                qml/utils/JsModule.js \
    qml/components/PreviewNotificationBar.qml


#specify where the config files are installed to
config_files.path = /yadpro
config_files.files += $${OTHER_FILES}
message($$config_files.files)
INSTALLS+=config_files

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

HEADERS += \
    networkmanager.h \
    previewcache.h

