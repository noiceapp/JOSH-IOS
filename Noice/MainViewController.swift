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

class MainViewController: UIViewController, UIWebViewDelegate {
    var videoObject : PFObject!
    var videoObjects : [PFObject]!
    var currentVideoIndex : Int!
    var pageCount : Int!
    let pageSize : Int = 10
    var hasMoreVideo : Bool!
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
            self.getNumberOfVotesWithVideo(videoObject, completion: {(videos: [PFObject], numberOfNoice: Int, numberOfMeh: Int) -> Void in
                self.numberOfNoice.text = String("\(numberOfNoice+1) noice")
                if numberOfMeh > 0 {
                    self.numberOfMeh.text = String("\(numberOfMeh-1) meh")
                }
                self.incrementVote()
                self.removeDecrementVote()
            })
        }
    }
    @IBAction func mehButtonDidTouch(sender: UIButton!) {
        //sender.selected = !sender.selected
        if self.mehButton.selected == false {
            self.mehButton.selected = true
            self.hahaButton.selected = false
            self.blabButton.hidden = true
            self.numberOfBlab.hidden = true
            self.getNumberOfVotesWithVideo(videoObject, completion: {(videos: [PFObject], numberOfNoice: Int, numberOfMeh: Int) -> Void in
                self.numberOfMeh.text = String("\(numberOfMeh+1) meh")
                if numberOfNoice > 0 {
                    self.numberOfNoice.text = String("\(numberOfNoice-1) noice")
                }
                self.decrementVote()
                self.removeIncrementVote()
            })
        }
    }
    @IBAction func blabButtonDidTouch(sender: UIButton!) {
        sender.selected = true
    }
    
    func incrementVote()
    {
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
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    for parseObject in parseObjects {
                        parseObject.deleteInBackground()
                    }
                }
            }
        }
    }
    
    func decrementVote()
    {
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
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    for parseObject in parseObjects {
                        parseObject.deleteInBackground()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this line is here to stop a weird web view crash http://stackoverflow.com/questions/29458788/uiwebview-webthread-exc-bad-access
        UIView.setAnimationsEnabled(false)
        
        pageCount = 0
        currentVideoIndex = 0
        
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "nextVideo")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "prevVideo")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    func didRotate()
    {
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            videoPlayer.allowsInlineMediaPlayback = false
            videoPlayer.frame = view.bounds
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchVideo()
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
                    if self.currentVideoIndex < self.videoObjects.count {
                        var video = self.videoObjects[self.currentVideoIndex]
                        self.configureWithVideo(video)
                    }
                }
            }
        }
    }
    
    func nextVideo() {
        currentVideoIndex = currentVideoIndex + 1
        if currentVideoIndex > videoObjects.count - 1 && hasMoreVideo == true {
            pageCount = pageCount + 1
            fetchVideo()
        }
        else {
            if currentVideoIndex < videoObjects.count {
                var video = videoObjects[currentVideoIndex]
                configureWithVideo(video)
            }
        }
    }
    
    func prevVideo() {
        if currentVideoIndex > 0 {
            currentVideoIndex = currentVideoIndex - 1
            var video = videoObjects[currentVideoIndex]
            configureWithVideo(video)
        }
    }
}

