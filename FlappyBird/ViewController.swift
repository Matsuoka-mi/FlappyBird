//
//  ViewController.swift
//  FlappyBird
//
//  Created by book mac on 2021/10/28.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する ・　画面が１秒間に何回更新されているかを示すFPSを右下に表示する
        skView.showsFPS = true
        
        //ノードの数を表示する　・　ノードが幾つ表示されているかを右下に表示させるもの
        skView.showsNodeCount = true
        
        //ビューと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示する　・　SKSceneはSKViewクラスのpresentScene()メソッドで設定
        skView.presentScene(scene)
        
       
        
    }

    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool{
        get{
            return true
        }
    }

}

