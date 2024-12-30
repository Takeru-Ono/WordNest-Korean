//
//  ViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 09.06.2024.
//
import UIKit
import AVFoundation

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

// QuizViewControllerDelegateプロトコルを作成
protocol QuizViewControllerDelegate: AnyObject {
    func quizCompleted(for category: String)
}

class ViewController: UIViewController, CorrectAnswerViewControllerDelegate, EndViewControllerDelegate {

    var questionLabel: UILabel!
    var playAudioButton: UIButton!
    var answerButtons: [UIButton] = []
    let questionContainerView = UIView()
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var questions: [QuestionProtocol] = []
    var selectedQuestions: [QuestionProtocol] = [] // 選択された10問
    var currentQuestionIndex = 0
    var category: String = "question_1_KoreanWordDictionary_noun_Basic"
    var language: String = "kr"
    var correctAnswersCount = 0
    let totalQuestions = 10
    var selectedQuizMode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // デバッグ用: selectedQuizModeの値を出力
//        print("selectedQuizMode: \(String(describing: selectedQuizMode))")
        setupUI() // UIをプログラムで構築
        loadQuestions()
        showQuestion()
    }

    // UIをプログラムで構築するメソッド
    func setupUI() {
        
        // 質問コンテナビューの設定
        questionContainerView.translatesAutoresizingMaskIntoConstraints = false
        questionContainerView.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white
        } // ダークモード: 薄いグレー、ライトモード: 白
        questionContainerView.layer.cornerRadius = 10
        questionContainerView.layer.borderColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }.cgColor // ダークモード: 白い枠線、ライトモード: 黒い枠線
        questionContainerView.layer.borderWidth = 1
        questionContainerView.layer.shadowColor = UIColor.black.cgColor
        questionContainerView.layer.shadowOpacity = 0.2
        questionContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        questionContainerView.layer.shadowRadius = 4
        view.addSubview(questionContainerView)
        
        // 1. 質問ラベルを追加（上部全体）
        questionLabel = UILabel()
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        questionLabel.numberOfLines = 0
        questionLabel.adjustsFontSizeToFitWidth = true // フォントサイズを自動調整
        questionLabel.minimumScaleFactor = 0.8 // 最小スケール（半分まで縮小）
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)
        
        // 2. 音声再生ボタンを追加（ラベルの横に配置）
        playAudioButton = UIButton(type: .system)
        playAudioButton.setTitle("", for: .normal)
        let audioIcon = UIImage(systemName: "speaker.wave.2.fill")
        playAudioButton.setImage(audioIcon, for: .normal)
        playAudioButton.tintColor = .systemBlue
        playAudioButton.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(playAudioButton)
        
        // 3. 選択肢のボタンを4つ追加（画面中央から下に分割して配置）
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            styleButton(button)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
            
            
            ButtonDesignUtility.addButtonAnimation(button, target: self, pressedAction: #selector(buttonPressed(_:)), releasedAction: #selector(buttonReleased(_:)))
            answerButtons.append(button)
            view.addSubview(button)
        }

        setupConstraints() // 制約を設定
    }

    // 制約を設定するメソッド
    func setupConstraints() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let horizontalSpacing: CGFloat = 20
        let verticalSpacing: CGFloat = 20

        // 横幅は2等分、中央から下の高さも2等分
        let buttonWidth = (screenWidth - 3 * horizontalSpacing) / 2
        let buttonHeight = (screenHeight / 2 - 3 * verticalSpacing) / 2 * 0.8

        // 質問コンテナビューを画面の上部1/3に配置
        NSLayoutConstraint.activate([
            questionContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // 上部に20ptの余白
            questionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            questionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
            questionContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33)
        ])

        // 質問ラベルの制約
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: questionContainerView.topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor),
            questionLabel.bottomAnchor.constraint(equalTo: questionContainerView.bottomAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: playAudioButton.leadingAnchor, constant: -10)
        ])

        // 音声再生ボタンの制約
        NSLayoutConstraint.activate([
            playAudioButton.centerYAnchor.constraint(equalTo: questionLabel.centerYAnchor),
            playAudioButton.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -10),
            playAudioButton.widthAnchor.constraint(equalToConstant: 50),
            playAudioButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 3. 2x2グリッドでボタンを配置
        let buttonContainerTop = screenHeight / 2 + verticalSpacing // 画面中央より少し下からスタート

        for (index, button) in answerButtons.enumerated() {
            let row = index / 2 // 0 or 1
            let column = index % 2 // 0 or 1

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight),
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing + CGFloat(column) * (buttonWidth + horizontalSpacing)),
                button.topAnchor.constraint(equalTo: view.topAnchor, constant: buttonContainerTop + CGFloat(row) * (buttonHeight + verticalSpacing))
            ])
        }
    }
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.systemGray4
        } // ダークモード: 暗めのグレー、ライトモード: 明るめのグレー
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }.cgColor // ダークモード: 白い枠線、ライトモード: 黒い枠線
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 4
        button.tintColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        } // ダークモード: 白文字、ライトモード: 黒文字
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byTruncatingTail
    }
    

    func loadQuestions() {
//        print("Loading CSV for category: \(category)")
        
        // データの読み込み
        questions = CSVLoader.loadCSV(from: category, forLanguage: language)
        
        // 質問が空でないかチェック
        if questions.isEmpty {
//            print("Failed to load questions from CSV or the file is empty")
            // 必要に応じて質問がない場合の処理
        } else {
            currentQuestionIndex = 0
            correctAnswersCount = 0
        }
    }

    // 質問を表示するメソッド
    func showQuestion() {
        guard currentQuestionIndex < totalQuestions else {
            showEndScreen()
            return
        }
        let question = questions[currentQuestionIndex]
        
        // 質問文を表示
        questionLabel.text = question.text
        
        var answers = question.choices
        answers.shuffle()  // シャッフルして選択肢をランダムに配置

        // ボタンに選択肢を設定
        for (index, button) in answerButtons.enumerated() {
            let answer = answers[index]
            button.setTitle(answer.0, for: .normal)
            
            // 正解のボタンには tag = 1、間違いには tag = 0 を設定
            button.tag = (answer.0 == question.correctAnswer) ? 1 : 0
            print("Button \(index + 1): \(answer.0) - Tag: \(button.tag)") // デバッグ: 各ボタンのタイトルとタグを出力
        }
        speakQuestionText(question.text)
    }

    // 音声再生ボタンが押された時の処理
    @objc func playAudioButtonTapped(_ sender: UIButton) {
        let question = questions[currentQuestionIndex]
        speakQuestionText(question.text)
    }

    // 選択肢ボタンがタップされたときの処理
    @objc func answerButtonTapped(_ sender: UIButton) {
//        print("Button tapped: \(sender.title(for: .normal) ?? "") - Tag: \(sender.tag)")
        
        // タグが 1 なら正解
        if sender.tag == 1 {
//            print("正解！")
            sender.backgroundColor = .systemGreen // 正解の場合は緑色
            showCorrectAnswer()
        } else {
//            print("不正解！")
            sender.backgroundColor = .systemRed // 不正解の場合は赤色
        }
    }

    func showCorrectAnswer() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let correctAnswerVC = storyboard.instantiateViewController(withIdentifier: "CorrectAnswerViewController") as? CorrectAnswerViewController {
            let question = questions[currentQuestionIndex]
            correctAnswerVC.correctChoice = (question.text, question.correctAnswer, question.correctEnglishName ?? "")
            correctAnswerVC.exampleSentence = (question.exampleSentence, question.exampleSentenceMeaning)


            var incorrectChoices = question.choices.filter { $0.0 != question.correctAnswer }
            incorrectChoices.shuffle()
            correctAnswerVC.incorrectChoices = Array(incorrectChoices.prefix(3))

            correctAnswerVC.delegate = self
            correctAnswerVC.modalPresentationStyle = .overCurrentContext
            present(correctAnswerVC, animated: true, completion: nil)
        } else {
//            print("Failed to instantiate CorrectAnswerViewController")
        }
    }
    
    func resetButtonColors() {
        for button in answerButtons {
            button.backgroundColor = .systemGray5 // デフォルトの色に戻す
            button.isEnabled = true // ボタンを有効化
        }
    }

    func moveToNextQuestion() {
        // ボタンの色をリセット
        resetButtonColors()
        currentQuestionIndex += 1
        

        if currentQuestionIndex >= selectedQuestions.count {
            showEndScreen()
        } else {
            showQuestion()
        }
    }

    func didCloseCorrectAnswerViewController() {
        moveToNextQuestion()
    }

    func speakQuestionText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        if language == "jp" {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        }
        speechSynthesizer.speak(utterance)
    }


    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }

    func showEndScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "EndViewController_Normal") as? EndViewController_Normal {
            endVC.correctAnswersCount = correctAnswersCount
            
            // `selectedQuizMode` を安全にアンラップして渡す
            if let quizMode = selectedQuizMode {
                endVC.selectedQuizMode = quizMode
            } else {
//                print("Error: selectedQuizMode is nil.")
                endVC.selectedQuizMode = "unknown_mode" // デフォルトのモードを設定
            }
            endVC.questions = questions
            endVC.modalPresentationStyle = .fullScreen
            endVC.delegate = self
            present(endVC, animated: true, completion: nil)

            // クイズが完了したので、回数と日付を保存
            saveQuizCompletionDate(for: category)
        }
    }

    func didCloseEndViewController() {
        loadQuestions()
        showQuestion()
    }

    func didReturnToHome() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }

    func saveQuizCompletionDate(for category: String) {
        guard let selectedQuizMode = selectedQuizMode else {
//            print("Error: selectedQuizMode is nil. Cannot save completion date.")
            return
        }

        let currentDate = Date()
        // 保存キーにクイズモードを含める
        let completionCountKey = "\(category)_\(selectedQuizMode)_completionCount"
        let completionDateKey = "\(category)_\(selectedQuizMode)_completionDate"
        
        var currentCompletionCount = UserDefaults.standard.integer(forKey: completionCountKey)
        currentCompletionCount += 1

        // 完了回数と日付を保存
        UserDefaults.standard.set(currentCompletionCount, forKey: completionCountKey)
        UserDefaults.standard.set(currentDate, forKey: completionDateKey)
//        print("Saving completion date with key: \(completionDateKey)")
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }
}
