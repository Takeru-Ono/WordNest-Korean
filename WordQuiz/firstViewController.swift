//
//  firstViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/06/26.
//
import UIKit
import AppTrackingTransparency  //追加
import AdSupport  //追加
import SafariServices


class FirstViewController: UIViewController, SettingsViewControllerDelegate, SFSafariViewControllerDelegate {
    func didSelectDesign(forCategory category: String) {
    }
    

    var selectedQuizMode: String? // クイズ形式を保存するためのプロパティ
    var bottomButtons: [UIButton] = [] // 下部ボタン（辞書、設定、About）




    // ボタン配列
    var buttons: [UIButton] = []
    var labels: [UILabel] = [] // 日本語→韓国語、韓国語→日本語のラベル用


    override func viewDidLoad() {
        super.viewDidLoad()
        // 戻るボタンを非表示にする
        self.navigationItem.hidesBackButton = true
        setupQuizSectionFlags() // 国旗アイコンを設定
        setupQuizButtons() // クイズボタンをセットアップ
        setupBottomButtons()
        // 初期設定
        DispatchQueue.main.async {
            self.updateFirstViewIcons(buttons: self.buttons)
        }
        
        let openTutorialButton = UIButton(type: .system)
        openTutorialButton.setTitle("チュートリアルを開く", for: .normal)
        openTutorialButton.addTarget(self, action: #selector(openTutorial), for: .touchUpInside)
        openTutorialButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openTutorialButton)

        NSLayoutConstraint.activate([
            openTutorialButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openTutorialButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])


    }
    
    private var iconsInitialized = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !iconsInitialized {
            updateFirstViewIcons(buttons: buttons)
            iconsInitialized = true
        }
    }
    
    @objc func openTutorial() {
        guard let url = URL(string: "https://takeru-ono.github.io/my-tutorial-page/") else {
            print("Invalid URL")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("SafariViewControllerを閉じました")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.updateFirstViewIcons(buttons: self.buttons)
        }
        
        //ATT対応
//        if #available(iOS 14, *) {
//            switch ATTrackingManager.trackingAuthorizationStatus {
//            case .authorized:
//                print("Allow Tracking")
//                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
//            case .denied:
//                print("拒否")
//            case .restricted:
//                print("制限")
//            case .notDetermined:
//                showRequestTrackingAuthorizationAlert()
//            @unknown default:
//                fatalError()
//            }
//        } else {// iOS14未満
//            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//                print("Allow Tracking")
//                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
//            } else {
//                print("制限")
//            }
//        }
        


    }
    

    
    ///Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😥")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
    
    func addOrUpdateReviewIcon(to button: UIButton, for category: String, isDisplayed: Bool) {
        // サブビューに既にアイコンがある場合は削除
        button.subviews
            .filter { $0 is UIImageView && $0.accessibilityIdentifier == "reviewIcon" }
            .forEach { $0.removeFromSuperview() }

        if isDisplayed {
            // ボタンのクリッピングを無効化
            button.clipsToBounds = false
            button.superview?.clipsToBounds = false

            // アイコンを新規追加
            let iconImageView = UIImageView(image: UIImage(named: "exclamation.png"))
            iconImageView.accessibilityIdentifier = "reviewIcon" // 識別用IDを設定
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(iconImageView)

            // アイコンのサイズと位置を設定
            let iconSize: CGFloat = 24 // 基本サイズ
            let iconScale: CGFloat = 1.2 // アイコンを1.5倍に拡大

            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: iconSize * iconScale),
                iconImageView.heightAnchor.constraint(equalToConstant: iconSize * iconScale),

                // ボタンの右上から外側にはみ出す位置にアイコンを配置
                iconImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: iconSize * 0.2),
                iconImageView.topAnchor.constraint(equalTo: button.topAnchor, constant: -(iconSize * 0.2))
            ])

            // アイコンを斜めに回転させる（例: 30度）
            let rotationAngle = CGFloat.pi / 7 // 30度
            iconImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)

            // アイコンを最前面に表示
            button.bringSubviewToFront(iconImageView)

