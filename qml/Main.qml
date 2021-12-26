/*
 * Copyright (C) 2021  Aaron Hafer
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * waydroidhelper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Components.Popups 1.3
import "modules"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'waydroidhelper.aaronhafer'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)
    
    property string appVersion : "v1.0.1"    

    PageStack {
      id: pageStack
      Component.onCompleted: push(page0)
      Page {
        id: page0
        visible: false
        anchors.fill: parent
        header: PageHeader {
            id: header0
            title: i18n.tr('Waydroid Helper')
      trailingActionBar {
        actions: [
        Action {
            iconName: "info"
            text: i18n.tr("About")
            onTriggered: pageStack.push(Qt.resolvedUrl("About.qml"))
        },
        Action {
            iconName: "dialog-question-symbolic"
            text: i18n.tr("Help")
            onTriggered: pageStack.push(Qt.resolvedUrl("Help.qml"))
        }
      ]
    }
  }

        Column {
            anchors.top: header0.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            ListItem {
                Label {
                    text: "Install Waydroid 📲>"
                    anchors.centerIn: parent
                    font.pointSize: 35
                    wrapMode: Text.WordWrap
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Installer.qml"))

                }

            }
            ListItem {
                Label {
                    text: "Show/Hide apps 🙈>"
                    anchors.centerIn: parent
                    font.pointSize: 35
                    wrapMode: Text.WordWrap
                }
                onClicked: {
                  PopupUtils.open(dialogHide)
                  pageStack.push(page1)

                }

            }
            ListItem {
                  Label {
                      text: '"Waydroid Stop" app 🛑>'
                      anchors.centerIn: parent
                      font.pointSize: 35
                      wrapMode: Text.WordWrap
                  }
                  onClicked: {
                      pageStack.push(page2)

                  }

              }
            ListItem {
                  Label {
                      text: "Waydroid Help ❓>"
                      anchors.centerIn: parent
                      font.pointSize: 35
                      wrapMode: Text.WordWrap
                  }
                  onClicked: {
                      pageStack.push(page3)

                  }

              }

            ListItem {
                  Label {
                      text: "Uninstall Waydroid 🗑>"
                      anchors.centerIn: parent
                      font.pointSize: 35
                      wrapMode: Text.WordWrap
                  }
                  onClicked: {
                      pageStack.push(Qt.resolvedUrl("Uninstaller.qml"))

                  }

              }
        }


      }

      Page {
          id: page1
          anchors.fill: parent
          visible: false
          header: PageHeader {
              id: header1
              title: i18n.tr('Show/Hide')
          }
          Component {
              id: dialogHide
              Dialog {
                  id: dialogueHide
                  title: "Show/Hide apps"
                  Label {
                    text: "Swipe on the listed apps to either hide them(bin) or show them(plus) in the Appdrawer. This will NOT install or uninstall the selected app. Reload the Appdrawer for the changes to take effect."
                    wrapMode: Text.Wrap
                  }

                  Button {
                      color: "green"
                      text: "ok"
                      onClicked: PopupUtils.close(dialogueHide)
                  }

              }
          }

          Flickable {
              id: applist
              property var repeaterModel: []
              anchors.top: header1.bottom
              anchors.bottom: parent.bottom
              anchors.left: parent.left
              anchors.right: parent.right
              contentHeight: applistcolumn.implicitHeight

              // this will not have any effect
              ViewItems.selectMode: true
              Column {
                  id: applistcolumn
                  // this will work
                  ViewItems.selectMode: false
                  width: parent.width
                  Repeater {
                      model: applist.repeaterModel
                      ListItem {
                          Label {
                              text: modelData
                              anchors.centerIn: parent
                              font.pointSize: 35
                              wrapMode: Text.WordWrap
                          }

                          leadingActions: ListItemActions {
                              actions: [
                                  Action {
                                      iconName: "delete"
                                      onTriggered: {
                                        python.call('appdrawer.hide', [modelData], function(returnValue) {
                                            console.log('hide was executed');
                                        })
                                      }
                                  }
                              ]
                          }
                          trailingActions: ListItemActions {
                              actions: [
                                  Action {
                                      iconName: "add"
                                      onTriggered: {
                                        python.call('appdrawer.show', [modelData], function(returnValue) {
                                            console.log('show was executed');
                                        })
                                      }
                                  }
                              ]
                          }
                      }
                 }
             }
          }
      }

      Page {
        id: page2
        visible: false
        anchors.fill: parent
        header: PageHeader {
            id: header2
            title: i18n.tr('Waydroid Stop')
        }
        Label {
          id: stopappExplain
          anchors.top: header2.bottom
          anchors.topMargin: 5
          anchors.horizontalCenter: parent.horizontalCenter
          width: parent.width * 0.9
          text: 'The "Waydroid Stop" app allows you to easily stop Waydroid without entering the terminal. Once you press "Add" a new icon will appear in your appdrawer. Pressing this icon will stop Waydroid if it has crashed or anything else went wrong. If you open any of your Android apps, waydroid will start automaticly again.'
          font.pointSize: 25
          wrapMode: Text.WordWrap
        }
        Image {
          anchors.left: parent.left
          anchors.leftMargin: parent.width / 8
          anchors.right: parent.right
          anchors.rightMargin: parent.width / 8
          anchors.top: stopappExplain.bottom
          anchors.bottom: removeButton.top
          fillMode: Image.PreserveAspectFit
          source: "../assets/waydroidstop.jpg"
        }
        Button {
          id: removeButton
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 20
          anchors.left: parent.left
          anchors.leftMargin: parent.width / 8
          color: "red"
          text: "Remove"
          onClicked: {
            python.call('stopapp.remove', [], function(returnValue) {
                console.log('create was executed');
            })
          }
        }
        Button {
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 20
          anchors.right: parent.right
          anchors.rightMargin: parent.width / 8
          color: "green"
          text: "Add"
          onClicked: {
            python.call('stopapp.create', [], function(returnValue) {
                console.log('create was executed');
            })
          }
        }
      }
    }

    Page {
      id: page3
      visible: false
      anchors.fill: parent
      header: PageHeader {
          id: header3
          title: i18n.tr('Waydroid Help')
      }

        CenteredLabel {
          id: helpExplain
          anchors.top: header3.bottom
          anchors.topMargin: 5
          width: parent.width * 0.9
          text: i18n.tr ("<b>You need to run these commands in the terminal app. Tap a command to copy it to the clipboard.</b><br><br>")

          textSize: Label.Large
          textFormat: Text.RichText
      }
      Flickable {
        anchors.top: helpExplain.bottom
        anchors.topMargin: 5
        anchors.bottom: page3.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: page3.width * 0.9
        contentHeight: helpList.implicitHeight
        clip: true
        Label {
          id: helpList
          anchors.left: parent.left
          anchors.right: parent.right


          text: "<a href='waydroid -h'>waydroid -h</a>, --help show this help message and exit <br><br>" +
                "<a href='waydroid -V'>waydroid -V</a>, --version show program's version number and exit <br><br>" +
                "<a href='waydroid -l LOG'>waydroid -l LOG</a>, --log LOG path to log file <br><br>" +
                "<a href='waydroid --details-to-stdout'>waydroid --details-to-stdout</a> print details (e.g. build output) to stdout, instead of writing to the log <br><br>" +
                "<a href='waydroid -v'>waydroid -v</a>, --verbose write even more to the logfiles (this may reduce performance) <br><br>" +
                "<a href='waydroid -q'>waydroid -q</a>, --quiet do not output any log messages"
          textSize: Label.Large
          textFormat: Text.RichText
          wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          onLinkActivated: {
              var mimeData = Clipboard.newData();
              mimeData.text = link;
              Clipboard.push(mimeData);
              PopupUtils.open(dialogCopy)
          }

        }
      }
      Component {
          id: dialogCopy
          Dialog {
              id: dialogueCopy
              title: "Copied"
              Label {
                text: "You copied a command to your clipboard. You can now paste and use it in the terminal app."
                wrapMode: Text.Wrap
              }

              Button {
                  text: "ok"
                  color: "green"
                  onClicked: PopupUtils.close(dialogueCopy)
              }

          }
      }
   }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importNames('main', ['appdrawer'], function() {
                console.log('appdrawer module imported');
                python.call('appdrawer.clean', [], function(returnValue) {
                    console.log('appdrawer.clean returned ' + returnValue);
                    applist.repeaterModel = returnValue
                })
            });

            importNames('main', ['stopapp'], function() {
                console.log('stopapp module imported');
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
