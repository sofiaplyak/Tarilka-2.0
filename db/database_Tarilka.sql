-- ============================================================
-- Database schema generated and modified by the Sofiia from the ER diagram (MySQL / MariaDB)
-- ============================================================

CREATE DATABASE IF NOT EXISTS tarilka_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tarilka_db;

-- Drop in dependency order so the script can be re-run safely
DROP TABLE IF EXISTS booking_items;
DROP TABLE IF EXISTS bookings;
-- DROP TABLE IF EXISTS contact_messages; 
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS menu_categories;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------------
-- users
-- ------------------------------------------------------------
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  full_name     VARCHAR(120) NOT NULL,
  email         VARCHAR(190) NOT NULL UNIQUE,
  phone         VARCHAR(30)  NULL,
  password_hash VARCHAR(255) NOT NULL,
  role          ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- services
-- ------------------------------------------------------------
CREATE TABLE services (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  description TEXT         NULL,
  sort_order INT NOT NULL DEFAULT 0,
  image_path  VARCHAR(255) NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- menu_categories
-- ------------------------------------------------------------
CREATE TABLE menu_categories (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- menu_items
-- ------------------------------------------------------------
CREATE TABLE menu_items (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  category_id   INT NOT NULL,
  name          VARCHAR(150)  NOT NULL,
  description   TEXT          NULL,
  price         DECIMAL(8,2)  NOT NULL,
  image_path    VARCHAR(255)  NULL,
  is_vegetarian TINYINT(1)    NOT NULL DEFAULT 0,
  allergens     SET('gluten','dairy','eggs','nuts','peanuts','soy','fish','shellfish','sesame','celery','mustard','sulphites') NULL,
  is_available  TINYINT(1)    NOT NULL DEFAULT 1,
  CONSTRAINT fk_menu_items_category
    FOREIGN KEY (category_id) REFERENCES menu_categories(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_menu_items_category (category_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- bookings
-- user_id and service_id are optional (guests can book without an account)
-- ------------------------------------------------------------
CREATE TABLE bookings (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NULL,
  service_id  INT NULL,
  full_name   VARCHAR(120) NOT NULL,
  email       VARCHAR(190) NOT NULL,
  phone       VARCHAR(30)  NULL,
  event_date  DATE         NOT NULL,
  guest_count INT          NOT NULL DEFAULT 1,
  venue       VARCHAR(255) NULL,
  notes       TEXT         NULL,
  status      ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL DEFAULT 'pending',
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bookings_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_bookings_service
    FOREIGN KEY (service_id) REFERENCES services(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  INDEX idx_bookings_user (user_id),
  INDEX idx_bookings_service (service_id),
  INDEX idx_bookings_event_date (event_date)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- booking_items (menu items attached to a booking)
-- ------------------------------------------------------------
CREATE TABLE booking_items (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  booking_id   INT NOT NULL,
  menu_item_id INT NOT NULL,
  quantity     INT NOT NULL DEFAULT 1,
  CONSTRAINT fk_booking_items_booking
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_booking_items_menu_item
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_booking_items_booking (booking_id),
  INDEX idx_booking_items_menu_item (menu_item_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- contact_messages (standalone, no foreign keys)
-- ------------------------------------------------------------
CREATE TABLE contact_messages (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  email      VARCHAR(190) NOT NULL,
  message    TEXT         NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- Sample data (optional, delete if not needed)
-- ============================================================

INSERT INTO menu_categories (name, sort_order) VALUES
  ('Starters', 1),
  ('Main dishes', 2),
  ('Desserts', 3),
  ('Drinks', 4);

INSERT INTO menu_items (category_id, name, description, price, allergens, is_available) VALUES

  -- Starters (1)
  (1, 'Tomato Bruschetta', 'Toasted ciabatta with diced tomato, basil and balsamic glaze.', 5.50, 'Gluten', 1),
  (1, 'Caprese Skewers', 'Cherry tomato, mozzarella and basil with pesto drizzle.', 6.00, 'Milk, Nuts', 1),
  (1, 'Smoked Salmon Blini', 'Mini buckwheat pancakes with smoked salmon and dill cream cheese.', 7.50, 'Fish, Milk, Gluten, Eggs', 1),
  (1, 'Wild Mushroom Arancini', 'Crispy risotto balls with garlic aioli.', 6.50, 'Gluten, Milk, Eggs', 1),
  (1, 'Roasted Butternut Squash Soup', 'Creamy soup served with warm bread roll.', 5.95, 'Milk, Gluten, Celery', 1),
  (1, 'Prawn Cocktail', 'Prawns in Marie Rose sauce on baby gem lettuce.', 8.00, 'Crustaceans, Eggs', 1),
  --my own
  (1, 'Lettuce wraps with sticky chicken', 'honeyed chicken thighs in crisp Little Gem lettuce cups, garnished with a scatter of sesame seeds and a hint of fresh red chilli', 0.00, 'Sesame, Soya, Gluten', 1),
  (1, 'Steak Tartare', 'finely chopped, mixed with various add-ons such as pickles, served with a raw egg and dijon mustard', 0.00, 'Eggs, Mustard, Sulphites', 1),
  (1, 'Italian scotch olives', 'this recipe from Italian restaurant Luca sees olives rolled them in sausage meat and breadcrumbs before frying.', 0.00,'Gluten, Eggs', 1),
  (1, 'Grilled peaches with burrata', 'salt cod is transformed into the traditional Portuguese sharing snack with saffron, potatoes and lemon', 0.00, 'Milk', 1),
  (1, 'Bacalhau fritters', 'honeyed chicken thighs in crisp Little Gem lettuce cups, garnished with a scatter of sesame seeds and a hint of fresh red chilli', 0.00, 'Fish, Gluten, Eggs', 1),
  (1, 'Garlic prawns', 'serve shell-on king prawns sizzling in a pool of paprika, sherry and garlic-infused oil', 0.00, 'Crustaceans, Sulphites', 1),
  (1, 'Fig and goat''s cheese filo parcels', 'crunchy filo-baked fresh figs stuffed with peppered goat''s cheese.', 0.00, 'Gluten, Mikj', 1),

  -- Main dishes (2)
  (2, 'Herb-Roasted Chicken Supreme', 'Served with creamy mash and seasonal vegetables.', 18.50, 'Milk', 1),
  (2, 'Slow-Braised Beef Short Rib', 'Red wine jus, roast potatoes and glazed carrots.', 24.00, 'Celery, Sulphites', 1),
  (2, 'Pan-Seared Salmon', 'Lemon butter sauce with new potatoes and asparagus.', 21.00, 'Fish, Milk', 1),
  (2, 'Wild Mushroom Risotto', 'Arborio rice with parmesan and truffle oil.', 16.50, 'Milk, Celery', 1),
  (2, 'Vegetable Moussaka', 'Layers of aubergine, courgette and tomato under a light bechamel.', 15.50, 'Milk, Gluten', 1),
  (2, 'Lamb Tagine', 'Slow-cooked lamb with apricots, couscous and flaked almonds.', 22.50, 'Gluten, Nuts', 1),
  (2, 'Spinach and Ricotta Cannelloni', 'Baked in tomato sauce with mozzarella.', 15.00, 'Gluten, Milk, Eggs', 1),
  --my own
  (2, 'Cedar-Plank Salmon', 'Cooked salmon coated with mustard, honey, rosemary, and zest mixture on grilling plank', 0.00, 'Fish, Mustard', 1),
  (2, 'Braised Chicken Legs with Grapes and Fennel', 'with sweet fennel and honey, spicy Calabrian chile paste, and red wine vinegar for brightness.', 0.00, 'Sulphites', 1),
  (2, 'Double-Stack Mushroom and Chicken Cheeseburger', 'that''s a burger made from a blend of ground meat and vegetables (usually mushrooms)—out of sustainability concerns', 0.00, 'Gluten, Milk, Eggs', 1),
  (2, 'Grilled Pork Spareribs with Barbecue Sauce', 'the temperature never crosses 300°F—an intentional limit that results in soft, juicy, and flavor-packed ribs', 0.00, 'Mustard, Soya, Sulphites', 1),
  (2, 'Fish Tacos al Pastor', 'A potent chile marinade adds lots of flavor before the fillets hit the grill, and a do-ahead pineapple salsa is the perfect finishing touch.', 0.00, 'Fish, Gluten, Sulphites', 1),
  (2, 'Mast Biryani', 'It''s packed full of a rainbow of colors, flavors, and textures, from spiced paneer, chickpeas, and tomatoes to roasted beets, sweet potatoes, and a citrusy coconut and cilantro sauce', 0.00, 'Milk', 1),
  (2, 'Seared Scallops With Basil Risotto', 'There''s just something about the caramelized crust and meaty interior of scallops that makes them the perfect protein', 0.00, 'Molluscs, Milk, Sulphites, Celery', 1),

  -- Desserts (3)
  (3, 'Classic Tiramisu', 'Mascarpone cream, espresso-soaked sponge and cocoa.', 6.50, 'Milk, Eggs, Gluten', 1),
  (3, 'Sticky Toffee Pudding', 'Warm date sponge with toffee sauce and vanilla cream.', 6.50, 'Milk, Eggs, Gluten', 1),
  (3, 'Lemon Posset', 'Silky lemon cream with shortbread.', 5.50, 'Milk, Gluten', 1),
  (3, 'Dark Chocolate Fondant', 'Molten centre with berry compote.', 7.00, 'Milk, Eggs, Gluten', 1),
  (3, 'Fresh Fruit Platter', 'Seasonal fruit selection, dairy-free and gluten-free.', 5.00, 'None', 1),
  -- my own
  (3, 'Mauritian coconut flan', 'A staple at every Mauritian gathering, coconut flan evokes a sense of home and family', 0.00, 'Milk, Eggs', 1),
  (3, 'Hazelnut meringues with chantilly cream', 'Toasted hazelnuts bring a sweet and nutty depth to these meringues, topped with creamy vanilla chantilly cream', 0.00, 'Nuts, Eggs, Milk', 1),
  (3, 'Madeleine ''baba''', 'Our variation of rum baba that''s made with spiced rum and added special spices to make the taste unforgettable', 0.00, 'Gluten, Eggs, Milk', 1),
  (3, 'Baked figs with amaretto', 'Jammy figs are roasted with amaretto in this warming autumnal dessert', 0.00, 'Nuts', 1),
  (3, 'Poached pears with chocolate sauce', 'A fancy dessert idea that makes the most of Williams pears, smooth dark chocolate sauce and pedro ximénez sherry', 0.00, 'Milk, Soya, Sulphites', 1),
  -- Drinks (4)
  (4, 'Still and Sparkling Water', 'Jug service per table.', 1.50, 'None', 1),
  (4, 'Freshly Squeezed Orange Juice', 'Served chilled.', 3.00, 'None', 1),
  (4, 'Tea and Coffee Service', 'Filter coffee, espresso, and a selection of teas.', 3.50, 'Milk', 1),
  (4, 'Elderflower Spritz (Non-Alcoholic)', 'Elderflower cordial, soda and fresh mint.', 4.00, 'None', 1),
  (4, 'House Red or White Wine', 'Per glass.', 6.50, 'Sulphites', 1),
  (4, 'Prosecco', 'Per glass, ideal for toasts.', 7.00, 'Sulphites', 1);
  --cocktails
  (4, 'Mojito', 'Dating back to 16th-century Cuba, the Mojito — made from rum, lime, mint, and sugar — was supposedly consumed for medicinal purposes.', 0.00, NULL, 1),
  (4, 'Manhattan', 'The classic Manhattan is two parts whiskey, one part sweet vermouth, and bitters.', 0.00, 'Sulphites', 1),
  (4, 'Gimlet', 'The simple and refreshing Gimlet is made with gin, lime juice, and sugar', 0.00, NULL, 1),
  (4, 'Corpse Reviver', 'The absinthe, gin, Lillet blanc, and orange liqueur cocktail that was used for "reviving a corpse," so basically it was a drink to cure a hangover.', 0.00, 'Sulphites', 1),
  (4, 'Mai Tai', 'The Mai Tai is made with rum, orange curaçao, orgeat (almond syrup), and lime juice and is one of the most famous tiki cocktails in the world', 0.00, 'Nuts', 1),
  (4, 'Rum Old Fashioned', 'The Old Fashioned is about as classic a cocktail as you can find. It uses the same formula as the first recorded cocktail over 200 years ago, which is spirit, sugar, water, and bitters', 0.00, NULL, 1),
  (4, 'Bellini', 'The wine cocktail is made with Prosecco and white peach purée, giving it a light and refreshing taste that''s perfect for brunch', 0.00, 'Sulphites', 1);


INSERT INTO services (title, description, sort_order) VALUES
  ('Plated Dinner',  'Guests receive individualy plated meals. Elegant but more expensive. ', 1),
  ('Buffet Style',    'Guests serve themselves from a variety of dishes. More budget-friendly and flexible.', 2),
  ('Family-Style',     'Large platters of food are placed on tables for sharing. Encourages interaction. Can make your family dishes for extra fee.', 3),
  ('Food Station', 'Live cooking stations e.g. pasta, tacos, carving sation, adds a fun, interactive touch. Price depends on the number of guests.', 4),
  ('Cocktail Reception', 'Small bites and hors d''oeuvres passed around. Perfect for a casual or modern event.',5 ),
  ('Breakfast Catering', 'Pastries, fruits, egss, coffee, and juice for morning events.', 6),
  ('Boxed Lunches', 'Pre-packaged meals with sandwiches, salads, or wraps - great for training sessions or seminars', 7),
  ('Drop-Off Catering', 'Prepared meals delivered and set up without staff', 8);
