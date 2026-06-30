-- Apply has_permission to areas (linked to locations permissions)
DROP POLICY IF EXISTS "Users read own company areas" ON public.areas;
DROP POLICY IF EXISTS "Users insert own company areas" ON public.areas;
DROP POLICY IF EXISTS "Users update own company areas" ON public.areas;

CREATE POLICY "Users read own company areas with permission"
  ON public.areas FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.read')
  );

CREATE POLICY "Users insert own company areas with permission"
  ON public.areas FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.create')
  );

CREATE POLICY "Users update own company areas with permission"
  ON public.areas FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('locations.update')
  );

-- Apply has_permission to assets
DROP POLICY IF EXISTS "Users read own company assets" ON public.assets;
DROP POLICY IF EXISTS "Users insert own company assets" ON public.assets;
DROP POLICY IF EXISTS "Users update own company assets" ON public.assets;

CREATE POLICY "Users read own company assets with permission"
  ON public.assets FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.read')
  );

CREATE POLICY "Users insert own company assets with permission"
  ON public.assets FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.create')
  );

CREATE POLICY "Users update own company assets with permission"
  ON public.assets FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('assets.update')
  );

-- Apply has_permission to categories
DROP POLICY IF EXISTS "Users read own company categories" ON public.categories;
DROP POLICY IF EXISTS "Users insert own company categories" ON public.categories;
DROP POLICY IF EXISTS "Users update own company categories" ON public.categories;

CREATE POLICY "Users read own company categories with permission"
  ON public.categories FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('categories.read')
  );

CREATE POLICY "Users insert own company categories with permission"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('categories.create')
  );

CREATE POLICY "Users update own company categories with permission"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('categories.update')
  );

-- Apply has_permission to work_orders
DROP POLICY IF EXISTS "Users read own company work orders" ON public.work_orders;
DROP POLICY IF EXISTS "Users insert own company work orders" ON public.work_orders;
DROP POLICY IF EXISTS "Users update own company work orders" ON public.work_orders;

CREATE POLICY "Users read own company work orders with permission"
  ON public.work_orders FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.read')
  );

CREATE POLICY "Users insert own company work orders with permission"
  ON public.work_orders FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.create')
  );

CREATE POLICY "Users update own company work orders with permission"
  ON public.work_orders FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );

-- Apply has_permission to work_order_change_requests
DROP POLICY IF EXISTS "Users read own company work order change requests" ON public.work_order_change_requests;
DROP POLICY IF EXISTS "Users insert own company work order change requests" ON public.work_order_change_requests;
DROP POLICY IF EXISTS "Users update own company work order change requests" ON public.work_order_change_requests;

CREATE POLICY "Users read own company work order change requests with permission"
  ON public.work_order_change_requests FOR SELECT
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.read')
  );

CREATE POLICY "Users insert own company work order change requests with permission"
  ON public.work_order_change_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );

CREATE POLICY "Users update own company work order change requests with permission"
  ON public.work_order_change_requests FOR UPDATE
  TO authenticated
  USING (
    company_id = public.get_user_company_id()
    AND public.has_permission('work_orders.update')
  );
