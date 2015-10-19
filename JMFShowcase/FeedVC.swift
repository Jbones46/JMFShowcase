//
//  FeedVC.swift
//  JMFShowcase
//
//  Created by Justin Ferre on 10/17/15.
//  Copyright © 2015 Justin Ferre. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imgSelectorImg: UIImageView!
   
    
    static var imageCache = NSCache()
    
    var imageSelected = false
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot  in
        self.tableView.estimatedRowHeight = 358
//            print(snapshot.value)
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                  //  print("snap: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                        
                        
                        
                    }
                }
               
            }
            
            self.tableView.reloadData()
//             NSUserDefaults.standardUserDefaults().synchronize()
        
        })
        
    }
    override func viewDidAppear(animated: Bool) {
         tableView.reloadData()
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            var img: UIImage?
            
            if let url = post.imageUrl {
                print(url)
            
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            
            cell.configureCell(post, img: img)
            
            return cell
            
            
        }else {
            return PostCell()
            
        }
       
       
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        }else{
            return tableView.estimatedRowHeight
            
        }
    
    }
   
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imgSelectorImg.image = image
        imageSelected = true
        
        
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(sender: MaterialButton) {
        
        if let txt = postField.text where txt != "" {
            if let img = imgSelectorImg.image where imageSelected == true {
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imgData = UIImageJPEGRepresentation(img, 0.3)!
                let keyData = "025EGLPQef5b701533f08f33f43dee50fdbb343f".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    
                    }) { encodingResult in
                
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.responseJSON(completionHandler: { response in response.result
                                
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        
                                        if let imageLink = links["image_link"] as? String {
                                            
//                                            print("LINK: \(imageLink)")
                                            self.postToFirebase(imageLink)
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                            })
                                
                            
                        case .Failure(let error):
                            print(error)
                        }
                }
                
            }else {
                self.postToFirebase(nil)
                
            }

            
            
        }
        
    }
    
    
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = [
        "description": postField.text!,
        "likes": 0
        
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        self.imgSelectorImg.image = UIImage(named: "camera")
        self.postField.text = ""
        imageSelected = false
        self.tableView.reloadData()
    }
    

}
