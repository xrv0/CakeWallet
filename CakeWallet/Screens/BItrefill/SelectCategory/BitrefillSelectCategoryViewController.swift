import UIKit
import FlexLayout


final class BitrefillSelectCategoryViewController: BaseViewController<BitrefillSelectCategoryView>, BitrefillFetchCountryData, UITableViewDelegate, UITableViewDataSource {
    weak var bitrefillFlow: BitrefillFlow?
    var bitrefillCategories = [BitrefillCategory]()
    var bitrefillProducts = [BitrefillProduct]()
    
    init(bitrefillFlow: BitrefillFlow?, categories: [BitrefillCategory], products: [BitrefillProduct]) {
        self.bitrefillFlow = bitrefillFlow
        self.bitrefillProducts = products
        self.bitrefillCategories = categories
        
        super.init()
        
        tabBarItem = UITabBarItem(
            title: "Bitrefill",
            image: UIImage(named: "bitrefill_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "bitrefill_selected_icon")?.resized(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func viewDidLoad() {
        guard let selectedCountry = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.bitrefillSelectedCountry) else {
            bitrefillFlow?.change(route: .selectCountry)
            return
        }
        
        let btn = UIBarButtonItem(title: "Country", style: .plain, target: self, action: #selector(changeCountry))
        btn.setTitleTextAttributes([NSAttributedStringKey.font: applyFont(ofSize: 16)], for: .normal)
        navigationItem.rightBarButtonItem = btn
        
        if let country = BitrefillCountry(rawValue: selectedCountry) {
            bitrefillFetchCountryData(viewController: self, forCountry: country, handler: { [weak self] categories, products in
                self?.bitrefillCategories = categories
                self?.bitrefillProducts = products
                
                self?.contentView.table.reloadData()
                self?.contentView.loaderHolder.isHidden = true
            })
        }
    }
    
    @objc
    func changeCountry() {
        bitrefillFlow?.change(route: .selectCountry)
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        title = "Category"
        tabBarItem.title = "Bitrefill"
        
        contentView.table.delegate = self
        contentView.table.dataSource = self
        contentView.table.register(items: [BitrefillCategory.self])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bitrefillCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = bitrefillCategories[indexPath.row]
        return tableView.dequeueReusableCell(withItem: item, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategoryType = bitrefillCategories[indexPath.row].type
        let products = self.bitrefillProducts
        let categoryProducts = products.filter { $0.type == selectedCategoryType.rawValue }
        let sortedCategoryProducts = categoryProducts.sorted{ $0.name < $1.name }
        
        if sortedCategoryProducts.count > 0 {
            bitrefillFlow?.change(route: .productsList(sortedCategoryProducts))
        }
    }
}

extension BitrefillSelectCategoryViewController: BitrefillSelectCountryDelegate {
    func dataFromCountrySelect(categories: [BitrefillCategory], products: [BitrefillProduct]) {
        bitrefillCategories = categories
        bitrefillProducts = products
        
        contentView.loaderHolder.isHidden = true
        contentView.table.reloadData()
    }
}
