//
//  JapaneseVerbDictionaryViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/11/20.
//
import UIKit
import AVFAudio

class JapaneseWordDictionaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var questions: [QuestionProtocol] = [] // CSVからロードされたデータを保持
    private var filteredQuestions: [QuestionProtocol] = [] // 検索結果
    private var expandedIndexPaths: Set<IndexPath> = [] // 展開状態を管理するセット
    var tableView: UITableView!
    var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestions()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        
        // 検索バー
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "単語や意味を検索"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        // ソートボタン
        let sortButton = UIButton(type: .system)
        sortButton.setTitle("ソート", for: .normal)
        sortButton.setTitleColor(.white, for: .normal)
        sortButton.backgroundColor = .systemBlue
        sortButton.layer.cornerRadius = 5
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        
        // ソートメニューを設定
        let menu = UIMenu(title: "ソート方法を選択", children: [
            UIAction(title: "韓国語 가나다　順", handler: { _ in
                self.sortQuestions(by: .koreanAscending)
            }),
            UIAction(title: "韓国語 가나다　逆順", handler: { _ in
                self.sortQuestions(by: .koreanDescending)
            }),
            UIAction(title: "日本語 あいうえお　順", handler: { _ in
                self.sortQuestions(by: .japaneseHiraganaAscending)
            }),
            UIAction(title: "日本語 あいうえお　逆順", handler: { _ in
                self.sortQuestions(by: .japaneseHiraganaDescending)
            })
        ])
        sortButton.menu = menu
        sortButton.showsMenuAsPrimaryAction = true // ボタンをタップした際にメニューを表示
        view.addSubview(sortButton)
        
        // タイトルラベル
        let titleLabel = UILabel()
        titleLabel.text = "🇯🇵 → 🇰🇷　名詞など"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // テーブルビュー
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(JapaneseNounCell.self, forCellReuseIdentifier: "WordCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 制約
        NSLayoutConstraint.activate([
            // タイトルラベル
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 検索バー
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: -10),
            
            // ソートボタン
            sortButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sortButton.widthAnchor.constraint(equalToConstant: 80),
            sortButton.heightAnchor.constraint(equalTo: searchBar.heightAnchor),
            
            // テーブルビュー
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    enum SortOption {
        case koreanAscending, koreanDescending, japaneseHiraganaAscending, japaneseHiraganaDescending
    }

    func sortQuestions(by option: SortOption) {
        switch option {
        case .koreanAscending:
            filteredQuestions.sort {
                $0.text.compare($1.text, options: [], range: nil, locale: Locale(identifier: "ko_KR")) == .orderedAscending
            }
        case .koreanDescending:
            filteredQuestions.sort {
                $0.text.compare($1.text, options: [], range: nil, locale: Locale(identifier: "ko_KR")) == .orderedDescending
            }
        case .japaneseHiraganaAscending:
            filteredQuestions.sort {
                ($0.correctHiragana ?? "") < ($1.correctHiragana ?? "")
            }
        case .japaneseHiraganaDescending:
            filteredQuestions.sort {
                ($0.correctHiragana ?? "") > ($1.correctHiragana ?? "")
            }
        }
        tableView.reloadData()
    }
    
    func loadQuestions() {
        let categories = CSVFileManager.loadNounCategories()
        
        questions = CSVLoader.loadAllQuestions(from: categories, forLanguage: "kr")
        filteredQuestions = questions // 初期状態では全ての質問を表示
        tableView.reloadData()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func sortButtonTapped() {
        let alert = UIAlertController(title: "ソート", message: "ソート方法を選んでください", preferredStyle: .actionSheet)
        
        // 韓国語昇順
        alert.addAction(UIAlertAction(title: "韓国語 昇順", style: .default, handler: { _ in
            if self.filteredQuestions.isEmpty {
                self.filteredQuestions = self.questions
            }
            self.filteredQuestions.sort { $0.text < $1.text }
            self.tableView.reloadData()
        }))
        
        // 韓国語降順
        alert.addAction(UIAlertAction(title: "韓国語 降順", style: .default, handler: { _ in
            if self.filteredQuestions.isEmpty {
                self.filteredQuestions = self.questions
            }
            self.filteredQuestions.sort { $0.text > $1.text }
            self.tableView.reloadData()
        }))
        
        // 日本語昇順
        alert.addAction(UIAlertAction(title: "日本語 昇順", style: .default, handler: { _ in
            if self.filteredQuestions.isEmpty {
                self.filteredQuestions = self.questions
            }
            self.filteredQuestions.sort { $0.correctAnswer < $1.correctAnswer }
            self.tableView.reloadData()
        }))
        
        // 日本語降順
        alert.addAction(UIAlertAction(title: "日本語 降順", style: .default, handler: { _ in
            if self.filteredQuestions.isEmpty {
                self.filteredQuestions = self.questions
            }
            self.filteredQuestions.sort { $0.correctAnswer > $1.correctAnswer }
            self.tableView.reloadData()
        }))
        
        // キャンセル
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        // アクションシートを表示
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredQuestions.isEmpty ? questions.count : filteredQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as? JapaneseNounCell else {
            fatalError("Failed to dequeue JapaneseNounCell")
        }
        
        let question = filteredQuestions.isEmpty ? questions[indexPath.row] : filteredQuestions[indexPath.row]
        let isExpanded = expandedIndexPaths.contains(indexPath)
        cell.configure(with: question, isExpanded: isExpanded)
        
        return cell
    }
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if expandedIndexPaths.contains(indexPath) {
            // 展開済みなら閉じる
            expandedIndexPaths.remove(indexPath)
        } else {
            // 未展開なら展開
            expandedIndexPaths.insert(indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic) // 対象のセルを再描画
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if expandedIndexPaths.contains(indexPath) {
            return UITableView.automaticDimension // 展開時は自動調整
        } else {
            return 60 // 通常時の高さ
        }
    }
    
    // MARK: - UISearchBar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredQuestions = questions
        } else {
            filteredQuestions = questions.filter { question in
                question.text.localizedCaseInsensitiveContains(searchText) ||
                question.correctAnswer.localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData() // 常に再描画する
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // キーボードを確実に閉じる
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredQuestions = questions
        tableView.reloadData()
    }
}

class JapaneseNounCell: UITableViewCell {
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let exampleSentenceLabel = UILabel()
    private let exampleMeaningLabel = UILabel()
    private var meaningAudioButton = UIButton(type: .system)
    private var exampleAudioButton = UIButton(type: .system)
    private let speechSynthesizer = AVSpeechSynthesizer()// 音声再生用

    // セルの再利用に必要
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // 単語ラベル
        wordLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)
             
        // 意味ラベル
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = .gray
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(meaningLabel)
        
        meaningAudioButton = UIButton(type: .system)
        meaningAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        meaningAudioButton.tintColor = .systemBlue
        meaningAudioButton.translatesAutoresizingMaskIntoConstraints = false
        meaningAudioButton.addTarget(self, action: #selector(playMeaningAudio), for: .touchUpInside)
        meaningAudioButton.isHidden = true // 初期状態は非表示
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
        
        exampleAudioButton = UIButton(type: .system)
        exampleAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        exampleAudioButton.tintColor = .systemGreen
        exampleAudioButton.translatesAutoresizingMaskIntoConstraints = false
        exampleAudioButton.addTarget(self, action: #selector(playExampleAudio), for: .touchUpInside)
        contentView.addSubview(exampleAudioButton)
        
        
        setupConstraints()
    }
    

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

            meaningAudioButton.centerYAnchor.constraint(equalTo: meaningLabel.centerYAnchor),
            meaningAudioButton.leadingAnchor.constraint(equalTo: meaningLabel.trailingAnchor, constant: 10),
            meaningAudioButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),

            exampleSentenceLabel.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 10),
            exampleSentenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),

            exampleAudioButton.centerYAnchor.constraint(equalTo: exampleSentenceLabel.centerYAnchor),
            exampleAudioButton.leadingAnchor.constraint(equalTo: exampleSentenceLabel.trailingAnchor, constant: 10),
            exampleAudioButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),

            exampleMeaningLabel.topAnchor.constraint(equalTo: exampleSentenceLabel.bottomAnchor, constant: 10),
            exampleMeaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            exampleMeaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

            exampleMeaningLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
 
    

    func configure(with question: QuestionProtocol, isExpanded: Bool) {
        wordLabel.text = question.correctAnswer
        meaningLabel.text = question.text.isEmpty ? "意味がありません" : question.text
        exampleSentenceLabel.text = question.exampleSentence
        exampleMeaningLabel.text = question.exampleSentenceMeaning
        
        meaningLabel.isHidden = !isExpanded
        meaningAudioButton.isHidden = !isExpanded
        exampleSentenceLabel.isHidden = !isExpanded
        exampleMeaningLabel.isHidden = !isExpanded
        exampleAudioButton.isHidden = !isExpanded

        // レイアウトを確実に更新
        setNeedsLayout()
        layoutIfNeeded()
    }

    // 意味の音声を再生
    @objc private func playMeaningAudio() {
        guard let meaning = meaningLabel.text else { return }
        playAudio(for: meaning, language: "ko-KR") // 日本語を設定
    }

    // 例文の音声を再生
    @objc private func playExampleAudio() {
        guard let example = exampleSentenceLabel.text else { return }
        playAudio(for: example, language: "ko-KR") // 韓国語を設定
    }

    // 音声を再生する共通メソッド
    private func playAudio(for text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(utterance)
    }
    
    
}
