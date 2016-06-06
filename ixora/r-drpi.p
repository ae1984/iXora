/* r-drpi.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


{mainhead.i}

def var t1 as int init 0.
def var t2 as int init 0.
def var i as int init 0.
def var ks as int init 1.
def var ksc as int init 1.
def var kd as int init 1.
def var ir as int init 0.
def var v-today as date label "DATUMS ".
def temp-table ww
        field remtrz like remtrz.remtrz
        field source like remtrz.source
        field sqn like remtrz.t_sqn
        field ref like remtrz.ref
        field crc like remtrz.fcrc
        field amt like remtrz.amt
        field jh1 like remtrz.jh1
        field jh2 like remtrz.jh2
        field pid like que.pid
        field scbank like remtrz.scbank
        field cbank like remtrz.scbank
        field dracc like remtrz.dracc
        field sts like CurSta.rem.
def var ds as date.

update v-today label "Дата" with side-label centered row 4 frame vv.

{image1.i rpt.img}
{image2.i }

 {report1.i 59}

ds = v-today - 8.

for each remtrz where remtrz.rdt ge ds no-lock.
  if (remtrz.source = "I" or remtrz.source = "SW" or remtrz.source = "UI") and 
     remtrz.valdt1 = v-today then do  :

   create ww.
   ww.remtrz = remtrz.remtrz.
   ww.source = remtrz.source.
   ww.sqn = remtrz.t_sqn.
   ww.ref = remtrz.ref.
   ww.crc = remtrz.fcrc.
   ww.amt = remtrz.amt.
   ww.scbank = remtrz.sbank.
   ww.cbank = remtrz.scbank.
   ww.dracc = remtrz.dracc.

   find que where que.remtrz = remtrz.remtrz no-lock no-error.
   if available que then
   ww.pid = que.pid.
   ww.jh1 = remtrz.jh1.
   ww.jh2 = remtrz.jh2.
 end.
end.            


 put trim(g-comp) format "x(60)" skip
     "Исполнитель:  " g-ofc skip
     "Напечатано :  " g-today "  " string(time,"hh:mm:ss") skip(1). 
 put skip(1) space(20) " Зарегестрированные входящие платежи за " v-today skip(1).
 put "----------------------------------------------------"
     "-------------------------------------------" skip.
 put " Платеж   Тр.ссыл.   Клиент   Кл.ссыл. Вал." space(9)
     "Сумма         1пров" space(3) "2пров  Код  " skip .
 put "----------------------------------------------------"
     "-------------------------------------------" skip.

 for each ww where ww.pid ne "D" break by ww.crc by ww.dracc by ww.scbank 
     by ww.source by ww.amt by ww.pid :
     accum ww.amt(total).
     accum ww.amt(total by ww.scbank).
     accum ww.amt(total by ww.dracc).
     accum ww.amt(total by ww.source).
     
     accum ksc(total by ww.scbank).
     accum kd(total by ww.dracc).
     accum ks(total by ww.source).
     
     find crc where crc.crc = ww.crc no-lock no-error.

     if first-of(ww.dracc) then put ww.dracc skip
     "-------------------------------------------" skip.
     if first-of(ww.scbank) then put 
     "==============================" skip
      ww.scbank "    " ww.cbank skip
     "==============================" skip.
     if first-of(ww.source) then put ww.source skip
     "-------------" skip.
     put ww.remtrz " " trim(ww.sqn) " " substr(ww.ref,1,6) " " substr(ww.ref,11)
         " " crc.code " " ww.amt " " ww.jh1 " " ww.jh2 "  " ww.pid
          skip .
     if last-of(ww.source) then put "-------------" skip
         " Всего по источнику : платежей " accum total by ww.source ks " " 
         ww.source ":   "
         accum total by ww.source ww.amt format ">,>>>,>>>,>>>,>>9.99" skip
         "-------------" skip.
     
     if last-of(ww.scbank) then put " Всего по банку     : платежей " 
        accum total by ww.scbank ksc " " ww.scbank ":   "
        accum total by ww.scbank ww.amt format ">,>>>,>>>,>>>,>>9.99" skip.

     if last-of(ww.dracc) then put " Всего по кор.счету : платежей " 
        accum total by ww.dracc kd " " ww.dracc ":   "
        accum total by ww.dracc ww.amt format ">,>>>,>>>,>>>,>>9.99" skip(1)
     "-------------------------------------------" skip.

     i = i + 1.
     if ww.jh1 <> ? then t1 = t1 + 1.
     if ww.jh2 <> ? then t2 = t2 + 1.
 end.

 put skip(1) "   Всего: платежей " i format ">>>9" space(25) "Сумма "
    accum total ww.amt format ">,>>>,>>>,>>>,>>9.99"
    " " " 1пров " t1 format ">>>9" " 2пров " t2 format ">>>9"
    skip(2).

{report2.i 132}
{report3.i}
{image3.i} 
