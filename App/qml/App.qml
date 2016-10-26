pragma Singleton

import QtQuick 2.0
import Qak 1.0

QtObject {
    id: app
    property bool dbg: debugBuild

    property bool paused: !Qt.application.active

    Component.onCompleted: {
        logger.settings.prefix = "Dead Ascend"

        Qak.resource.prefix = "assets/"

        info('App','debug',dbg)
    }

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }

    function getAsset(path) {

        path = Qak.resource.url(path)

        //if(!Qak.resource.exists(path))
        //    warn('App','getAsset','couldn\'t locate',path)

        return path
    }

    // Logging
    property QtObject logger: Log { enabled: dbg; history: debugBuild }

    function log() {
        logger.log.apply(logger, arguments)
    }

    function error() {
        logger.error.apply(logger, arguments)
    }

    function debug() {
        logger.debug.apply(logger, arguments)
    }

    function warn() {
        logger.warn.apply(logger, arguments)
    }

    function info() {
        logger.info.apply(logger, arguments)
    }

    /*
     * Copyright (C) 2013 Nikita Krupenko
     *
     * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
     * associated documentation files (the "Software"), to deal in the Software without restriction,
     * including without limitation the rights to use, copy, modify, merge, publish, distribute,
     * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     *
     * The above copyright notice and this permission notice shall be included in all copies or
     * substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
     * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
     * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
     * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
     */

    function serialize(object, maxDepth) {
        function _processObject(object, maxDepth, level) {
            var output = []
            var pad = "  "
            if (maxDepth == undefined) {
                maxDepth = -1
            }
            if (level == undefined) {
                level = 0
            }
            var padding = Array(level + 1).join(pad)

            output.push((Array.isArray(object) ? "[" : "{"))
            var fields = []
            for (var key in object) {
                var keyText = Array.isArray(object) ? "" : ("\"" + key + "\": ")
                if (typeof (object[key]) == "object" && key != "parent" && maxDepth != 0) {
                    var res = _processObject(object[key], maxDepth > 0 ? maxDepth - 1 : -1, level + 1)
                    fields.push(padding + pad + keyText + res)
                } else {
                    fields.push(padding + pad + keyText + "\"" + object[key] + "\"")
                }
            }
            output.push(fields.join(",\n"))
            output.push(padding + (Array.isArray(object) ? "]" : "}"))

            return output.join("\n")
        }

        return _processObject(object, maxDepth)
    }
}
