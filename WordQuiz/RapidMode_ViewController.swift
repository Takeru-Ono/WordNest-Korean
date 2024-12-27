//
//  RapidModeJapanese_ViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/08/25.
//
import UIKit
import AVFoundation

class RapidMode_ViewController: UIViewController, EndViewControllerDelegate {
    

    var quizResults: [QuizResult] = []

    var questionLabel: UILabel!
    var playAudioButton: UIButton!
    var answerButtons: [UIButton] = []
    var speechSynthesizer = AVSpeechSynthesizer()
    let questionContainerView = UIView()
    var countdownLabel: UILabel! // カウントダウン用のラベルを宣言
    
    var questions: [QuestionProtocol] = [] // QuestionProtocolを使うことで、QuestionとQuestion_Jpの両方を扱える
    var selectedQuestions: [QuestionProtocol] = [] // 選択された10問
    var currentQuestionIndex = 0
    var category: String = "" // デフォルトカテゴリ
    var language: String = "kr" // クイズ形式を指定 ("kr" or "jp")
    var correctAnswersCount = 0
    let totalQuestions = 10
    var countdownTimer: Timer?
    var countdownDuration: TimeInterval = 2 // タイマーのデフォルト時間（秒）
    var isQuizEnded = false
    var selectedQuizMode: String?
    
    let countdownCircleLayer = CAShapeLayer() // 時計風の円形レイヤー
    let countdownCircleBackgroundLayer = CAShapeLayer() // 背景円

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserSettings()
        setupUI() // UIをプログラムで構築
        loadQuestions()
        showQuestion()
        print("selectedQuizMode: \(String(describing: selectedQuizMode))")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let circleRadius: CGFloat = 25 // 半径
        let circleCenter = CGPoint(x: questionContainerView.bounds.width - circleRadius - 20, y: circleRadius + 20) // コンテナの右上

