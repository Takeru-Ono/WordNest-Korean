//
//  DictionaryViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/11/17.
//
import UIKit

class DictionaryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        // タイトルラベル
        let titleLabel = UILabel()
        titleLabel.text = "辞書"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 制約
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 韓国語 動詞辞書ボタン
        let krVerbButton = createButton(title: "🇰🇷 → 🇯🇵 動詞、形容詞", color: UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0), icon: "figure.walk", action: #selector(openVerbDictionary))
        
        // 韓国語 名詞辞書ボタン
        let krNounButton = createButton(title: "🇰🇷 → 🇯🇵 名詞など", color: UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 1.0), icon: "book", action: #selector(openWordDictionary))
        
        // 日本語→韓国語 動詞辞書ボタン
        let jpVerbButton = createButton(title: "🇯🇵 → 🇰🇷 動詞、形容詞", color: UIColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 1.0), icon: "figure.walk", action: #selector(openJapaneseVerbDictionary))
        
        // 日本語→韓国語 名詞辞書ボタン
        let jpNounButton = createButton(title: "🇯🇵 → 🇰🇷 名詞など", color: UIColor(red: 0.3, green: 0.7, blue: 0.8, alpha: 1.0), icon: "book", action: #selector(openJapaneseNounDictionary))
        
        // 苦手単語表示ボタンの追加
        let jpKrFavoritesButton = createButton(
            title: "🇯🇵 → 🇰🇷 苦手単語",
            color: UIColor(red: 0.9, green: 0.4, blue: 0.4, alpha: 1.0),
            icon: "star.fill",
            action: #selector(openJpKrFavorites)
        )

        let krJpFavoritesButton = createButton(
            title: "🇰🇷 → 🇯🇵 苦手単語",
            color: UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0),
            icon: "star.fill",
            action: #selector(openKrJpFavorites)
        )
        
        // ボタンの配置
        let stackView = UIStackView(arrangedSubviews: [
            jpVerbButton,
            krVerbButton,
            jpNounButton,
            krNounButton,
            jpKrFavoritesButton,
            krJpFavoritesButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        

        
        
        // 制約の設定
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30)
        ])
    }
    
    // ボタンを作成するユーティリティ関数
    private func createButton(title: String, color: UIColor, icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        
        if #available(iOS 15.0, *) {
            // UIButtonConfigurationを使用
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: icon)
            config.imagePlacement = .leading // アイコンを左側に配置
            config.imagePadding = 10 // アイコンとテキストの間隔
            config.baseBackgroundColor = color // ボタン背景色
            config.baseForegroundColor = .white // テキストとアイコンの色
            
            button.configuration = config
        } else {
            // iOS 15未満の場合の従来の方法
            button.setTitle(" \(title)", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = color
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: action, for: .touchUpInside)
            button.setImage(UIImage(systemName: icon), for: .normal)
            button.tintColor = .white
            button.contentHorizontalAlignment = .left
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        }
        
        // 共通の制約
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    // MARK: - ボタンアクション
    
    @objc func openVerbDictionary() {
        let allQuestions = CSVLoader.loadCSV(from: "WordQuiz_Questions", forLanguage: "kr")
        let verbQuestions = filterQuestions(by: "verb", from: allQuestions)
        let verbDictionaryVC = VerbDictionaryViewController()
        verbDictionaryVC.questions = verbQuestions
        navigationController?.pushViewController(verbDictionaryVC, animated: true)
    }

    @objc func openWordDictionary() {
        let allQuestions = CSVLoader.loadCSV(from: "WordQuiz_Questions", forLanguage: "kr")
        let nounQuestions = filterQuestions(by: "noun", from: allQuestions)
        let wordDictionaryVC = WordDictionaryViewController()
        wordDictionaryVC.questions = nounQuestions
        navigationController?.pushViewController(wordDictionaryVC, animated: true)
    }
    
    @objc func openJapaneseVerbDictionary() {
        let allQuestions = CSVLoader.loadCSV(from: "WordQuiz_Questions", forLanguage: "kr")
        let verbQuestions = filterQuestions(by: "verb", from: allQuestions)
        let jpVerbDictionaryVC = JapaneseVerbDictionaryViewController()
        jpVerbDictionaryVC.questions = verbQuestions
        navigationController?.pushViewController(jpVerbDictionaryVC, animated: true)
    }
    
    @objc func openJapaneseNounDictionary() {
        let allQuestions = CSVLoader.loadCSV(from: "WordQuiz_Questions", forLanguage: "kr")
        let nounQuestions = filterQuestions(by: "noun", from: allQuestions)
        let jpNounDictionaryVC = JapaneseWordDictionaryViewController()
        jpNounDictionaryVC.questions = nounQuestions
        navigationController?.pushViewController(jpNounDictionaryVC, animated: true)
    }
    
    // 動詞や名詞をフィルタリングするユーティリティ関数
    func filterQuestions(by type: String, from questions: [QuestionProtocol]) -> [QuestionProtocol] {
        return questions.filter { question in
            if type == "verb" {
                return question.text.contains("verb")
            } else if type == "noun" {
                return question.text.contains("noun")
            }
            return false
        }
    }
    
    // MARK: - 苦手単語表示ボタンアクション
    @objc func openJpKrFavorites() {
        let favoritesVC = FavoriteViewControllerJP()
        favoritesVC.mode = "jp_kr"
        navigationController?.pushViewController(favoritesVC, animated: true)
    }

    @objc func openKrJpFavorites() {
        let favoritesVC = FavoriteViewControllerKR()
        favoritesVC.mode = "kr_jp"
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}
