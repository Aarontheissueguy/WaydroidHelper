import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Lomiri.Components.Popups 1.3

Page {
    id: uninstallerPage
    header: PageHeader {
        id: header
        title: i18n.tr("Uninstall Waydroid")
        opacity: 1
    }

    property bool completed: false
    property bool running: false
    property alias wipeData: wipe.checked

    property string state: "initial"
    property var states: new Map([
        [ "initial", i18n.tr("Press 'start' to uninstall Waydroid.") ],
        [ "starting", i18n.tr("Uninstallation starting") ],
        [ "container", i18n.tr("Stopping Waydroid container service") ],
        [ "cleanup", i18n.tr("Cleaning up Waydroid images") ],
        [ "complete", i18n.tr("Uninstallation complete!") ],
    ])

    function startUninstallation(password) {
        uninstallerPage.running = true;
        root.setAppLifecycleExemption();
        python.call('installer.uninstall', [ password, wipeData ]);
    }

    function showPasswordPrompt() {
        if (root.inputMethodHints === null) {
            startUninstallation('');
            return;
        }

        PopupUtils.open(passwordPrompt);
    }

    Connections {
        target: python

        onState: { // (string id, bool hasProgress)
            if (!uninstallerPage.states.has(id)) {
                console.log('unknown state', id);
                return;
            }

            if (id === uninstallerPage.state && hasProgress === !progress.indeterminate) {
                return;
            }

            progress.indeterminate = !hasProgress;
            uninstallerPage.state = id;

            if (id === "complete") {
                uninstallerPage.completed = true;
                uninstallerPage.running = false;
                root.unsetAppLifecycleExemption();
            }
        }
    }

    ColumnLayout {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: units.gu(3)

        Label {
            id: content
            text: uninstallerPage.states.get(uninstallerPage.state)
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: uninstallerPage.width / 1.5
        }

        ProgressBar {
            id: progress
            visible: running
            indeterminate: true
            value: 0
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: progressText
            visible: running
            opacity: progress.indeterminate ? 0 : 1
            Layout.alignment: Qt.AlignHCenter
        }

        Row {
            visible: !running && !uninstallerPage.completed
            spacing: units.gu(1)
            Layout.alignment: Qt.AlignHCenter

            CheckBox {
                id: wipe
            }

            Label {
                text: i18n.tr("Wipe app data")

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wipe.checked = !wipe.checked;
                    }
                }
            }
        }

        Button {
            id: startButton
            visible: !running
            color: theme.palette.normal.positive
            text: uninstallerPage.completed ? i18n.tr("Ok") : i18n.tr("Start")
            Layout.alignment: Qt.AlignHCenter

            onClicked: {
                if (!uninstallerPage.completed) {
                    showPasswordPrompt();
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
        }
    }

    Python {
        id: python

        signal state(string id, bool hasProgress)

        Component.onCompleted: {
            python.setHandler('state', state);
        }

        onError: {
            console.log('python error:', traceback);
        }
    }
}
