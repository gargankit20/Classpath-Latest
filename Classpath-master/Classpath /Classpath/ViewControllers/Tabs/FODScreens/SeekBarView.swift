//
//  SeekBarView.swift
//  Classpath
//
//  Created by coldfin on 08/01/19.
//  Copyright © 2019 coldfin_lb. All rights reserved.
//

import UIKit
@objc protocol touchDelegate{
    func touchSlider(_ point:CGPoint, view:UIView)
}

class SeekBarView: UIView {
    var delegate: touchDelegate!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //MARK: Seek bar thumbnail touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updatePlayerSeekBar(touch!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updatePlayerSeekBar(touch!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch =  touches.first
        updatePlayerSeekBar(touch!)
    }
    
    func updatePlayerSeekBar(_ touch: UITouch){
        let point = CGPoint(x: (touch.location(in: self).x), y: (touch.location(in: self).y))
        // let (_,index) = path.findClosestPointOnPath(fromPoint: point)
        // point = path.lookupTable[index]
        self.delegate.touchSlider(point, view: self)
    //    constThumbnailLead.constant = point.x
        //   currentSelectionX = point.x
        //  currentSelectionY = point.y
        //    self.delegate.touchSlider(index/2)
   //     viewSeekBar.setNeedsDisplay()
    }
}
