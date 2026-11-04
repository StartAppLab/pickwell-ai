import {createProductThumbnailHandler} from '../_shared/product_thumbnail.mjs';
Deno.serve(createProductThumbnailHandler({SUPABASE_URL:Deno.env.get('SUPABASE_URL'),SUPABASE_SERVICE_ROLE_KEY:Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}));
