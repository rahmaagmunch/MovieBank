//
//  MovieDetailViewModel.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import RxCocoa
import RxSwift

class MovieDetailViewModel {
    let viewDidLoad = PublishSubject<Void>()
    
    let movie: Driver<Movie>
    let reviews: Driver<[Review]>
    let videoId: Driver<String?>
    let isLoading: Driver<Bool>
    let error: Driver<String?>
    
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(movie: Movie, networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
        
        let movieRelay = BehaviorRelay<Movie>(value: movie)
        let reviewsRelay = BehaviorRelay<[Review]>(value: [])
        let videoIdRelay = BehaviorRelay<String?>(value: nil)
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = BehaviorRelay<String?>(value: nil)
        
        self.movie = movieRelay.asDriver()
        self.reviews = reviewsRelay.asDriver()
        self.videoId = videoIdRelay.asDriver()
        self.isLoading = loadingRelay.asDriver()
        self.error = errorRelay.asDriver()
        
        viewDidLoad
            .do(onNext: { loadingRelay.accept(true) })
            .flatMapLatest { [weak self] _ -> Observable<(ReviewResponse, VideoResponse)> in
                guard let self = self else { return .empty() }
                
                let reviews = self.networkService.fetchReviews(movieId: movie.id)
                let videos = self.networkService.fetchVideos(movieId: movie.id)
                
                return Observable.zip(reviews, videos)
                    .catch { error in
                        errorRelay.accept((error as? NetworkError)?.localizedDescription ?? error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { reviewResponse, videoResponse in
                reviewsRelay.accept(reviewResponse.results)
                
                let trailer = videoResponse.results.first { $0.type == "Trailer" && $0.site == "YouTube" }
                videoIdRelay.accept(trailer?.key)
                
                loadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
