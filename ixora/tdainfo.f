/* tdainfo.f
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Вывод информации о депозитном счете клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-1
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
    22/08/03 nataly изменен формат aaa.pri , pri.pri c "x(1)"  - > "x(3)"
    19/03/04 nataly intavail поставлен формат с отриц остатком
    20.05.2004 nadejda - добавлена информация, является ли счет исключением по % ставке
	07.06.2005 u00121 - увеличил формат вывод полей Закрыть сегодня и Закрыть всрок до 100 млн.
	25/09/2008 galina - счет 20-тизначный
	29/09/2008 galina - указала ширину фрейма tda0
    28/12/2010 evseev - заремил v-paynow, т.к. расчитывается неверно.
*/

def var vaaa like aaa.aaa.
def var vopnamt like aaa.opnamt.
def var adddepos as deci.
def var capitalized as deci.
def var currentbase as deci.
def var intpaid as deci.
def var intavail as deci.
def var vterm as inte.
def var vday as inte.
def var v-pay as deci.
def var v-paynow as deci.
def var intrat like aaa.rate.
def var v-excl as char.

form vaaa     label "Номер счета" format "x(20)"
     aaa.cif        label " Клиент  "
     cif.name no-label format "x(35)" skip (1)
     crc.code label "Валюта     " format "x(3)"
     lgr.lgr  at 25 label " Группа  " format "x(3)"
     lgr.des  no-label format "x(35)" skip
     aaa.sta  label "Статус     " format "x(1)"
     aaa.pri at 25  label " Код %   " format "x(3)" skip(1)
     aaa.lstmdt label "Дата начала   "
    /* aaa.cla    label "Срок (месяцы)  " format " zz9"  nataly-----*/
     vday    label      "Срок (дни)    " format "zzzz9"
    /* v-paynow   label "Закр. сегодня " format "zzz,zzz,zzz.99"  skip  */
     "Закр. сегодня : - " skip
     aaa.expdt  label "Дата окончания"
     vterm      label "Осталось(дней)" format "-zzz9"
     v-pay      label "Закр. всрок   " format "zzz,zzz,zzz.99" skip(1)
with side-label row 5 width 90 title " Общая информация " overlay frame tda0.

form vopnamt     format "zzz,zzz,zzz.99" label "Начальная сумма       " skip
     adddepos    format "zzz,zzz,zzz.99" label "Дополнительно внесено " skip
     capitalized format "zzz,zzz,zzz.99" label "Капитализированные %  " skip
     currentbase format "zzz,zzz,zzz.99" label "Всего на сегодня      "
with side-label row 15 column 1 title " База начисления процентов " overlay frame tda1.

form intrat      format "        zzz.99"  label "% ставка на сегодня "
     v-excl      format "x"             no-label skip
     aaa.accrued format "zzz,zzz,zzz.99-" label "Всего начислено     "  skip
     intpaid     format "zzz,zzz,zzz.99-" label "Выплачено           "  skip
     intavail    format "zzz,zzz,zzz.99-" label "Доступно к выплате  "
with side-label row 15 column 41 title " Процентный доход " overlay frame tda2.



