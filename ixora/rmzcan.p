/* rmzcan.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Удаление/сторнирование 1 и 2-ой проводки внешнего платежа
 * RUN
        верхнее меню в пунктах платежной системы
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-...
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        08.10.2003 nadejda  - удаление специнструкции, наложенной на счет клиента при второй проводке внешнего входящего валютного платежа
        09.10.2003 nadejda  - если вторая проводка была блокировкой суммы на транзитном счете валютного контроля, то удаление записи в списке блокированных сумм
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        16.05.2005 saltanat - Добавила в поверку ---if remtrz.jh1 eq ? след:   --- and remtrz.jh2 eq ?--- 
                              Поменяла местами удаление проводок. Сперва удаляем вторую, а затем первую.
        31/07/2007 madiyar - убрал упоминание удаленной таблицы sta
*/

/* caremin.p */

{global.i}
{lgps.i}
{ps-prmt.i}
def var p1 as log format "Да/Нет". def var p2 as log format "Да/Нет". 
define shared var s-remtrz like remtrz.remtrz.
def shared frame remtrz.
def new shared var s-sta as char format "x(2)" label "State".
def new shared var s-rem like rem.rem.
def new shared var s-ref like rem.ref.


define new shared var s-jh like jh.jh.
define new shared var s-consol like jh.consol init false.
define new shared var s-aah as int.
define new shared var s-line as int.
define new shared var s-force as log init true format "Да/Нет".
define new shared var jh5 like remtrz.jh1.
define new shared var vjh5 like remtrz.jh2.
def new shared var rem5 like rem.rem.

def var cans as log format "Да/Нет".
def buffer b-jh for jh.
def buffer b-jl for jl.
def var djh like jh.jh.
def var dvjh like jh.jh.
def var v-jhdel as log format "Да/Нет".
def buffer tgl for gl.
def var acode like crc.code.
def var bcode like crc.code.

def var rcode as int.
def var rdes as cha .
define variable v-sts like jh.sts .

djh = ?.
dvjh = ?.

def var ourbank as char.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
  display "Отсутствует запись OURBNK в таблице SYSC!".
  pause .
  undo .
  return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "CASHGL" no-lock.

{rmz.f}

