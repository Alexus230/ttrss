/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2016  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../items"

Page {
    id: feedsPage
    property var category
    property bool needsUpdate: false

    Component.onCompleted: {
        feedModel.category = feedsPage.category
        feedModel.clear()
        feedModel.update()
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        model: feedModel

        PullDownMenu {
            SettingsItem {}
            MenuItem {
                text: qsTr("Add subscription")
                onClicked: add_subscription()
            }
            MenuItem {
                text: qsTr("Logout")
                visible: pageStack.depth === 1
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("MainPage.qml"),
                                      { doAutoLogin: false })
                }
            }
            MenuItem {
                text: qsTr("Update")
                enabled: !network.loading
                onClicked: {
                    feedModel.update()
                }
            }
            ToggleShowAllItem {
                onUpdateView: {
                    if (feedsPage.visible) {
                        feedModel.update()
                    } else {
                        feedsPage.needsUpdate = true
                    }
                }
            }
        }

        delegate: FeedDelegate {
            onClicked: {
                feedModel.selectedIndex = index
                showFeed(model)
            }
        }

        header: PageHeader {
            title: category ? category.title : ""
        }
        ViewPlaceholder {
            enabled: listView.count == 0
            text: network.loading ?
                      qsTr("Loading") :
                      settings.showAll ? qsTr("No feeds in category") : qsTr("Category has no unread items")
        }
        BusyIndicator {
            visible: listView.count != 0 && network.loading
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }
        VerticalScrollDecorator { }
    }

    function showFeed(feedModel) {
        if(feedModel !== null) {
            pageStack.push(Qt.resolvedUrl("FeedItems.qml"),
                           { feed: feedModel })
        }
    }

    onVisibleChanged: {
        if (visible) {
            cover = Qt.resolvedUrl("../cover/FeedsCover.qml")
            if (feedsPage.needsUpdate) {
                feedsPage.needsUpdate = false
                feedModel.update()
            }
        }
    }

    function add_subscription() {
        var params = {
            initial: feedsPage.category.categoryId
        }
        var dialog = pageStack.push(Qt.resolvedUrl("AddSubscription.qml"),
                                    params)

        dialog.accepted.connect(function() {
            var ttrss = rootWindow.getTTRSS()
            ttrss.subscribe(dialog.selected, dialog.src, subscribed)
        })

        function subscribed(result) {
            switch (result) {
            case 0:
                notification.show(qsTr('Already subscribed to Feed'))
                break
            case 1:
                //notification.show(qsTr('Feed added'))

                // During categoryModel.update() the elements in
                // categoryModel will be removed and therefore
                // feedsPage.category and feeds.category become
                // null.
                //
                // The following code sets both
                // feedsPage.category and feedModel.category
                // back to its previous value.
                var catId = feedsPage.category.categoryId;
                function tmp() {
                    feedsPage.category = categoryModel.getItemForId(catId);
                    feedModel.category = feedsPage.category
                    feedModel.update()
                    categoryModel.updateFinished.disconnect(tmp)
                }
                categoryModel.updateFinished.connect(tmp)

                categoryModel.update()
                break
            case 2:
                notification.show(qsTr('Invalid URL'))
                break
            case 3:
                notification.show(qsTr('URL content is HTML, no feeds available'))
                break
            case 4:
                notification.show(qsTr('URL content is HTML which contains multiple feeds'))
                break
            case 5:
                notification.show(qsTr('Couldn\'t download the URL content'))
                break
            case 5:
                notification.show(qsTr('Content is an invalid XML'))
                break
            default:
                notification.show(qsTr('An error occurred while subscribing to the feed'))
            }
        }
    }
}
