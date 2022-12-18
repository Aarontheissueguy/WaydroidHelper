import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4
import Ubuntu.Components.Popups 1.3

Page {
    id: installerPage
    header: PageHeader {
        id: header
        title: i18n.tr("Install Waydroid")
        opacity: 1
        trailingActionBar {
            actions: [
            Action {
                iconName: "google-plus-symbolic"
                text: i18n.tr("GAPPS")
                onTriggered: PopupUtils.open(gapps)

            }
        ]
        }
    }

    property var inputMethodHints: Qt.ImhHiddenText
    property var isPasswordNumeric: inputMethodHints & Qt.ImhDigitsOnly

    function startInstallation(password) {
        python.call('installer.install', [ password, gAPPS ], () => {
            console.log('installation started');
        })
    }

    function checkPassword(password) {
        return new Promise((resolve, reject) => {
            python.call('installer.check_password', [ password ], (result) => {
                if (!result) {
                    reject();
                    return;
                }

                resolve();
            });
        });
    }

    function showPasswordPrompt() {
        const PASSWORD_TYPE_KEYBOARD = 0;
        const PASSWORD_TYPE_NUMERIC = 1;

        python.call('installer.get_password_type', [], (passwordType) => {
            const value = python.getattr(passwordType, 'value');

            switch (value) {
                case PASSWORD_TYPE_KEYBOARD:
                    installerPage.inputMethodHints = Qt.ImhHiddenText;
                    break;
                case PASSWORD_TYPE_NUMERIC:
                    installerPage.inputMethodHints = Qt.ImhHiddenText | Qt.ImhDigitsOnly;
                    break;
                default:
                    // no password set, just start the installation
                    startInstallation('');
                    return;
            }

            PopupUtils.open(passwordPrompt);
        });
    }

    MainView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        Component.onCompleted: PopupUtils.open(dialogInstall)

        ActivityIndicator {
            id: activity
            anchors.top: parent.top
            anchors.topMargin: parent.height / 15
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: content
            anchors.top: (activity.running == true) ? activity.bottom : parent.top
            anchors.topMargin:(activity.running == true) ? parent.height / 15 : parent.height / 25
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            width: parent.width / 1.5
            text: i18n.tr("By pressing 'start' the installation will, well... start. The installer will let you know what it is doing at the moment. Be patient! The installation may take a while. Do not close the app during the installation! I reccomend to disable screen suspension in the settings to keep the screen always on without touching it.")
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
                showPasswordPrompt();
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
                console.log("Installer is running")
                if(activity.running == false){
                    pageStack.pop();
		}
            }
        }
    }

    property var gAPPS: false
    Component {
        id: dialogInstall
        Dialog {
            id: dialogueInstall
            title: "Disclaimer!"
            Label {
                text: i18n.tr("You are about to use an experimental Waydroid installer! <br> Supported devices:") + i18n.tr("<br>Fairephone 3/3+<br>OnePlus 5/5T<br>Pixel/Pixel XL<br>Pixel 2 XL<br>Pixel 3a<br>Poco F1<br>Redmi Note 7/7 Pro/9 Pro/9 Pro Max<br>Samsung Galaxy S10<br>SHIFT6mq<br>Vollaphone (X)<br>") + i18n.tr("Other devices using Halium 9 or above may or may not work as well! <br> There is absolutely no warranty for this to work! Do not use this installer if you dont want to risk to brick your device permenantly (,which is highly unlikely though)!")
                wrapMode: Text.Wrap
            }

            Button {
                text: i18n.tr ("I understand the risk")
                color: "red"
                onClicked: PopupUtils.close(dialogueInstall)
            }
            Button {
                text: i18n.tr("Cancel")
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
            title: i18n.tr("Authorization")

            property bool blocked: false

            Label {
                text: isPasswordNumeric ? i18n.tr("Enter your passcode:") : i18n.tr("Enter your password:")
                wrapMode: Text.Wrap
            }

            TextField {
                id: password
                readOnly: blocked
                placeholderText: isPasswordNumeric ? i18n.tr("passcode") : i18n.tr("password")
                echoMode: TextInput.Password
                inputMethodHints: installerPage.inputMethodHints
                maximumLength: isPasswordNumeric ? 4 : 32767
                onDisplayTextChanged: {
                    if (password.text.length > 0) {
                        wrongPasswordHint.visible = false;
                    }
                }
            }

            Label {
                id: wrongPasswordHint
                color: theme.palette.normal.negative
                text: isPasswordNumeric ? i18n.tr("Incorrect passcode") : i18n.tr("Incorrect password")
                visible: false
            }

            Button {
                text: i18n.tr("Ok")
                enabled: !blocked
                color: "green"
                onClicked: {
                    blocked = true;
                    checkPassword(password.text)
                        .then(() => {
                            PopupUtils.close(passPrompt)
                            startInstallation(password.text);
                            password.text = '';
                        })
                        .catch(() => {
                            wrongPasswordHint.visible = true;
                            password.text = '';
                            blocked = false;
                        });
                }
            }

        }
    }

    Component {
        id: gapps
        Dialog {
            id: gappsPromt
            title: "Google Apps"
            Label {
                text: i18n.tr("You can install a special version of Waydroid that comes with google apps. (I personally do not recommend this as it will result in worse privacy.)")
                wrapMode: Text.Wrap
            }

            Button {
                text: i18n.tr("Enable GAPPS")
                color: "red"
                onClicked: {
                    gAPPS = true
                    PopupUtils.close(gappsPromt)


                }

            }
            Button {
                text: i18n.tr("Cancel")
                color: "green"
                onClicked: {
                    PopupUtils.close(gappsPromt)


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

            python.setHandler('whatState', (state) => {
                    content.text = state
                });

            python.setHandler('runningStatus', (status) => {
                    content.text = status
                    activity.running = false
                    startButtonFake.color = "green"
                    startButtonFake.text = i18n.tr("OK")
                });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
