-- =====================================================
-- 美妆穿搭顾问 APP - Supabase 数据库表结构
-- =====================================================

-- 1. 用户档案表
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id TEXT PRIMARY KEY,
  nickname TEXT,
  avatar_url TEXT,
  face_shape TEXT,
  age INTEGER,
  gender TEXT,
  city TEXT,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 衣橱物品表
CREATE TABLE IF NOT EXISTS wardrobe (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  category TEXT NOT NULL,
  name TEXT NOT NULL,
  image_url TEXT,
  local_image_path TEXT,
  color TEXT,
  style TEXT,
  season TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建衣橱表索引
CREATE INDEX IF NOT EXISTS idx_wardrobe_user_id ON wardrobe(user_id);
CREATE INDEX IF NOT EXISTS idx_wardrobe_category ON wardrobe(category);

-- 3. 推荐记录表
CREATE TABLE IF NOT EXISTS recommendations (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  content TEXT NOT NULL,
  project_url TEXT,
  face_shape TEXT,
  weather_condition TEXT,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- 创建推荐表索引
CREATE INDEX IF NOT EXISTS idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_type ON recommendations(type);
CREATE INDEX IF NOT EXISTS idx_recommendations_favorite ON recommendations(is_favorite);

-- =====================================================
-- 存储桶 (Storage Buckets)
-- =====================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('wardrobe-images', 'wardrobe-images', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- Row Level Security (RLS) 策略
-- =====================================================

-- 启用 RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE wardrobe ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;

-- 用户档案 RLS
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
CREATE POLICY "Users can view their own profile" ON user_profiles FOR SELECT USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
CREATE POLICY "Users can insert their own profile" ON user_profiles FOR INSERT WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
CREATE POLICY "Users can update their own profile" ON user_profiles FOR UPDATE USING (user_id = auth.uid()::text);

-- 衣橱 RLS
DROP POLICY IF EXISTS "Users can view their own wardrobe" ON wardrobe;
CREATE POLICY "Users can view their own wardrobe" ON wardrobe FOR SELECT USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can insert their own wardrobe items" ON wardrobe;
CREATE POLICY "Users can insert their own wardrobe items" ON wardrobe FOR INSERT WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own wardrobe items" ON wardrobe;
CREATE POLICY "Users can update their own wardrobe items" ON wardrobe FOR UPDATE USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can delete their own wardrobe items" ON wardrobe;
CREATE POLICY "Users can delete their own wardrobe items" ON wardrobe FOR DELETE USING (user_id = auth.uid()::text);

-- 推荐 RLS
DROP POLICY IF EXISTS "Users can view their own recommendations" ON recommendations;
CREATE POLICY "Users can view their own recommendations" ON recommendations FOR SELECT USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can insert their own recommendations" ON recommendations;
CREATE POLICY "Users can insert their own recommendations" ON recommendations FOR INSERT WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can update their own recommendations" ON recommendations;
CREATE POLICY "Users can update their own recommendations" ON recommendations FOR UPDATE USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Users can delete their own recommendations" ON recommendations;
CREATE POLICY "Users can delete their own recommendations" ON recommendations FOR DELETE USING (user_id = auth.uid()::text);

-- 存储桶策略
DROP POLICY IF EXISTS "Allow public read access to wardrobe images" ON storage.objects;
CREATE POLICY "Allow public read access to wardrobe images" ON storage.objects FOR SELECT USING (bucket_id = 'wardrobe-images');

DROP POLICY IF EXISTS "Allow authenticated users to upload wardrobe images" ON storage.objects;
CREATE POLICY "Allow authenticated users to upload wardrobe images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'wardrobe-images');

DROP POLICY IF EXISTS "Allow users to update their own wardrobe images" ON storage.objects;
CREATE POLICY "Allow users to update their own wardrobe images" ON storage.objects FOR UPDATE USING (bucket_id = 'wardrobe-images');

DROP POLICY IF EXISTS "Allow users to delete their own wardrobe images" ON storage.objects;
CREATE POLICY "Allow users to delete their own wardrobe images" ON storage.objects FOR DELETE USING (bucket_id = 'wardrobe-images');
