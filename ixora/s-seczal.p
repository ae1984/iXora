/* s-seczal.p
 * MODULE
        Кредитный
 * DESCRIPTION
        Работа с залогодателями
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
        01/03/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        05/04/2011 madiyar - в список залогодателей добавляем краткое наименование клиента
*/

def input parameter p-lon as char.
def input parameter p-ln as integer.
def output parameter p-log as logi.
def output parameter p-txt as char.

p-log = yes.
p-txt = ''.

find first lon where lon.lon = p-lon no-lock no-error.
if not avail lon then return.

find first lonsec1 where lonsec1.lon = lon.lon and lonsec1.ln = p-ln no-lock no-error.
if not avail lonsec1 then return.


def var v-cif as char no-undo.
def var v-ja as logi no-undo.
def var v-rid as rowid.

def temp-table wrk like lonsec1zal
    field clname as char
    index idx clname cif.

def buffer b-wrk for wrk.

for each lonsec1zal where lonsec1zal.lon = p-lon and lonsec1zal.ln = p-ln no-lock:
    find first cif where cif.cif = lonsec1zal.cif no-lock no-error.
    if avail cif then do:
        create wrk.
        buffer-copy lonsec1zal to wrk.
        wrk.clname = trim(cif.prefix + ' ' + cif.name).
    end.
end.

define button btn1 label "Сохранить".
define query qt for wrk.

define browse bt query qt
       displ wrk.cif label "Код" format "x(6)"
             wrk.clname label "Наименование" format "x(70)"
             with 26 down overlay no-label title " Залогодатели ".

define frame ft bt skip btn1 with width 85 column 10 row 4 overlay no-label.

def frame fr2
    v-cif format "x(6)" validate(can-find(cif where cif.cif = v-cif), "Нет такого клиента!")
    with width 6 column 14 no-label overlay no-box.

def frame fr3 skip(1)
    v-cif label " Код клиента" format "x(6)" validate(can-find(cif where cif.cif = v-cif), "Нет такого клиента!") " " skip(1)
    with side-labels centered row 13 overlay.

on "return" of bt in frame ft do:
    if not avail wrk then return.
    
    v-rid = rowid(wrk).
    v-cif = wrk.cif.
    frame fr2:row = bt:focused-row + 7.
    displ v-cif with frame fr2.
    update v-cif with frame fr2.
    wrk.cif = v-cif.
    hide frame fr2.
    find first cif where cif.cif = wrk.cif no-lock no-error.
    if avail cif then wrk.clname = trim(cif.prefix + ' ' + cif.name).

    open query qt for each wrk no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
end.

on "insert-mode" of bt in frame ft do:
    v-cif = ''.
    displ v-cif with frame fr3.
    update v-cif with frame fr3.
    hide frame fr3.

    create wrk.
    assign wrk.lon = p-lon wrk.ln = p-ln wrk.cif = v-cif.
    find first cif where cif.cif = wrk.cif no-lock no-error.
    if avail cif then wrk.clname = trim(cif.sname).
    v-rid = rowid(wrk).
    
    open query qt for each wrk no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
end.

on "delete-character" of bt in frame ft do:
    if not avail wrk then return.
    v-ja = no.
    message "Исключить выбранного залогодателя?" view-as alert-box buttons yes-no update v-ja.
    if v-ja then do:
        find b-wrk where rowid(b-wrk) = rowid(wrk) exclusive-lock no-error.
        if avail b-wrk then do:
            assign v-rid = rowid(wrk).
            bt:set-repositioned-row(bt:focused-row, "always").
            get next qt.
            if not avail wrk then get last qt.
            if avail wrk then v-rid = rowid(wrk).

            delete b-wrk.

            open query qt for each wrk no-lock.
            reposition qt to rowid v-rid no-error.
            if avail wrk then bt:refresh().
        end.
    end.
end.

on "end-error" of bt in frame ft do:
    p-log = no.
    hide frame ft.
    hide frame fr2.
    hide frame fr3.
    pause 0.
    return.
end.

on choose of btn1 in frame ft do:
    p-txt = ''.
    do transaction:
        for each lonsec1zal where lonsec1zal.lon = p-lon and lonsec1zal.ln = p-ln exclusive-lock:
            delete lonsec1zal.
        end.
        for each wrk no-lock:
            create lonsec1zal.
            assign lonsec1zal.lon = wrk.lon
                   lonsec1zal.ln = wrk.ln
                   lonsec1zal.cif = wrk.cif.
            
            if p-txt <> '' then p-txt = p-txt + ','.
            p-txt = p-txt + wrk.clname.
        end.
     end.
end.

open query qt for each wrk no-lock.
enable bt btn1 with frame ft.

wait-for window-close of current-window or choose of btn1.


hide frame ft.
hide frame fr2.
hide frame fr3.
pause 0.

