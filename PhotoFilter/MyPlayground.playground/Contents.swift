//: Playground - noun: a place where people can play

import UIKit
import CoreImage
var str = "Hello, playground"


let filterNames = CIFilter.filterNamesInCategories([kCICategoryBuiltIn]) //kCICategoryBuiltIn,kCICategoryColorEffect

var filterNameAry = [String]()
var filterKeyNameAry = [String]()
for name in filterNames {
    let filter = CIFilter(name: name)//CIAttributeFilterName
    let disName = filter!.attributes[kCIAttributeFilterDisplayName] as! String
    let filterName = filter!.attributes[kCIAttributeFilterName] as! String
    //print("\(disName):\(filterName)")
    
    if let inputImg = filter!.attributes[kCIInputImageKey]{//,let _ = filter!.attributes["inputIntensity"] {
    //if filterName.hasPrefix("CIPhoto") || filterName == "CILinearToSRGBToneCurve" || filterName == "CISRGBToneCurveToLinear" {// || filterName == "CIVignetteEffect"  {
        print("\(filterName):\(disName)：\(filter!.attributes)")
        filterKeyNameAry.append(filterName)
    
        filterNameAry.append(disName)
    }
    print("--------------------------------------------------------[\(filterName)]")
}

//print(filterKeyNameAry)
//print(filterNameAry)
