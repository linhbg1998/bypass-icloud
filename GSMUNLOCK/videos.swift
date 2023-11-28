//
//  videos.swift
//  AU-RAM
//
//  Created by linh on 22/09/2023.
//

import Cocoa
import AVKit

class videos: NSViewController {
    var player: AVPlayer?
    
    
    @IBOutlet weak var pass: NSButton!
    
    @IBOutlet weak var playerView: AVPlayerView!
    
    @IBOutlet weak var hello: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func pass(_ sender: Any) {
        guard let videoURL = URL(string: "https://gsmunlockinfo.com/video/bypasspascode.mp4") else {
            return
        }

        // Tạo AVPlayer
        player = AVPlayer(url: videoURL)

        // Thiết lập AVPlayer cho AVPlayerView
        playerView.player = player
        
        
    }
    
    
    @IBAction func hello(_ sender: Any) {
        // URL của video trực tuyến (điều chỉnh URL tùy theo video của bạn)
                guard let videoURL = URL(string: "https://gsmunlockinfo.com/video/bypasshello.mp4") else {
                    return
                }

                // Tạo AVPlayer
                player = AVPlayer(url: videoURL)

                // Thiết lập AVPlayer cho AVPlayerView
                playerView.player = player
        
        
        
    }
    
    override func viewDidAppear() {
            super.viewDidAppear()
            player?.play()
        }
    
    
    
    
}

