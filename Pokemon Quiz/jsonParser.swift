//
//  jsonParser.swift
//  Pokemon Quiz
//
//  Created by José Muñoz on 9/16/16.
//  Copyright © 2016 Superior Tech. All rights reserved.
//

import Foundation


class jsonParser {
    
    static func getJsonData(region:String) -> [NSDictionary]{
        
        var jsonData:[NSDictionary] = [NSDictionary()]
        
        guard let path = NSBundle.mainBundle().pathForResource(region, ofType: "json") else {
            return jsonData
        }
        
        let data: NSData = NSData(contentsOfURL: NSURL(fileURLWithPath: path))!
        
        do{
        
        jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! [NSDictionary]
        }catch{
            print(error)
        }
    
        return jsonData
    }
}