import QtQuick 2.9
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Morph.Web 0.1
import QtWebEngine 1.7

Page {
    id: helpPage
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr("Help")
        opacity: 1
    }
    
      WebEngineView {
        id: webview
        anchors{ fill: parent }
        focus: true
        property var currentWebview: webview
        settings.pluginsEnabled: true

        profile:  WebEngineProfile {
          id: webContext
          httpUserAgent: "Mozilla/5.0 (Linux, Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577 Safari/537.36"
          storageName: "Storage"
          persistentStoragePath: "/home/phablet/.cache/waydroidhelper.aaronhafer/waydroidhelper.aaronhafer/QtWebEngine"
          persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        }
        anchors {
          fill:parent
          centerIn: parent.verticalCenter
        }
        
        url: "https://waydro.id"   
    }
  }
