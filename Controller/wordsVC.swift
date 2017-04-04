//
//  wordsVC.swift
//  learnWithMAc
//
//  Created by Etnuh on 2/6/17.
//  Copyright © 2017 Rainman Technologies. All rights reserved.
//

import UIKit
import GameKit



class wordsVC: UIViewController, GKGameCenterControllerDelegate {
    
    let myLetters = letter()
    var currentWord = 0
    var correctChoicePlacement: UInt32 = 0
    var points = Int()
    var counter = Int()
    
    @IBOutlet weak var picOfWordsImage: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var letterLabel: UILabel!
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var score = 0
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.rainmantechnologies.learningWithMack"
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error!)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error!)
            }
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        

        
        imageChanger()
        newGame()
        points = 0
        counter = 0
        picResize()
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        counter += 1
        imageChanger()
    }
    

    
    func newGame() {
        
        letterLabel.text = myLetters.wordsForGame[currentWord]
        
        correctChoicePlacement = arc4random_uniform(UInt32(3))+1
        
        var x = 1
        
        for i in 1...myLetters.letters.count {
            
            // Create a button
            if let button = (view.viewWithTag(i) as? UIButton) {
                
                button.layer.cornerRadius = 8
                button.layer.masksToBounds = true
                button.layer.shadowOpacity = 0.5
                
                if (i == Int(correctChoicePlacement)) {
                
                    button.setTitle(myLetters.myChoice[currentWord][0], for: .normal)
                
                }
                else {
                
                    button.setTitle(myLetters.myChoice[currentWord][x], for: .normal)
                
                    x = 2
                }
            }
        }
                    currentWord += 1
    }
    
    func picResize() {
        
        picOfWordsImage.layer.cornerRadius = 8
        picOfWordsImage.clipsToBounds = true
        
    }
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self 
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
        
        
    }
    
    @IBAction func wordButton(_ sender: AnyObject) {
        
        if (sender.tag == Int(correctChoicePlacement)) {
            
            print("Right")
            points += 1
            pointsLabel.text = String(points)
        }
        else {
            
            print("Wrong")
    
        }
        
        if (currentWord != myLetters.wordsForGame.count) {
            
            newGame()
            
        }
        else {
        
            let alert = UIAlertController(title: "Your Score",
                                          message: "You scored \(points) points.",
                                          preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Play Again?", style: .default, handler: { (action) -> Void in
                
                // Add 10 points to current score
                self.score += 10
                self.pointsLabel.text = "\(self.score)"
                
                // Submit score to GC leaderboard
                let bestScoreInt = GKScore(leaderboardIdentifier: self.LEADERBOARD_ID)
                bestScoreInt.value = Int64(self.score)
                GKScore.report([bestScoreInt]) { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Best Score submitted to your Leaderboard!")
                    }
                }
                
                self.currentWord = Int(arc4random_uniform(UInt32(3)))
                self.currentWord = 0
                self.correctChoicePlacement = 0
                self.points = 0
                self.counter = 0
                self.pointsLabel.text = String(self.points)
                self.newGame()
                self.imageChanger()
                
                
                
                
            })
            // Add action buttons and present the Alert
            alert.addAction(action1)
            

            present(alert, animated: true, completion: nil)
            
            }
    }
    
    func imageChanger() {
        
        if counter <= 25 {
            
            picOfWordsImage.image = UIImage(named: myLetters.imagesForWordGame[counter])
            
        }
        
       
    }
}

