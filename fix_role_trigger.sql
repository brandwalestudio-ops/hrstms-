-- Create or Replace the function to handle new user creation
-- This update respects the 'role' passed in the user metadata during signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role text;
BEGIN
  -- Insert into profiles
  INSERT INTO public.profiles (id, email, full_name, department, phone)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'department', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'phone', '')
  );
  
  -- Determine role from metadata, default to 'employee'
  v_role := COALESCE(NEW.raw_user_meta_data ->> 'role', 'employee');
  
  -- Validate role against enum values (simplified check)
  IF v_role NOT IN ('admin', 'hr_admin', 'store_incharge', 'employee') THEN
    v_role := 'employee';
  END IF;

  -- Insert into user_roles
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, v_role::app_role);
  
  RETURN NEW;
END;
$$;
