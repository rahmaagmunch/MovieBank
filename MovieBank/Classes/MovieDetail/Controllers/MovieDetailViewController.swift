//
//  MovieDetailViewController.swift
//  MovieBank
//
//  Created by Rahma Agustina on 23/01/26.
//

import UIKit
import youtube_ios_player_helper
import RxSwift

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(movie: Movie) {
        self.viewModel = MovieDetailViewModel(movie: movie)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ok")
        self.view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")

        setupBindings()
        viewModel.viewDidLoad.onNext(())
    }
    
    private func setupBindings() {
        let headerView = MovieDetailHeaderView.loadFromNib()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 500)
        tableView.tableHeaderView = headerView
        
        viewModel.movie
            .drive(onNext: { [weak self] movie in
                headerView.titleLabel.text = movie.title
                headerView.ratingLabel.text = "⭐️ \(String(format: "%.1f", movie.voteAverage)) (\(movie.voteCount) votes)"
                headerView.movieOverviewLabel.text = movie.overview
            })
            .disposed(by: disposeBag)
        
        viewModel.reviews
            .drive(tableView.rx.items(cellIdentifier: ReviewTableViewCell.reuseIdentifier, cellType: ReviewTableViewCell.self)) { _, review, cell in
                cell.configure(with: review)
            }
            .disposed(by: disposeBag)
        
        viewModel.videoId
            .drive(onNext: { [weak self] id in
                guard let videoId = id else { return }
                headerView.ytVideoPlayerView.load(
                    withVideoId: videoId,
                                    playerVars: [
                                        "playsinline": 1,
                                        "controls": 1,
                                        "modestbranding": 1
                                    ]
                                )
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
