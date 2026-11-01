export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string | null;
          first_name: string | null;
          last_name: string | null;
          phone: string | null;
          role: string | null;
          avatar_url: string | null;
          created_at: string | null;
          updated_at: string | null;
          default_org_id: string | null;
        };
        Insert: {
          id: string;
          email?: string | null;
          first_name?: string | null;
          last_name?: string | null;
          phone?: string | null;
          role?: string | null;
          avatar_url?: string | null;
          created_at?: string | null;
          updated_at?: string | null;
          default_org_id?: string | null;
        };
        Update: {
          email?: string | null;
          first_name?: string | null;
          last_name?: string | null;
          phone?: string | null;
          role?: string | null;
          avatar_url?: string | null;
          updated_at?: string | null;
          default_org_id?: string | null;
        };
        Relationships: [];
      };
      organizations: {
        Row: {
          id: string;
          name: string;
          slug: string | null;
          owner_id: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          slug?: string | null;
          owner_id: string;
          created_at?: string;
        };
        Update: {
          name?: string;
          slug?: string | null;
        };
        Relationships: [];
      };
      organization_members: {
        Row: {
          org_id: string;
          user_id: string;
          role: 'owner' | 'admin' | 'member';
          created_at: string;
        };
        Insert: {
          org_id: string;
          user_id: string;
          role?: 'owner' | 'admin' | 'member';
          created_at?: string;
        };
        Update: {
          role?: 'owner' | 'admin' | 'member';
        };
        Relationships: [];
      };
      billing_customers: {
        Row: {
          id: string;
          org_id: string | null;
          provider: string | null;
          external_id: string | null;
          plan: string | null;
          status: string | null;
          current_period_end: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          org_id?: string | null;
          provider?: string | null;
          external_id?: string | null;
          plan?: string | null;
          status?: string | null;
          current_period_end?: string | null;
          created_at?: string;
        };
        Update: {
          org_id?: string | null;
          provider?: string | null;
          external_id?: string | null;
          plan?: string | null;
          status?: string | null;
          current_period_end?: string | null;
        };
        Relationships: [];
      };
      usage_counters: {
        Row: {
          id: string;
          org_id: string;
          key: string;
          count: number;
          window_start: string;
          window_end: string;
        };
        Insert: {
          id?: string;
          org_id: string;
          key: string;
          count?: number;
          window_start: string;
          window_end: string;
        };
        Update: {
          count?: number;
        };
        Relationships: [];
      };
      credits_wallets: {
        Row: {
          org_id: string;
          credits: number;
          refreshed_at: string;
        };
        Insert: {
          org_id: string;
          credits?: number;
          refreshed_at?: string;
        };
        Update: {
          credits?: number;
          refreshed_at?: string;
        };
        Relationships: [];
      };
      billing_events_raw: {
        Row: {
          id: string;
          org_id: string | null;
          provider: string | null;
          external_id: string | null;
          payload: Record<string, unknown> | null;
          received_at: string;
        };
        Insert: {
          id?: string;
          org_id?: string | null;
          provider?: string | null;
          external_id?: string | null;
          payload?: Record<string, unknown> | null;
          received_at?: string;
        };
        Update: {
          org_id?: string | null;
          provider?: string | null;
          external_id?: string | null;
          payload?: Record<string, unknown> | null;
        };
        Relationships: [];
      };
      audit_logs: {
        Row: {
          id: string;
          org_id: string | null;
          user_id: string | null;
          action: string;
          meta: Record<string, unknown> | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          org_id?: string | null;
          user_id?: string | null;
          action: string;
          meta?: Record<string, unknown> | null;
          created_at?: string;
        };
        Update: {
          org_id?: string | null;
          user_id?: string | null;
          action?: string;
          meta?: Record<string, unknown> | null;
        };
        Relationships: [];
      };
      feature_flags: {
        Row: {
          id: string;
          key: string;
          enabled: boolean;
          rollout: Record<string, unknown>;
          created_at: string;
        };
        Insert: {
          id?: string;
          key: string;
          enabled?: boolean;
          rollout?: Record<string, unknown>;
          created_at?: string;
        };
        Update: {
          enabled?: boolean;
          rollout?: Record<string, unknown>;
        };
        Relationships: [];
      };
      menu_items: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          price: number;
          is_available: boolean;
          category: string | null;
          created_at: string;
          updated_at: string | null;
        };
        Insert: {
          id?: string;
          name: string;
          description?: string | null;
          price: number;
          is_available?: boolean;
          category?: string | null;
          created_at?: string;
          updated_at?: string | null;
        };
        Update: {
          name?: string;
          description?: string | null;
          price?: number;
          is_available?: boolean;
          category?: string | null;
          updated_at?: string | null;
        };
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: {
      is_org_member: {
        Args: { org: string };
        Returns: boolean;
      };
      list_memberships_for_user: {
        Args: { member: string };
        Returns: Database['public']['Tables']['organization_members']['Row'][];
      };
    };
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
