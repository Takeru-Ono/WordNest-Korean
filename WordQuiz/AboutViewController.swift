//
//  AboutViewController.swift
//  Word Quiz
//
//  Created by Takeru Ono on 2024/11/29.
//
import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        setupUI()
    }

    func setupUI() {
        
        // タイトルラベル
        let titleLabel = UILabel()
        titleLabel.text = "About"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // バージョン情報
        let versionLabel = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "バージョン: \(version)"
        } else {
            versionLabel.text = "バージョン情報: 不明"
        }
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)

        // ボタンを作成
        let buttons = [
            ("お問い合わせ", #selector(openContactForm)),
            ("プライバシーポリシー", #selector(openPrivacyPolicy)),
            ("利用規約", #selector(openTermsOfService)),
            ("ライセンス情報", #selector(openLicensePage)) // 新しいボタンを追加
        ]

        var previousElement: UIView? = versionLabel

        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = UIColor.systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: 50),
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

            if let previous = previousElement {
                button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 20).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40).isActive = true
            }

            previousElement = button
        }

        // レイアウトの制約
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func openContactForm() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self

            // 宛先
            mailComposeVC.setToRecipients(["snowflake86hello@gmail.com"])

            // 件名
            mailComposeVC.setSubject("お問い合わせ")

            // 本文に必要な情報を追加
            let deviceModel = UIDevice.current.model          // デバイスモデル（例: iPhone）
            let systemVersion = UIDevice.current.systemVersion // iOSのバージョン
            let systemName = UIDevice.current.systemName       // OSの名前（例: iOS）
            
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明"
            let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "不明"

            // メール本文のテンプレート
            let messageBody = """
            お問い合わせ内容をここにご記入ください。

            ---
            【アプリ情報】
            バージョン: \(appVersion)
            ビルド番号: \(buildVersion)

            【デバイス情報】
            機種: \(deviceModel)
            OS: \(systemName) \(systemVersion)

            【その他】
            特記事項があれば記載してください。
            ---
            """

            mailComposeVC.setMessageBody(messageBody, isHTML: false)

            // メールコンポーザーを表示
            present(mailComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: "メールが送信できません",
                message: "メールアプリが設定されていません。",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }

    @objc func openPrivacyPolicy() {
        if let url = URL(string: "http://glotnest.com/about/privacy-policy/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func openTermsOfService() {
        if let url = URL(string: "http://glotnest.com/about/terms-of-service/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func openLicensePage() {
        // ライセンス情報を表示
        if let url = URL(string: "http://glotnest.com/about/license-info/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MFMailComposeViewControllerDelegate メソッド
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
