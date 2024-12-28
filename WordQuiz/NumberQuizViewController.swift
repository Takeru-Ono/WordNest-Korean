//
//  DateQuestionViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/08/27.
//
import UIKit
import AVFoundation

struct DateTimeQuestion: QuestionProtocol {
    var text: String
    var correctAnswer: String
    var correctEnglishName: String?
    var exampleSentence: String
    var exampleSentenceMeaning: String
    var exampleSentenceMeaningEnglish: String? // オプショナル
    var correctHiragana: String? // オプショナル
    var choices: [(String, String, String)] // 初期値で空に設定

    init(question: String, correctAnswer: String, correctEnglishName: String? = nil) {
        self.text = question
        self.correctAnswer = correctAnswer
        self.correctEnglishName = nil
        self.exampleSentence = ""
        self.exampleSentenceMeaning = ""
        self.exampleSentenceMeaningEnglish = nil
        self.correctHiragana = nil
        self.choices = [] // 選択肢が不要なら空配列
    }
}

class NumberQuizViewController: UIViewController {

    // UI要素
    var questionLabel: UILabel!
    var answerButtons: [UIButton] = []
    var playAudioButton: UIButton!
    var countdownLabel: UILabel!
    let questionContainerView = UIView()
    // ボタン配列
    var buttons: [UIButton] = []
    var quizResults: [QuizResult] = []

    // クイズの設定変数
    var selectedQuizMode: String?
    var correctAnswer: String = ""
    var correctAnswersCount: Int = 0
    var totalQuestions: Int = 10
    var currentQuestionIndex: Int = 0
    var questions: [QuestionProtocol] = []
    var speechSynthesizer = AVSpeechSynthesizer()
    var countdownTimer: Timer?
    var countdownDuration: TimeInterval = 2.0
    
    let countdownCircleLayer = CAShapeLayer() // 時計風の円形レイヤー
    let countdownCircleBackgroundLayer = CAShapeLayer() // 背景円

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate() // 画面が閉じられたときにタイマーを無効化
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // UIをプログラムで構築
        loadUserSettings()
        generateQuestion()
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
        updateQuestionLabelFontSize()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
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
        
