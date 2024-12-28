//
//  EndViewController_Normal.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/12/05.
//

//
//  EndViewController_Normal.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/12/05.
//

import UIKit

extension EndViewController_Normal.Question {
    init?(from question: any QuestionProtocol) {
        let text = question.text
        let correctAnswer = question.correctAnswer
        self.text = text
        self.correctAnswer = correctAnswer
        self.exampleSentence = question.exampleSentence
        self.exampleSentenceMeaning = question.exampleSentenceMeaning
    }
}

class EndViewController_Normal: UIViewController, UITableViewDelegate, UITableViewDataSource {

    weak var delegate: EndViewControllerDelegate?

    var resultLabel: UILabel!
    var tableView: UITableView!
    var restartButton: UIButton!
    var returnHomeButton: UIButton!
    
    var correctAnswersCount: Int = 0
    var questions: [QuestionProtocol] = [] // 出題された問題リスト
    var favoriteQuestions: [Question] = []
    var category: String = "" // カテゴリを保存
    var selectedQuizMode: String = "" // クイズモードを保存
    private var expandedIndexPaths: Set<IndexPath> = [] // 展開中のセルを追跡

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デバッグ用
//        print("EndViewController_Normal loaded with mode: \(selectedQuizMode) and category: \(category)")
        
        // UI設定
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        setupUI()
        
        // 苦手リストをロード
        favoriteQuestions = loadFavoriteQuestions(for: selectedQuizMode)
        tableView.reloadData()
    }

    func setupUI() {
        // 結果ラベル
        resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.text = "お疲れ様でした！"
        view.addSubview(resultLabel)

        // テーブルビュー
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SimpleModeQuestionTableViewCell_Normal.self, forCellReuseIdentifier: "SimpleModeQuestionTableViewCell_Normal")
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

        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 結果ラベル
            resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // テーブルビュー
            tableView.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: -20),

            // 再スタートボタン
            restartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            restartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            restartButton.bottomAnchor.constraint(equalTo: returnHomeButton.topAnchor, constant: -10),

            // ホームに戻るボタン
            returnHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            returnHomeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            returnHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - Favorite Words Handling
    
    struct Question: Codable {
        let text: String                // 問題文
        let correctAnswer: String       // 正解
        let exampleSentence: String?    // 例文
        let exampleSentenceMeaning: String? // 例文の意味
    }
    
    
    
    func saveFavoriteQuestions(_ questions: [Question], for mode: String) {
        // モードから不要な部分を削除（例: _normal）
        let adjustedMode = mode.replacingOccurrences(of: "_normal", with: "")
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
        let adjustedMode = mode.replacingOccurrences(of: "_normal", with: "")
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
        if let convertedQuestion = EndViewController_Normal.Question(from: question) {
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

        // 展開状態をトグル
        if expandedIndexPaths.contains(indexPath) {
            expandedIndexPaths.remove(indexPath) // 展開を解除
        } else {
            expandedIndexPaths.insert(indexPath) // 展開する
        }

        // 対象セルのみリロードして再描画
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 展開時は自動調整、高さを指定する場合はここで指定
        return expandedIndexPaths.contains(indexPath) ? UITableView.automaticDimension : 60
    }
    
    // MARK: - UITableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SimpleModeQuestionTableViewCell_Normal",
            for: indexPath
        ) as? SimpleModeQuestionTableViewCell_Normal else {
            fatalError("Failed to dequeue SimpleModeQuestionTableViewCell_Normal")
        }

        let question = questions[indexPath.row]
        if let convertedQuestion = EndViewController_Normal.Question(from: question) {
            let isFavorite = favoriteQuestions.contains { $0.text == convertedQuestion.text }

            cell.configure(
                word: convertedQuestion.text,
                meaning: convertedQuestion.correctAnswer,
                example: convertedQuestion.exampleSentence,
                exampleMeaning: convertedQuestion.exampleSentenceMeaning,
                isExpanded: expandedIndexPaths.contains(indexPath),
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


    // MARK: - Restart and Home Actions

    @objc func restartQuiz() {
        self.view.window?.rootViewController?.dismiss(animated: true) {
            if let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                for viewController in navigationController.viewControllers {
                    if viewController is SelectCategoryViewController {
                        navigationController.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
        }
    }
    
    @objc func returnToHome() {
        self.view.window?.rootViewController?.dismiss(animated: true) {
            if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewController") {
                let navigationController = UINavigationController(rootViewController: firstVC)
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
}


import AVFoundation

class SimpleModeQuestionTableViewCell_Normal: UITableViewCell {
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let exampleSentenceLabel = UILabel()
    private let exampleMeaningLabel = UILabel()
    private let wordAudioButton = UIButton(type: .system)
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
        // 単語ラベル
        wordLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)

        // 単語の音声ボタン
        wordAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        wordAudioButton.tintColor = .systemBlue
        wordAudioButton.translatesAutoresizingMaskIntoConstraints = false
        wordAudioButton.addTarget(self, action: #selector(playWordAudio), for: .touchUpInside)
        contentView.addSubview(wordAudioButton)

        // 意味ラベル
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = .gray
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(meaningLabel)

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
        exampleAudioButton.addTarget(self, action: #selector(playExampleAudio), for: .touchUpInside)
        exampleAudioButton.translatesAutoresizingMaskIntoConstraints = false
        exampleAudioButton.tintColor = .systemGreen
        contentView.addSubview(exampleAudioButton)

        // 苦手ボタン
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

            wordAudioButton.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            wordAudioButton.leadingAnchor.constraint(equalTo: wordLabel.trailingAnchor, constant: 10),

            favoriteButton.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),

            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            meaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

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
        word: String,                 // 韓国語
        meaning: String,              // 日本語
        example: String?,             // 例文
        exampleMeaning: String?,      // 例文の意味
        isExpanded: Bool,             // 展開状態
        isRemoved: Bool,              // 「苦手」リストに含まれているかどうか
        mode: String                  // クイズモード
    ){
        wordLabel.text = word
        meaningLabel.text = meaning
        exampleSentenceLabel.text = example
        exampleMeaningLabel.text = exampleMeaning
        
        
        meaningLabel.isHidden = !isExpanded
        exampleSentenceLabel.isHidden = !isExpanded || example == nil
        exampleMeaningLabel.isHidden = !isExpanded || example == nil
        exampleAudioButton.isHidden = !isExpanded
        
        // 苦手ボタンの色を更新
        if isRemoved {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal) // 星の枠線だけ表示
        } else {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal) // 塗りつぶされた星を表示
        }
    }

    @objc private func favoriteButtonTapped() {
        onFavoriteButtonTapped?()
    }

    @objc private func playWordAudio() {
        guard let word = wordLabel.text else { return }
        playAudio(for: word, language: "ko-KR") // 韓国語の音声再生
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
}
