//
//  SentMemesTableViewController.swift
//  Meme Me 2.0
//
//  Created by Betz, Florian (059) on 18.03.21.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: Variables
    var sentMemes: [Meme]!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController!.tabBar.isHidden = false
        
        self.sentMemes = appDelegate.memes

        tableView!.reloadData()
    }
    
    // MARK: Datasource
    
    // define amount of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let memes = self.sentMemes {
            return memes.count
        } else {
            return 0
        }
    }
    
    // fill rows with content
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemeTableViewCell")! as UITableViewCell
        let meme = self.sentMemes[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = meme.topText! + " .. " + meme.bottomText!
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    // jump to details view with selected row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "detailViewController") as! MemeDetailViewController
        let memedImage = self.sentMemes[(indexPath as NSIndexPath).row].memedImage
        
        detailController.memedImage = memedImage
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}
