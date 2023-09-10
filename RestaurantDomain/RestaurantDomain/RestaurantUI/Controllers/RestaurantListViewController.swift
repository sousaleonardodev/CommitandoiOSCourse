//

import Foundation
import UIKit

final class RestaurantListViewController: UITableViewController {
	private(set) var restaurantCollection: [RestaurantItemCellController] = []
	private var interactor: RestaurantListInteractorInput?

	convenience init(interactor: RestaurantListInteractorInput?) {
		self.init()
		self.interactor = interactor
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

		refresh()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		restaurantCollection.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		restaurantCollection[indexPath.row].renderCell()
	}

	@objc
	private func refresh() {
		interactor?.loadService()
	}
}

extension RestaurantListViewController: RestaurantListPresenterOutput {
	func setLoading(_ isLoading: Bool) {
		guard isLoading else {
			refreshControl?.endRefreshing()
			return
		}

		refreshControl?.beginRefreshing()
	}

	func setRestaurantItemsCell(_ items: [RestaurantItemCellController]) {
		restaurantCollection = items
		tableView.reloadData()
	}
}
