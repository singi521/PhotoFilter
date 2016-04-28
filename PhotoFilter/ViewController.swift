//
//  ViewController.swift
//  PhotoFilter
//
//  Created by vincentyen on 4/28/16.
//  Copyright © 2016 Fun Anima Co., Ltd. All rights reserved.
//


import UIKit


class ViewController: UIViewController {
    
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var bottomCollectionView: UICollectionView!
    @IBOutlet weak var loadingui: UIActivityIndicatorView!
    @IBOutlet weak var desLabel: UILabel!
    
    let screenHeight  = UIScreen.mainScreen().bounds.height
    let screenWidth   = UIScreen.mainScreen().bounds.width
    
    var currentPageIndex:Int = 0
    
    var imgViews:[UIImageView] = []
    
    var oriImgs = [UIImage]()
    
    var thumbImg:[UIImage] = []
    
    var currentFilter:CIFilter?
    
    
    var cacheFilterImage = Dictionary<String,(filter:CIFilter,image:UIImage)>()
    var cacheThumbFilterImage = Dictionary<String,UIImage>()
    /*
     lazy var context: CIContext = {
     let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
     let options = [kCIContextWorkingColorSpace : NSNull()]
     return CIContext(EAGLContext: eaglContext, options: options)
     }()*/
    
    var context:CIContext!
    
    
    func onTouchedScrollView(){
        
        if let existView = self.view.viewWithTag(999) as? UIImageView {
            existView.image = self.oriImgs[self.pageIdx()]
        }else{
            let currentImgView:UIImageView = self.imgViews[self.pageIdx()]
            let newImgView = UIImageView(image: self.oriImgs[self.pageIdx()])
            newImgView.frame = CGRectMake(0, 0, currentImgView.frame.width, currentImgView.frame.height)
            newImgView.contentMode = currentImgView.contentMode
            newImgView.userInteractionEnabled = false
            newImgView.tag = 999
            
            self.view.addSubview(newImgView)
        }
        
        self.imageScrollView.scrollEnabled = false
    }
    
