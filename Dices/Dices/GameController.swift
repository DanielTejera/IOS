//
//  GameController.swift
//  Dices
//
//  Created by Alumno on 21/02/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class GameController: UIViewController {
    
    // MARK: - Interface Variables
    
    @IBOutlet weak var progressP1: UIProgressView!
    @IBOutlet weak var scoreP1: UILabel!
    
    @IBOutlet weak var progressP2: UIProgressView!
    @IBOutlet weak var scoreP2: UILabel!
    
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var dice: UIImageView!
    @IBOutlet weak var acumulatedRolls: UILabel!
    
    @IBOutlet weak var pickUpButton: UIButton!
    
    // MARK: - Constants
    
    let SCORE_TO_WIN = 10
    let FORBIDDEN_NUMBER = 1
    let ANIMATION_TIME = 1.0
    let DICE_ANIMATION_TIME = 0.4
    
    // MARK: - Program variables
    var currentPlayer = 1
    var score = 0
    var firstTime = true
    
    // MARK: - System funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(firstTime){
            prepareGame()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        prepareFirstTurn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Preparation
    
    /**
     Set the accountants and the progress bars at the beginning of each game for the two players
     */
    
    func prepareGame(){
        
        self.scoreP1.text = "0"
        self.progressP1.progress = 0
        
        self.scoreP2.text = "0"
        self.progressP2.progress = 0
        
        prepareDice()
        
    }
    
    /**
     Sets the information of the player that will do the first turn in the game
     */
    func prepareFirstTurn(){
        
        self.playerName.text = NSLocalizedString("P", comment: "Player name") + String(self.currentPlayer)
        
        
        if (self.currentPlayer == 1){
            self.playerName.textColor = UIColor.blue
            self.acumulatedRolls.textColor = UIColor.blue
        }else{
            self.playerName.textColor = UIColor.red
            self.acumulatedRolls.textColor = UIColor.red
        }
        
        if (firstTime){
            self.acumulatedRolls.text = "0"
            self.pickUpButton.isEnabled = false
            
            makeFirstTurnAlert()
            firstTime = false;
        }
        
    }
    
    /**
     Sets the images that will be used to animate the die, in addition to fixing an initial image
     
     */
    func prepareDice(){
        var faces : [UIImage] = []
        
        for image in 1...6 {
            faces.insert(UIImage(named: image.description)!, at: image - 1)
        }
        
        self.dice.animationImages = faces
        self.dice.animationDuration = DICE_ANIMATION_TIME
        self.dice.image = self.dice.animationImages![0]
    }
    
    // MARK: - Alerts
    
    /**
     Create and display the alert that informs the players about who is going to start the game
     */
    func makeFirstTurnAlert(){
        let firstTurnAlert = UIAlertController(title: NSLocalizedString("Let's start the game!", comment: "Start game title"),
                                               message: NSLocalizedString("Player ", comment: "Start message 1") + String(self.currentPlayer) + NSLocalizedString(" starts", comment: "Start message 2"),
                                               preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: NSLocalizedString("Accept", comment: "Accept action"), style: .default) { (action:UIAlertAction) in
            
        }
        
        firstTurnAlert.addAction(acceptAction)
        
        self.present(firstTurnAlert, animated: true, completion: nil)
    }
    
    /**
     Create and display the alert that informs the players about the turn change
     */
    func makeTurnAlert(){
        let newTurnAlert = UIAlertController(title: NSLocalizedString("New turn!", comment: "New turn title"),
                                             message: NSLocalizedString("Player ", comment: "Turn alert message 1") + String(self.currentPlayer) + NSLocalizedString(" begins the turn", comment: "Turn alert message 2"),
                                             preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: NSLocalizedString("Accept", comment: "Accept action"), style: .default) { (action:UIAlertAction) in
            
        }
        
        newTurnAlert.addAction(acceptAction)
        
        
        self.present(newTurnAlert, animated: true, completion: nil)
        
        
    }
    
    /**
     Create and display the alert that informs the players about who has won
     
     ## ACTIONS ##
     
     - acceptAction: It causes that a new game begins, being the player who initiates the one that lost the previous game
     - cancelAction: It causes the rules screen to be displayed, throug a unwindSegue
     */
    func makeWinAlert(){
        
        let winAlert = UIAlertController(title: NSLocalizedString("Player ", comment: "Win title 1") + String(self.currentPlayer) + NSLocalizedString(" wins!", comment: "Win title 2"),
                                         message: NSLocalizedString("Play again?", comment: "Win message"),
                                         preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default) { (action:UIAlertAction) in
            if (self.currentPlayer == 1){
                self.currentPlayer = 2
            }else{
                self.currentPlayer = 1
            }
            
            self.firstTime = true
            self.prepareGame()
            self.prepareFirstTurn()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: .default) { (action: UIAlertAction) in
            self.performSegue(withIdentifier: "unwindToRules", sender: self)
            
        }
        
        winAlert.addAction(acceptAction)
        winAlert.addAction(cancelAction)
        
        self.present(winAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - Buttons
    
    /**
     Reacts to a touch of the button called "Roll".
     It causes the dice make its animation, showing the player the roll that has achieved
     */
    @IBAction func rollDice(_ sender: UIButton) {
        if (acumulatedRolls.text == "0"){
            pickUpButton.isEnabled = true
        }
        var number = Int (arc4random_uniform(6)+1)
        
        self.dice.startAnimating()
        Timer.scheduledTimer(withTimeInterval: ANIMATION_TIME, repeats: false) { (Timer) in
            self.dice.stopAnimating()
            self.dice.image = self.dice.animationImages![number - 1]
            if (number != 1){
                number += Int (self.acumulatedRolls.text!)!
                self.acumulatedRolls.text = String (number)
            }else{
                self.changeTurn()
            }
        }
    }
    
    /**
     Reacts to a touch of the button called "PickUp".
     Accumulate in the overall score of the player the accumulated score in the current turn.
     Update the global score tag and progress bar of the current player
     */
    @IBAction func pickUpScore(_ sender: UIButton) {
        if (currentPlayer == 1){
            self.score = Int(self.acumulatedRolls.text!)! + Int(self.scoreP1.text!)!
            let progress: Float = (Float(score)/Float(100))
            self.progressP1.progress = progress
            self.scoreP1.text = String(score)
            if (score >= SCORE_TO_WIN){
                makeWinAlert()
            }else{
                changeTurn()
            }
        }else{
            self.score = Int(self.acumulatedRolls.text!)! + Int(self.scoreP2.text!)!
            let progress: Float = (Float(score)/Float(100))
            self.progressP2.progress = progress
            self.scoreP2.text = String(score)
            if (score >= SCORE_TO_WIN){
                makeWinAlert()
            }else{
                changeTurn()
            }
        }
    }
    
    // MARK: - Game Controls
    
    /**
     Make the necessary changes to make the change of turn between players
     */
    func changeTurn(){
        if (currentPlayer == 1){
            currentPlayer = 2
            playerName.text = NSLocalizedString("P2", comment: "Player name 2")
            playerName.textColor = UIColor.red
            acumulatedRolls.textColor = UIColor.red
            
        }else{
            currentPlayer = 1
            playerName.text = NSLocalizedString("P1", comment: "Player name 1")
            playerName.textColor = UIColor.blue
            acumulatedRolls.textColor = UIColor.blue
        }
        acumulatedRolls.text = "0"
        self.pickUpButton.isEnabled = false
        makeTurnAlert()
    }
    
    // MARK: - Preservation
    
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(currentPlayer, forKey: "currentPlayer")
        
        coder.encode(scoreP1.text, forKey: "scoreP1Text")
        coder.encode(scoreP2.text, forKey: "scoreP2Text")
        
        coder.encode(progressP1.progress, forKey: "progressP1")
        coder.encode(progressP2.progress, forKey: "progressP2")
        
        coder.encode(playerName.text, forKey: "playerName")
        coder.encode(acumulatedRolls.text, forKey: "acumulatedRolls")
        
        coder.encode(dice.image, forKey: "diceImage")
        
        coder.encode(firstTime, forKey: "firstTime")
        
        coder.encode(pickUpButton.isEnabled, forKey:"pickUpButtonState")
    }
    
    // MARK: - Restoration
    
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        currentPlayer = coder.decodeInteger(forKey: "currentPlayer")
        
        scoreP1.text = coder.decodeObject(forKey: "scoreP1Text") as? String
        scoreP2.text = coder.decodeObject(forKey: "scoreP2Text") as? String
        
        progressP1.progress = coder.decodeFloat(forKey: "progressP1")
        progressP2.progress = coder.decodeFloat(forKey: "progressP2")
        
        playerName.text = coder.decodeObject(forKey: "playerName") as? String
        acumulatedRolls.text = coder.decodeObject(forKey: "acumulatedRolls") as? String
        
        dice.image = coder.decodeObject(forKey: "diceImage") as? UIImage
        
        firstTime = coder.decodeBool(forKey: "firstTime")
        
        pickUpButton.isEnabled = coder.decodeBool(forKey: "pickUpButtonState")
        
    }
    
    
}
