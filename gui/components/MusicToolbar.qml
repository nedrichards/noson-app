/*
 * Copyright (C) 2017
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id: toolBar
    property alias color: bg.color
    height: units.gu(7.25)
    objectName: "musicToolbarObject"

    Rectangle {
        id: bg
        anchors.fill: parent
        color: styleMusic.playerControls.backgroundColor
        opacity: 1.0
    }

    /* Toolbar controls */
    Item {
        id: toolbarControls
        anchors {
            fill: parent
        }
        state: player.currentMetaSource === "" ? "disabled" : "enabled"
        states: [
            State {
                name: "disabled"
                PropertyChanges {
                    target: disabledPlayerControlsGroup
                    visible: true
                }
                PropertyChanges {
                    target: enabledPlayerControlsGroup
                    visible: false
                }
            },
            State {
                name: "enabled"
                PropertyChanges {
                    target: disabledPlayerControlsGroup
                    visible: false
                }
                PropertyChanges {
                    target: enabledPlayerControlsGroup
                    visible: true
                }
            }
        ]

        /* Disabled (empty state) controls */
        Item {
            id: disabledPlayerControlsGroup
            anchors {
                bottom: playerControlsProgressBar.top
                left: parent.left
                right: parent.right
                top: parent.top
            }

            Label {
                id: noSongsInQueueLabel
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: disabledPlayerControlsPlayButton.left
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                color: styleMusic.playerControls.labelColor
                text: player.currentCount === 0 ? qsTr("No music in queue") : qsTr("Tap to play music")
                font.pointSize: units.fs("large")
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            /* Play/Pause button */
            Icon {
                id: disabledPlayerControlsPlayButton
                anchors {
                    right: parent.right
                    rightMargin: units.gu(3)
                    verticalCenter: parent.verticalCenter
                }
                visible: player.currentCount > 0
                color: styleMusic.playerControls.labelColor
                height: units.gu(4)
                source: player.isPlaying ? "qrc:/images/media-playback-pause.svg" : "qrc:/images/media-playback-start.svg"
                width: height
            }

            /* Select input */
            Icon {
                id: disabledPlayerControlsSelectButton
                anchors {
                    right: parent.right
                    rightMargin: units.gu(3)
                    verticalCenter: parent.verticalCenter
                }
                visible: player.currentCount === 0
                color: styleMusic.playerControls.labelColor
                height: units.gu(4)
                source: "qrc:/images/input.svg"
                width: height
            }

            /* Click action */
            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    if (player.currentCount > 0)
                        player.playQueue(true)
                    else
                        mainView.dialogSelectSource.open()
                }
            }
        }

        /* Enabled controls */
        Item {
            id: enabledPlayerControlsGroup
            anchors {
                bottom: playerControlsProgressBar.top
                left: parent.left
                right: parent.right
                top: parent.top
            }

            /* Album art in player controls */
            CoverGrid {
                 id:  playerControlsImage
                 anchors {
                     bottom: parent.bottom
                     left: parent.left
                     top: parent.top
                     margins: units.dp(2)
                 }
                 covers: [{art: makeCoverSource(player.currentMetaArt, player.currentMetaArtist, player.currentMetaAlbum)}]
                 size: parent.height
                 useFallbackArt: false
            }

            /* Column of meta labels */
            Column {
                id: playerControlsLabels
                anchors {
                    left: playerControlsImage.right
                    leftMargin: units.gu(1.5)
                    right: playerControlsPlayButton.left
                    rightMargin: units.gu(1)
                    verticalCenter: parent.verticalCenter
                }

                /* Title of track */
                Label {
                    id: playerControlsTitle
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    color: styleMusic.common.music
                    elide: Text.ElideRight
                    font.pointSize: units.fs("medium")
                    font.weight: Font.DemiBold
                    text: player.currentMetaTitle
                }

                /* Artist of track */
                Label {
                    id: playerControlsArtist
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    color: styleMusic.common.subtitle
                    elide: Text.ElideRight
                    font.pointSize: units.fs("small")
                    text: player.currentMetaArtist
                }
            }

            /* Play/Pause button */
            Icon {
                id: playerControlsPlayButton
                anchors {
                    right: parent.right
                    rightMargin: units.gu(3)
                    verticalCenter: parent.verticalCenter
                }
                color: styleMusic.playerControls.labelColor
                height: units.gu(4)
                source: player.playbackState === "PLAYING" ? "qrc:/images/media-playback-pause.svg" : "qrc:/images/media-playback-start.svg"
                objectName: "playShape"
                width: height
            }

            /* Mouse area to jump to now playing */
            MouseArea {
                anchors {
                    fill: parent
                }
                objectName: "jumpNowPlaying"
                enabled: true
                onClicked: {
                    if (mainView.nowPlayingPage !== null) {
                        while (stackView.depth > 1 && stackView.currentItem !== mainView.nowPlayingPage) {
                            stackView.pop();
                        }
                    } else {
                        tabs.pushNowPlaying();
                    }
                }
            }

            /* Mouse area for the play button (ontop of the jump to now playing) */
            MouseArea {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: playerControlsPlayButton.horizontalCenter
                    top: parent.top
                }
                onClicked: player.toggle()
                width: units.gu(8)

                Rectangle {
                    anchors {
                        fill: parent
                    }
                    color: styleMusic.playerControls.labelColor
                    opacity: parent.pressed ? 0.1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                        }
                    }
                }
            }
        }

        /* Object which provides the progress bar when toolbar is minimized */
        Rectangle {
            id: playerControlsProgressBar
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            color: styleMusic.playerControls.backgroundColor
            height: units.gu(0.25)

            Rectangle {
                id: playerControlsProgressBarHint
                anchors {
                    left: parent.left
                    top: parent.top
                }
                color: styleMusic.nowPlaying.progressForegroundColor
                height: parent.height
                width: player.duration > 0 ? (player.position / player.duration) * playerControlsProgressBar.width : 0

                Connections {
                    target: player
                    onPositionChanged: {
                        playerControlsProgressBarHint.width = (player.position / player.duration) * playerControlsProgressBar.width
                    }
                    onStopped: {
                        playerControlsProgressBarHint.width = 0;
                    }
                }
            }
        }
    }
}
