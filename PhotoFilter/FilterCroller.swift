//
//  FilterCroller.swift
//  ImageFilterTest
//
//  Created by vincentyen on 4/25/16.
//  Copyright © 2016 Fun Anima Co., Ltd. All rights reserved.
//

import UIKit
import CoreImage

class FilterCroller: NSObject {

    static var filterNames = [String]()
    
    static var filterKeys = [String]()
    /*
     kCICategoryDistortionEffect 扭曲效果，比如磕碰，旋轉，孔
     kCICategoryGeometryAdjustment 幾何開著​​調整，比如仿射變換，平切，透視轉換
     kCICategoryCompositeOperation 合併，比如源覆蓋（來源以上），最小化，源在頂（來源之上），色彩混合模式
     kCICategoryHalftoneEffect 半色調效果，比如screen、line screen、hatched
     kCICategoryColorAdjustment 色彩調整，比如伽馬調整，白點調整，曝光
     kCICategoryColorEffect 色彩效果，比如色調調整、posterize
     kCICategoryTransition 圖像間轉換，比如dissolve、disintegrate with mask、swipe
     kCICategoryTileEffect 瓦片效果，比如parallelogram、triangle
     kCICategoryGenerator 圖像生成器，比如stripes、constant color、checkerboard
     kCICategoryGradient 漸變，比如軸向漸變，仿射漸變，高斯漸變
     kCICategoryStylize 風格化，比如像素化，水晶化
     kCICategorySharpen 銳化，發光
     kCICategoryBlur 模糊，比如高斯模糊，焦點模糊，運動模糊
     (2)按使用场景分类：
     kCICategoryStillImage 用於靜態圖像
     kCICategoryVideo 用於影片
     kCICategoryInterlaced 用於交錯圖像
     kCICategoryNonSquarePixels 用於非矩形像素
     kCICategoryHighDynamicRange 用於HDR
     kCICategoryBuiltIn
     */
    class func searchFilterName() {
        let filterNamesCollect = CIFilter.filterNamesInCategories([kCICategoryColorEffect])
        
        
        for name in filterNamesCollect {
            let filter = CIFilter(name: name)//CIAttributeFilterName
            let disName = filter!.attributes[kCIAttributeFilterDisplayName] as! String
            let filterName = filter!.attributes[kCIAttributeFilterName] as! String
            //print("\(disName):\(filterName)")
            
            //if let inputImage = filter!.attributes[kCIInputImageKey]{//,let _ = filter!.attributes[kCIInputIntensityKey] {
            if filterName.hasPrefix("CIPhoto") {//|| filterName == "CILinearToSRGBToneCurve" || filterName == "CISRGBToneCurveToLinear" {// || filterName == "CIVignetteEffect"  {
                print("inputImage:\(filterName)")
                filterNames.append(disName)
                filterKeys.append(filterName)
            }
            
        }
    }
    
    @IBAction func autoAdjustImage(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            //self.imageView.image = self.oImg?.autoAdjustImage()
        }
        
    }
    
    @IBAction func autoAdjust2(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            //self.imageView.image = self.oImg?.noir()
        }
    }
    
    @IBAction func autoAdjust3(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            //self.imageView.image = self.oImg?.sepiaTone()
        }
    }
}

extension UIImage {
    
    
    func autoAdjustImage() -> UIImage? {
        
        let imageData = UIImageJPEGRepresentation(self,0.8)
        var inputImage = CoreImage.CIImage(data: imageData!)
        let options:[String : AnyObject] = [CIDetectorImageOrientation:1] //图片方向
        let context = CIContext(options:nil)
        
        let filters = inputImage!.autoAdjustmentFiltersWithOptions(options)
        //遍历所有滤镜，依次处理图像
        for filter: CIFilter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage = filter.outputImage
        }
        
        let cgImage = context.createCGImage(inputImage!, fromRect: inputImage!.extent)
        
