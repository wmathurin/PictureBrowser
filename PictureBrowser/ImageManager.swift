//
//  ImageManager
//  PictureBrowser
//
//  Created by Wolfgang Mathurin on 8/31/16.
//  Copyright © 2016 WM. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox

private let _instance = ImageManager()
class ImageManager {
    class var sharedInstance: ImageManager {
        get {
            return _instance
        }
    }
    
    private var _cache : [String:UIImage] = [:]
    
    private func cache(key:String, value:UIImage) {
        _cache[key] = value
    }
    
    func fetch(path:String, handler:(UIImage) -> ()) {
        if let image = _cache[path] {
            handler(image)
        }
        else {
            if let client = Dropbox.authorizedClient {
                let req = client.files.getThumbnail(path: path)
                req.response({ typeData, error in
                    if let (_,data) = typeData {
                        self._cache[path] = UIImage(data: data, scale: 1.0)
                        return self.fetch(path, handler:handler)
                    }
                })
            }
        }
    }
}