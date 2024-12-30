//
//  SplashViewController.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/12/28.
//
import UIKit

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        }
        
        // ロゴ画像ビューを追加
        let logoImageView = UIImageView(image: UIImage(named: "splash")) // "splash_logo" を実際の画像名に置き換える
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        // ロゴの制約を設定
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 一定時間後に FirstViewController に遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
              self.transitionToFirstViewController()
        }
    }

    private func transitionToFirstViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as? FirstViewController {
            self.navigationController?.pushViewController(firstVC, animated: true)
        } else {
//            print("Failed to instantiate FirstViewController.")
        }
    }
}
