//
//  quizzoController.swift
//  Pokemon Quiz
//
//  Created by José Muñoz on 9/16/16.
//  Copyright © 2016 Superior Tech. All rights reserved.
//

import UIKit

class quizzoController : ViewController {
    
    @IBOutlet weak var txtEntry: UITextField!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.txtEntry.resignFirstResponder()
    }
    
    
    
    @IBAction func btnAdd(sender: AnyObject) {
    }
    
    
}