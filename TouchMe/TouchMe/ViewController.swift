//
//  ViewController.swift
//  TouchMe
//
//  Created by Jiying Zou on 2017/6/15.
//  Copyright © 2017年 Jiying Zou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var whoseTurn: player = .Computer
    var computerInput:[buttonColor] = [buttonColor]()
    var highlightTime = 0.5
    var indexOfNextButtonToTouch: Int = 0
    let winningNumber: Int = 25
    var timer: Timer = Timer()
    let startSecond: Int = 5
    var userDefault: UserDefaults = UserDefaults.standard
    
    @IBOutlet var btnRed: UIButton!
    @IBOutlet var btnYellow: UIButton!
    @IBOutlet var btnGreen: UIButton!
    @IBOutlet var btnBlue: UIButton!
    @IBOutlet var imgStart: UIImageView!
    @IBOutlet var imgCorrect: UIImageView!
    @IBOutlet var lblPoints: UILabel!
    @IBOutlet var lblCount: UILabel!
    @IBOutlet var lblHighestScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let highestScore: Int = userDefault.integer(forKey: "HighestScore")
        
        lblHighestScore.text = "Highest: " + String(describing: highestScore)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newGameStart()
    }
    
    @IBAction func buttonTouched(sender: UIButton)
    {
        let buttonTag: Int = sender.tag
        
        if let colorToched = buttonColor(rawValue: buttonTag) {
            
            if whoseTurn == .Computer {
                
                return
                
            }
            
            let originalColor: UIColor = sender.backgroundColor!
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                
                sender.backgroundColor = UIColor.white
                
            }, completion: { (success) in
                
                sender.backgroundColor = originalColor
                
                if colorToched == self.computerInput[self.indexOfNextButtonToTouch] {//玩家按正確按鈕
                    print("user:" + String(describing: colorToched))
                    self.indexOfNextButtonToTouch += 1
                    
                    
                    if self.indexOfNextButtonToTouch == self.computerInput.count { //看玩家按完全部按鈕了沒
                        
                        if self.gameContinued() == false { //按完 -> 贏了
                            
                            //print("player wins!")
                            
                            self.timer.invalidate()
                            
                            self.createAlert(title: "You win!", message: "Try Again?")
                            
                        }
                        
                        self.indexOfNextButtonToTouch = 0
                        
                    } else {
                        
                        print("player 還沒按完")
                        
                    }
                } else {
                    
                    //玩家按錯誤按鈕
                    //print("player loses!")
                    
                    self.timer.invalidate()
                    
                    let scoreNow: String = self.lblHighestScore.text!
                    
                    let index = scoreNow.index(scoreNow.startIndex, offsetBy: 9)
                    
                    if self.computerInput.count - 1 > Int(scoreNow.substring(from: index))! {
                        
                        self.userDefault.set(self.computerInput.count - 1, forKey: "HighestScore")
                        
                    }
                    
                    self.createAlert(title: "You lose!", message: "You get  \(self.computerInput.count - 1)  points! Try again?")
                    
                    self.indexOfNextButtonToTouch = 0
                    
                }
                
            })
            
            
            
            
        }
    }
    
    enum buttonColor: Int {
        
        case Red = 1
        
        case Yellow = 2
        
        case Green = 3
        
        case Blue = 4
        
    }
    
    enum player {
        
        case Human
        
        case Computer
        
    }
    
    func newGameStart() {
        
        computerInput = [buttonColor]()
        
        timer = Timer()
        
        lblCount.text = String(startSecond)
        
        lblPoints.text = String(0)
        
        startAnimation()
        
        
    }
    
    func randomButton() -> buttonColor {
        
        let randomNum: Int = Int(arc4random_uniform(4)) + 1
        
        let color = buttonColor(rawValue: randomNum)
        
        return color!
    }
    
    func gameContinued() -> Bool {
        
        var result: Bool = true
        
        if computerInput.count == winningNumber {
            
            result = false
            
        } else {
            
            if computerInput.count == 0 {
                
                self.computerInput += [self.randomButton()]
                
                self.computerStart(index: 0, hightlightTime: 0.5)
                
            } else {
                
                whoseTurn = .Computer
                
                lblPoints.text = String(computerInput.count)
                
                timer.invalidate()
                
                UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: { //繼續玩
                    
                    self.imgCorrect.alpha = 1
                    
                }, completion: { (success) in
                    
                    UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
                        
                        self.imgCorrect.alpha = 0
                        
                    }, completion: { (success) in
                        
                        self.computerInput += [self.randomButton()]
                        
                        self.computerStart(index: 0, hightlightTime: 0.5)
                        
                    })
                    
                })
            }
            
        }
        
        return result
        
    }
    
    func buttonByColor(color: buttonColor) -> UIButton {
        
        switch color {
        case .Red:
            return btnRed
        case .Yellow:
            return btnYellow
        case .Green:
            return btnGreen
        case .Blue:
            return btnBlue
            
        }
        
    }
    
    func computerStart(index: Int, hightlightTime: Double){
        
        whoseTurn = .Computer
        
        if index == computerInput.count {
            
            whoseTurn = .Human
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.countDown), userInfo: nil, repeats: true)
            
            return
            
        }
        
        lblCount.text = String(startSecond + computerInput.count - 1)
        
        let button: UIButton = buttonByColor(color: computerInput[index])
        
        let originalColor: UIColor = button.backgroundColor!
        
        let highlightColor: UIColor = UIColor.white
        
        UIView.animateKeyframes(withDuration: hightlightTime, delay: 0.0, options: [], animations: {
            
            button.backgroundColor = highlightColor
            
            print("computer:" + String(describing: self.computerInput[index]))
            
        }) { (success) in
            button.backgroundColor = originalColor
            
            let newIndex: Int = index + 1
            
            self.computerStart(index: newIndex, hightlightTime: hightlightTime)
            
        }
        
    }
    
    func createAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
            print("over")
            
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
            print("new game start!")
            
            self.newGameStart()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func startAnimation(){
        
        whoseTurn = .Computer
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
            
            self.imgStart.alpha = 1
            
        }) { (success) in
            
            UIView.animate(withDuration: 2.0, delay: 1.0, options: [], animations: {
                
                self.imgStart.alpha = 0
                
            }, completion: { (success) in
                
                self.imgStart.alpha = 0
                
                self.gameContinued()
                
            })
        }
        
    }
    
    func countDown() {
        
        if Int(lblCount.text!)! > 0 {
            
            lblCount.text = String(Int(lblCount.text!)! - 1)
            
        } else {
            
            timer.invalidate()
            
            self.createAlert(title: "You lose!", message: "You get  \(self.computerInput.count - 1)  points! Try again?")
            
            self.indexOfNextButtonToTouch = 0
            
            
        }
        
    }
    

}

