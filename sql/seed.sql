-- sql\seed.sql

-- ============================================================
-- MARCAT — SEED DATA
-- ============================================================
-- Covers: stores, categories, brands, products, product_colors,
--         product_sizes, product_images, store_inventory, offers
--
-- NOT seeded here (created via the application / auth trigger):
--   profiles, customers, staff, customer_addresses, sales,
--   sale_items, deliveries, wishlist, returns, return_items,
--   loyalty_transactions, commissions
--
-- Run AFTER database.sql.
-- All Unsplash URLs use the CDN format and reference real photos.
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. STORES
-- ────────────────────────────────────────────────────────────

INSERT INTO public.stores (id, name, location, phone, is_active) VALUES
(1, 'MARCAT Downtown',   'First Circle, Rainbow Street, Amman',          '+962-6-500-1001', true),
(2, 'MARCAT City Walk',  'City Walk Shopping Centre, 7th Circle, Amman', '+962-6-500-1002', true),
(3, 'MARCAT Mecca Mall', 'Mecca Mall, Sweifieh, Amman',                  '+962-6-500-1003', true),
(4, 'MARCAT Abdali',     'Abdali Boulevard, Central Amman',              '+962-6-500-1004', false);

SELECT setval('public.stores_id_seq', (SELECT MAX(id) FROM public.stores));


-- ────────────────────────────────────────────────────────────
-- 2. CATEGORIES  (4 root + 10 children = 14 total)
-- ────────────────────────────────────────────────────────────

INSERT INTO public.categories (id, name, parent_id, image_url, is_active) VALUES

-- Root categories
(1,  'Men',         NULL,
     'https://images.unsplash.com/photo-1488161628813-04466f872be2?auto=format&fit=crop&w=800&q=80',
     true),
(2,  'Women',       NULL,
     'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=800&q=80',
     true),
(3,  'Footwear',    NULL,
     'https://images.unsplash.com/photo-1542291026-7b4b8ab8f9b9?auto=format&fit=crop&w=800&q=80',
     true),
(4,  'Accessories', NULL,
     'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
     true),

-- Men sub-categories
(5,  'T-Shirts',  1,
     'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
     true),
(6,  'Jeans',     1,
     'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=800&q=80',
     true),
(7,  'Jackets',   1,
     'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80',
     true),

-- Women sub-categories
(8,  'Dresses',   2,
     'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=800&q=80',
     true),
(9,  'Tops',      2,
     'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?auto=format&fit=crop&w=800&q=80',
     true),
(10, 'Pants',     2,
     'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
     true),

-- Footwear sub-categories
(11, 'Sneakers',  3,
     'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80',
     true),
(12, 'Boots',     3,
     'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80',
     true),

-- Accessories sub-categories
(13, 'Bags',      4,
     'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80',
     true),
(14, 'Watches',   4,
     'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?auto=format&fit=crop&w=800&q=80',
     true);

SELECT setval('public.categories_id_seq', (SELECT MAX(id) FROM public.categories));


-- ────────────────────────────────────────────────────────────
-- 3. BRANDS
-- ────────────────────────────────────────────────────────────

INSERT INTO public.brands (id, name, logo_url) VALUES
(1, 'Nike',
    'https://images.unsplash.com/photo-1542291026-7b4b8ab8f9b9?auto=format&fit=crop&w=300&q=80'),
(2, 'Adidas',
    'https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=300&q=80'),
(3, 'Levi''s',
    'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=300&q=80'),
(4, 'Zara',
    'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=300&q=80'),
