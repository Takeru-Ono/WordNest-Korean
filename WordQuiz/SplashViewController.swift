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
        // 背景色を設定
        view.backgroundColor = UIColor(red: 126/255, green: 177/255, blue: 224/255, alpha: 1.0)
        
        
        // ロゴ画像ビューを追加
        let logoImageView = UIImageView(image: UIImage(named: "AppIcon")) // "splash_logo" を実際の画像名に置き換える
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        



        // ロゴの制約を設定 (画面全体にする)
        // ロゴの制約を設定 (中央少し上に配置し、大きくする)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 水平方向で中央揃え
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50), // 垂直方向で中央から少し上に移動
            logoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6), // 幅を画面の60%に設定
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor) // 高さは幅と同じ比率（正方形）
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
