//
//  SelectCategoryViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/06/26.
//
import UIKit

class SelectCategoryViewController: UIViewController {
    
    var selectedQuizMode: String? // 受け取ったクイズ形式を保持
    // ボタンを保持する配列
    var categoryButtons: [UIButton] = []
    var category: String = "" // 追加: カテゴリを保存するプロパティ
    var scrollView: UIScrollView!
    
    let resourcePath = Bundle.main.resourcePath ?? ""
    // カテゴリー名の配列（タグに対応）
    lazy var categories: [String] = {
        CSVFileManager.fetchCSVFileNames(from: resourcePath)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カテゴリのプリント
//        print("Fetched categories: \(categories)")
        
        setupScrollView()
        setupCategoryButtons()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCategoryButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupScrollView() {
        // スクロールビューの設定
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // スクロールビューの制約
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }

    func setupCategoryButtons() {
        // 既存のボタンを削除
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        categoryButtons.removeAll()
        
        // タイトルラベルの作成と追加
        let titleLabel = UILabel()
        titleLabel.text = "カテゴリーを選んでください"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(titleLabel)

        // タイトルラベルの制約
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            titleLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // カテゴリーの分類
        var nounCategories = categories.filter { $0.contains("noun") }
        var verbCategories = categories.filter { $0.contains("verb") }
        let otherCategories = categories.filter { !$0.contains("noun") && !$0.contains("verb") }

        var orderedCategories: [String] = []

        // 名詞と動詞を交互に並べる
        while !nounCategories.isEmpty || !verbCategories.isEmpty {
            if let noun = nounCategories.first {
                orderedCategories.append(noun)
                nounCategories.removeFirst()
            }
            if let verb = verbCategories.first {
                orderedCategories.append(verb)
                verbCategories.removeFirst()
            }
        }
        // その他のカテゴリーを最後に追加
        orderedCategories.append(contentsOf: otherCategories)

        
        var nounCount = 0
        var verbCount = 0
        var otherCount = 0
        
        // レイアウト設定
        let buttonSize: CGFloat = 80 // ボタンのサイズ
        let spacing: CGFloat = 10   // ボタン間のスペース
        let sideMargin: CGFloat = 20 // 両サイドのマージン
        let columns = Int((view.frame.width - (sideMargin * 2) + spacing) / (buttonSize + spacing)) // 列の数

        var x: CGFloat = sideMargin
        var y: CGFloat = 70 // タイトルラベルの下から配置開始

        
        for (index, category) in orderedCategories.enumerated() {
            let button = UIButton(type: .system)
            var line1: String = "その他"
            let line2: String = "前回プレイした日:"
            var line3: String = ""
            
            if category.contains("noun") {
                nounCount += 1
                line1 = "名詞 \(nounCount)"
                button.backgroundColor = UIColor(red: 72/255.0, green: 201/255.0, blue: 176/255.0, alpha: 1.0)
            } else if category.contains("verb") {
                verbCount += 1
                line1 = "動詞 \(verbCount)"
                button.backgroundColor = UIColor(red: 165/255.0, green: 105/255.0, blue: 189/255.0, alpha: 1.0)
            } else {
                otherCount += 1
                line1 = "その他 \(otherCount)"
                button.backgroundColor = UIColor.lightGray
            }
            
            // 日付取得
            if let finishDate = getCompletionDate(for: category, mode: selectedQuizMode ?? "") {
//                print("Finish Date found: \(finishDate)")
                line3 = finishDate
            } else {
//                print("No Finish Date found")
                line3 = "未完了"
            }
            
            // ボタンのテキストを構成
            let fullText = line1 + "\n" + line2 + " " + line3
            let attributedString = NSMutableAttributedString(string: fullText)

              if let firstLineBreakRange = fullText.range(of: "\n") {
                  let firstLineLength = fullText.distance(from: fullText.startIndex, to: firstLineBreakRange.lowerBound)
                  attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 0, length: firstLineLength))

                  let secondLineStart = firstLineLength + 1
                  let line2Length = line2.count
                  attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: secondLineStart, length: line2Length))