(5, 'H&M',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=300&q=80'),
(6, 'Timex',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=300&q=80');

SELECT setval('public.brands_id_seq', (SELECT MAX(id) FROM public.brands));


-- ────────────────────────────────────────────────────────────
-- 4. PRODUCTS  (20 products)
-- ────────────────────────────────────────────────────────────

INSERT INTO public.products
  (id, name, description, sku, base_price, brand_id, category_id, primary_image_url, status)
VALUES

-- ── Men ▸ T-Shirts (category 5) ─────────────────────────────
(1,
 'Classic White Tee',
 'A timeless wardrobe staple crafted from 100% premium ring-spun cotton. Relaxed fit, ribbed crew neck, and a slightly longer back hem for a polished look.',
 'NK-TSH-WHT-001', 24.99, 1, 5,
 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
 'active'),

(2,
 'Essential Black Tee',
 'Clean, minimal, and endlessly versatile. Slim fit in soft organic cotton with a reinforced neckline. Our best-seller in black.',
 'AD-TSH-BLK-001', 29.99, 2, 5,
 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Men ▸ Jeans (category 6) ────────────────────────────────
(3,
 '511 Slim Fit Jeans',
 'Sits just below the waist, slim through hip and thigh with a narrow leg opening. Crafted from rigid stretch denim that softens beautifully with every wear.',
 'LV-JNS-511-BLU', 69.99, 3, 6,
 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=800&q=80',
 'active'),

(4,
 'Tapered Black Jeans',
 'Modern tapered cut in a deep-black non-fade wash. 2% elastane delivers comfort stretch throughout the day without losing shape.',
 'ZR-JNS-BLK-002', 49.99, 4, 6,
 'https://images.unsplash.com/photo-1604176354204-9268737828e4?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Men ▸ Jackets (category 7) ──────────────────────────────
(5,
 'Leather Biker Jacket',
 'Full-grain cowhide leather with asymmetric zip, quilted lining, snap-tab collar, and silver-tone hardware. A wardrobe cornerstone.',
 'ZR-JKT-LTH-001', 149.99, 4, 7,
 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80',
 'active'),

(6,
 'Classic Denim Jacket',
 'Heritage 1967 silhouette, updated with a contemporary fit. 100% rigid cotton denim with structured shoulders and clean flat-fell seams.',
 'LV-JKT-DNM-001', 89.99, 3, 7,
 'https://images.unsplash.com/photo-1548549557-dbe9946621da?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Women ▸ Dresses (category 8) ────────────────────────────
(7,
 'Floral Midi Dress',
 'Lightweight 100% viscose chiffon in a vibrant botanical print. Floaty A-line silhouette with a self-tie waist, flutter sleeves, and midi length.',
 'ZR-DRS-FLR-001', 59.99, 4, 8,
 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=800&q=80',
 'active'),

(8,
 'Wrap Mini Dress',
 'Classic wrap silhouette in stretch jersey. Flattering V-neckline, adjustable tie waist. Elegant for evenings, effortless for day.',
 'HM-DRS-WRP-001', 44.99, 5, 8,
 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Women ▸ Tops (category 9) ───────────────────────────────
(9,
 'Ribbed Crop Top',
 'Soft ribbed cotton-blend in a relaxed cropped fit. Pairs perfectly with high-waist bottoms. Available in essential neutrals.',
 'HM-TOP-RBD-001', 19.99, 5, 9,
 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?auto=format&fit=crop&w=800&q=80',
 'active'),

(10,
 'Linen Oversized Blouse',
 'Breathable 100% European linen in a flowy oversized fit. Button-front with a relaxed open collar and slightly dropped shoulders.',
 'ZR-TOP-LNN-001', 39.99, 4, 9,
 'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Women ▸ Pants (category 10) ─────────────────────────────
(11,
 'Wide-Leg Tailored Trousers',
 'Polished wide-leg trousers in a fluid woven fabric. High waist with a clean front pleat. Transitions seamlessly from desk to dinner.',
 'ZR-PNT-WDL-001', 54.99, 4, 10,
 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
 'active'),

(12,
 'Essential Jogger Pants',
 'Sporty meets minimal. Mid-weight French terry with a tapered leg, elastic waistband, and zippered side pockets.',
 'AD-PNT-JGR-001', 49.99, 2, 10,
 'https://images.unsplash.com/photo-1556906781-9b4e166ea3de?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Footwear ▸ Sneakers (category 11) ───────────────────────
(13,
 'Air Max Pulse',
 'Engineered mesh upper for all-day breathability. Visible heel Air unit for bold, lightweight cushioning. Rubber waffle outsole for grip.',
 'NK-SNK-AMP-001', 119.99, 1, 11,
 'https://images.unsplash.com/photo-1542291026-7b4b8ab8f9b9?auto=format&fit=crop&w=800&q=80',
 'active'),

(14,
 'Stan Smith Originals',
 'The iconic low-top court shoe since 1971. Smooth full-grain leather upper with perforated 3-Stripes branding and a cupsole construction.',
 'AD-SNK-STS-001', 89.99, 2, 11,
 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80',
 'active'),

(15,
 'Ultraboost 22',
 'PRIMEKNIT+ upper with a sock-like adaptive fit. Full-length BOOST midsole for explosive energy return. Continental rubber outsole.',
 'AD-SNK-UB22-001', 159.99, 2, 11,
 'https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Footwear ▸ Boots (category 12) ──────────────────────────
(16,
 'Suede Ankle Boots',
 'Refined split-suede ankle boots with a 5 cm block heel, a pointed toe, and inner zip closure for easy on and off.',
 'ZR-BOT-ANK-001', 89.99, 4, 12,
 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80',
 'active'),

(17,
 'Chelsea Leather Boots',
 'Classic pull-on Chelsea silhouette in smooth full-grain leather. Elastic side panels, tab pull, and a low stacked leather heel.',
 'HM-BOT-CLS-001', 79.99, 5, 12,
 'https://images.unsplash.com/photo-1605812860427-4024433a70fd?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Accessories ▸ Bags (category 13) ────────────────────────
(18,
 'Structured Leather Tote',
 'Spacious everyday tote in vegetable-tanned Italian leather. Interior zip pocket, two open pockets, and a magnetic snap closure.',
 'ZR-BAG-TOT-001', 99.99, 4, 13,
 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80',
 'active'),

(19,
 'Mini Quilted Crossbody',
 'Compact quilted faux-leather crossbody bag with a gold-tone chain strap. Fits a phone, cards, and keys — perfect for a night out.',
 'HM-BAG-CRS-001', 34.99, 5, 13,
 'https://images.unsplash.com/photo-1548036161-0e5ef8daa68e?auto=format&fit=crop&w=800&q=80',
 'active'),

-- ── Accessories ▸ Watches (category 14) ─────────────────────
(20,
 'Weekender 40mm Watch',
 'Timeless field-watch design with Indiglo® night-light technology. 40mm stainless steel case, genuine leather strap, mineral crystal. Water resistant 30m.',
 'TX-WTC-WKD-001', 74.99, 6, 14,
 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
 'active');

SELECT setval('public.products_id_seq', (SELECT MAX(id) FROM public.products));


-- ────────────────────────────────────────────────────────────
-- 5. PRODUCT COLORS  (2 per product = 40 rows)
--    hex_code must match ^#[0-9A-Fa-f]{6}$
-- ────────────────────────────────────────────────────────────

INSERT INTO public.product_colors (id, product_id, name, hex_code) VALUES

-- Product 1 – Classic White Tee
(1,  1, 'White',          '#FFFFFF'),
(2,  1, 'Navy',           '#1B2A4A'),

-- Product 2 – Essential Black Tee
(3,  2, 'Black',          '#1A1A1A'),
(4,  2, 'Charcoal',       '#36454F'),

-- Product 3 – 511 Slim Fit Jeans
(5,  3, 'Indigo',         '#3D3B8E'),
(6,  3, 'Light Wash',     '#87AECB'),

-- Product 4 – Tapered Black Jeans
(7,  4, 'Jet Black',      '#0D0D0D'),
(8,  4, 'Dark Grey',      '#4A4A4A'),

-- Product 5 – Leather Biker Jacket
(9,  5, 'Black',          '#1A1A1A'),
(10, 5, 'Cognac',         '#9B5523'),

-- Product 6 – Classic Denim Jacket
(11, 6, 'Mid Blue',       '#3A7EC8'),
(12, 6, 'Light Blue',     '#87CEEB'),

-- Product 7 – Floral Midi Dress
(13, 7, 'Pink Floral',    '#F4A7B9'),
(14, 7, 'Blue Floral',    '#7BB7D8'),

-- Product 8 – Wrap Mini Dress
(15, 8, 'Black',          '#1A1A1A'),
(16, 8, 'Burgundy',       '#800020'),

-- Product 9 – Ribbed Crop Top
(17, 9, 'White',          '#FFFFFF'),
(18, 9, 'Black',          '#1A1A1A'),

-- Product 10 – Linen Oversized Blouse
(19, 10, 'Off-White',     '#FAF7F0'),
(20, 10, 'Sand',          '#C2B280'),

-- Product 11 – Wide-Leg Tailored Trousers
(21, 11, 'Black',         '#1A1A1A'),
(22, 11, 'Camel',         '#C19A6B'),

-- Product 12 – Essential Jogger Pants
(23, 12, 'Black',         '#1A1A1A'),
(24, 12, 'Heather Grey',  '#B0B0B0'),

-- Product 13 – Air Max Pulse
(25, 13, 'White',         '#FFFFFF'),
(26, 13, 'Black',         '#1A1A1A'),

-- Product 14 – Stan Smith Originals
(27, 14, 'White / Green', '#FFFFFF'),
(28, 14, 'White / Navy',  '#FAFAFA'),

-- Product 15 – Ultraboost 22
(29, 15, 'Core Black',    '#1A1A1A'),
(30, 15, 'Cloud White',   '#F5F5F5'),

-- Product 16 – Suede Ankle Boots
(31, 16, 'Tan',           '#D2B48C'),
(32, 16, 'Black',         '#1A1A1A'),

-- Product 17 – Chelsea Leather Boots
(33, 17, 'Black',         '#1A1A1A'),
(34, 17, 'Dark Brown',    '#5C3317'),

-- Product 18 – Structured Leather Tote
(35, 18, 'Black',         '#1A1A1A'),
(36, 18, 'Cognac',        '#9B5523'),

-- Product 19 – Mini Quilted Crossbody
(37, 19, 'Black',         '#1A1A1A'),
(38, 19, 'Blush Pink',    '#FFB7C5'),

-- Product 20 – Weekender Watch
(39, 20, 'Silver',        '#C0C0C0'),
(40, 20, 'Rose Gold',     '#B76E79');

SELECT setval('public.product_colors_id_seq', (SELECT MAX(id) FROM public.product_colors));


-- ────────────────────────────────────────────────────────────
-- 6. PRODUCT SIZES  (4 per product = 73 rows)
--    Clothing: S / M / L / XL  (women's: XS / S / M / L)
--    Jeans:    28–36 waist (EU)
--    Shoes:    EU 38–42
--    Bags:     Small / Large  or  One Size
--    Watches:  38mm / 42mm
-- ────────────────────────────────────────────────────────────

INSERT INTO public.product_sizes (id, product_id, label) VALUES

-- Product 1 – Classic White Tee
(1,  1, 'S'),  (2,  1, 'M'),  (3,  1, 'L'),  (4,  1, 'XL'),

-- Product 2 – Essential Black Tee
(5,  2, 'S'),  (6,  2, 'M'),  (7,  2, 'L'),  (8,  2, 'XL'),

-- Product 3 – 511 Slim Fit Jeans
(9,  3, '30'), (10, 3, '32'), (11, 3, '34'), (12, 3, '36'),

-- Product 4 – Tapered Black Jeans
(13, 4, '28'), (14, 4, '30'), (15, 4, '32'), (16, 4, '34'),

-- Product 5 – Leather Biker Jacket
(17, 5, 'S'),  (18, 5, 'M'),  (19, 5, 'L'),  (20, 5, 'XL'),

-- Product 6 – Classic Denim Jacket
(21, 6, 'S'),  (22, 6, 'M'),  (23, 6, 'L'),  (24, 6, 'XL'),

-- Product 7 – Floral Midi Dress
(25, 7, 'XS'), (26, 7, 'S'),  (27, 7, 'M'),  (28, 7, 'L'),

-- Product 8 – Wrap Mini Dress
(29, 8, 'XS'), (30, 8, 'S'),  (31, 8, 'M'),  (32, 8, 'L'),

-- Product 9 – Ribbed Crop Top
(33, 9, 'XS'), (34, 9, 'S'),  (35, 9, 'M'),  (36, 9, 'L'),

-- Product 10 – Linen Oversized Blouse
(37, 10, 'XS'), (38, 10, 'S'), (39, 10, 'M'), (40, 10, 'L'),

-- Product 11 – Wide-Leg Tailored Trousers
(41, 11, 'XS'), (42, 11, 'S'), (43, 11, 'M'), (44, 11, 'L'),

-- Product 12 – Essential Jogger Pants
(45, 12, 'XS'), (46, 12, 'S'), (47, 12, 'M'), (48, 12, 'L'),

-- Product 13 – Air Max Pulse
(49, 13, '39'), (50, 13, '40'), (51, 13, '41'), (52, 13, '42'),

-- Product 14 – Stan Smith Originals
(53, 14, '38'), (54, 14, '39'), (55, 14, '40'), (56, 14, '41'),

-- Product 15 – Ultraboost 22
(57, 15, '39'), (58, 15, '40'), (59, 15, '41'), (60, 15, '42'),

-- Product 16 – Suede Ankle Boots
(61, 16, '36'), (62, 16, '37'), (63, 16, '38'), (64, 16, '39'),

-- Product 17 – Chelsea Leather Boots
(65, 17, '38'), (66, 17, '39'), (67, 17, '40'), (68, 17, '41'),

-- Product 18 – Structured Leather Tote
(69, 18, 'Small'),     (70, 18, 'Large'),

-- Product 19 – Mini Quilted Crossbody
(71, 19, 'One Size'),

-- Product 20 – Weekender Watch
(72, 20, '38mm'),      (73, 20, '42mm');

SELECT setval('public.product_sizes_id_seq', (SELECT MAX(id) FROM public.product_sizes));


-- ────────────────────────────────────────────────────────────
-- 7. PRODUCT IMAGES  (2 per product = 40 rows)
--    display_order 0 = hero image, 1 = alternate angle
-- ────────────────────────────────────────────────────────────

INSERT INTO public.product_images (product_id, image_url, display_order) VALUES

-- Product 1 – Classic White Tee
(1, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80', 0),
(1, 'https://images.unsplash.com/photo-1503342394128-c104d54dba01?auto=format&fit=crop&w=800&q=80', 1),

-- Product 2 – Essential Black Tee
(2, 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=800&q=80', 0),
(2, 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?auto=format&fit=crop&w=800&q=80', 1),

-- Product 3 – 511 Slim Fit Jeans
(3, 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=800&q=80', 0),
(3, 'https://images.unsplash.com/photo-1475178626620-a4d074967452?auto=format&fit=crop&w=800&q=80', 1),

-- Product 4 – Tapered Black Jeans
(4, 'https://images.unsplash.com/photo-1604176354204-9268737828e4?auto=format&fit=crop&w=800&q=80', 0),
(4, 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=800&q=80', 1),

-- Product 5 – Leather Biker Jacket
(5, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=800&q=80', 0),
(5, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=800&q=80', 1),

-- Product 6 – Classic Denim Jacket
(6, 'https://images.unsplash.com/photo-1548549557-dbe9946621da?auto=format&fit=crop&w=800&q=80', 0),
(6, 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?auto=format&fit=crop&w=800&q=80', 1),

-- Product 7 – Floral Midi Dress
(7, 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=800&q=80', 0),
(7, 'https://images.unsplash.com/photo-1496747433903-da4fda1af03c?auto=format&fit=crop&w=800&q=80', 1),

-- Product 8 – Wrap Mini Dress
(8, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80', 0),
(8, 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80', 1),

-- Product 9 – Ribbed Crop Top
(9, 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?auto=format&fit=crop&w=800&q=80', 0),
(9, 'https://images.unsplash.com/photo-1571513722275-4ad2a717e1b3?auto=format&fit=crop&w=800&q=80', 1),

-- Product 10 – Linen Oversized Blouse
(10, 'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?auto=format&fit=crop&w=800&q=80', 0),
(10, 'https://images.unsplash.com/photo-1605763240000-7e93b172d754?auto=format&fit=crop&w=800&q=80', 1),

-- Product 11 – Wide-Leg Tailored Trousers
(11, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80', 0),
(11, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80', 1),

-- Product 12 – Essential Jogger Pants
(12, 'https://images.unsplash.com/photo-1556906781-9b4e166ea3de?auto=format&fit=crop&w=800&q=80', 0),
(12, 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?auto=format&fit=crop&w=800&q=80', 1),

-- Product 13 – Air Max Pulse
(13, 'https://images.unsplash.com/photo-1542291026-7b4b8ab8f9b9?auto=format&fit=crop&w=800&q=80', 0),
(13, 'https://images.unsplash.com/photo-1570464197285-9949814674a7?auto=format&fit=crop&w=800&q=80', 1),

-- Product 14 – Stan Smith Originals
(14, 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80', 0),
(14, 'https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=800&q=80', 1),

-- Product 15 – Ultraboost 22
(15, 'https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&w=800&q=80', 0),
(15, 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?auto=format&fit=crop&w=800&q=80', 1),

-- Product 16 – Suede Ankle Boots
(16, 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80', 0),
(16, 'https://images.unsplash.com/photo-1607522370275-f6fd4a45a7d6?auto=format&fit=crop&w=800&q=80', 1),

-- Product 17 – Chelsea Leather Boots
(17, 'https://images.unsplash.com/photo-1605812860427-4024433a70fd?auto=format&fit=crop&w=800&q=80', 0),
(17, 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?auto=format&fit=crop&w=800&q=80', 1),

-- Product 18 – Structured Leather Tote
(18, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80', 0),
(18, 'https://images.unsplash.com/photo-1548036161-ab9fbb4e4f37?auto=format&fit=crop&w=800&q=80', 1),

-- Product 19 – Mini Quilted Crossbody
(19, 'https://images.unsplash.com/photo-1548036161-0e5ef8daa68e?auto=format&fit=crop&w=800&q=80', 0),
(19, 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=800&q=80', 1),

-- Product 20 – Weekender Watch
(20, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80', 0),
(20, 'https://images.unsplash.com/photo-1526045612212-70caf35c14df?auto=format&fit=crop&w=800&q=80', 1);


-- ────────────────────────────────────────────────────────────
-- 8. STORE INVENTORY
--
-- Generates a row for every valid (store, size, color) triple —
-- i.e. only combinations where the color and size belong to the
-- same product.  Stock levels are randomised (5–54 available,
-- 0–3 reserved).  Only active stores 1–3 are stocked; store 4
-- (inactive) is intentionally left empty.
-- ────────────────────────────────────────────────────────────

INSERT INTO public.store_inventory (store_id, product_size_id, color_id, available, reserved)
SELECT
  s.id                              AS store_id,
  ps.id                             AS product_size_id,
  pc.id                             AS color_id,
  floor(random() * 50 + 5)::INT    AS available,
  floor(random() * 4)::INT          AS reserved
FROM generate_series(1, 3) AS s(id)
CROSS JOIN public.product_sizes  ps
JOIN       public.product_colors pc ON pc.product_id = ps.product_id
ON CONFLICT (store_id, product_size_id, color_id) DO NOTHING;


-- ────────────────────────────────────────────────────────────
-- 9. OFFERS / COUPONS  (5 offers)
-- ────────────────────────────────────────────────────────────

INSERT INTO public.offers
  (id, code, description, discount_type, discount_value,
   min_order_total, max_uses, used_count, expires_at, is_active)
VALUES

(1,
 'WELCOME10',
 '10% off your first order — no minimum spend, no expiry. Welcome to MARCAT!',
 'percentage', 10.00,
  0.00, NULL, 0,
  NULL,
  true),

(2,
 'SUMMER25',
 'Summer Sale — 25% off sitewide on orders over JOD 75. Valid through August 2026.',
 'percentage', 25.00,
  75.00, 500, 0,
  '2026-08-31 23:59:59+03',
  true),

(3,
 'SAVE50',
 'Spend JOD 200, save JOD 50. Limited to 200 redemptions.',
 'fixed', 50.00,
  200.00, 200, 0,
  '2026-06-30 23:59:59+03',
  true),

(4,
 'FLASH15',
 'Flash deal — 15% off everything, no minimum. First 100 customers only.',
 'percentage', 15.00,
  0.00, 100, 0,
  '2026-04-30 23:59:59+03',
  true),

(5,
 'BLACKFRIDAY',
 'Black Friday — 30% off orders over JOD 50. Reactivated each November.',
 'percentage', 30.00,
  50.00, 1000, 0,
  '2026-11-30 23:59:59+03',
  false);

SELECT setval('public.offers_id_seq', (SELECT MAX(id) FROM public.offers));


-- ────────────────────────────────────────────────────────────
-- DONE
-- Seeded:
--   4  stores         (3 active, 1 inactive)
--  14  categories     (4 root + 10 children)
--   6  brands
--  20  products       (all status = active)
--  40  product colors (2 per product)
--  73  product sizes
--  40  product images (2 per product)
-- ~438 inventory rows (3 stores × all size/color combos)
--   5  offers         (4 active, 1 inactive)
-- ────────────────────────────────────────────────────────────