//            print("Added icon for button with frame: \(button.frame)")
        } else {
//            print("Removed icon for button with frame: \(button.frame)")
        }

        // アイコン表示状態を保存
        updateIconDisplayedState(for: category, isDisplayed: isDisplayed)
    }
    
    func updateFirstViewIcons(buttons: [UIButton]) {
        let modes = ["jp_kr_normal", "kr_jp_normal", "jp_kr_rapid", "kr_jp_rapid", "jp_kr_number", "kr_jp_number"]
        // カテゴリー名の配列（タグに対応）
        let resourcePath = Bundle.main.resourcePath ?? ""
        let categories = CSVFileManager.fetchCSVFileNames(from: resourcePath)


        for (index, mode) in modes.enumerated() {
            // モード全体の状態をチェック
            checkAndUpdateModeIconDisplayed(for: mode, categories: categories)

            // モードのキーを取得してアイコン表示
            let button = buttons[index]
            let modeKey = "\(mode)_IconDisplayed"
            let modeIconDisplayed = UserDefaults.standard.bool(forKey: modeKey)

//            print("Checking mode '\(mode)': Icon displayed = \(modeIconDisplayed)")

            if modeIconDisplayed {
//                print("Calling addOrUpdateReviewIcon for mode: \(mode)")
                // アイコンを表示
                addOrUpdateReviewIcon(to: button, for: "Mode", isDisplayed: true)

            } else {
                // アイコンを非表示
                addOrUpdateReviewIcon(to: button, for: "Mode", isDisplayed: false)
//                print("No icon needed for mode: \(mode)")
            }
        }
    }
    
    
    /// 日本語→韓国語、韓国語→日本語を表す国旗を設定
    func setupQuizSectionFlags() {
        // 日本語→韓国語ラベル
        let japanToKoreaLabel = UILabel()
        japanToKoreaLabel.text = "🇯🇵 → 🇰🇷" // 日本国旗→韓国国旗
        japanToKoreaLabel.font = UIFont.systemFont(ofSize: 30) // サイズ調整
        japanToKoreaLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(japanToKoreaLabel)

        // 韓国語→日本語ラベル
        let koreaToJapanLabel = UILabel()
        koreaToJapanLabel.text = "🇰🇷 → 🇯🇵" // 韓国国旗→日本国旗
        koreaToJapanLabel.font = UIFont.systemFont(ofSize: 30)
        koreaToJapanLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(koreaToJapanLabel)

        // レイアウト制約
        NSLayoutConstraint.activate([
            // 日本語→韓国語ラベル
            japanToKoreaLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            japanToKoreaLabel.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: UIScreen.main.bounds.width * 0.265), // 左側中央寄り

            // 韓国語→日本語ラベル
            koreaToJapanLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            koreaToJapanLabel.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIScreen.main.bounds.width * 0.265) // 右側中央寄り
        ])
        view.sendSubviewToBack(japanToKoreaLabel)
        view.sendSubviewToBack(koreaToJapanLabel)
        japanToKoreaLabel.alpha = 1.0
        koreaToJapanLabel.alpha = 1.0
    }
    
    /// 下部ボタン（辞書、設定、About）をセットアップ
    func setupBottomButtons() {
        let buttonTitles = [
            ("辞書", #selector(openDictionary)),
            ("設定", #selector(openSettings)),
            ("About", #selector(openAbout))
        ]

        for (title, action) in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = UIColor.systemGray6
            button.setTitleColor(UIColor.label, for: .normal)
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            bottomButtons.append(button)
            view.addSubview(button)
        }

        setupBottomButtonConstraints()
    }

    /// 下部ボタンの制約を設定
    func setupBottomButtonConstraints() {
        guard !bottomButtons.isEmpty else { return }

        let _: CGFloat = 15 // ボタン間のスペース
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 50

        for (index, button) in bottomButtons.enumerated() {
            NSLayoutConstraint.activate([
                button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])

            if index == 0 {
                // 最初のボタンを左寄せ
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
            } else if index == bottomButtons.count - 1 {
                // 最後のボタンを右寄せ
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
            } else {
                // 中央のボタンを正確に中央に配置
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            }
        }
    }
    
    func setupDictionaryButton() {
        let dictionaryButton = UIButton(type: .system)
        dictionaryButton.setTitle("辞書", for: .normal)
        dictionaryButton.setTitleColor(.white, for: .normal)
        dictionaryButton.backgroundColor = .systemBlue
        dictionaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dictionaryButton.layer.cornerRadius = 10
        dictionaryButton.translatesAutoresizingMaskIntoConstraints = false
        dictionaryButton.addTarget(self, action: #selector(openDictionary), for: .touchUpInside)
        
        view.addSubview(dictionaryButton)

        // 辞書ボタンのレイアウトを設定
        NSLayoutConstraint.activate([
            dictionaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dictionaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            dictionaryButton.widthAnchor.constraint(equalToConstant: 150),
            dictionaryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func openDictionary() {
        // 辞書画面に遷移
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let dictionaryVC = storyboard.instantiateViewController(withIdentifier: "DictionaryViewController") as? DictionaryViewController {
            navigationController?.pushViewController(dictionaryVC, animated: true)
        }
    }
    
    @objc func openAbout() {
        // About画面に遷移
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let aboutVC = storyboard.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
            navigationController?.pushViewController(aboutVC, animated: true)
        }
    }
    

    
    func checkAndUpdateModeIconDisplayed(for mode: String, categories: [String]) {
        var modeIconDisplayed = false

        for category in categories {
            let key = "\(mode)_\(category)_IconDisplayed"
            if UserDefaults.standard.bool(forKey: key) {
                modeIconDisplayed = true
                break // 1つでもtrueがあれば終了
            }
        }

        // モード全体のアイコン表示状態を保存
        let modeKey = "\(mode)_IconDisplayed"
        UserDefaults.standard.set(modeIconDisplayed, forKey: modeKey)
        UserDefaults.standard.synchronize()

        // デバッグログ
        _ = modeIconDisplayed ? "true" : "false"
//        print("Mode icon display state for '\(mode)': \(state)")
    }


    
    @objc func buttonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }

    
    // アイコンをボタンの右上に追加する関数
    func addReviewIcon(to button: UIButton, for category: String) {
        // 既にアイコンがある場合は何もしない
        if button.subviews.contains(where: { $0 is UIImageView }) {
            return
        }

        let iconImageView = UIImageView(image: UIImage(named: "exclamation.png"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -5),
            iconImageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 5)
        ])
        
        button.bringSubviewToFront(iconImageView) // アイコンを最前面に表示
        // デバッグログ
//        print("Added icon to button: \(button)")
//        print("Icon Frame: \(iconImageView.frame)")
//        print("Button Frame: \(button.frame)")
//        print("Icon alpha: \(iconImageView.alpha), isHidden: \(iconImageView.isHidden)")

        // アイコン表示状態を保存し、FirstViewのアイコン表示状態も更新
        updateIconDisplayedState(for: category, isDisplayed: true)
//        print("Added icon to button: \(button)")
    }

    // アイコンをボタンから削除する関数
    func removeReviewIcon(from button: UIButton, for category: String) {
        // ボタンのサブビューからUIImageViewを探して削除
        if let iconView = button.subviews.first(where: { $0 is UIImageView }) {
            iconView.removeFromSuperview()
        }

        // アイコン非表示状態を保存し、FirstViewのアイコン表示状態も更新
        updateIconDisplayedState(for: category, isDisplayed: false)
    }

    // アイコンの表示/非表示状態をUserDefaultsに保存する関数
    private func updateIconDisplayedState(for category: String, isDisplayed: Bool) {
        // 各カテゴリーのアイコン表示状態を保存
        let key = "\(category)_IconDisplayed"
        UserDefaults.standard.set(isDisplayed, forKey: key)
        
        // カテゴリー全体のアイコン表示状態をチェックして更新
        updateFirstViewIconDisplayedState()
        
        // デバッグ用のログ
        _ = isDisplayed ? "true" : "false"
//        print("Saved icon displayed state for category: '\(category)' with value: \(state)")
    }

    // FirstViewのアイコン表示状態を更新する関数
    private func updateFirstViewIconDisplayedState() {
        // アイコン表示状態を持つすべてのカテゴリーを取得（必要に応じて設定）
        let resourcePath = Bundle.main.resourcePath ?? ""
        let categories = CSVFileManager.fetchCSVFileNames(from: resourcePath)
        
        // 1つでもアイコンが表示されていればFirstViewIconDisplayedをtrueにする
        let isAnyIconDisplayed = categories.contains { category in
            return UserDefaults.standard.bool(forKey: "\(category)_IconDisplayed")
        }

        // FirstViewのアイコン表示状態を保存
        UserDefaults.standard.set(isAnyIconDisplayed, forKey: "FirstViewIconDisplayed")
        
        // デバッグ用のログ
        _ = isAnyIconDisplayed ? "true" : "false"
//        print("FirstViewIconDisplayed is now set to \(state)")
    }


    @objc func openSettings() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settingsVC.delegate = self
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }

    // MARK: - クイズボタンのセットアップ
    func setupQuizButtons() {

        let relaxedGreen = UIColor(red: 57/255.0, green: 198/255.0, blue: 66/255.0, alpha: 1.0)   // ゆっくり (#39C642)
        let orangeColor = UIColor(red: 239/255.0, green: 140/255.0, blue: 24/255.0, alpha: 1.0) // タイムアタック (#EF8C18)
        let blueColor = UIColor(red: 25/255.0, green: 126/255.0, blue: 223/255.0, alpha: 1.0)   // 数字クイズ (#197EDF)

        let buttonTitles = [
            (
                "ゆっくり",
                #selector(startJapaneseToKoreanQuiz),
                #selector(startKoreanToJapaneseQuiz),
                relaxedGreen,
                "tortoise.fill"
            ),
            (
                "タイムアタック",
                #selector(startJapaneseToKoreanRapidQuiz),
                #selector(startKoreanToJapaneseRapidQuiz),
                orangeColor,
                "hare.fill"
            ),
            (
                "数字クイズ",
                #selector(startJapaneseToKoreanNumberQuiz),
                #selector(startKoreanToJapaneseNumberQuiz),
                blueColor,
                "123.rectangle.fill"
            )
        ]
        
        
        for (index, title) in buttonTitles.enumerated() {
            let leftButton = createButton(title: title.0, action: title.1, color: title.3, iconName: title.4)
            let rightButton = createButton(title: title.0, action: title.2, color: title.3, iconName: title.4)

            buttons.append(contentsOf: [leftButton, rightButton])
            view.addSubview(leftButton)
            view.addSubview(rightButton)

            // 左ボタンの制約
            NSLayoutConstraint.activate([
                leftButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(index) * 60 + 100),
                leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30), // 左から30ポイントの余白
                leftButton.widthAnchor.constraint(equalToConstant: 150),
                leftButton.heightAnchor.constraint(equalToConstant: 50)
            ])

            // 右ボタンの制約
            NSLayoutConstraint.activate([
                rightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CGFloat(index) * 60 + 100),
                rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30), // 右から30ポイントの余白
                rightButton.widthAnchor.constraint(equalToConstant: 150),
                rightButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        for button in buttons {
            view.bringSubviewToFront(button)
        }
        
        
    }
    /// ボタン作成
    func createButton(title: String, action: Selector, color: UIColor, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // ボタンの外観を設定
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = color
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: iconName) // アイコンを設定
        config.imagePadding = 10 // アイコンとテキストの間のスペース
        config.imagePlacement = .leading // アイコンを左に配置
        config.title = title // テキストを設定
        config.titleAlignment = .center // テキストを中央揃え
        config.cornerStyle = .medium // 角丸を適用

        button.configuration = config
        button.alpha = 1.0 // ボタンの透明度を明示的に設定
        button.translatesAutoresizingMaskIntoConstraints = false
        config.baseBackgroundColor = UIColor { traitCollection in
            return UIColor(red: 0.85, green: 0.93, blue: 0.88, alpha: 1.0) // 必要ならモードごとに調整
            
        }
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        return button
    }
    
    
    // クイズの選択処理
    @objc func startKoreanToJapaneseQuiz() {
        selectedQuizMode = "kr_jp_normal"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    @objc func startKoreanToJapaneseRapidQuiz() {
        selectedQuizMode = "kr_jp_rapid"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    @objc func startJapaneseToKoreanQuiz() {
        selectedQuizMode = "jp_kr_normal"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    @objc func startJapaneseToKoreanRapidQuiz() {
        selectedQuizMode = "jp_kr_rapid"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    @objc func startKoreanToJapaneseNumberQuiz() {
        selectedQuizMode = "kr_jp_number"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    @objc func startJapaneseToKoreanNumberQuiz() {
        selectedQuizMode = "jp_kr_number"
//        print("Selected mode: \(String(describing: selectedQuizMode))")  // デバッグ用ログ
        navigateToCategorySelection()
    }

    func navigateToCategorySelection() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if selectedQuizMode == "kr_jp_normal" || selectedQuizMode == "jp_kr_normal" {
            if let selectCategoryVC = storyboard.instantiateViewController(withIdentifier: "SelectCategoryViewController") as? SelectCategoryViewController {
                selectCategoryVC.selectedQuizMode = selectedQuizMode
                self.navigationController?.pushViewController(selectCategoryVC, animated: true)
            }
        } else if selectedQuizMode == "kr_jp_rapid" || selectedQuizMode == "jp_kr_rapid" {
            if let selectCategoryVC = storyboard.instantiateViewController(withIdentifier: "SelectCategory_RapidMode_ViewController") as? SelectCategory_RapidMode_ViewController {
                selectCategoryVC.selectedQuizMode = selectedQuizMode
                self.navigationController?.pushViewController(selectCategoryVC, animated: true)
            }
        } else if selectedQuizMode == "kr_jp_number" || selectedQuizMode == "jp_kr_number" {
            if let selectCategoryVC = storyboard.instantiateViewController(withIdentifier: "SelectNumberCategoryViewController") as? SelectNumberCategoryViewController {
                selectCategoryVC.selectedQuizMode = selectedQuizMode
                self.navigationController?.pushViewController(selectCategoryVC, animated: true)
            }
        }
    }
}
