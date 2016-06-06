/* h-usrid.p
 * MODULE
        Хлепер для переменной int v-usrid
 * DESCRIPTION
        По F2 в pragma на переменной v-usrid 
        Выдает список доступных пользоватлей для sharing документов в Internet Office
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
        02/03/04 isaev
 * CHANGES
 * USES ib
 */


def shared var g-lang as char.
def shared var g-usrid like usr.id.
def shared var g-usrcif like usr.cif.
def shared var g-action as int.
def buffer busr for usr.

def temp-table lst
    field id as int format ">>>>>>>>9" label "No."
    field login as char format "x(20)" label "Login"
    index idx1 is unique id
    .

def var i as int init 0.

case g-action:
    when 1 then do:
        for each busr where busr.cif = g-usrcif no-lock:
            if busr.id = g-usrid or can-find(shr where shr.who = g-usrid and shr.whom = busr.id use-index pk) then
                next.
            i = i + 1.
            create lst.
            buffer-copy busr to lst.
        end.
    end.
    when 2 then do:
        for each shr where shr.who = g-usrid use-index idx1 no-lock:
            i = i + 1.
            create lst.
            lst.id = shr.whom.
            find first busr where busr.id = shr.whom no-lock no-error.
            if avail busr then
                lst.login = busr.login.
        end.
    end.
    when 3 then do:
        for each busr no-lock:
            i = i + 1.
            create lst.
            buffer-copy busr to lst.
        end.
    end.
end.


if i > 0 then do:
    {itemlist.i   &start = " "
                  &file = " lst "
                  &where = " yes "
                  &frame = "row 3 centered scroll 1 15 down overlay title "" ПОЛЬЗОВАТЕЛИ """
                  &flddisp = " lst.id lst.login "
                  &chkey = " id "
                  &chtype = " int "
                  &index  = " idx1 "
                  &funadd = "."}
end. else
    message 'Подходящие учетные записи отсутвуют' view-as alert-box.

/*
find first {&file} where {&where} use-index {&index} no-lock no-error.
    display {&flddisp}
        with frame xf{&set}.
*/
