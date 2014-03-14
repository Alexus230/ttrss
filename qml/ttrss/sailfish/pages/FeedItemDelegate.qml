//Copyright Hauke Schade, 2012-2013
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: listItem

    signal clicked
    property alias pressed: mouseArea.pressed

    contentHeight: Theme.itemSizeMedium
    width: parent.width

    Row {
        spacing: Theme.paddingMedium
        anchors.fill: parent
        anchors.leftMargin: icon.visible ? icon.width + Theme.paddingMedium : 0
        Image {
            source: "../../resources/ic_star_enabled.png"
            visible: model.marked
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
        Image {
            source: "../../resources/ic_rss_enabled.png"
            visible: model.rss
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium
        spacing: Theme.paddingMedium
        clip: true

        Image {
            id: icon
            sourceSize.height: 80
            sourceSize.width: 80
            asynchronous: true
            width: 60
            height: 60
            anchors.verticalCenter: parent.verticalCenter

            source: feed.isCat ? model.icon : ''

            visible: settings.displayIcons && model.icon != '' && feed.isCat && status == Image.Ready
        }

        Column {
            width: parent.width
            Label {
                id: mainText
                width: parent.width
                text: model.title
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeMedium
                color: listItem.highlighted ? Theme.highlightColor : ((model.unreadcount > 0) ? Theme.primaryColor : Theme.secondaryColor)
                elide: Text.ElideRight
                truncationMode: TruncationMode.Elide
            }

            Label {
                id: subText
                width: parent.width
                text: model.subtitle
                font.weight: Font.Light
                font.pixelSize: Theme.fontSizeSmall
                color: listItem.highlighted ? Theme.highlightColor : ((model.unreadcount > 0) ? Theme.primaryColor : Theme.secondaryColor)
                maximumLineCount: 4
                elide: Text.ElideRight
                truncationMode: TruncationMode.Elide
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text != ""
            }
//            Row {
//                id: myrow
//                property variant mymod: model
//                spacing: constant.paddingMedium

//                Repeater {
//                    model: myrow.mymod.labels
//                    LabelLabel {
//                        label: myrow.mymod.labels.get(index)
//                    }
//                }
//            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: listItem.clicked();
        onPressAndHold: listItem.pressAndHold();
    }
}