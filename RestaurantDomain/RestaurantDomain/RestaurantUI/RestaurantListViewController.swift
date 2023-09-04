//

import Foundation
import RestaurantDomain
import UIKit

final class RestaurantListViewController: UITableViewController {
	private var service: RestaurantLoader?
	private(set) var restaurants: [RestaurantItem] = []

	convenience init(service: RestaurantLoader) {
		self.init()
		self.service = service
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupRefreshControll()

		load()
	}

	private func setupRefreshControll() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
		refreshControl?.beginRefreshing()
	}

	@objc
	private func load() {
		service?.load{ [weak self] result in
			switch result {
			case let .success(restaurants):
				self?.restaurants = restaurants
			case let .failure(error):
				dump(error)
			}
			self?.refreshControl?.endRefreshing()
		}
	}
}
