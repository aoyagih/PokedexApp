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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //ここからポケモンの分類
        //ピカチュウの画像を表示
        //let image = UIImage(named: "00000042.jpg")
        let image = UIImage(named: "00000001.png")
        let imageview = UIImageView(image: image)
        imageview.frame = CGRect(x: 100, y: 100, width: 300, height: 300)
        view.addSubview(imageview)
        
        //1
        let modelSize = 299
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
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
                "つくる　でんきが　きょうりょくな　ピカチュウほど　ほっぺの　ふくろは　やわらかく　よく　のびるぞ。","うまれたときから　せなかにふしぎな　タネが　うえてあったからだと　ともに　そだつという。","あついものを　このむ　せいかく。　あめにぬれると　しっぽの　さきから　けむりが　でるという。",
                               "こうらに　とじこもり　みを　まもる。　あいての　すきを　みのがさずみずを　ふきだして　はんげきする。"]
            let height = ["0.4m", "0.7m", "0.6m", "0.5m"]
            let weight = ["6.0kg", "6.9kg", "8.5kg", "9.0kg"]
            
            
            for i in 0...3{
                if(predictedLabel == label[i]){
                    print(name[i] + type[i] + classify[i] + explanation[i] + height[i] + weight[i])
                }
            }
    
        } else {
            // Fallback on earlier versions
            print("too old ios")
        }
    }

    

}

