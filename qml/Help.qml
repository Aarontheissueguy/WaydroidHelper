import QtQuick 2.9
import QtGraphicalEffects 1.0
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2
Page {
    id: helpPage

    header: PageHeader {
        id: header
        title: i18n.tr("Help")
        opacity: 1
    }
    WebView {
      anchors.fill: parent
      url: "https://waydro.id"
    }
}
