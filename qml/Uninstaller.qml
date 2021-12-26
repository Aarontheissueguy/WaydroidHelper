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
        title: i18n.tr("Uninstall Waydroid")
        opacity: 1
    }
    MainView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        
        Label {
            id: content
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            text: i18n.tr("Press 'start' to uninstall WayDroid.")
            font.pointSize: 25
            wrapMode: Text.WordWrap
        }
        Button {
            id: startButton
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "green"
            text: i18n.tr("Start")
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
            text: i18n.tr("Running")
            onClicked: console.log("uninstaller is running")
        }
    }

    Component {
        id: passwordPrompt
        Dialog {
            id: passPrompt
            title: "Password"
            Label {
                text: i18n.tr("Enter your password:")
                wrapMode: Text.Wrap
            }
            TextField {
                id: password
                placeholderText: "password"
                echoMode: TextInput.Password
            }

            Button {
                text: i18n.tr("Ok")
                color: "green"
                onClicked: {
                    PopupUtils.close(passPrompt)
                    python.call('installer.uninstall', [password.text], function(returnValue) {
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
