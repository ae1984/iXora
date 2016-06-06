/* h-kdlon.p
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
   30/04/2004 madiar - Просмотр досье филиалов в ГБ
*/

/* h-kdlon.p ПотребКредит
   Список заявок - F2 на номере заявки в форме для переменной s-kdlon

   21.07.2003 marinav
*/

{global.i}
{kd.i}

def temp-table t-ln
  field rdt like kdcif.regdt
  field lon like kdlon.kdlon
  field amount like kdlon.amountz
  field goal like kdlon.goalz  
  index main is primary rdt ASC.

def var v-sel as char format "x".
def var v-nom as char format "x(30)".
def var v-dt as date format "99/99/9999".
def var v-int as integer format ">>>9".


    for each kdlon where (kdlon.bank = s-ourbank or s-ourbank = "TXB00") and kdlon.kdcif = s-kdcif no-lock.
      create t-ln.
      assign t-ln.rdt = kdlon.regdt
             t-ln.lon = kdlon.kdlon
             t-ln.amount = kdlon.amountz
             t-ln.goal = kdlon.goalz. 
    end.


find first t-ln no-error.
if not avail t-ln then do:
  message skip " Совпадение не найдено !" skip(1) view-as alert-box button ok title "".
  return.
end.


{itemlist.i 
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.lon label 'КОД' format 'x(6)'
                    t-ln.rdt label 'ДАТА РЕГ' 
                    t-ln.amount label 'СУММА' format '>>>,>>>,>>9.99'
                    t-ln.goal label 'ЦЕЛЬ КРЕДИТА' format 'x(30)'
                   " 
       &chkey = "lon"
       &chtype = "string"
       &index  = "main" 
}



