import UIKit

class SelectNumberCategoryViewController: UIViewController {
    
    var selectedQuizMode: String? // 前の画面から渡されたクイズ形式（kr_jp_number, jp_kr_numberなど）
    
    // カテゴリー名と対応する識別子のリスト
    let categories: [(title: String, identifier: String, imageName: String)] = [
        ("漢数詞（0-100,100,10000）", "SequentialNumbers", "number.circle"),
        ("固有数詞（1−99）", "NativeKoreanNumbers", "character.book.closed"),
        ("ランダム日付クイズ", "Date", "calendar.circle"),
        ("ランダム時間クイズ", "Time", "clock.circle"),
        ("ランダム大きな数字クイズ", "LargeNumbers", "textformat.123"),
        ("ランダム数え方クイズ", "KoreanCounter", "list.number")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        // タイトルラベル
        let titleLabel = UILabel()
        titleLabel.text = "数字クイズのカテゴリー"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0 // 複数行対応
        titleLabel.lineBreakMode = .byWordWrapping // ワード単位での改行
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // スタックビューを用いてボタンを縦に並べる
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // 各カテゴリ用の色を定義（例）
        let colors: [UIColor] = [
            UIColor(red: 129/255.0, green: 199/255.0, blue: 132/255.0, alpha: 1.0), // 関数詞
            UIColor(red: 251/255.0, green: 140/255.0, blue: 0/255.0, alpha: 1.0),   // 固有数詞
            UIColor(red: 126/255.0, green: 87/255.0, blue: 194/255.0, alpha: 1.0),  // 日付
            UIColor(red: 39/255.0, green: 198/255.0, blue: 66/255.0, alpha: 1.0),   // 時間
            UIColor(red: 239/255.0, green: 140/255.0, blue: 24/255.0, alpha: 1.0),  // 大きな数字
            UIColor(red: 25/255.0, green: 126/255.0, blue: 223/255.0, alpha: 1.0)   // 数え方
        ]
        
        // カテゴリごとにボタンを生成
        for (index, category) in categories.enumerated() {
            let button = UIButton(type: .system)
            
            var config = UIButton.Configuration.filled()
            
            // AttributedString用の属性を設定
            var container = AttributeContainer()
            container.font = UIFont.boldSystemFont(ofSize: 18)
            container.foregroundColor = UIColor.white
            
            var attString = AttributedString(category.title)
            attString.mergeAttributes(container)
            
            config.attributedTitle = attString
            config.baseBackgroundColor = colors[index]
            config.cornerStyle = .medium
            config.image = UIImage(systemName: category.imageName)
            config.imagePadding = 10
            config.imagePlacement = .leading
            
            button.configuration = config
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.tag = index
            
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
        }
        
        // AutoLayout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20)
        ])
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        let selectedCategory = categories[sender.tag].identifier
        navigateToQuiz(category: selectedCategory)
    }

    private func navigateToQuiz(category: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let quizVC = storyboard.instantiateViewController(withIdentifier: "NumberQuizViewController") as? NumberQuizViewController {
            quizVC.selectedQuizMode = "\(selectedQuizMode ?? "")_\(category)"
            self.navigationController?.pushViewController(quizVC, animated: true)
        } else {
            print("NumberQuizViewController could not be instantiated")
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