    func onRealaseScrollView(){
        self.imageScrollView.scrollEnabled = true
        self.view.viewWithTag(999)?.removeFromSuperview()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = CIContext(options: nil)
        
        bottomCollectionView.dataSource = self
        bottomCollectionView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        FilterCroller.searchFilterName()
        
        let defaultImg = UIImage(named: "20150531010754.jpg")!
        addImage(defaultImg,x:0)
        addImage(UIImage(named: "20150531012710.jpg")!, x: screenWidth)
        
        beginImage = CIImage(image: defaultImg)
        
        imageScrollView.contentSize.width = screenWidth * 2
        imageScrollView.pagingEnabled = true
        
        self.imageScrollView.delegate = self
        
        slider.addTarget(self, action: #selector(ViewController.sliderEndChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(ViewController.onTouchedScrollView),name: "Touched",object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(ViewController.onRealaseScrollView),name: "TouchOut",object: nil)
        
        self.currentFilter = CIFilter(name: "CISepiaTone")
        self.currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        self.currentFilter!.setValue(0.5, forKey: kCIInputIntensityKey)
        
        
    }
    
    var currentKeyWithFilter:String = ""
    
    var orientation:UIImageOrientation = .Up
    
    func filterToImage(filter:CIFilter) -> UIImage {
        
        let cgimg = self.context.createCGImage(filter.outputImage!, fromRect: filter.outputImage!.extent)
        
        return UIImage(CGImage: cgimg, scale:1, orientation:.Up)
    }
    
    func sliderEndChanged(slider:UISlider){
        print("slider:\(slider.value)")
        
        if let filter = self.currentFilter {
            
            print("inputKeys:\(filter.inputKeys)")
            
            let inputKeys = Set(filter.inputKeys)
            let imgView = self.imgViews[self.pageIdx()]
            
            if inputKeys.contains(self.currentKeyWithFilter) {
                self.currentFilter?.setValue(slider.value, forKey: self.currentKeyWithFilter)
                
                dispatch_async(dispatch_get_main_queue()) {
                    imgView.image = self.filterToImage(filter)
                }
                
            }
        }
        
        
        
        
        
    }
    
    
    func addImage(img:UIImage,x:CGFloat){
        
        //let reSizeImg = img//UIImage.scaleAndRotateImage(img, maxResolution: Int(max(self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height)))
        let newSize = CGSizeMake(screenWidth * UIScreen.mainScreen().scale, screenHeight * UIScreen.mainScreen().scale)
        let reSizeImg = img.resizedImageWithContentMode(.ScaleAspectFill, bounds: newSize, interpolationQuality: .Default)
        let imgView = UIImageView(image: reSizeImg)
        imgView.contentMode = UIViewContentMode.ScaleAspectFit
        imgView.frame = CGRectMake(x, 0, screenWidth, screenHeight)
        imgView.clipsToBounds = true
        
        
        imgView.tag = Int(x / screenWidth )
        
        imgViews.append(imgView)
        oriImgs.append(reSizeImg)
        
        thumbImg.append(UIImage.resizeImage2(img, newSize: CGSizeMake(50, 50)))
        
        imageScrollView.addSubview(imgView)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        for view in self.imageScrollView.subviews {
            //view.bounds.origin.y = self.imageScrollView.bounds.origin.y
            view.frame.origin.y = -self.imageScrollView.frame.origin.y
            view.setNeedsDisplay()
        }
        
    }
    
    func pageIdx()->Int {
        return Int(imageScrollView.contentOffset.x / screenWidth)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var beginImage:CIImage?
    
    
}


extension ViewController :UICollectionViewDataSource ,UICollectionViewDelegate{
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterCroller.filterNames.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let myCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! MyCell
        if indexPath.row == 0 {
            myCell.disLable.text = ""
            myCell.thumbImg.image = self.thumbImg[self.pageIdx()]
            
            
        }else{
            let disPlayName = FilterCroller.filterNames[indexPath.row-1]
            let filterKey = FilterCroller.filterKeys[indexPath.row-1]
            
            myCell.disLable.text = ""//NSLocalizedString(filterKey, comment: "")
            
            
            //給初始
            myCell.thumbImg.image = self.thumbImg[self.pageIdx()]
            
            //Filter Process
            var thumbImage:UIImage?
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if let cacheImg = self.cacheThumbFilterImage[filterKey] {
                    thumbImage = cacheImg
                }else{
                    
                    thumbImage = self.filterToImage(self.thumbImg[self.pageIdx()].filterWithName(filterKey))
                    self.cacheThumbFilterImage[filterKey] = thumbImage
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    //套濾鏡
                    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MyCell {
                        cell.thumbImg.image = thumbImage
                    }
                }
            }
            
            
            
            
        }
        
        myCell.thumbImg.backgroundColor = UIColor.clearColor()
        return myCell
    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.loadingui.isAnimating() {
            return
        }
        let idx = self.pageIdx()
        let imgView = self.imgViews[idx]
        
        if indexPath.row == 0 {
            self.loadingui.startAnimating()
            dispatch_async(dispatch_get_main_queue()) {
                self.loadingui.stopAnimating()
                //imgView.image = self.oriImgs[idx]
                print("Success")
                
                let filter = PhotoEffect.oldFilmEffect(self.beginImage!)
                
                self.currentFilter = filter
                
                let outputImage = filter.outputImage!
                
                let cgimg = self.context.createCGImage(outputImage, fromRect: outputImage.extent)
                
                let newImage = UIImage(CGImage: cgimg, scale:1, orientation:.Up)
                imgView.image = newImage
                
                self.settingSliderValue()
            }
            
            return
        }
        
        let selectedFilterName  = FilterCroller.filterNames[indexPath.row-1]
        let selectedFilterKey   = FilterCroller.filterKeys[indexPath.row-1]
        self.desLabel.text = selectedFilterName
        print("didSelectItemAtIndexPath[\(indexPath)]:\(selectedFilterName):\(selectedFilterKey)")
        
        self.view.bringSubviewToFront(self.loadingui)
        
        
        if let (cacheFilter,cacheImage) = self.cacheFilterImage[selectedFilterKey]{
            
            self.currentFilter = cacheFilter
            imgView.image = cacheImage
            
            self.settingSliderValue()
            
            if let setValue = cacheFilter.valueForKey(self.currentKeyWithFilter) as? Float {
                self.slider.value = setValue
            }
            
        }else{
            self.loadingui.startAnimating()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                if self.cacheFilterImage[selectedFilterKey] == nil {
                    self.currentFilter = self.oriImgs[idx].filterWithName(selectedFilterKey)
                }
                print("設定Filter完畢")
                dispatch_async(dispatch_get_main_queue()) {
                    
                    print("currentFilter inputKey: \(self.currentFilter?.inputKeys)")
                    
                    self.settingSliderValue()
                    
                    let img = self.filterToImage(self.currentFilter!)
                    
                    self.cacheFilterImage[selectedFilterKey] = (self.currentFilter!,img)
                    
                    imgView.image = img
                    
                    self.loadingui.stopAnimating()
                    print("Success")
                }
            }
        }
        
        
        
    }
    
    func settingSliderValue(){
        self.slider.hidden = true
        if let attr = self.currentFilter?.attributes {
            if let intensity = attr[kCIInputIntensityKey] as? Dictionary<String,AnyObject> {
                self.currentKeyWithFilter = kCIInputIntensityKey
                let defaultValue = intensity[kCIAttributeDefault] as? Float
                let tMin = intensity[kCIAttributeSliderMin] as? Float
                let tMax = intensity[kCIAttributeSliderMax] as? Float
                self.view.bringSubviewToFront(self.slider)
                self.slider.hidden = false
                self.slider.value = defaultValue ?? 1
                
                
                
                self.slider.minimumValue = tMin ?? 0
                self.slider.maximumValue = tMax ?? 1
            }else{
                
                for inputKey in self.currentFilter!.inputKeys {
                    let inputDict = attr[inputKey] as! Dictionary<String,AnyObject>
                    
                    
                    
                    let className = inputDict[kCIAttributeClass] as! String
                    
                    if className == "NSNumber" {
                        
                        self.currentKeyWithFilter = inputKey
                        
                        let defaultValue = inputDict[kCIAttributeDefault] as? Float
                        let tMin = (inputDict[kCIAttributeSliderMin] ?? inputDict[kCIAttributeMin]) as? Float
                        let tMax = (inputDict[kCIAttributeSliderMax] ?? inputDict[kCIAttributeMax]) as? Float
                        if tMin == nil {
                            self.slider.enabled = false
                            print("inputDict: \(inputDict)")
                        }else{
                            self.slider.enabled = true
                            print("inputKey: [\(inputKey)]:\(className) : \(tMin) ~ \(tMax)")
                        }
                        self.slider.hidden = false
                        self.view.bringSubviewToFront(self.slider)
                        self.slider.value = defaultValue ?? 1
                        self.slider.minimumValue = tMin ?? 0
                        self.slider.maximumValue = tMax ?? 1
                        
                        
                        break
                    }
                }
            }
        }
    }
    
}

