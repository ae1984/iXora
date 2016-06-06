/* mob333txb.p
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

/*___Копирование информации о платеже_*/
/* KMobile в таблицу mobtemp на TXB00 */
/*___ 23.08.2002 by S@SCO ____________*/

def input parameter g-today as date.
def input parameter g-ofc as char.
def input parameter g-dnum as char.
def input parameter g-phone as char.
def input parameter g-sum as decimal.
def input parameter g-rem as char.

if not connected ("txb") then do:
       message "Нет связи с базой головного офиса!"
       view-as alert-box title "Уведомление для KMobile".
       return.
end.

create txb.mobtemp.
assign txb.mobtemp.valdate = g-today
       txb.mobtemp.cdate = today
       txb.mobtemp.ctime = time
       txb.mobtemp.sum = g-sum
       txb.mobtemp.who = g-ofc
       txb.mobtemp.state = 0
       txb.mobtemp.phone = g-phone
       txb.mobtemp.ref = g-dnum
       txb.mobtemp.npl = g-rem
       no-error.

