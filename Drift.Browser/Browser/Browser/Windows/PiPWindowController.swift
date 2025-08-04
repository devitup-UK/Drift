//
//  PiPWindowController.swift
//  Drift
//
//  Created by Tom Alderson on 27/06/2025.
//

import AppKit
import AVKit


final class PiPWindowController: NSWindowController {

    private let player = AVPlayer()
    private let playerView = AVPlayerView()

    init(url: URL, startTime: Double, paused: Bool) {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 204),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)

        panel.level          = .floating
        panel.isOpaque       = false
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        panel.titleVisibility = .hidden
        panel.hasShadow       = true
        panel.isMovableByWindowBackground = true

        super.init(window: panel)

        playerView.player = player
        playerView.controlsStyle = .inline
        playerView.videoGravity  = .resizeAspect
        panel.contentView = playerView

        // Load media
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.seek(to: CMTime(seconds: startTime, preferredTimescale: 600))

        if !paused { player.play() }
    }

    required init?(coder: NSCoder) { fatalError() }

    func closePiP() {
        player.pause()
        close()
    }
}
