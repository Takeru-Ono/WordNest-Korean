//
//  ViewController_Japanese.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/08/25.
//
import UIKit
import AVFoundation

protocol CorrectAnswerViewController_JPDelegate: AnyObject {
    func didCloseCorrectAnswerViewController()
}

class ViewController_JP: UIViewController, EndViewControllerDelegate, CorrectAnswerViewControllerDelegate_JP, CorrectAnswerViewControllerDelegate {
    func didCloseCorrectAnswerViewController() {
        // 正解表示画面が閉じられた時の処理
        moveToNextQuestion()
    }
    
    var normalModeTimer: Timer? // タイマー
    var startTime: Date? // タイマー開始時刻
    var timeTaken: TimeInterval = 0.0 // 回答時間を記録
    
    var incorrectAttempts = 0 // 間違いの回数
    var savedResults: [QuizResultData] = [] // 保存用クイズ結果
    

    var questionLabel: UILabel!
    var answerButtons: [UIButton] = []
    let questionContainerView = UIView()
    
    var speechSynthesizer = AVSpeechSynthesizer()
    var questions: [QuestionProtocol] = []
    var selectedQuestions: [QuestionProtocol] = [] // 選択された10問
    var currentQuestionIndex = 0
    var category: String = "question_1_KoreanWordDictionary_Noun_Basic"
    var language: String = "jp"
    var correctAnswersCount = 0
    let totalQuestions = 10
    var selectedQuizMode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI() // UIをプログラムで構築
        loadQuestions() // ビューがロードされたときに質問をロード
        showQuestion() // 最初の質問を表示
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
        
        
        // 2. 選択肢のボタンを4つ追加（画面中央から下に分割して配置）
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
            questionLabel.bottomAnchor.constraint(equalTo: questionContainerView.bottomAnchor)
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

    
    

    // 質問をロードするメソッド
    func loadQuestions() {
//        print("Loading CSV for category: \(category)")
        questions = CSVLoader.loadCSV(from: category, forLanguage: language)
        // 質問が空の場合の安全対策
        if questions.isEmpty {
            selectedQuestions = [] // 空の質問セット
        } else {
            // 質問数が10問未満でも動作するよう調整
            selectedQuestions = Array(questions.prefix(10)) // 最大10問選択
            currentQuestionIndex = 0
            correctAnswersCount = 0
        }
    }

    // 質問を表示するメソッド
    func showQuestion() {
        guard currentQuestionIndex < selectedQuestions.count else {
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
//            print("Button \(index + 1): \(answer.0) - Tag: \(button.tag)") // デバッグ: 各ボタンのタイトルとタグを出力
            

        }
        // タイマー開始
        startNormalModeTimer()
        incorrectAttempts = 0 // 間違い回数をリセット
        
    }
    
    // ボタンに回答を設定するメソッド
    func configureButton(_ button: UIButton, with answer: (String, String, String)) {
        if #available(iOS 15.0, *) {
            // iOS 15.0以降の新しい方法
            var config = UIButton.Configuration.plain()
            config.title = answer.0
            config.image = UIImage(named: answer.2)?.resized(to: CGSize(width: 40, height: 40))
            config.imagePlacement = .leading // アイコンを左側に配置
            config.imagePadding = 10 // アイコンとテキストの間隔を設定
            button.configuration = config
        } else {
            // iOS 15.0未満の従来の方法
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
    }
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc func buttonTouchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }
    



    // 選択肢ボタンがタップされたときの処理
    @objc func answerButtonTapped(_ sender: UIButton) {
//        print("Button tapped: \(sender.title(for: .normal) ?? "") - Tag: \(sender.tag)")
        guard let startTime = startTime else { return }
        
        // ボタンのタイトル（選択肢の韓国語）を取得
        if let buttonTitle = sender.title(for: .normal) {
            // 選択肢の韓国語を音声再生
            playSpeech(for: buttonTitle, language: "ko-KR")
        }

        
        // タグが 1 なら正解
        if sender.tag == 1 {
            // タイマーを停止
            normalModeTimer?.invalidate()
//            print("正解！")
            sender.backgroundColor = .systemGreen // 正解の場合は緑色
            
            let timeTaken = Date().timeIntervalSince(startTime)

            // 結果を記録
            saveQuizResult(
                question: selectedQuestions[currentQuestionIndex].text,
                selectedAnswer: sender.title(for: .normal) ?? "",
                correctAnswer: selectedQuestions[currentQuestionIndex].correctAnswer,
                isCorrect: true,
                timeTaken: timeTaken,
                incorrectAttempts: incorrectAttempts
            )
            showCorrectAnswer()
        } else {
//            print("不正解！")
            sender.backgroundColor = .systemRed // 不正解の場合は赤色
            incorrectAttempts += 1
        }
    }
    
    // 韓国語の音声再生を行うメソッド
    func playSpeech(for text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language) // 言語コードを指定（韓国語は "ko-KR"）
