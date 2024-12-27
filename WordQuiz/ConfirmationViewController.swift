//
//  ConfirmationViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/07/10.
//
import UIKit

class ConfirmationViewController: UIViewController {
    

    @IBOutlet weak var countdownSlider: UISlider!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var skipConfirmationSwitch: UISwitch!
    
    var totalQuestions: Int = 0
    var selectedCategory: String = ""
    var countdownDuration: TimeInterval = 2.0


    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedDuration = UserDefaults.standard.value(forKey: "CountdownDuration") as? TimeInterval {
            countdownDuration = savedDuration
        }

        countdownSlider.minimumValue = 1.0
        countdownSlider.maximumValue = 10.0
        countdownSlider.value = Float(countdownDuration)
        updateCountdownLabel()
        
        countdownSlider.addTarget(self, action: #selector(countdownSliderValueChanged(_:)), for: .valueChanged)
    }



    @objc func countdownSliderValueChanged(_ sender: UISlider) {
        sender.value = round(sender.value)
        countdownDuration = TimeInterval(sender.value)
        updateCountdownLabel()
    }

    func updateCountdownLabel() {
        countdownLabel.text = String(format: "Countdown: %.0f seconds", countdownDuration)
    }

    @IBAction func startQuizButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(countdownDuration, forKey: "CountdownDuration")
        UserDefaults.standard.set(skipConfirmationSwitch.isOn, forKey: "SkipConfirmation")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let quizVC = storyboard.instantiateViewController(withIdentifier: "RapidMode_ViewController") as? RapidMode_ViewController {
            quizVC.category = selectedCategory
            quizVC.countdownDuration = countdownDuration
            self.navigationController?.pushViewController(quizVC, animated: true)
        }
    }
    
}
