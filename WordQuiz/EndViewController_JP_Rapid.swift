import UIKit

protocol EndViewController_JPDelegate: AnyObject {
    func didCloseEndViewController()
    func didReturnToHome()
}

extension EndViewController_JP_Rapid.Question {
    init?(from question: any QuestionProtocol) {
        let text = question.text
        let correctAnswer = question.correctAnswer
        self.text = text
        self.correctAnswer = correctAnswer
        self.exampleSentence = question.exampleSentence
        self.exampleSentenceMeaning = question.exampleSentenceMeaning
    }
}

class EndViewController_JP_Rapid: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: EndViewControllerDelegate?

    var resultLabel: UILabel!
    var tableView: UITableView!
    var evaluationLabel: UILabel!
    var buttons: [UIButton] = []
    var questions: [QuestionProtocol] = []
    var quizResults: [QuizResult] = []
    var favoriteQuestions: [Question] = []
    var category: String = ""
    var selectedQuizMode: String = ""
    var correctAnswersCount: Int = 0
    var hideIconSwitch: UISwitch!
    private var expandedIndexPaths: Set<IndexPath> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // デバッグ用
//        print("EndViewController_Rapid loaded with category: \(category)")
//        print("EndViewController_Rapid loaded with quiz mode: \(selectedQuizMode)")

        setupUI()
        // 苦手リストをロード
        favoriteQuestions = loadFavoriteQuestions(for: selectedQuizMode)
        tableView.reloadData()
    }

    func setupUI() {
        // 1. 結果ラベル
        resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.text = "\(quizResults.filter { $0.isCorrect }.count) 問正解しました！"
        view.addSubview(resultLabel)

        // 2. テーブルビュー
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RapidModeQuestionTableViewCell_JP_Rapid.self, forCellReuseIdentifier: "RapidModeQuestionTableViewCell_JP_Rapid")
        view.addSubview(tableView)

        // 3. 評価ラベル
        evaluationLabel = UILabel()
        evaluationLabel.text = "このクイズを終えたのは \(getCompletionCount(for: category, mode: selectedQuizMode)) 回目です。評価を選んでください。"
        evaluationLabel.textAlignment = .center
        evaluationLabel.numberOfLines = 1
        evaluationLabel.adjustsFontSizeToFitWidth = true
        evaluationLabel.minimumScaleFactor = 0.5
        evaluationLabel.lineBreakMode = .byWordWrapping
        evaluationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(evaluationLabel)

        // 4. ボタンを作成
        let buttonTitles = ["全然できなかった", "できなかった", "多少できた", "よくできた"]
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitles[i], for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.titleLabel?.lineBreakMode = .byClipping
            button.tag = i
            
            // 背景色を条件分岐で設定
            switch i {
            case 0:
                button.backgroundColor = UIColor(red: 1.0, green: 0.39, blue: 0.28, alpha: 1.0) // Tomato (#FF6347)
            case 1:
                button.backgroundColor = UIColor.orange // (#FFA500)
            case 2:
                button.backgroundColor = UIColor(red: 0.60, green: 0.80, blue: 0.20, alpha: 1.0) // YellowGreen (#9ACD32)
            case 3:
                button.backgroundColor = UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0) // ForestGreen (#228B22)
            default:
                button.backgroundColor = UIColor.systemBlue
            }
            
            // 角丸
            button.layer.cornerRadius = 10
            // 立体感（シャドウ）をつける
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 2, height: 2)
            button.layer.shadowRadius = 4
            button.layer.shadowOpacity = 0.5
            button.layer.masksToBounds = false

            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(evaluationButtonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            view.addSubview(button)
        }
        
        // アイコン非表示チェックボックス（スイッチ）
        hideIconSwitch = UISwitch()
        hideIconSwitch.translatesAutoresizingMaskIntoConstraints = false
        hideIconSwitch.addTarget(self, action: #selector(hideIconSwitchToggled(_:)), for: .valueChanged)

        // ※ここでグローバル状態を取得してスイッチに反映
        hideIconSwitch.isOn = getGlobalIconHiddenState(for: selectedQuizMode, category: category)
        view.addSubview(hideIconSwitch)

        setupConstraints()
    }
    

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 結果ラベル
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 40),

            // テーブルビュー
            tableView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: evaluationLabel.topAnchor, constant: -20),

            // 評価ラベル
            evaluationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -view.frame.height * 0.2),
            evaluationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            evaluationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            evaluationLabel.heightAnchor.constraint(equalToConstant: 40)

        ])

        // 画面幅を取得
        let screenWidth = UIScreen.main.bounds.width
        let buttonWidth = screenWidth / 4 - 20 // 各ボタンの幅 (左右マージンを差し引く)

        for i in 0..<buttons.count {
            let button = buttons[i]
            view.addSubview(button)

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: evaluationLabel.bottomAnchor, constant: 10), // 評価ラベルの下に配置
                button.widthAnchor.constraint(equalToConstant: buttonWidth), // ボタンの幅を画面の4分の1に設定
                button.heightAnchor.constraint(equalToConstant: 50), // ボタンの高さ
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CGFloat(20 + CGFloat(i) * (buttonWidth + 10))) // 左マージン + ボタンの間隔
            ])
        }

        // チェックボックス説明ラベル
        let hideIconLabel = UILabel()
        hideIconLabel.text = "チェックを入れると、復習マークがつかなくなります。"
        hideIconLabel.font = UIFont.systemFont(ofSize: 14)
        hideIconLabel.textAlignment = .center
        hideIconLabel.numberOfLines = 0
        hideIconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hideIconLabel)

        NSLayoutConstraint.activate([
            hideIconLabel.topAnchor.constraint(equalTo: buttons[0].bottomAnchor, constant: 20),
            hideIconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hideIconLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // アイコン非表示スイッチ
        NSLayoutConstraint.activate([
            hideIconSwitch.topAnchor.constraint(equalTo: hideIconLabel.bottomAnchor, constant: 10),
            hideIconSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hideIconSwitch.widthAnchor.constraint(equalToConstant: 50),  // スイッチの幅
            hideIconSwitch.heightAnchor.constraint(equalToConstant: 30) // スイッチの高さ
        ])
    }
    
    // MARK: - グローバルなアイコン非表示状態に関する関数追加
    func saveGlobalIconHiddenState(for mode: String, category: String, isHidden: Bool) {
        let userKey = "\(mode)_\(category)_GlobalIconHidden"
        UserDefaults.standard.set(isHidden, forKey: userKey)
        UserDefaults.standard.synchronize()
//        print("Saved global icon hidden state for key '\(userKey)': \(isHidden)")
    }

    // カテゴリーごとのアイコン表示状態を取得
    func getGlobalIconHiddenState(for mode: String, category: String) -> Bool {
        let userKey = "\(mode)_\(category)_GlobalIconHidden"
        let value = UserDefaults.standard.bool(forKey: userKey)
//        print("Retrieved global icon hidden state for key '\(userKey)': \(value)")
        return value
    }

    // MARK: - アイコン表示非表示のチェックボックスに関する関数（修正）
    @objc private func hideIconSwitchToggled(_ sender: UISwitch) {
        let isHiddenByUser = sender.isOn
        guard !category.isEmpty else { return } // カテゴリーが空の場合は何もしない
        saveGlobalIconHiddenState(for: selectedQuizMode, category: category, isHidden: isHiddenByUser)
    }

    // 以下はもう使わない可能性が高いが、必要なら残しておく
    // 「カテゴリー別アイコン非表示状態」は廃止または不要になる場合がある
    // コメントアウトしても良い
    /*
    func saveIconHiddenState(for mode: String?, category: String, isHiddenByUser: Bool) {
        guard let mode = mode else { return }
        let userKey = "\(mode)_\(category)_IconHiddenByUser"
        UserDefaults.standard.set(isHiddenByUser, forKey: userKey)
        UserDefaults.standard.synchronize()
        print("Saved hide icon state by user for key: \(userKey), value: \(isHiddenByUser)")
    }

    func getIconHiddenState(for mode: String?, category: String) -> Bool {
        guard let mode = mode else { return false }
        let userKey = "\(mode)_\(category)_IconHiddenByUser"
        return UserDefaults.standard.bool(forKey: userKey)
    }
    */
    
    // MARK: - 苦手ボタンに関する関数

    
    struct Question: Codable {
        let text: String                // 問題文
        let correctAnswer: String       // 正解
        let exampleSentence: String?    // 例文
        let exampleSentenceMeaning: String? // 例文の意味
    }
    
    
    
    func saveFavoriteQuestions(_ questions: [Question], for mode: String) {
        // モードから不要な部分を削除（例: _normal）
        let adjustedMode = mode.replacingOccurrences(of: "_rapid", with: "")
        let key = "favoriteQuestions_\(adjustedMode)"
       
        do {
            let data = try JSONEncoder().encode(questions)
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
//            print("Saved favorite questions for key '\(key)': \(questions)")
        } catch {
//            print("Failed to save favorite questions: \(error)")
        }
    }
    
    func loadFavoriteQuestions(for mode: String) -> [Question] {
        // モードから不要な部分を削除（例: _normal）
        let adjustedMode = mode.replacingOccurrences(of: "_rapid", with: "")
        let key = "favoriteQuestions_\(adjustedMode)"
       
        guard let data = UserDefaults.standard.data(forKey: key) else {
//            print("No favorite questions found for key '\(key)'")
            return []
        }
        do {
            let questions = try JSONDecoder().decode([Question].self, from: data)
//            print("Loaded favorite questions for key '\(key)': \(questions)")
            return questions
        } catch {
//            print("Failed to load favorite questions: \(error)")
            return []
        }
    }
    
    func toggleFavorite(question: QuestionProtocol, for mode: String) {
        if let convertedQuestion = EndViewController_JP_Rapid.Question(from: question) {
            var favoriteQuestions = loadFavoriteQuestions(for: mode)
            
            if let index = favoriteQuestions.firstIndex(where: { $0.text == convertedQuestion.text }) {
                favoriteQuestions.remove(at: index)
//                print("Removed from favorite: \(convertedQuestion.text)")
            } else {
                favoriteQuestions.append(convertedQuestion)
//                print("Added to favorite: \(convertedQuestion.text)")
            }
            
            saveFavoriteQuestions(favoriteQuestions, for: mode)
        } else {
//            print("Failed to convert QuestionProtocol to EndViewController_Normal.Question")
        }
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if expandedIndexPaths.contains(indexPath) {
            expandedIndexPaths.remove(indexPath) // 展開を解除
        } else {
            expandedIndexPaths.insert(indexPath) // 展開する
        }
        
        // 対象セルのみリロードして再描画
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandedIndexPaths.contains(indexPath) ? UITableView.automaticDimension : 60 // 展開時と通常時の高さ
    }
    
    // MARK: - UITableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RapidModeQuestionTableViewCell_JP_Rapid", for: indexPath) as? RapidModeQuestionTableViewCell_JP_Rapid else {
            fatalError("Failed to dequeue RapidModeQuestionTableViewCell_JP_Rapid")
        }

        let question = questions[indexPath.row]
        let quizResult = quizResults[indexPath.row]
        if let convertedQuestion = EndViewController_Rapid.Question(from: question) {
            let isFavorite = favoriteQuestions.contains { $0.text == convertedQuestion.text }

            cell.configure(
                word: convertedQuestion.text,
                meaning: convertedQuestion.correctAnswer,
                example: convertedQuestion.exampleSentence,
                exampleMeaning: convertedQuestion.exampleSentenceMeaning,
                isExpanded: expandedIndexPaths.contains(indexPath),
                isCorrect: quizResult.isCorrect,
                isRemoved: !isFavorite,
                mode: selectedQuizMode
            )
        }
        
        cell.onFavoriteButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.toggleFavorite(question: question, for: self.selectedQuizMode)
            self.favoriteQuestions = self.loadFavoriteQuestions(for: self.selectedQuizMode)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
    
    // Restartクイズの処理を呼び出す
    @objc func restartQuiz() {
        // すべてのモーダル画面を閉じる
        self.view.window?.rootViewController?.dismiss(animated: true) {
            // ナビゲーションスタック内で目的の画面に戻る
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let navigationController = windowScene.windows.first?.rootViewController as? UINavigationController {
                for viewController in navigationController.viewControllers {
                    if viewController is SelectCategory_RapidMode_ViewController {
                        navigationController.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
        }
    }

    // 評価ボタンが押された時の処理
    @objc func evaluationButtonTapped(_ sender: UIButton) {
        let nextReviewDate: Date
        let currentDate = Date()
        
        switch sender.tag {
        case 0:
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 0, to: currentDate)!
        case 1:
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        case 2:
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
        case 3:
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        default:
            nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)! // デフォルト1日後
        }
        
        // 次の復習日を保存
        saveNextReviewDate(for: category, mode: selectedQuizMode, nextReviewDate: nextReviewDate)
        // 最後に、評価ボタンを押した後に自動的にリスタートする
        restartQuiz()
    }
    
    // 次の復習日を保存する
    func saveNextReviewDate(for category: String, mode: String, nextReviewDate: Date) {
        // モードとカテゴリー名を組み合わせたキーを作成
        let nextReviewDateKey = "\(mode)_\(category)_nextReviewDate"
        
        // DateFormatterを使用して日付を文字列に変換
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd" // 任意のフォーマットを指定
        let dateString = dateFormatter.string(from: nextReviewDate)
        
        // 文字列として保存
        UserDefaults.standard.set(dateString, forKey: nextReviewDateKey)
        UserDefaults.standard.synchronize() // 同期を確実にする
        
        // デバッグ: 保存されたキーとデータを確認するログ
//        print("Saving next review date for key '\(nextReviewDateKey)': \(dateString)")
    }

    func getCompletionCount(for category: String, mode: String) -> Int {
        let completionCountKey = "\(category)_\(selectedQuizMode)_completionCount"
        let count = UserDefaults.standard.integer(forKey: completionCountKey)
//        print("Completion count key: \(completionCountKey), Retrieved count: \(count)")
        return count
    }
}








