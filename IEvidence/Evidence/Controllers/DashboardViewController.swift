import UIKit

class DashboardViewController: UIViewController {

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headingLabel = UILabel()
    private let welcomeLabel = UILabel()

    private let statsStack = UIStackView()

    private let casesHeadingLabel = UILabel()
    private let tableView = UITableView()
    private let searchController = UISearchController(
        searchResultsController: nil
    )

    private var filteredCases: [CaseModel] = []

    private let createCaseButton = UIButton(type: .system)
    
    private let activeCasesValueLabel = UILabel()
    private let closedCasesValueLabel = UILabel()
    private let evidenceValueLabel = UILabel()

    // MARK: - Sample Data

    private var cases: [CaseModel] = []

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cases = CaseStorage.shared.fetchCases()
        tableView.reloadData()

        updateDashboardStatistics()
    }

    private func updateDashboardStatistics() {

        let allCases = CaseStorage.shared.fetchCases()

        let activeCases = allCases.filter {
            $0.status.lowercased() == "active"
        }

        let closedCases = allCases.filter {
            $0.status.lowercased() == "closed"
        }

        let allEvidence = allCases.reduce(0) { total, caseItem in
            total + EvidenceStorage.shared.fetchEvidence(
                for: caseItem.caseNumber
            ).count
        }

        activeCasesValueLabel.text = "\(activeCases.count)"
        closedCasesValueLabel.text = "\(closedCases.count)"
        evidenceValueLabel.text = "\(allEvidence)"
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScreen()
        setupUI()
        setupConstraints()
        setupProfileButton()
        setupSearchController()
    }

    // MARK: - Screen Setup

    private func setupScreen() {
        view.backgroundColor = .systemGroupedBackground
        title = "Dashboard"
    }

    // MARK: - UI Setup

    private func setupUI() {

        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Main Vertical Stack
        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(contentStack)

        // Heading
        headingLabel.text = "iEvidence"
        headingLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headingLabel.textColor = .label

        // Welcome Message
        welcomeLabel.text = "Welcome, Investigator"
        welcomeLabel.font = .systemFont(ofSize: 17, weight: .medium)
        welcomeLabel.textColor = .secondaryLabel

        // Statistics
        let activeCasesCard = makeStatCard(
            title: "Active Cases",
            valueLabel: activeCasesValueLabel,
            symbol: "folder.fill"
        )

        let closedCasesCard = makeStatCard(
            title: "Closed Cases",
            valueLabel: closedCasesValueLabel,
            symbol: "checkmark.folder.fill"
        )

        let evidenceCard = makeStatCard(
            title: "Total Evidence",
            valueLabel: evidenceValueLabel,
            symbol: "doc.text.fill"
        )
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 10

        statsStack.addArrangedSubview(activeCasesCard)
        statsStack.addArrangedSubview(closedCasesCard)
        statsStack.addArrangedSubview(evidenceCard)

        // Recent Cases Heading
        casesHeadingLabel.text = "Recent Cases"
        casesHeadingLabel.font = .systemFont(ofSize: 21, weight: .bold)
        casesHeadingLabel.textColor = .label

        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CaseTableViewCell.self,
            forCellReuseIdentifier: "CaseCell"
        )
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true

        // Create Case Button
        createCaseButton.setTitle("＋  Create New Case", for: .normal)
        createCaseButton.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        createCaseButton.setTitleColor(.white, for: .normal)
        createCaseButton.backgroundColor = .systemBlue
        createCaseButton.layer.cornerRadius = 12
        createCaseButton.addTarget(
            self,
            action: #selector(createCaseTapped),
            for: .touchUpInside
        )

        // Add Components to Stack
        contentStack.addArrangedSubview(headingLabel)
        contentStack.addArrangedSubview(welcomeLabel)
        contentStack.addArrangedSubview(statsStack)
        contentStack.addArrangedSubview(casesHeadingLabel)
        contentStack.addArrangedSubview(tableView)
        contentStack.addArrangedSubview(createCaseButton)
    }

    // MARK: - Statistics Card

   
    private func makeStatCard(
        title: String,
        valueLabel: UILabel,
        symbol: String
    ) -> UIView {

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.separator.cgColor

        let icon = UIImageView()
        icon.image = UIImage(systemName: symbol)
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit

        valueLabel.font = .systemFont(ofSize: 25, weight: .bold)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 2

        let stack = UIStackView(
            arrangedSubviews: [icon, valueLabel, titleLabel]
        )
        stack.axis = .vertical
        stack.spacing = 7
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),
            card.heightAnchor.constraint(equalToConstant: 125)
        ])

        return card
    }


    // MARK: - Auto Layout

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            // Scroll View
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            // Content Stack
            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 25
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 18
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -18
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -25
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -36
            ),

            // Table View
            tableView.heightAnchor.constraint(equalToConstant: 240),

            // Create Case Button
            createCaseButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    // MARK: - Button Action

    @objc private func createCaseTapped() {

        let createCaseVC = CreateCaseViewController()

        let navigationController = UINavigationController(
            rootViewController: createCaseVC
        )

        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true)
    }
}

