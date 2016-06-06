/* comm-com.p
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
        12/10/04 kanat - добавил отдельное зачисление по ИВЦ - которое идет за вычетом налоговых платежей	
        13/10/04 kanat - перекомпиляция 
        15/10/04 kanat - поменял окруление по суммам
        21/10/04 kanat - переделал запрос по вычету налоговых сумм с процентов (убрал kodd <> ? ) и для платежей не ИВЦ
        25/02/05 kanat - добавил снятие комиссий за перечисление процентов для прочих платежей
        06/04/06   marinav проставление кодов доходов и департаментов в проводке
        11.08.2006 u00124 - добавил зачисление процентов по прочим платежам
        16.08.2006 u00124 - Запрет на зачисление комиссии по прочим платежам Алматытелеком.
*/

{comm-txb.i}
{get-dep.i}
def var seltxb as int                     .
def var v-taxsum as decimal               .
def var v-temp-sum as decimal             .
def var v-sumprc as decimal               .
def buffer temp-commonls for commonls.
def var v-gl-f as char                    no-undo.
def var v-gl-u as char                    no-undo.
def var v-depd as char                    no-undo.
def var v-dox as char                     no-undo. 
def var v-dep  as char                    no-undo.

seltxb = comm-cod().

{comm-arp.i} /* Проверка остатка на АРП c заданной суммой */
{comm-chk.i} /* Проверка незачисленных платежей на АРП по счету за дату */
{comm-com.i}

define input parameter ctype as int.
             /* ctype =  1 : %% организации     */
             /*       = 10 : 10 тенге для банка */

define temp-table tcommpl no-undo like commonpl
    field depd as char      
    field v-gl as char      
    field rid as rowid.

define temp-table tcom no-undo 
            field depd as char      
            field v-gl as char      
            field comdoc as int.

def shared var g-today as date.
def var dat as date.
def var tsum as decimal.
def new shared var s-jh like jh.jh.
def var summa as decimal.

def buffer b-syscarp for sysc.
find last b-syscarp where b-syscarp.sysc = "ATARP" no-lock no-error.

dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .

