/* accdelbx.p
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Акцепт обнулений задолженностей клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 1.4.1.20.2
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def temp-table v-temp
    field aaa    as char
    field cif    as char
    field name   as char
    field rem    as char
    field whn    as date
    field crc    as char
    field sumval as deci
    field sumten as deci
    field ofc    as char
    field checks as char
    index idx is primary aaa    ascending
                         whn    ascending
                         crc    ascending
                         sumten ascending.

def buffer b-bxcif for bxcif.

def var v-acc as char.

def query q-link for bxcif, v-temp scrolling.

def browse b-link
    query q-link no-lock displ
    bxcif.delwhn    column-label "Дата!создания" format "99/99/9999"
    v-temp.crc      column-label "Вал" format "x(3)"
    bxcif.cif       column-label "Cif!код!клиен." format "x(6)"
    v-temp.name     column-label "Наименование!клиента" format "x(10)"
    bxcif.rem       label        "Примечание" format "x(15)"
    bxcif.whn       column-label "Дата!образован.!задолженн." format "99/99/9999"
    bxcif.aaa       column-label "№ счета!клиента" format "x(20)"
    bxcif.amount    column-label "Сумма!в!валюте" format ">>>9.99"
    bxcif.delchoose column-label "id!менеджер" format "x(8)"
with 12 down separators no-assign no-hide.

def frame controldel
    skip(3)
    b-link skip
    v-acc label "A - акцепт, O - отказать" format "x(1)" validate(v-acc = "A" or v-acc = "O", "Выберите < A > или < O > !!!") skip
with side-labels width 105 no-box no-hide.

def frame show
    skip(2)
    v-temp.name label "Наименование" format "x(80)" skip(1)
    bxcif.rem   label "Примечание" format "x(80)" skip(1)
with side-labels width 105.

release v-temp.
empty temp-table v-temp.

for each b-bxcif where b-bxcif.del = yes no-lock use-index delidx:
    create v-temp.
    assign
    v-temp.cif = b-bxcif.cif
    v-temp.aaa = b-bxcif.aaa
    v-temp.rem = b-bxcif.rem
    v-temp.whn = b-bxcif.whn.
    find first cif where cif.cif = b-bxcif.cif no-lock no-error.
    if avail cif then v-temp.name = trim(cif.prefix) + " " + trim(cif.name).
    if b-bxcif.del = yes then v-temp.checks = "null".
    else v-temp.checks = "".
    find first crc where crc.crc = b-bxcif.crc no-lock no-error.
    if avail crc then v-temp.crc = crc.code.
    if b-bxcif.crc <> 1 then do:
        find last crchis where crchis.crc = b-bxcif.crc and crchis.rdt <= b-bxcif.whn no-lock no-error.
        if avail crchis then v-temp.sumten = b-bxcif.amount * crchis.rate[1].
    end.
    else v-temp.sumten = b-bxcif.amount.
    v-temp.sumval = b-bxcif.amount.
end.

close query q-link.
hide browse b-link.
hide frame arrears.

open query q-link for each bxcif where bxcif.del = yes no-lock use-index delidx,
each v-temp where trim(v-temp.cif) = bxcif.cif and trim(v-temp.aaa) = trim(bxcif.aaa) and trim(v-temp.rem) = trim(bxcif.rem) and
v-temp.whn = bxcif.whn and v-temp.sumval = bxcif.amount no-lock use-index idx.

enable all with frame controldel.
browse b-link:sensitive = true.

on "return" of b-link in frame controldel do:
    apply "go" to this-procedure.
    hide frame show.
end.

on up of b-link in frame controldel do:
    GET PREV q-link.
    if avail bxcif and avail v-temp then displ v-temp.name bxcif.rem with frame show.
end.
on down of b-link in frame controldel do:
    GET NEXT q-link.
    if avail bxcif and avail v-temp then displ v-temp.name bxcif.rem with frame show.
end.

do:
    update b-link with frame controldel.
    update v-acc  with frame controldel.
end.

do transaction on error undo, retry:
    if v-acc = "A" then do:
        for each v-temp no-lock use-index idx, each bxcif where trim(bxcif.cif) = trim(v-temp.cif) and
        trim(bxcif.aaa) = trim(v-temp.aaa) and trim(bxcif.rem) = trim(v-temp.rem) and bxcif.whn = v-temp.whn and
        bxcif.amount = v-temp.sumval exclusive-lock use-index delidx:
            if bxcif.delchoose <> g-ofc and v-temp.checks = "null" then do:
                create hisdelbxcif.
                assign
                hisdelbxcif.cif         = bxcif.cif
                hisdelbxcif.aaa         = bxcif.aaa
                hisdelbxcif.amount      = bxcif.amount
                hisdelbxcif.whn         = bxcif.whn
                hisdelbxcif.period      = bxcif.period
                hisdelbxcif.crc         = bxcif.crc
                hisdelbxcif.rem         = bxcif.rem
                hisdelbxcif.delchoose   = bxcif.delchoose
                hisdelbxcif.delaccept   = g-ofc
                hisdelbxcif.dtdel       = g-today
                hisdelbxcif.timedel     = string(time, "HH:MM:SS").

                delete bxcif.
            end.
            else if bxcif.delchoose = g-ofc and v-temp.checks = "null" then do:
                message "Вы не можете акцептовать эту запись. Клиент - " bxcif.cif ", счет - " bxcif.aaa ", дата - " bxcif.whn
                ", сумма - " bxcif.amount view-as alert-box buttons ok.
            end.
        end.
    end.
end.

enable all with frame controldel.
apply "endkey" to frame controldel.
wait-for "endkey" of frame controldel focus b-link in frame controldel.
return.