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

class MainViewController: UIViewController {
    var videoObject : PFObject!
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
            self.getNumberOfVotesWithVideo(videoObject, completion: {(numberOfNoice: Int, numberOfMeh: Int) -> Void in
                self.numberOfNoice.text = String("\(numberOfNoice+1) noice")
                var vote = PFObject(className: "Vote")
                vote["user"] = PFInstallation.currentInstallation()
                vote["value"] = (1)
                vote["video"] = self.videoObject
                vote.saveInBackground()
            })
        }
    }
    @IBAction func mehButtonDidTouch(sender: UIButton!) {
        //sender.selected = !sender.selected
        if self.mehButton.selected == false {
            self.mehButton.selected = true
            self.getNumberOfVotesWithVideo(videoObject, completion: {(numberOfNoice: Int, numberOfMeh: Int) -> Void in
                self.numberOfMeh.text = String("\(numberOfMeh+1) meh")
                var vote = PFObject(className: "Vote")
                vote["user"] = PFInstallation.currentInstallation()
                vote["value"] = (-1)
                vote["video"] = self.videoObject
                vote.saveInBackground()
            })
        }
    }
    @IBAction func blabButtonDidTouch(sender: UIButton!) {
        sender.selected = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this line is here to stop a weird web view crash http://stackoverflow.com/questions/29458788/uiwebview-webthread-exc-bad-access
        UIView.setAnimationsEnabled(false)
        
        // Do any additional setup after loading the view, typically from a nib.
        videoTitle.text = ""
        videoDescription.text = ""
        numberOfNoice.text = ""
        numberOfMeh.text = ""
        numberOfBlab.text = ""
        
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var query = PFQuery(className: "Video")
        query.limit = 10
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {(results: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if let parseObjects = results as? [PFObject] {
                    if let videoObject = parseObjects.first {
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
                        
                        self.getNumberOfVotesWithVideo(videoObject, completion: {(numberOfNoice: Int, numberOfMeh: Int) -> Void in
                            self.numberOfNoice.text = String("\(numberOfNoice) noice")
                            self.numberOfMeh.text = String("\(numberOfMeh) meh")
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
                }
            }
        }

    }
    
    func playYoutubeVideoWithId(videoId: String) {
        let youTubeVideoHTML = "<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@',playerVars: {playsinline:1}, events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
        let htmlString = String(format: youTubeVideoHTML, arguments: [videoPlayer.bounds.width, videoPlayer.bounds.height, videoId])
        videoPlayer.loadHTMLString(htmlString, baseURL: NSBundle.mainBundle().resourceURL)
    }
    
    func getNumberOfVotesWithVideo(videoObject: PFObject, completion: (numberOfNoice: Int, nubmerOfMeh: Int) ->())
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
                    completion(numberOfNoice: numberOfNoice, nubmerOfMeh: numberOfMeh)
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
                if let numberOfBlab = results {
                    completion(numberOfBlab: numberOfBlab.count)
                }
            }
        }
    }
}

