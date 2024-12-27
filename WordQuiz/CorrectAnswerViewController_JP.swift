//
//  CorrectAnswerViewController.swift
//  Word Quiz
//
//  Created by Takeru Ono on 11.06.2024.
//
import UIKit
import AVFoundation

protocol CorrectAnswerViewControllerDelegate_JP: AnyObject {
    func didCloseCorrectAnswerViewControllerJP()
}

class CorrectAnswerViewController_JP: UIViewController {

    var correctAnswerLabel: UILabel!
    var playAudioButton0: UIButton!
    var exampleSentenceLabel: UILabel!
    var exampleSentenceMeaningLabel: UILabel!
    var sentenceAudioButton: UIButton!
    var incorrectChoiceLabel1: UILabel!
    var incorrectChoiceLabel2: UILabel!
    var incorrectChoiceLabel3: UILabel!
    var playAudioButton1: UIButton!
    var playAudioButton2: UIButton!
    var playAudioButton3: UIButton!
    var separatorLine0: UIView!
    let exampleTitleLabel = UILabel()
    var sentenceMeaningTitleLabel: UILabel!
    var otherChoicesLabel: UILabel!
    var exampleStackView: UIStackView!
    
    let questionContainerView = UIView()

    var exampleSentence: (String, String)?
    var correctChoice: (String, String, String)? // (表示する単語, 音声用テキスト, 画像名だが今回は未使用)
    var incorrectChoices: [(String, String, String)] = []
    weak var delegateJP: CorrectAnswerViewControllerDelegate_JP?

    var speechSynthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()

        // タップで閉じる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateCorrectAnswerLabelConstraints()
        
        // 正解ラベルの上下余白を定義
        let correctAnswerLabelPadding: CGFloat = 30 // 上下余白（例として30pt）

        // コンテナの高さから正解ラベルとセパレートラインの高さ、余白を引く
        let remainingHeight = questionContainerView.frame.height
            - correctAnswerLabel.frame.height
            - correctAnswerLabelPadding * 2 // 上下余白
            - separatorLine0.frame.height

        // スタックビューの開始位置を計算
        let stackViewTop = separatorLine0.frame.maxY + remainingHeight * 0.25

