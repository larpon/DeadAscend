import QtQuick 2.0

import Qak 1.0
import Qak.Tools 1.0
import Qak.QtQuick 2.0

import ".."
import "."

Base {
    id: scene

    ready: true

    anchors { fill: parent }

    Component.onCompleted: {
        var sfx = sounds
        //sfx.add("level"+sceneName,"hum",App.getAsset("sounds/low_machine_hum.wav"))

    }

    Component.onDestruction: {

    }

    property int currentStep: 0

    function nextStep() {
        currentStep++
    }

    function stepText(step) {
        if(step === 0)
            return 'Welcome survivor<br>This is how you<br>play the game'
        if(step === 1)
            return 'Tab on objects<br>to examine them'
        if(step === 2)
            return 'Good job!'
        if(step === 3)
            return 'Tab once on objects<br>to pick them up'
        if(step === 4)
            return 'Good job!'
        if(step === 5)
            return 'Objects you have<br>picked up is in<br>your inventory...'
        if(step === 6)
            return 'To use objects<br>hold and drag them<br>from the inventory to the room<br>(place the zombie doll on the box)'
        if(step === 7)
            return 'Good job!'
        if(step === 8)
            return 'That\'s basically it!<br>Now try and put the wiener<br>on the doll\'s head!'
        if(step === 9)
            return 'Good job!<br>You have completed the tutorial!<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="red">NOW TRY THE REAL DEAL</font>'

        return ""
    }

    onCurrentStepChanged: {
        arrowW.opacity = 0
        arrowSW.opacity = 0
        arrowNE.opacity = 0
        arrowSE.opacity = 0
        var o
        if(currentStep === 1) {
            continueButton.opacity = 0
            o = game.getObject('light_1_tut')
            arrowW.x = o.x + o.width
            arrowW.y = o.y + o.halfHeight - arrowW.halfHeight
            arrowW.opacity = 1

            o = game.getObject('box_1_tut')
            arrowSW.x = o.x + o.halfWidth
            arrowSW.y = o.y - arrowSW.height
            arrowSW.opacity = 1
        }
        if(currentStep === 2) {
            continueButton.opacity = 1
        }
        if(currentStep === 3) {
            continueButton.opacity = 0
            o = game.getObject('zombie_doll')
            o.locked = false

            arrowSW.x = o.x + o.width
            arrowSW.y = o.y - arrowSW.height + 10
            arrowSW.opacity = 1
        }
        if(currentStep === 4) {
            continueButton.opacity = 1
        }
        if(currentStep === 5) {
            game.inventory.show = true
            arrowSW.x = arrowSW.width + 25
            arrowSW.y = scene.height - arrowSW.height * 2.4
            arrowSW.opacity = 1
        }
        if(currentStep === 6) {
            game.inventory.show = true
            continueButton.opacity = 0

            arrowNE.x = 250
            arrowNE.y = scene.height - arrowNE.height * 2.4
            arrowNE.opacity = 1
        }
        if(currentStep === 7) {
            continueButton.opacity = 1
        }
        if(currentStep === 8) {
            game.inventory.show = false
            continueButton.opacity = 0

            o = game.getObject('zombie_doll')
            o.acceptDrops = true
            arrowW.x = o.x + o.width + 10
            arrowW.y = o.y - arrowW.halfHeight
            arrowW.opacity = 1

            o = game.getObject('wiener')
            o.locked = false
            arrowSE.x = o.x
            arrowSE.y = o.y - arrowSE.height
            arrowSE.opacity = 1

        }
        if(currentStep === 9) {
            continueButton.opacity = 1

        }
        if(currentStep === 10) {
            core.goBack()
        }
    }

    MouseArea {
        anchors { fill: parent }
        z: -10
        onClicked: { }
    }

    Item {
        id: textCont
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 160
        }

        Text {
            id: tutorialText

            anchors { centerIn:  parent }

            color: core.colors.yellow
            style: Text.Outline; styleColor: core.colors.black
            font { family: core.fonts.standard.name; capitalization: Font.MixedCase }
            font.pixelSize: 50

            Behavior on scale {
                NumberAnimation { duration: 100 }
            }

            text: stepText(currentStep);
        }
    }



    TextButton {
        id: continueButton

        x: parent.width - width - 20
        y: parent.halfHeight - halfHeight

        font.pixelSize: 60

        panicClickSafety: true
        bounce: true

        text: 'Continue'

        onClicked: nextStep()

        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Area {
        id: box
        name: "box_1_tut"
        stateless: true

        DropSpot {

            enabled: currentStep === 6
            anchors { fill: parent }

            keys: [ "zombie_doll" ]

            name: "zombie_doll_drop"

            onDropped: {
                drop.accept()
                var o = drag.source
                o.x = box.x + 60
                o.y = box.y - o.height + o.halfHeight
                o.clickable = false
                nextStep()
            }
        }
    }

    Image {
        id: arrowW
        source: App.getAsset("sprites/arrows/w.png")

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Image {
        id: arrowSW
        source: App.getAsset("sprites/arrows/sw.png")

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Image {
        id: arrowSE
        source: App.getAsset("sprites/arrows/se.png")

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Image {
        id: arrowNE
        source: App.getAsset("sprites/arrows/ne.png")

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Image {
        id: realDeal
        source: App.getAsset("sprites/arrows/w.png")

        visible: opacity > 0
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    onObjectClicked: {

        if(object.name === "light_1_tut" && currentStep === 1) {
            arrowW.opacity = 0
            if(arrowSW.opacity < 1)
                nextStep()
        }

        if(object.name === "box_1_tut" && currentStep === 1) {
            arrowSW.opacity = 0
            if(arrowW.opacity < 1)
                nextStep()
        }

        if(object.name === "zombie_doll" && currentStep === 3) {
            arrowSW.opacity = 0
            nextStep()
        }
    }

    onObjectDropped: {
        if(object.name === "wiener") {

            var zd = game.getObject('zombie_doll')
            object.x = zd.x
            object.y = zd.y - 5

            arrowSE.opacity = 0
            arrowW.opacity = 0
            nextStep()
        }
    }


    onObjectTravelingToInventory: {
    }

    onObjectDragged: {
    }

    onObjectReturned: {
    }

    onObjectAddedToInventory: {
        if(object.name === "wiener") {
            arrowSE.opacity = 0
        }
    }

    onObjectRemovedFromInventory: {
    }

}
