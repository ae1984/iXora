/* unistor.p
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
        27.01.2004 sasco  - убрал today для cashofc
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/


/* LAST CHANGE:      13.11.2001   by sasco - change cashofc record */

{global.i}
def var v-jh like jh.jh.
def new shared var s-jh like jh.jh. 
define variable rcode as integer.
define variable rdes  as character.
define variable vcash as logical.
define variable camdam as decimal.
define variable vcrc like crc.crc.
define variable tel like ofc.ofc.
def var sure as log . 
def var v-sts like jh.sts.
repeat:
    displ " Режим удаления / сторнирования транзакций " with centered row 5
    frame sss. 
   repeat : 
    repeat:
     update v-jh label "Транзакция" with centered side-label frame vvv . 
     leave . 
    end.
    if keyfunction(lastkey) = "End-error" then return . 
    sure = false.
    find jh where jh.jh eq v-jh no-lock no-error.
    find first jl where jl.jh = jh.jh no-error . 
    if avail jl and avail jh then do:
     if jh.sub = "rmz" 
      then message "Транзакция платежной системы удаляется в 31 процессе .".
      else 
      if jh.sub = "jou"
      then message "Транзакция журнала операций удаляется в журнале операций.".
       else
      if jh.sub = "ujo"
      then message 
      "Транзакция универсального журнала удаляется в универсальном журнале .".
      else 
      if jh.sub = "lon"
      then message
     "Транзакция кредитного модуля  удаляется в кредитном модуле .".
     else 
     leave . 
    end.  else 
    message " Транзакция не найдена " . 
   end.


   do transaction on error undo, retry:
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?",
                jh.jdt) update sure.
                if not sure then undo, return.
            
            run trxstor(input v-jh, input 6,
                output s-jh, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.

            run x-jlvo.
        end.
        else do:
            message "Вы уверены ?" update sure.
                if not sure then undo, return.

/*--- checking cash, by sasco ---*/
            find sysc where sysc.sysc = 'CASHGL' no-lock.
            for each jl where jl.jh = v-jh:
                    if jl.gl = sysc.inval and jl.sts = 6 then
                    do:
                        /*---- changing CASHOFC record, by sasco ---- */
                         find first cashofc where 
                               cashofc.whn eq g-today   /* today with...*/
                           and cashofc.crc eq jl.crc /* ...currency */
                           and cashofc.sts eq 2 and /* ...of current status */
                               cashofc.ofc eq jl.teller /*...by officer... */
                               no-error.
                         if avail cashofc then
                         cashofc.amt = cashofc.amt - jl.dam + jl.cam.
                         else do: /* загадка, но создать запись */
                               create cashofc.
                               cashofc.who = g-ofc.
                               cashofc.ofc = g-ofc.
                               cashofc.whn = g-today.
                               cashofc.crc = jl.crc.
                               cashofc.sts = 2.
                               cashofc.amt = jl.cam - jl.dam.
                         end.
                    end.
            end.
            
            v-sts = jh.sts.
            
            run trxsts (input v-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
            run trxdel (input v-jh, input true, output rcode, output rdes). 
                if rcode ne 0 then do:
                    message rdes.
                    if rcode = 50 then do:
                                       run trxsts (input v-jh, input v-sts, output rcode, output rdes).
                                       return.
                                  end.     
                    else undo, return.
                end.
        end.

        run comm-dt(string(v-jh)).
    end. 
end. 
