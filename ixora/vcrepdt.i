/* vcrepdt.i
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


def var v-dtb as date.
def var v-dte as date.
def var v-closed as logical format "да/нет" init yes.

form 
  skip(1)
  v-dtb    label "         Контракты после " format "99/99/9999" " " skip
  v-dte    label " Отчетная дата (не вкл.) " format "99/99/9999" " " skip(1)
  v-closed label " Показывать закрытые контракты " skip(1)
  with centered side-label row 5 title "{1}" frame f-dt.


find vcparams where parcode = "contrs14" no-lock no-error.
if avail vcparams then v-dtb = date(vcparams.valchar). else v-dtb = 01/01/2002.

v-dte = g-today.

update v-dtb v-dte v-closed with frame f-dt.
