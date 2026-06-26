# Categories Table Policies

```sql
CREATE POLICY "Users read own company categories"
  ON public.categories FOR SELECT
  TO authenticated
  USING (company_id = public.get_user_company_id());

CREATE POLICY "Users insert own company categories"
  ON public.categories FOR INSERT
  TO authenticated
  WITH CHECK (company_id = public.get_user_company_id());

CREATE POLICY "Users update own company categories"
  ON public.categories FOR UPDATE
  TO authenticated
  USING (company_id = public.get_user_company_id());
```

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if there are active assets associated with the category:
  * Trigger: `tr_prevent_delete_categories_with_relations`
  * Active Assets Check: Blocked if any asset referencing this category has `deleted_at IS NULL`.
