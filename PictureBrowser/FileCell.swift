//
//  FileCell.swift
//  PictureBrowser
//
//  Created by Wolfgang Mathurin on 8/30/16.
//  Copyright © 2016 WM. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    private var _file : Files.Metadata?
    var file : Files.Metadata? {
        set {
            self._file = newValue
            self.title.text = newValue?.name
            self.thumbnail.image = nil
            
            if self.isFile {
                let pathFetched = self.path!
                ImageManager.sharedInstance.fetch(pathFetched, handler:{ image in
                    if self.path == pathFetched {
                        self.thumbnail.image = image
                    }
                })
            }
        }
        get {
            return self._file
        }
    }
    
    var path : String? {
        get {
            return file?.pathLower
        }
    }
    
    
    var isFile : Bool {
        get {
            return file is Files.FileMetadata?
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
