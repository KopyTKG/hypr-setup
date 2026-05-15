import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bgColor

    // Time / date in top-right
    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 6

        Text {
            id: clock
            text: Qt.formatTime(new Date(), "HH:mm")
            color: config.textColor
            font.family: config.font
            font.pixelSize: 48
            font.weight: Font.Light
            Layout.alignment: Qt.AlignRight
        }
        Text {
            id: dateText
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            color: config.mutedColor
            font.family: config.font
            font.pixelSize: 16
            Layout.alignment: Qt.AlignRight
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "HH:mm")
            dateText.text = Qt.formatDate(new Date(), "dddd, MMMM d")
        }
    }

    // Centered login card
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 460
        height: 280
        color: config.cardColor
        border.color: config.borderColor
        border.width: 1
        radius: 14

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 60
            spacing: 18

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: userModel.lastUser || ""
                color: config.textColor
                font.family: config.font
                font.pixelSize: 20
                font.weight: Font.Medium
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                echoMode: TextInput.Password
                placeholderText: "Password"
                placeholderTextColor: config.mutedColor
                color: config.textColor
                font.family: config.font
                font.pixelSize: 15
                horizontalAlignment: TextInput.AlignHCenter
                background: Rectangle {
                    color: config.inputColor
                    border.color: passwordField.activeFocus ? config.mutedColor : config.borderInputColor
                    border.width: passwordField.activeFocus ? 1 : 0
                    radius: height / 2
                }
                Keys.onReturnPressed: doLogin()
                Keys.onEnterPressed: doLogin()
                Component.onCompleted: forceActiveFocus()
            }

            Text {
                id: errorText
                Layout.alignment: Qt.AlignHCenter
                color: "#f7768e"
                font.family: config.font
                font.pixelSize: 13
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    // Hostname at the bottom
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        text: sddm.hostName
        color: config.mutedColor
        font.family: config.font
        font.pixelSize: 13
    }

    function doLogin() {
        const user = userModel.lastUser
        if (user && passwordField.text.length > 0) {
            sddm.login(user, passwordField.text, sessionModel.lastIndex)
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Authentication failed"
            errorText.opacity = 1
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorText.text = ""
            errorText.opacity = 0
        }
    }
}