        return UIImage(CGImage: cgImage)
    }
    
    func filterWithName(name:String) -> CIFilter {
        let imageData = UIImagePNGRepresentation(self)
        let inputImage = CoreImage.CIImage(data: imageData!)
        
        let filter = CIFilter(name:name)
            
        if filter!.inputKeys.contains(kCIInputImageKey) == true {
            filter!.setValue(inputImage, forKey: kCIInputImageKey)
        }
        
        //6'
        let vignette = CIFilter(name: "CIVignette")
        vignette?.setValue(filter?.outputImage, forKey: kCIInputImageKey)
        vignette?.setValue(0.5 * 2, forKey: kCIInputIntensityKey)
        vignette?.setValue(0.5 * 30, forKey: kCIInputRadiusKey)
        
        return vignette!
        
        //[filter setValue: [NSValue valueWithCGAffineTransform:CGAffineTransformMakeRotation(30)] forKey:@"inputTransform"];

        //filter!.setValue(0.8, forKey: kCIInputIntensityKey)
        
    }
    
    
    
    //棕褐色复古滤镜（老照片效果）
    func sepiaTone() -> UIImage?
    {
        let imageData = UIImagePNGRepresentation(self)
        let inputImage = CoreImage.CIImage(data: imageData!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: kCIInputIntensityKey)
        if let outputImage = filter!.outputImage {
            let outImage = context.createCGImage(outputImage, fromRect: outputImage.extent)
            return UIImage(CGImage: outImage)
        }
        return nil
    }
    
    //黑白效果滤镜
    func noir() -> UIImage?
    {
        let imageData = UIImagePNGRepresentation(self)
        let inputImage = CoreImage.CIImage(data: imageData!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CIPhotoEffectNoir")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        if let outputImage = filter!.outputImage {
            let outImage = context.createCGImage(outputImage, fromRect: outputImage.extent)
            return UIImage(CGImage: outImage)
        }
        return nil
    }
    
    static func resizeImage2(image: UIImage, newSize: CGSize) -> UIImage {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        let newImageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: newImageRef!)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    ///限制輸出Image最大邊為 maxResolution
    func scaleAndRotateImage(maxResolution:Int) -> UIImage {
        
        //print("旋轉照片並縮小")
        let kMaxResolution = maxResolution
        
        let imgRef = self.CGImage
        let width:Int = Int(CGImageGetWidth(imgRef))
        let height:Int = Int(CGImageGetHeight(imgRef))
        //print("org.size:\(width),\(height)")
        var transform = CGAffineTransformIdentity
        var bounds = CGRectMake(0,0,CGFloat(width),CGFloat(height))
        
        if width > kMaxResolution || height > kMaxResolution {
            let ratio = Float(width) / Float(height)
            
            if ratio > 1 {
                
                bounds.size.width = CGFloat(kMaxResolution)
                bounds.size.height = CGFloat(roundf(Float(bounds.size.width)/ratio))
            }else{
                bounds.size.height = CGFloat(kMaxResolution)
                bounds.size.width = CGFloat(roundf(Float(bounds.size.height) * ratio))
            }
            //print("ratio:\(ratio)")
        }
        
        //print("bounds.size:\(bounds.size.width),\(bounds.size.height)")
        
        /*
         if width > height {//橫向照片
         var ratio = width / height
         bounds.size.width = CGFloat(bounds_width)
         bounds.size.height = CGFloat(roundf(Float(bounds_height) / ratio))
         } else {
         var ratio = height / width
         bounds.size.width = CGFloat(roundf(Float(bounds_width)/ratio))
         bounds.size.height = CGFloat(bounds_height)
         }
         */
        
        //print("指定大小：\(bounds.size.width),\(bounds.size.height)")
        let mbounds = UIScreen.mainScreen().bounds
        
        let scaleRatio = Int(mbounds.size.width) / width
        //        var scaleRatioheight = Float(bounds.size.height) / height
        
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(imgRef)), CGFloat(CGImageGetHeight(imgRef)))
        
        
        let m_pi = CGFloat(M_PI)
        
        let boundHeight:CGFloat
        
        let orient = self.imageOrientation
        
        switch orient {
        case UIImageOrientation.Up: //EXIF = 1
            transform = CGAffineTransformIdentity
            
        case UIImageOrientation.UpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            
        case UIImageOrientation.Down: //EXIF = 3
            
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformRotate(transform, m_pi)
            
        case UIImageOrientation.DownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            
        case UIImageOrientation.LeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, 3.0 * m_pi / 2.0)
            
        case UIImageOrientation.Left: //EXIF = 6
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width)
            transform = CGAffineTransformRotate(transform, 3.0 * m_pi / 2.0)
            
        case UIImageOrientation.RightMirrored: //EXIF = 7
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, m_pi / 2.0)
            
        case UIImageOrientation.Right: //EXIF = 8
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0)
            transform = CGAffineTransformRotate(transform, m_pi / 2.0)
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        if (orient == UIImageOrientation.Right || orient == UIImageOrientation.Left) {
            CGContextScaleCTM(context, CGFloat(-scaleRatio), CGFloat(scaleRatio))
            CGContextTranslateCTM(context, CGFloat(-height), 0)
        } else {
            CGContextScaleCTM(context, CGFloat(scaleRatio), CGFloat(-scaleRatio))
            CGContextTranslateCTM(context, 0, CGFloat(-height))
        }
        
        CGContextConcatCTM(context, transform);
        
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imgRef)
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //print("照片輸出尺寸：\(imageCopy.size.width),\(imageCopy.size.height)")
        
        
        return imageCopy
        //return UIImage(data: compressData)!
        
    }
    
    func resizedImage(newSize:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        var drawTransposed:Bool
        switch(self.imageOrientation) {
        case .Left:
            fallthrough
        case .LeftMirrored:
            fallthrough
        case .Right:
            fallthrough
        case .RightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
            break
        }
        return self.resizedImage(
            newSize,
            transform: self.transformForOrientation(newSize),
            drawTransposed: drawTransposed,
            interpolationQuality: quality
        )
    }
    func resizedImageWithContentMode(contentMode:UIViewContentMode, bounds:CGSize, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let horizontalRatio:CGFloat = bounds.width / self.size.width
        let verticalRatio:CGFloat = bounds.height / self.size.height
        var ratio:CGFloat = 1
        switch(contentMode) {
        case .ScaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
            break
        case .ScaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
            break
        default:
            print("Unsupported content mode \(contentMode)")
        }
        let newSize:CGSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio)
        return self.resizedImage(newSize, interpolationQuality: quality)
    }
    func resizedImage(newSize:CGSize, transform:CGAffineTransform, drawTransposed transpose:Bool, interpolationQuality quality:CGInterpolationQuality) -> UIImage {
        let newRect:CGRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let transposedRect:CGRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width)
        let imageRef:CGImageRef = self.CGImage!
        // build a context that's the same dimensions as the new size
        //let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        //let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        let bitmap = CGBitmapContextCreate(nil, Int(newRect.size.width), Int(newRect.size.height), CGImageGetBitsPerComponent(imageRef), 0, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef).rawValue)
        // rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform)
        // set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, quality)
        // draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef)
        // get the resized image from the context and a UIImage
        let newImageRef:CGImageRef = CGBitmapContextCreateImage(bitmap)!
        let newImage:UIImage = UIImage(CGImage: newImageRef)
        return newImage
    }
    func transformForOrientation(newSize:CGSize) -> CGAffineTransform {
        var transform:CGAffineTransform = CGAffineTransformIdentity
        switch (self.imageOrientation) {
        case .Down:          // EXIF = 3
            fallthrough
        case .DownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case .Left:          // EXIF = 6
            fallthrough
        case .LeftMirrored:  // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case .Right:         // EXIF = 8
            fallthrough
        case .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            break
        default:
            break
        }
        switch(self.imageOrientation) {
        case .UpMirrored:    // EXIF = 2
            fallthrough
        case .DownMirrored:  // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case .LeftMirrored:  // EXIF = 5
            fallthrough
        case .RightMirrored: // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        default:
            break
        }
        return transform
    }
}