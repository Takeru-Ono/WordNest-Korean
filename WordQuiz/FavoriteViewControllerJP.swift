//
//  FavoriteViewControllerJP.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/12/10.
//

import UIKit
import AVFoundation


class FavoriteViewControllerJP: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var mode: String = "jp_kr" // jp_kr または kr_jp
    var favoriteQuestions: [FavoriteQuestion] = [] // FavoriteQuestion型の配列
    private var filteredQuestions: [FavoriteQuestion] = [] // 検索結果
    private var toBeRemovedQuestions: Set<Int> = [] // 削除予定のインデックスを保持
    private var expandedIndexPaths: Set<IndexPath> = [] // 展開状態を管理するセット
    private var filteredWords: [[String: String]] = [] // 検索結果
    var tableView = UITableView()
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        favoriteQuestions = loadFavoriteQuestions(for: mode) // 型が一致
        filteredQuestions = favoriteQuestions // 初期状態はすべての単語を表示
        tableView.reloadData()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
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
        sortButton.showsMenuAsPrimaryAction = true
        view.addSubview(sortButton)
        
        // タイトルラベル
        let titleLabel = UILabel()
        titleLabel.text = "🇯🇵 → 🇰🇷 苦手単語"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // テーブルビュー
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteTableViewCellJP.self, forCellReuseIdentifier: "FavoriteCellJP")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // レイアウト
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
    
    func loadFavoriteQuestions(for mode: String) -> [FavoriteQuestion] {
        let key = "favoriteQuestions_\(mode)"
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([FavoriteQuestion].self, from: data)
        } catch {
            print("Error loading favorite questions: \(error)")
            return []
        }
    }
    
    
    func saveFavoriteQuestions(_ questions: [FavoriteQuestion], for mode: String) {
        let key = "favoriteQuestions_\(mode)"
        do {
            let data = try JSONEncoder().encode(questions)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving favorite questions: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveFavoriteQuestions(favoriteQuestions, for: mode) // 正しい引数を渡す
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCellJP", for: indexPath) as? FavoriteTableViewCellJP else {
            fatalError("Failed to dequeue FavoriteTableViewCellJP.")
        }
        
        let question = filteredQuestions[indexPath.row]
        let isExpanded = expandedIndexPaths.contains(indexPath)
        let isRemoved = toBeRemovedQuestions.contains(indexPath.row)

        print("Question at index \(indexPath.row): \(question.text), \(question.correctAnswer)")

      
        cell.configure(
            with: question, // FavoriteQuestion型
            isExpanded: isExpanded,
            isRemoved: isRemoved
        )
        
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
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
    
    @objc private func toggleFavorite(_ sender: UIButton) {
        let index = sender.tag
        if toBeRemovedQuestions.contains(index) {
            toBeRemovedQuestions.remove(index)
        } else {
            toBeRemovedQuestions.insert(index)
        }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredQuestions = favoriteQuestions
        } else {
            filteredQuestions = favoriteQuestions.filter { question in
                question.text.localizedCaseInsensitiveContains(searchText) ||
                question.correctAnswer.localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData()
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
    
    private func debugFavoriteWords() {
        let key = mode == "jp_kr" ? "favoriteWords_jp_kr" : "favoriteWords_kr_jp"
        if let favoriteWords = UserDefaults.standard.array(forKey: key) as? [[String: String]] {
            print("Loaded favorite words for key '\(key)': \(favoriteWords)")
        } else {
            print("No favorite words found for key '\(key)'.")
        }
    }
    
    
    
}

class FavoriteTableViewCellJP: UITableViewCell {
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let exampleSentenceLabel = UILabel()
    private let exampleMeaningLabel = UILabel()
    private var meaningAudioButton = UIButton(type: .system)
    private var exampleAudioButton = UIButton(type: .system)
    private let speechSynthesizer = AVSpeechSynthesizer()// 音声再生用

    // セルの再利用に必要
    let favoriteButton = UIButton(type: .system)
    private var meaningHeightConstraint: NSLayoutConstraint!


    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 各ビューの設定
        wordLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)

        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.textColor = .gray
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(meaningLabel)
        
        meaningAudioButton = UIButton(type: .system)
        meaningAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        meaningAudioButton.tintColor = .systemGreen
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

        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)

        // 制約を設定
        setupConstraints()
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 単語ラベル
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),


            // 苦手ボタン
            favoriteButton.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),

            // 意味ラベル
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            meaningLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            
            meaningAudioButton.centerYAnchor.constraint(equalTo: meaningLabel.centerYAnchor),
            meaningAudioButton.leadingAnchor.constraint(equalTo: meaningLabel.trailingAnchor, constant: 10),
            meaningAudioButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),

            // 例文ラベル
            exampleSentenceLabel.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 10),
            exampleSentenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            exampleSentenceLabel.trailingAnchor.constraint(equalTo: exampleAudioButton.leadingAnchor, constant: -10),
            
            exampleMeaningLabel.topAnchor.constraint(equalTo: exampleSentenceLabel.bottomAnchor, constant: 10),
            exampleMeaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            exampleMeaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            exampleMeaningLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10) ,

            // 例文の音声ボタン
            exampleAudioButton.centerYAnchor.constraint(equalTo: exampleSentenceLabel.centerYAnchor),
            exampleAudioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            exampleAudioButton.widthAnchor.constraint(equalToConstant: 30),
            exampleAudioButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        print("Word Label Frame: \(wordLabel.frame)")
        print("Meaning Label Frame: \(meaningLabel.frame)")
    }
    
    func configure(
        with question: FavoriteQuestion,
        isExpanded: Bool,
        isRemoved: Bool
    ) {
        // 単語と意味の設定
        wordLabel.text = question.text
        meaningLabel.text = question.correctAnswer
        // 例文とその意味をアンラップ
        let exampleSentence = question.exampleSentence ?? "例文なし"
        let exampleMeaning = question.exampleSentenceMeaning ?? "意味なし"

        // アンラップした値をラベルに設定
        exampleSentenceLabel.text = "例文: \(exampleSentence)"
        exampleMeaningLabel.text = "意味: \(exampleMeaning)"
        meaningLabel.isHidden = !isExpanded
        meaningAudioButton.isHidden = !isExpanded
        exampleSentenceLabel.isHidden = !isExpanded
        exampleMeaningLabel.isHidden = !isExpanded
        exampleAudioButton.isHidden = !isExpanded

        // 苦手ボタンの色を更新
        if isRemoved {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal) // 星の枠線だけ表示
        } else {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal) // 塗りつぶされた星を表示
        }
        
        // レイアウトを確実に更新
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // 意味の音声再生
     @objc private func playMeaningAudio() {
         guard let text = meaningLabel.text else { return }
         playAudio(for: text, language: "ko-KR") // 韓国語で再生
     }
     
     // 例文の音声再生
     @objc private func playExampleAudio() {
         guard let text = exampleSentenceLabel.text else { return }
         playAudio(for: text, language: "ko-KR") // 韓国語で再生
     }
     
     // 音声再生の共通メソッド
     private func playAudio(for text: String, language: String) {
         let utterance = AVSpeechUtterance(string: text)
         utterance.voice = AVSpeechSynthesisVoice(language: language)
         speechSynthesizer.speak(utterance)
     }
    
}
