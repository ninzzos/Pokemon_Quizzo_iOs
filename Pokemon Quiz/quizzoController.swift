//
//  quizzoController.swift
//  Pokemon Quiz
//
//  Created by José Muñoz on 9/16/16.
//  Copyright © 2016 Superior Tech. All rights reserved.
//

import UIKit

class quizzoController : ViewController, UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var gridPokemon: UICollectionView!
    @IBOutlet weak var txtEntry: UITextField!
    var data:[NSDictionary] = [[:]]
    var currentData:[NSDictionary] = [[:]]
    
    override func viewDidLoad() {
        
        self.currentData = jsonParser.getJsonData()
        self.data.removeAll()
        self.gridPokemon.dataSource = self
        self.gridPokemon.delegate = self
        
        self.txtEntry.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(quizzoController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(quizzoController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.txtEntry.resignFirstResponder()
    }
    
    //UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("gridCellTemplate", forIndexPath: indexPath) as! pokeCell
        var imgPath = (self.data[indexPath.item]["image"] as! String)
        
        imgPath.removeRange(Range<String.Index>(start: imgPath.startIndex, end: imgPath.startIndex.advancedBy(10)))
        
        cell.lblName.text = (self.data[indexPath.item]["name"] as! String)
        cell.imgDisplay.image = UIImage(contentsOfFile: self.fetchImagePath(imgPath))
        //cell.backgroundColor = UIColor.blueColor()
        
        return cell
    }
    
    // TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.pokemonExists()
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.textColor = UIColor.blackColor()
    }
    
    //actions
    
    @IBAction func btnAdd(sender: AnyObject) {
        self.pokemonExists()
    }
    
    //helper functions
    
    func pokemonExists(){
        let entry:String = self.txtEntry.text!;
        var cont:Int! = 0
        for tmp in self.currentData {
            if(entry == tmp["name"] as! String || entry == tmp["alternative"] as! String){
                self.txtEntry.text = ""
                self.txtEntry.textColor = UIColor.blackColor()
                self.data.append(tmp)
                self.currentData.removeAtIndex(cont)
                self.gridPokemon.reloadData()
                
                cont = 0
                break;
            }
            cont = cont+1
        }
        if(cont == self.currentData.count){
            self.txtEntry.textColor = UIColor.redColor()
        }

    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        self.view.frame.origin.y = self.view.frame.origin.y - (sender.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().height
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        self.view.frame.origin.y = 0
    }
    
    func fetchImagePath(name:String)->String!{
        var tmp = name
        if(name.containsString(".png")){
            tmp.removeRange(Range<String.Index>(start: name.endIndex.advancedBy(-4), end: name.endIndex))
        }
        
       let finalPath = NSBundle.mainBundle().pathForResource(tmp, ofType: "png")
        
        return finalPath
    }
    
}