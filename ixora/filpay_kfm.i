/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2009 madiyar
 * BASES
        BANK
 * CHANGES
        17.08.2010 galina - поменяла местами ОКПО и ОКЭД
        25/08/2010 galina - отрезаем лишние пробелы перед и после ФИО
        23/05/2013 Luiza  - ТЗ № 1838 все проверки по финмон отключаем, будут проверяться в AML
*/

/*{global.i}*/

/* galina - мои переменные*/

def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def var v-mess as integer no-undo.
def var v-oper as char no-undo.
def var v-operId as integer no-undo.
def var v-kfm as logi no-undo.
def var v-name as char no-undo.
def var v-fname as char no-undo.
def var v-mname as char no-undo.
def var v-clnameU as char no-undo.
def var v-doctype as char no-undo.
def var v-docdt as char no-undo.
def var v-docreg  as char no-undo.
def var v-bnkbik as char no-undo.

def new shared var v-chief as char no-undo.
def new shared var v-clOKED as char no-undo.
def new shared var v-clOKPO as char no-undo.
def new shared var v-clbin as char no-undo.
def new shared var v-clphone as char no-undo.
def new shared var v-clemail as char no-undo.
def new shared var v-bdt  as date no-undo.
def new shared var v-bplace as char no-undo.
def new shared var v-cladru as char no-undo.
def new shared var v-cladrf as char no-undo.
def new shared var v-res2 as char no-undo.
def new shared var v-res as char no-undo.
def new shared var v-cltype as char no-undo.
def new shared var v-publicf as char no-undo.

/* def buffer b-filp for filpayment. */

/****конец - мои переменные*******/

/*********galina - КФМ************/
/* v-monamt = filpayment.amount.
if v-crc > 1 then do:
  find first crc where crc.crc = v-crc no-lock no-error.
  if avail crc then v-monamt = filpayment.amount * crc.rate[1].
end.
v-mess = 0.
v-monamt2 = v-monamt.
if v-monamt < 7000000 then do:
  for each b-filp where b-filp.bankto = filpayment.bankto and b-filp.iik = filpayment.iik and b-filp.whn >= g-today - 7 and b-filp.whn <= g-today and  b-filp.type = filpayment.type no-lock:
       if b-filp.jh = 0 then next.
       if b-filp.crc = 1 then v-monamt2 = v-monamt2 + b-filp.amount.
       else do:
           find last crchis where crchis.crc = b-filp.crc and crchis.rdt < b-filp.whn no-lock no-error.
           if avail crchis then v-monamt2 = v-monamt2 + b-filp.amount * crchis.rate[1].
       end.
  end.
  v-mess = 1.
end.
if v-monamt2 >= 7000000 then do:
   if filpayment.type begins 'get' then do:
       if v-mess = 1 then message 'Общая сумма снятий со счета за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
       else message "Снятие со счета суммы >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box  title 'ВНИМАНИЕ'.
   end.
   else do:
       if v-mess = 1 then message 'Общая сумма зачисления на счет за последние 7 дней >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
       else message "Зачисление на счет >= 7000000 тенге подлежит финансовому мониторингу!" view-as alert-box  title 'ВНИМАНИЕ'.
   end.
   empty temp-table t-kfmoperh.
   empty temp-table t-kfmprt.
   empty temp-table t-kfmprth.

   v-oper = ''.
   if filpayment.type begins 'get' then do:
       if v-cltype = '01' then do:
           if filpayment.knp = '321' then v-oper = '03' .
           else  v-oper = '05'.
       end.
       else v-oper = '05'.
   end.
   else v-oper = '05'.

   find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(filpayment.crc) no-lock no-error.

   run kfmoperh_cre('01','01',filpayment.id,v-oper,filpayment.knp,'1',codfr.code,trim(string(filpayment.amount,'>>>>>>>>>>>>9.99')),v-monamt,'','','','','','','','','', output v-operId).

   v-name = ''.
   v-fname = ''.
   v-mname = ''.
   v-doctype = ''.
   v-docdt = ''.
   v-docreg = ''.

   if v-cltype = '01' then v-clnameU = v-fio.
   else do:
       if v-cltype = '02' then do:
           if filpayment.name <> '' then do:
               if num-entries(trim(filpayment.name),' ') >= 1 then v-fname = entry(1,trim(filpayment.name),' ').
               if num-entries(trim(filpayment.name),' ') > 1 then v-name = entry(2,trim(filpayment.name),' ').
               if num-entries(trim(filpayment.name),' ') > 2 then v-mname = entry(3,trim(filpayment.name),' ').
           end.
       end.
       else do:
           if v-chief <> '' then do:
               if num-entries(v-chief,' ') >= 1 then v-fname = entry(1,v-chief,' ').
               if num-entries(v-chief,' ') > 1 then v-name = entry(2,v-chief,' ').
               if num-entries(v-chief,' ') > 2 then v-mname = entry(3,v-chief,' ').
           end.
       end.
       if v-res2 = '0' then v-doctype = '11'.
       else v-doctype = '01'.
       if num-entries(v-pss,' ') >= 2 then v-docdt = entry(2,v-pss,' ').
       if num-entries(v-pss,' ') >= 3 then v-docreg = entry(3,v-pss,' ').
       if num-entries(v-pss,' ') > 3 then v-docreg = entry(3,v-pss,' ') + ' ' + entry(4,v-pss,' ').
   end.
   find first sysc where sysc.sysc = 'clecod' no-lock no-error.
   if avail sysc and sysc.chval <> '' then v-bnkbik = sysc.chval.

   run kfmprt_cre(v-operId,1,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',filpayment.iik,v-bankname,v-bnkbik,'KZ','','','','',v-clnameU,v-chief,filpayment.rnnto,v-clOKPO,v-clOKED,v-clbin,v-fname,v-name,v-mname,v-clphone,v-clemail,v-doctype,entry(1,v-pss,' '),'',v-docreg,v-docdt,string(v-bdt,'99/99/9999'),v-bplace,v-cladru,v-cladrf,'','01').
   s-operType = 'fm'.
   run kfmoper_cre(v-operId).

   if not kfmres then do:
      if filpayment.type = 'add' then do:
          find current filpayment.
          delete filpayment.
      end.
      return.
   end.
   v-kfm = yes.
end. */

/*********конец - КФМ***********/
