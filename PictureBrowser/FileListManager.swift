//
//  FileListManager
//  PictureBrowser
//
//  Created by Wolfgang Mathurin on 8/31/16.
//  Copyright © 2016 WM. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox

private let _instance = FileListManager()
class FileListManager {
    class var sharedInstance: FileListManager {
        get {
            return _instance
        }
    }
    
    private var _cache : [String:[Files.Metadata]] = [:]
    
    func fetch(path:String, handler:([Files.Metadata]) -> ()) {
        if let files = _cache[path] {
            handler(files)
        }
        else {
            if let client = Dropbox.authorizedClient {
                let req = client.files.listFolder(path: path, recursive: false, includeMediaInfo: true, includeDeleted: false, includeHasExplicitSharedMembers: false)
                req.response { response, error in
                    if let result = response {
                        self._cache[path] = result.entries
                        self.fetch(path, handler: handler)
                    }
                }
            }
        }
    }
}