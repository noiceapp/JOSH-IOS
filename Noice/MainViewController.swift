//
//  ViewController.swift
//  Noice
//
//  Created by Joshua Lee on 7/14/15.
//  Copyright (c) 2015 Joshua Lee. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import Social

class MainViewController: UIViewController, UIWebViewDelegate {
    var videoObject : PFObject!
    var videoObjects : [PFObject]!
    var pageCount : Int!
    let pageSize : Int = 50
    var hasMoreVideo : Bool!
    var statusBarView : UIView!
    var currentVideoNoice : Int!
    var currentVideoMeh : Int!
    var currentVideoBlah : Int!
    @IBOutlet weak var videoPlayer: UIWebView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UITextView!
    @IBOutlet weak var hahaButton: UIButton!
    @IBOutlet weak var mehButton: UIButton!
    @IBOutlet weak var blabButton: UIButton!
    @IBOutlet weak var numberOfNoice: UILabel!
    @IBOutlet weak var numberOfMeh: UILabel!
    @IBOutlet weak var numberOfBlab: UILabel!
    
    @IBAction func hahaButtonDidTouch(sender: UIButton!) {
        //sender.selected = !sender.selected
        //self.blabButton.selected = true
        if self.hahaButton.selected == false {
            self.hahaButton.selected = true
            self.mehButton.selected = false
            self.blabButton.hidden = false
            self.numberOfBlab.hidden = false
            //self.incrementVote()
            //self.removeDecrementVote()
            self.incrementVoteWithUpdate()
            
            self.numberOfNoice.text = String("\(currentVideoNoice) noice")
            self.numberOfMeh.text = String("\(currentVideoMeh) meh")
        }
    }
    @IBAction func mehButtonDidTouch(sender: UIButton!) {
        if self.mehButton.selected == false {
            self.mehButton.selected = true
            self.hahaButton.selected = false
            self.blabButton.hidden = true
            self.numberOfBlab.hidden = true
            //self.decrementVote()
            //self.removeIncrementVote()
            self.decrementVoteWithUpdate()
            
            self.numberOfMeh.text = String("\(currentVideoMeh) meh")
            self.numberOfNoice.text = String("\(currentVideoNoice) noice")
        }
    }
    @IBAction func blabButtonDidTouch(sender: UIButton!) {
        blabButton.selected = true

        let optionMenu = UIAlertController(title: nil, message: "Make it viral", preferredStyle: .ActionSheet)
        let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler:{(alert: UIAlertAction!) -> Void in
            var content = FBSDKShareLinkContent()
            var videoURL = NSURL(string: self.videoObject["url"] as! String)
            content.contentURL = videoURL
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
            self.shareVideo()
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: {(alert: UIAlertAction!) -> Void in
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                var twitterSheet : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                var videoURL = NSURL(string: self.videoObject["url"] as! String)
                twitterSheet.addURL(videoURL)
                self.presentViewController(twitterSheet, animated: true, completion: nil)
                self.shareVideo()
            }
            else {
                var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(facebookAction)
        optionMenu.addAction(twitterAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func updateButtonLabelText()
    {
        self.numberOfNoice.text = String("\(currentVideoNoice) noice")
        self.numberOfMeh.text = String("\(currentVideoMeh) meh")
        self.numberOfBlab.text = String("\(currentVideoBlah) blah")
    }
    
    func shareVideo()
    {
        self.getNubmerOfShareWithVideo(videoObject, completion: {(numberOfBlab: Int) -> Void in
            self.numberOfBlab.text = String("\(numberOfBlab+1) blab")
            if self.videoObject != nil {
                var shareObject = PFObject(className: "Share")
                shareObject["user"] = PFInstallation.currentInstallation()
                shareObject["video"] = self.videoObject
                shareObject.saveInBackground()
            }
        })
    }
    
    func incrementVoteWithUpdate()
    {
        currentVideoNoice = currentVideoNoice + 1
        if currentVideoMeh > 0  {
            currentVideoMeh = currentVideoMeh - 1
        }
        var query = PFQuery(className: "Vote")
        query.whereKey("user", equalTo: PFInstallation.currentInstallation())
        query.whereKey("video", equalTo: self.videoObject)
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if parseObjects.count > 0 {
                        var parseObject : PFObject = parseObjects.first!
                        parseObject["value"] = (1)
                        parseObject.saveInBackground()
                    }
                    else {
                        var vote = PFObject(className: "Vote")
                        vote["user"] = PFInstallation.currentInstallation()
                        vote["value"] = (1)
                        vote["video"] = self.videoObject
                        vote.saveInBackground()
                    }
                }
            }
        }
    }
    
    func decrementVoteWithUpdate()
    {
        currentVideoMeh = currentVideoMeh + 1
        if currentVideoNoice > 0 {
            currentVideoNoice = currentVideoNoice - 1
        }
        var query = PFQuery(className: "Vote")
        query.whereKey("user", equalTo: PFInstallation.currentInstallation())
        query.whereKey("video", equalTo: self.videoObject)
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if parseObjects.count > 0 {
                        var parseObject : PFObject = parseObjects.first!
                        parseObject["value"] = (-1)
                        parseObject.saveInBackground()
                    }
                    else {
                        var vote = PFObject(className: "Vote")
                        vote["user"] = PFInstallation.currentInstallation()
                        vote["value"] = (-1)
                        vote["video"] = self.videoObject
                        vote.saveInBackground()
                    }
                }
            }
        }
    }
    
    /*func incrementVote()
    {
        currentVideoNoice = currentVideoNoice + 1
        var vote = PFObject(className: "Vote")
        vote["user"] = PFInstallation.currentInstallation()
        vote["value"] = (1)
        vote["video"] = self.videoObject
        vote.saveInBackground()
    }
    
    func removeIncrementVote()
    {
        var query = PFQuery(className: "Vote")
        query.whereKey("user", equalTo: PFInstallation.currentInstallation())
        query.whereKey("value", equalTo: (1))
        query.whereKey("video", equalTo: self.videoObject)
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if self.currentVideoNoice > 0 {
                        self.currentVideoNoice = self.currentVideoNoice - 1
                    }
                    self.updateButtonLabelText()
                    for parseObject in parseObjects {
                        parseObject.deleteInBackground()
                    }
                }
            }
        }
    }
    
    func decrementVote()
    {
        currentVideoMeh = currentVideoMeh + 1
        var vote = PFObject(className: "Vote")
        vote["user"] = PFInstallation.currentInstallation()
        vote["value"] = (-1)
        vote["video"] = self.videoObject
        vote.saveInBackground()
    }
    
    func removeDecrementVote()
    {
        var query = PFQuery(className: "Vote")
        query.whereKey("user", equalTo: PFInstallation.currentInstallation())
        query.whereKey("value", equalTo: (-1))
        query.whereKey("video", equalTo: self.videoObject)
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if self.currentVideoMeh > 0 {
                        self.currentVideoMeh = self.currentVideoMeh - 1
                    }
                    self.updateButtonLabelText()
                    for parseObject in parseObjects {
                        parseObject.deleteInBackground()
                    }
                }
            }
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this line is here to stop a weird web view crash http://stackoverflow.com/questions/29458788/uiwebview-webthread-exc-bad-access
        UIView.setAnimationsEnabled(false)
        
        pageCount = 0
        
        // Do any additional setup after loading the view, typically from a nib.
        videoTitle.text = ""
        videoDescription.text = ""
        numberOfNoice.text = ""
        numberOfMeh.text = ""
        numberOfBlab.text = ""
        videoObjects = []
        
        hahaButton.userInteractionEnabled = false
        mehButton.userInteractionEnabled = false
        
        //haha button image
        let hahaImage = UIImage(named: "haha")
        let tappedHahaImage = UIImage(named: "haha-tapped") as UIImage!
        
        hahaButton.setImage(hahaImage, forState: UIControlState.Normal)
        hahaButton.setImage(tappedHahaImage, forState: UIControlState.Selected)
        hahaButton.adjustsImageWhenHighlighted = false
        
        //meh button image
        let mehImage = UIImage(named: "meh")
        let tappedMehImage = UIImage(named: "meh-tapped")
        
        mehButton.setImage(mehImage, forState: UIControlState.Normal)
        mehButton.setImage(tappedMehImage, forState: UIControlState.Selected)
        mehButton.adjustsImageWhenHighlighted = false
        
        //blab button image
        let blabImage = UIImage(named: "blab")
        let tappedBlabImage = UIImage(named: "blab-tapped")
        
        blabButton.setImage(blabImage, forState: UIControlState.Normal)
        blabButton.setImage(tappedBlabImage, forState: UIControlState.Selected)
        blabButton.adjustsImageWhenHighlighted = false
        
        //video webview playback
        videoPlayer.allowsInlineMediaPlayback = true
        videoPlayer.mediaPlaybackRequiresUserAction = false
        videoPlayer.scrollView.scrollEnabled = false
        
        videoDescription.textColor = UIColor(red: 97.0/256.0, green: 97.0/256.0, blue: 97.0/256.0, alpha: 1.0)
        
        //status bar background
        statusBarView = UIView()
        statusBarView.frame = CGRectMake(0,0,view.bounds.size.width,20)
        statusBarView.backgroundColor = UIColor(red: 253.0/256.0, green: 210.0/256.0, blue: 119.0/256.0, alpha: 1.0)
        view.insertSubview(statusBarView, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "nextVideo")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeRight)
        
        fetchVideo()
    }
    
    func didRotate()
    {
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            videoPlayer.allowsInlineMediaPlayback = false
            videoPlayer.stringByEvaluatingJavaScriptFromString(("player.pauseVideo();"))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.videoPlayer.stringByEvaluatingJavaScriptFromString(("player.playVideo();"))
            })
        }
        else
        {
            videoPlayer.allowsInlineMediaPlayback = true
        }
    }
    
    func playYoutubeVideoWithId(videoId: String) {
        let youTubeVideoHTML = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@',playerVars: {controls:0, playsinline:1}, events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
        let htmlString = String(format: youTubeVideoHTML, arguments: [videoPlayer.bounds.width, videoPlayer.bounds.height, videoId])
        videoPlayer.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().resourceURL)
    }
    
    func getNumberOfVotesWithVideo(videoObject: PFObject, completion: (videos: [PFObject], numberOfNoice: Int, nubmerOfMeh: Int) ->())
    {
        //go fetch voting information
        var voteQuery = PFQuery(className: "Vote")
        voteQuery.whereKey("video", equalTo: videoObject)
        voteQuery.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseVoteObjects = results as? [PFObject] {
                    var numberOfNoice = 0
                    var numberOfMeh = 0
                    for parseVoteObject in parseVoteObjects {
                        
                        let voteValue : NSNumber = parseVoteObject["value"] as! NSNumber
                        if voteValue.integerValue == 1 {
                            numberOfNoice++
                        }
                        else if voteValue.integerValue == -1 {
                            numberOfMeh++
                        }
                    }
                    completion(videos: parseVoteObjects, numberOfNoice: numberOfNoice, nubmerOfMeh: numberOfMeh)
                }
            }
        }
    }
    
    func getNubmerOfShareWithVideo(videoObject: PFObject, completion: (numberOfBlab: Int) ->())
    {
        //go fetch sharing information
        var shareQuery = PFQuery(className: "Share")
        shareQuery.whereKey("video", equalTo: videoObject)
        shareQuery.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                //highlight blab button if current user has shared
                if let parseVoteObjects = results as? [PFObject] {
                    var hasFoundUser = false
                    for parseVoteobject in parseVoteObjects {
                        if (parseVoteobject["user"]?.objectId == PFInstallation.currentInstallation().objectId) {
                            hasFoundUser = true
                            self.blabButton.selected = true
                        }
                    }
                    if hasFoundUser == false {
                        self.blabButton.selected = false
                    }
                }
                if let numberOfBlab = results {
                    completion(numberOfBlab: numberOfBlab.count)
                }
            }
        }
    }
    
    func configureWithVideo(videoObject: PFObject)
    {
        self.videoObject = videoObject
        //get the url and start playing the video
        let videoUrl : String = videoObject["url"] as! String
        let urlComponents = NSURLComponents(URL: NSURL(string: videoUrl)!, resolvingAgainstBaseURL: false)
        let parameters = urlComponents?.queryItems
        if let queryParameters = parameters as? [NSURLQueryItem] {
            for parameter in queryParameters {
                if parameter.name == "v" {
                    let videoId : String! = parameter.value
                    self.playYoutubeVideoWithId(videoId)
                }
            }
        }
        //set the title and description
        self.videoTitle.text = videoObject["title"] as? String
        self.videoDescription.text = videoObject["description"] as! String
        
        self.getNumberOfVotesWithVideo(videoObject, completion: {(videos: [PFObject], numberOfNoice: Int, numberOfMeh: Int) -> Void in
            self.currentVideoNoice = numberOfNoice
            self.currentVideoMeh = numberOfMeh
            
            self.hahaButton.userInteractionEnabled = true
            self.mehButton.userInteractionEnabled = true
            
            self.numberOfNoice.text = String("\(numberOfNoice) noice")
            self.numberOfMeh.text = String("\(numberOfMeh) meh")
            
            var hasFoundUser = false
            for parseObject in videos {
                if (parseObject["user"]?.objectId == PFInstallation.currentInstallation().objectId) {
                    hasFoundUser = true
                    //if current user has voted the video then we want to show that
                    if (parseObject["value"]?.integerValue == 1) {
                        self.hahaButton.selected = true
                        self.mehButton.selected = false
                        self.blabButton.hidden = false
                        self.numberOfBlab.hidden = false
                    }
                    else {
                        self.hahaButton.selected = false
                        self.mehButton.selected = true
                        self.blabButton.hidden = true
                        self.numberOfBlab.hidden = true
                    }
                }
            }
            if (hasFoundUser == false) {
                self.hahaButton.selected = false
                self.mehButton.selected = false
                self.blabButton.hidden = true
                self.numberOfBlab.hidden = true
            }
        })
        
        self.getNubmerOfShareWithVideo(videoObject, completion: {(numberOfBlab: Int) -> Void in
            self.currentVideoBlah = numberOfBlab
            if numberOfBlab > 0 {
                self.numberOfBlab.text = String("\(numberOfBlab) blab")
            }
            else {
                self.numberOfBlab.text = "Be the first!"
            }
        })
    }
    
    func fetchVideo() {
        var query = PFQuery(className: "Video")
        query.limit = pageSize
        query.skip = pageSize * pageCount
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if parseObjects.count == self.pageSize {
                        self.hasMoreVideo = true
                    }
                    else {
                        self.hasMoreVideo = false
                    }
                    self.videoObjects.extend(parseObjects)
                    if self.videoObjects.count > 0 {
                        self.configureWithVideo(self.videoObjects.first!)
                        self.videoObjects.removeAtIndex(0)
                    }
                }
            }
        }
    }
    
    func nextVideo() {
        if (hasMoreVideo == false && videoObjects.count == 0) {
            let alert = UIAlertController(title: nil, message: "Come back later for more Noice!", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "Ok", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            alert.addAction(ok)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let lower : UInt32 = 0
        let upper : UInt32 = UInt32(videoObjects.count)
        let randomNumber : Int = Int(arc4random_uniform(upper - lower) + lower)
        
        if videoObjects.count == 0 && hasMoreVideo == true {
            pageCount = pageCount + 1
            fetchVideo()
        }
        else {
            if randomNumber < videoObjects.count {
                var video = videoObjects[randomNumber]
                configureWithVideo(video)
                videoObjects.removeAtIndex(randomNumber)
            }
        }
        
        
    }
}

