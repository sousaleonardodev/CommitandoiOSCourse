//

import Foundation
import UIKit
import RestaurantDomain

final class RefreshController: NSObject {
	private(set) lazy var view: UIRefreshControl = setupRefreshControl()

	private let viewModel: RestaurantListViewModel
	init(viewModel: RestaurantListViewModel) {
		self.viewModel = viewModel
	}

	@objc
	func refresh() {
		viewModel.loadService()
	}

	private func setupRefreshControl() -> UIRefreshControl {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		viewModel.onLoadingState = { [weak self] isLoading in
			guard isLoading else {
				self?.view.endRefreshing()
				return
			}
			self?.view.beginRefreshing()
		}
		return refreshControl
	}
}
