
import Foundation
import SKPhotoBrowser
import AVKit

class MediaBrowser: SKPhotoBrowserDelegate{

    let browser: SKPhotoBrowser
    var photos = [SKPhotoProtocol]()
    var restoreMediaBrowser = false
    let selectionIndex: Int

    init(media: NSArray, index selectedIndex: Int) {
        var index = 0
        var count = 0
        for (idx, md) in media.enumerated() {
            if idx == selectedIndex {
                index = count
            }
            let photo = SKPhoto.photoWithImageURL(md as! String)
            photos.append(photo)
            count += 1
        }
        selectionIndex = index
        browser = SKPhotoBrowser(photos: photos)
        browser.initializePageIndex(index)
        browser.delegate = self
    }

    init(mediaImages: NSArray, index selectedIndex: Int) {
        var index = 0
        var count = 0
        for (idx, md) in mediaImages.enumerated() {
            if idx == selectedIndex {
                index = count
            }
            let photo = SKPhoto.photoWithImage(md as! UIImage)
            photos.append(photo)
            count += 1
        }
        selectionIndex = index
        browser = SKPhotoBrowser(photos: photos)
        browser.initializePageIndex(index)
        browser.delegate = self
    }
}
