//
//  FileListContoller.swift
//  PictureBrowser
//
//  Created by Wolfgang Mathurin on 8/30/16.
//  Copyright © 2016 WM. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentPath = ""
    
    private var _files : [Files.Metadata] = []
    var files : [Files.Metadata] {
        set {
            self._files = newValue;
            self.refreshTable()
        }
        get {
            return _files
        }
    }

    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let client = Dropbox.authorizedClient {
            let req = client.files.listFolder(path: self.currentPath, recursive: false, includeMediaInfo: true, includeDeleted: false, includeHasExplicitSharedMembers: false)
            req.response { response, error in
                if let result = response {
                    self.files = result.entries
                } else {
                    print(error!)
                }
            }
        }
        else {
            Dropbox.authorizeFromController(self)
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Back button handler
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Segue for cell click
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "drill"
        {
            if let destinationVC = segue.destinationViewController as? FileListController, cell = sender as? FileCell {
                destinationVC.currentPath = cell.path!
            }
        }
    }
    
    // 
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "drill"
        {
            if let cell = sender as? FileCell  {
                return !cell.isFile
            }
        }
        return false
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as! FileCell
        cell.file = self.files[indexPath.row]
        return cell
    }
}

