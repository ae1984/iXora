/* h-kdname.p
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
        21.07.2003 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр досье филиалов в ГБ
        14/10/2005 madiar - Возвращается не frame-value, а t-ln.name
*/

{global.i}
{kd.i}

def temp-table t-ln
  field ln like kdaffil.ln
  field name like kdaffil.name
  index main is primary ln ASC.

def var v-sel as char format "x".
def var v-nom as char format "x(30)".
def var v-dt as date format "99/99/9999".
def var v-int as integer format ">>>9".

    find kdcif where (kdcif.bank = s-ourbank or s-ourbank = "TXB00") and kdcif.kdcif = s-kdcif no-lock no-error.
    create t-ln.
    assign t-ln.ln = 0
           t-ln.name = kdcif.name.
    for each kdaffil where (kdaffil.bank = s-ourbank or s-ourbank = "TXB00") and kdaffil.code = '22'
              and kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon  no-lock.
      create t-ln.
      assign t-ln.ln = kdaffil.ln
             t-ln.name = kdaffil.name.
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
       &flddisp = " t-ln.ln label 'КОД' format '>>9'
                    t-ln.name label 'ЗАЛОГОДАТЕЛЬ'
                   "
       &chkey = "name"
       &chtype = "string"
       &index  = "main"
}

/*return frame-value.*/
return t-ln.name.
