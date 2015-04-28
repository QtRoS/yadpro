.pragma library
.import QtQuick.LocalStorage 2.0 as SQL

/* For internal usage in module.
 */
var gDbCache = undefined

function openStdDataBase() {
    if (!gDbCache) {
        gDbCache = SQL.LocalStorage.openDatabaseSync("YaD Pro", "1.0", "Settings", 100)

        gDbCache.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS settings (id  INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT, name  TEXT  NULL, value  TEXT  NULL);")
        })
    }

    return gDbCache
}

function getValue(name) {
    var db = openStdDataBase()
    var value

    db.transaction(function(tx) {

        var dbResult = tx.executeSql("SELECT * FROM settings WHERE name = ?", [name])
        // console.log("settings SELECTED: ", dbResult.rows.length)
        if (!dbResult.rows.length) {
            value = ""
        } else {
            value = dbResult.rows.item(0).value
        }
    })

    return value
}

function setValue(name, value) {
    var db = openStdDataBase()

    db.transaction(function(tx) {
        var dbResult = tx.executeSql("SELECT * FROM settings WHERE name = ?", [name])
        // console.log("settings SELECTED: ", dbResult.rows.length)

        if (!dbResult.rows.length) {
            tx.executeSql("INSERT INTO settings (name, value) VALUES (?, ?)", [name, value])
            // console.log("DB settings setValue, AFFECTED ROWS: ", dbResult.rowsAffected)
        } else {
            tx.executeSql("UPDATE settings SET value = ? WHERE name = ?", [value, name])
            // console.log("DB settings setValue, AFFECTED ROWS: ", dbResult.rowsAffected)
        }
    })
}

