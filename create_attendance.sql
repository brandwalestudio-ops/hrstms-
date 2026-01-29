-- Create attendance table
CREATE TABLE public.attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  date DATE DEFAULT CURRENT_DATE NOT NULL,
  clock_in TIMESTAMP WITH TIME ZONE DEFAULT now(),
  clock_out TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'present',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(employee_id, date)
);

-- Enable RLS
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Employees can view own attendance"
  ON public.attendance FOR SELECT
  USING (auth.uid() = employee_id);

CREATE POLICY "Admin/HR can view all attendance"
  ON public.attendance FOR SELECT
  USING (public.is_admin_or_hr(auth.uid()));

CREATE POLICY "Employees can clock in (insert)"
  ON public.attendance FOR INSERT
  WITH CHECK (auth.uid() = employee_id);

CREATE POLICY "Employees can clock out (update)"
  ON public.attendance FOR UPDATE
  USING (auth.uid() = employee_id);

-- Add to realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.attendance;
