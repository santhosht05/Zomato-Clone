# 🍔 SwadhaFood — Zomato Clone

A fully featured, modern food ordering and delivery web application built using **Java Servlets**, **JSP**, **Maven**, and **MySQL**. SwadhaFood recreates the core user experiences and administrative workflows of Zomato, featuring custom styled UI components, responsive pages, and automated setup.

---

## 🚀 Key Features

### 👤 Customer Experience
* **User Authentication**: Secure signup and login with role-based redirection.
* **Interactive Dashboard**: Custom landing page displaying high-rated restaurants and popular dishes.
* **Dynamic Menu & Search**: Explore items per restaurant, browse dishes, and filter options.
* **Seamless Cart Management**: Add, update, and remove items with real-time price calculations.
* **Favorites / Wishlist**: Save favorite restaurants for quick access.
* **Mock Checkout & Payments**: Interactive credit/debit card simulated payments.
* **Order History**: Track past orders and view delivery statuses.

### 💼 Admin Management Panel
* **Restaurant Management**: Create, edit, and delete restaurants.
* **Menu Control**: Add and manage dishes, prices, and descriptions.
* **Order Tracking**: Monitor customer orders and update dispatch status.
* **User Overview**: Track registered users and roles.

---

## 🛠️ Technology Stack

* **Backend Logic**: Java Servlets (Servlet API 5.0 / Tomcat 10)
* **Frontend templating**: JSP (JavaServer Pages), JSTL
* **Database Layer**: MySQL 8.0, JDBC (com.mysql.cj.jdbc.Driver)
* **Styling & Interaction**: Vanilla CSS, Modern JavaScript
* **Build Automation**: Apache Maven (Project Object Model)
* **Deployment & Web Server**: Apache Tomcat 10.1.x

---

## 📁 Repository Structure

```text
├── database/
│   └── swadhafood.sql       # Database schema and mock dataset
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── swadhafood/  # Java Servlets and Database Connection helper
│   │   └── webapp/
│   │       ├── css/         # Global stylesheets (style.css)
│   │       ├── js/          # Frontend interactive scripts (script.js)
│   │       ├── WEB-INF/     # Deployment descriptors & library dependencies
│   │       └── *.jsp        # JSP pages (index, login, cart, dashboard, etc.)
├── pom.xml                  # Maven configuration file
├── run.ps1                  # ⚡ Windows PowerShell automated setup & launch script
└── README.md                # Project documentation
```

---

## ⚡ Quick Start: Automated Execution (Windows)

The repository comes equipped with an automated script ([`run.ps1`](file:///e:/zomatocloning222/run.ps1)) that handles setting up Java dependencies, database migrations, server configurations, compilation, and launching the app in one command.

### Prerequisites
1. **Java JDK 17+** must be installed and defined in your system environment variable `JAVA_HOME`.
2. **MySQL Server** running locally.

### Steps to Run
1. Open **PowerShell** as Administrator.
2. Navigate to the project root directory:
   ```powershell
   cd e:\zomatocloning222
   ```
3. Run the setup script:
   ```powershell
   .\run.ps1
   ```

*What the script does automatically:*
* Connects to your local MySQL server and imports [`database/swadhafood.sql`](file:///e:/zomatocloning222/database/swadhafood.sql).
* Installs a local portable sandbox version of **Apache Maven** and **Apache Tomcat 10** under a temporary `/tomcat-setup/` folder.
* Modifies port settings to `8081` to prevent conflicts with other local server processes.
* Compiles the application, runs the Maven packaging step (`mvn clean package`), and deploys the resulting WAR file.
* Starts Tomcat and launches `http://localhost:8081/swadhafood/` automatically in your web browser.

---

## 🔧 Manual Setup (Any OS)

If you are not running Windows, or prefer setting up manually:

### 1. Database Setup
Import the SQL schema and seed data into your local MySQL database:
```bash
mysql -u root -p < database/swadhafood.sql
```

### 2. Configure Credentials
Open [`DBConnection.java`](file:///e:/zomatocloning222/src/main/java/swadhafood/DBConnection.java) and update your MySQL username and password variables:
```java
private static final String DB_USER = "root";
private static final String DB_PASS = "Santhosht@8"; // Update with your MySQL password
```

### 3. Compile and Package
Execute Maven package to generate the WAR build:
```bash
mvn clean package
```
This produces `target/swadhafood.war`.

### 4. Deploy
1. Copy the generated `swadhafood.war` file from the `target/` directory.
2. Paste it into the `webapps/` folder of your Apache Tomcat 10 installation directory.
3. Start Tomcat:
   * Windows: Run `bin/startup.bat`
   * Linux/macOS: Run `bin/startup.sh`
4. Access the web app at `http://localhost:8080/swadhafood/` (or whichever port your Tomcat is configured to).

---

## 🔒 Default Login Credentials (for testing)

To test user roles right away, use the following database seed credentials:

* **Customer Account**:
  * Email: `customer@gmail.com`
  * Password: `password123`
* **Admin Account**:
  * Email: `admin@gmail.com`
  * Password: `admin123`
