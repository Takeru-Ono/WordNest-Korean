//
//  CSVFileManager.swift
//  WordQuiz
//
//  Created by Takeru Ono on 2024/12/27.
//
import Foundation

class CSVFileManager {
    /// 指定ディレクトリ内のCSVファイル名を取得
    /// - Parameter directory: ディレクトリのパス
    /// - Returns: CSVファイル名の配列
    static func fetchCSVFileNames(from directory: String) -> [String] {
        var csvFileNames: [String] = []
        
        do {
            // ディレクトリ内のファイル一覧を取得
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: directory)
            
            // "csv" 拡張子のファイル名だけを抽出し、アルファベット順に並べ替え
            csvFileNames = fileNames.filter { $0.hasSuffix(".csv") }
                .sorted { lhs, rhs in
                    let lhsNumber = extractNumber(from: lhs)
                    let rhsNumber = extractNumber(from: rhs)
                    // 数字順で比較
                    if lhsNumber != rhsNumber {
                        return lhsNumber < rhsNumber
                    }
                    
                    // 数字が同じ場合はアルファベット順で比較
                    return lhs < rhs
                }
                .map { $0.replacingOccurrences(of: ".csv", with: "") }
            // 拡張子を除去
        } catch {
            
        }
        
        return csvFileNames
    }
    
    private static func extractNumber(from fileName: String) -> Int {
        // 数値部分を抽出
        let numbers = fileName.compactMap { $0.isNumber ? Int(String($0)) : nil }
        return numbers.reduce(0) { $0 * 10 + $1 } // 数字を結合して整数にする
    }
    
    static func loadVerbCategories() -> [String] {
        // リソースパスを取得
        let resourcePath = Bundle.main.resourcePath ?? ""
        let categories = CSVFileManager.fetchCSVFileNames(from: resourcePath)

        // "verb" を含むカテゴリーだけを抽出
        let verbCategories = categories.filter { $0.contains("verb") }
        
        return verbCategories
    }
    
    /// "noun" を含むカテゴリーだけを抽出
    /// - Returns: "noun" を含むカテゴリー名の配列
    static func loadNounCategories() -> [String] {
        // リソースパスを取得
        let resourcePath = Bundle.main.resourcePath ?? ""
        let categories = CSVFileManager.fetchCSVFileNames(from: resourcePath)

        // "noun" を含むカテゴリーだけを抽出
        let nounCategories = categories.filter { $0.contains("noun") }
    
        return nounCategories
    }
}
