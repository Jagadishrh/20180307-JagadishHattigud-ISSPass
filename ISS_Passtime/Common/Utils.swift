//
//  Utils.swift
//  ISS_Passtime
//
//  Created by Jagadish R Hattigud on 07/03/18.
//  Copyright © 2018 Jagadish R Hattigud. All rights reserved.
//

import UIKit

class Utils :UIView {
    
    func getTimestamp (row : Int) -> String {
        let ISS = ISSPasstimeViewController()
        let temp = ISS.retfromMap[row].value(forKey:"risetime") as! Double
        let date = NSDate(timeIntervalSince1970:temp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        print("formatted date is \(formatter.string(from: date as Date))")
        return formatter.string(from: date as Date)
    }
}