        // 質問ラベル
        questionLabel = UILabel()
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)    // 他の設定はそのままで、質問ラベルに以下を追加
        questionLabel.adjustsFontSizeToFitWidth = true // フォントサイズを自動調整
        questionLabel.minimumScaleFactor = 0.5 // 最小フォントスケール（50%まで縮小）
        
        questionLabel.numberOfLines = 0
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)
        
        // カウントダウンラベル
        countdownLabel = UILabel()
        countdownLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        countdownLabel.textColor = .red
        countdownLabel.textAlignment = .center
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countdownLabel)
        
        // 音声再生ボタン
        playAudioButton = UIButton(type: .system)
        playAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton.tintColor = .systemBlue
        playAudioButton.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        view.addSubview(playAudioButton)
        
        // 答えのボタン
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            styleButton(button)
            button.layer.borderColor = UIColor.black.cgColor // ボタンに枠を設定
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)

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
        // レイアウトの制約
        setupConstraints()
        updateQuestionLabelFontSize()
    }
    
    func updateQuestionLabelFontSize() {
        // 質問コンテナの幅に基づいてフォントサイズを調整
        let maxFontSize: CGFloat = 50 // 最大フォントサイズ
        let minFontSize: CGFloat = 10 // 最小フォントサイズ

        guard let text = questionLabel.text else { return }

        let labelWidth = questionContainerView.bounds.width - 20 // コンテナの幅からマージンを引く
        let labelHeight = questionContainerView.bounds.height - 20 // コンテナの高さからマージンを引く

        var fontSize = maxFontSize

        // テキストが収まるフォントサイズを探す
        while fontSize > minFontSize {
            let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            let textSize = text.size(withAttributes: [.font: font])

            if textSize.width <= labelWidth && textSize.height <= labelHeight {
                break
            }
            fontSize -= 1
        }

        // フォントサイズを設定
        questionLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
    
    func updatePlayAudioButtonVisibility() {
        // クイズモードに応じて音声ボタンの表示を切り替える
        if selectedQuizMode?.contains("jp_kr") == true {
            playAudioButton.isHidden = true // 日本語から韓国語の場合は隠す
        } else {
            playAudioButton.isHidden = false // それ以外は表示
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

        // 質問ラベルの制約をコンテナの中央に配置
        NSLayoutConstraint.activate([
            questionLabel.centerXAnchor.constraint(equalTo: questionContainerView.centerXAnchor),
            questionLabel.centerYAnchor.constraint(equalTo: questionContainerView.centerYAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -10)
        ])

        // 音声再生ボタンを質問ラベルの真下に配置
        NSLayoutConstraint.activate([
            playAudioButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10), // 質問ラベルの真下に10ptの余白
            playAudioButton.centerXAnchor.constraint(equalTo: questionLabel.centerXAnchor), // 質問ラベルと水平中央を揃える
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
    
    func setAnswerButtons(with answers: [String]) {
        // ボタンがある場合は再利用し、ない場合は新規作成
        for (index, answer) in answers.enumerated() {
            let button: UIButton
            if index < answerButtons.count {
                button = answerButtons[index]
            } else {
                button = UIButton(type: .system)
                button.layer.cornerRadius = 8
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.systemBlue.cgColor
                button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
                answerButtons.append(button)
                view.addSubview(button)
            }
            button.setTitle(answer, for: .normal)
        }
        setupConstraints() // ボタンの配置を更新
    }
    
    func loadUserSettings() {
        if let savedDuration = UserDefaults.standard.value(forKey: "NumberQuizDuration") as? TimeInterval {
            countdownDuration = savedDuration
        }
    }
    


    func generateQuestion() {
        // 音声ボタンの表示・非表示を更新
        updatePlayAudioButtonVisibility()
        if selectedQuizMode?.contains("SequentialNumbers") == true {
            if currentQuestionIndex >= 103 {
                showEndView()
                return
            }
            generateSequentialNumberQuestion()
        } else if selectedQuizMode?.contains("NativeKoreanNumbers") == true {
            if currentQuestionIndex >= 99 {
                showEndView()
                return
            }
            generateNativeKoreanNumberQuestion()
        } else {
            if currentQuestionIndex >= totalQuestions {
                showEndView()
                return
            }
            if selectedQuizMode?.contains("Date") == true {
                generateDateQuestion()
            } else if selectedQuizMode?.contains("Time") == true {
                generateTimeQuestion()
            } else if selectedQuizMode?.contains("LargeNumbers") == true {
                generateLargeNumberQuestion()
            } else if selectedQuizMode?.contains("KoreanCounter") == true {
                generateKoreanCounterQuiz()
            }
        }
        autoPlayAudioIfNeeded()
        startQuizCountdown()
    }

    @objc func answerButtonTapped(_ sender: UIButton) {
        // クイズ終了後は操作を無効化する
        countdownTimer?.invalidate()
        
        let isCorrect = sender.title(for: .normal) == correctAnswer
        
        if isCorrect {
            correctAnswersCount += 1
        }

        // 結果を保存
        let currentQuestionText = questionLabel.text ?? ""
        let selectedAnswer = sender.title(for: .normal) ?? ""
        let result = QuizResult(
            question: currentQuestionText,
            isCorrect: isCorrect,
            selectedAnswer: selectedAnswer,
            correctAnswer: correctAnswer
        )
        quizResults.append(result)
        
        generateQuestion()
        enableAnswerButtons()
    }

    @objc func playAudio() {
        let utterance = AVSpeechUtterance(string: questionLabel.text ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: selectedQuizMode?.contains("kr_jp") == true ? "ko-KR" : "ja-JP")
        speechSynthesizer.speak(utterance)
    }

    func showEndView() {
        // クイズの最後の状態で未選択を記録
        if countdownTimer?.isValid == true {
            recordUnselectedAnswer()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let endVC = storyboard.instantiateViewController(withIdentifier: "NumberEndViewController") as? NumberEndViewController {
            endVC.correctAnswersCount = correctAnswersCount
            endVC.questions = questions
            endVC.quizResults = quizResults 
            // `selectedQuizMode` を安全にアンラップして渡す
            if let quizMode = selectedQuizMode {
                endVC.selectedQuizMode = quizMode
            } else {
//                print("Error: selectedQuizMode is nil.")
                endVC.selectedQuizMode = "unknown_mode" // デフォルトのモードを設定
            }
            
            endVC.modalPresentationStyle = .fullScreen
            present(endVC, animated: true, completion: nil)
        }
    }

    func disableAnswerButtons() {
        answerButtons.forEach { $0.isEnabled = false }
    }

    func enableAnswerButtons() {
        answerButtons.forEach { $0.isEnabled = true }
    }
    
    func autoPlayAudioIfNeeded() {
        if selectedQuizMode?.contains("kr_jp") == true {
            playAudio()
        }
    }

    func startQuizCountdown() {
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
                // 未選択の場合の処理
                self.recordUnselectedAnswer()
                self.generateQuestion() // 次の問題を表示
            }
        }
    }
    
    func recordUnselectedAnswer() {
        // 質問文を取得
        let currentQuestionText = questionLabel.text ?? ""
        
        // 結果を保存
        let result = QuizResult(
            question: currentQuestionText,
            isCorrect: false, // 未選択は不正解とする
            selectedAnswer: "未選択",
            correctAnswer: correctAnswer
        )
        quizResults.append(result)
//        print("Recorded unselected answer for question: \(currentQuestionText)")
    }
    
    // 各クイズ生成メソッド
    func generateSequentialNumberQuestion() {
        // 韓国語の1〜99、100、1000、10000までの数え方を定義
        let koreanNumbers = ["열", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구", "십", "십일", "십이", "십삼", "십사", "십오", "십육", "십칠", "십팔", "십구", "이십", "이십일", "이십이", "이십삼", "이십사", "이십오", "이십육", "이십칠", "이십팔", "이십구", "삼십", "삼십일", "삼십이", "삼십삼", "삼십사", "삼십오", "삼십육", "삼십칠", "삼십팔", "삼십구", "사십", "사십일", "사십이", "사십삼", "사십사", "사십오", "사십육", "사십칠", "사십팔", "사십구", "오십", "오십일", "오십이", "오십삼", "오십사", "오십오", "오십육", "오십칠", "오십팔", "오십구", "육십", "육십일", "육십이", "육십삼", "육십사", "육십오", "육십육", "육십칠", "육십팔", "육십구", "칠십", "칠십일", "칠십이", "칠십삼", "칠십사", "칠십오", "칠십육", "칠십칠", "칠십팔", "칠십구", "팔십", "팔십일", "팔십이", "팔십삼", "팔십사", "팔십오", "팔십육", "팔십칠", "팔십팔", "팔십구", "구십", "구십일", "구십이", "구십삼", "구십사", "구십오", "구십육", "구십칠", "구십팔", "구십구", "백", "천", "만"]
        
        // 日本語の1〜99、100、1000、10000までの数え方を定義
        let japaneseNumbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "1000", "10000"]
        
        // 現在の出題するインデックスを生成
        let currentIndex = currentQuestionIndex % koreanNumbers.count
        
        var questionText = ""
        
        // 韓国語から日本語へのクイズ
        if selectedQuizMode?.contains("kr_jp") == true {
            questionText = koreanNumbers[currentIndex] // 韓国語で出題
            correctAnswer = japaneseNumbers[currentIndex] // 正解は日本語
            // ダミーなし、全て正解の回答が表示される
            let answers = [correctAnswer, correctAnswer, correctAnswer, correctAnswer]
            setAnswerButtons(with: answers)
            
        // 日本語から韓国語へのクイズ
        } else if selectedQuizMode?.contains("jp_kr") == true {
            questionText = japaneseNumbers[currentIndex] // 日本語で出題
            correctAnswer = koreanNumbers[currentIndex]  // 正解は韓国語
            
            // ランダムにダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyIndex = Int.random(in: 0..<koreanNumbers.count)
                let dummyAnswer = koreanNumbers[randomDummyIndex]
                if !answers.contains(dummyAnswer) {
                    answers.append(dummyAnswer)
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
        }
        
        questionLabel.text = questionText
        // ここで問題を追加してEndViewで使用できるようにする
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer, correctEnglishName: nil)
        questions.append(question)

        currentQuestionIndex += 1
    }
    func generateNativeKoreanNumberQuestion() {
        // 固有の韓国語の数字を定義
        // Korean native numbers 1〜99
        let koreanNumbers = [
            "하나","둘","셋","넷","다섯","여섯","일곱","여덟","아홉","열",               // 1〜10
            "열하나","열둘","열셋","열넷","열다섯","열여섯","열일곱","열여덟","열아홉",  // 11〜19
            "스물","스물하나","스물둘","스물셋","스물넷","스물다섯","스물여섯","스물일곱","스물여덟","스물아홉", // 20〜29
            "서른","서른하나","서른둘","서른셋","서른넷","서른다섯","서른여섯","서른일곱","서른여덟","서른아홉", // 30〜39
            "마흔","마흔하나","마흔둘","마흔셋","마흔넷","마흔다섯","마흔여섯","마흔일곱","마흔여덟","마흔아홉", // 40〜49
            "쉰","쉰하나","쉰둘","쉰셋","쉰넷","쉰다섯","쉰여섯","쉰일곱","쉰여덟","쉰아홉", // 50〜59
            "예순","예순하나","예순둘","예순셋","예순넷","예순다섯","예순여섯","예순일곱","예순여덟","예순아홉", // 60〜69
            "일흔","일흔하나","일흔둘","일흔셋","일흔넷","일흔다섯","일흔여섯","일흔일곱","일흔여덟","일흔아홉", // 70〜79
            "여든","여든하나","여든둘","여든셋","여든넷","여든다섯","여든여섯","여든일곱","여든여덟","여든아홉", // 80〜89
            "아흔","아흔하나","아흔둘","아흔셋","아흔넷","아흔다섯","아흔여섯","아흔일곱","아흔여덟","아흔아홉"  // 90〜99
        ]

        // Japanese numbers 1〜99
        // シンプルに "1","2",..."99" の文字列配列
        var japaneseNumbers: [String] = []
        for i in 1...99 {
            japaneseNumbers.append("\(i)")
        }

        // 現在の出題するインデックスを生成
        let currentIndex = currentQuestionIndex % koreanNumbers.count

        var questionText = ""
        
        // 韓国語から日本語へのクイズ
        if selectedQuizMode?.contains("kr_jp") == true {
            questionText = koreanNumbers[currentIndex] // 韓国語で出題
            correctAnswer = japaneseNumbers[currentIndex] // 正解は日本語
            // ダミーなし、全て正解の回答が表示される
            let answers = [correctAnswer, correctAnswer, correctAnswer, correctAnswer]
            setAnswerButtons(with: answers)
            
        // 日本語から韓国語へのクイズ
        } else if selectedQuizMode?.contains("jp_kr") == true {
            questionText = japaneseNumbers[currentIndex] // 日本語で出題
            correctAnswer = koreanNumbers[currentIndex]  // 正解は韓国語
            
            // ランダムにダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyIndex = Int.random(in: 0..<koreanNumbers.count)
                let dummyAnswer = koreanNumbers[randomDummyIndex]
                if !answers.contains(dummyAnswer) {
                    answers.append(dummyAnswer)
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
        }
        
        questionLabel.text = questionText
        // ここで問題を追加してEndViewで使用できるようにする
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer)
        questions.append(question)
        currentQuestionIndex += 1
    }
    
    func generateLargeNumberQuestion() {
        // 10000〜99999までのランダムな数字を生成
        let randomNumber = Int.random(in: 10000...99999)
        
        // 韓国語の単位と数字
        let koreanUnits = ["만", "천", "백", "십", ""]
        let koreanNumbers = ["", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
        
        // 数字を韓国語に変換する関数
        func numberToKorean(_ number: Int) -> String {
            let digits = String(number).map { Int(String($0)) ?? 0 } // 数字を桁ごとの配列に変換
            var korean = ""
            let startIndex = koreanUnits.count - digits.count // 桁が少ない場合の単位開始位置
            
            // 左から順に単位を適用
            for (index, digit) in digits.enumerated() {
                if digit > 0 {
                    korean += koreanNumbers[digit] + koreanUnits[startIndex + index] + " " // 単位の右にスペースを追加
                }
            }
            
            return korean.trimmingCharacters(in: .whitespaces) // 最後のスペースを削除
        }

        // 韓国語表現
        let koreanRepresentation = numberToKorean(randomNumber)
        
        var questionText = ""
        
        // 出題が韓国語のケース
        if selectedQuizMode?.contains("kr_jp") == true {
            questionText = koreanRepresentation
            correctAnswer = "\(randomNumber)"
            
            // ダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyNumber = Int.random(in: 10000...99999)
                if !answers.contains("\(randomDummyNumber)") {
                    answers.append("\(randomDummyNumber)")
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
            
        // 出題が数字のケース
        } else if selectedQuizMode?.contains("jp_kr") == true {
            questionText = "\(randomNumber)"
            correctAnswer = koreanRepresentation
            
            // ダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyNumber = Int.random(in: 10000...99999)
                let dummyAnswer = numberToKorean(randomDummyNumber)
                if !answers.contains(dummyAnswer) {
                    answers.append(dummyAnswer)
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
        }
        
        questionLabel.text = questionText
        // クイズデータを保存
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer)
        questions.append(question)
        currentQuestionIndex += 1
    }
    
    
    func generateKoreanCounterQuiz() {
        // 韓国語の固有数詞を定義（1〜99まで）
        let koreanNumbers = [
            "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열",
            "열한", "열두", "열셋", "열넷", "열다섯", "열여섯", "열일곱", "열여덟", "열아홉", "스무",
            "스물한", "스물두", "스물세", "스물네", "스물다섯", "스물여섯", "스물일곱", "스물여덟", "스물아홉", "서른",
            "서른한", "서른두", "서른세", "서른네", "서른다섯", "서른여섯", "서른일곱", "서른여덟", "서른아홉", "마흔",
            "마흔한", "마흔두", "마흔세", "마흔네", "마흔다섯", "마흔여섯", "마흔일곱", "마흔여덟", "마흔아홉", "쉰",
            "쉰한", "쉰두", "쉰세", "쉰네", "쉰다섯", "쉰여섯", "쉰일곱", "쉰여덟", "쉰아홉", "예순",
            "예순한", "예순두", "예순세", "예순네", "예순다섯", "예순여섯", "예순일곱", "예순여덟", "예순아홉", "일흔",
            "일흔한", "일흔두", "일흔세", "일흔네", "일흔다섯", "일흔여섯", "일흔일곱", "일흔여덟", "일흔아홉", "여든",
            "여든한", "여든두", "여든세", "여든네", "여든다섯", "여든여섯", "여든일곱", "여든여덟", "여든아홉", "아흔"
        ]

        // 日本語の数字を定義（1〜99まで）
        let japaneseNumbers = [
            "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
            "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
            "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
            "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
            "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
            "51", "52", "53", "54", "55", "56", "57", "58", "59", "60",
            "61", "62", "63", "64", "65", "66", "67", "68", "69", "70",
            "71", "72", "73", "74", "75", "76", "77", "78", "79", "80",
            "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
            "91", "92", "93", "94", "95", "96", "97", "98", "99"
        ]

        // 韓国語の単位を定義
        let koreanCounters = ["개", "병", "살", "명", "권", "마리"]

        // 日本語の対応する単位を定義
        let japaneseCounters = ["個", "本", "歳", "人", "冊", "匹"]

        // ランダムに出題する数（1〜99の範囲で選ぶ）
        let currentNumberIndex = Int.random(in: 0..<koreanNumbers.count)

        // ランダムに単位（数え方）を選ぶ
        let currentCounterIndex = Int.random(in: 0..<koreanCounters.count)

        var questionText = ""
        
        // 韓国語から日本語へのクイズ
        if selectedQuizMode?.contains("kr_jp") == true {
            // 例: 스물다섯 살 -> 25歳
            questionText = "\(koreanNumbers[currentNumberIndex]) \(koreanCounters[currentCounterIndex])"
            correctAnswer = "\(japaneseNumbers[currentNumberIndex]) \(japaneseCounters[currentCounterIndex])"
            
            // ダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyNumberIndex = Int.random(in: 0..<japaneseNumbers.count)
                let randomDummyCounterIndex = Int.random(in: 0..<japaneseCounters.count)
                let dummyAnswer = "\(japaneseNumbers[randomDummyNumberIndex]) \(japaneseCounters[randomDummyCounterIndex])"
                if !answers.contains(dummyAnswer) {
                    answers.append(dummyAnswer)
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
            
        // 日本語から韓国語へのクイズ
        } else if selectedQuizMode?.contains("jp_kr") == true {
            // 例: 25歳 -> 스물다섯 살
            questionText = "\(japaneseNumbers[currentNumberIndex]) \(japaneseCounters[currentCounterIndex])"
            correctAnswer = "\(koreanNumbers[currentNumberIndex]) \(koreanCounters[currentCounterIndex])"
            
            // ランダムにダミーを生成
            var answers = [correctAnswer]
            while answers.count < 4 {
                let randomDummyNumberIndex = Int.random(in: 0..<koreanNumbers.count)
                let randomDummyCounterIndex = Int.random(in: 0..<koreanCounters.count)
                let dummyAnswer = "\(koreanNumbers[randomDummyNumberIndex]) \(koreanCounters[randomDummyCounterIndex])"
                if !answers.contains(dummyAnswer) {
                    answers.append(dummyAnswer)
                }
            }
            answers.shuffle()
            setAnswerButtons(with: answers)
        }
        
        questionLabel.text = questionText
        // ここで問題を追加してEndViewで使用できるようにする
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer)
        questions.append(question)
        currentQuestionIndex += 1
    }

    // 日付のクイズを生成する
    func generateDateQuestion() {
        let invalidDates: Set<String> = ["2-30", "2-31", "4-31", "6-31", "9-31", "11-31"]
        var month = Int.random(in: 1...12)
        var day = Int.random(in: 1...31)
        
        while invalidDates.contains("\(month)-\(day)") {
            month = Int.random(in: 1...12)
            day = Int.random(in: 1...31)
        }

        let koreanMonths = ["일월", "이월", "삼월", "사월", "오월", "유월", "칠월", "팔월", "구월", "시월", "십일월", "십이월"]
        let koreanDays = ["일일", "이일", "삼일", "사일", "오일", "육일", "칠일", "팔일", "구일", "십일", "십일일", "십이일", "십삼일", "십사일", "십오일", "십육일", "십칠일", "십팔일", "십구일", "이십일", "이십일일", "이십이일", "이십삼일", "이십사일", "이십오일", "이십육일", "이십칠일", "이십팔일", "이십구일", "삼십일", "삼십일일"]
        let japaneseMonths = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
        let japaneseDays = ["1日", "2日", "3日", "4日", "5日", "6日", "7日", "8日", "9日", "10日", "11日", "12日", "13日", "14日", "15日", "16日", "17日", "18日", "19日", "20日", "21日", "22日", "23日", "24日", "25日", "26日", "27日", "28日", "29日", "30日", "31日"]

        var questionText = ""
        
        if selectedQuizMode?.contains("kr_jp") == true {
            questionText = "\(koreanMonths[month - 1]) \(koreanDays[day - 1])"
            correctAnswer = "\(japaneseMonths[month - 1]) \(japaneseDays[day - 1])"
        } else if selectedQuizMode?.contains("jp_kr") == true {
            questionText = "\(japaneseMonths[month - 1]) \(japaneseDays[day - 1])"
            correctAnswer = "\(koreanMonths[month - 1]) \(koreanDays[day - 1])"
        }

        questionLabel.text = questionText
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer)
        questions.append(question)

        // ダミーの選択肢を作成
        var answers = [correctAnswer]
        while answers.count < 4 {
            let randomMonth = Int.random(in: 1...12)
            let randomDay = Int.random(in: 1...31)
            
            // 無効な日付をスキップ
            if invalidDates.contains("\(randomMonth)-\(randomDay)") {
                continue
            }
            
            let answer: String
            if selectedQuizMode?.contains("kr_jp") == true {
                answer = "\(randomMonth)月\(randomDay)日"
            } else {
                answer = "\(koreanMonths[randomMonth - 1]) \(koreanDays[randomDay - 1])"
            }

            if !answers.contains(answer) {
                answers.append(answer)
            }
        }

        answers.shuffle()
        setAnswerButtons(with: answers)
        currentQuestionIndex += 1
    }

    // 時間のクイズを生成する
    func generateTimeQuestion() {
        let koreanHours = ["한시", "두시", "세시", "네시", "다섯시", "여섯시", "일곱시", "여덟시", "아홉시", "열시", "열한시", "열두시"]
        let koreanMinutes = ["일분", "이분", "삼분", "사분", "오분", "육분", "칠분", "팔분", "구분", "십분", "십일분", "십이분", "십삼분", "십사분", "십오분", "십육분", "십칠분", "십팔분", "십구분", "이십분", "이십일분", "이십이분", "이십삼분", "이십사분", "이십오분", "이십육분", "이십칠분", "이십팔분", "이십구분", "삼십분"]
        let japaneseHours = ["1時", "2時", "3時", "4時", "5時", "6時", "7時", "8時", "9時", "10時", "11時", "12時"]
        let japaneseMinutes = ["1分", "2分", "3分", "4分", "5分", "6分", "7分", "8分", "9分", "10分", "11分", "12分", "13分", "14分", "15分", "16分", "17分", "18分", "19分", "20分", "21分", "22分", "23分", "24分", "25分", "26分", "27分", "28分", "29分", "30分"]

        let hour = Int.random(in: 1...12)
        let minute = Int.random(in: 1...30)

        var questionText = ""
        
        if selectedQuizMode?.contains("kr_jp") == true {
            questionText = "\(koreanHours[hour - 1]) \(koreanMinutes[minute - 1])"
            correctAnswer = "\(japaneseHours[hour - 1])\(japaneseMinutes[minute - 1])"
        } else if selectedQuizMode?.contains("jp_kr") == true {
            questionText = "\(japaneseHours[hour - 1]) \(japaneseMinutes[minute - 1])"
            correctAnswer = "\(koreanHours[hour - 1]) \(koreanMinutes[minute - 1])"
        }

        questionLabel.text = questionText
        let question = DateTimeQuestion(question: questionText, correctAnswer: correctAnswer)
        questions.append(question)

        // ダミーの選択肢を作成
        var answers = [correctAnswer]
        while answers.count < 4 {
            let randomHour = Int.random(in: 1...12)
            let randomMinute = Int.random(in: 1...30)
            
            let answer: String
            if selectedQuizMode?.contains("kr_jp") == true {
                answer = "\(randomHour)時 \(randomMinute)分"
            } else {
                answer = "\(koreanHours[randomHour - 1]) \(koreanMinutes[randomMinute - 1])"
            }

            if !answers.contains(answer) {
                answers.append(answer)
            }
        }

        answers.shuffle()
        setAnswerButtons(with: answers)
        currentQuestionIndex += 1
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


}
