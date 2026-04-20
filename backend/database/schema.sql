-- Product Catalog Database Schema
CREATE DATABASE IF NOT EXISTS product_catalog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_catalog;

-- Categories
CREATE TABLE IF NOT EXISTS categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  slug VARCHAR(120) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE IF NOT EXISTS products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  specifications JSON,
  images JSON,
  category_id INT,
  slug VARCHAR(300) UNIQUE NOT NULL,
  featured TINYINT(1) DEFAULT 0,
  status ENUM('active','inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Static page content
CREATE TABLE IF NOT EXISTS site_content (
  content_id INT AUTO_INCREMENT PRIMARY KEY,
  page_name VARCHAR(100) UNIQUE NOT NULL,
  content_body LONGTEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Company information
CREATE TABLE IF NOT EXISTS company_info (
  company_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  phone VARCHAR(50),
  email VARCHAR(150),
  tagline VARCHAR(500),
  logo_url VARCHAR(500),
  logo_upload VARCHAR(500),
  logo_source ENUM('url','upload') NOT NULL DEFAULT 'url',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Social media links
CREATE TABLE IF NOT EXISTS social_media_links (
  link_id INT AUTO_INCREMENT PRIMARY KEY,
  platform VARCHAR(50) NOT NULL,
  url VARCHAR(500) NOT NULL,
  icon VARCHAR(100),
  active TINYINT(1) DEFAULT 1,
  sort_order INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- SEO metadata
CREATE TABLE IF NOT EXISTS seo (
  seo_id INT AUTO_INCREMENT PRIMARY KEY,
  page_name VARCHAR(100) UNIQUE NOT NULL,
  meta_title VARCHAR(255),
  meta_description VARCHAR(500),
  keywords JSON,
  og_image VARCHAR(500),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Default seed data
INSERT IGNORE INTO categories (name, description, slug) VALUES
  ('Equipment', 'Professional-grade equipment for all applications', 'equipment'),
  ('Lighting', 'High-performance lighting solutions', 'lighting'),
  ('Accessories', 'Essential accessories and add-ons', 'accessories');

INSERT IGNORE INTO company_info (name, address, phone, email, tagline) VALUES
  ('EON Marketing', '123 Industrial Blvd, City, State 00000', '+1 (555) 000-0000', 'info@eonmarketing.com', 'Premium Equipment & Lighting Solutions');

INSERT IGNORE INTO site_content (page_name, content_body) VALUES
  ('about', '<h1>About Us</h1><p>We are a premier provider of professional equipment and lighting solutions. With years of industry experience, we deliver quality products to meet your project needs.</p>'),
  ('contact', '<h1>Contact Us</h1><p>Get in touch with us for product inquiries, quotes, or support. Our team is ready to assist you.</p>'),
  ('shipping', '<h1>Shipping Policies</h1><p>We offer fast and reliable shipping on all orders. Standard delivery is 5-7 business days. Express options available upon request.</p>'),
  ('terms', '<h1>Terms & Conditions</h1><p>By using our website and services, you agree to the following terms and conditions. Please read them carefully before proceeding.</p>');

INSERT IGNORE INTO social_media_links (platform, url, icon, sort_order) VALUES
  ('Facebook', 'https://facebook.com/', 'facebook', 1),
  ('Instagram', 'https://instagram.com/', 'instagram', 2),
  ('X', 'https://x.com/', 'x-twitter', 3);

INSERT IGNORE INTO seo (page_name, meta_title, meta_description, keywords) VALUES
  ('home', 'EON Marketing – Equipment & Lighting Solutions', 'Shop professional equipment and lighting products. Quality solutions for every project.', '["equipment", "lighting", "professional", "industrial"]'),
  ('catalog', 'Product Catalog – EON Marketing', 'Browse our complete catalog of equipment and lighting products.', '["product catalog", "equipment", "lighting products"]'),
  ('about', 'About Us – EON Marketing', 'Learn about EON Marketing and our commitment to quality.', '["about", "company", "equipment supplier"]'),
  ('contact', 'Contact Us – EON Marketing', 'Get in touch with our team for inquiries and quotes.', '["contact", "inquiry", "quote"]');