//        utterance.rate = 0.5 // 再生速度を調整
        speechSynthesizer.speak(utterance)
    }

    func showCorrectAnswer() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let correctAnswerVC = storyboard.instantiateViewController(withIdentifier: "CorrectAnswerViewController_JP") as? CorrectAnswerViewController_JP {
            let question = questions[currentQuestionIndex]
            correctAnswerVC.correctChoice = (question.text, question.correctAnswer, question.correctEnglishName ?? "")
            correctAnswerVC.exampleSentence = (question.exampleSentence, question.exampleSentenceMeaning)

            var incorrectChoices = question.choices.filter { $0.0 != question.correctAnswer }
            incorrectChoices.shuffle()
            correctAnswerVC.incorrectChoices = Array(incorrectChoices.prefix(3))
            correctAnswerVC.delegateJP = self
            correctAnswerVC.modalPresentationStyle = .overCurrentContext
            present(correctAnswerVC, animated: true, completion: nil)
        } else {
//            print("Failed to instantiate CorrectAnswerViewController_JP")
        }
    }
    
    func resetButtonColors() {
        for button in answerButtons {
            button.backgroundColor = .systemGray5 // デフォルトの色に戻す
            button.isEnabled = true // ボタンを有効化
        }
    }


    func moveToNextQuestion() {
        normalModeTimer?.invalidate()
        // ボタンの色をリセット
        resetButtonColors()
//        print("moveToNextQuestion called, current index: \(currentQuestionIndex)")
        currentQuestionIndex += 1

        if currentQuestionIndex >= selectedQuestions.count {
//            print("Quiz Ended")
            showEndScreen()
        } else {
            showQuestion()
        }
    }

    func didCloseCorrectAnswerViewControllerJP() {
        moveToNextQuestion()
    }

    @objc func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }

    func showEndScreen() {
        saveResultsToJSON()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "EndViewController_JP_Normal") as? EndViewController_JP_Normal {
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
            
            // クイズが完了したので、次の復習日を保存
            saveQuizCompletionDate(for: category)
        }
    }

    // EndViewControllerから戻ってきたときの処理
    func didCloseEndViewController() {
        loadQuestions()
        showQuestion()
    }

    func didReturnToHome() {
        // ホームに戻る処理をここに追加
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
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // 押し込むアニメーション
        }
    }

    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity // 元に戻すアニメーション
        }
    }
    
    func saveQuizResult(question: String, selectedAnswer: String, correctAnswer: String, isCorrect: Bool, timeTaken: TimeInterval, incorrectAttempts: Int) {
        let result = QuizResultData(
            question: question,
            selectedAnswer: selectedAnswer,
            correctAnswer: correctAnswer,
            isCorrect: isCorrect,
            timeTaken: timeTaken,
            incorrectAttempts: incorrectAttempts
        )
        savedResults.append(result)
    }
    
    func saveQuizCompletionDetails(for category: String) -> (completionDate: Date, completionCount: Int) {
        let currentDate = Date()
        let completionCountKey = "\(category)_completionCount"
        let completionDateKey = "\(category)_completionDate"

        // 現在の回数を取得して1加算
        var currentCompletionCount = UserDefaults.standard.integer(forKey: completionCountKey)
        currentCompletionCount += 1

        // 完了回数と日付を保存
        UserDefaults.standard.set(currentCompletionCount, forKey: completionCountKey)
        UserDefaults.standard.set(currentDate, forKey: completionDateKey)

        return (completionDate: currentDate, completionCount: currentCompletionCount)
    }
    
    func saveResultsToJSON() {
        // 日付と回数を取得
        let completionDetails = saveQuizCompletionDetails(for: category)

        // 保存するデータを構築
        let savedQuizResult = SavedQuizResult(
            mode: selectedQuizMode ?? "unknown_mode", // クイズモード
            category: category,                      // カテゴリ
            completionDate: completionDetails.completionDate, // 完了日付
            completionCount: completionDetails.completionCount, // 実行回数
            results: savedResults                   // クイズ結果
        )
        
        let fileURL = getResultsFileURL()

        do {
            let jsonData = try JSONEncoder().encode(savedQuizResult)
            try jsonData.write(to: fileURL)
//            print("Quiz results saved to: \(fileURL)")
        } catch {
//            print("Error saving quiz results: \(error)")
        }
    }
    
    func getResultsFileURL() -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("quiz_results_Normal_jp_kr.json")
    }
    func startNormalModeTimer() {
        normalModeTimer?.invalidate() // 既存のタイマーを無効化
        startTime = Date() // 現在時刻を記録

        // タイマーを一定間隔で更新
        normalModeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.startTime else { return }
            self.timeTaken = Date().timeIntervalSince(startTime) // 経過時間を計算
        }
    }

}
