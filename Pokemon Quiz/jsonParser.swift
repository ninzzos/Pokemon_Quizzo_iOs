//
//  jsonParser.swift
//  Pokemon Quiz
//
//  Created by José Muñoz on 9/16/16.
//  Copyright © 2016 Superior Tech. All rights reserved.
//

import Foundation


class jsonParser {
    
    static func getJsonData(_ region:String) -> [NSDictionary]{
        
        var jsonData:[NSDictionary] = [NSDictionary()]
        
        guard let path = Bundle.main.path(forResource: region, ofType: "json") else {
            return jsonData
        }
        
        let data: Data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        do{
        
        jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [NSDictionary]
        }catch{
            print(error)
        }
    
        return jsonData
    }
}
