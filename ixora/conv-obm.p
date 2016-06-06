/* conv-obm.p
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
        08.06.2011 aigul - исправила вывод курса (после запятой выводить 4 цифры)
*/

/* conv-obm.p
   Конвертация для обменных операций
   27.11.2000 */

def input        parameter  crc1  as inte.
def input        parameter  crc2  as inte.
def input-output parameter  amt1  as deci.
def input-output parameter  amt2  as deci.
def output       parameter  vrat1 as deci decimals 4.
def output       parameter  vrat2 as deci decimals 4.
def output       parameter  coef1 as inte.
def output       parameter  coef2 as inte.
def output       parameter  vbuy  as deci.
def output       parameter  vsel  as deci.

def shared var vrat as deci decimals 4.
def buffer  fcrc  for crc.
def buffer  tcrc  for crc.


find fcrc where fcrc.crc = crc1 no-lock.
find tcrc where tcrc.crc = crc2 no-lock.
if crc1 <> 1 then do:
 amt2 = round(amt1 * vrat * tcrc.rate[9]
           / tcrc.rate[3] / fcrc.rate[9],tcrc.decpnt).
 vbuy = round(amt1 * (fcrc.rate[1] - vrat) / fcrc.rate[9], 2).
 vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
 vrat1 = vrat.
 vrat2 = tcrc.rate[3].
end.
else do.
 amt2 = round(amt1 * fcrc.rate[2] * tcrc.rate[9]
       / vrat / fcrc.rate[9],fcrc.decpnt).
 vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
 vsel = round(amt2 * (vrat - tcrc.rate[1]) / tcrc.rate[9], 2).
 vrat1 = fcrc.rate[2].
 vrat2 = vrat.
end.
 coef1 = fcrc.rate[9].
 coef2 = tcrc.rate[9].
