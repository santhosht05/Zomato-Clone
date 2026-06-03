DROP DATABASE IF EXISTS swadhafood;
CREATE DATABASE swadhafood DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE swadhafood;

-- =============================================
-- Table: users
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    role ENUM('user','admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Table: restaurants
-- =============================================
CREATE TABLE IF NOT EXISTS restaurants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    cuisine VARCHAR(200) NOT NULL,
    image_url VARCHAR(500) DEFAULT '',
    rating DECIMAL(2,1) DEFAULT 4.0,
    delivery_time VARCHAR(20) DEFAULT '30-40 min',
    min_price INT DEFAULT 100,
    description TEXT,
    address VARCHAR(300),
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Table: foods
-- =============================================
CREATE TABLE IF NOT EXISTS foods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(500) DEFAULT '',
    description TEXT,
    category VARCHAR(100) DEFAULT 'Main Course',
    is_veg TINYINT(1) DEFAULT 1,
    is_available TINYINT(1) DEFAULT 1,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- =============================================
-- Table: cart
-- =============================================
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    food_id INT NOT NULL,
    quantity INT DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE CASCADE,
    UNIQUE KEY uq_user_food (user_id, food_id)
);

-- =============================================
-- Table: orders
-- =============================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_name VARCHAR(150),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('card','upi','cod') DEFAULT 'cod',
    payment_status ENUM('pending','paid','failed') DEFAULT 'pending',
    delivery_status ENUM('placed','confirmed','preparing','out_for_delivery','delivered','cancelled') DEFAULT 'placed',
    delivery_address TEXT,
    coupon_code VARCHAR(50),
    discount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =============================================
-- Table: order_items
-- =============================================
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    food_id INT,
    food_name VARCHAR(150),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE SET NULL
);

-- =============================================
-- Table: favorites
-- =============================================
CREATE TABLE IF NOT EXISTS favorites (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    UNIQUE KEY uq_fav (user_id, restaurant_id)
);

-- =============================================
-- Seed Data: Admin User
-- Password: admin123 (plain text for demo - hash in prod)
-- =============================================
INSERT INTO users (name, email, password, phone, role) VALUES
('Admin', 'admin@swadhafood.com', 'admin123', '9999999999', 'admin'),
('Demo User', 'demo@swadhafood.com', 'demo123', '9876543210', 'user');

