import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let rememberButton = UIButton()
    private let forgotPasswordButton = UIButton()
    
    private let loginButton = UIButton()
    private let footerLabel = UILabel()
    
    private var isPasswordVisible = false
    private var rememberMe = false
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Screen Setup
    
    private func setupScreen() {
        
        view.backgroundColor = UIColor(
            red: 0.95,
            green: 0.96,
            blue: 0.98,
            alpha: 1.0
        )
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        // Logo
        logoImageView.image = UIImage(systemName: "shield.lefthalf.filled")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit
        
        // Application title
        titleLabel.text = "iEvidence"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(
            red: 0.08,
            green: 0.15,
            blue: 0.28,
            alpha: 1
        )
        
        // Subtitle
        subtitleLabel.text = "Digital Evidence Management System"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .black
        subtitleLabel.textAlignment = .center
        // Email field
        emailTextField.placeholder = "Enter your email address"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.textContentType = .username
        emailTextField.textColor = .black

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your email address",
            attributes: [.foregroundColor: UIColor.black]
        )

        // Password field
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.textColor = .black

        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your password",
            attributes: [.foregroundColor: UIColor.black]
        )
        // Password visibility button
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(
            UIImage(systemName: "eye"),
            for: .normal
        )
        eyeButton.addTarget(
            self,
            action: #selector(togglePasswordVisibility),
            for: .touchUpInside
        )
        
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        // Style text fields
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
        
        // Remember me
        rememberButton.setTitle(" Remember me", for: .normal)
        rememberButton.setTitleColor(.black, for: .normal)
        rememberButton.setImage(
            UIImage(systemName: "square"),
            for: .normal
        )
        rememberButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        rememberButton.addTarget(
            self,
            action: #selector(toggleRememberMe),
            for: .touchUpInside
        )
        
        // Forgot password
        forgotPasswordButton.setTitle(
            "Forgot Password?",
            for: .normal
        )
        forgotPasswordButton.setTitleColor(.systemBlue, for: .normal)
        forgotPasswordButton.titleLabel?.font =
            .systemFont(ofSize: 14, weight: .medium)
        
        forgotPasswordButton.addTarget(
            self,
            action: #selector(forgotPasswordTapped),
            for: .touchUpInside
        )
        
        // Login button
        loginButton.setTitle("Sign In", for: .normal)
        loginButton.backgroundColor = UIColor(
            red: 0.08,
            green: 0.20,
            blue: 0.38,
            alpha: 1
        )
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font =
            .systemFont(ofSize: 17, weight: .semibold)
        loginButton.layer.cornerRadius = 12
        
        loginButton.addTarget(
            self,
            action: #selector(loginTapped),
            for: .touchUpInside
        )
        
        // Footer
        footerLabel.text = "Secure access for authorized personnel only"
        footerLabel.textAlignment = .center
        footerLabel.font = .systemFont(ofSize: 12)
        footerLabel.textColor = .secondaryLabel
        
        // Add components to screen
        let components: [UIView] = [
            logoImageView,
            titleLabel,
            subtitleLabel,
            emailTextField,
            passwordTextField,
            rememberButton,
            forgotPasswordButton,
            loginButton,
            footerLabel
        ]
        
        components.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Text Field Styling
    
    private func styleTextField(_ textField: UITextField) {
        
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        
        textField.font = .systemFont(ofSize: 15)
        
        textField.leftView = UIView(
            frame: CGRect(x: 0, y: 0, width: 15, height: 0)
        )
        
        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    // MARK: - Auto Layout
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            // Logo
            logoImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 65
            ),
            
            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 65),
            logoImageView.heightAnchor.constraint(equalToConstant: 65),
            
            // Title
            titleLabel.topAnchor.constraint(
                equalTo: logoImageView.bottomAnchor,
                constant: 18
            ),
            
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 25
            ),
            
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -25
            ),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            
            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            
            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),
            
            // Email
            emailTextField.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: 45
            ),
            
            emailTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 25
            ),
            
            emailTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -25
            ),
            
            // Password
            passwordTextField.topAnchor.constraint(
                equalTo: emailTextField.bottomAnchor,
                constant: 18
            ),
            
            passwordTextField.leadingAnchor.constraint(
                equalTo: emailTextField.leadingAnchor
            ),
            
            passwordTextField.trailingAnchor.constraint(
                equalTo: emailTextField.trailingAnchor
            ),
            
            // Remember me
            rememberButton.topAnchor.constraint(
                equalTo: passwordTextField.bottomAnchor,
                constant: 18
            ),
            
            rememberButton.leadingAnchor.constraint(
                equalTo: emailTextField.leadingAnchor
            ),
            
            // Forgot password
            forgotPasswordButton.centerYAnchor.constraint(
                equalTo: rememberButton.centerYAnchor
            ),
            
            forgotPasswordButton.trailingAnchor.constraint(
                equalTo: emailTextField.trailingAnchor
            ),
            
            // Login button
            loginButton.topAnchor.constraint(
                equalTo: rememberButton.bottomAnchor,
                constant: 30
            ),
            
            loginButton.leadingAnchor.constraint(
                equalTo: emailTextField.leadingAnchor
            ),
            
            loginButton.trailingAnchor.constraint(
                equalTo: emailTextField.trailingAnchor
            ),
            
            loginButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Footer
            footerLabel.topAnchor.constraint(
                equalTo: loginButton.bottomAnchor,
                constant: 35
            ),
            
            footerLabel.leadingAnchor.constraint(
                equalTo: emailTextField.leadingAnchor
            ),
            
            footerLabel.trailingAnchor.constraint(
                equalTo: emailTextField.trailingAnchor
            )
        ])
    }
    
    // MARK: - Password Visibility
    
    @objc private func togglePasswordVisibility() {
        
        isPasswordVisible.toggle()
        
        passwordTextField.isSecureTextEntry = !isPasswordVisible
    }
    
    // MARK: - Remember Me
    
    @objc private func toggleRememberMe() {
        
        rememberMe.toggle()
        
        let imageName = rememberMe
        ? "checkmark.square.fill"
        : "square"
        
        rememberButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
    
    // MARK: - Forgot Password
    
    @objc private func forgotPasswordTapped() {
        
        showAlert(
            title: "Forgot Password",
            message: "Password recovery will be connected to the backend."
        )
    }
    
    // MARK: - Login
    
    @objc private func loginTapped() {
        
        let email = emailTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let password = passwordTextField.text ?? ""
        
        guard !email.isEmpty else {
            
            showAlert(
                title: "Missing Email",
                message: "Please enter your email address."
            )
            return
        }
        
        guard email.contains("@"), email.contains(".") else {
            
            showAlert(
                title: "Invalid Email",
                message: "Please enter a valid email address."
            )
            return
        }
        
        guard password.count >= 8 else {
            
            showAlert(
                title: "Invalid Password",
                message: "Password must contain at least 8 characters."
            )
            return
        }
        
        let alert = UIAlertController(
            title: "Validation Successful",
            message: "Your information is ready for server authentication.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.openDashboard()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Alert
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        
        present(alert, animated: true)
    }
    private func openDashboard() {
        
        let dashboard = DashboardViewController()
        
        let navigationController = UINavigationController(
            rootViewController: dashboard
        )
        
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
}
