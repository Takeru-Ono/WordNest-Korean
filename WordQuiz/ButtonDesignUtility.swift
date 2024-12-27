//
//  ButtonDesignUtility.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/09/15.
//
import UIKit

class ButtonDesignUtility {

    // ボタン1のデザイン（フラットデザイン）
    static func applyButton1Design(to button: UIButton) {
        clearLayersAndStyles(from: button) // 既存のレイヤーとスタイルをクリア

        button.backgroundColor = UIColor.systemTeal
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.shadowOpacity = 0
    }

    // ボタン2のデザイン（グラデーションデザイン）
    static func applyButton2Design(to button: UIButton) {
        clearLayersAndStyles(from: button) // 既存のレイヤーとスタイルをクリア

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 10
        button.layer.insertSublayer(gradientLayer, at: 0)

        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
    }

    // ボタン3のデザイン（アウトラインデザイン）
    static func applyButton3Design(to button: UIButton) {
        clearLayersAndStyles(from: button) // 既存のレイヤーとスタイルをクリア

        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }

    // ボタン4のデザイン（カードデザイン）
    static func applyButton4Design(to button: UIButton) {
        clearLayersAndStyles(from: button) // 既存のレイヤーとスタイルをクリア

        button.backgroundColor = UIColor.systemGray6
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 5
    }

    // ボーダー、影、レイヤーをクリアするメソッド
    static func clearLayersAndStyles(from button: UIButton) {
        button.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }

        // ボーダーと影の設定をクリア
        button.layer.borderWidth = 0
        button.layer.borderColor = nil
        button.layer.shadowOpacity = 0
        button.layer.shadowColor = nil
        button.layer.shadowOffset = CGSize.zero
        button.layer.cornerRadius = 0
    }

    // デザイン適用
    static func applyDesign(to button: UIButton, designType: String = "design1") {
        switch designType {
        case "design1":
            applyButton1Design(to: button)
        case "design2":
            applyButton2Design(to: button)
        case "design3":
            applyButton3Design(to: button)
        case "design4":
            applyButton4Design(to: button)
        default:
            applyButton1Design(to: button)
        }
    }

    // 設定ボタンのデザイン適用
    static func applySettingsButtonDesign(to button: UIButton) {
        clearLayersAndStyles(from: button) // ボーダーや影をクリア
        button.tintColor = UIColor.systemBlue // 色を変更
        button.backgroundColor = .clear
    }

    // 背景デザインを設定するメソッド
    static func applyBackgroundDesign(to view: UIView, designType: String = "Background1") {
        clearBackground(view: view)
        
        switch designType {
        case "Background1":
            view.backgroundColor = UIColor.systemTeal // フラットな背景色
        case "Background2":
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0) // グラデーションを追加
        case "Background3":
            view.backgroundColor = UIColor.systemBackground
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.systemBlue.cgColor // 境界線を追加
        case "Background4":
            view.backgroundColor = UIColor.systemGray6
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.layer.shadowOffset = CGSize(width: 4, height: 4) // カードのような影を追加
            view.layer.shadowRadius = 5
        default:
            view.backgroundColor = UIColor.systemBackground
        }
    }

    // 背景デザインをクリアするメソッド
    static func clearBackground(view: UIView) {
        view.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        view.backgroundColor = .clear
    }

    // ボタンアニメーション追加
    static func addButtonAnimation(_ button: UIButton, target: Any, pressedAction: Selector, releasedAction: Selector) {
        button.addTarget(target, action: pressedAction, for: [.touchDown, .touchDragInside])
        button.addTarget(target, action: releasedAction, for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
}
