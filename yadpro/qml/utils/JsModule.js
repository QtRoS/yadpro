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
.pragma library

function decorateFileSize(size) {

    if (size === 0)
        return "0b"

    var suffix = ["b", "kb", "mb", "gb"]
    var iter = 0

    for (; size > 1024; iter++)
    {
        size = size / 1024.0
    }

    return (Math.round(size * 100) / 100) + " " + suffix[iter];
}

function decorateDate(lastMod) {
    return ", " + Qt.formatDateTime(new Date(lastMod))
}

function decorateTitle(text) {
    var ind = text.lastIndexOf("/") + 1
    text = text.substr(ind)
    return text
}

function getFileName(fullPath) {
    var ind = fullPath.lastIndexOf("/")
    if (ind === -1)
        return fullPath

    return fullPath.substr(ind + 1)
}

function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function getImageByFileType(fileName) {

    var ind = fileName.lastIndexOf(".")
    if (ind === -1)
        return  "/img/qml/images/unknown.png" // return unknown

    var ext = fileName.substr(ind + 1)

    ext = ext.toLowerCase()

    switch(ext)
    {
    case "pdf":
        return "/img/qml/images/pdf.png"
    case "djvu":
        return "/img/qml/images/djvu.png"
    case "djv":
        return "/img/qml/images/djvu.png"
    case "txt":
        return "/img/qml/images/txt.png"
    case "c":
        return "/img/qml/images/c.png"
    case "cpp":
        return "/img/qml/images/cpp.png"
    case "cs":
        return "/img/qml/images/cs.png"
    case "java":
        return "/img/qml/images/java.png"
    case "ruby":
        return "/img/qml/images/ruby.png"
    case "rb":
        return "/img/qml/images/ruby.png"
    case "py":
        return "/img/qml/images/python.png"
    case "xml":
        return "/img/qml/images/xml.png"
    case "png":
        return "/img/qml/images/img.png"
    case "jpg":
        return "/img/qml/images/img.png"
    case "jpeg":
        return "/img/qml/images/img.png"
    case "gif":
        return "/img/qml/images/img.png"
    case "mp3":
        return "/img/qml/images/audio.png"
    case "wav":
        return "/img/qml/images/audio.png"
    case "ogg":
        return "/img/qml/images/audio.png"
    case "avi":
        return "/img/qml/images/video.png"
    case "mkv":
        return "/img/qml/images/video.png"
    case "mp4":
        return "/img/qml/images/video.png"
    case "flv":
        return "/img/qml/images/video.png"
    case "mpeg":
        return "/img/qml/images/video.png"
    case "mpeg4":
        return "/img/qml/images/video.png"
    case "doc":
        return "/img/qml/images/doc.png"
    case "docx":
        return "/img/qml/images/doc.png"
    case "odt":
        return "/img/qml/images/doc.png"
    case "rtf":
        return "/img/qml/images/doc.png"
    case "ods":
        return "/img/qml/images/doc.png"
    case "docx":
        return "/img/qml/images/doc.png"
    case "odf":
        return "/img/qml/images/doc.png"
    case "ppt":
        return "/img/qml/images/doc.png"
    case "pptx":
        return "/img/qml/images/doc.png"
    case "xls":
        return "/img/qml/images/doc.png"
    case "xlsx":
        return "/img/qml/images/doc.png"
    case "zip":
        return "/img/qml/images/zip.png"
    case "rar":
        return "/img/qml/images/zip.png"
    case "tar":
        return "/img/qml/images/zip.png"
    case "gz":
        return "/img/qml/images/zip.png"
    case "bz2":
        return "/img/qml/images/zip.png"
    case "exe":
        return "/img/qml/images/exe.png"
    case "deb":
        return "/img/qml/images/deb.png"
    default:
        return "/img/qml/images/unknown.png"
    }
}
