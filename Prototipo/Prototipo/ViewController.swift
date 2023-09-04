//

import UIKit

final class ViewController: UITableViewController {
	private lazy var models = RestaurantItemViewModel.dataModel

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		models.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestautantItemCell", for: indexPath) as? RestautantItemCell else {
			return UITableViewCell()
		}

		let model = models[indexPath.row]

		cell.title.text = model.title
		cell.location.text = model.location
		cell.distance.text = model.distance
		cell.ratings.enumerated().forEach { (index, imageView) in
			let imageName = index < model.rating ? "star.fill" : "star"
			imageView.image = UIImage(systemName: imageName)
		}

		return cell
	}
}

final class RestautantItemCell: UITableViewCell {
	@IBOutlet weak var title: UILabel!

	@IBOutlet private(set) var parasols: UILabel!
	@IBOutlet private(set) var location: UILabel!
	@IBOutlet private(set) var distance: UILabel!
	@IBOutlet private(set) var ratings: [UIImageView]!
}
