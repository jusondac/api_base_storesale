# Storefront Management API

This API provides robust tools for managing storefronts, products, orders, and sales analytics. It includes authentication, authorization, and features for tracking inventory, orders, and performance metrics. Built with Rails 7.

## Features

### Version 1
- **Authentication & Authorization**
  - JWT-based login and signup.
  - Password recovery via email.
- **Basic Store Management**
  - CRUD for Products, Categories, and Customers.
- **Order Management**
  - Create, update, and delete orders.
  - Validate order items.
- **Rspec Tests**
  - Fully tested for all endpoints and models.

### Version 2
- **Advanced Features**
  - Sales analytics: revenue tracking, customer lifetime value, and sales trends.
  - Storefront management: associate products with storefronts and manage inventory.
  - Payment handling with invoices and tracking.
- **Refactored Services**
  - Simplified services for products, stock, restock, and payments.
- **Optimized Performance**
  - Indexing and relationships optimized for query performance.

### Version 3 (Upcoming)
- **Production Management**
  - Track raw materials, production stages, and final goods.
  - Supplier management with raw material restocking.
- **Employee Management**
  - Assign employees to specific tasks or storefronts.
- **Detailed Reporting**
  - Reports for sales, inventory, and production stages.

## Setup

### Prerequisites
- Ruby 3.1+
- Rails 7+
- SQLite (default) or PostgreSQL

### Installation
1. Clone the repository:
   ```bash
   git clone <repo_url>
   cd <repo_name>
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Setup the database:
   ```bash
   rails db:create db:migrate db:seed
   ```
4. Start the server:
   ```bash
   rails s
   ```

## API Endpoints - Version 1 (v1)

### Products
- `GET /api/v1/products` – List all products
- `POST /api/v1/products` – Create a new product
- `GET /api/v1/products/:id` – Show a specific product
- `PUT /api/v1/products/:id` – Update a product
- `DELETE /api/v1/products/:id` – Delete a product

### Categories
- `GET /api/v1/categories` – List all categories
- `POST /api/v1/categories` – Create a new category
- `GET /api/v1/categories/:id` – Show a specific category
- `PUT /api/v1/categories/:id` – Update a category
- `DELETE /api/v1/categories/:id` – Delete a category

### Customers
- `GET /api/v1/customers` – List all customers
- `POST /api/v1/customers` – Create a new customer
- `GET /api/v1/customers/:id` – Show a specific customer
- `PUT /api/v1/customers/:id` – Update a customer
- `DELETE /api/v1/customers/:id` – Delete a customer

### Orders
- `GET /api/v1/orders` – List all orders
- `POST /api/v1/orders` – Create a new order
- `GET /api/v1/orders/:id` – Show a specific order
- `PUT /api/v1/orders/:id` – Update an order
- `DELETE /api/v1/orders/:id` – Delete an order

#### Order Items
- `POST /api/v1/orders/:order_id/order_items` – Add an item to an order
- `DELETE /api/v1/orders/:order_id/order_items/:id` – Remove an item from an order

### Authentication
- `POST /api/v1/auth/signup` – Register a new user
- `POST /api/v1/auth/login` – Log in a user
- `GET /api/v1/auth/auto_login` – Auto login (optional)

---

## API Endpoints - Version 2 (v2)

### Analytics
- `GET /api/v2/analytics` – View analytics data

### Stocks
- `GET /api/v2/stocks` – List all stocks
- `GET /api/v2/stocks/:id` – Show a specific stock
- `PUT /api/v2/stocks/:id` – Update a stock

### Restocks
- `POST /api/v2/restocks` – Create a restock entry
- `GET /api/v2/restocks` – List all restocks
- `GET /api/v2/restocks/:id` – Show a specific restock entry

### Suppliers
- `GET /api/v2/suppliers` – List all suppliers
- `POST /api/v2/suppliers` – Create a new supplier

### Invoices
- `GET /api/v2/invoices` – List all invoices
- `GET /api/v2/invoices/:id` – Show a specific invoice

### Payments
- `GET /api/v2/payments` – List all payments
- `POST /api/v2/payments` – Create a payment

### Employees
- `GET /api/v2/employees` – List all employees

### Storefronts
- `GET /api/v2/storefronts` – List all storefronts
- `GET /api/v2/storefronts/:id` – Show a specific storefront
- `POST /api/v2/storefronts` – Create a new storefront
- `PUT /api/v2/storefronts/:id` – Update a storefront
- `DELETE /api/v2/storefronts/:id` – Delete a storefront

---

## Health Check
- `GET /up` – Returns `200` if the app is running without issues, `500` if there are errors. Used for uptime monitoring.

## Progressive Web App (PWA)
- `GET /service-worker` – Service Worker file for PWA functionality
- `GET /manifest` – Web App Manifest for PWA


## License

This project is licensed under the MIT License. See the LICENSE file for details.