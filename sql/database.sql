-- sql\database.sql

-- ============================================================
-- MARCAT DATABASE SCHEMA — Supabase / PostgreSQL  v4
-- Combined from:
--   • supabase_setup.sql (v3 base schema)
--   • 001_create_wishlist_table.sql  (wishlist uses user_id → auth.users)
--   • 002_offers_anon_read_policy.sql (anon read of active offers)
-- ============================================================


-- ============================================================
-- 0. EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- hashing PINs
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- fuzzy product search


-- ============================================================
-- 1. ENUMS
-- ============================================================

CREATE TYPE public.user_role         AS ENUM ('admin', 'store_manager', 'salesperson', 'driver', 'customer');
CREATE TYPE public.loyalty_tier      AS ENUM ('Bronze', 'Silver', 'Gold', 'Platinum');
CREATE TYPE public.sale_channel      AS ENUM ('online', 'pos');
CREATE TYPE public.sale_status       AS ENUM ('pending', 'paid', 'shipped', 'delivered', 'cancelled');
CREATE TYPE public.delivery_status   AS ENUM ('pending', 'out_for_delivery', 'delivered', 'failed');
CREATE TYPE public.return_status     AS ENUM ('requested', 'approved', 'received', 'refunded', 'rejected');
CREATE TYPE public.product_status    AS ENUM ('active', 'draft', 'archived');
CREATE TYPE public.commission_status AS ENUM ('pending', 'paid');


-- ============================================================
-- 2. HELPERS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


-- ============================================================
-- 3. BASE TABLES
-- ============================================================