// MARK: - Table View Data Source

extension DashboardViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        if searchController.isActive {
            return filteredCases.count
        }

        return cases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CaseCell",
            for: indexPath
        ) as! CaseTableViewCell

        let currentCase: CaseModel

        if searchController.isActive {
            currentCase = filteredCases[indexPath.row]
        } else {
            currentCase = cases[indexPath.row]
        }

        cell.configure(
            number: currentCase.caseNumber,
            title: currentCase.caseTitle,
            status: currentCase.status
        )

        return cell
    }

}
extension DashboardViewController: UISearchResultsUpdating {

  
    func updateSearchResults(
        for searchController: UISearchController
    ) {
        let searchText = searchController.searchBar.text ?? ""

        if searchText.isEmpty {
            filteredCases = cases
        } else {
            filteredCases = cases.filter { caseItem in
                caseItem.caseNumber.localizedCaseInsensitiveContains(searchText) ||
                caseItem.firNumber.localizedCaseInsensitiveContains(searchText) ||
                caseItem.caseTitle.localizedCaseInsensitiveContains(searchText)
            }
        }

        tableView.reloadData()
    }
}

// MARK: - Table View Delegate

extension DashboardViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 80
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCase: CaseModel

        if searchController.isActive {
            selectedCase = filteredCases[indexPath.row]
        } else {
            selectedCase = cases[indexPath.row]
        }
        
        let detailVC = CaseDetailViewController()
        detailVC.caseDetails = selectedCase
        
        navigationController?.pushViewController(
            detailVC,
            animated: true
        )
        
    }
    
    
    // MARK: - Custom Case Cell
    
    class CaseTableViewCell: UITableViewCell {
        
        private let caseNumberLabel = UILabel()
        private let caseTitleLabel = UILabel()
        private let statusLabel = UILabel()
        
        override init(
            style: UITableViewCell.CellStyle,
            reuseIdentifier: String?
        ) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupCell()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupCell() {
            
            backgroundColor = .secondarySystemGroupedBackground
            selectionStyle = .none
            
            caseNumberLabel.font = .systemFont(
                ofSize: 12,
                weight: .medium
            )
            caseNumberLabel.textColor = .secondaryLabel
            
            caseTitleLabel.font = .systemFont(
                ofSize: 15,
                weight: .semibold
            )
            
            statusLabel.font = .systemFont(
                ofSize: 12,
                weight: .medium
            )
            statusLabel.textColor = .systemGreen
            
            let stack = UIStackView(
                arrangedSubviews: [
                    caseNumberLabel,
                    caseTitleLabel,
                    statusLabel
                ]
            )
            
            stack.axis = .vertical
            stack.spacing = 4
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(stack)
            
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 12
                ),
                stack.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -12
                ),
                stack.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                )
            ])
        }
        
        func configure(number: String, title: String, status: String) {
            
            caseNumberLabel.text = number
            caseTitleLabel.text = title
            statusLabel.text = status
        }
    }
    
    private func setupProfileButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Profile",
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
    }

    @objc private func profileTapped() {
        let profileVC = ProfileViewController()

        navigationController?.pushViewController(
            profileVC,
            animated: true
        )
    }
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search cases..."

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true
    }
}
