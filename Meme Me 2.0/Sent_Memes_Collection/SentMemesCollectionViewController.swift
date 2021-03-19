//
//  SentMemesCollectionViewController.swift
//  Meme Me 2.0
//
//  Created by Betz, Florian (059) on 18.03.21.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    // MARK: Variables
    var sentMemes: [Meme]!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: Outlets
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController!.tabBar.isHidden = false
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (1 * space)) / 2.0
        let landscapeDimension = (view.frame.size.width - (3 * space)) / 4.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        if UIDevice.current.orientation.isLandscape {
            flowLayout.itemSize = CGSize(width: landscapeDimension, height: landscapeDimension)
        } else {
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
        
        sentMemes = appDelegate.memes
        collectionView!.reloadData()
    }
    
    // MARK: Datasource
    
    // define amount of items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let memes = sentMemes {
            return memes.count
        } else {
            return 0
        }
    }
    
    // fill each collection item with data
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath) as! MemeCollectionViewCell
        let memedImage = self.sentMemes[(indexPath as NSIndexPath).row].memedImage
    
        cell.collectionViewCellMemedImage?.image = memedImage
        return cell
    }
    
    // jump to details view and fill the details view with data from the selected collection item
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "detailViewController") as! MemeDetailViewController
        let memedImage = self.sentMemes[(indexPath as NSIndexPath).row].memedImage
        
        detailController.memedImage = memedImage
        self.navigationController?.pushViewController(detailController, animated: true)
    }

}
