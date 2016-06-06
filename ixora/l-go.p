/* l-go.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Акцепт внешнего входящего платежа на очереди 2L
 * RUN
        верхнее меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-9-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08.10.2003 nadejda  - удаление специнструкции, наложенной на счет клиента при второй проводке внешнего входящего валютного платежа
*/

{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "да/нет".
def var ok as log .

Message " Вы уверены ? " update yn .
do transaction:

  find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

  find jh where jh.jh = remtrz.jh2 no-error.
  if not available jh then do:
    Message " 2TRX doesn't exist !!! " . pause.
    return.
  end.

  find que of remtrz NO-LOCK no-error.
  if not available que or que.pid ne '2l' then do:
    Message " Платеж находится не в очереди 2L  !!! " . pause.
    return.
  end.

  if jh.sts < 5 then do :
    Message " Сначала распечатайте !!! " . pause.
    return.
  end.

  if yn then do  :
    find first que where que.remtrz = s-remtrz exclusive-lock no-error .
    if avail que then do :

      /* 07.10.2003 nadejda - снять специнструкцию по второй проводке, наложенную валютным контролем - если найдется :-) */
      if remtrz.tcrc <> 1 then do:
        find first jl where jl.jh = remtrz.jh2 and jl.sub = "cif" and jl.dc = "c" no-lock no-error.
        if avail jl then run jou-aasdel (jl.acc, remtrz.amt, remtrz.jh2).
      end.
      /******************************/

      /* que.pid = m_pid. by Alex */ 
      if jh.sts = 6 then que.rcod = "0" .
                    else que.rcod = "1" .
      v-text = " Отправлен платеж " + remtrz.remtrz + " по маршруту , rcod = " + que.rcod.
      run lgps.
      que.con = "F".
      que.dp = today.
      que.tp = time.

      release que .
      release remtrz.
    end.
  end .

end.