        // スタックビューの制約を更新
        exampleStackView.topAnchor.constraint(equalTo: questionContainerView.topAnchor, constant: stackViewTop).isActive = true

    }
    
    func updateCorrectAnswerLabelConstraints() {
        // テキストに基づいてラベルのサイズを計算
        let labelSize = calculateLabelSize(for: correctAnswerLabel)
        
        // 制約を更新
        correctAnswerLabel.heightAnchor.constraint(equalToConstant: labelSize.height).isActive = true
        correctAnswerLabel.widthAnchor.constraint(equalToConstant: labelSize.width).isActive = true
    }
    func calculateLabelSize(for label: UILabel) -> CGSize {
        guard let text = label.text, let font = label.font else {
            return .zero
        }
        let maxSize = CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let textSize = (text as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).size
        return textSize
    }
    

    // UIのセットアップ
    func setupUI() {
        // コンテナビューの作成
        questionContainerView.translatesAutoresizingMaskIntoConstraints = false
        questionContainerView.backgroundColor = .white // 背景色を白に変更
        questionContainerView.layer.cornerRadius = 10 // 角を丸める
        questionContainerView.layer.borderColor = UIColor.black.cgColor // 枠線を黒に
        questionContainerView.layer.borderWidth = 1 // 枠線を細くする
        questionContainerView.layer.shadowColor = UIColor.black.cgColor // 影の色を黒に
        questionContainerView.layer.shadowOpacity = 0.2 // 影の透明度（0.0~1.0）
        questionContainerView.layer.shadowOffset = CGSize(width: 2, height: 2) // 影の位置
        questionContainerView.layer.shadowRadius = 4 // 影のぼかし半径
        view.addSubview(questionContainerView)

        // 正解ラベル
        correctAnswerLabel = UILabel()
        correctAnswerLabel.textAlignment = .center
        correctAnswerLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        correctAnswerLabel.numberOfLines = 2 // 1行に固定
        correctAnswerLabel.adjustsFontSizeToFitWidth = true // フォントサイズを自動調整
        correctAnswerLabel.minimumScaleFactor = 0.5 // 最小縮小率を指定
        correctAnswerLabel.lineBreakMode = .byClipping // テキストの切り捨てを防ぐ
        correctAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(correctAnswerLabel)
        
        // 正解音声ボタン
        playAudioButton0 = UIButton(type: .system)
        playAudioButton0.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton0.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton0.tintColor = .systemBlue
        playAudioButton0.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(playAudioButton0)
        
        // 仕切り線の作成
        separatorLine0 = UIView()
        separatorLine0.backgroundColor = .lightGray // 線の色
        separatorLine0.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorLine0)
        
        // 例文タイトルラベル
       
        exampleTitleLabel.text = "例文"
        exampleTitleLabel.font = UIFont.boldSystemFont(ofSize: 18) // 太字
        exampleTitleLabel.textColor = .darkGray
        exampleTitleLabel.translatesAutoresizingMaskIntoConstraints = false


        // 例文ラベル
        exampleSentenceLabel = UILabel()
        exampleSentenceLabel.numberOfLines = 1
        exampleSentenceLabel.textAlignment = .center
        exampleSentenceLabel.font = UIFont.systemFont(ofSize: 25)
        exampleSentenceLabel.translatesAutoresizingMaskIntoConstraints = false
        exampleSentenceLabel.adjustsFontSizeToFitWidth = true
        exampleSentenceLabel.minimumScaleFactor = 0.5 // 最小フォントサイズを指定
        
        // 例文音声ボタン
        sentenceAudioButton = UIButton(type: .system)
        sentenceAudioButton.translatesAutoresizingMaskIntoConstraints = false
        sentenceAudioButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        sentenceAudioButton.tintColor = .systemBlue
        sentenceAudioButton.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        
        
        // 意味タイトルラベル
        sentenceMeaningTitleLabel = UILabel()
        sentenceMeaningTitleLabel.text = "意味"
        sentenceMeaningTitleLabel.font = UIFont.boldSystemFont(ofSize: 18) // 太字
        sentenceMeaningTitleLabel.textColor = .darkGray
        sentenceMeaningTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        
        // 例文の意味ラベル
        exampleSentenceMeaningLabel = UILabel()
        exampleSentenceMeaningLabel.numberOfLines = 0
        exampleSentenceMeaningLabel.textAlignment = .center
        exampleSentenceMeaningLabel.font = UIFont.systemFont(ofSize: 20)
        exampleSentenceMeaningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // スタックビューを作成
        let exampleStackView = UIStackView()
        exampleStackView.axis = .vertical // 垂直方向に要素を配置
        exampleStackView.alignment = .fill // 要素を幅いっぱいに広げる
        exampleStackView.distribution = .equalSpacing // 垂直方向に均等に配置
        exampleStackView.spacing = 10 // 要素間の間隔を設定
        exampleStackView.translatesAutoresizingMaskIntoConstraints = false
        questionContainerView.addSubview(exampleStackView)
        
        // スタックビューに要素を追加
        exampleStackView.addArrangedSubview(exampleTitleLabel)
        exampleStackView.addArrangedSubview(exampleSentenceLabel)      // 例文ラベル
        exampleStackView.addArrangedSubview(sentenceAudioButton)       // 音声ボタン
        exampleStackView.addArrangedSubview(sentenceMeaningTitleLabel)
        exampleStackView.addArrangedSubview(exampleSentenceMeaningLabel) // 例文の意味ラベル

        // 制約を後で動的に計算するために viewDidLayoutSubviews を利用
        self.exampleStackView = exampleStackView
        
        // 他に選択肢ラベル
        otherChoicesLabel = UILabel()
        otherChoicesLabel.text = "他の選択肢"
        otherChoicesLabel.font = UIFont.boldSystemFont(ofSize: 18) // 太字
        otherChoicesLabel.textColor = .darkGray
        otherChoicesLabel.textAlignment = .left
        otherChoicesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(otherChoicesLabel)

        // 不正解選択肢1
        incorrectChoiceLabel1 = UILabel()
        incorrectChoiceLabel1.font = UIFont.systemFont(ofSize: 20)
        incorrectChoiceLabel1.textAlignment = .center
        incorrectChoiceLabel1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incorrectChoiceLabel1)

        playAudioButton1 = UIButton(type: .system)
        playAudioButton1.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton1.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton1.tintColor = .systemBlue
        playAudioButton1.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(playAudioButton1)

        // 不正解選択肢2
        incorrectChoiceLabel2 = UILabel()
        incorrectChoiceLabel2.font = UIFont.systemFont(ofSize: 20)
        incorrectChoiceLabel2.textAlignment = .center
        incorrectChoiceLabel2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incorrectChoiceLabel2)

        playAudioButton2 = UIButton(type: .system)
        playAudioButton2.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton2.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton2.tintColor = .systemBlue
        playAudioButton2.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(playAudioButton2)

        // 不正解選択肢3
        incorrectChoiceLabel3 = UILabel()
        incorrectChoiceLabel3.font = UIFont.systemFont(ofSize: 20)
        incorrectChoiceLabel3.textAlignment = .center
        incorrectChoiceLabel3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incorrectChoiceLabel3)

        playAudioButton3 = UIButton(type: .system)
        playAudioButton3.translatesAutoresizingMaskIntoConstraints = false
        playAudioButton3.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        playAudioButton3.tintColor = .systemBlue
        playAudioButton3.addTarget(self, action: #selector(playAudioButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(playAudioButton3)

        setupConstraints()
    }

    func setupConstraints() {
        let margin = view.layoutMarginsGuide
        
        let horizontalSpacing: CGFloat = 20
        let verticalSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // コンテナの位置とサイズ
            questionContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            questionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            questionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
            questionContainerView.bottomAnchor.constraint(equalTo: exampleStackView.bottomAnchor, constant: 20),
            
            // 正解ラベル
            correctAnswerLabel.topAnchor.constraint(equalTo: questionContainerView.topAnchor, constant: 30), // 上に配置
            correctAnswerLabel.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: 20),
            correctAnswerLabel.trailingAnchor.constraint(equalTo: playAudioButton0.leadingAnchor, constant: -10),

            // 正解音声ボタン
            playAudioButton0.centerYAnchor.constraint(equalTo: correctAnswerLabel.centerYAnchor), // ラベルの横に配置
            playAudioButton0.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -20),
            playAudioButton0.widthAnchor.constraint(equalToConstant: 30),
            playAudioButton0.heightAnchor.constraint(equalToConstant: 30),
            
            // 仕切り線
            separatorLine0.topAnchor.constraint(equalTo: correctAnswerLabel.bottomAnchor, constant: 30),
            separatorLine0.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: horizontalSpacing),
            separatorLine0.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -horizontalSpacing),
            separatorLine0.heightAnchor.constraint(equalToConstant: 1), // 線の高さを1に設定

            exampleStackView.topAnchor.constraint(equalTo: separatorLine0.bottomAnchor, constant: 30),
            exampleStackView.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: 20),
            exampleStackView.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -20),
            exampleStackView.bottomAnchor.constraint(lessThanOrEqualTo: questionContainerView.bottomAnchor, constant: -20),
        

            // 例文
            exampleSentenceLabel.topAnchor.constraint(equalTo: exampleTitleLabel.bottomAnchor, constant: 20),
            exampleSentenceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20), // 最低限の高さを指定
            
            // 例文の音声ボタンを例文ラベルの下中央に配置
            sentenceAudioButton.topAnchor.constraint(equalTo: exampleSentenceLabel.bottomAnchor, constant: 10),
            sentenceAudioButton.centerXAnchor.constraint(equalTo: questionContainerView.centerXAnchor), // 中央に配置
            sentenceAudioButton.widthAnchor.constraint(equalToConstant: 30),
            sentenceAudioButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 意味タイトルラベル
            sentenceMeaningTitleLabel.topAnchor.constraint(equalTo: sentenceAudioButton.bottomAnchor, constant: 5),

            // 例文の意味ラベルを音声ボタンの下に配置
            exampleSentenceMeaningLabel.topAnchor.constraint(equalTo: sentenceMeaningTitleLabel.bottomAnchor, constant: 10),
            exampleSentenceMeaningLabel.leadingAnchor.constraint(equalTo: questionContainerView.leadingAnchor, constant: 20),
            exampleSentenceMeaningLabel.trailingAnchor.constraint(equalTo: questionContainerView.trailingAnchor, constant: -20),
            exampleSentenceMeaningLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20), // 最低限の高さを指定
            
            // 他に選択肢ラベル
            otherChoicesLabel.topAnchor.constraint(equalTo: questionContainerView.bottomAnchor, constant: 30),
            otherChoicesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20),
            otherChoicesLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            // 間違いの選択肢1
            incorrectChoiceLabel1.topAnchor.constraint(equalTo: otherChoicesLabel.bottomAnchor, constant: 20), // コンテナ外に配置
            incorrectChoiceLabel1.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 40),

            playAudioButton1.centerYAnchor.constraint(equalTo: incorrectChoiceLabel1.centerYAnchor),
            playAudioButton1.leadingAnchor.constraint(equalTo: incorrectChoiceLabel1.trailingAnchor, constant: 10),
            playAudioButton1.widthAnchor.constraint(equalToConstant: 30),
            playAudioButton1.heightAnchor.constraint(equalToConstant: 30),

            // 間違いの選択肢2
            incorrectChoiceLabel2.topAnchor.constraint(equalTo: incorrectChoiceLabel1.bottomAnchor, constant: 40), // 選択肢1の下に配置
            incorrectChoiceLabel2.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 40),

            playAudioButton2.centerYAnchor.constraint(equalTo: incorrectChoiceLabel2.centerYAnchor),
            playAudioButton2.leadingAnchor.constraint(equalTo: incorrectChoiceLabel2.trailingAnchor, constant: 10),
            playAudioButton2.widthAnchor.constraint(equalToConstant: 30),
            playAudioButton2.heightAnchor.constraint(equalToConstant: 30),

            // 間違いの選択肢3
            incorrectChoiceLabel3.topAnchor.constraint(equalTo: incorrectChoiceLabel2.bottomAnchor, constant: 40), // 選択肢2の下に配置
            incorrectChoiceLabel3.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 40),

            playAudioButton3.centerYAnchor.constraint(equalTo: incorrectChoiceLabel3.centerYAnchor),
            playAudioButton3.leadingAnchor.constraint(equalTo: incorrectChoiceLabel3.trailingAnchor, constant: 10),
            playAudioButton3.widthAnchor.constraint(equalToConstant: 30),
            playAudioButton3.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func populateData() {
        if let correctChoice = correctChoice {
            let japaneseText = "\(correctChoice.0)" // 日本語部分
            let meaningText = "- \(correctChoice.1)" // 意味部分
            correctAnswerLabel.text = "\(japaneseText)\n\(meaningText)"
        }

        // 例文がなければ例文ラベルと音声ボタンを非表示
        if let exampleSentence = exampleSentence, !exampleSentence.0.isEmpty {
            exampleSentenceLabel.text = "\(exampleSentence.0)"
            exampleSentenceMeaningLabel.text = "\(exampleSentence.1)"
            
            exampleSentenceLabel.isHidden = false
            exampleSentenceMeaningLabel.isHidden = false
            sentenceAudioButton.isHidden = false
        } else {
            exampleSentenceLabel.isHidden = true
            exampleSentenceMeaningLabel.isHidden = true
            sentenceAudioButton.isHidden = true
        }

        if incorrectChoices.count >= 3 {
            incorrectChoiceLabel1.text = "\(incorrectChoices[0].0) - \(incorrectChoices[0].1)"
            incorrectChoiceLabel2.text = "\(incorrectChoices[1].0) - \(incorrectChoices[1].1)"
            incorrectChoiceLabel3.text = "\(incorrectChoices[2].0) - \(incorrectChoices[2].1)"
        }
    }

    @objc func playAudioButtonTapped(_ sender: UIButton) {
        var choiceText = ""
        switch sender {
        case playAudioButton0:
            if let correctChoice = correctChoice {
                choiceText = correctChoice.1
            }
        case sentenceAudioButton:
            if let exampleSentence = exampleSentence {
                choiceText = exampleSentence.0
            }
        case playAudioButton1:
            choiceText = incorrectChoices[0].0
        case playAudioButton2:
            choiceText = incorrectChoices[1].0
        case playAudioButton3:
            choiceText = incorrectChoices[2].0
        default:
            break
        }

        guard !choiceText.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: choiceText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        speechSynthesizer.speak(utterance)
    }

    @objc func dismissViewController() {
        dismiss(animated: true) {
            self.delegateJP?.didCloseCorrectAnswerViewControllerJP()
        }
    }
}
