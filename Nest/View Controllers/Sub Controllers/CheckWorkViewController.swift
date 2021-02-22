////
//  ViewController.swift
//  Nest
//
//  Created by Uditi Sharma on 23/01/2021.
//

import UIKit
import Vision


class CheckWorkViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let mobilenet = MobileNetV2()
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    var challengeName = challengeArray[descriptionInt].keywords
    //change to array at thing
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white, UIColor.systemPink]
        view.layer.addSublayer(gradientLayer)
        
        pageTitle.text = challengeArray[descriptionInt].titleOfChallenge
        
        textView.isEditable = false
        
        textView.text = "\(challengeArray[descriptionInt].descriptionOfChallenge)"

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        imageView.image = image
        resultLabel.text = "Loading..."
        if let imagebuffer = convertImage(image: image) {
            
            if let prediction = try? mobilenet.prediction(image: imagebuffer){
                print("hello")
                print(" \(prediction.classLabel) ")
                resultLabel!.text =  "\(prediction.classLabel)"
            }
        }
    }
    
    // convert A image to cv Pixel Buffer with 224*224
    func convertImage(image: UIImage) -> CVPixelBuffer? {
        
        let newSize = CGSize(width: 224.0, height: 224.0)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        // convert to pixel buffer
        
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newSize.width),
                                         Int(newSize.height),
                                         kCVPixelFormatType_32ARGB,
                                         attributes,
                                         &pixelBuffer)
        
        guard let createdPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(createdPixelBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(newSize.width),
                                      height: Int(newSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(createdPixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        resizedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return createdPixelBuffer
    }
    
    
    @IBAction func camClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)

    }
    
    
    @IBAction func checkClicked(_ sender: Any) {
        print("hello there")
        
        var resultsText = resultLabel!.text
//        if resultsText!.contains(challengeName) {
        let word = resultsText!.components(separatedBy: " ").first
        print(word!)


        if challengeName.contains(word!) {

            print("poggers!! ")
            let alert = UIAlertController(title: "Congrats on completing your task!", message: "You have gained 10 points for this task!", preferredStyle: .alert)
        
            let ok = UIAlertAction(title: "Save for myself", style: .default, handler: { action in

                if self.imageView.image != nil {

                    if let imageData = self.imageView.image?.pngData() {
//save image
                    }

                }
            })

            alert.addAction(ok)

            let post = UIAlertAction(title: "Post on The Hub to inspire others!", style: .default, handler: { action in
                // what happens when they post it to hub- firebase


            })
            alert.addAction(post)

            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            })
            alert.addAction(cancel)
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })

        } else {
        print("nope send error message")
            print("nope")

            let alert = UIAlertController(title: "Whoops", message: "Please take another picture!.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            self.present(alert, animated: true, completion: nil)

        }
}
}
