import QtQuick 2.0

import Qak 1.0

import FileIO 1.0

Item {
    id: reader

    signal error

    FileIO {
        id: fileReader
        source: ""
        onError: { Qak.error(msg); reader.error(msg) }
    }

    function read(file) {
        if(Qak.resource.exists(file)) {
            fileReader.source = file
            return JSON.parse(fileReader.read())
        }
        Qak.error('Can\'t read json file',file)
        error('Can\'t read file '+file)
        return null
    }
}
