-- T07.1: schedule the existing tested retention/reconciliation functions.
-- The operator enables pg_cron on hosted Supabase; isolated native/PGlite
-- environments need not install a scheduler to apply the application schema.
do $$
begin
 if exists(select 1 from pg_extension where extname='pg_cron') then
  perform cron.schedule('pickwell-private-maintenance','*/5 * * * *',
   'select public.pickwell_prune_analysis(); select public.pickwell_reconcile_expired();');
  perform cron.schedule('pickwell-telemetry-retention','17 0 * * *',
   $command$select public.pickwell_prune_telemetry();
    delete from cron.job_run_details where end_time<now()-interval '7 days'
     and jobid in (select jobid from cron.job where jobname in
      ('pickwell-private-maintenance','pickwell-telemetry-retention'));$command$);
 else
  raise notice 'Pickwell scheduler not installed; hosted operator must enable pg_cron and register maintenance jobs before release';
 end if;
end $$;
