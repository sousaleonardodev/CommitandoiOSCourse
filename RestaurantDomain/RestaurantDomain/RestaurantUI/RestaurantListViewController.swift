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

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		restaurants.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let model = restaurants[indexPath.row]
		let cell = RestaurantItemCell()

		cell.title.text = model.name
		cell.location.text = model.location
		cell.distance.text = model.distanceToString
		cell.parasols.text = model.parasolsToString
		cell.ratings.enumerated().forEach { (index, imageView) in
			let imageName = index < model.ratings ? "star.fill" : "star"
			imageView.image = UIImage(named: imageName)
		}

		return cell
	}

	private func setupRefreshControll() {
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
	}

	@objc
	private func load() {
		refreshControl?.beginRefreshing()

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

final class RestaurantItemCell: UITableViewCell {
	private(set) var title = UILabel()
	private(set) var location = UILabel()
	private(set) var distance = UILabel()
	private(set) var parasols = UILabel()
	private(set) var ratings: [UIImageView] = {
		.init(repeating: UIImageView(), count: 5)
	}()
}

private extension RestaurantItem {
	var parasolsToString: String {
		"Guarda-sois: \(parasols)"
	}

	var distanceToString: String {
		"Distância: \(distance)"
	}
}
