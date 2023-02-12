import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    id: aboutPage

    header: PageHeader {
        title: i18n.tr("About")
    }

    ScrollView {
        id: scrollView
        anchors {
            top: aboutPage.header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        clip: true

        Column {
            id: aboutColumn
            spacing: units.gu(2)
            width: scrollView.width

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("WayDroid Helper")
                fontSize: "x-large"
            }

            LomiriShape {
                width: units.gu(12); height: units.gu(12)
                anchors.horizontalCenter: parent.horizontalCenter
                radius: "medium"
                image: Image {
                    source: Qt.resolvedUrl("../assets/logo.png")
                }
            }

            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("Version: ") + "%1".arg(Qt.application.version)
            }

            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: i18n.tr("A Tweak tool application for WayDroid on Ubuntu Touch.")
            }

            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                //TRANSLATORS: Please make sure the URLs are correct
                text: i18n.tr("This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the <a href='https://www.gnu.org/licenses/gpl-3.0.en.html'>GNU General Public License</a> for more details.")
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "<a href='https://github.com/Aarontheissueguy/WaydroidHelper'>" + i18n.tr("SOURCE") + "</a> | <a href='https://github.com/Aarontheissueguy/WaydroidHelper/issues'>" + i18n.tr("ISSUES") + "</a> | <a href='https://www.paypal.com/paypalme/AaronTheIssueGuy'>" + i18n.tr("DONATE") + "</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }           

            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                style: Font.Bold
                text: i18n.tr("Copyright") + " (c) 2021 - 2022 Aaron Hafer"
            }
            
            Label {
                width: parent.width
                linkColor: LomiriColors.orange
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                style: Font.Bold
                text: i18n.tr("General contributions: ") + "Rudi Timmermans"
           }
        }
    }
}
