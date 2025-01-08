//
//  CSVLoader.swift
//  WordQuiz
//
//  Created by Takeru Ono on 09.06.2024.
//
import Foundation

// 1. 共通プロトコルを定義
protocol QuestionProtocol {
    var text: String { get }
    var correctAnswer: String { get }
    var correctEnglishName: String? { get }
    var exampleSentence: String { get }
    var exampleSentenceMeaning: String { get }
    var exampleSentenceMeaningEnglish: String? { get }
    var correctHiragana: String? { get }
    var choices: [(String, String, String)] { get }
}

// 2. Question と Question_Jp をプロトコルに準拠させる
struct Question: QuestionProtocol {
    var text: String
    var correctAnswer: String
    var correctEnglishName: String? // 英語名
    var exampleSentence: String
    var exampleSentenceMeaning: String
    var exampleSentenceMeaningEnglish: String? // 例文の英訳
    var correctHiragana: String? // ひらがな読み
    var choices: [(String, String, String)]
}

struct Question_Jp: QuestionProtocol {
    var text: String
    var correctAnswer: String
    var correctEnglishName: String? // 英語名
    var exampleSentence: String
    var exampleSentenceMeaning: String
    var exampleSentenceMeaningEnglish: String? // 例文の英訳
    var correctHiragana: String? // ひらがな読み
    var choices: [(String, String, String)]
}

// 3. CSVLoaderクラスで、どちらの型も読み込めるようにする
class CSVLoader {
    
    static func loadAllQuestions(from categories: [String], forLanguage language: String) -> [QuestionProtocol] {
        var allQuestions: [QuestionProtocol] = []

        for category in categories {
            allQuestions += loadCSV(from: category, forLanguage: language)
        }

        return allQuestions
    }
    
    
    static func loadCSV(from csvFile: String, forLanguage language: String) -> [QuestionProtocol] {
        var questions: [QuestionProtocol] = []
        
        guard let path = Bundle.main.path(forResource: csvFile, ofType: "csv") else {
            return questions
        }
        
        do {
            let csvData = try String(contentsOfFile: path)
            // 改行コードを処理
            let rows = csvData.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n").map { $0.split(separator: ",") }
            
            // 1行目をスキップするために、配列の先頭を削除
            let dataRows = Array(rows.dropFirst())
            
            for (_, row) in dataRows.enumerated() {
                
                guard row.count >= 3 else {
                    continue
                }
                
                // 言語によって読み込む列を変更
                let text: String
                let correctAnswer: String
                let correctEnglishName: String
                
                if language == "jp" {
                    // 日本語から韓国語へ
                    text = String(row[1]) // 質問のテキスト (2列目)
                    correctAnswer = String(row[0]) // 正解のテキスト (1列目)
                } else {
                    // 韓国語から日本語へ
                    text = String(row[0]) // 質問のテキスト (1列目)
                    correctAnswer = String(row[1]) // 正解のテキスト (2列目)
                }
                
                correctEnglishName = String(row[2])// 正解の画像ファイル名 (3列目)
                // ひらがな列を読み取る
                let correctHiragana = row.count > 30 && !row[30].trimmingCharacters(in: .whitespaces).isEmpty ? String(row[30]) : nil
                
                // 例文とその意味が空の場合は空白文字列を設定
                let exampleSentence = row.count > 27 && !row[27].trimmingCharacters(in: .whitespaces).isEmpty ? String(row[27]) : ""
                let exampleSentenceMeaning = row.count > 28 && !row[28].trimmingCharacters(in: .whitespaces).isEmpty ? String(row[28]) : ""
                let exampleSentenceMeaningEnglish = row.count > 29 ? String(row[29]) : nil
                
                
                
                var choices: [(String, String, String)] = []
                
                // 不正解の選択肢を抽出
                let incorrectIndices = [3, 6, 9, 12, 15, 18, 21, 24]
                var incorrectChoices: [(String, String, String)] = []
                
                for i in incorrectIndices {
                    if i + 2 < row.count {
                        if language == "jp" {
                            // 日本語から韓国語へ
                            incorrectChoices.append((String(row[i]), String(row[i+1]), String(row[i+2])))
                        } else {
                            // 韓国語から日本語へ
                            incorrectChoices.append((String(row[i+1]), String(row[i]), String(row[i+2])))
                        }
                    } else {
                        
                        continue
                    }
                }
                
                // 不正解の選択肢から3つをランダムに選ぶ
                incorrectChoices.shuffle()
                choices = Array(incorrectChoices.prefix(3))
                
                // 正解の選択肢を追加
                choices.append((correctAnswer, correctAnswer, correctEnglishName))
                
                // Questionオブジェクトを作成
                if language == "jp" {
                    let question = Question_Jp(
                        text: text,
                        correctAnswer: correctAnswer,
                        correctEnglishName: correctEnglishName,
                        exampleSentence: exampleSentence,
                        exampleSentenceMeaning: exampleSentenceMeaning,
                        exampleSentenceMeaningEnglish: exampleSentenceMeaningEnglish,
                        correctHiragana: correctHiragana,
                        choices: choices
                    )
                    questions.append(question)
                } else {
                    let question = Question(
                        text: text,
                        correctAnswer: correctAnswer,
                        correctEnglishName: correctEnglishName,
                        exampleSentence: exampleSentence,
                        exampleSentenceMeaning: exampleSentenceMeaning,
                        exampleSentenceMeaningEnglish: exampleSentenceMeaningEnglish,
                        correctHiragana: correctHiragana,
                        choices: choices
                    )
                    questions.append(question)
                }
            }
        } catch {
        }
        
        return questions
    }
}