        let circularPath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)

        // 背景の円の位置を更新
        countdownCircleBackgroundLayer.path = circularPath.cgPath
        // アニメーション用の円の位置を更新
        countdownCircleLayer.path = circularPath.cgPath
        // カウントダウンラベルの位置を更新
        countdownLabel.center = circleCenter
    }

    func loadUserSettings() {
        if let duration = UserDefaults.standard.value(forKey: "CountdownDuration") as? TimeInterval {
            countdownDuration = duration
        }
    }
    
    // UIをプログラムで構築するメソッド
    func setupUI() {
        // コンテナビューの作成
        questionContainerView.translatesAutoresizingMaskIntoConstraints = false
        questionContainerView.backgroundColor = .white // 背景色を白に変更
        questionContainerView.layer.cornerRadius = 10 // 角を丸める
        questionContainerView.layer.borderColor = UIColor.black.cgColor // 枠線を黒に
        questionContainerView.layer.borderWidth = 1 // 枠線を細くする
        questionContainerView.layer.shadowColor = UIColor.black.cgColor // 影の色を黒に
        questionContainerView.layer.shadowOpacity = 0.2 // 影の透明度（0.0~1.0）
        questionContainerView.layer.shadowOffset = CGSize(width: 2, height: 2) // 影の位置
        questionContainerView.layer.shadowRadius = 4 // 影のぼかし半径
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

            // アニメーションの追加
            ButtonDesignUtility.addButtonAnimation(button, target: self, pressedAction: #selector(buttonPressed(_:)), releasedAction: #selector(buttonReleased(_:)))

            answerButtons.append(button)
            view.addSubview(button)
        }

        // 背景の円
        countdownCircleBackgroundLayer.strokeColor = UIColor.lightGray.cgColor
        countdownCircleBackgroundLayer.fillColor = UIColor.clear.cgColor
        countdownCircleBackgroundLayer.lineWidth = 5
        questionContainerView.layer.addSublayer(countdownCircleBackgroundLayer)

        // アニメーション用の円
        countdownCircleLayer.strokeColor = UIColor.red.cgColor
        countdownCircleLayer.fillColor = UIColor.clear.cgColor
        countdownCircleLayer.lineWidth = 5
        countdownCircleLayer.lineCap = .round
        countdownCircleLayer.strokeEnd = 1.0
        questionContainerView.layer.addSublayer(countdownCircleLayer)

        // カウントダウンラベルの配置
        countdownLabel = UILabel()
        countdownLabel.text = "\(countdownDuration)"
        countdownLabel.font = UIFont.boldSystemFont(ofSize: 18)
        countdownLabel.textColor = .black
        countdownLabel.textAlignment = .center
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        questionContainerView.addSubview(countdownLabel)

        // ラベルの制約を円の中心に配置
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: questionContainerView.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: questionContainerView.centerYAnchor)
        ])

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

        // 音声再生ボタンを質問ラベルの右側に配置
        NSLayoutConstraint.activate([
            playAudioButton.centerYAnchor.constraint(equalTo: questionLabel.centerYAnchor), // 質問ラベルと同じ高さ
            playAudioButton.leadingAnchor.constraint(equalTo: questionLabel.trailingAnchor, constant: 10), // 質問ラベルの右側に10pt余白
            playAudioButton.trailingAnchor.constraint(lessThanOrEqualTo: questionContainerView.trailingAnchor, constant: -10), // コンテナの右端に余裕を持たせる
            playAudioButton.widthAnchor.constraint(equalToConstant: 40), // ボタンの幅
            playAudioButton.heightAnchor.constraint(equalToConstant: 40) // ボタンの高さ
        ])
        // カウントダウンラベルをコンテナの右上に配置
        NSLayoutConstraint.activate([
            countdownLabel.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -10),
            countdownLabel.topAnchor.constraint(equalTo: questionContainerView.topAnchor, constant: 10)
        ])

        // 3. 2x2グリッドでボタンを配置
        // 3. 選択肢ボタン（2×2グリッド）を中央から下に配置
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
        button.backgroundColor = .systemGray4 // ボタンの背景色
        button.layer.cornerRadius = 10 // 角を丸くする
        button.layer.borderWidth = 1 // 枠線の太さ
        button.layer.borderColor = UIColor.black.cgColor // 枠線の色
        button.layer.shadowColor = UIColor.black.cgColor // 影の色
        button.layer.shadowOpacity = 0.2 // 影の透明度
        button.layer.shadowOffset = CGSize(width: 2, height: 2) // 影の位置
        button.layer.shadowRadius = 4 // 影のぼかし半径
        button.tintColor = .black // テキストやアイコンの色
        
        // ボタンタイトルの文字数に応じてサイズを調整
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5 // 最小50%まで縮小
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byTruncatingTail // 収まりきらない場合は省略
    }

    // 質問をCSVからロードするメソッド
    func loadQuestions() {
        print("Loading CSV for category: \(category)")
        questions = CSVLoader.loadCSV(from: category, forLanguage: language) // QuestionProtocol型に統一
        questions.shuffle() // まず全体をシャッフル

        // 20問中から10問をランダムに選ぶ
        if questions.count > totalQuestions {
            selectedQuestions = Array(questions.prefix(totalQuestions))
        } else {
            selectedQuestions = questions // 質問が10問以下の場合、すべてを選択
        }

        currentQuestionIndex = 0
        correctAnswersCount = 0
        isQuizEnded = false // クイズ終了フラグをリセット
        print("Selected \(selectedQuestions.count) questions")

        if selectedQuestions.isEmpty {
            print("No questions loaded")
        }
    }

    // 質問を表示するメソッド
    func showQuestion() {
        guard currentQuestionIndex < totalQuestions else {
            showEndScreen()
            return
        }
        let question = selectedQuestions[currentQuestionIndex]
        
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
        startCountdown()
        speakQuestionText(question.text)
    }
    
    // ボタンに回答を設定するメソッド
    func configureButton(_ button: UIButton, with answer: (String, String, String)) {
        button.setTitle(answer.0, for: .normal)
        if let image = UIImage(named: answer.2) {
            let resizedImage = image.resized(to: CGSize(width: 40, height: 40))
            button.setImage(resizedImage, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.contentHorizontalAlignment = .left
        } else {
            button.setImage(nil, for: .normal)
        }
    }

    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // 押し込むアニメーション
        }
    }

    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity // 元に戻すアニメーション
        }
    }

    // 音声再生ボタンが押された時の処理
    @objc func playAudioButtonTapped(_ sender: UIButton) {
        let question = questions[currentQuestionIndex]
        speakQuestionText(question.text)
    }
    
    func saveResult(question: String, selectedAnswer: String, correctAnswer: String, isCorrect: Bool) {
        let result = QuizResult(question: question, isCorrect: isCorrect, selectedAnswer: selectedAnswer, correctAnswer: correctAnswer)
        quizResults.append(result)
    }



    @objc func answerButtonTapped(_ sender: UIButton) {
        // クイズ終了後は操作を無効化する
        guard !isQuizEnded else { return }
        
        countdownTimer?.invalidate()
        let isCorrect = sender.tag == 1
        
        if isCorrect {
            correctAnswersCount += 1
        }
        
        // 結果を保存
        if currentQuestionIndex < selectedQuestions.count {
            let currentQuestion = selectedQuestions[currentQuestionIndex]
            saveResult(
                question: currentQuestion.text,
                selectedAnswer: sender.title(for: .normal) ?? "",
                correctAnswer: currentQuestion.correctAnswer,
                isCorrect: isCorrect
            )
        }

        moveToNextQuestion()
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

        // クイズ終了後は次の問題に進まない
        if isQuizEnded { return }

        // 未選択状態を確認
        if currentQuestionIndex < selectedQuestions.count {
            let currentQuestion = selectedQuestions[currentQuestionIndex]

            // アンサーボタンが未選択の場合の処理
            let wasSelected = answerButtons.contains { $0.isHighlighted }
            if !wasSelected {
                saveResult(
                    question: currentQuestion.text,
                    selectedAnswer: "未選択", // 未選択の場合の特別な値
                    correctAnswer: currentQuestion.correctAnswer,
                    isCorrect: false // 未選択は不正解とする
                )
            }
        }

        currentQuestionIndex += 1

        if currentQuestionIndex >= totalQuestions {
            showEndScreen()
        } else {
            showQuestion()
        }
    }

    func speakQuestionText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        // 言語に応じた音声設定
        if language == "jp" {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        }
        speechSynthesizer.speak(utterance)
    }

    // クイズ終了時に呼び出される
    func showEndScreen() {
        isQuizEnded = true // クイズ終了フラグを設定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "EndViewController_Rapid") as? EndViewController_Rapid {
            
            endVC.correctAnswersCount = correctAnswersCount
            // `selectedQuizMode` を安全にアンラップして渡す
            if let quizMode = selectedQuizMode {
                endVC.selectedQuizMode = quizMode
            } else {
                print("Error: selectedQuizMode is nil.")
                endVC.selectedQuizMode = "unknown_mode" // デフォルトのモードを設定
            }
            endVC.quizResults = quizResults
            endVC.category = category // カテゴリをEndViewControllerに渡す
            endVC.questions = selectedQuestions
            endVC.modalPresentationStyle = .fullScreen
            endVC.delegate = self
            present(endVC, animated: true, completion: nil)
            
            // クイズが完了したので、次の復習日を保存
            saveQuizCompletionDate(for: category)
        }
    }

    func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        loadQuestions() // 新しい質問をロード
        showQuestion()  // 最初の質問を表示
    }

    func didCloseEndViewController() {
        resetQuiz()
    }

    func didReturnToHome() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }

    func startCountdown() {
        countdownTimer?.invalidate()
        var remainingTime = countdownDuration
        countdownLabel.text = String(format: "%.1f", remainingTime)

        // アニメーションの設定
        let countdownAnimation = CABasicAnimation(keyPath: "strokeEnd")
        countdownAnimation.fromValue = 1.0
        countdownAnimation.toValue = 0.0
        countdownAnimation.duration = countdownDuration
        countdownAnimation.fillMode = .forwards
        countdownAnimation.isRemovedOnCompletion = false
        countdownCircleLayer.add(countdownAnimation, forKey: "countdownAnimation")

        // タイマーで時間を更新
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            remainingTime -= 0.1
            self.countdownLabel.text = String(format: "%.1f", remainingTime)

            if remainingTime <= 0 {
                timer.invalidate()
                self.countdownLabel.text = "0.0" // 0.0に固定表示
                self.moveToNextQuestion()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
    }
    
    func saveQuizCompletionDate(for category: String) {
        guard let selectedQuizMode = selectedQuizMode else {
            print("Error: selectedQuizMode is nil. Cannot save completion date.")
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
        print("Saving completion date with key: \(completionDateKey)")
    }

}
