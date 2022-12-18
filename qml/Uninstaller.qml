import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Popups 1.3

Page {
    id: uninstallerPage
    header: PageHeader {
        id: header
        title: i18n.tr("Uninstall Waydroid")
        opacity: 1
    }

    property bool completed: false

    function startUninstallation(password) {
        python.call('installer.uninstall', [ password ]);
    }

    function showPasswordPrompt() {
        if (root.inputMethodHints === null) {
            startUninstallation('');
            return;
        }

        PopupUtils.open(passwordPrompt);
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
            text: i18n.tr("Press 'start' to uninstall Waydroid.")
            font.pointSize: 25
            wrapMode: Text.Wrap
        }

        Button {
            id: startButton
            enabled: !activity.running
            anchors.top: content.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: theme.palette.normal.positive
            text: uninstallerPage.completed ? i18n.tr("Ok") : i18n.tr("Start")
            onClicked: {
                if (!uninstallerPage.completed) {
                    activity.running = true
                    PopupUtils.open(passwordPrompt);
                    return;
                }
                
                pageStack.pop();
            }
        }
    }

    Component {
        id: passwordPrompt

        PasswordPrompt {
            onPassword: {
                startUninstallation(password);
            }

            onCancel: {
                activity.running = false;
            }
        }
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importNames('installer', ['installer'], () => {});

            python.setHandler('whatState', (state) => {
                content.text = state;
            });

            python.setHandler('runningStatus', (status) => {
                content.text = status;
                uninstallerPage.completed = true;
                activity.running = false;
            });
        }

        onError: {
            console.log('python error:', traceback);
        }
    }
}
