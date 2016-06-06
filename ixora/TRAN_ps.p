/* TRAN_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Автоматическое создание перевода в Алм.фил. из ЦО со счета клиента на сумму остатка на счете
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10/08/2010 galina
 * BASES
        BANK
 * CHANGES
*/

{global.i}
{lgps.i "new"}
m_pid = "TRAN".

def var v-rmz as char.
if time >= 68400 then do:
    for each transfer no-lock:
        find first aaa where aaa.aaa = transfer.aaafrom no-lock no-error.
        if not avail aaa then next.
        if aaa.sta = 'C' then next.
        if aaa.cbal - aaa.hbal <= 0 then next.
        run rmzcre (1,
                    aaa.cbal - aaa.hbal,
                    aaa.aaa,
                    transfer.rnnfrom,
                    transfer.clnamefrom,
                    'TXB16',
                    transfer.aaato,
                    transfer.clnameto,
                    transfer.rnnto,
                    '0',
                     no,
                    '321',
                    transfer.kod,
                    transfer.kbe,
                    'Перевод собственных средств',
                    '1P',
                    0,
                    5,
                    g-today) .

        v-rmz = return-value.
        find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
        if avail remtrz then do:
            remtrz.source = 'P'.
            remtrz.ordins[1] = " ".
            remtrz.ordins[2] = " ".
            remtrz.valdt1 = g-today.
            remtrz.valdt2 = g-today.
         end.

         v-text = " Создан платеж " + v-rmz.
         run lgps.
    end.


    find first dproc where dproc.pid = m_pid no-lock no-error.
       if avail dproc then do:
          v-text = " Процесс TRAN завершил свою работу. Начинается останов процесса... ".
          run lgps.
          find current dproc exclusive-lock no-error.
          dproc.tout = 1000.
       end.
end.