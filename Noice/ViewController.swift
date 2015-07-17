//
//  ViewController.swift
//  Noice
//
//  Created by Joshua Lee on 7/14/15.
//  Copyright (c) 2015 Joshua Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoPlayer: UIWebView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UITextView!
    @IBOutlet weak var hahaButton: UIButton!
    @IBOutlet weak var mehButton: UIButton!
    @IBOutlet weak var blabButton: UIButton!
    

    @IBAction func hahaButtonDidTouch(sender: UIButton!) {
        let image = UIImage(named: "haha-tapped") as UIImage!
        hahaButton.setImage(image, forState: UIControlState.Normal)
    }
    @IBAction func mehButtonDidTouch(sender: UIButton!) {
        let image = UIImage(named: "meh-tapped") as UIImage!
        mehButton.setImage(image, forState: UIControlState.Normal)
    }
    @IBAction func blabButtonDidTouch(sender: UIButton!) {
        let image = UIImage(named: "blab-tapped") as UIImage!
        blabButton.setImage(image, forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

