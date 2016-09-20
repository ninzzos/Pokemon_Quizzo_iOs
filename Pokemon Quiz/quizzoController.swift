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
    @IBOutlet weak var btnAdd: UIButton!
    let size = (UIScreen.main.bounds.width)
    var offset:CGFloat = -1.0
    var pokedexSize:Int = 0
    var data:[NSDictionary] = [[:]]
    var currentData:[NSDictionary] = [[:]]
    var typeColors:NSDictionary = ["fire":0xff1744,
                                   "water":0x2196f3,
                                   "grass":0x4caf50,
                                   "poison":0xba68c8,
                                   "normal":0xf9a825,
                                   "electric":0xffd740,
                                   "fighting":0xe57373,
                                   "ground":0xa1887f,
                                   "bug":0x9ccc65,
                                   "psychic":0x9575cd,
                                   "rock":0x757575,
                                   "steel":0xd7ccc8,
                                   "flying":0x80deea,
                                   "fairy":0xea80fc,
                                   "ice":0x18ffff,
                                   "ghost":0x9c27b0,
                                   "dragon":0xff8a80]
    
    //timer Stuff
    var secondsRemaining:Int = 0
    var timer:Timer = Timer()
    
    override func viewDidLoad() {
        self.navigationItem.hidesBackButton = true
        
        self.timerManager()
        self.getPokedex("kanto")
        
        NotificationCenter.default.addObserver(self, selector: #selector(quizzoController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(quizzoController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        self.txtEntry.placeholder = "0/\(self.pokedexSize)"
        self.gridPokemon.dataSource = self
        self.gridPokemon.delegate = self
        self.txtEntry.delegate = self
        
    }
    
    @IBAction func btnAddClick(_ sender:AnyObject){
        
        self.pokemonExists()
    }
    
    @IBAction func btnQuitAction(_ sender: AnyObject) {
        
        self.stopTimer()
    }
    
    //UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCellTemplate", for: indexPath) as! pokeCell
        let currentItem:NSDictionary = self.data[(indexPath as NSIndexPath).item]
        var imgPath = (currentItem["image"] as! String)
        
        imgPath.removeSubrange(imgPath.startIndex..<imgPath.characters.index(imgPath.startIndex, offsetBy: 10))
        
        cell.lblName.text = (currentItem["name"] as! String)
        cell.imgDisplay.image = UIImage(contentsOfFile: self.fetchImagePath(imgPath))
        
        let type:String! = (currentItem["types"] as! NSArray?)?.object(at: 0) as! String
        
        cell.backgroundColor = self.UIColorFromRGB(self.typeColors[type] as! UInt)
        
        return cell
    }
    
    func scrollGridToBottom(){
        DispatchQueue.main.async(execute: {
            let section:Int = (self.gridPokemon.numberOfSections-1)
            let itemNumber:Int = self.collectionView(self.gridPokemon, numberOfItemsInSection: section)-1
            if(itemNumber >= 0){
                let lastIndex:IndexPath = IndexPath(item: itemNumber, section: section)
                self.gridPokemon.scrollToItem(at: lastIndex, at: UICollectionViewScrollPosition.bottom, animated: true)
            }
        })
        
    }
    
    // TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.pokemonExists()
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor.black
    }
    
    //helper functions
    func pokemonExists(){
        if(!self.txtEntry.text!.isEmpty){
            if(self.currentData.count > 0){
                let entry:String = self.txtEntry.text!;
                var cont:Int! = 0
                for tmp in self.currentData {
                    if(entry.compare((tmp["name"] as! String), options: String.CompareOptions.caseInsensitive, range: entry.startIndex..<entry.endIndex, locale: nil) == ComparisonResult.orderedSame || entry.compare((tmp["alternative"] as! String), options: String.CompareOptions.caseInsensitive, range: entry.startIndex..<entry.endIndex, locale: nil) == ComparisonResult.orderedSame){
                    
                        self.txtEntry.text = ""
                        self.txtEntry.textColor = UIColor.black
                        self.data.append(tmp)
                        self.currentData.remove(at: cont)
                        self.gridPokemon.reloadData()
                        cont = 0
                        
                        //now scroll shit there
                        self.scrollGridToBottom()
                        
                        //update the hint
                        self.txtEntry.placeholder = "\(self.data.count)/\(self.pokedexSize)"
                        
                        break;
                    }
                    cont = cont+1
                }
                if(cont == self.currentData.count){
                    self.txtEntry.textColor = UIColor.red
                }
            }
            else{
                self.stopTimer()
            }
        }
    }
    
    //hacer que el gridview baje
    func keyboardWillShow(_ sender: Notification) {
        if(self.offset == -1.0){
            self.offset = ((sender as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
        }
        self.view.frame.origin.y = self.view.frame.origin.y - offset
        self.gridPokemon.contentInset = UIEdgeInsets(top: self.offset, left: 0, bottom: 0, right: 0)
        self.gridPokemon.scrollIndicatorInsets = UIEdgeInsets(top: self.offset, left: 0, bottom: 0, right: 0)
        //self.gridPokemon.contentSize = CGSize(width: self.gridPokemon.contentSize.width, height: self.gridPokemon.contentSize.height+offset)
        
    }
    
    func keyboardWillHide(_ sender: Notification) {
        
        self.view.frame.origin.y = 0
        self.gridPokemon.contentInset = UIEdgeInsets.zero
        self.gridPokemon.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func fetchImagePath(_ name:String)->String!{
        var tmp = name
        tmp.removeSubrange(name.characters.index(name.endIndex, offsetBy: -4)..<name.endIndex)
        
        let finalPath = Bundle.main.path(forResource: tmp, ofType: "png")
        
        return finalPath
    }
    
    func getPokedex(_ region:String){
        self.currentData = jsonParser.getJsonData(region)
        self.pokedexSize = self.currentData.count
        self.data.removeAll()
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func presentBanner(_ title:String, message:String){
        
        let alert: UIAlertController = UIAlertController(title: title, message: message,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: {
                                                                                    (action:UIAlertAction) in
                                                                                        alert.dismiss(animated: true, completion: nil);
                                                                                        self.navigationController!.popViewController(animated: true)
                                                                                }))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {
                                                                                (action:UIAlertAction) in
                                                                                    self.navigationItem.hidesBackButton = false;
                                                                                    self.navigationItem.rightBarButtonItem?.isEnabled = false;
                                                                            }))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    // despues de un monton de stackoverflow, ya corre en el background thread
    func timerManager(){
        
        self.secondsRemaining = 12*60
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(quizzoController.timerTick), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer, forMode: RunLoopMode.UITrackingRunLoopMode)
        
    }
    
    func timerTick(){
        if(self.secondsRemaining > 0){
            self.secondsRemaining = self.secondsRemaining-1
            let minutes = secondsRemaining/60
            let seconds = secondsRemaining-(minutes*60)
            let timeString:String = "Time Remaining: "+(minutes<10 ? "0" : "")+"\(minutes):"+(seconds<10 ? "0" : "")+"\(seconds)"
            
            navigationItem.title = timeString
        }
        else{
            self.stopTimer()
        }
    }
    
    func stopTimer(){
        self.txtEntry.isEnabled = false
        self.btnAdd.isEnabled = false
        self.timer.invalidate()
        self.presentBanner("Time is up!", message: "you completed \(self.data.count) out of \(self.pokedexSize)")
    }
}
