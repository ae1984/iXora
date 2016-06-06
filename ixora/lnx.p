/* lnx.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Изменение схемы кредиты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        02/07/2008 madiyar
 * BASES
        BANK
 * CHANGES
        17/07/2010 madiyar - разрешено изменение 1->6
        01/02/2013 zhasulan - ТЗ 1653 (запрет на выбор схемы 5 для групп <> 90,92)
*/

{global.i}

def shared var s-lon like lon.lon.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "lon не найден!" view-as alert-box error.
    return.
end.

def var plan_lst as char no-undo init "1,2,5,6".
def var v-plan as integer no-undo.
def var v-group as integer no-undo.
def var v-des as char no-undo.
def var correct as logical.
v-plan = lon.plan.
v-group = lon.grp.

if lookup(string(v-plan),plan_lst) = 0 then do:
    message "Некорректная схема кредита для изменения!" view-as alert-box error.
    return.
end.

def temp-table t-ln no-undo
  field plan as integer
  field des as character
  index idx is primary plan.

empty temp-table t-ln.

for each codfr where codfr.codfr = "lnplan" no-lock:
    if lookup(string(codfr.code),plan_lst) > 0 then do:
        create t-ln.
        assign t-ln.plan = integer(codfr.code)
               t-ln.des = codfr.name[1].
    end.
end.

define frame chplan
    skip(1)
    v-plan label " Схема кредита " format ">9" validate(can-find(t-ln where t-ln.plan = v-plan),"Некорректная схема!")
    v-des no-label format "x(30)"
    skip(1)
    with centered overlay side-labels row 15 title " Изменение схемы кредита ".

on help of v-plan in frame chplan do:
    {itemlist.i
        &file = "t-ln"
        &frame = "row 6 centered scroll 1 12 down overlay "
        &where = " true "
        &flddisp = " t-ln.plan label 'КОД' format '>9'
                     t-ln.des label 'ОПИСАНИЕ' format 'x(20)'
                    "
        &chkey = "plan"
        &chtype = "integer"
        &index  = "idx"
        &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-plan = t-ln.plan.
    displ v-plan with frame chplan.
end.


find first t-ln where t-ln.plan = v-plan no-lock no-error.
if avail t-ln then v-des = t-ln.des. else v-des = ''.
displ v-plan v-des with frame chplan.

repeat:
correct = true.
update v-plan with frame chplan
editing:
    readkey.
    apply lastkey.
    find first t-ln where t-ln.plan = input frame chplan v-plan no-lock no-error.
    if avail t-ln then v-des = t-ln.des. else v-des = ''.
    displ v-des with frame chplan.
end.
if v-group <> 90 and v-group <> 92 and input frame chplan v-plan = 5 then do:
       message "Вы не можете выбрать схему 5" view-as alert-box button Ok.
       correct = false.
   end.
if correct then leave.
end.

if v-plan <> lon.plan then do:
    find current lon exclusive-lock.
    lon.plan = v-plan.
    find current lon no-lock.
end.
