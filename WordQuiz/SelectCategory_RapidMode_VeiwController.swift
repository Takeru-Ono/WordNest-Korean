//
//  SelectCategory_RapidMode_VeiwController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/06/30.
import UIKit

class SelectCategory_RapidMode_ViewController: UIViewController {
    
    var selectedQuizMode: String? // 受け取ったクイズ形式を保持
    var category: String = "" // 追加: カテゴリを保存するプロパティ
    var categoryButtons: [UIButton] = [] // カテゴリボタンを保持する配列
    var scrollView: UIScrollView!

    
    let resourcePath = Bundle.main.resourcePath ?? ""
    // カテゴリー名の配列（タグに対応）
    lazy var categories: [String] = {
        CSVFileManager.fetchCSVFileNames(from: resourcePath)
    }()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCategoryButtons()
        // 戻った際に毎回アイコンをチェックして更新
        displayReviewIconsIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupCategoryButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let currentMode = selectedQuizMode {
            for (index, category) in categories.enumerated() {
                let button = categoryButtons[index]
                let hasIcon = button.subviews.contains { $0 is UIImageView }
                
                // アイコンの表示状態を保存
                updateIconDisplayedState(for: currentMode, category: category, isDisplayed: hasIcon)
            }
        }
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

        // ボタンの作成と追加
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
                line3 = finishDate
            } else {
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

        // アイコンのチェックと更新
        displayReviewIconsIfNeeded()
    }
    // ここでグローバルアイコン非表示状態をチェック
    // グローバル状態がOnの場合、全てのアイコンを非表示にし、以降の処理は行わない
    func displayReviewIconsIfNeeded() {
        guard let mode = selectedQuizMode else { return }
        
        // デバッグ用フォーマッタ
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        for (index, button) in categoryButtons.enumerated() {
            let category = categories[index]
            
            // モードとカテゴリーのGlobalアイコン状態を確認
            if getGlobalIconHiddenState(for: mode, category: category) {
                // Globalアイコンが非表示設定されている場合
                print("Global icon hidden for mode \(mode) and category \(category). Removing icon.")
                removeReviewIcon(from: button, for: category)
                continue
            }

            // 従来のロジックで次の復習日を確認
            if let nextReviewDate = getNextReviewDate(for: category, mode: mode) {
                print("Category: \(category)")
                print("Next Review Date for category \(category): \(dateFormatter.string(from: nextReviewDate))")
                print("Current Date: \(dateFormatter.string(from: Date()))")
                
                if Date() >= nextReviewDate {
                    print("Icon will be displayed for category \(category).")
                    addReviewIcon(to: button, for: category)
                } else {
                    print("Icon will NOT be displayed for category \(category).")
                    removeReviewIcon(from: button, for: category)
                }
            } else {
                print("No Next Review Date set for category \(category).")
            }
        }
    }

    // Globalアイコンの非表示状態を取得する関数
    func getGlobalIconHiddenState(for mode: String, category: String) -> Bool {
        let userKey = "\(mode)_\(category)_GlobalIconHidden"
        let value = UserDefaults.standard.bool(forKey: userKey)
        print("Retrieved global icon hidden state for key '\(userKey)': \(value)")
        return value
    }
    
    // アイコンの非表示状態を取得する関数
    func getIconHiddenState(for category: String, mode: String) -> Bool {
        let hiddenStateKey = "\(mode)_\(category)_IconHidden"
        let isHidden = UserDefaults.standard.bool(forKey: hiddenStateKey)
        
        // デバッグ用ログ
        print("Retrieved icon hidden state for key '\(hiddenStateKey)': \(isHidden)")
        return isHidden
    }
    
    // クイズ完了日を取得する関数
    func getCompletionDate(for category: String, mode: String) -> String? {
        
        let completionDateKey = "\(category)_\(mode)_completionDate"
        print("Retrieving completion date with key: \(completionDateKey)")
        if let date = UserDefaults.standard.object(forKey: completionDateKey) as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd" // 表示形式
            return dateFormatter.string(from: date)
            
        }
        
        return nil
    }
    
    func addReviewIcon(to button: UIButton, for category: String) {
        // ボタンのクリッピングを無効化（アイコンがボタン範囲外に表示されるように）
        button.clipsToBounds = false

        // 親ビュー（ボタンのスーパービュー）のクリッピングを無効化
        if let parentView = button.superview {
            parentView.clipsToBounds = false
        }
        // 既にアイコンがある場合は何もしない
        if button.subviews.contains(where: { $0 is UIImageView }) {
            return
        }

        // アイコン画像を作成
        let iconImageView = UIImageView(image: UIImage(named: "exclamation.png"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconImageView)

        // アイコンのサイズを1.2倍に設定
        let iconSize: CGFloat = 24 // 通常サイズが20なら1.2倍に
        let iconScale: CGFloat = 1.2

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize * iconScale),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize * iconScale),

            // ボタンの右上から外側にはみ出る位置にアイコンを配置
            iconImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: iconSize * 0.2),
            iconImageView.topAnchor.constraint(equalTo: button.topAnchor, constant: -(iconSize * 0.2))
        ])
        
        // アイコンを斜めに回転させる（例: 45度）
        let rotationAngle = CGFloat.pi / 7 // 45度
        iconImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)

        // 現在のモードとカテゴリーに基づいてアイコン表示状態を保存
        updateIconDisplayedState(for: selectedQuizMode, category: category, isDisplayed: true)
    }
    func removeReviewIcon(from button: UIButton, for category: String) {
        // ボタンのサブビューからUIImageViewを探して削除
        if let iconView = button.subviews.first(where: { $0 is UIImageView }) {
            iconView.removeFromSuperview()
        }

        // 現在のモードとカテゴリーに基づいてアイコン非表示状態を保存
        updateIconDisplayedState(for: selectedQuizMode, category: category, isDisplayed: false)
    }

    // アイコンの表示/非表示状態をUserDefaultsに保存する関数
    private func updateIconDisplayedState(for mode: String?, category: String, isDisplayed: Bool) {
        guard let mode = mode else {
            print("Error: selectedQuizMode is nil")
            return
        }

        // クイズモードとカテゴリーごとのキーを作成
        let key = "\(mode)_\(category)_IconDisplayed"
        UserDefaults.standard.set(isDisplayed, forKey: key)
        UserDefaults.standard.synchronize()

        // デバッグ用のログ
        let state = isDisplayed ? "true" : "false"
        print("Saved icon displayed state for key: '\(key)' with value: \(state)")
    }

    
    // クイズ完了日を取得
    func getQuizCompletionDate(for category: String, mode: String) -> Date? {
        let completionDateKey = "\(mode)_\(category)_completionDate"
        return UserDefaults.standard.object(forKey: completionDateKey) as? Date
    }
    

    func getNextReviewDate(for category: String, mode: String) -> Date? {
        // モードとカテゴリー名を組み合わせたキーを作成
        let nextReviewDateKey = "\(mode)_\(category)_nextReviewDate"
        
        // UserDefaultsから保存された文字列を取得
        if let dateString = UserDefaults.standard.string(forKey: nextReviewDateKey) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd" // 保存したフォーマットに合わせる

            // デバッグ: 取得した文字列を表示
            print("Retrieved Date String for key '\(nextReviewDateKey)': \(dateString)")
            
            // 文字列をDate型に変換
            if let date = dateFormatter.date(from: dateString) {
                return date
            } else {
                print("Failed to convert date string to Date for key '\(nextReviewDateKey)'.")
            }
        } else {
            print("No Next Review Date found in UserDefaults for key '\(nextReviewDateKey)'.")
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
            print("Error: UILabel not found.")
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
    
    // カテゴリーボタンがタップされた時の処理
    @objc func categoryButtonTapped(_ sender: UIButton) {
        let selectedCategory = categories[sender.tag - 1] // タグからカテゴリー名を取得
        category = selectedCategory // category に選択されたカテゴリー名を設定

        print("Category set to: \(category)") // デバッグ用プリント

        // 次の画面へ遷移
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if selectedQuizMode == "kr_jp_rapid" {
            if let rapidQuizVC = storyboard.instantiateViewController(withIdentifier: "RapidMode_ViewController") as? RapidMode_ViewController {
                rapidQuizVC.category = category // category を次の画面に渡す
                rapidQuizVC.selectedQuizMode = selectedQuizMode // モードも渡す
                self.navigationController?.pushViewController(rapidQuizVC, animated: true)
            }
        } else if selectedQuizMode == "jp_kr_rapid" {
            if let rapidQuizVC = storyboard.instantiateViewController(withIdentifier: "RapidMode_JP_ViewController") as? RapidMode_JP_ViewController {
                rapidQuizVC.category = category // category を次の画面に渡す
                rapidQuizVC.selectedQuizMode = selectedQuizMode // モードも渡す
                self.navigationController?.pushViewController(rapidQuizVC, animated: true)
            }
        }
    }

    // ボタン押下時のアニメーション
    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) // 押し込むアニメーション
        }
    }

    // ボタン押上時のアニメーション
    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity // 元に戻すアニメーション
        }
    }
}