                  let line3Start = secondLineStart + line2Length + 1
                  let line3Length = fullText.count - line3Start
                  attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: line3Start, length: line3Length))
              }
            button.setAttributedTitle(attributedString, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.layer.borderWidth = 0

            button.tag = index + 1
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

            categoryButtons.append(button)
            scrollView.addSubview(button)

            // ボタンのフレームを計算
            if index % columns == 0 && index > 0 {
                x = sideMargin
                y += buttonSize + spacing
            }
            button.frame = CGRect(x: x, y: y, width: buttonSize, height: buttonSize)
            x += buttonSize + spacing
        }
        // スクロールビューのコンテンツサイズを設定
        let contentHeight = y + buttonSize + spacing
        scrollView.contentSize = CGSize(width: view.frame.width, height: contentHeight)
    }
    
    // アイコンをボタンの右上に追加する関数
    func addReviewIcon(to button: UIButton) {
        // アイコンの画像を設定
        let iconImageView = UIImageView(image: UIImage(named: "exclamation.png"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconImageView)

        // アイコンを右上に配置
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -5), // ボタンの右上に配置
            iconImageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 5)
        ])
    }

    // クイズ完了日を取得する関数
    func getCompletionDate(for category: String, mode: String) -> String? {
        
        let completionDateKey = "\(category)_\(mode)_completionDate"
//        print("Retrieving completion date with key: \(completionDateKey)")
        if let date = UserDefaults.standard.object(forKey: completionDateKey) as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd" // 表示形式
            return dateFormatter.string(from: date)
            
        }
        
        return nil
    }
    
    // ボタンを4列で正方形に配置するための制約を設定
    func setupButtonConstraints() {
        let screenWidth = UIScreen.main.bounds.width // 画面の幅を取得
        let buttonSize: CGFloat = 80 // ボタンのサイズ
        let spacing: CGFloat = 10 // ボタン間の間隔
        let columns = 4 // 列の数
        let sideMargin: CGFloat = 20 // 両サイドに設ける余白

        // 両サイドに余白を加えた画面の幅で4等分
        let adjustedWidth = screenWidth - (sideMargin * 2)
        let sectionWidth = adjustedWidth / CGFloat(columns) // 画面を4分割

        // ラベルが存在することを安全に確認する
        guard let titleLabel = view.subviews.first(where: { $0 is UILabel }) else {
//            print("Error: UILabel not found.")
            return
        }

        for (index, button) in categoryButtons.enumerated() {
            let row = index / columns
            let column = index % columns
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
            
            // X軸の中央位置を計算して、ボタンをその位置に配置
            let centerXPosition = sideMargin + sectionWidth * CGFloat(column) + sectionWidth / 2
            button.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: centerXPosition).isActive = true

            // ボタンの最初の行をラベルの下に配置する
            if row == 0 {
                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            } else {
                let previousButton = categoryButtons[index - columns]
                button.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: spacing).isActive = true
            }
        }
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        // デバッグログ
//        print("Button \(sender.tag) tapped in SelectCategoryViewController")

        // タグを基にカテゴリを取得
        guard sender.tag > 0, sender.tag <= categories.count else {
//            print("Error: Invalid button tag or out of range")
            return
        }

        let selectedCategory = categories[sender.tag - 1]
//        print("Selected category: \(selectedCategory)")

        // ストーリーボードを取得
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // 選択したクイズモードに基づいて画面遷移
        if selectedQuizMode == "kr_jp_normal" {
            if let quizVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                quizVC.category = selectedCategory
                quizVC.selectedQuizMode = selectedQuizMode
                self.navigationController?.pushViewController(quizVC, animated: true)
            }
        } else if selectedQuizMode == "jp_kr_normal" {
            if let quizVC = storyboard.instantiateViewController(withIdentifier: "ViewController_JP") as? ViewController_JP {
                quizVC.category = selectedCategory
                quizVC.selectedQuizMode = selectedQuizMode
                self.navigationController?.pushViewController(quizVC, animated: true)
            }
        } else {
//            print("Error: Unsupported quiz mode: \(selectedQuizMode ?? "nil")")
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
}
