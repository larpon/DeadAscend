import QtQuick 2.0
import QtMultimedia 5.4

import "."

Item {
    id: container

    property alias volume: musicPlayer.volume
    property alias source: musicPlayer.source
    property alias muted: musicPlayer.mute

    function play() {
        musicPlayer.play()
    }

    function pause() {
        musicPlayer.pause()
    }

    function stop() {
        musicPlayer.stop()
    }

    // TODO NICE TO HAVE use Audio QML type instead?
    MediaPlayer {
        id: musicPlayer

        source: ""
        volume: 1
        property bool mute: false

        muted: volume <= 0

        onError: {
            App.error('MusicPlayer',"error",source,error,errorString,status,statusString(),availability)
        }

        onStatusChanged: {
            App.info('MusicPlayer',"status",source,error,status,statusString(),availability)
            muteChanged()

            if(availability == MediaPlayer.Available && musicPlayer.status == MediaPlayer.EndOfMedia) {
                // Fix Invalid media error bug by resetting the source before replay
                var tmpSrc = musicPlayer.source
                musicPlayer.source = ""
                musicPlayer.source = tmpSrc
                musicPlayer.play()
            }
        }

        onAvailabilityChanged: {
            App.info('MusicPlayer',"availability",source,error,status,statusString(),availability)
            muteChanged()
        }

        onMuteChanged: {
            App.debug('MusicPlayer','Mute changed',mute)
            //mute ? pause() : play()
            muted = mute
        }

        function statusString() {
            var statusString = "Unknown"
            if(status === MediaPlayer.NoMedia)
                statusString = "no media has been set"
            if(status === MediaPlayer.Loading)
                statusString = "the media is currently being loaded"
            if(status === MediaPlayer.Loaded)
                statusString = "the media has been loaded"
            if(status === MediaPlayer.Buffering)
                statusString = "the media is buffering data"
            if(status === MediaPlayer.Stalled)
                statusString = "playback has been interrupted while the media is buffering data"
            if(status === MediaPlayer.Buffered)
                statusString = "the media has buffered data"
            if(status === MediaPlayer.EndOfMedia)
                statusString = "the media has played to the end"
            if(status === MediaPlayer.InvalidMedia)
                statusString = "the media cannot be played"
            if(status === MediaPlayer.UnknownStatus)
                statusString = "unknown"
            return statusString
        }

    }

}