-- ---------------------------
-- Stores
-- ---------------------------
CREATE TABLE public.stores (
  id         SERIAL PRIMARY KEY,
  name       TEXT    NOT NULL,
  location   TEXT,
  phone      TEXT,
  is_active  BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_stores_updated_at
  BEFORE UPDATE ON public.stores
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Profiles (extends auth.users)
-- ---------------------------
CREATE TABLE public.profiles (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT   NOT NULL,
  last_name  TEXT   NOT NULL,
  phone      TEXT,
  avatar_url TEXT,
  role       public.user_role NOT NULL DEFAULT 'customer',
  -- Soft-delete: 'deleted' rows hidden from all policies
  status     TEXT   NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Customers
-- ---------------------------
CREATE TABLE public.customers (
  id             UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  loyalty_points INTEGER             NOT NULL DEFAULT 0   CHECK (loyalty_points >= 0),
  loyalty_tier   public.loyalty_tier NOT NULL DEFAULT 'Bronze',
  -- total_spent updated by after-sale trigger, never by loyalty math
  total_spent    DECIMAL(12,2)       NOT NULL DEFAULT 0.00 CHECK (total_spent >= 0),
  date_of_birth  DATE,
  notes          TEXT,
  created_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customers_updated_at
  BEFORE UPDATE ON public.customers
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Customer Addresses
-- ---------------------------
CREATE TABLE public.customer_addresses (
  id           SERIAL PRIMARY KEY,
  customer_id  UUID    NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  label        TEXT    NOT NULL,
  full_address TEXT    NOT NULL,
  city         TEXT,
  country      TEXT,
  is_default   BOOLEAN     NOT NULL DEFAULT false,
  latitude     DECIMAL(9,6),
  longitude    DECIMAL(9,6),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customer_addresses_updated_at
  BEFORE UPDATE ON public.customer_addresses
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Staff
-- ---------------------------
CREATE TABLE public.staff (
  id                UUID    PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  assigned_store_id INTEGER REFERENCES public.stores(id) ON DELETE SET NULL,
  pos_pin_hash      TEXT,
  target_sales      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  is_active         BOOLEAN       NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_staff_updated_at
  BEFORE UPDATE ON public.staff
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Offers / Coupons
-- ---------------------------
CREATE TABLE public.offers (
  id              SERIAL PRIMARY KEY,
  code            TEXT          NOT NULL UNIQUE,
  description     TEXT,
  discount_type   TEXT          NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value  DECIMAL(10,2) NOT NULL CHECK (discount_value > 0),
  min_order_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  max_uses        INTEGER,
  used_count      INTEGER       NOT NULL DEFAULT 0,
  expires_at      TIMESTAMPTZ,
  is_active       BOOLEAN       NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);


-- ---------------------------
-- Categories (supports nesting)
-- ---------------------------
CREATE TABLE public.categories (
  id        SERIAL PRIMARY KEY,
  name      TEXT    NOT NULL,
  parent_id INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true
);


-- ---------------------------
-- Brands
-- ---------------------------
CREATE TABLE public.brands (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  logo_url TEXT
);


-- ---------------------------
-- Products
-- ---------------------------
CREATE TABLE public.products (
  id                SERIAL PRIMARY KEY,
  name              TEXT          NOT NULL,
  description       TEXT,
  sku               TEXT          NOT NULL UNIQUE,
  base_price        DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
  brand_id          INTEGER REFERENCES public.brands(id)     ON DELETE SET NULL,
  category_id       INTEGER REFERENCES public.categories(id) ON DELETE SET NULL,
  primary_image_url TEXT,
  -- 'archived' products hidden from public RLS
  status            public.product_status NOT NULL DEFAULT 'active',
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_sku       ON public.products (sku);
CREATE INDEX idx_products_category  ON public.products (category_id);
CREATE INDEX idx_products_brand     ON public.products (brand_id);
CREATE INDEX idx_products_name_trgm ON public.products USING gin (name gin_trgm_ops);

CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Product Colors
-- ---------------------------
CREATE TABLE public.product_colors (
  id         SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  name       TEXT    NOT NULL,
  hex_code   TEXT    NOT NULL CHECK (hex_code ~ '^#[0-9A-Fa-f]{6}$')
);

CREATE INDEX idx_product_colors_product ON public.product_colors (product_id);


-- ---------------------------
-- Product Sizes
-- ---------------------------
CREATE TABLE public.product_sizes (
  id         SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  label      TEXT    NOT NULL
);

CREATE INDEX idx_product_sizes_product ON public.product_sizes (product_id);


-- ---------------------------
-- Product Images
-- ---------------------------
CREATE TABLE public.product_images (
  id            SERIAL PRIMARY KEY,
  product_id    INTEGER NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  image_url     TEXT    NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0
);


-- ---------------------------
-- Store Inventory
-- ---------------------------
CREATE TABLE public.store_inventory (
  id              SERIAL PRIMARY KEY,
  store_id        INTEGER NOT NULL REFERENCES public.stores(id)         ON DELETE CASCADE,
  product_size_id INTEGER NOT NULL REFERENCES public.product_sizes(id)  ON DELETE CASCADE,
  color_id        INTEGER NOT NULL REFERENCES public.product_colors(id) ON DELETE CASCADE,
  available       INTEGER     NOT NULL DEFAULT 0 CHECK (available >= 0),
  reserved        INTEGER     NOT NULL DEFAULT 0 CHECK (reserved >= 0),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (store_id, product_size_id, color_id)
);

CREATE INDEX idx_store_inventory_store ON public.store_inventory (store_id);

CREATE TRIGGER trg_store_inventory_updated_at
  BEFORE UPDATE ON public.store_inventory
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Sales (Orders & POS Tickets)
-- ---------------------------
CREATE TABLE public.sales (
  id                  SERIAL PRIMARY KEY,
  reference_number    TEXT   NOT NULL UNIQUE,
  channel             public.sale_channel  NOT NULL,
  store_id            INTEGER REFERENCES public.stores(id)             ON DELETE SET NULL,
  customer_id         UUID    REFERENCES public.customers(id)          ON DELETE SET NULL,
  staff_id            UUID    REFERENCES public.staff(id)              ON DELETE SET NULL,
  offer_id            INTEGER REFERENCES public.offers(id)             ON DELETE SET NULL,
  shipping_address_id INTEGER REFERENCES public.customer_addresses(id) ON DELETE SET NULL,
  status              public.sale_status NOT NULL DEFAULT 'pending',
  subtotal            DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
  discount_total      DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (discount_total >= 0),
  tax_total           DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (tax_total >= 0),
  shipping_cost       DECIMAL(12,2) NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
  grand_total         DECIMAL(12,2) NOT NULL CHECK (grand_total >= 0),
  notes               TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sales_customer ON public.sales (customer_id);
CREATE INDEX idx_sales_staff    ON public.sales (staff_id);
CREATE INDEX idx_sales_status   ON public.sales (status);
CREATE INDEX idx_sales_created  ON public.sales (created_at DESC);

CREATE TRIGGER trg_sales_updated_at
  BEFORE UPDATE ON public.sales
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Sale Items
-- ---------------------------
CREATE TABLE public.sale_items (
  id              SERIAL PRIMARY KEY,
  sale_id         INTEGER NOT NULL REFERENCES public.sales(id)          ON DELETE CASCADE,
  product_id      INTEGER NOT NULL REFERENCES public.products(id)       ON DELETE RESTRICT,
  product_size_id INTEGER NOT NULL REFERENCES public.product_sizes(id)  ON DELETE RESTRICT,
  color_id        INTEGER NOT NULL REFERENCES public.product_colors(id) ON DELETE RESTRICT,
  quantity        INTEGER       NOT NULL CHECK (quantity > 0),
  unit_price      DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
  total_price     DECIMAL(12,2) NOT NULL CHECK (total_price >= 0)
);

CREATE INDEX idx_sale_items_sale ON public.sale_items (sale_id);


-- ---------------------------
-- Deliveries
-- ---------------------------
CREATE TABLE public.deliveries (
  id              SERIAL PRIMARY KEY,
  sale_id         INTEGER NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  driver_id       UUID    REFERENCES public.staff(id)          ON DELETE SET NULL,
  status          public.delivery_status NOT NULL DEFAULT 'pending',
  tracking_number TEXT,
  proof_image_url TEXT,
  delivered_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deliveries_driver ON public.deliveries (driver_id);
CREATE INDEX idx_deliveries_sale   ON public.deliveries (sale_id);

CREATE TRIGGER trg_deliveries_updated_at
  BEFORE UPDATE ON public.deliveries
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Wishlist
-- Merged from 001_create_wishlist_table.sql:
--   • uses user_id (→ auth.users) instead of customer_id
--   • product_id is BIGINT to match migration spec
--   • granular RLS policies (select / insert / delete)
-- ---------------------------
CREATE TABLE public.wishlist (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID   NOT NULL REFERENCES auth.users(id)    ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT wishlist_user_product_unique UNIQUE (user_id, product_id)
);

CREATE INDEX idx_wishlist_user_id    ON public.wishlist (user_id);
CREATE INDEX idx_wishlist_product_id ON public.wishlist (product_id);


-- ---------------------------
-- Returns
-- ---------------------------
CREATE TABLE public.returns (
  id            SERIAL PRIMARY KEY,
  sale_id       INTEGER NOT NULL REFERENCES public.sales(id)     ON DELETE RESTRICT,
  customer_id   UUID    NOT NULL REFERENCES public.customers(id) ON DELETE RESTRICT,
  status        public.return_status NOT NULL DEFAULT 'requested',
  reason        TEXT,
  refund_amount DECIMAL(12,2) CHECK (refund_amount >= 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_returns_customer ON public.returns (customer_id);
CREATE INDEX idx_returns_sale     ON public.returns (sale_id);

CREATE TRIGGER trg_returns_updated_at
  BEFORE UPDATE ON public.returns
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();


-- ---------------------------
-- Return Items
-- Quantity validated against original sale_items via trigger
-- ---------------------------
CREATE TABLE public.return_items (
  id                SERIAL PRIMARY KEY,
  return_id         INTEGER NOT NULL REFERENCES public.returns(id)    ON DELETE CASCADE,
  sale_item_id      INTEGER NOT NULL REFERENCES public.sale_items(id) ON DELETE RESTRICT,
  quantity_returned INTEGER NOT NULL CHECK (quantity_returned > 0),
  reason            TEXT
);

CREATE INDEX idx_return_items_return ON public.return_items (return_id);
CREATE INDEX idx_return_items_item   ON public.return_items (sale_item_id);


-- ---------------------------
-- Loyalty Transactions
-- points <> 0 enforced: zero-point rows are noise
-- ---------------------------
CREATE TABLE public.loyalty_transactions (
  id          SERIAL PRIMARY KEY,
  customer_id UUID    NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  sale_id     INTEGER REFERENCES public.sales(id)              ON DELETE SET NULL,
  points      INTEGER NOT NULL CHECK (points <> 0),
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_loyalty_customer ON public.loyalty_transactions (customer_id);


-- ---------------------------
-- Commissions
-- ---------------------------
CREATE TABLE public.commissions (
  id         SERIAL PRIMARY KEY,
  staff_id   UUID    NOT NULL REFERENCES public.staff(id)  ON DELETE CASCADE,
  sale_id    INTEGER NOT NULL REFERENCES public.sales(id)  ON DELETE CASCADE,
  amount     DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  status     public.commission_status NOT NULL DEFAULT 'pending',
  paid_at    TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_commissions_staff ON public.commissions (staff_id);


-- ============================================================
-- 4. ROLE HELPERS
-- Reads role from the JWT custom claim 'user_role' instead of
-- querying public.profiles inside RLS policies — eliminates the
-- N+1 subquery that fires per-row on every policy evaluation.
--
-- To populate the claim, add a Supabase Auth hook that runs:
--   UPDATE auth.users SET raw_app_meta_data =
--     raw_app_meta_data || jsonb_build_object('user_role', role)
--   FROM public.profiles WHERE profiles.id = auth.uid();
-- OR use a custom JWT template in the Supabase dashboard to
-- embed the role at token-mint time.
-- ============================================================

CREATE OR REPLACE FUNCTION public.my_role()
RETURNS public.user_role
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'user_role')::public.user_role,
    (SELECT role FROM public.profiles WHERE id = auth.uid())
  );
$$;


CREATE OR REPLACE FUNCTION public.has_role(VARIADIC roles public.user_role[])
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'user_role')::public.user_role,
    (SELECT role FROM public.profiles WHERE id = auth.uid())
  ) = ANY(roles);
$$;


-- ============================================================
-- 5. TRIGGERS & AUTH FUNCTIONS
-- ============================================================

-- Auto-create profile + customer row on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'first_name', 'New'),
    COALESCE(NEW.raw_user_meta_data->>'last_name',  'User'),
    'customer'
  );
  INSERT INTO public.customers (id) VALUES (NEW.id);
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- Auto-update loyalty tier when points change
CREATE OR REPLACE FUNCTION public.update_loyalty_tier()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.loyalty_tier = CASE
    WHEN NEW.loyalty_points >= 10000 THEN 'Platinum'::public.loyalty_tier
    WHEN NEW.loyalty_points >= 5000  THEN 'Gold'::public.loyalty_tier
    WHEN NEW.loyalty_points >= 1000  THEN 'Silver'::public.loyalty_tier
    ELSE                                  'Bronze'::public.loyalty_tier
  END;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_loyalty_tier
  BEFORE UPDATE OF loyalty_points ON public.customers
  FOR EACH ROW EXECUTE PROCEDURE public.update_loyalty_tier();


-- Update customer.total_spent when a sale transitions to 'paid'
CREATE OR REPLACE FUNCTION public.update_customer_total_spent()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.status = 'paid' AND OLD.status <> 'paid' AND NEW.customer_id IS NOT NULL THEN
    UPDATE public.customers
    SET total_spent = total_spent + NEW.grand_total
    WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_sale_paid_update_spent
  AFTER UPDATE OF status ON public.sales
  FOR EACH ROW EXECUTE PROCEDURE public.update_customer_total_spent();


-- Also fire on INSERT when a POS sale is created directly as 'paid'
CREATE OR REPLACE FUNCTION public.update_customer_total_spent_on_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NEW.status = 'paid' AND NEW.customer_id IS NOT NULL THEN
    UPDATE public.customers
    SET total_spent = total_spent + NEW.grand_total
    WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_sale_insert_update_spent
  AFTER INSERT ON public.sales
  FOR EACH ROW EXECUTE PROCEDURE public.update_customer_total_spent_on_insert();


-- Validate return quantity ≤ original sale_items.quantity
CREATE OR REPLACE FUNCTION public.check_return_quantity()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  v_original_qty  INT;
  v_returned_qty  INT;
BEGIN
  SELECT quantity INTO v_original_qty
  FROM public.sale_items WHERE id = NEW.sale_item_id;

  SELECT COALESCE(SUM(ri.quantity_returned), 0) INTO v_returned_qty
  FROM public.return_items ri
  JOIN public.returns r ON r.id = ri.return_id
  WHERE ri.sale_item_id = NEW.sale_item_id
    AND r.status NOT IN ('rejected')
    AND ri.id IS DISTINCT FROM NEW.id;

  IF v_returned_qty + NEW.quantity_returned > v_original_qty THEN
    RAISE EXCEPTION
      'Return quantity (%) exceeds available quantity for sale_item_id=% (sold=%, already returned=%)',
      NEW.quantity_returned, NEW.sale_item_id, v_original_qty, v_returned_qty;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_return_quantity
  BEFORE INSERT OR UPDATE ON public.return_items
  FOR EACH ROW EXECUTE PROCEDURE public.check_return_quantity();


-- Ensure sale_item product_id, product_size_id, and color_id
-- all belong to the same product — prevents cross-product references.
CREATE OR REPLACE FUNCTION public.check_sale_item_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
  v_size_product_id  INT;
  v_color_product_id INT;
BEGIN
  SELECT product_id INTO v_size_product_id
  FROM public.product_sizes WHERE id = NEW.product_size_id;

  SELECT product_id INTO v_color_product_id
  FROM public.product_colors WHERE id = NEW.color_id;

  IF v_size_product_id IS DISTINCT FROM NEW.product_id THEN
    RAISE EXCEPTION
      'sale_item product_size_id=% belongs to product % not %',
      NEW.product_size_id, v_size_product_id, NEW.product_id;
  END IF;

  IF v_color_product_id IS DISTINCT FROM NEW.product_id THEN
    RAISE EXCEPTION
      'sale_item color_id=% belongs to product % not %',
      NEW.color_id, v_color_product_id, NEW.product_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_sale_item_consistency
  BEFORE INSERT OR UPDATE ON public.sale_items
  FOR EACH ROW EXECUTE PROCEDURE public.check_sale_item_consistency();


-- ============================================================
-- 6. VIEWS
-- ============================================================

CREATE VIEW public.v_staff_details AS
SELECT
  s.id,
  p.first_name,
  p.last_name,
  p.phone,
  p.avatar_url,
  p.role,
  s.assigned_store_id,
  st.name    AS store_name,
  s.is_active
FROM public.staff s
JOIN public.profiles p ON p.id = s.id
LEFT JOIN public.stores st ON st.id = s.assigned_store_id
-- Exclude soft-deleted profiles and inactive staff from default view
WHERE p.status <> 'deleted'
  AND s.is_active = true;


CREATE VIEW public.v_store_inventory AS
SELECT
  si.id,
  si.store_id,
  st.name  AS store_name,
  p.id     AS product_id,
  p.name   AS product_name,
  p.sku,
  sz.id    AS product_size_id,
  sz.label AS size_label,
  c.id     AS color_id,
  c.name   AS color_name,
  c.hex_code,
  si.available,
  si.reserved,
  (si.available - si.reserved) AS truly_available
FROM public.store_inventory si
JOIN public.stores st        ON st.id = si.store_id
JOIN public.product_sizes sz ON sz.id = si.product_size_id
JOIN public.product_colors c ON c.id  = si.color_id
JOIN public.products p       ON p.id  = sz.product_id
WHERE p.status <> 'archived';


-- Use LEFT JOIN so POS sales (no shipping address) are not silently dropped
CREATE VIEW public.v_active_deliveries AS
SELECT
  d.id              AS delivery_id,
  d.status          AS delivery_status,
  d.driver_id,
  s.id              AS sale_id,
  s.reference_number,
  a.full_address,
  a.city,
  a.latitude,
  a.longitude,
  p.first_name      AS customer_first_name,
  p.last_name       AS customer_last_name,
  p.phone           AS customer_phone,
  d.created_at,
  d.updated_at
FROM public.deliveries d
JOIN  public.sales s                   ON s.id  = d.sale_id
LEFT  JOIN public.customer_addresses a ON a.id  = s.shipping_address_id
LEFT  JOIN public.profiles p           ON p.id  = s.customer_id
WHERE d.status IN ('pending', 'out_for_delivery');


CREATE VIEW public.v_customer_summary AS
SELECT
  p.id         AS user_id,
  p.first_name,
  p.last_name,
  p.phone,
  p.avatar_url,
  p.status,
  c.loyalty_points,
  c.loyalty_tier,
  c.total_spent,
  c.date_of_birth,
  c.notes,
  c.created_at AS customer_since
FROM public.profiles p
JOIN public.customers c ON c.id = p.id
WHERE p.status <> 'deleted';


CREATE VIEW public.v_sales_summary AS
SELECT
  s.id,
  s.reference_number,
  s.channel,
  s.status,
  s.grand_total,
  s.created_at,
  p.first_name  AS customer_first_name,
  p.last_name   AS customer_last_name,
  sp.first_name AS staff_first_name,
  sp.last_name  AS staff_last_name,
  st.name       AS store_name
FROM public.sales s
LEFT JOIN public.profiles p  ON p.id  = s.customer_id
LEFT JOIN public.profiles sp ON sp.id = s.staff_id
LEFT JOIN public.stores st   ON st.id = s.store_id;


-- ============================================================
-- 7. RPCs (Stored Procedures)
-- ============================================================

-- ----------------------------
-- Set default address (ownership-checked)
-- IS DISTINCT FROM handles NULL auth.uid() correctly
-- ----------------------------
CREATE OR REPLACE FUNCTION public.set_default_address(p_address_id INT, p_customer_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- IS DISTINCT FROM treats NULL as a concrete value,
  -- preventing anonymous callers from bypassing the ownership check.
  IF p_customer_id IS DISTINCT FROM auth.uid()
     AND NOT public.has_role('admin', 'store_manager')
  THEN
    RAISE EXCEPTION 'Access denied';
  END IF;
  UPDATE public.customer_addresses SET is_default = false WHERE customer_id = p_customer_id;
  UPDATE public.customer_addresses SET is_default = true  WHERE id = p_address_id AND customer_id = p_customer_id;
END;
$$;


-- ----------------------------
-- Verify POS PIN
-- ----------------------------
CREATE OR REPLACE FUNCTION public.verify_pos_pin(p_staff_id UUID, p_pin TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_hash TEXT;
BEGIN
  SELECT pos_pin_hash INTO v_hash
  FROM public.staff
  WHERE id = p_staff_id AND is_active = true;

  RETURN v_hash IS NOT NULL AND v_hash = crypt(p_pin, v_hash);
END;
$$;


-- ----------------------------
-- Set POS PIN (hashed)
-- ----------------------------
CREATE OR REPLACE FUNCTION public.set_pos_pin(p_staff_id UUID, p_pin TEXT)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF length(p_pin) <> 4 OR p_pin !~ '^\d{4}$' THEN
    RAISE EXCEPTION 'PIN must be exactly 4 digits';
  END IF;
  UPDATE public.staff SET pos_pin_hash = crypt(p_pin, gen_salt('bf')) WHERE id = p_staff_id;
END;
$$;


-- ----------------------------
-- Get Product Availability
-- Returns inventory rows for all size/colour combos of a product,
-- aggregated across all stores. Used by the customer product detail page.
-- ----------------------------
CREATE OR REPLACE FUNCTION public.get_product_availability(p_product_id INT)
RETURNS TABLE (
  id              INT,
  store_id        INT,
  product_size_id INT,
  color_id        INT,
  available       INT,
  reserved        INT,
  updated_at      TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT
    si.id,
    si.store_id,
    si.product_size_id,
    si.color_id,
    si.available,
    si.reserved,
    si.updated_at
  FROM public.store_inventory si
  JOIN public.product_sizes ps ON ps.id = si.product_size_id
  WHERE ps.product_id = p_product_id;
$$;


-- ----------------------------
-- Preview Coupon Validity
-- NOTE: This function is a VALIDATION-ONLY PREVIEW.
-- It does not acquire a durable lock and makes no writes.
-- The definitive enforcement (FOR UPDATE + used_count increment)
-- happens inside create_order_with_items / process_pos_sale.
-- Do NOT rely on this function's return value as a guarantee
-- that the offer will still be valid when the order is created.
-- ----------------------------
CREATE OR REPLACE FUNCTION public.apply_coupon(p_code TEXT, p_cart_total DECIMAL)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_offer    public.offers%ROWTYPE;
  v_discount DECIMAL := 0.00;
BEGIN
  -- Read-only check — no FOR UPDATE (lock would be released immediately anyway)
  SELECT * INTO v_offer
  FROM public.offers
  WHERE code = UPPER(p_code)
    AND is_active = true
    AND (expires_at IS NULL OR expires_at > NOW())
    AND (max_uses IS NULL OR used_count < max_uses)
    AND p_cart_total >= min_order_total;

  IF NOT FOUND THEN
    RETURN json_build_object('success', false, 'discount', 0,
                             'message', 'Invalid or expired code', 'offer_id', null);
  END IF;

  v_discount := CASE v_offer.discount_type
    WHEN 'percentage' THEN ROUND(p_cart_total * (v_offer.discount_value / 100), 2)
    WHEN 'fixed'      THEN LEAST(v_offer.discount_value, p_cart_total)
  END;

  RETURN json_build_object(
    'success',  true,
    'discount', v_discount,
    'message',  COALESCE(v_offer.description, 'Discount applied'),
    'offer_id', v_offer.id
  );
END;
$$;


-- ----------------------------
-- Internal helper: generate a unique order reference number
-- Bounded retry loop (max 10 attempts)
-- ----------------------------
CREATE OR REPLACE FUNCTION public.generate_reference_number(p_prefix TEXT DEFAULT 'ORD')
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_ref      TEXT;
  v_exists   BOOLEAN;
  v_attempts INT := 0;
BEGIN
  LOOP
    v_attempts := v_attempts + 1;
    IF v_attempts > 10 THEN
      RAISE EXCEPTION 'Could not generate a unique reference number after 10 attempts';
    END IF;

    v_ref := p_prefix || '-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-'
             || UPPER(SUBSTRING(gen_random_uuid()::TEXT FROM 1 FOR 8));

    SELECT EXISTS (SELECT 1 FROM public.sales WHERE reference_number = v_ref) INTO v_exists;
    EXIT WHEN NOT v_exists;
  END LOOP;
  RETURN v_ref;
END;
$$;


-- ----------------------------
-- Create Online Order (transactional)
-- p_store_id is required — inventory reservation is store-scoped
-- grand_total is computed server-side; client value is validated
-- Offer row locked with FOR UPDATE
-- reference_number generated internally
-- ----------------------------
CREATE OR REPLACE FUNCTION public.create_order_with_items(
  p_channel             public.sale_channel,
  p_store_id            INT,
  p_customer_id         UUID,
  p_shipping_address_id INT,
  p_subtotal            DECIMAL,
  p_discount_total      DECIMAL,
  p_tax_total           DECIMAL,
  p_shipping_cost       DECIMAL,
  p_offer_id            INT,
  p_items               JSONB
  -- Item shape: [{product_id, product_size_id, color_id, quantity, unit_price, discount_amount}]
)
RETURNS TABLE (sale_id INT, reference_number TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_sale_id           INT;
  v_reference         TEXT;
  v_item              JSONB;
  v_qty               INT;
  v_unit_price        DECIMAL;
  v_discount_amount   DECIMAL;
  v_avail             INT;
  v_computed_subtotal DECIMAL := 0.00;
  v_computed_grand    DECIMAL;
  v_offer             public.offers%ROWTYPE;
BEGIN
  -- Compute subtotal server-side and validate against client value
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_unit_price      := (v_item->>'unit_price')::DECIMAL;
    v_discount_amount := COALESCE((v_item->>'discount_amount')::DECIMAL, 0.00);
    v_computed_subtotal := v_computed_subtotal
                         + ((v_item->>'quantity')::INT * v_unit_price)
                         - v_discount_amount;
  END LOOP;

  IF ROUND(v_computed_subtotal, 2) <> ROUND(p_subtotal, 2) THEN
    RAISE EXCEPTION 'subtotal mismatch: client sent % but server computed %',
      p_subtotal, v_computed_subtotal;
  END IF;

  v_computed_grand := v_computed_subtotal - p_discount_total + p_tax_total + p_shipping_cost;

  IF v_computed_grand < 0 THEN
    RAISE EXCEPTION 'grand_total cannot be negative';
  END IF;

  v_reference := public.generate_reference_number('ORD');

  INSERT INTO public.sales (
    reference_number, channel, store_id, customer_id, shipping_address_id,
    subtotal, discount_total, tax_total, shipping_cost, grand_total, offer_id
  ) VALUES (
    v_reference, p_channel, p_store_id, p_customer_id, p_shipping_address_id,
    v_computed_subtotal, p_discount_total, p_tax_total, p_shipping_cost,
    v_computed_grand, p_offer_id
  ) RETURNING id INTO v_sale_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty := (v_item->>'quantity')::INT;

    -- Lock inventory row before reading to prevent concurrent over-reservation
    SELECT available INTO v_avail
    FROM public.store_inventory
    WHERE store_id        = p_store_id
      AND product_size_id = (v_item->>'product_size_id')::INT
      AND color_id        = (v_item->>'color_id')::INT
    FOR UPDATE;

    IF v_avail IS NULL OR v_avail < v_qty THEN
      RAISE EXCEPTION 'Insufficient stock for store=%, size_id=%, color_id=%',
        p_store_id, (v_item->>'product_size_id'), (v_item->>'color_id');
    END IF;

    UPDATE public.store_inventory
    SET reserved = reserved + v_qty
    WHERE store_id        = p_store_id
      AND product_size_id = (v_item->>'product_size_id')::INT
      AND color_id        = (v_item->>'color_id')::INT;

    v_discount_amount := COALESCE((v_item->>'discount_amount')::DECIMAL, 0.00);

    INSERT INTO public.sale_items (
      sale_id, product_id, product_size_id, color_id,
      quantity, unit_price, discount_amount, total_price
    ) VALUES (
      v_sale_id,
      (v_item->>'product_id')::INT,
      (v_item->>'product_size_id')::INT,
      (v_item->>'color_id')::INT,
      v_qty,
      (v_item->>'unit_price')::DECIMAL,
      v_discount_amount,
      v_qty * (v_item->>'unit_price')::DECIMAL - v_discount_amount
    );
  END LOOP;

  IF p_offer_id IS NOT NULL THEN
    SELECT * INTO v_offer FROM public.offers WHERE id = p_offer_id FOR UPDATE;
    IF v_offer.max_uses IS NOT NULL AND v_offer.used_count >= v_offer.max_uses THEN
      RAISE EXCEPTION 'Offer % has reached its usage limit', p_offer_id;
    END IF;
    UPDATE public.offers SET used_count = used_count + 1 WHERE id = p_offer_id;
  END IF;

  INSERT INTO public.deliveries (sale_id) VALUES (v_sale_id);

  RETURN QUERY SELECT v_sale_id, v_reference;
END;
$$;


-- ----------------------------
-- Process POS Sale (transactional)
-- grand_total computed server-side
-- Offer row locked with FOR UPDATE
-- reference_number generated internally
-- Inventory row locked FOR UPDATE before decrement
-- ----------------------------
CREATE OR REPLACE FUNCTION public.process_pos_sale(
  p_staff_id    UUID,
  p_store_id    INT,
  p_tax_total   DECIMAL,
  p_customer_id UUID    DEFAULT NULL,
  p_offer_id    INT     DEFAULT NULL,
  p_items       JSONB   DEFAULT '[]'
  -- Item shape: [{product_id, product_size_id, color_id, quantity, unit_price, discount_amount}]
)
RETURNS TABLE (sale_id INT, reference_number TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_sale_id           INT;
  v_reference         TEXT;
  v_item              JSONB;
  v_qty               INT;
  v_unit_price        DECIMAL;
  v_discount_amount   DECIMAL;
  v_avail             INT;
  v_computed_subtotal DECIMAL := 0.00;
  v_discount_total    DECIMAL := 0.00;
  v_computed_grand    DECIMAL;
  v_offer             public.offers%ROWTYPE;
BEGIN
  -- Compute totals server-side
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_unit_price      := (v_item->>'unit_price')::DECIMAL;
    v_discount_amount := COALESCE((v_item->>'discount_amount')::DECIMAL, 0.00);
    v_computed_subtotal := v_computed_subtotal
                         + ((v_item->>'quantity')::INT * v_unit_price);
    v_discount_total    := v_discount_total + v_discount_amount;
  END LOOP;

  -- Apply coupon-level discount on top of item-level discounts
  IF p_offer_id IS NOT NULL THEN
    SELECT * INTO v_offer FROM public.offers WHERE id = p_offer_id AND is_active = true FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Offer % is invalid or inactive', p_offer_id;
    END IF;
    IF v_offer.max_uses IS NOT NULL AND v_offer.used_count >= v_offer.max_uses THEN
      RAISE EXCEPTION 'Offer % has reached its usage limit', p_offer_id;
    END IF;
    v_discount_total := v_discount_total + CASE v_offer.discount_type
      WHEN 'percentage' THEN ROUND((v_computed_subtotal - v_discount_total) * (v_offer.discount_value / 100), 2)
      WHEN 'fixed'      THEN LEAST(v_offer.discount_value, v_computed_subtotal - v_discount_total)
    END;
  END IF;

  v_computed_grand := v_computed_subtotal - v_discount_total + p_tax_total;

  IF v_computed_grand < 0 THEN
    RAISE EXCEPTION 'grand_total cannot be negative';
  END IF;

  v_reference := public.generate_reference_number('POS');

  INSERT INTO public.sales (
    reference_number, channel, store_id, staff_id, customer_id, offer_id,
    status, subtotal, discount_total, tax_total, grand_total
  ) VALUES (
    v_reference, 'pos', p_store_id, p_staff_id, p_customer_id, p_offer_id,
    'paid', v_computed_subtotal, v_discount_total, p_tax_total, v_computed_grand
  ) RETURNING id INTO v_sale_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty             := (v_item->>'quantity')::INT;
    v_discount_amount := COALESCE((v_item->>'discount_amount')::DECIMAL, 0.00);

    -- Lock inventory row before reading, preventing concurrent over-decrement
    SELECT available INTO v_avail
    FROM public.store_inventory
    WHERE store_id        = p_store_id
      AND product_size_id = (v_item->>'product_size_id')::INT
      AND color_id        = (v_item->>'color_id')::INT
    FOR UPDATE;

    IF v_avail IS NULL OR v_avail < v_qty THEN
      RAISE EXCEPTION 'Insufficient stock for size_id=%, color_id=% at store %',
        (v_item->>'product_size_id'), (v_item->>'color_id'), p_store_id;
    END IF;

    UPDATE public.store_inventory
    SET available = available - v_qty
    WHERE store_id        = p_store_id
      AND product_size_id = (v_item->>'product_size_id')::INT
      AND color_id        = (v_item->>'color_id')::INT;

    INSERT INTO public.sale_items (
      sale_id, product_id, product_size_id, color_id,
      quantity, unit_price, discount_amount, total_price
    ) VALUES (
      v_sale_id,
      (v_item->>'product_id')::INT,
      (v_item->>'product_size_id')::INT,
      (v_item->>'color_id')::INT,
      v_qty,
      (v_item->>'unit_price')::DECIMAL,
      v_discount_amount,
      v_qty * (v_item->>'unit_price')::DECIMAL - v_discount_amount
    );
  END LOOP;

  IF p_offer_id IS NOT NULL THEN
    UPDATE public.offers SET used_count = used_count + 1 WHERE id = p_offer_id;
  END IF;

  RETURN QUERY SELECT v_sale_id, v_reference;
END;
$$;


-- ----------------------------
-- Earn / Redeem Loyalty Points
-- total_spent not touched here (handled by sale trigger)
-- ----------------------------
CREATE OR REPLACE FUNCTION public.adjust_loyalty_points(
  p_customer_id UUID,
  p_points      INT,          -- positive = earn, negative = redeem
  p_description TEXT,
  p_sale_id     INT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- Zero-point calls are a no-op (also enforced by table CHECK)
  IF p_points = 0 THEN
    RETURN;
  END IF;

  IF p_points < 0 THEN
    IF (SELECT loyalty_points FROM public.customers WHERE id = p_customer_id) + p_points < 0 THEN
      RAISE EXCEPTION 'Insufficient loyalty points';
    END IF;
  END IF;

  UPDATE public.customers
  SET loyalty_points = loyalty_points + p_points
  WHERE id = p_customer_id;

  INSERT INTO public.loyalty_transactions (customer_id, sale_id, points, description)
  VALUES (p_customer_id, p_sale_id, p_points, p_description);
END;
$$;


-- ============================================================
-- 8. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_addresses   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_sizes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_colors       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_inventory      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sale_items           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.returns              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.return_items         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commissions          ENABLE ROW LEVEL SECURITY;


-- ──────────────────────────────────────
-- PROFILES
-- Own-profile read excludes status='deleted' so that a user who
-- soft-deletes their account cannot re-authenticate and retrieve their row.
-- ──────────────────────────────────────
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id AND status <> 'deleted');

CREATE POLICY "profiles_select_staff" ON public.profiles
  FOR SELECT USING (
    public.has_role('admin', 'store_manager', 'salesperson', 'driver')
    AND status <> 'deleted'
  );

CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id AND status <> 'deleted');

CREATE POLICY "profiles_update_admin" ON public.profiles
  FOR UPDATE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- CUSTOMERS
-- Staff policy uses JWT role check only; deleted-profile filtering
-- is enforced at the view layer (v_customer_summary).
-- ──────────────────────────────────────
CREATE POLICY "customers_select_own" ON public.customers
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "customers_select_staff" ON public.customers
  FOR SELECT USING (
    public.has_role('admin', 'store_manager', 'salesperson')
  );

CREATE POLICY "customers_update_admin" ON public.customers
  FOR UPDATE USING (public.has_role('admin', 'store_manager'));


-- ──────────────────────────────────────
-- CUSTOMER ADDRESSES
-- ──────────────────────────────────────
CREATE POLICY "addresses_all_own" ON public.customer_addresses
  FOR ALL USING (auth.uid() = customer_id);

CREATE POLICY "addresses_select_staff" ON public.customer_addresses
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson', 'driver'));


-- ──────────────────────────────────────
-- STAFF
-- Store manager sees only active staff; admin sees all.
-- ──────────────────────────────────────
CREATE POLICY "staff_select_self" ON public.staff
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "staff_select_manager" ON public.staff
  FOR SELECT USING (
    public.has_role('store_manager')
    AND is_active = true
  );

CREATE POLICY "staff_select_admin" ON public.staff
  FOR SELECT USING (public.has_role('admin'));

CREATE POLICY "staff_all_admin" ON public.staff
  FOR ALL USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- STORES
-- Customers only see active stores; staff see all.
-- ──────────────────────────────────────
CREATE POLICY "stores_select_customers" ON public.stores
  FOR SELECT USING (
    auth.role() = 'authenticated'
    AND is_active = true
  );

CREATE POLICY "stores_select_staff" ON public.stores
  FOR SELECT USING (
    public.has_role('admin', 'store_manager', 'salesperson', 'driver')
  );

CREATE POLICY "stores_all_admin" ON public.stores
  FOR ALL USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- PRODUCT CATALOGUE
-- Public read excludes 'archived' products; staff see all.
-- ──────────────────────────────────────
CREATE POLICY "categories_public_read"  ON public.categories  FOR SELECT USING (true);
CREATE POLICY "categories_admin_write"  ON public.categories  FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "brands_public_read"      ON public.brands      FOR SELECT USING (true);
CREATE POLICY "brands_admin_write"      ON public.brands      FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "products_public_read"    ON public.products    FOR SELECT USING (status = 'active');
CREATE POLICY "products_staff_read_all" ON public.products    FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));
CREATE POLICY "products_admin_write"    ON public.products    FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "sizes_public_read"       ON public.product_sizes   FOR SELECT USING (true);
CREATE POLICY "sizes_admin_write"       ON public.product_sizes   FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "colors_public_read"      ON public.product_colors  FOR SELECT USING (true);
CREATE POLICY "colors_admin_write"      ON public.product_colors  FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "images_public_read"      ON public.product_images  FOR SELECT USING (true);
CREATE POLICY "images_admin_write"      ON public.product_images  FOR ALL    USING (public.has_role('admin'));

CREATE POLICY "inventory_public_read"   ON public.store_inventory FOR SELECT USING (true);
CREATE POLICY "inventory_admin_write"   ON public.store_inventory FOR ALL    USING (public.has_role('admin', 'store_manager'));


-- ──────────────────────────────────────
-- OFFERS
-- Merged from supabase_setup.sql + 002_offers_anon_read_policy.sql:
--   • anon users can read active offers (homepage hero slides)
--   • authenticated users can read active offers
--   • staff can read all offers (including inactive) for troubleshooting
--   • admin has full write access
-- ──────────────────────────────────────

-- Performance index for homepage query:
--   SELECT * FROM offers WHERE is_active = true AND (expires_at IS NULL OR expires_at > now())
--   ORDER BY created_at DESC LIMIT 5
CREATE INDEX IF NOT EXISTS idx_offers_active_expires
  ON public.offers (is_active, expires_at DESC NULLS FIRST, created_at DESC);

-- Allow unauthenticated (anon) users to read active offers
CREATE POLICY "offers_anon_read_active" ON public.offers
  FOR SELECT
  USING (is_active = true);

-- Authenticated users can also read active offers
CREATE POLICY "offers_authenticated_read" ON public.offers
  FOR SELECT USING (auth.role() = 'authenticated' AND is_active = true);

-- Staff see all offers regardless of is_active (for troubleshooting coupon issues)
CREATE POLICY "offers_staff_read_all" ON public.offers
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "offers_admin_all" ON public.offers
  FOR ALL USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- SALES
-- ──────────────────────────────────────
CREATE POLICY "sales_select_own" ON public.sales
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "sales_select_staff" ON public.sales
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "sales_insert_customer" ON public.sales
  FOR INSERT WITH CHECK (
    auth.uid() = customer_id
    OR public.has_role('admin', 'store_manager', 'salesperson')
  );

CREATE POLICY "sales_update_staff" ON public.sales
  FOR UPDATE USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "sales_delete_admin" ON public.sales
  FOR DELETE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- SALE ITEMS
-- ──────────────────────────────────────
CREATE POLICY "sale_items_select_own" ON public.sale_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.sales WHERE id = sale_id AND customer_id = auth.uid())
  );

CREATE POLICY "sale_items_select_staff" ON public.sale_items
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "sale_items_insert" ON public.sale_items
  FOR INSERT WITH CHECK (
    public.has_role('admin', 'store_manager', 'salesperson')
    OR EXISTS (SELECT 1 FROM public.sales WHERE id = sale_id AND customer_id = auth.uid())
  );

CREATE POLICY "sale_items_delete_admin" ON public.sale_items
  FOR DELETE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- DELIVERIES
-- ──────────────────────────────────────
CREATE POLICY "deliveries_select_own" ON public.deliveries
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.sales WHERE id = sale_id AND customer_id = auth.uid())
  );

CREATE POLICY "deliveries_select_driver" ON public.deliveries
  FOR SELECT USING (auth.uid() = driver_id OR public.has_role('admin', 'store_manager'));

CREATE POLICY "deliveries_update_driver" ON public.deliveries
  FOR UPDATE USING (auth.uid() = driver_id OR public.has_role('admin', 'store_manager'));

CREATE POLICY "deliveries_delete_admin" ON public.deliveries
  FOR DELETE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- WISHLIST
-- Granular policies from 001_create_wishlist_table.sql.
-- user_id references auth.users directly.
-- ──────────────────────────────────────
CREATE POLICY "wishlist_select_own" ON public.wishlist
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "wishlist_insert_own" ON public.wishlist
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "wishlist_delete_own" ON public.wishlist
  FOR DELETE USING (auth.uid() = user_id);


-- ──────────────────────────────────────
-- RETURNS & RETURN ITEMS
-- ──────────────────────────────────────
CREATE POLICY "returns_select_own" ON public.returns
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "returns_insert_own" ON public.returns
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "returns_select_staff" ON public.returns
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "returns_update_staff" ON public.returns
  FOR UPDATE USING (public.has_role('admin', 'store_manager'));

CREATE POLICY "returns_delete_admin" ON public.returns
  FOR DELETE USING (public.has_role('admin'));

CREATE POLICY "return_items_select_own" ON public.return_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.returns WHERE id = return_id AND customer_id = auth.uid())
  );

CREATE POLICY "return_items_select_staff" ON public.return_items
  FOR SELECT USING (public.has_role('admin', 'store_manager', 'salesperson'));

CREATE POLICY "return_items_insert" ON public.return_items
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.returns WHERE id = return_id AND customer_id = auth.uid())
    OR public.has_role('admin', 'store_manager')
  );

CREATE POLICY "return_items_delete_admin" ON public.return_items
  FOR DELETE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- LOYALTY TRANSACTIONS
-- ──────────────────────────────────────
CREATE POLICY "loyalty_select_own" ON public.loyalty_transactions
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "loyalty_select_staff" ON public.loyalty_transactions
  FOR SELECT USING (public.has_role('admin', 'store_manager'));

CREATE POLICY "loyalty_delete_admin" ON public.loyalty_transactions
  FOR DELETE USING (public.has_role('admin'));


-- ──────────────────────────────────────
-- COMMISSIONS
-- ──────────────────────────────────────
CREATE POLICY "commissions_select_self" ON public.commissions
  FOR SELECT USING (auth.uid() = staff_id);

CREATE POLICY "commissions_all_admin" ON public.commissions
  FOR ALL USING (public.has_role('admin'));