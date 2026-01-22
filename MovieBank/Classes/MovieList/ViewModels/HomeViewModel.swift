//
//  HomeViewModel.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    let loadMoreTrigger = PublishSubject<Void>()
    let refreshTrigger = PublishSubject<Void>()
    let movieSelected = PublishSubject<Movie>()
    
    let movies: Driver<[Movie]>
    let isLoading: Driver<Bool>
    let error: Driver<String?>
    
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    private var currentPage = 1
    private var canLoadMore = true
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = BehaviorRelay<String?>(value: nil)
        let moviesRelay = BehaviorRelay<[Movie]>(value: [])
        
        self.movies = moviesRelay.asDriver()
        self.isLoading = loadingRelay.asDriver()
        self.error = errorRelay.asDriver()
        
        let loadMore = loadMoreTrigger
            .filter { [weak self] _ in self?.canLoadMore ?? false }
            .filter { !loadingRelay.value }
            .share()
        
        let refresh = refreshTrigger
            .do(onNext: { [weak self] in
                self?.currentPage = 1
                self?.canLoadMore = true
            })
            .share()
        
        let loadRequest = Observable.merge(
            loadMore.map { [weak self] in self?.currentPage ?? 1 },
            refresh.map { 1 }
        )
        
        loadRequest
            .do(onNext: { _ in
                loadingRelay.accept(true)
                errorRelay.accept(nil)
            })
            .flatMapLatest { [weak self] page -> Observable<MovieResponse> in
                guard let self = self else { return .empty() }
                return self.networkService.fetchMovies(page: page)
                    .catch { error in
                        errorRelay.accept((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                
                if self.currentPage == 1 {
                    moviesRelay.accept(response.results)
                } else {
                    moviesRelay.accept(moviesRelay.value + response.results)
                }
                
                self.currentPage += 1
                self.canLoadMore = self.currentPage <= response.totalPages
                loadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        loadMoreTrigger.onNext(())
    }
}
