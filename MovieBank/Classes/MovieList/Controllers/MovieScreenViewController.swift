//
//  MovieScreenViewController.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import UIKit
import RxSwift

class MovieScreenViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieCollectionViewCell")
        collectionView.refreshControl = refreshControl
        
        view.addSubview(loadingIndicator)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        
        setupBindings()
    }

    private func setupBindings() {
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        viewModel.movies
            .drive(collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.reuseIdentifier, cellType: MovieCollectionViewCell.self)) { _, movie, cell in
                cell.configure(with: movie)
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .filter { [weak self] isLoading in
                self?.refreshControl.isRefreshing == false
            }
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
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .map { [weak self] offset -> Bool in
                guard let self = self else { return false }
                let contentHeight = self.collectionView.contentSize.height
                let scrollViewHeight = self.collectionView.frame.height
                return offset.y > contentHeight - scrollViewHeight - 200
            }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }
            .bind(to: viewModel.loadMoreTrigger)
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Movie.self)
            .subscribe(onNext: { [weak self] movie in
                print("selected movie \(movie.id)")
                self?.navigateToDetail(movie: movie)
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToDetail(movie: Movie) {
        let detailVC = MovieDetailViewController(movie: movie)
        print("navigationController \(navigationController)") // not nil
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MovieScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 16
        let totalSpacing: CGFloat = spacing * 3
        let itemWidth = (collectionView.bounds.width - totalSpacing) / 2
        let itemHeight = itemWidth * 1.8
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
}
