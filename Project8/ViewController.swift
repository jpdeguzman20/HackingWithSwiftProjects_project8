//
//  ViewController.swift
//  Project8
//
//  Created by Jonathan Deguzman on 11/30/16.
//  Copyright © 2016 Jonathan Deguzman. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0
    var level = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loop through all the views in our view controller (voew.subviews) and look only for the views with a tag of 1001. When found, we typecast that view as a UIButton and then append it to our buttons array.
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            // addTarget is the code way of Ctrl+dragging from a storyboard.
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }
    
    // Method to load the contents of each level into our screen
    func loadLevel() {
        // Variable to store the level's clues
        var clueString = ""
        // Variable to store how many letters each answer is
        var solutionString = ""
        // Array to store the letter groups
        var letterBits = [String]()
        
        // Get the file path of the level file I need to use and load it from the disk
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            // If it has contents, grab that too
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                // Store each line of its contents (separated by \n) into an array of Strings
                var lines = levelContents.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                
                // Using the enumerated method, go through each line and look for the colon and separate the line into 2 halves. Enumerated is useful for telling us where each item was in the array
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    // Store the first half as the answer
                    let answer = parts[0]
                    // Store the second half as the clue
                    let clue = parts[1]
                    
                    // Build the string to say 1-7 and its respective clues
                    clueString += "\(index + 1). \(clue)\n"
                    
                    // Get rid of the pipe symbol using the replacingOccurreneces method
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    // Store each 'letter bit' in our String array.
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        // Now configure the buttons and labels
        
        // Use the trimmingCharacters() method to get rid of white spaces and new lines
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Shuffle our buttons and letter groups
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        
        if letterBits.count == letterButtons.count {
            // From 0 up to but not including the number of buttons, set the name of the button to the letter bit
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    func letterTapped(btn: UIButton) {
        // Get the text from the title label of the button that was tapped and append it to the current text of the answer text field
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        // Append the button that was tapped to the activatedButtons array
        activatedButtons.append(btn)
        // Hide the button because it has already been used
        btn.isHidden = true
    }
    
    func levelUp(action: UIAlertAction!) {
        level += 1
        
        // clear the solutions array before filling it up with the solutions for the next level
        solutions.removeAll(keepingCapacity:  true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }

    @IBAction func submitTapped(_ sender: AnyObject) {
        // index(of:) method will tell us which solution matches the word submitted and returns the position in which it was found
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            // Split the answer label text by \n
            var splitClues = answersLabel.text!.components(separatedBy: "\n")
            // Replace the line at the solution position with the solution itself
            splitClues[solutionPosition] = currentAnswer.text!
            // Re-join the clues label back together
            answersLabel.text = splitClues.joined(separator: "\n")
            
            // Clear answer and update score
            currentAnswer.text = ""
            score += 1
            
            // If the user gets a score of 7, that means he/she has guessed all the answers correctly. Now, prompt the user to go the next level.
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }
    }
    
    @IBAction func clearTapped(_ sender: AnyObject) {
        // Remove the text from the answer text field
        currentAnswer.text = ""
        
        // Make all the buttons that were tapped visible again so that the user can use them
        for btn in activatedButtons {
            btn.isHidden = false
        }
    
        // Clear the activated buttons array
        activatedButtons.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

