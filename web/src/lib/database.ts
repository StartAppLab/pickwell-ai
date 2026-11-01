'use client';

import type {
  PostgrestError,
  PostgrestResponse,
  PostgrestSingleResponse,
  SupabaseClient,
} from '@supabase/supabase-js';
import { createSupabaseBrowserClient } from '@/lib/supabase-client';
import type { Database } from '@/types/database';

const supabase = createSupabaseBrowserClient() as SupabaseClient<
  Database,
  'public'
>;

export interface UserProfile {
  id: string;
  email: string | null;
  first_name: string | null;
  last_name: string | null;
  phone: string | null;
  role: string | null;
  avatar_url: string | null;
}

export interface MenuItem {
  id: string;
  name: string;
  description: string | null;
  price: number;
  is_available: boolean;
  category: string | null;
  created_at: string;
  updated_at: string | null;
}

export interface DashboardMetrics {
  totalItems: number;
  availableItems: number;
  categories: Array<{ category: string; count: number }>;
  averagePrice: number;
  recentItems: MenuItem[];
}

export async function ensureProfile(userId: string, email: string) {
  if (!userId) return;

  const { data, error } = await supabase
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .maybeSingle();

  if (error && error.code !== 'PGRST116') {
    throw error;
  }

  if (!data) {
    const { error: insertError } = await supabase.from('profiles').insert({
      id: userId,
      email,
      first_name: null,
      last_name: null,
      phone: null,
      role: 'member',
      avatar_url: null,
    });

    if (insertError) {
      throw insertError;
    }
  }
}

export async function getUserProfile(userId: string) {
  const result = await supabase
    .from('profiles')
    .select('id, email, first_name, last_name, phone, role, avatar_url')
    .eq('id', userId)
    .single();

  return normalizeResponse(result);
}

export async function updateUserProfile(
  userId: string,
  profile: Partial<UserProfile>
) {
  const payload: Database['public']['Tables']['profiles']['Update'] = {
    updated_at: new Date().toISOString(),
  };

  if (profile.first_name !== undefined) payload.first_name = profile.first_name;
  if (profile.last_name !== undefined) payload.last_name = profile.last_name;
  if (profile.phone !== undefined) payload.phone = profile.phone;
  if (profile.role !== undefined) payload.role = profile.role;
  if (profile.avatar_url !== undefined) payload.avatar_url = profile.avatar_url;

  const result = await supabase
    .from('profiles')
    .update(payload)
    .eq('id', userId)
    .select('id, email, first_name, last_name, phone, role, avatar_url')
    .single();

  return normalizeResponse(result);
}

export async function getMenuItems(search?: string) {
  let query = supabase
    .from('menu_items')
    .select(
      'id, name, description, price, is_available, category, created_at, updated_at'
    )
    .order('created_at', { ascending: false });

  if (search) {
    query = query.ilike('name', `%${search}%`);
  }

  const result = await query;
  return normalizeResponse(result);
}

export async function createMenuItem(
  payload: Omit<MenuItem, 'id' | 'created_at' | 'updated_at'>
) {
  const insertData: Database['public']['Tables']['menu_items']['Insert'] = {
    name: payload.name,
    price: payload.price,
    is_available: payload.is_available,
  };
  if (payload.description !== undefined)
    insertData.description = payload.description;
  if (payload.category !== undefined) insertData.category = payload.category;

  const result = await supabase
    .from('menu_items')
    .insert(insertData)
    .select(
      'id, name, description, price, is_available, category, created_at, updated_at'
    )
    .single();

  return normalizeResponse(result);
}

export async function updateMenuItem(
  id: string,
  payload: Partial<Omit<MenuItem, 'id' | 'created_at' | 'updated_at'>>
) {
  const updateData: Database['public']['Tables']['menu_items']['Update'] = {
    updated_at: new Date().toISOString(),
  };

  if (payload.name !== undefined) updateData.name = payload.name;
  if (payload.price !== undefined) updateData.price = payload.price;
  if (payload.description !== undefined)
    updateData.description = payload.description;
  if (payload.category !== undefined) updateData.category = payload.category;
  if (payload.is_available !== undefined)
    updateData.is_available = payload.is_available;

  const result = await supabase
    .from('menu_items')
    .update(updateData)
    .eq('id', id)
    .select(
      'id, name, description, price, is_available, category, created_at, updated_at'
    )
    .single();

  return normalizeResponse(result);
}

export async function deleteMenuItem(id: string) {
  const { error } = await supabase.from('menu_items').delete().eq('id', id);

  if (error) {
    return { error: error.message };
  }

  return { error: undefined };
}

export async function getDashboardMetrics(): Promise<{
  data?: DashboardMetrics;
  error?: string;
}> {
  const { data, error } = (await supabase
    .from('menu_items')
    .select(
      'id, name, description, price, is_available, category, created_at, updated_at'
    )
    .order('created_at', { ascending: false })) as {
    data: MenuItem[] | null;
    error: PostgrestError | null;
  };

  if (error) {
    return { error: error.message };
  }

  const items = data ?? [];
  const totalItems = items.length;
  const availableItems = items.filter((item) => item.is_available).length;
  const averagePrice =
    totalItems === 0
      ? 0
      : items.reduce((sum, item) => sum + (item.price ?? 0), 0) / totalItems;

  const categoriesMap = new Map<string, number>();
  items.forEach((item) => {
    const key = item.category ?? 'Uncategorized';
    categoriesMap.set(key, (categoriesMap.get(key) ?? 0) + 1);
  });

  const categories = Array.from(categoriesMap.entries()).map(
    ([category, count]) => ({ category, count })
  );

  return {
    data: {
      totalItems,
      availableItems,
      averagePrice,
      categories,
      recentItems: items.slice(0, 5),
    },
  };
}

type PostgrestResult<T> = PostgrestResponse<T> | PostgrestSingleResponse<T>;

function normalizeResponse<T>({ data, error }: PostgrestResult<T>) {
  if (error) {
    return { error: error.message };
  }
  return { data };
}
