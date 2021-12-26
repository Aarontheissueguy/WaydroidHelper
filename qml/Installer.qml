import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Popups 1.3

Page {
    id: aboutPage

    header: PageHeader {
        id: header
        title: i18n.tr("Install Waydroid")
        opacity: 1
    }
    Rectangle {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Component.onCompleted: PopupUtils.open(dialogInstall)
        Label {
            id: content
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            text: 'By pressing "start" the installation will, well... start. The installer will let you know what it is doing at the moment. Be patient! The installation may take a while. Do not close the app during the installation! Once Waydroid is installed, your device will restart automatically. I reccomend to disable screen suspension in the settings to keep the screen always on without touching it.'
            font.pointSize: 25
            wrapMode: Text.WordWrap
        }
        Button {
            id: startButton
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "green"
            text: "start"
            onClicked: {
                startButton.visible = false
                startButtonFake.visible = true
                PopupUtils.open(passwordPrompt)
            }
        }
        Button {
            id: startButtonFake
            visible: false
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "gray"
            text: "running"
            onClicked: console.log("Installer is running")
        }
    }
    Component {
        id: dialogInstall
        Dialog {
            id: dialogueInstall
            title: "Disclaimer!"
            Label {
                text: "You are about to use an experimental Waydroid installer! <br> Supported devices (✔️ = tested): <br> * VollaPhone ✔️ (X) <br> * Redmi Note 7 (Pro) <br> * Redmi Note 9 (Pro/Pro Max/S) <br> * Fairphone 3(+) <br> * Pixel 3a <br> There is absolutely no warranty for this to work! Do not use this installer if you dont want to risk to brick your device (,which is highly unlikely though)!"
                wrapMode: Text.Wrap
            }

            Button {
                text: "I understand the risk"
                color: "red"
                onClicked: PopupUtils.close(dialogueInstall)
            }
            Button {
                text: "cancel"
                color: "green"
                onClicked: {
                    PopupUtils.close(dialogueInstall)
                    pageStack.pop()
                
                }

            }

        }
    }

    Component {
        id: passwordPrompt
        Dialog {
            id: passPrompt
            title: "Password"
            Label {
                text: "Enter your password:"
                wrapMode: Text.Wrap
            }
            TextField {
                id: password
                placeholderText: "password"
                echoMode: TextInput.Password
            }

            Button {
                text: "ok"
                color: "green"
                onClicked: {
                    PopupUtils.close(passPrompt)
                    python.call('installer.install', [password.text], function(returnValue) {
                        console.log('test was executed');
                    })
                    
                
                }

            }

        }
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importNames('installer', ['installer'], function() {
                console.log('installer module imported');

            });

            python.setHandler('whatState',
                function (state) {
                    content.text = state
                })

        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
