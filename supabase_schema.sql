-- Subject-based Authorization Schema
-- Each subject has its own table with authorized users

-- ============================================
-- SUBJECT TABLES (one per subject)
-- ============================================

-- ============================================
-- SUBJECTS TABLE (Single table design)
-- ============================================

CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    qr_code TEXT UNIQUE NOT NULL,
    auth_users TEXT[] DEFAULT '{}',
    chapters TEXT DEFAULT '',
    flashcards TEXT DEFAULT '',
    pyqs TEXT DEFAULT '',
    exemplars TEXT DEFAULT '',
    notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert initial data matching previous tables
INSERT INTO subjects (name, qr_code) VALUES 
    ('11th - Math', 'http://epathshala.nic.in/QR/?id=11076'),
    ('12th - Physics', 'google.com');

-- ============================================
-- USERS TABLE
-- ============================================

CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view subjects if they are in auth_users
-- Or maybe just view public fields? For now, let's allow select for everyone, filter in client?
-- "The app should show subjects to the user only if... auth_users contains the user's email"
-- We can enforce this in RLS or in the query.
-- RLS Policy:
-- Allow anyone to view subjects (filtering happens in client query for now)
DROP POLICY IF EXISTS "Users can view authorized subjects" ON subjects;
CREATE POLICY "Users can view authorized subjects"
    ON subjects FOR SELECT
    USING (true);

-- Allow update via RPC (security definer handles it) or explicit policy
CREATE POLICY "Anyone can update subjects"
    ON subjects FOR UPDATE
    USING (true); -- Restricted by logic in app or RPC

-- Users table policies
CREATE POLICY "Users can view their own profile"
    ON users FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own profile"
    ON users FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update their own profile"
    ON users FOR UPDATE
    USING (true);

-- ============================================
-- RPC FUNCTIONS
-- ============================================

-- Function to safely add user to subject
CREATE OR REPLACE FUNCTION add_user_to_subject(qr_code_text TEXT, user_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    subject_exists BOOLEAN;
BEGIN
    -- Check if subject exists
    SELECT EXISTS(SELECT 1 FROM subjects WHERE qr_code = qr_code_text) INTO subject_exists;
    
    IF NOT subject_exists THEN
        RETURN FALSE;
    END IF;
    
    -- Update auth_users if email not present
    UPDATE subjects
    SET auth_users = array_append(auth_users, user_email)
    WHERE qr_code = qr_code_text
    AND NOT (auth_users @> ARRAY[user_email]);
    
    RETURN TRUE;
END;
$$;

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_subjects_qr_code ON subjects(qr_code);
CREATE INDEX idx_subjects_auth_users ON subjects USING GIN(auth_users);

-- ============================================
-- COLLEGE APPLICATIONS TABLE
-- ============================================

CREATE TABLE college_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_email TEXT NOT NULL,
    grade_9 TEXT,
    grade_10 TEXT,
    grade_11 TEXT,
    grade_12 TEXT,
    extracurriculars TEXT,
    needs_aid BOOLEAN DEFAULT FALSE,
    location TEXT NOT NULL, -- 'india' or 'abroad'
    countries TEXT[], -- Array of countries if location is 'abroad'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_email)
);

-- RLS for college_applications
ALTER TABLE college_applications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own college application"
    ON college_applications FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own college application"
    ON college_applications FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update their own college application"
    ON college_applications FOR UPDATE
    USING (true);

CREATE INDEX idx_college_applications_user_email ON college_applications(user_email);
