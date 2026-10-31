-- V6: ejecutar una sola vez en SQL Editor como propietario del proyecto.
-- El rol admin solo se asigna desde el servidor (auth.users.raw_app_meta_data).
CREATE OR REPLACE FUNCTION public.admin_list_vendor_applications()
RETURNS SETOF public.vendor_applications
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF auth.uid() IS NULL OR NOT EXISTS (
  SELECT 1 FROM auth.users u WHERE u.id=auth.uid() AND u.raw_app_meta_data->>'role'='admin'
 ) THEN RAISE EXCEPTION 'Acceso denegado'; END IF;
 RETURN QUERY SELECT * FROM public.vendor_applications ORDER BY created_at DESC;
END; $$;
REVOKE ALL ON FUNCTION public.admin_list_vendor_applications() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_list_vendor_applications() TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_review_vendor_application(p_application_id uuid,p_new_status text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
 IF auth.uid() IS NULL OR NOT EXISTS (
  SELECT 1 FROM auth.users u WHERE u.id=auth.uid() AND u.raw_app_meta_data->>'role'='admin'
 ) THEN RAISE EXCEPTION 'Acceso denegado'; END IF;
 IF p_new_status NOT IN ('approved','rejected') OR p_new_status IS NULL THEN
  RAISE EXCEPTION 'Estado no permitido'; END IF;
 UPDATE public.vendor_applications SET status=p_new_status
 WHERE id=p_application_id AND status='pending';
 IF NOT FOUND THEN RAISE EXCEPTION 'Solicitud no encontrada o ya revisada'; END IF;
END; $$;
REVOKE ALL ON FUNCTION public.admin_review_vendor_application(uuid,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_review_vendor_application(uuid,text) TO authenticated;
