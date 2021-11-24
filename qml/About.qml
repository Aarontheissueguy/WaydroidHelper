import QtQuick 2.9
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3

Page {
    id: aboutPage

    header: PageHeader {
        id: header
        title: i18n.tr("About WayDroid Helper")
        opacity: 1
    }

                Column {
                    id: layout

                    spacing: units.gu(3)
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: units.gu(7)
                    }

                    UbuntuShape {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: width
                        width: Math.min(parent.width/2, parent.height/1)
                        source: Image {
                            source: Qt.resolvedUrl("../assets/logo.png")
                        }
                        radius: "large"
                    }

                    Column {
                        width: parent.width
                        Label {
                            width: parent.width
                            textSize: Label.XLarge
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: i18n.tr("WayDroid Helper<br/>")
                        }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: i18n.tr("A Tweak tool application for WayDroid on Ubuntu Touch.<br/>")
                    }

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }

                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("(C) 2021 By Aaron Hafer<br/>")
                        }
                        
                        Label {
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("General contributions:<br/>") +
                                          "Rudi Timmermans<br/>"
                        }

                        Label {
                            textSize: Label.Small
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("Released under the terms of the GNU GPL v3")
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        textSize: Label.Small
                        horizontalAlignment: Text.AlignHCenter
                        linkColor: theme.palette.normal.focus
                        text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/Aarontheissueguy/WaydroidHelper\">GitHub</a>")
                        onLinkActivated: Qt.openUrlExternally(link)
                    }

                }
            }
         }

    