-- =============================================
-- Seed Data: Restaurants with real images
-- =============================================
INSERT INTO restaurants (name, cuisine, image_url, rating, delivery_time, min_price, description, address) VALUES
('Spice Garden', 'North Indian, Mughlai', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop', 4.5, '25-35 min', 150, 'Authentic North Indian cuisine with rich gravies and tandoori delights. A perfect place for family dinners.', 'MG Road, Bengaluru'),
('Pizza Palace', 'Italian, Fast Food', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop', 4.3, '20-30 min', 200, 'Crispy thin crust pizzas loaded with fresh toppings. Made with authentic Italian recipes.', 'Koramangala, Bengaluru'),
('Biryani House', 'Biryani, South Indian', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop', 4.7, '30-45 min', 120, 'Aromatic dum biryani cooked in traditional style. Famous for Hyderabadi and Lucknowi biryani.', 'Indiranagar, Bengaluru'),
('Dragon Wok', 'Chinese, Asian', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop', 4.2, '25-40 min', 180, 'Authentic Chinese dishes with a modern twist. Noodles, dim sum, and stir-fries done right.', 'Whitefield, Bengaluru'),
('Burger Barn', 'American, Fast Food', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop', 4.1, '15-25 min', 100, 'Juicy gourmet burgers with fresh ingredients. Quick service and great value for money.', 'HSR Layout, Bengaluru'),
('South Spice', 'South Indian, Kerala', 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=500&auto=format&fit=crop', 4.6, '20-35 min', 80, 'Traditional South Indian breakfast and meals. Crispy dosas, fluffy idlis, and aromatic sambar.', 'Jayanagar, Bengaluru'),
('The Grill House', 'BBQ, Continental', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=500&auto=format&fit=crop', 4.4, '35-50 min', 300, 'Flame-grilled specialties and continental dishes. Premium dining experience with a relaxed atmosphere.', 'Sadashivanagar, Bengaluru'),
('Sweet Treats', 'Desserts, Bakery', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500&auto=format&fit=crop', 4.8, '20-30 min', 50, 'Handcrafted desserts, cakes, and pastries. Freshly baked daily with premium ingredients.', 'JP Nagar, Bengaluru');

-- =============================================
-- Seed Data: Foods for Restaurant 1 (Spice Garden)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(1, 'Butter Chicken', 320.00, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400', 'Tender chicken cooked in creamy tomato gravy with aromatic spices', 'Main Course', 0),
(1, 'Paneer Butter Masala', 280.00, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400', 'Fresh cottage cheese in rich butter and tomato sauce', 'Main Course', 1),
(1, 'Dal Makhani', 220.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400', 'Slow-cooked black lentils with butter and cream', 'Main Course', 1),
(1, 'Tandoori Chicken', 350.00, 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=400', 'Marinated whole chicken cooked in clay oven', 'Starters', 0),
(1, 'Garlic Naan', 40.00, 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=400', 'Soft leavened bread with garlic and butter', 'Breads', 1),
(1, 'Gulab Jamun', 80.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400', 'Soft milk dumplings soaked in sugar syrup', 'Desserts', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 2 (Pizza Palace)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(2, 'Margherita Pizza', 250.00, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', 'Classic pizza with tomato sauce and fresh mozzarella', 'Pizza', 1),
(2, 'Pepperoni Pizza', 320.00, 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400', 'Loaded with spicy pepperoni slices and cheese', 'Pizza', 0),
(2, 'BBQ Chicken Pizza', 360.00, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400', 'Grilled chicken with BBQ sauce and caramelized onions', 'Pizza', 0),
(2, 'Pasta Arrabiata', 220.00, 'https://images.unsplash.com/photo-1563379971899-660589a01cc3?w=400', 'Penne in spicy tomato sauce with herbs', 'Pasta', 1),
(2, 'Garlic Bread', 90.00, 'https://images.unsplash.com/photo-1573140247632-f8fd74997d5c?w=400', 'Toasted bread with garlic butter and herbs', 'Starters', 1),
(2, 'Tiramisu', 150.00, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400', 'Classic Italian dessert with coffee and mascarpone', 'Desserts', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 3 (Biryani House)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(3, 'Hyderabadi Chicken Biryani', 280.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400', 'Aromatic basmati rice cooked with spiced chicken', 'Biryani', 0),
(3, 'Veg Dum Biryani', 220.00, 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=400', 'Fragrant rice with mixed vegetables and saffron', 'Biryani', 1),
(3, 'Mutton Biryani', 380.00, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400', 'Slow-cooked mutton with long-grain basmati rice', 'Biryani', 0),
(3, 'Raita', 60.00, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400', 'Chilled yogurt with vegetables and spices', 'Sides', 1),
(3, 'Shorba', 80.00, 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=400', 'Traditional spiced broth served with biryani', 'Sides', 0),
(3, 'Double Ka Meetha', 120.00, 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400', 'Hyderabadi bread pudding with dry fruits', 'Desserts', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 4 (Dragon Wok)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(4, 'Veg Fried Rice', 180.00, 'https://images.unsplash.com/photo-1603133872878-685f7699c334?w=400', 'Wok-tossed rice with mixed vegetables and soy sauce', 'Rice', 1),
(4, 'Chicken Hakka Noodles', 220.00, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400', 'Stir-fried noodles with chicken and vegetables', 'Noodles', 0),
(4, 'Dim Sum (6 pcs)', 160.00, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400', 'Steamed dumplings with choice of filling', 'Starters', 1),
(4, 'Manchurian Gravy', 200.00, 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400', 'Crispy fried balls in tangy manchurian sauce', 'Starters', 1),
(4, 'Chilli Chicken', 260.00, 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400', 'Spicy dry chicken with bell peppers', 'Main Course', 0),
(4, 'Spring Rolls (4 pcs)', 140.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400', 'Crispy rolls filled with vegetables', 'Starters', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 5 (Burger Barn)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(5, 'Classic Beef Burger', 199.00, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400', 'Juicy beef patty with lettuce, tomato and special sauce', 'Burgers', 0),
(5, 'Veg Supreme Burger', 159.00, 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?w=400', 'Crispy veggie patty with fresh toppings', 'Burgers', 1),
(5, 'Chicken BBQ Burger', 220.00, 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400', 'Grilled chicken with BBQ sauce and coleslaw', 'Burgers', 0),
(5, 'French Fries (Large)', 99.00, 'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400', 'Crispy golden fries with dipping sauce', 'Sides', 1),
(5, 'Milkshake', 120.00, 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=400', 'Thick shake in chocolate, vanilla or strawberry', 'Beverages', 1),
(5, 'Onion Rings', 89.00, 'https://images.unsplash.com/photo-1639024471283-2bc7b3c6a267?w=400', 'Golden fried onion rings with ranch dip', 'Sides', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 6 (South Spice)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(6, 'Masala Dosa', 80.00, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400', 'Crispy dosa filled with spiced potato filling', 'Breakfast', 1),
(6, 'Idli Sambar (3 pcs)', 60.00, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400', 'Steamed rice cakes with sambar and chutney', 'Breakfast', 1),
(6, 'Chettinad Chicken Curry', 280.00, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400', 'Spicy authentic Chettinad style chicken', 'Main Course', 0),
(6, 'Kerala Fish Curry', 320.00, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400', 'Traditional coconut-based fish curry', 'Main Course', 0),
(6, 'Appam with Stew', 120.00, 'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=400', 'Soft lacy appam with vegetable stew', 'Breakfast', 1),
(6, 'Filter Coffee', 40.00, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400', 'Authentic South Indian filter coffee', 'Beverages', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 7 (The Grill House)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(7, 'BBQ Pork Ribs', 580.00, 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400', 'Slow-cooked pork ribs with smoky BBQ glaze', 'Grills', 0),
(7, 'Grilled Salmon', 520.00, 'https://images.unsplash.com/photo-1485921325833-c519f76c4927?w=400', 'Atlantic salmon with lemon butter and herbs', 'Grills', 0),
(7, 'Mushroom Risotto', 380.00, 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=400', 'Creamy arborio rice with wild mushrooms', 'Main Course', 1),
(7, 'Caesar Salad', 220.00, 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400', 'Romaine lettuce with caesar dressing and croutons', 'Salads', 1),
(7, 'Chocolate Lava Cake', 180.00, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400', 'Warm chocolate cake with molten center', 'Desserts', 1),
(7, 'Mocktail Platter', 250.00, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400', 'Selection of 3 signature mocktails', 'Beverages', 1);

-- =============================================
-- Seed Data: Foods for Restaurant 8 (Sweet Treats)
-- =============================================
INSERT INTO foods (restaurant_id, name, price, image_url, description, category, is_veg) VALUES
(8, 'Chocolate Truffle Cake', 350.00, 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400', 'Rich dark chocolate cake with ganache frosting', 'Cakes', 1),
(8, 'Red Velvet Cupcake (4 pcs)', 180.00, 'https://images.unsplash.com/photo-1614707267537-b85acf00c4b8?w=400', 'Moist red velvet with cream cheese frosting', 'Cupcakes', 1),
(8, 'Mango Cheesecake', 280.00, 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400', 'No-bake cheesecake with fresh mango topping', 'Cakes', 1),
(8, 'Belgian Waffles', 160.00, 'https://images.unsplash.com/photo-1562376502-6f769499c886?w=400', 'Crispy waffles with whipped cream and berries', 'Waffles', 1),
(8, 'Macaron Box (6 pcs)', 240.00, 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=400', 'Assorted French macarons in seasonal flavors', 'Pastries', 1),
(8, 'Brownie Sundae', 150.00, 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400', 'Warm brownie with vanilla ice cream and chocolate sauce', 'Desserts', 1);
