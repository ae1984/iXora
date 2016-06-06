/* clplaned.f
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

/* clplaned.f Настройки кредитного модуля
   Форма редактирования справочника схем начисления процентов

   30.07.2003 nadejda
*/

def var v-codfr as char init "lnplan".
def var v-plans as char init "A,M".

def buffer b-codfr for codfr.

function chkcod returns logical (p-value as char).
  def var i as integer.

  if p-value = "" then return false.

  if index (p-value, ".") > 0 or index (p-value, ",") > 0 then return false.

  i = integer (p-value) no-error.
  if error-status:error then return false.

  return true.
end.

form
     codfr.code format "x(5)" label "КОД"
       help " Код схемы - 1 цифра"
       validate (chkcod (codfr.code), " Код схемы должен быть цифрой, спецсимволы не допускаются !")
     codfr.name[1] format "x(40)" label "НАИМЕНОВАНИЕ СХЕМЫ"
       help " Название схемы - коротко !"
     codfr.name[2] format "x(1)" label "МЕТОД НАЧИСЛ"
       help " A - автоматически ежедневно, M - менеджером по графику"
       validate (lookup (codfr.name[2], v-plans) > 0, " Неверный метод начисления процентов !")
     with row 5 centered scroll 1 12 down frame f-ed .
