// Isolated PostgreSQL engine checks; the installed pgTAP suite also runs on Supabase.
import { PGlite } from "npm:@electric-sql/pglite@0.3.14";

const alice = "10000000-0000-0000-0000-000000000001";
const bob = "20000000-0000-0000-0000-000000000002";
function assert(value: unknown): asserts value {
  if (!value) throw new Error("Assertion failed");
}
Deno.test("SQL module enforces ownership, validity, leases and atomic revocation", async () => {
  const db = new PGlite();
  try {
    await db.exec(
      `create role anon; create role authenticated; create role service_role bypassrls;
      create schema auth;
      create table auth.users(id uuid primary key);
      create function auth.uid() returns uuid language sql stable as
        $$select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid$$;
      create function auth.jwt() returns jsonb language sql stable as
        $$select jsonb_build_object('is_anonymous', coalesce(nullif(current_setting('request.jwt.claim.is_anonymous', true), ''), 'false')::boolean)$$;
      grant usage on schema auth to authenticated, anon;
      grant execute on function auth.uid(), auth.jwt() to authenticated, anon;
      insert into auth.users values ('${alice}'), ('${bob}');`,
    );
    await db.exec(
      await Deno.readTextFile(
        new URL("../migrations/subscription_entitlements.sql", import.meta.url),
      ),
    );
    const scalar = async (sql: string) =>
      (await db.query<{ value: unknown }>(sql)).rows[0].value;
    const claim = async (user: string, interval = 0) =>
      await scalar(
        `select public.claim_entitlement_sync('${user}', ${interval}) as value`,
      );
    const token = await claim(alice);
    assert(typeof token === "string");
    assert(await claim(alice) === null);
    assert(
      await scalar(
        `select public.apply_entitlement_snapshot('${alice}', gen_random_uuid(), 'PRODUCTION', '[]') as value`,
      ) === false,
    );
    const grants = [{
      entitlement_id: "premium",
      product_id: "lifetime",
      is_active: true,
      is_non_expiring: true,
      expires_at: null,
    }];
    assert(
      await scalar(
        `select public.apply_entitlement_snapshot('${alice}', '${token}', 'PRODUCTION', '${
          JSON.stringify(grants)
        }') as value`,
      ) === true,
    );
    assert(await claim(alice, 30) === null);
    const ownRole = async () => {
      await db.exec(
        `set role authenticated; select set_config('request.jwt.claim.sub', '${alice}', false)`,
      );
    };
    const denied = async (sql: string) => {
      let code;
      try {
        await db.exec(sql);
      } catch (error) {
        code = (error as { code: string }).code;
      }
      assert(code === "42501");
    };
    await ownRole();
    assert(
      await scalar("select public.has_entitlement('premium') as value") ===
        true,
    );
    await db.exec(
      "select set_config('request.jwt.claim.is_anonymous', 'true', false)",
    );
    assert(
      await scalar("select public.has_entitlement('premium') as value") ===
        false,
    );
    await db.exec(
      "select set_config('request.jwt.claim.is_anonymous', 'false', false)",
    );
    await denied("update public.user_entitlements set is_active = true");
    await denied("delete from public.user_entitlements");
    await denied(
      `insert into public.user_entitlements(user_id) values ('${alice}')`,
    );
    await denied(`select public.claim_entitlement_sync('${alice}', 0)`);
    await denied("select * from public.entitlement_sync_leases");
    await db.exec("reset role");
    await db.exec(
      `insert into public.user_entitlements(user_id, entitlement_id, environment, product_id, is_active, is_non_expiring, verified_until)
      values ('${bob}', 'other', 'PRODUCTION', 'lifetime', true, true, now() + interval '1 hour')`,
    );
    await ownRole();
    assert(
      await scalar("select count(*) as value from public.user_entitlements") ===
        1,
    );
    assert(
      await scalar("select public.has_entitlement('other') as value") === false,
    );
    await db.exec("reset role");
    await db.exec(
      `update public.user_entitlements set verified_until = now() - interval '1 second' where user_id = '${alice}'`,
    );
    await ownRole();
    assert(
      await scalar("select public.has_entitlement('premium') as value") ===
        false,
    );
    await db.exec("reset role");
    const second = await claim(alice);
    assert(
      await scalar(
        `select public.apply_entitlement_snapshot('${alice}', '${second}', 'PRODUCTION', '[]') as value`,
      ) === true,
    );
    assert(
      await scalar(
        `select count(*) as value from public.user_entitlements where user_id = '${alice}'`,
      ) === 0,
    );
    const third = await claim(alice);
    await db.exec(
      `update public.entitlement_sync_leases set lease_until = now() - interval '1 second' where user_id = '${alice}'`,
    );
    const fourth = await claim(alice);
    assert(third !== fourth);
    assert(
      await scalar(
        `select public.apply_entitlement_snapshot('${alice}', '${third}', 'PRODUCTION', '${
          JSON.stringify(grants)
        }') as value`,
      ) === false,
    );
    await db.exec("set role anon");
    await denied("select public.has_entitlement('premium')");
    await db.exec(`reset role; delete from auth.users where id = '${bob}'`);
    assert(
      await scalar(
        `select count(*) as value from public.user_entitlements where user_id = '${bob}'`,
      ) === 0,
    );
  } finally {
    await db.close();
  }
});
