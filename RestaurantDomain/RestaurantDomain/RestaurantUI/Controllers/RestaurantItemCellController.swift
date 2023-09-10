//

import Foundation
import UIKit
import RestaurantDomain

final class RestaurantItemCellController {
	let viewModel: RestaurantItem

	init(viewModel: RestaurantItem) {
		self.viewModel = viewModel
	}

	func renderCell() -> UITableViewCell {
		let cell = RestaurantItemCell()

		cell.title.text = viewModel.name
		cell.location.text = viewModel.location
		cell.distance.text = viewModel.distanceToString
		cell.parasols.text = viewModel.parasolsToString
		cell.ratings.enumerated().forEach { (index, imageView) in
			let imageName = index < viewModel.ratings ? "star.fill" : "star"
			imageView.image = UIImage(named: imageName)
		}

		return cell
	}
}

private extension RestaurantItem {
	var parasolsToString: String {
		"Guarda-sois: \(parasols)"
	}

	var distanceToString: String {
		"Distância: \(distance)"
	}
}
