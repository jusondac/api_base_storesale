# E-Commerce API (Version 1)
## Overview

This is a robust E-Commerce API built using Ruby on Rails. The project is designed to handle essential functionalities like managing products, categories, customers, and orders. It also includes JWT-based authentication for secure user access.
Features

## Authentication

- Signup/Login: Secure user registration and login.
- JWT-Based Authentication: Protects API endpoints and ensures secure access.

## Core Models

- Product: CRUD operations for managing product inventory.
- Category: Categorization of products.
- Customer: Manage customer data and relations.
- Order: Complex order creation with associated order items.

## Error Handling

- Friendly and descriptive error messages.
- Validation checks for empty or invalid data (e.g., order without items).

## Test Suite

- Comprehensive RSpec tests for controllers and authentication.
- Covers both success and failure scenarios.

# Installation
## Prerequisites

    Ruby ~> 3.0.0
    Rails ~> 7.0

## Setup Steps

Clone the repository:

```
git clone https://github.com/your-username/ecommerce-api.git
cd ecommerce-api
```

## Install dependencies:

```bundle install```

## Set up the database:

``` rails db:create db:migrate db:seed```

## Start the Rails server:

```rails s```

## Test the application:

``` rspec```

## The suite includes:

- Authentication tests.
- CRUD tests for products, categories, and orders.
- Error handling and edge cases.

## Future Plans

- Version 2: Inventory and sales analytics.
- Version 3: Production and advanced reporting.

## Contributions

Feel free to fork this repo, submit issues, or create pull requests. Contributions are always welcome!

## License

This project is licensed under the MIT License. See the LICENSE file for details.