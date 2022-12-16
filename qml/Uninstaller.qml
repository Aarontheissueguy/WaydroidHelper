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
        ActivityIndicator {
            id: activity
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: parent.height / 15
        }
        Label {
            id: content
            anchors.top: (activity.running == true) ? activity.bottom : parent.top
            anchors.topMargin: (activity.running == true) ? parent.height / 15 : parent.height / 25
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 1.5
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Press 'start' to uninstall WayDroid.")
            font.pointSize: 25
            wrapMode: Text.Wrap
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
                activity.running = true
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
            onClicked: {
		console.log("uninstaller is running")
                if( startButtonFake.color == "#008000" )
                    pageStack.pop();
	    }
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

            python.setHandler('runningStatus',
                function (status) {
                    content.text = status
                    activity.running = false
                    startButtonFake.color = "green"
                    startButtonFake.text = i18n.tr("OK")
                })

        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