import AVFoundation

class RapidModeQuestionTableViewCell_JP_Rapid: UITableViewCell {
    private let statusLabel = UILabel()
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let meaningAudioButton = UIButton(type: .system)
    private let exampleSentenceLabel = UILabel()
    private let exampleMeaningLabel = UILabel()
    private let exampleAudioButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    private let speechSynthesizer = AVSpeechSynthesizer()

    var onFavoriteButtonTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)

        wordLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)

        
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = .gray
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(meaningLabel)
        
        
        meaningAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        meaningAudioButton.tintColor = .systemBlue
        meaningAudioButton.translatesAutoresizingMaskIntoConstraints = false
        meaningAudioButton.addTarget(self, action: #selector(playMeaningAudio), for: .touchUpInside)
        contentView.addSubview(meaningAudioButton)
        
        // 例文ラベル
        exampleSentenceLabel.font = UIFont.systemFont(ofSize: 14)
        exampleSentenceLabel.textColor = .darkGray
        exampleSentenceLabel.numberOfLines = 0
        exampleSentenceLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleSentenceLabel.isHidden = true
        contentView.addSubview(exampleSentenceLabel)
        
        // 例文の意味ラベル
        exampleMeaningLabel.font = UIFont.systemFont(ofSize: 14)
        exampleMeaningLabel.textColor = .gray
        exampleMeaningLabel.numberOfLines = 0
        exampleMeaningLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleMeaningLabel.isHidden = true
        contentView.addSubview(exampleMeaningLabel)
        
        exampleAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        exampleAudioButton.translatesAutoresizingMaskIntoConstraints = false
        exampleAudioButton.tintColor = .systemGreen
        exampleAudioButton.addTarget(self, action: #selector(playExampleAudio), for: .touchUpInside)
        contentView.addSubview(exampleAudioButton)

        
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)

        
        
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.topAnchor, constant: 30), // 固定された位置に配置
            statusLabel.widthAnchor.constraint(equalToConstant: 30),
            statusLabel.heightAnchor.constraint(equalToConstant: 30),

            wordLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 10),
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            // 意味ラベル
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: wordLabel.leadingAnchor),
            
            // 音声ボタン (意味の横)
            meaningAudioButton.centerYAnchor.constraint(equalTo: meaningLabel.centerYAnchor),
            meaningAudioButton.leadingAnchor.constraint(equalTo: meaningLabel.trailingAnchor, constant: 10),
            meaningAudioButton.widthAnchor.constraint(equalToConstant: 30),
            meaningAudioButton.heightAnchor.constraint(equalToConstant: 30),
            
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            favoriteButton.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),

            // 例文ラベル
            exampleSentenceLabel.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 10),
            exampleSentenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            exampleSentenceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            // 例文の意味ラベル
            exampleMeaningLabel.topAnchor.constraint(equalTo: exampleSentenceLabel.bottomAnchor, constant: 5),
            exampleMeaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            exampleMeaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            exampleMeaningLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // 例文の音声ボタン
            exampleAudioButton.centerYAnchor.constraint(equalTo: exampleSentenceLabel.centerYAnchor),
            exampleAudioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            exampleAudioButton.widthAnchor.constraint(equalToConstant: 30),
            exampleAudioButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(
        word: String,
        meaning: String,
        example: String?,
        exampleMeaning: String?,
        isExpanded: Bool,
        isCorrect: Bool,
        isRemoved: Bool,
        mode: String
    ) {
        // 韓国語の単語
        wordLabel.text = word
        // 日本語の意味
        meaningLabel.text = meaning
        // 例文
        exampleSentenceLabel.text = example
        // 例文の意味
        exampleMeaningLabel.text = exampleMeaning

        // 正解/不正解表示
        statusLabel.text = isCorrect ? "O" : "X"
        statusLabel.textColor = isCorrect ? .systemGreen : .systemRed

        // 展開状態による表示制御
        meaningLabel.isHidden = !isExpanded
        meaningAudioButton.isHidden = !isExpanded
        
        exampleSentenceLabel.isHidden = !isExpanded || example == nil
        exampleMeaningLabel.isHidden = !isExpanded || exampleMeaning == nil
        exampleAudioButton.isHidden = !isExpanded
        

        // 苦手ボタンの色を更新
        if isRemoved {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal) // 星の枠線だけ表示
        } else {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal) // 塗りつぶされた星を表示
        }
    }

    @objc private func playMeaningAudio() {
        guard let meaning = meaningLabel.text else { return }
        playAudio(for: meaning, language: "ko-KR")
    }
    
    @objc private func playExampleAudio() {
        guard let example = exampleSentenceLabel.text, !example.isEmpty else {
//            print("No example sentence to play.")
            return
        }
        playAudio(for: example, language: "ko-KR") // 韓国語の例文を設定
    }
    
    private func playAudio(for text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(utterance)
    }

    @objc private func favoriteButtonTapped() {
        onFavoriteButtonTapped?()
    }
}