extension ViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBAction func onTappedPickUp(sender:AnyObject){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.allowsEditing = false
        self.presentViewController(imagePickerController, animated: true, completion: { imageP in
            print("顯示相簿完畢")
        })
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("OG")
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.orientation = pickedImage.imageOrientation
            
            let newSize = CGSizeMake(screenWidth * UIScreen.mainScreen().scale, screenHeight * UIScreen.mainScreen().scale)
            
            let resizeImg = pickedImage.resizedImageWithContentMode(.ScaleAspectFill, bounds: newSize, interpolationQuality: .Default)
            
            let idx = self.pageIdx()
            self.oriImgs[idx] = resizeImg
            //self.thumbImg[idx] = UIImage.resizeImage2(pickedImage, newSize: CGSizeMake(50, 50))
            
            self.thumbImg[idx] = resizeImg.resizedImageWithContentMode(.ScaleAspectFill, bounds: CGSizeMake(100, 100), interpolationQuality: .Medium)
            self.imgViews[idx].image = resizeImg
            
            self.cacheFilterImage.removeAll()
            self.cacheThumbFilterImage.removeAll()
            self.bottomCollectionView.reloadData()
            
            self.beginImage = CIImage(image: resizeImg)
        }
        
        self.view.viewWithTag(999)?.removeFromSuperview()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    /*
     func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
     let resizeImg = image//UIImage.scaleAndRotateImage(image, maxResolution: Int(max(self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height)))
     self.oriImgs[self.pageIdx()] = resizeImg
     self.imgViews[self.pageIdx()].image = resizeImg
     
     
     dismissViewControllerAnimated(true, completion: nil)
     }*/
}

extension ViewController :UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if self.currentPageIndex != self.pageIdx() {
            self.currentPageIndex = self.pageIdx()
            self.cacheFilterImage.removeAll()
            self.cacheThumbFilterImage.removeAll()
            self.bottomCollectionView.reloadData()
            self.beginImage = CIImage(image: self.oriImgs[self.pageIdx()])
            print("換頁了")
        }
        self.view.viewWithTag(999)?.removeFromSuperview()
    }
}

extension UIScrollView {
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesBegan")
        if touches.first?.view is UIScrollView {
            NSNotificationCenter.defaultCenter().postNotificationName("Touched", object: nil)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesEnded")
        NSNotificationCenter.defaultCenter().postNotificationName("TouchOut", object: nil)
    }
    
    
}