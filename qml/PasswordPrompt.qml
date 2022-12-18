import QtQuick 2.7
import Ubuntu.Components 1.3
import io.thp.pyotherside 1.4
import Ubuntu.Components.Popups 1.3

Dialog {
    id: passPrompt
    title: i18n.tr("Authorization")

    signal password(string password)
    signal cancel
    property bool blocked: false

    QtObject {
        id: d

        function checkPassword(password) {
            return new Promise((resolve, reject) => {
                python.call('pam.authenticate', [ "phablet", password ], (result) => {
                    if (!result) {
                        reject();
                        return;
                    }

                    resolve();
                });
            });
        }
    }

    Label {
        text: root.isPasswordNumeric ? i18n.tr("Enter your passcode:") : i18n.tr("Enter your password:")
        wrapMode: Text.Wrap
    }

    TextField {
        id: password
        readOnly: blocked
        placeholderText: root.isPasswordNumeric ? i18n.tr("passcode") : i18n.tr("password")
        echoMode: TextInput.Password
        inputMethodHints: root.inputMethodHints
        maximumLength: root.isPasswordNumeric ? 4 : 32767
        onDisplayTextChanged: {
            if (password.text.length > 0) {
                wrongPasswordHint.visible = false;
            }
        }
    }

    Label {
        id: wrongPasswordHint
        color: theme.palette.normal.negative
        text: root.isPasswordNumeric ? i18n.tr("Incorrect passcode") : i18n.tr("Incorrect password")
        visible: false
    }

    Button {
        text: i18n.tr("Ok")
        enabled: !blocked
        color: theme.palette.normal.positive
        onClicked: {
            blocked = true;
            d.checkPassword(password.text)
                .then(() => {
                    PopupUtils.close(passPrompt);
                    passPrompt.password(password.text);
                    password.text = '';
                })
                .catch(() => {
                    wrongPasswordHint.visible = true;
                    password.text = '';
                    blocked = false;
                });
        }
    }

    Button {
        text: i18n.tr("Cancel")
        enabled: !blocked
        onClicked: {
            passPrompt.cancel();
            PopupUtils.close(passPrompt);
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('pam', () => {});
        }

        onError: {
            console.log('python error:', traceback);
        }
    }
}