find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then assign v-gl-u = entry(1, sysc.chval) v-gl-f = entry(2, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.

{comm-sel.i}

if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and 
           commonls.visible = yes no-lock no-error.

if comm-chk(selarp,dat) then return.

if ctype = 1 then do:
/*if selbn <> "АлматыТелеком Прочие" then do:*/
if selarp <> b-syscarp.chval then do:
     for each commonpl where commonpl.txb = seltxb and
                             commonpl.date = dat and commonpl.joudoc <> ? and
                             commonpl.prcdoc = ? and commonpl.arp = selarp and
                             commonpl.grp = selgrp and commonpl.deluid = ?
                             no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
         tcommpl.rid = rowid(commonpl).
     end.
end.
else do:
     for each commtk where commtk.txb = seltxb and
                             commtk.date = dat and commtk.joudoc <> ? and
                             commtk.prcdoc = ? and commtk.arp = selarp and
                             commtk.grp = selgrp and commtk.deluid = ?
                             no-lock:
         create tcommpl.
         buffer-copy commtk to tcommpl.
         tcommpl.rid = rowid(commtk).
     end.
end.
end.
 else
if selarp <> b-syscarp.chval then do:
     for each commonpl where commonpl.txb = seltxb and
                             commonpl.date = dat and commonpl.joudoc <> ? and
                             commonpl.comdoc = ? and commonpl.arp = selarp and
                             commonpl.grp = selgrp and commonpl.deluid = ?
                             no-lock:
         v-dep = string(get-dep(commonpl.uid, dat)).
         run get-profit (input commonpl.uid, input v-dep, output v-depd).
         if v-depd = '' then v-depd = '227'.
         create tcommpl.
         buffer-copy commonpl to tcommpl.
         tcommpl.depd = v-depd.
         tcommpl.rid = rowid(commonpl).
         if trim(commonpl.rnn) = '' then tcommpl.v-gl = v-gl-f.   
                                    else
         if substring(commonpl.rnn,5,1) = '0' then tcommpl.v-gl = v-gl-u.
                                              else tcommpl.v-gl = v-gl-f.   
     end.
end.
if selgrp = 9 then do:
for each tcommpl no-lock:
find first temp-commonls where temp-commonls.txb = seltxb and 
                               temp-commonls.grp = selgrp and 
                               temp-commonls.arp = selarp and 
                               temp-commonls.type = tcommpl.type and 
                               temp-commonls.comprc <> 0 no-lock no-error.          
    if avail temp-commonls then
    v-sumprc = v-sumprc + truncate(tcommpl.sum * temp-commonls.comprc, 2).
    accumulate tcommpl.comsum(total).
end.
end.
else do:
for each tcommpl:
    accumulate tcommpl.sum(total).
    accumulate tcommpl.comsum(total).
end.
end.

if ctype = 1 then
   do:
      /* ком. - проценты */
      summa = accum total tcommpl.sum.

      if selarp <> "000904883" then do:
         if selgrp = 9 then do:
            summa = v-sumprc.
            v-temp-sum = summa.
         end.
         else do:
            summa = truncate(summa * selprc, 2).
            v-temp-sum = summa.
         end.
      end.
      else do:
          for each ivcimp where ivcimp.dat = dat and trim(ivcimp.kodd) <> '' and ivcimp.ref <> ? no-lock.
             v-taxsum = v-taxsum + ivcimp.sump.  		
          end.
          v-temp-sum = summa.
          summa = truncate((summa - v-taxsum) * selprc, 2).
      end.

   end.
   else
      /* ком. 10 тенге */
      summa = accum total tcommpl.COMsum.

if (ctype = 1 and v-temp-sum = 0) or (ctype = 10 and summa = 0) then do:
/*
if summa = 0 then do:
*/
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

MESSAGE "Сформировать транзакц. на сумму " summa " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи" UPDATE choice4 as logical.

    case choice4:
       when false then return.
    end.        

    choice4 = false.

    REPEAT WHILE (not comm-arp(selarp,summa)) or choice4 <> false: 
         MESSAGE "Не хватает средств на счете " + selarp + "~nПопытаться еще раз ?"
                   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                   TITLE "Проверка остатка" UPDATE choice4.

         case choice4:
            when false then return.
         end.        
     end.

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.

/*output to temp_com1.txt.                    */

do transaction:
        if (ctype = 1 and summa > 0 and v-temp-sum > 0) or (ctype = 10 and summa > 0) then do:

            display "Формируется п/п на сумму: " summa format "->,>>>,>>9.99"
            with no-labels centered frame fsm.
                            

            if ctype = 1 then do:
                 run trx  (     6, 
                                summa, 
                                1,
                                '', 
                                selarp,
                                commonls.prcgl, /* счет % */
                                '',                            
                                "Комиссия " +
                                string (selprc * 100,">9.9") + "% за платежи " + selbn, commonls.kbe, '14', '840').
                 if return-value = '' then undo, return.          
                 s-jh = int(return-value).            
            end.
            else do:
               v-dox = ''.
               if selgrp = 1                      then v-dox = '4'.
               if selgrp = 3 and seltxb ne 1      then v-dox = '1'.
               if selgrp = 10 and seltxb = 1      then v-dox = '1'.
               if selgrp = 3 and seltxb = 1       then v-dox = '5'.
               if selgrp = 4                      then v-dox = '3'.
               if selgrp = 9                      then v-dox = '7'.
               if lookup(string(selgrp), '2,5,6,7,8') > 0 then v-dox = '5'.
               if v-dox = '' then do:
                   MESSAGE "Не найден код доходов для данного вида платежей " selgrp
                   VIEW-AS ALERT-BOX TITLE "Внимание".
                   return.
               end. 

               for each tcommpl break by tcommpl.v-gl by tcommpl.depd :
                   accumulate tcommpl.comsum (total by tcommpl.v-gl by tcommpl.depd ).
                   if last-of( tcommpl.depd ) and  (accum total by tcommpl.depd tcommpl.comsum) > 0
                   then do:
                       /*
                       displ tcommpl.v-gl tcommpl.depd selarp (accum total by tcommpl.depd tcommpl.comsum).
                       pause 0.
                       */
                  
                       run trx  ( 6, 
                                  (accum total by tcommpl.depd tcommpl.comsum), 
                                  1, 
                                  '', 
                                  selarp,
                                  tcommpl.v-gl,
                                  '',                            
                                  "Комиссия за платежи " + selbn, commonls.kbe, '14', '840').
                       if return-value = '' then undo, return.          
                       s-jh = int(return-value).            

                       run cods-com (input integer(tcommpl.v-gl), input tcommpl.depd, input v-dox).

                       create tcom.
                       tcom.depd = tcommpl.depd.
                       tcom.v-gl = tcommpl.v-gl.
                       tcom.comdoc = s-jh.
                   
                       /*displ s-jh skip.*/
                   end.
               end.
            end.
        end.
end.  

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
release cods.

do transaction:
/*if selbn <> "АлматыТелеком Прочие" then do:*/
if selarp <> b-syscarp.chval then do:
for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
if ctype = 1 then assign commonpl.prcdoc = return-value.
             else do:
                find tcom where tcom.depd = tcommpl.depd and tcom.v-gl = tcommpl.v-gl no-error.
                if avail tcom then commonpl.comdoc = string(tcom.comdoc).
             end.
end.
end.
else do:
   for each tcommpl, commtk where rowid(commtk) = tcommpl.rid:
       if ctype = 1 then assign commtk.prcdoc = return-value.
       else do:
            find tcom where tcom.depd = tcommpl.depd and tcom.v-gl = tcommpl.v-gl no-error.
            if avail tcom then commtk.comdoc = string(tcom.comdoc).
       end.
   end.
end.

end.
hide frame fsm.
  
















