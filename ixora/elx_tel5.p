/* elx_tel5.p 
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Реестр по приему платежей через Элекснет
 * MENU
        5-2-1-1-4-5
 * AUTHOR
        17/10/2006 u00124
 * CHANGES
        17/11/2006 u00124 Редактирование меню
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{comm-chk.i}
{global.i}

def temp-table tcommpl like commonpl.
def var dat as date                      no-undo.
def var files as char initial ""         no-undo.
def var outf as char                     no-undo.
def var subj as char                     no-undo.
def var selgrp  as integer init 3        no-undo.
def var selarp  as char                  no-undo.
def var ourbank as char                  no-undo.
def var p-parameter as integer init 100  no-undo.
def var p-count as integer init 0        no-undo.
def var p-patch as integer init 1        no-undo.
def var p-patch-sum as decimal init 0    no-undo.
def var p-patch-comsum as decimal init 0 no-undo. 
def var tcnt as integer init 0           no-undo.
def var tsum as decimal init 0           no-undo. 
def var ttsum as decimal init 0          no-undo. 

DEFINE STREAM s1.
 if seltxb = 0 then selgrp = 3.
 if seltxb = 1 then selgrp = 10.
 dat = g-today.
p-parameter = 4000.
update dat label ' Укажите дату ' format '99/99/99' skip with side-label row 5 centered frame dataa .

update p-parameter label ' Введите количество платежей в пачке ' format '>>>>>>9' skip with side-label row 6 centered frame dataa.

def buffer b-ktrekv for sysc.
find last b-ktrekv  where b-ktrekv.sysc  = "KTREKV" no-lock no-error.
if not avail b-ktrekv then return.


selarp = ENTRY(1, b-ktrekv.chval).



outf = "Tr" + string(dat, "99.99.99").
substr(outf, 5, 1) = "".

for each txb where visible and city = seltxb no-lock:
for each commonpl no-lock where commonpl.txb = txb.txb and date = dat and commonpl.arp = selarp
       and deluid = ?:
     create tcommpl.
     buffer-copy commonpl to tcommpl.
end.
end.

find first tcommpl no-error.
if available tcommpl then do:

  OUTPUT STREAM s1 TO kztcreg.txt.
  put STREAM s1 unformatted
  "                         РЕЕСТР" skip
  "извещений по приему платежей(КИОСКИ ОПЛАТЫ) за услуги связи " + ENTRY(5, b-ktrekv.chval) skip(1)
  "                    За " + string(dat,'99/99/9999') + " г." skip(1).

  for each tcommpl no-lock break by tcommpl.date by tcommpl.sum:
      if p-count = 0 then
      do:
        put STREAM s1 unformatted
        "                            Пачка N " p-patch format ">>>>>>9"   skip
        fill("=", 118) format "x(118)" skip
        "     Номер       Номер        Номер           Сумма              Счет - извещение           Время      Уникальный номер " skip
        "   документа    телефона      счета                                                                    платежа" skip
        fill("-", 118) format "x(118)" skip.

      end.
      p-patch-sum = p-patch-sum + tcommpl.sum.
      tcnt = tcnt + 1.
      tsum = tsum + tcommpl.comsum.
      p-patch-comsum = p-patch-comsum + tcommpl.comsum.
      ttsum = ttsum + tcommpl.sum + tcommpl.comsum.

    ACCUMULATE tcommpl.sum (total count).
    put STREAM s1 unformatted
      space(3) tcommpl.dnum format "zzzzzz9"
      space(7)
      tcommpl.counter format "zzzzzzz9"
      space(5)
      tcommpl.accnt format "zzzzzzz9"
      space(2)
      tcommpl.sum format ">>>>>>>>>>9.99"
      space(13)
      tcommpl.fioadr format "x(24)"
      space(2)
      string(tcommpl.cretime,"HH:MM:SS") 
      space(2)
      tcommpl.billdoc format "x(6)"



    skip.
    p-count = p-count + 1.
    if (p-count = p-parameter) or (last-of(tcommpl.date) and (p-count <> 0)) then
    do:
      put STREAM s1 unformatted
      fill("-", 118) format "x(118)" skip.
      put STREAM s1 unformatted "ИТОГО ПЛАТЕЖЕЙ ПО ПАЧКЕ " p-patch format ">>>>>>>9" " НА СУММУ "
      truncate(p-patch-sum,2) format ">,>>>,>>>,>>9.99" skip.
      put STREAM s1 unformatted " КОМИССИЯ ПАЧКИ" truncate(p-patch-comsum, 2) format ">>>,>>9.99" skip
      fill("-", 118) format "x(118)" skip(5).
      p-patch-sum = 0.0.
      p-patch-comsum = 0.0.
      p-count = 0.
      p-patch = p-patch + 1.
    end.

  end.

  find ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then ourbank = ofc.name. else ourbank = "UNKNOWN".

  put STREAM s1 unformatted
    fill("-", 118) format "x(118)" skip
    "ИТОГО ПЛАТЕЖЕЙ  " (accum count tcommpl.sum) format ">>>>>>>>>>>>>>>>9" skip(1)
    "      НА СУММУ  " (accum total tcommpl.sum) format ">>>>>>>>>>>>>9.99" skip(1)
    "КОМИССИЯ(0.5%)  " truncate((accum total tcommpl.sum) * 0.005, 2) format ">>>>>>>>>>>>>9.99" skip(1)
    "      К ОПЛАТЕ  " ((accum total tcommpl.sum) - truncate((accum total tcommpl.sum) * 0.005, 2))  format ">>>>>>>>>>>>>9.99" skip(2)



    "Менеджер операцион-" skip
    " ного департамента                    " ourbank format "x(40)"
    skip(2)
    "Подпись исполнителя:" skip(2)
    fill("=", 118) format "x(118)" skip(2).

    OUTPUT STREAM s1 CLOSE.
  run menu-prt ("kztcreg.txt").
  unix silent value ( ' cp kztcreg.txt ' + outf ).

  files = files + ";" + outf.


  MESSAGE "Отправить реестр биллинговых платежей в Алматытелеком?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Платежи Казахтелеком" UPDATE choicereg as logical.
  if choicereg = False then return.
  unix silent value('un-win kztcreg.txt ' + outf + ".txt").
  run mail("oud@almatytelecom.kz"  , "TEXAKABANK <abpk@elexnet.kz>", "КИОСКИ ОПЛАТЫ", "", "1", "", outf + ".txt"). 
  run mail("dpuchkov@elexnet.kz", "TEXAKABANK <abpk@elexnet.kz>", "КИОСКИ ОПЛАТЫ", "", "1", "", outf + ".txt").
end.
else do:
    MESSAGE "Отправленные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
















