-- Ejecutar en SQL Editor del proyecto Blackstore, una sola vez.
-- La tabla existente tiene la columna obligatoria whatsapp (no phone).
-- No se elimina ni modifica información previa.
ALTER TABLE public.vendor_applications ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.vendor_applications FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.submit_vendor_application(
 p_business_name text, p_contact_name text, p_city text,
 p_phone text, p_category text, p_description text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
 IF length(trim(coalesce(p_business_name,''))) NOT BETWEEN 1 AND 80
 OR length(trim(coalesce(p_contact_name,''))) NOT BETWEEN 1 AND 80
 OR length(trim(coalesce(p_city,''))) NOT BETWEEN 1 AND 60
 OR length(trim(coalesce(p_phone,''))) NOT BETWEEN 7 AND 25
 OR length(trim(coalesce(p_category,''))) NOT BETWEEN 1 AND 100
 OR length(coalesce(p_description,'')) > 500 THEN
   RAISE EXCEPTION 'Datos de solicitud no validos';
 END IF;
 INSERT INTO public.vendor_applications
 (business_name, contact_name, city, whatsapp, category, description, status)
 VALUES (trim(p_business_name), trim(p_contact_name), trim(p_city), trim(p_phone),
 trim(p_category), trim(coalesce(p_description,'')), 'pending');
END;
$$;
REVOKE ALL ON FUNCTION public.submit_vendor_application(text,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_vendor_application(text,text,text,text,text,text) TO anon, authenticated;
-- Antes de lanzamiento masivo, agregar CAPTCHA y proteccion contra spam.
