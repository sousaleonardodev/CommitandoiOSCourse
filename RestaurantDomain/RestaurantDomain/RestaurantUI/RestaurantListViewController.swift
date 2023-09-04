//

import Foundation
import RestaurantDomain
import UIKit

final class RestaurantListViewController: UIViewController {
	private var service: RestaurantLoader?
	private(set) var restaurants: [RestaurantItem] = []

	convenience init(service: RestaurantLoader) {
		self.init()
		self.service = service
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		service?.load{ result in
			switch result {
			case let .success(restaurants):
				self.restaurants = restaurants
			case let .failure(error):
				dump(error)
			}
		}
	}
}
