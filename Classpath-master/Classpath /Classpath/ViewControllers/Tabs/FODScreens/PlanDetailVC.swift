//
//  PlanDetailVC.swift
//  Classpath
//
//  Created by coldfin on 08/01/19.
//  Copyright © 2019 coldfin_lb. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import VerticalProgressView
import PDFKit

class PlanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblAttachments: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var btnDownload:UIButton!
    
}
class PlanDetailVC: UIViewController,UITableViewDataSource,UITableViewDelegate,touchDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constTableHeight: NSLayoutConstraint!
    @IBOutlet weak var playerSeekBar: UIProgressView!
    @IBOutlet weak var constThumbnailLead: NSLayoutConstraint!
    @IBOutlet weak var viewSeekBar: SeekBarView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var btnPlayCenter: UIButton!
    @IBOutlet weak var btnPlayBar: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var viewVideoUtilityBar: UIView!
    @IBOutlet weak var volumeSeekBar: SeekBarView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var downloading: UILabel!
    
    let volumeView = MPVolumeView()
    var thumbnail = UIView()
    var verticalProgressView = VerticalProgressView()
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isVideoPlaying = false
    
    var playSeekWidth:CGFloat = 0.0
    
    var time = Timer()
    var orientation = "portrait"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSeekWidth = viewSeekBar.frame.width
        tblView.rowHeight = 100
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        
        setUpPlayer()
        setDesign()
    }
    override func viewDidAppear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .all
    }
    override func viewDidDisappear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    func setUpPlayer() {
            
                  let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/fitsitters-9e3f8.appspot.com/o/Videos%2FZbhUAqB52saZglR55QC0D9mYE553%2F20180616164506.mp4?alt=media&token=db583e92-81ed-4b77-a920-acdffc21f61b")!
            
            // "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8"
            
            if player != nil {
                self.player = nil;
            }
            
            isVideoPlaying = false
            player = AVPlayer(url: url)
            player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            
            player.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            player.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            player.currentItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"),object: nil)
            
            addTimeObserver()
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            
            videoView.layer.addSublayer(playerLayer)
    
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            
            let duration = Float(currentItem.duration.seconds)
            let seconds:Float = Float(currentItem.currentTime().seconds)

            let progress = (seconds/duration)
            let leading = ((CGFloat(progress))*(self?.viewSeekBar.frame.width)!)
            
            if !(leading.isNaN) {
                self!.constThumbnailLead.constant = CGFloat(leading-10)
                self!.playerSeekBar.progress = progress
                self!.durationLabel.text = self?.getTimeString(from: currentItem.currentTime())
            }
        })
    }
    
    @IBAction func onClick_PlayPause(_ sender: UIButton) {
        
        if sender == btnPlayCenter && isVideoPlaying {
            viewVideoUtilityBar.isHidden = false
            time = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideUtilityBar), userInfo: nil, repeats: false)
            return
        }
        
        if isVideoPlaying {
            player.pause()
            time.invalidate()
            btnPlayCenter.setImage(UIImage(named: "play_button"), for: .normal)
            btnPlayBar.setImage(UIImage(named: "play"), for: .normal)
        }else {
            player.play()
            self.loader.startAnimating()
            self.player.volume = 1.0
            btnPlayCenter.setImage(UIImage(named: ""), for: .normal)
            btnPlayBar.setImage(UIImage(named: "pause"), for: .normal)
            time = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideUtilityBar), userInfo: nil, repeats: false)
        }
        isVideoPlaying = !isVideoPlaying
    }
    
    @IBAction func onClick_Volume(_ sender: Any) {
        volumeSeekBar.isHidden = !volumeSeekBar.isHidden
    }
    
    @IBAction func onClick_fullScreen(_ sender: Any) {
        if orientation == "portrait" {
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    @objc func hideUtilityBar() {
      //  viewVideoUtilityBar.isHidden = true
        UIView.animate(withDuration: 0.1, animations:{
         self.view.setNeedsLayout()
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            // self.durationLabel.text = getTimeString(from: player.currentItem!.duration)
        }else {
            if btnPlayCenter.image(for: .normal) != UIImage(named: "play_button") {
                switch keyPath {
                case "playbackBufferEmpty":
                    // Show loader
                    loader.startAnimating()
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    loader.stopAnimating()
                case "playbackBufferFull":
                    // Hide loader
                    loader.startAnimating()
                case .none:
                    print("")
                case .some(_):
                    print("")
                }
            }
        }
    }

    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    func setDesign() {
        viewSeekBar.delegate = self
        constThumbnailLead.constant = 0
        let percentage:Float = 0
        playerSeekBar.progress = percentage;
        playerSeekBar.trackTintColor = .clear
        playerSeekBar.backgroundColor = textThemeColor
        playerSeekBar.progressTintColor = themeColor
        playerSeekBar.progressViewStyle = .bar
        
        setUpVolumeSeekBar()
    }
    
    func setUpVolumeSeekBar() {
        NotificationCenter.default.addObserver(self, selector: #selector(systemVolumeDidChange), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),object: nil)

        volumeSeekBar.delegate = self
        
        verticalProgressView = VerticalProgressView(frame: CGRect(x: 5, y: 5, width: 10, height: 116))
        volumeSeekBar.addSubview(verticalProgressView)
        
        verticalProgressView.backgroundColor = textThemeColor
        verticalProgressView.progressTintColor = themeColor
        verticalProgressView.layer.cornerRadius = 5
        verticalProgressView.clipsToBounds = true
        volumeSeekBar.isHidden = true
        
        thumbnail = UIView(frame: CGRect(x: 0, y: 116, width: 20, height: 20))
        thumbnail.layer.cornerRadius = 10
        thumbnail.backgroundColor = .white
        volumeSeekBar.addSubview(thumbnail)
        
        let float:Float = AVAudioSession.sharedInstance().outputVolume
        let vol = float*120
        UIView.animate(withDuration: 0.0, animations: {
            self.thumbnail.frame = CGRect(x: 0, y: Int(115-vol), width: 20, height: 20)
        })
        let percentage:Float = (vol/Float(volumeSeekBar.frame.height))
        verticalProgressView.progress = percentage
        
        if verticalProgressView.progress == 0 {
            btnVolume.setImage(UIImage(named: "sound"), for: .normal)
        }else {
            btnVolume.setImage(UIImage(named: "sound_on"), for: .normal)
        }
    }
    
    @objc func systemVolumeDidChange(notification: NSNotification) {
        let float:Float = (notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float)!
        let vol = float*120
        print(vol)
        
        UIView.animate(withDuration: 0.0, animations: {
            self.thumbnail.frame = CGRect(x: 0, y: Int(115-vol), width: 20, height: 20)
        })
        let percentage:Float = (vol/Float(volumeSeekBar.frame.height))
        verticalProgressView.progress = percentage
        
        if vol <= 5 {
            btnVolume.setImage(UIImage(named: "sound"), for: .normal)
        }else {
            btnVolume.setImage(UIImage(named: "sound_on"), for: .normal)
        }
    }
    
    @objc func playerDidFinishPlaying(notification: NSNotification) {
        btnPlayCenter.setImage(UIImage(named: "play_button"), for: .normal)
        btnPlayBar.setImage(UIImage(named: "play"), for: .normal)
        setUpPlayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            self.navigationController?.navigationBar.isHidden = true
            orientation = "landscape"
        } else {
            self.navigationController?.navigationBar.isHidden = false
            orientation = "portrait"
        }
    }
    
    //MARK: TableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        constTableHeight.constant = CGFloat(3*100) //row count into height
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "planCell", for: indexPath) as! PlanTableViewCell
        return cell
    }
    
    //MARK: Seekbar touch delegate
    func touchSlider(_ point: CGPoint, view: UIView) {
        if view == viewSeekBar {
            let seconds = point.x
            if seconds > 0 && seconds <= view.frame.width{
                constThumbnailLead.constant = seconds-10
                let percentage:Float = Float(seconds/viewSeekBar.frame.width)
                
                guard let currentItem = self.player.currentItem else {return}
                let duration = Float(currentItem.duration.seconds)
                
                let sec = (percentage*duration)
                playerSeekBar.progress = percentage;
                player.seek(to: CMTimeMake(value: Int64(sec*1000), timescale: 1000))
                viewSeekBar.setNeedsDisplay()
            }
        }else if view == volumeSeekBar {
            let volume = point.y
            if volume > 0 && volume <= view.frame.height{
                UIView.animate(withDuration: 0.0, animations: {
                    self.thumbnail.frame = CGRect(x: 0, y: volume-10, width: 20, height: 20)
                })
                let percentage:Float = Float((120-volume)/volumeSeekBar.frame.height)
                verticalProgressView.progress = percentage
                
                if volume >= 114 {
                    btnVolume.setImage(UIImage(named: "sound"), for: .normal)
                }else {
                    btnVolume.setImage(UIImage(named: "sound_on"), for: .normal)
                }
                
                if let view = volumeView.subviews.first as? UISlider{
                    view.value = percentage //---0 t0 1.0---
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
