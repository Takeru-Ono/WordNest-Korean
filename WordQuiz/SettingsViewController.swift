//
//  SettingViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/07/03.
//
import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didSelectDesign(forCategory category: String)
}

class SettingsViewController: UIViewController {
    weak var delegate: SettingsViewControllerDelegate?
    // RapidMode用スライダーとラベル
    private let countdownLabel = UILabel()
    private let countdownSlider = UISlider()
    
    // NumberQuiz用スライダーとラベル
    private let numberQuizLabel = UILabel()
    private let numberQuizSlider = UISlider()
    
    // 設定値
    private var countdownDuration: TimeInterval = 4.0 // RapidModeのデフォルト値
    private var numberQuizDuration: TimeInterval = 4.0 // NumberQuizのデフォルト値

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        loadSavedSettings()
    }
    
    // UI構築
    private func setupUI() {

        // RapidModeのラベル
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)
        
        // RapidModeのスライダー
        countdownSlider.minimumValue = 2.0
        countdownSlider.maximumValue = 10.0
        countdownSlider.translatesAutoresizingMaskIntoConstraints = false
        countdownSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(countdownSlider)
        
        // NumberQuizのラベル
        numberQuizLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numberQuizLabel)
        
        // NumberQuizのスライダー
        numberQuizSlider.minimumValue = 2.0
        numberQuizSlider.maximumValue = 10.0
        numberQuizSlider.translatesAutoresizingMaskIntoConstraints = false
        numberQuizSlider.addTarget(self, action: #selector(numberQuizSliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(numberQuizSlider)
        
        // レイアウト設定
        setupConstraints()
    }
    
    // レイアウトの制約を追加
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // RapidModeラベル
            countdownLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countdownLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            // RapidModeスライダー
            countdownSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countdownSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            countdownSlider.topAnchor.constraint(equalTo: countdownLabel.bottomAnchor, constant: 10),
            
            // NumberQuizラベル
            numberQuizLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberQuizLabel.topAnchor.constraint(equalTo: countdownSlider.bottomAnchor, constant: 40),
            
            // NumberQuizスライダー
            numberQuizSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            numberQuizSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberQuizSlider.topAnchor.constraint(equalTo: numberQuizLabel.bottomAnchor, constant: 10)
        ])
    }
    
    // 保存されている設定値を読み込み
    private func loadSavedSettings() {

        // RapidMode設定
        if let savedDuration = UserDefaults.standard.value(forKey: "CountdownDuration") as? TimeInterval {
            countdownDuration = savedDuration
        }
        countdownSlider.value = Float(countdownDuration)
        updateCountdownLabel()
        
        // NumberQuiz設定
        if let savedNumberQuizDuration = UserDefaults.standard.value(forKey: "NumberQuizDuration") as? TimeInterval {
            numberQuizDuration = savedNumberQuizDuration
        }
        numberQuizSlider.value = Float(numberQuizDuration)
        updateNumberQuizLabel()
    }
    
    
    // RapidModeスライダー値変更アクション
    @objc private func sliderValueChanged(_ sender: UISlider) {
        sender.value = round(sender.value)
        countdownDuration = TimeInterval(sender.value)
        updateCountdownLabel()
        UserDefaults.standard.set(countdownDuration, forKey: "CountdownDuration")
    }
    
    // NumberQuizスライダー値変更アクション
    @objc private func numberQuizSliderValueChanged(_ sender: UISlider) {
        sender.value = round(sender.value)
        numberQuizDuration = TimeInterval(sender.value)
        updateNumberQuizLabel()
        UserDefaults.standard.set(numberQuizDuration, forKey: "NumberQuizDuration")
    }
    
    // RapidModeラベル更新
    private func updateCountdownLabel() {
        countdownLabel.text = String(format: "タイムアタック制限時間: %.0f 秒", countdownDuration)
    }
    
    // NumberQuizラベル更新
    private func updateNumberQuizLabel() {
        numberQuizLabel.text = String(format: "数字クイズ制限時間: %.0f 秒", numberQuizDuration)
    }
}
