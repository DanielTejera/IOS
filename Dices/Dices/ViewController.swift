//
//  ViewController.swift
//  Dices
//
//  Created by Alumno on 15/02/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var rulesText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.rulesText.text = NSLocalizedString("In the game two players take turns.\n \nAt each turn, a player repeatedly rolls a die, accumulating the score obtained on each roll until he rolls a 1 or decides to collect the accumulated score and add it to his overall score.\nThe player who first reaches 100 points in his overall score wins.\n \nIf the player with the turn draws a 1 in a roll, he loses the turn, which passes to the other player, and the accumulated score in that turn does not add up to his overall score.", comment: "Rules")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Unwind Segue
    
    /**
     Makes it possible to return to this screen from another where this unwindSegue is launched
     */
    @IBAction func unwindToRules(segue: UIStoryboardSegue) {}
    
}

