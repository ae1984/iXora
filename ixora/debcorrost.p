/* debcorrost.p
 * MODULE
        привязка проводки к дебитору
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
 * BASES
        BANK
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24/07/2012 Luiza
 * CHANGES
                25/07/2012 Luiza  - добавила проверку с таблицей remdeb.
                26/07/2012 Luiza  - при запросе дебиторов не показывать закрытые and debls.sts <> "C"

*/


{mainhead.i}

def var v-amt as deci .
def var v-jh as int .
def var v-grp as int .
def var v-ls as int .
def var v-date as date .
def var v-rmz as char .
def var v-who as char .
def var v-arp as char .
def var v-yes as logic format "да/нет" no-undo.

form
    skip
    v-jh label   " Номер проводки  " format "zzzzzzzzz" validate (can-find(first jh where jh.jh = v-jh no-lock),"Неверный номер проводки") skip
    v-grp label  " Код группы      " validate (can-find(first debgrp where debgrp.grp = v-grp no-lock),"Неверный код группы") skip
    v-ls label   " Код дебитора    "  validate (can-find(first debls where debls.grp = v-grp and debls.ls = v-ls no-lock),"Неверный код дебитора") skip
    v-yes label  " Выполнить?      " skip
    WITH  SIDE-LABELS column 5 ROW 7 TITLE "Данные для привязки дебитора" width 50 FRAME qqq.

DEFINE QUERY q-grp FOR debgrp.
DEFINE BROWSE b-grp QUERY q-grp
       DISPLAY debgrp.grp label "Код группы " format "zzz" debgrp.des label "Наименование   " format "x(50)"
       WITH  15 DOWN.
DEFINE FRAME f-grp b-grp  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 25 width 75 NO-BOX.

DEFINE QUERY q-ls FOR debls.
DEFINE BROWSE b-ls QUERY q-ls
       DISPLAY debls.ls label "Код группы " format "zzz" debls.name label "Наименование   " format "x(50)"
       WITH  15 DOWN.
DEFINE FRAME f-ls b-ls  WITH overlay 1 COLUMN SIDE-LABELS row 11 COLUMN 25 width 75 NO-BOX.

/*on help of v-grp in frame qqq do:
    OPEN QUERY  q-grp FOR EACH debgrp no-lock.
    ENABLE ALL WITH FRAME f-grp.
    wait-for return of frame f-grp
    FOCUS b-grp IN FRAME f-grp.
    v-grp = debgrp.grp.
    hide frame f-grp.
    displ v-grp with frame qqq.
end.
on help of v-ls in frame qqq do:
    OPEN QUERY  q-ls FOR EACH debls where debls.grp = v-grp no-lock.
    ENABLE ALL WITH FRAME f-ls.
    wait-for return of frame f-ls
    FOCUS b-ls IN FRAME f-ls.
    v-ls = debls.ls.
    hide frame f-ls.
    displ v-ls with frame qqq.
end.*/


update v-jh /*v-grp v-ls*/ with frame qqq.


find first jh where jh.jh = v-jh no-lock.
find first jl where jl.jh = v-jh no-lock. /*209477 */
if not available jl then do:
    message "Не найдена запись в таблице проводок!" view-as alert-box.
    return.
end.
v-rmz = trim(jh.ref).
v-date = jh.jdt.
v-who = jh.who.
v-amt = jl.dam.
find first remdeb where remdeb.remtrz = v-rmz no-lock no-error.
v-grp = remdeb.grp.
v-ls = remdeb.ls.
displ v-grp v-ls with frame qqq.
pause 0.

    OPEN QUERY  q-grp FOR EACH debgrp WHERE debgrp.grp > 0 no-lock.
    ENABLE ALL WITH FRAME f-grp.
    wait-for return of frame f-grp
    FOCUS b-grp IN FRAME f-grp.
    v-grp = debgrp.grp.
    hide frame f-grp.
    displ v-grp with frame qqq.
    PAUSE 0.
    OPEN QUERY  q-ls FOR EACH debls where debls.grp = v-grp and debls.ls > 0 and debls.sts <> "C"  no-lock.
    ENABLE ALL WITH FRAME f-ls.
    wait-for return of frame f-ls
    FOCUS b-ls IN FRAME f-ls.
    v-ls = debls.ls.
    hide frame f-ls.
    displ v-ls with frame qqq.
if v-amt <> 0 then v-arp = jl.acc.
else do:
    message "Проводка погашения" view-as alert-box.
    return.
end.
if v-grp <> remdeb.grp or v-ls <> remdeb.ls  then do:
    message "Выбранные коды группы и дебитора не совпадают с кодами проводки!" view-as alert-box.
    return.
end.
find first debgrp where debgrp.grp = v-grp and debgrp.arp = v-arp no-lock no-error.
if not available debgrp then do:
    message "АРП счет проводки не совпадает с АРП счетом выбранной группы дебитора" view-as alert-box.
    return.
end.
/*открытие*/
find first debop where debop.jh = v-jh no-lock no-error.
if available debop then do:
    message "Данная проводка уже привязана" view-as alert-box.
    return.
end.
v-yes  = false.
update v-yes with frame qqq.
if v-yes then do:
    find first debls where debls.grp = v-grp and debls.ls = v-ls .


    create debhis.
    assign debhis.date   = v-date
           debhis.dwhn   = v-date
           debhis.grp    = v-grp
           debhis.ls     = v-ls
           debhis.amt    = v-amt
           debhis.dost   = v-amt
           debhis.ost    = debls.amt + v-amt
           debhis.ofc    = v-who
           debhis.ctime  = 11111
           debhis.rem[1] = v-rmz
           debhis.rem[2] = ''
           debhis.rem[3] = ''
           debhis.jh     = v-jh
           debhis.djh    = v-jh
           debhis.dactive = yes
           debhis.type = 1.
           debhis.dtime = 11111.



    debls.amt = debhis.ost.

    create debop.
    assign debop.date = v-date
           debop.ctime = 11111
           debop.grp = v-grp
           debop.ls = v-ls
           debop.who = v-who
           debop.amt = v-amt
           debop.ost = v-amt
           debop.type = 1
           debop.closed = no
           debop.cdt = ?
           debop.jh = v-jh.

       debop.period = 'month0'.
       debop.attn = '100'.

    message "Привязка завершена" view-as alert-box.
end.