//
//  ViewController.swift
//  ForkmanForSwiftPodsWithIOS7
//
//  Created by Li Jiantang on 28/09/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        request(.GET, "https://github.com/tonyli508/ForkmanForSwiftPodsWithIOS7/blob/master/README.md").responseString(encoding: NSUTF8StringEncoding) { [unowned self] (request, response, result) -> Void in
            
            self.textView.text = result.value
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

