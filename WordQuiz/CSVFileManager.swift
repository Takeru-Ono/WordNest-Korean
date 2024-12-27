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
            // "csv" 拡張子のファイル名だけを抽出
            csvFileNames = fileNames.filter { $0.hasSuffix(".csv") }
                .map { $0.replacingOccurrences(of: ".csv", with: "") } // 拡張子を除去
        } catch {
            print("Error fetching file names: \(error)")
        }
        
        return csvFileNames
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
