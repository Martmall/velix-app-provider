-- ========================================================
-- VELIX PRODUCTION SUPABASE SCHEMA & SEED SCRIPT
-- ========================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES / USERS TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user', -- 'user', 'partner', 'admin'
    is_verified BOOLEAN DEFAULT false,
    license_number TEXT,
    business_name TEXT,
    cac_number TEXT,
    bank_name TEXT,
    account_number TEXT,
    account_name TEXT,
    rating NUMERIC DEFAULT 5.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. VEHICLES TABLE
CREATE TABLE IF NOT EXISTS public.vehicles (
    id TEXT PRIMARY KEY,
    partner_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    category TEXT NOT NULL,
    price_per_day NUMERIC NOT NULL,
    location TEXT NOT NULL,
    image_url TEXT NOT NULL,
    images JSONB DEFAULT '[]'::jsonb,
    specs JSONB DEFAULT '{}'::jsonb,
    is_available BOOLEAN DEFAULT true,
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'rented', 'maintenance'
    rating NUMERIC DEFAULT 5.0,
    trips_count INTEGER DEFAULT 0,
    license_plate TEXT,
    video_url TEXT,
    unavailable_dates JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS public.bookings (
    id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL REFERENCES public.profiles(id),
    partner_id TEXT NOT NULL REFERENCES public.profiles(id),
    vehicle_id TEXT NOT NULL REFERENCES public.vehicles(id),
    customer_name TEXT NOT NULL,
    customer_phone TEXT,
    customer_email TEXT,
    vehicle_name TEXT NOT NULL,
    vehicle_image TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    pickup_location TEXT NOT NULL,
    dropoff_location TEXT NOT NULL,
    total_price NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'active', 'completed', 'cancelled'
    verification_code TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TRANSACTIONS & WALLET TABLE
CREATE TABLE IF NOT EXISTS public.transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    title TEXT NOT NULL,
    description TEXT,
    amount NUMERIC NOT NULL,
    type TEXT NOT NULL, -- 'credit', 'debit', 'hold', 'payout'
    status TEXT NOT NULL DEFAULT 'completed', -- 'completed', 'pending', 'failed'
    reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. SUPPORT & DISPUTES TABLE
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    user_name TEXT NOT NULL,
    user_role TEXT NOT NULL, -- 'partner', 'user'
    subject TEXT NOT NULL,
    category TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    status TEXT NOT NULL DEFAULT 'in_progress', -- 'open', 'in_progress', 'resolved'
    messages JSONB DEFAULT '[]'::jsonb,
    evidence_urls JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. FAVORITES TABLE
CREATE TABLE IF NOT EXISTS public.favorites (
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    vehicle_id TEXT NOT NULL REFERENCES public.vehicles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, vehicle_id)
);

-- ========================================================
-- SEED DATA (3 REAL RECORDS PER FEATURE ACROSS LIFECYCLE)
-- ========================================================

-- SEED PROFILES
INSERT INTO public.profiles (id, full_name, email, phone, avatar_url, role, is_verified, license_number, business_name, cac_number, bank_name, account_number, account_name, rating)
VALUES
('usr_admin_01', 'Velix Executive Admin', 'admin@velix.com', '+234 800 000 0000', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 'admin', true, NULL, 'Velix Global Logistics', 'RC-000001', 'Access Bank', '0011223344', 'Velix Corporate Admin', 5.0),
('usr_partner_01', 'Ibrahim Suleiman', 'partner@velix.com', '+234 803 123 4567', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'partner', true, 'DL-883921-ABJ', 'Suleiman Prestige Motors Ltd', 'RC-1849204', 'Zenith Bank', '0123456789', 'Ibrahim Suleiman Autos', 4.95),
('usr_user_01', 'Inusa Ibrahim', 'user@velix.com', '+234 903 542 7435', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', 'user', true, 'DL-908234-LAG', NULL, NULL, NULL, NULL, NULL, 5.0)
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role = EXCLUDED.role, is_verified = EXCLUDED.is_verified;

-- SEED 3 REAL VEHICLES FOR PARTNER
INSERT INTO public.vehicles (id, partner_id, name, brand, model, year, category, price_per_day, location, image_url, images, specs, is_available, status, rating, trips_count, license_plate, video_url, unavailable_dates)
VALUES
(
    'car_partner_01',
    'usr_partner_01',
    'Toyota Land Cruiser Prado V6',
    'Toyota',
    'Land Cruiser Prado',
    2024,
    'SUV',
    150000,
    'Victoria Island, Lagos',
    'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800',
    '["https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800", "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800"]'::jsonb,
    '{"seats": "7 Seats", "transmission": "Automatic", "fuel": "Petrol V6", "power": "280 HP"}'::jsonb,
    true,
    'rented',
    4.95,
    14,
    'KJA-482-AA',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    '["2026-09-10", "2026-09-11", "2026-09-12"]'::jsonb
),
(
    'car_partner_02',
    'usr_partner_01',
    'Mercedes-Benz GLE 450 4MATIC',
    'Mercedes-Benz',
    'GLE 450',
    2023,
    'Luxury',
    180000,
    'Lekki Phase 1, Lagos',
    'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
    '["https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800", "https://images.unsplash.com/photo-1606611013016-969c19ba27bb?w=800"]'::jsonb,
    '{"seats": "5 Seats", "transmission": "Automatic 9G", "fuel": "Mild Hybrid", "power": "362 HP"}'::jsonb,
    true,
    'active',
    5.0,
    8,
    'APP-104-LK',
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    '["2026-09-15", "2026-09-16"]'::jsonb
),
(
    'car_partner_03',
    'usr_partner_01',
    'Lexus RX 350 F-Sport',
    'Lexus',
    'RX 350',
    2022,
    'SUV',
    120000,
    'Ikeja GRA, Lagos',
    'https://images.unsplash.com/photo-1563720223185-11003d516935?w=800',
    '["https://images.unsplash.com/photo-1563720223185-11003d516935?w=800"]'::jsonb,
    '{"seats": "5 Seats", "transmission": "Automatic", "fuel": "Petrol V6", "power": "295 HP"}'::jsonb,
    false,
    'maintenance',
    4.88,
    22,
    'LSR-339-BC',
    NULL,
    '["2026-09-08", "2026-09-09", "2026-09-10", "2026-09-11"]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, price_per_day = EXCLUDED.price_per_day, status = EXCLUDED.status;

-- SEED 3 REAL BOOKINGS (ACTIVE, PENDING, COMPLETED)
INSERT INTO public.bookings (id, customer_id, partner_id, vehicle_id, customer_name, customer_phone, customer_email, vehicle_name, vehicle_image, start_date, end_date, pickup_location, dropoff_location, total_price, status, verification_code)
VALUES
(
    'BK-89021',
    'usr_user_01',
    'usr_partner_01',
    'car_partner_01',
    'Inusa Ibrahim',
    '+234 903 542 7435',
    'user@velix.com',
    'Toyota Land Cruiser Prado V6',
    'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800',
    NOW() - INTERVAL '1 day',
    NOW() + INTERVAL '2 days',
    'Victoria Island (Eko Hotel Gate)',
    'Murtala Muhammed International Airport, Ikeja',
    150000,
    'active',
    '8492'
),
(
    'BK-89022',
    'usr_user_01',
    'usr_partner_01',
    'car_partner_02',
    'Inusa Ibrahim',
    '+234 903 542 7435',
    'user@velix.com',
    'Mercedes-Benz GLE 450 4MATIC',
    'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
    NOW() + INTERVAL '1 day',
    NOW() + INTERVAL '3 days',
    'Admiralty Way, Lekki Phase 1',
    'Victoria Island',
    180000,
    'pending',
    '4910'
),
(
    'BK-84012',
    'usr_user_01',
    'usr_partner_01',
    'car_partner_03',
    'Amina Bello',
    '+234 802 111 2233',
    'amina.bello@example.com',
    'Lexus RX 350 F-Sport',
    'https://images.unsplash.com/photo-1563720223185-11003d516935?w=800',
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '8 days',
    'Ikeja GRA, Lagos',
    'Ikeja GRA, Lagos',
    150000,
    'completed',
    '3391'
)
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, total_price = EXCLUDED.total_price;

-- SEED 3 FINANCIAL RECORDS PER ACCOUNT
INSERT INTO public.transactions (id, user_id, title, description, amount, type, status, reference, created_at)
VALUES
('txn_prt_01', 'usr_partner_01', 'Rental Payout Credited', 'Net earnings for completed booking BK-84012 (Lexus RX 350)', 127500, 'credit', 'completed', 'REF-PAY-84012', NOW() - INTERVAL '8 days'),
('txn_prt_02', 'usr_partner_01', 'Escrow Rental Hold', 'Guaranteed escrow holding for active booking BK-89021', 127500, 'hold', 'pending', 'REF-ESC-89021', NOW() - INTERVAL '1 day'),
('txn_prt_03', 'usr_partner_01', 'Bank Withdrawal Sent', 'Direct transfer to Zenith Bank account 0123456789', 70000, 'payout', 'completed', 'REF-WDR-33921', NOW() - INTERVAL '3 days'),
('txn_usr_01', 'usr_user_01', 'Wallet Top-up (Paystack)', 'Instant debit card deposit to Velix Wallet', 50000, 'credit', 'completed', 'ref_982410', NOW() - INTERVAL '2 days'),
('txn_usr_02', 'usr_user_01', 'Rental Booking Payment', 'Booking payment for Toyota Land Cruiser Prado BK-89021', 150000, 'debit', 'completed', 'ref_bk_89021', NOW() - INTERVAL '1 day'),
('txn_usr_03', 'usr_user_01', 'Security Deposit Refund', 'Refund of cautionary damage deposit for past trip BK-84012', 30000, 'credit', 'completed', 'ref_rf_84012', NOW() - INTERVAL '7 days')
ON CONFLICT (id) DO NOTHING;

-- SEED 3 SUPPORT TICKETS FOR PARTNER & USER
INSERT INTO public.support_tickets (id, user_id, user_name, user_role, subject, category, priority, status, messages)
VALUES
(
    'TKT-4921',
    'usr_partner_01',
    'Ibrahim Suleiman',
    'partner',
    'Security Deposit & Fuel Level Confirmation',
    'Booking Inspection',
    'medium',
    'in_progress',
    '[{"sender": "Ibrahim Suleiman", "text": "Customer returned car with 85% fuel level as agreed. Deposit can be released.", "timestamp": "2026-09-08T14:30:00Z"}]'::jsonb
),
(
    'TKT-4922',
    'usr_partner_01',
    'Ibrahim Suleiman',
    'partner',
    'Toll Fee Reimbursement on Lekki-Ikoyi Link',
    'Billing',
    'low',
    'resolved',
    '[{"sender": "Ibrahim Suleiman", "text": "Toll charge of N1,500 has been verified.", "timestamp": "2026-09-05T09:15:00Z"}]'::jsonb
),
(
    'TKT-4923',
    'usr_partner_01',
    'Ibrahim Suleiman',
    'partner',
    'Fleet Commercial Insurance Policy Renewal Inquiry',
    'Policy',
    'high',
    'open',
    '[{"sender": "Ibrahim Suleiman", "text": "Kindly provide updated comprehensive policy documents for the 2024 Prado.", "timestamp": "2026-09-09T08:00:00Z"}]'::jsonb
),
(
    'TKT-7823',
    'usr_user_01',
    'Inusa Ibrahim',
    'user',
    'Airport Terminal Pick-up Assistance',
    'Trip Assistance',
    'high',
    'in_progress',
    '[{"sender": "Inusa Ibrahim", "text": "Arriving at Terminal 2, flight slightly delayed by 15 mins. Will host meet at arrivals?", "timestamp": "2026-09-09T07:45:00Z"}]'::jsonb
),
(
    'TKT-7824',
    'usr_user_01',
    'Inusa Ibrahim',
    'user',
    'Invoice and Tax Receipt PDF Download Request',
    'Invoicing',
    'low',
    'resolved',
    '[{"sender": "Inusa Ibrahim", "text": "Need company VAT invoice for corporate expense claim.", "timestamp": "2026-09-04T11:20:00Z"}]'::jsonb
),
(
    'TKT-7825',
    'usr_user_01',
    'Inusa Ibrahim',
    'user',
    'Extend Rental Duration by 2 Days',
    'Trip Extension',
    'medium',
    'open',
    '[{"sender": "Inusa Ibrahim", "text": "Would love to extend my Prado booking by 2 additional days if available.", "timestamp": "2026-09-09T10:10:00Z"}]'::jsonb
)
ON CONFLICT (id) DO NOTHING;

-- SEED 3 USER FAVORITES
INSERT INTO public.favorites (user_id, vehicle_id)
VALUES
('usr_user_01', 'car_partner_01'),
('usr_user_01', 'car_partner_02'),
('usr_user_01', 'car_partner_03')
ON CONFLICT DO NOTHING;
