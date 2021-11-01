//
//  GameScene.swift
//  FlappyBird
//
//  Created by book mac on 2021/10/28.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!  //追加
    
    //課題----------------------------------------------------------------------------
    var mushiNode:SKSpriteNode!
    
    
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0   //0...00001 1
    let groundCategory: UInt32 = 1 << 1 //0...00010 2
    let wallCategory: UInt32 = 1 << 2   //0...00100 4
    let scoreCategory: UInt32 = 1 << 3  //0...01000 8
    
    //課題----------------------------------------------------------------------------
    let mushiCategory: UInt32 = 1 << 4 //0...10000
    
    //スコア用
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    
    //課題----------------------------------------------------------------------------
    //アイテムスコア用
    var itemscore = 0
    var itemscoreLabelNode:SKLabelNode!
    var itembestScoreLabelNode:SKLabelNode!
    
    
    //chapter8 UserDefaults 値を保存する
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)    //addchild(_:)　画面に表示させる
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)   //壁はscrollNode.addChild
        
        //課題----------------------------------------------------------------------------
        //虫用のノード
        mushiNode = SKSpriteNode()
        scrollNode.addChild(mushiNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        
        //chapter8 スコア初期化を行うメソッド
        setupScoreLabel()
        //課題----------------------------------------------------------------------------
        setupitemScoreLabel()
        
        //課題
        setupMushi()
        
        
    }
    
    //touchesBegan(_:with:)　でタップしたら呼ばれるメソッド
    //画面をタップしたときに呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        if scrollNode.speed > 0 {
            
            //鳥の速度をゼロにする velocity:速度
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            
        }else if bird.speed == 0 {
            restart()
        }
        
    }
    
    
    
    
    
    
    func setupGround() {
        //地面の画像を読み込む・表示する画像をSKTextureで扱うという認識
        let groundTexture = SKTexture(imageNamed: "ground")
        
        //SKTextureクラスにfilteringModeプロパティに.nearestと設定で荒くても処理速度優先
        //.linearだと、画質優先
        groundTexture.filteringMode = .nearest
        
        //地面をスクロースさせるのに必要な枚数を計算　多めに並べてスクロール時に切れないようにするため＋２
        
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //5秒かけて左方向に画像一枚文スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        //元の位置に一瞬で戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        //左スクロール　->元の位置 ->左にスクロール　と無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置する
        for i in 0..<needNumber {
            
            //テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: groundTexture)
            
            
            //スプライトの表示する位置を指定する ・　↓高さと幅の半分をNodeの中心位置とするという記述。
            //CGFloat　はCocoa の浮動小数点系
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                
                y: groundTexture.size().height / 2
            )
            
            //スプライトにアニメーションを設定する　動きを与えたいSKNodeにrun(_:)メソッドで作成したSKActionを設定してアクションを開始させる
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            //groundCategory:00010
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないよう設定する
            sprite.physicsBody?.isDynamic = false
            
            //シーンにスプライトを追加する　・　このスプライトを画面に表示させる
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupCloud() {
        //雲の画像を読み込む・表示する画像をSKTextureで扱うという認識
        let cloudTexture = SKTexture(imageNamed: "cloud")
        
        //SKTextureクラスにfilteringModeプロパティに.nearestと設定で荒くても処理速度優先
        //.linearだと、画質優先
        cloudTexture.filteringMode = .nearest
        
        //地面をスクロースさせるのに必要な枚数を計算　多めに並べてスクロール時に切れないようにするため＋２
        
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //20秒かけて左方向に画像一枚文スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        //元の位置に一瞬で戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左スクロール　->元の位置 ->左にスクロール　と無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //cloudのスプライトを配置する
        for i in 0..<needCloudNumber {
            
            //テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: cloudTexture)
            
            
            //スプライトの表示する位置を指定する ・　↓高さと幅の半分をNodeの中心位置とするという記述。
            //CGFloat　はCocoa の浮動小数点系
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                
                y: self.size.height - cloudTexture.size().height / 2
            )
            
            //スプライトにアニメーションを設定する　動きを与えたいSKNodeにrun(_:)メソッドで作成したSKActionを設定してアクションを開始させる
            sprite.run(repeatScrollCloud)
            
            
            
            
            
            //シーンにスプライトを追加する　・　このスプライトを画面に表示させる
            scrollNode.addChild(sprite)
        }
        
    }
    
    
    func setupWall() {
        //壁の画像を読み込む・表示する画像をSKTextureで扱うという認識
        let wallTexture = SKTexture(imageNamed: "wall")
        
        //SKTextureクラスにfilteringModeプロパティに.nearestと設定で荒くても処理速度優先
        //当たり判定を行うスプライトには.linearで、画質優先
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算　フレームの幅と壁の幅
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        //画面外まで移動する移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //removeFromParent()で自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成　画面外まで移動して削除
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //鳥が通り抜ける隙間の大きさを鳥のサイズの４倍とする
        let slit_length = birdSize.height * 4
        
        //隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 60
        
        //空の中央位置（y座標）を取得
        //地面の画像サイズを取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        //空の高さ（画面の高さから地面の高さを引いた）の半分　に　地面の高さを足したもの
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        //空の中央位置を基準にして下の壁の中央位置を取得
        //空の中央から鳥の通れる隙間の半分と壁の半分を引いたものが下の壁の中央位置
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        //壁を生成するアクションを作成
        let creatWallAnimation = SKAction.run({
            
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            
            //フレームの幅＋壁の半分を足したものがwall.positionのx座標
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            //   wall.zPosition = -50 //雲より手前、　地面より奥
            
            //-random_y_range〜random_y_rangeの範囲のランダム値を生成
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            
            //下の壁の中央位置にランダム値を足して、下の壁の表示位置を決定
            let under_wall_y = under_wall_center_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            //カテゴリマスク　wallCategory:  1 << 2   //0...00100   4
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないよう設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            //カテゴリマスク　wallCategory:  1 << 2   //0...00100   4
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないよう設定する
            upper.physicsBody?.isDynamic = false
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            
            //カテゴリマスク　 scoreCategory: 0...01000   8
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            
            //contactTestBitMask 衝突した時に通知として送る値 birdCategory: 0...00001 1
            //contactTestBitMask 衝突することを判定する相手のカテゴリーを設定する
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.run(wallAnimation
            )
            wall.addChild(scoreNode)
            self.wallNode.addChild(wall)
            
            
        })
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([creatWallAnimation, waitAnimation]))
        wallNode.run(repeatForeverAnimation)
        
        
        
    }
    
    //課題ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    
    func setupMushi() {
        //虫の画像を読み込む・表示する画像をSKTextureで扱うという認識
        let mushiTexture = SKTexture(imageNamed: "mushi")
        
        //SKTextureクラスにfilteringModeプロパティに.nearestと設定で荒くても処理速度優先
        //当たり判定を行うスプライトには.linearで、画質優先
        mushiTexture.filteringMode = .linear
        
        //移動する距離を計算　フレームの幅と壁の幅
        let movingDistance = self.frame.size.width + mushiTexture.size().width
        
        //画面外まで移動する移動するアクションを作成
        let moveMushi = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //removeFromParent()で自身を取り除くアクションを作成
        let removeMushi = SKAction.removeFromParent()
        
        //2つのアニメーションを順に実行するアクションを作成　画面外まで移動して削除
        let mushiAnimation = SKAction.sequence([moveMushi, removeMushi])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        //課題----------------------------------------------------------------
        
        //振れ幅
        let random_x_range: CGFloat = 100
        let random_y_range: CGFloat = 100
        
        
        // 空の中央位置(y座標)を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        //空の中央位置を基準にして虫の中央位置を取得
        //空の中央から虫の半分を引いたものが虫の中央位置
        let Mushi_mushi_center_y = sky_center_y - mushiTexture.size().width / 2
        
        //虫を生成するアクションを作成
        let creatMushiAnimation = SKAction.run({
            
            //虫関連のノードを乗せるノードを作成
            let mushi = SKNode()
            
            
            //-random_y_range〜random_y_rangeの範囲のランダム値を生成
            let random_x = CGFloat.random(in: -random_x_range...random_x_range)
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            
            //フレームの幅＋虫の半分を足したものがmushi.positionのx座標-------------------------
            
            mushi.position = CGPoint(x: self.frame.size.width + mushiTexture.size().width / 2, y: 0)
            
            //   mushi.zPosition = -50 //雲より手前、　地面より奥
            
            //虫の中央位置にランダム値を足して、表示位置を決定
            
            let Mushi_mushi_y = Mushi_mushi_center_y + random_y
            
            //虫を作成
            let Mushi = SKSpriteNode(texture: mushiTexture)
            
            
            Mushi.position = CGPoint(x: random_x, y: Mushi_mushi_y)
            
            //スプライトに物理演算を設定する
            Mushi.physicsBody = SKPhysicsBody(rectangleOf: mushiTexture.size())
            
            //カテゴリマスク　wallCategory:  1 << 2   //0...00100   4
            Mushi.physicsBody?.categoryBitMask = self.mushiCategory
            
            //衝突の時に動かないよう設定する
            Mushi.physicsBody?.isDynamic = false
            
            mushi.addChild(Mushi)
            
            
            mushi.run(mushiAnimation)
            self.mushiNode.addChild(mushi)
            
            
        })
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([creatMushiAnimation, waitAnimation]))
        wallNode.run(repeatForeverAnimation)
        
        
        
    }
    
    
    //ここまでーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    
    
    
    
    func setupBird(){
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        //物理演算を設定 鳥のスプライトに半径を指定して円形の物理体を設定する
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定 birdCategory: 00001  groundCategory: 00010 wallCategory:01000
        //groundCategory | wallCategory  00010 | 01000
        //bird 衝突しにいく：00001 衝突される：00010 | 01000
        //上下の壁　衝突しにいく: 01000
        //scoreNode 衝突しに行く：01000
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory | mushiCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | mushiCategory
        
        
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
        
        
    }
    
    //SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        
        //ゲームオーバーの時は何もしない.壁に当たったら地面にも当たるので２度目の処理をしないようにする為
        if scrollNode.speed <= 0{
            return
        }
        
        // ||はor
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            
            
            //スコア用の物体と衝突した
            print("ScoreUP")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            //UserDefaultsはキーと値を指定して保存する.取り出すときはキーを指定。
            //integer(forKey:)メソッドでキーを指定する。ここではBESTをキーにする
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()  //synchronize(即座に反映させるためのメソッド）
            }
            
            //課題--------------------------------------------------------------------
        }else if(contact.bodyA.categoryBitMask & mushiCategory) == mushiCategory || (contact.bodyB.categoryBitMask & mushiCategory) == mushiCategory {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
            //衝突で消える
            contact.bodyA.node?.removeFromParent()
            
            //衝突で音が鳴る
            let sound: SKAction = SKAction.playSoundFileNamed("oto.mp3", waitForCompletion: true)
            
            self.run(sound);
            
            
            //スコア用の物体と衝突した
            print("ScoreUP")
            itemscore += 1
            itemscoreLabelNode.text = "itemScore:\(itemscore)"
            
            //ベストスコア更新か確認する
            //UserDefaultsはキーと値を指定して保存する.取り出すときはキーを指定。
            //integer(forKey:)メソッドでキーを指定する。ここではBESTをキーにする
            var itembestScore = userDefaults.integer(forKey: "itemBEST")
            if itemscore > itembestScore {
                itembestScore = score
                itembestScoreLabelNode.text = "itemBest Score:\(itembestScore)"
                userDefaults.set(itembestScore, forKey: "itemBEST")
                userDefaults.synchronize()  //synchronize(即座に反映させるためのメソッド）
            }
            
            //ここまで--------------------------------------------------------------------
            
        }else
        
        {
            
            //壁か地面と衝突した
            print("GameOver")
            
            
            
            //スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
        
        
    }
    
    func restart(){
        
        
        
        score = 0
        scoreLabelNode.text = "Score:\(score)"  //スコア表示のリセット
        
        //課題
        itemscore = 0
        itemscoreLabelNode.text = "itemScore:\(itemscore)"  //スコア表示のリセット
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 //いちばん手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 //一番手前
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "BEST Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
    }
    
    func setupitemScoreLabel(){
        itemscore = 0
        itemscoreLabelNode = SKLabelNode()
        itemscoreLabelNode.fontColor = UIColor.black
        itemscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemscoreLabelNode.zPosition = 100 //いちばん手前に表示する
        itemscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemscoreLabelNode.text = "itemScore:\(itemscore)"
        self.addChild(itemscoreLabelNode)
        
        itembestScoreLabelNode = SKLabelNode()
        itembestScoreLabelNode.fontColor = UIColor.black
        itembestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
        itembestScoreLabelNode.zPosition = 100 //一番手前
        itembestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let itembestScore = userDefaults.integer(forKey: "itemBEST")
        itembestScoreLabelNode.text = "itemBEST Score:\(itembestScore)"
        self.addChild(itembestScoreLabelNode)
        
    }
    
    
}
