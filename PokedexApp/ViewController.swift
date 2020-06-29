//
//  ViewController.swift
//  PokedexApp
//
//  Created by Aoyagi Hiroki on 2020/06/22.
//  Copyright © 2020 aoyagih. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var myImageview: UIImageView!
    @IBOutlet weak var explainLabel: UILabel!
    
    @IBAction func didTapTakePicture(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let resize = CGSize(width: 300.0, height: 300.0)
        myImageview.image = UIImage(systemName: "camera.viewfinder")?.reSizeImage(reSize: resize)
        
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        let resize = CGSize(width: 300.0, height: 300.0)
        
        myImageview.image = image.reSizeImage(reSize: resize)
        // print out the image size as a test
        print(image.reSizeImage(reSize: resize).size)
        
        
        coreMLRequest(image: image.reSizeImage(reSize: resize))
    }
    
    func coreMLRequest(image: UIImage){
        //ここからポケモンの分類
            
            //1
            let modelSize = 299
            UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            //2
            let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
            var pixelBuffer : CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
            guard (status == kCVReturnSuccess) else { return }

            CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: newImage.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
            //3
            if #available(iOS 12.0, *) {
                let model3 = PokemonClassifier()
                guard let prediction = try? model3.prediction(image: pixelBuffer!) else { return }
                let predictedLabel = prediction.classLabel
                print(predictedLabel)
                
                let label = ["pikachu", "bulbasasur", "charmander", "squirtle"]
                let name = ["ピカチュウ", "フシギダネ", "ヒトカゲ", "ゼニガメ"]
                let type = ["でんき","くさ", "ほのお" ,"みず"]
                let classify = ["ねずみポケモン", "たねポケモン", "とかげポケモン", "かめのこポケモン"]
                let explanation = [
                    "つくる　でんきが　きょうりょくな　ピカチュウほど\nほっぺの　ふくろは　やわらかく　よく　のびるぞ。","うまれたときから　せなかにふしぎな　タネが\nうえてあったからだと　ともに　そだつという。","あついものを　このむ　せいかく。\nあめにぬれると　しっぽの　さきから　けむりが　でるという。",
                                   "こうらに　とじこもり　みを　まもる。\nあいての　すきを　みのがさずみずを　ふきだして　はんげきする。"]
                let height = ["0.4m", "0.7m", "0.6m", "0.5m"]
                let weight = ["6.0kg", "6.9kg", "8.5kg", "9.0kg"]
                
                
                for i in 0...3{
                    if(predictedLabel == label[i]){
                        print(name[i] + type[i] + classify[i] + explanation[i] + height[i] + weight[i])
                        explainLabel.text = "\(name[i])\nタイプ:\(type[i])    ぶんるい:\(classify[i])\nたかさ:\(height[i]) 　　おもさ:\(weight[i])\n\(explanation[i])"
                    }
                }
                
        
            } else {
                // Fallback on earlier versions
                print("too old ios")
            }
        
    }

}


extension UIImage {
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
