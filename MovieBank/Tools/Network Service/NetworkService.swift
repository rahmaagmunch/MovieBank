//
//  NetworkService.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetchMovies(page: Int) -> Observable<MovieResponse>
    func fetchMovieDetails(id: Int) -> Observable<Movie>
    func fetchReviews(movieId: Int) -> Observable<ReviewResponse>
    func fetchVideos(movieId: Int) -> Observable<VideoResponse>
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let urlBuilder: URLBuilderProtocol
    
    init(session: URLSession = .shared,
         urlBuilder: URLBuilderProtocol = URLBuilder()) {
        self.session = session
        self.urlBuilder = urlBuilder
    }
    
    func fetchMovies(page: Int) -> Observable<MovieResponse> {
        guard let url = urlBuilder.buildMoviesURL(page: page) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return request(url: url)
    }
    
    func fetchMovieDetails(id: Int) -> Observable<Movie> {
        guard let url = urlBuilder.buildMovieDetailsURL(id: id) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return request(url: url)
    }
    
    func fetchReviews(movieId: Int) -> Observable<ReviewResponse> {
        guard let url = urlBuilder.buildReviewsURL(movieId: movieId) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return request(url: url)
    }
    
    func fetchVideos(movieId: Int) -> Observable<VideoResponse> {
        guard let url = urlBuilder.buildVideosURL(movieId: movieId) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return request(url: url)
    }
    
    private func request<T: Codable>(url: URL) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            let task = self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
                        observer.onError(NetworkError.noInternetConnection)
                    } else {
                        observer.onError(NetworkError.networkError(error))
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    observer.onError(NetworkError.serverError(httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkError.noData)
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    observer.onNext(decoded)
                    observer.onCompleted()
                } catch {
                    observer.onError(NetworkError.decodingError)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
