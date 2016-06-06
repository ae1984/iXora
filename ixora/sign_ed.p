/* sign_ed.p
 * MODULE
        Потребительские кредиты - замена подписей
 * DESCRIPTION
        Редактирование локальных параметров по каждому профилю
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
        11/06/2008 madiyar
 * BASES
        BANK
 * CHANGES
        18/07/2011 evseev - изменения в sign_common.i
*/

{global.i}

{sign_common.i}

def temp-table t-data no-undo
  field dcode as char
  field des as char
  field str as char
  index idx is primary dcode.

def buffer b-data for t-data.
def var v-rid as rowid.

def var v-who as integer no-undo.
v-who = 0.

{itemlist.i
    &file = "t-faces"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " t-faces.code label 'КОД' format '>9'
                 t-faces.face label 'НАИМЕНОВАНИЕ' format 'x(64)'
               "
    &chkey = "code"
    &chtype = "integer"
    &index  = "idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
}
v-who = t-faces.code.

def var i as integer no-undo.

empty temp-table t-data.

do i = 1 to num-entries(spr_list):

    find first codific where codific.codfr = entry(i,spr_list) no-lock no-error.
    if not avail codific then do:
        create codific.
        codific.codfr = entry(i,spr_list).
        find first sysc where sysc.sysc = entry(i,spr_list) no-lock no-error.
        if avail sysc then codific.Name = sysc.des.
        codific.who = g-ofc.
        codific.whn = g-today.
        find current codific no-lock.
    end.

    find first codfr where codfr.codfr = entry(i,spr_list) and codfr.code = string(v-who) no-lock no-error.
    if not avail codfr then do:
        create codfr.
        codfr.codfr = entry(i,spr_list).
        codfr.code = string(v-who).
        codfr.name[1] = "".
        codfr.level = 1.
        find current codfr no-lock.
    end.

    create t-data.
    t-data.dcode = entry(i,spr_list).
    t-data.des = codific.Name.
    t-data.str = codfr.name[1].

end.

define query qt for t-data.
define browse bt query qt
    displ t-data.dcode label "КОД ПАР" format "x(12)"
          t-data.des label "ПАРАМЕТР" format "x(38)"
          t-data.str label "ЗНАЧЕНИЕ" format "x(52)"
    with 26 down centered overlay no-label no-box /*title " ПАРАМЕТРЫ "*/.

define button bsave label "Сохранить".

define frame ft
   " " t-faces.face format "x(80)" skip(1)
   bt help " <Enter>-Редактирование параметра, F4-Выход" skip
   " " bsave
   with width 110 row 3 overlay no-label.

on "return" of bt in frame ft do:
    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-data).
    update t-data.str label "ЗНАЧЕНИЕ" format "x(2000)" view-as fill-in size 108 by 1 with centered row 7 overlay width 110 frame fr.
    hide frame fr.
    open query qt for each t-data.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
end.

on choose of bsave in frame ft do:
    for each b-data no-lock:
        find first codfr where codfr.codfr = b-data.dcode and codfr.code = string(v-who) exclusive-lock no-error.
        if not avail codfr then do:
            create codfr.
            codfr.codfr = b-data.dcode.
            codfr.code = string(v-who).
            codfr.level = 1.
        end.
        codfr.name[1] = b-data.str.
        find current codfr no-lock.
    end.
    message " Данные сохранены " view-as alert-box information.
end.

open query qt for each t-data.
displ t-faces.face with frame ft.
enable bt bsave with frame ft.

wait-for choose of bsave or window-close of current-window.
pause 0.

