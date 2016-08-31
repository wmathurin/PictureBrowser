//
//  ViewController.swift
//  PictureBrowser
//
//  Created by Wolfgang Mathurin on 8/30/16.
//  Copyright © 2016 WM. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var history : [String] = []
    var pathToFiles : [String: [Files.Metadata]] = [:];

    var currentPath:String{
        set {
            if history.last == nil || history.last! != newValue {
                history.append(newValue)
            }
        }
        get {
            return history.last != nil ? history.last! : ""
        }
    }
    
    var files:[Files.Metadata] {
        get {
            if let files = self.pathToFiles[self.currentPath] {
                return files
            }
            else {
                return [];
            }
        }
    }
    
    func gotoPath(path:String) {
        if self.pathToFiles[path] != nil {
            self.currentPath = path;
            self.refreshTable();
        }
        else {
            self.fetchFiles(path, onComplete:{ () -> Void in
                self.gotoPath(path)
            })
        }
    }

    // Data fetching
    func fetchFiles(path:String, onComplete:()->Void) {
        if let client = Dropbox.authorizedClient {
            let req = client.files.listFolder(path: path, recursive: false, includeMediaInfo: true, includeDeleted: false, includeHasExplicitSharedMembers: false)
            req.response { response, error in
                if let result = response {
                    self.pathToFiles[path] = result.entries;
                    onComplete()
                } else {
                    print(error!)
                }
            }
        }
    }
    
    // Table refresh
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gotoPath("");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Link button handler
    @IBAction func linkButtonClicked(sender: AnyObject) {
        if (Dropbox.authorizedClient == nil) {
            Dropbox.authorizeFromController(self)
        } else {
            print("User is already authorized!")
        }
    }
    
    // Back button handler
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.history.removeLast()
        self.refreshTable()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as! CustomCell
        cell.title.text = self.files[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let file = self.files[indexPath.row]
        if file is Files.FolderMetadata {
            self.gotoPath(file.pathLower!)
        }
    }
}

