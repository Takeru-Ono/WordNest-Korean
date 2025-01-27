//
//  NumberEndViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/09/01.
//
import UIKit
import AVFoundation

// Delegate Protocol
protocol NumberEndViewControllerDelegate: AnyObject {
    func didCloseEndViewController()
    func didReturnToHome()
}

class NumberEndViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: NumberEndViewControllerDelegate?
    
    // UI要素
    var resultLabel: UILabel!
    var tableView: UITableView!
    var restartButton: UIButton!
    var returnHomeButton: UIButton!
    var quizResults: [QuizResult] = []
    
    var correctAnswersCount: Int = 0
    var questions: [QuestionProtocol] = [] // 出題された問題リスト
    var selectedQuizMode: String? // クイズモードを保存
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UIをセットアップ
    }
    
    func setupUI() {
        // 結果ラベル
        resultLabel = UILabel()
        resultLabel.text = " \(correctAnswersCount) 問正解しました！"
        resultLabel.font = UIFont.boldSystemFont(ofSize: 24)
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0 // 行数を無制限に
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultLabel)
        
        // テーブルビュー
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NumberQuestionTableViewCell.self, forCellReuseIdentifier: "QuestionTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // クイズ再スタートボタン
        restartButton = UIButton(type: .system)
        restartButton.setTitle("カテゴリー選択に戻る", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        restartButton.addTarget(self, action: #selector(restartQuiz), for: .touchUpInside)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(restartButton)
        
        // ホームに戻るボタン
        returnHomeButton = UIButton(type: .system)
        returnHomeButton.setTitle("ホームに戻る", for: .normal)
        returnHomeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        returnHomeButton.addTarget(self, action: #selector(returnToHome), for: .touchUpInside)
        returnHomeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(returnHomeButton)
        
        setupConstraints() // 制約を設定
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: -20),
            
            restartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            restartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            restartButton.bottomAnchor.constraint(equalTo: returnHomeButton.topAnchor, constant: -20),
            restartButton.heightAnchor.constraint(equalToConstant: 44),
            
            returnHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            returnHomeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            returnHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            returnHomeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath) as? NumberQuestionTableViewCell else {
            fatalError("Failed to dequeue QuestionTableViewCell")
        }
        
        let quizResult = quizResults[indexPath.row]
        cell.selectedQuizMode = selectedQuizMode // モードをセルに渡す
        cell.configureCell(with: quizResult)
        
        return cell
    }
    
    @objc func restartQuiz() {
        self.view.window?.rootViewController?.dismiss(animated: true) {
            // iOS 15以降で推奨される方法
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let navigationController = windowScene.windows.first?.rootViewController as? UINavigationController {
                for viewController in navigationController.viewControllers {
                    if viewController is SelectNumberCategoryViewController {
                        navigationController.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    @objc func returnToHome() {
        self.view.window?.rootViewController?.dismiss(animated: true) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewController") {
                    let navigationController = UINavigationController(rootViewController: firstVC)
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
}

// カスタムセルの設定
class NumberQuestionTableViewCell: UITableViewCell {
    var statusLabel = UILabel()
    var questionLabel: UILabel!
    var answerLabel: UILabel!
    var playAudioButton: UIButton!
    var speechSynthesizer = AVSpeechSynthesizer()
    
    var selectedQuizMode: String? // クイズモードを格納
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellUI()
    }
    
    func setupCellUI() {
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        questionLabel = UILabel()
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        questionLabel.numberOfLines = 0
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(questionLabel)
        
        answerLabel = UILabel()
        answerLabel.font = UIFont.systemFont(ofSize: 16)
        answerLabel.numberOfLines = 0
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(answerLabel)
        
        // 音声再生ボタン
        playAudioButton = UIButton(type: .system)
        playAudioButton.setTitle("", for: .normal)
        playAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        playAudioButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playAudioButton)
        
        NSLayoutConstraint.activate([
            // まるばつ表示
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 30), // 固定された位置に配置
            statusLabel.widthAnchor.constraint(equalToConstant: 30),
            statusLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // QuestionLabelをStatusLabelの右に配置
            questionLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 10),
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
            answerLabel.leadingAnchor.constraint(equalTo: questionLabel.leadingAnchor), // 修正箇所
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            playAudioButton.centerYAnchor.constraint(equalTo: answerLabel.centerYAnchor),
            playAudioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            playAudioButton.widthAnchor.constraint(equalToConstant: 24),
            playAudioButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configureCell(with result: QuizResult) {
        statusLabel.text = result.isCorrect ? "O" : "X"
        statusLabel.textColor = result.isCorrect ? .systemGreen : .systemRed

        questionLabel.text = "Q: \(result.question)"
        answerLabel.text = "A: \(result.correctAnswer)"
        
        if let mode = selectedQuizMode {
            if mode.contains("kr_jp") {
                // 韓国語の質問文を再生
                playAudioButton.accessibilityHint = result.question
            } else if mode.contains("jp_kr") {
                // 韓国語の答えを再生
                playAudioButton.accessibilityHint = result.correctAnswer
            }
        } else {
            playAudioButton.accessibilityHint = nil // モード不明時のデフォルト
        }
//        print("Selected Quiz Mode in Cell: \(selectedQuizMode ?? "None")")
//        print("Accessibility Hint in Cell: \(playAudioButton.accessibilityHint ?? "None")")
    }

    @objc func playAudio(_ sender: UIButton) {
        // ボタンから直接データを取得
        guard let textToSpeak = sender.accessibilityHint, !textToSpeak.isEmpty else {
//            print("Error: No text to speak.")
            return
        }

        // 言語を韓国語に固定
        let language = "ko-KR"

//        print("Text to Speak: '\(textToSpeak)', Language: '\(language)'")

        // 読み上げ処理
        let utterance = AVSpeechUtterance(string: textToSpeak)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5 // 読み上げ速度を調整
        speechSynthesizer.stopSpeaking(at: .immediate) // 既存の音声再生を停止
        speechSynthesizer.speak(utterance)
    }
}
