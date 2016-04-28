//
//  PhotoEffect.swift
//  ImageFilterTest
//
//  Created by vincentyen on 4/28/16.
//  Copyright © 2016 Fun Anima Co., Ltd. All rights reserved.
//

import UIKit

class PhotoEffect {
    
    class func oldPhoto(img:CIImage,withAmount intensity:Float) -> CIFilter {
        
        //1.
        let sepia = CIFilter(name: "CISepiaTone")
        sepia!.setValue(img, forKey: kCIInputImageKey)
        sepia!.setValue(intensity, forKey: kCIInputIntensityKey)
        
        //2.
        let random = CIFilter(name: "CIRandomGenerator")
        
        //3.
        let lighten = CIFilter(name: "CIColorControls")
        lighten!.setValue(random?.outputImage, forKey: kCIInputImageKey)
        lighten!.setValue(1 - intensity, forKey: kCIInputBrightnessKey)
        lighten!.setValue(0, forKey: kCIInputSaturationKey)
        
        //4.
        let croppedImage = lighten!.outputImage!.imageByCroppingToRect(img.extent)
        
        //5
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite!.setValue(sepia?.outputImage, forKey: kCIInputImageKey)
        composite!.setValue(croppedImage , forKey: kCIInputBackgroundImageKey)
        
        //6'
        let vignette = CIFilter(name: "CIVignette")
        vignette?.setValue(composite?.outputImage, forKey: kCIInputImageKey)
        vignette?.setValue(intensity * 2, forKey: kCIInputIntensityKey)
        vignette?.setValue(intensity * 30, forKey: kCIInputRadiusKey)
        
        
        //7
        return vignette!
    }
    
    class func oldFilmEffect(inputImage:CIImage) -> CIFilter {
        
        // 1.創建CISepiaTone濾鏡
        let sepiaToneFilter = CIFilter(name: "CISepiaTone")!
        sepiaToneFilter.setValue(inputImage, forKey: kCIInputImageKey)
        sepiaToneFilter.setValue(1, forKey: kCIInputIntensityKey)
        // 2.創建白色斑點濾鏡
        let whiteSpecksFilter = CIFilter(name: "CIColorMatrix")!
        whiteSpecksFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.imageByCroppingToRect(inputImage.extent), forKey: kCIInputImageKey)
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputRVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputBVector")
        whiteSpecksFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBiasVector")
        // 3.把CISepiaTone濾鏡和白班圖濾鏡以源覆蓋（來源以上）的方式先組合起來
        let sourceOverCompositingFilter = CIFilter(name: "CISourceOverCompositing")!
        sourceOverCompositingFilter.setValue(whiteSpecksFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        sourceOverCompositingFilter.setValue(sepiaToneFilter.outputImage, forKey: kCIInputImageKey)
        
        // 4.用CGAffineTransform濾鏡選對隨機噪點圖進行處理
        let affineTransformFilter = CIFilter(name: "CIAffineTransform")!
        affineTransformFilter.setValue(CIFilter(name: "CIRandomGenerator")!.outputImage!.imageByCroppingToRect(inputImage.extent), forKey: kCIInputImageKey)
        affineTransformFilter.setValue(NSValue(CGAffineTransform: CGAffineTransformMakeScale(1.5, 25)), forKey: kCIInputTransformKey)
        // 5.創建藍綠色磨砂圖濾鏡
        let darkScratchesFilter = CIFilter(name: "CIColorMatrix")!
        darkScratchesFilter.setValue(affineTransformFilter.outputImage, forKey: kCIInputImageKey)
        darkScratchesFilter.setValue(CIVector(x: 4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputAVector")
        darkScratchesFilter.setValue(CIVector(x: 0, y: 1, z: 1, w: 1), forKey: "inputBiasVector")
        // 6. 用CIMinimumComponent濾鏡把藍綠色磨砂圖濾鏡處理成黑色磨砂圖濾鏡
        
        let minimumComponentFilter = CIFilter(name: "CIMinimumComponent")!
        minimumComponentFilter.setValue(darkScratchesFilter.outputImage, forKey: kCIInputImageKey)
        // ---------完成
        // 7.合併
        let multiplyCompositingFilter = CIFilter(name: "CIMultiplyCompositing")!
        multiplyCompositingFilter.setValue(minimumComponentFilter.outputImage, forKey: kCIInputBackgroundImageKey)
        multiplyCompositingFilter.setValue(sourceOverCompositingFilter.outputImage, forKey: kCIInputImageKey)
        // 8.輸出
        return multiplyCompositingFilter
    }
}
