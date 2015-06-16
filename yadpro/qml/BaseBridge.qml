import QtQuick 2.4

import "utils/JsModule.js" as JS
import YaD.CppUtils 1.0

QtObject {
    id: bridgeObject

    /*
        This signal emitted when job is done.
        # jobResult
            @ isError
            @ code
            @ response
                !status
                !statusText
     */
    signal jobDone(var jobResult)

    signal operationProgress(int progress)

    /* Temporary storage for all crosstask operations. */
    property var crossTaskStorage: { "localName" : ""}

    property string currentFolder: JS.ROOT_PATH
    property bool isBusy: taskCount > 0

    property int taskCount: 0
    property var tasks: []

    function __addTask(t) {
        if (!t)
            return
        tasks.push(t)
        taskCount = tasks.length
    }

    function __removeTask(t) {
        for(var i = 0; i < tasks.length; i++) {
            if (tasks[i].id === t.id) {
                tasks.splice(i, 1)
                break
            }
        }
        taskCount = tasks.length
    }

    property ListModel folderModel: ListModel {
        id: dirModel
    }
}
