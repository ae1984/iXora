/* asu-reg.p
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
*/


{global.i}
{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{comm-chk.i} /* Проверка незачисленных платежей на АРП по счету за дату */
{comm-com.i}

def var dat as date.
def var summa as decimal.
def var tsum as decimal.
def var ttsum as decimal.
def var tcnt as integer init 0.
def var i as integer.
def var files as char initial "".
def var outf as char. 
def var subj as char.
def var selgrp  as integer init 7. /* водоканал */
def var selarp  as char.
def var selprc  as decimal format "9.9999".
def var selcom  as decimal format ">>>9.99".

DEFINE STREAM s1.

dat = g-today.
update dat label ' Укажите дату ' format '99/99/99' skip
with side-label row 5 centered frame dataa .

find first commonls where commonls.txb = seltxb and commonls.grp = selgrp and 
           commonls.visible = yes no-lock no-error .

selarp = commonls.arp. 
selprc = commonls.comprc.
selcom = commonls.comsum.

outf = "Tr" + string(dat, "99.99.99").
substr(outf, 5, 1) = "". 

if comm-chk(selarp,dat) then return.
i = 0.

if can-find (first commonpl where txb = seltxb and date = dat and
                                  commonpl.arp = selarp and deluid = ?  and 
                                  commonpl.grp = selgrp no-lock)
then do:
    OUTPUT STREAM s1 TO wpreg.txt.

    tsum = 0.0.
    ttsum = 0.0.

    put STREAM s1 unformatted
    "                            Реестр" skip
    "      извещений по приему платежей за услуги Астана Су Арнасы " skip
    "                         За " + string(dat,'99/99/9999') + " г." skip

    fill("=", 86) format "x(86)" skip
    "    Номер      Номер  Ф.И.О.                        Сумма      Комиссия       Всего" skip
    "  документа    счета " skip
    fill("-", 86) format "x(86)" skip.

    for each commonpl where commonpl.date = dat and
                            commonpl.txb = seltxb and
                            commonpl.arp = selarp and
                            commonpl.deluid = ?  and
                            commonpl.grp = 7
                            no-lock:

         summa = summa + commonpl.sum.
         tcnt = tcnt + 1.
         tsum = tsum + (selprc * commonpl.sum).
         ttsum = ttsum + commonpl.sum - (selprc * commonpl.sum).

         put stream s1
             space(3)
             commonpl.dnum format ">>>>>>9"
             space(2)
             commonpl.accnt format "99999999"
             space(2)
             commonpl.fio format "x(18)"
             space(1)
             commonpl.sum
                      format ">,>>>,>>>,>>9.99" 
             space(4)
             truncate(commonpl.sum * selprc, 2)
                      format ">,>>9.99"
             commonpl.sum - truncate(commonpl.sum * selprc,2)
                      format ">,>>>,>>>,>>9.99" 
             skip.

    end.

    find ofc where ofc.ofc = g-ofc no-lock.

 put STREAM s1 unformatted
    fill("-", 86) format "x(86)" skip.
 put STREAM s1 unformatted    
    "ИТОГО " tcnt format ">>>>" " ПЛАТЕЖЕЙ   НА СУММУ " 
    summa format ">,>>>,>>>,>>9.99" 
    skip
    "                      КОМИССИЯ         " 
    truncate(tsum,2)  format ">,>>9.99" skip
    "                         ВСЕГО " 
    truncate(ttsum,2) format ">,>>>,>>>,>>9.99"
    skip(2)
    "Менеджер операцион-" skip
    " ного департамента                " ofc.name format "x(30)"
    skip(2)
    "Подпись исполнителя:" skip(2)
    fill("=", 86) format "x(86)" skip(2).

    OUTPUT STREAM s1 CLOSE.

run menu-prt ("wpreg.txt").
unix silent value ( ' cp wpreg.txt ' + outf ).

if summa > 0 then do:
    files = files + ";" + outf.
    display  
    "Сформирован файл " 
    outf format "x(9)" 
    " на сумму " 
    summa with no-labels.
    pause.
  end.

end.
else do:
    MESSAGE "Отправленные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