do transaction :

 find remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
  if remtrz.jh1 ne ? then do:
   jh5 = remtrz.jh1.  
   find jh where jh.jh eq remtrz.jh1 no-error.
   if not available jh then remtrz.jh1 = ?.
   else 
 do:
   p1 = false  . p2 = no . 
   for each jl of jh no-lock :
    if jl.gl eq sysc.inval then do: p1 = true .  end . 
    if jl.sts eq 6 then do: p2 = true .  end .
   end .           
   if p1 and  p2 then  do:
     message "Проводка уже акцептована кассиром!"  
      chr(7) chr(7) chr(7).
     pause .
     return.
    end.
   rem5 = substr(jh.party,1,10) .
  end. 
 end.

 if remtrz.jh2 ne ? then do:
  vjh5 = remtrz.jh2.  
  find jh where jh.jh eq remtrz.jh2 no-error.
  if not available jh then remtrz.jh2 = ?.
 end.
 else 
 do:
  find first rem where rem.rem = rem5 exclusive-lock no-error . 
  if avail rem then remtrz.jh2 = rem.vjh . 
 end.


              if remtrz.jh1 eq ? and remtrz.jh2 eq ?
                then do:
                     bell.
                     {mesg.i 0214}.
                     pause 3.
                     undo, retry.
              end.
              {mesg.i 0823} update cans.
              if not cans then undo.

       if remtrz.jh2 ne ? then do: /* Begin of trx 2 delete */
              find jh where jh.jh eq remtrz.jh2 no-error.
              s-jh = remtrz.jh2.

      /* 07.10.2003 nadejda - снять специнструкцию по второй проводке, наложенную валютным контролем - если найдется :-) */
      if remtrz.tcrc <> 1 then do:
        find first jl where jl.jh = remtrz.jh2 and jl.sub = "cif" and jl.dc = "c" no-lock no-error.
        if avail jl then run jou-aasdel (jl.acc, remtrz.amt, remtrz.jh2).
        else do:
          /* если это была блокировка на транзитном счете - удалить запись из таблицы блокированных сумм */
          find first jl where jl.jh = remtrz.jh2 and jl.sub = "arp" and jl.dc = "c" no-lock no-error.
          if avail jl then run rmzcan-vcblk (remtrz.remtrz).
        end.
      end.
      /*********************************************/

              if jh.post eq true
                then do:
   dvjh = ? .
   run trxstor(input s-jh, input 6, output dvjh, output rcode, output rdes).
   if rcode ne 0 then do:
                       message rdes.
                       pause .
                       undo, return .
                      end.
                    remtrz.jh2 = ?.
  v-text = "2 проводка " + string(s-jh) + " сторнирована для " + 
  s-remtrz + " пров." + string(dvjh).
  run lgps.
              end.
              else do:
            find jh where jh.jh = s-jh no-error.
            if avail jh then v-sts = jh.sts.
            else v-sts = 0.
            
            run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                         message rdes.
                         undo, retry .
                end.
            run trxdel (input s-jh, input true, output rcode, output rdes). 
                if rcode ne 0 then do:
                         message rdes.
                         if rcode = 50 then do:
                                            run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                                            return.
                                       end.     
                         else undo, retry.
                end.
                   remtrz.jh2 = ?.
                   remtrz.rwho = userid('bank').

                   remtrz.rtim = time.
      v-text = "Удалена 2 проводка для " + s-remtrz .
      run lgps.
              end.
           end. /* End of trx 2 delete */

          
     if remtrz.jh1 ne ? then do:    /* Begin of trx 1 delete */ 
              find jh where jh.jh eq remtrz.jh1 no-error.
              rem5 = substr(jh.party,1,10) . 
              s-jh = remtrz.jh1.
              if jh.post eq true
                then do:
   djh = ? .
   run trxstor(input s-jh, input 6, output djh, output rcode, output rdes).
        if rcode ne 0 then do:
               message rdes.
               pause . 
               undo, return .
        end.
                    
          if remtrz.jh1 eq remtrz.jh2 then remtrz.jh2 = ?.
          remtrz.jh1 = ?.
        v-text = "1 проводка " + string(s-jh) + " сторнирована для " 
        + s-remtrz + " пров." + string(djh).
       run lgps.
              end.
              else do:
            find jh where jh.jh = s-jh no-error.
            if avail jh then v-sts = jh.sts.
            else v-sts = 0.
            
            run trxsts (input s-jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                            message rdes.
                            undo, return .
                end.
            run trxdel (input s-jh, input true, output rcode, output rdes). 
                if rcode ne 0 then do:
                          message rdes.
                          if rcode = 50 then do:
                                             run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                                             return.
                                        end.     
                          else undo, return.
                end.
                   remtrz.jh1 = ?.
                   remtrz.info[10] = "" . 
                   remtrz.rwho = userid('bank').
                   remtrz.rtim = time.
  
  v-text = "Удалена 1 проводка для " + s-remtrz .            
  run lgps.
       end.
  end. /* End of trx 1 delete. */

     display remtrz.jh1 remtrz.jh2 with frame remtrz.
     pause 0 . 
     find first rem where rem.rem = rem5 exclusive-lock no-error . 
     if avail rem then do:
       find first cursta where substr(cursta.ref,1,22) = substr(rem.ref,1,22) 
            exclusive-lock no-error.        
       if avail cursta then do :
           s-sta = "09".
           s-ref = cursta.ref.
           s-rem = rem.rem.
           run csin.
       end.
       run delecon.
       delete rem . 
       v-text = rem5 + " delete was done for " + s-remtrz .
       run lgps. 
     end .
 end.
 pause 0 .
do trans .
 if djh ne ? then do:
  s-jh = djh .
  run x-jlvou.
  for each jl where jl.jh = djh exclusive-lock .
   jl.sts = 6.
  end .
  jh.sts = 6 . 
 end.
 if dvjh ne ? then do:
  s-jh = dvjh.
  run x-jlvou.
  for each jl where jl.jh = dvjh exclusive-lock .
     jl.sts = 6.
  end .
  jh.sts = 6 .
 end.
end . 
Message "Проводка аннулирована!" . pause.


