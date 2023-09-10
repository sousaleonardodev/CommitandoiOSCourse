//

import UIKit

final class RestaurantItemCell: UITableViewCell {
	private(set) var title = UILabel()
	private(set) var location = UILabel()
	private(set) var distance = UILabel()
	private(set) var parasols = UILabel()
	private(set) var ratings: [UIImageView] = {
		.init(repeating: UIImageView(), count: 5)
	}()
}
