-- CajaMaster: cierre transaccional y validado en el servidor.
-- Ejecutar en Supabase Dashboard > SQL Editor del proyecto correcto.

create or replace function public.close_cash_session(
  p_session_id uuid,
  p_counted_cash numeric
)
returns public.caja_sessions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_session public.caja_sessions%rowtype;
  v_expected numeric(12,2);
  v_counted numeric(12,2);
  v_difference numeric(12,2);
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión para cerrar la caja.';
  end if;

  if p_counted_cash is null or p_counted_cash < 0 then
    raise exception 'El efectivo contado debe ser un importe no negativo.';
  end if;

  select s.*
    into v_session
    from public.caja_sessions as s
   where s.id = p_session_id
     and s.opened_by = auth.uid()
     and s.status = 'open'
   for update;

  if not found then
    raise exception 'No se encontró una caja abierta de tu propiedad.';
  end if;

  select round(
    v_session.opening_fund + coalesce(sum(
      case
        when m.movement_type = 'sale' and m.payment_method = 'cash' then m.amount
        when m.movement_type = 'expense' and m.payment_method = 'cash' then -m.amount
        else 0::numeric
      end
    ), 0),
    2
  )
    into v_expected
    from public.caja_movements as m
   where m.session_id = p_session_id;

  v_counted := round(p_counted_cash, 2);
  v_difference := round(v_counted - v_expected, 2);

  update public.caja_sessions
     set status = 'closed',
         closed_at = now(),
         expected_cash = v_expected,
         counted_cash = v_counted,
         difference = v_difference
   where id = p_session_id
   returning * into v_session;

  return v_session;
end;
$$;

revoke all on function public.close_cash_session(uuid, numeric) from public;
revoke all on function public.close_cash_session(uuid, numeric) from anon;
grant execute on function public.close_cash_session(uuid, numeric) to authenticated;
