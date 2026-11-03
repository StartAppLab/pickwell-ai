-- Allow an operator to configure repeated-label testing without disabling
-- admission, accounting or same-request idempotency. Defaults stay unchanged.
alter table public.quota_controls
 drop constraint quota_controls_barcode_calls_daily_check,
 add constraint quota_controls_barcode_calls_daily_check
 check (barcode_calls_daily between 1 and 1000);
