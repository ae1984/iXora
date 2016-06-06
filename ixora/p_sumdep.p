/* p_sumdep.p
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
	30.03.2004 valery добавлен выбор депозитов по счетам 220620, 220720 и выбор новых депозитов группа которых начинается на "D" и старых - на "3"
*/



def var kols as integer.
def var s as decimal format "zzz,zzz,zzz,zzz.99-".
def var prtek as decimal format "zzz,zzz,zzz,zzz.99-".
def var prpred as decimal format "zzz,zzz,zzz,zzz.99-".
s = 0.0.
kols = 0.
prtek = 0.0.
prpred = 0.0.
output to 'depoz.txt'.
for each aaa where aaa.sta <> 'C' and aaa.gl = 221520 or aaa.gl = 221720 or aaa.gl = 220620 or aaa.gl = 220720 and aaa.lgr begins "3" or aaa.lgr begins "D" break by aaa.rate by aaa.crc:
 prtek = aaa.rate.
 if prtek <> prpred then do: 
    displ prpred label 'Ставка' s label 'Сумма' kols label 'К-во счетов' aaa.crc label 'Валюта'.
    s = aaa.cbal .
    kols = 1.
 end.
 if prtek = prpred then s = s + aaa.cbal.
 prpred = aaa.rate. 
   kols = kols + 1.
/*displ s aaa.crc aaa.aaa aaa.cbal aaa.ddr aaa.lgr aaa.grp  aaa.name aaa.rate
aaa.sta.   */

end.
output close.
run menu-prt('depoz.txt').