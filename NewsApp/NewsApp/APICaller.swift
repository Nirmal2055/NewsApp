//
//  APICaller.swift
//  NewsApp
//
//  Created by Nirmal Koirala on 24/08/2022.
//

import Foundation
final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let TopHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=8f823decb07241a8ad2f7e759b559c40")
        
        static let searchUrlString = URL(string: "https://newsapi.org/v2/everything?sortBy=popularity&apiKey=8f823decb07241a8ad2f7e759b559c40&q=")

    }
        
    
    private init() {}
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        
        guard let url = Constants.TopHeadlinesURL else{
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles?.count ?? 0)")
                    completion(.success(result.articles ?? []))
                }
                catch let err {
                    print(err)
                    completion(.failure(err))
                }
            }
        }
        
        task.resume()
    }
    
    public func search(with query: String,  completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let searchUrl = Constants.searchUrlString?.absoluteString ?? ""
        let urlstring = searchUrl + query
        guard let url = URL(string: urlstring) else {
            return
        }
                let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error{
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles?.count ?? 0)")
                    completion(.success(result.articles ?? []))
                }
                catch let err {
                    print(err)
                    completion(.failure(err))
                }
            }
        }
        
        task.resume()
    }
}
//Models
struct APIResponse: Codable{
    let articles: [Article]?
}
 
struct Article: Codable{
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable{
    let name: String
    
}
