/* trxstsch.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.01.2004 sasco    - убрал today для cashofc
        19.01.2004 nataly   -  вставлена проверка для  смены статуса транзакции для проводок пласт карт
        18.11.2011 lyubov   - при смене статуса снимается акцепт
        02/11/2012 Luiza    - добавила логирование в файл trxstsch

*/


/* trxstsch.p */
/* 7.12.2001 /sasco/ - изменение таблицы cashofc для кассовых транзакций */

{mainhead.i TXCHG}
define var v-jh  like jh.jh.
define var v-sts like jh.sts.
define var v-acc like jl.acc.
def var amt  as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var v-who like jh.who.
def var v-tell like jl.teller.
def var v-party like jh.party.
def var v-whn like jh.whn.
def var v-tim like jh.tim.
def var v-stn as int.
def var v-aax as int.
def var old-sts like jl.sts.

DEFINE VARIABLE v-savstn as int.

define variable v-sub   as character.
define variable v-ref   like joudoc.docnum.
define variable v-cash  as logical.


find sysc where sysc.sysc eq "CASHGL" no-lock .

form v-jh skip
     v-acc amt skip
     with row 7 centered side-label frame sts.

update v-jh with frame sts.
find jh where jh.jh eq v-jh no-error.
if available jh  then do:
     if jh.party = 'BWX'  then do:
     message
       ' Проводка Деп-та Пласт Карт. Для смены статуса проводки см. п.9-16' view-as alert-box.
         leave.
     end.

        v-who   = jh.who.
        v-whn   = jh.whn.
        v-tim   = jh.tim.
        v-party = jh.party.
        v-sts   = jh.sts.
        v-sub   = jh.sub.
        v-ref   = jh.ref.
        old-sts = jh.sts.

        for each jl where jl.jh = jh.jh:
            v-tell = jl.teller.
            if jl.gl eq sysc.inval then
            message "Кассовая транзакция ! " .
            v-cash = true.
        end.
        disp v-who label "ИСПОЛН."
            v-whn label " ДАТА " " "
            string(v-tim,"HH:MM") label "ВРЕМЯ"
            v-party label "ИНФОРМ."
            v-tell label "КОНТРОЛ." skip
            v-sts label "СТАТУС "
             with row 12 centered side-label overlay
             title "Информация о транзакции " frame sstss.
        update v-sts validate(v-sts = 0 or v-sts = 5 or v-sts = 6,"")
            with row 12 overlay frame sstss.

    jh.sts = v-sts.
    run savelog("trxstsch","изменение статуса транзакции " + string(v-jh) + " с " + string(old-sts) + " на " + string(v-sts)  + " ofc: "  + g-ofc).


    for each jl where jl.jh = jh.jh:

        /* 7.12.2001 by sasco */
        if jl.gl = sysc.inval then do:
           if v-sts = 6 and old-sts <> 6 then do: /* загадка, но прибавить */
              find first cashofc where cashofc.ofc = v-tell and
                                       cashofc.whn = g-today and
                                       cashofc.crc = jl.crc and
                                       cashofc.sts = 2
                                       no-error.
              if avail cashofc then
                       cashofc.amt = cashofc.amt + jl.dam - jl.cam.
           end.
           if v-sts <> 6 and old-sts = 6 then do: /* минусовать */
              find first cashofc where cashofc.ofc = v-tell and
                                       cashofc.whn = g-today and
                                       cashofc.crc = jl.crc and
                                       cashofc.sts = 2
                                       no-error.
              if avail cashofc then
                       cashofc.amt = cashofc.amt - jl.dam + jl.cam.
           end.
        end.

        jl.sts = v-sts.
        jl.teller = ''.
    end.

    find cursts where cursts.sub eq v-sub and cursts.acc eq v-ref
                                        use-index subacc no-lock no-error.
    if available cursts then do:
        case v-sts:
            when 0 then do:        run chgsts(v-sub, v-ref, "trx").  end.
            when 5 then do:
                if v-cash then do: run chgsts(v-sub, v-ref, "cas").  end.
                else do:           run chgsts(v-sub, v-ref, "rdy").  end.
            end.
            when 6 then do:        run chgsts(v-sub, v-ref, "rdy").  end.
        end case.
    end.

end.
/*
else do:

  find aah where aah.aah eq v-jh no-error.
  if available aah then do:
        v-who = aah.who.
        v-whn = aah.whn.
        v-tim = aah.tim.
        v-stn = aah.stn.
        v-acc = aah.aaa.
        amt = aah.amt.

        for each aal where aal.aah = aah.aah no-lock break by aal.aax:
            v-tell = aal.teller.
            v-aax = aal.aax.
            find first aax where aax.ln eq aal.aax.
            if available aax then do:
                if aax.cash ne ? then
                message "Кассовая транзакция ! " .
            end.
        end.
        disp v-acc amt with frame sts.
        disp v-who label "ИСПОЛН."
            v-whn label " ДАТА " " "
            string(v-tim,"HH:MM") label "ВРЕМЯ" skip
            v-tell label "КОНТРОЛ."
            v-stn label "СТАТУС "
             with row 12 centered side-label overlay
             title "Информация о транзакции " frame ssstsss.

        v-savstn = v-stn.


        update v-stn when v-stn < 9
        validate(v-stn = 0 or v-stn = 5 or v-stn = 6,"")
            with row 12 overlay frame ssstsss.


**************** Vladislav Levitsky, 24.07.97 *

        aah.stn = v-stn.
        for each aal where aal.aah = aah.aah and aal.stn <> 9
              exclusive-lock:
           if v-savstn = 6 and v-stn <> 6 and aal.aax = 51 and
              aal.fday = 0 then
            do:
               find aaa where aaa.aaa = aal.aaa exclusive-lock.
               aal.fday = 1.
               aaa.cbal = aaa.cbal - aal.amt.
               aaa.fbal[aal.fday] = aaa.fbal[aal.fday] + aal.amt.
            end.
           aal.stn = v-stn.
        end.

**************** Vladislav Levitsky, 24.07.97 *


  end.
  else do:
    bell.
    {mesg.i 0235}.
    undo,leave.
  end.
end.
*/
{mesg.i 0935}.
