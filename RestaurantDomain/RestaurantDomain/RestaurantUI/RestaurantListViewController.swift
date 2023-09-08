//

import Foundation
import UIKit

final class RestaurantListViewController: UITableViewController {
	var restaurantCollection = [RestaurantItemCellController]() {
		didSet {
			tableView.reloadData()
		}
	}

	private var refreshController: RefreshController?

	convenience init(refreshController: RefreshController) {
		self.init()
		self.refreshController = refreshController
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = refreshController?.view
		refreshController?.refresh()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		restaurantCollection.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		restaurantCollection[indexPath.row].renderCell()
	}
}
