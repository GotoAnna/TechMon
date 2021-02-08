//
//  BattleViewController.swift
//  TechMon
//
//  Created by Mac on 2021/02/04.
//

import UIKit

class BattleViewController: UIViewController {

    //プレイヤーの関連づけ
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    //敵の関連づけ
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    //音楽再生などで使う便利クラス
    let techMonManager = TechMonManager.shared
    var player: Character!
    var enemy: Character!
    
    //キャラクターのステータス
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    var gameTimer: Timer! //ゲーム用タイマー
    var isPlayerAttackAvailable: Bool = true //プレイヤーが攻撃できるかどうか
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //キャラクターの読み込み(TechMonManagerのplyer, enemyを代入)
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        //プレイヤーのステータスを反映
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        
        //敵のステータスを反映
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                         selector: #selector(updateGame), userInfo: nil, repeats: true)
        
        gameTimer.fire()
    }
    
    
    
    func updateUI()
    {
        //プレイヤーのステータスを反映
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        //敵のステータスを反映
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
    }
    
    
    
    func judgeBattle()
    {
        if player.currentHP <= 0
        {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
        else if enemy.currentHP <= 0
        {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin:  true)
        }
    }
    
    //バトル画面を表示
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    //バトル画面を非表示
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame()
    {
        //プレイヤーのステータスを更新
        player.currentMP += 1
        //MPが20を超えたら攻撃できるようにして, MPは21以上にならないようにする
        if player.currentMP >= player.maxMP
        {
            isPlayerAttackAvailable = true
            player.currentMP = player.maxMP
        }
        else{
            isPlayerAttackAvailable = false
        }
        
        //敵のステータスを更新
        enemy.currentMP += 1
        //敵はMPが35までいったら自動で一回攻撃する
        if enemy.currentMP >= enemy.maxMP{
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
    }
    
    //敵の攻撃
    func enemyAttack()
    {
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        
        judgeBattle()
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool)
    {
        //BGMやタイマーを止めておく
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        //勝敗結果でメッセージと音楽を変える
        var finishMessage: String = ""
        if isPlayerWin{
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！！"
        }
        else{
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        
        //OKボタンを押したらバトル画面を閉じる(dismiss)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:
                                        {
                                            _ in self.dismiss(animated: true, completion: nil)
                                        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func attackAction()
    {
        if isPlayerAttackAvailable{
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP
            {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
    @IBAction func tameruAction()
    {
        if isPlayerAttackAvailable
        {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP
            {
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }
    }
    
    @IBAction func fireAction()
    {
        if isPlayerAttackAvailable &&  player.currentTP >= 40
        {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0
            {
                player.currentTP = 0
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
