import QtQuick 2.9
import Lomiri.Components 1.3

Label {
    anchors.horizontalCenter: parent.horizontalCenter
    width: Math.min(units.gu(80), parent.width - gnalMargins * 3)
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
}
