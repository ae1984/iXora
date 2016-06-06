/* obnul.p
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Обнуление задолженностей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 1.4.1.20.1
 * AUTHOR
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        02.12.2011 damir - перекомпиляция
*/

{mainhead.i}

def var v-cif     like cif.cif.
def var v-cifname as char.
def var v-accept  as char.
def var phand     as handle.
def var titl      as char init "ВЫБЕРИТЕ ЗАДОЛЖЕННОСТЬ".

def buffer b-bxcif for bxcif.

def temp-table v-temp
    field aaa    as char
    field cif    as char
    field rem    as char
    field whn    as date
    field crc    as char
    field sumten as deci
    field checks as char
    index idx is primary aaa    ascending
                         whn    ascending
                         crc    ascending
                         sumten ascending.

def query q-link for bxcif, v-temp scrolling.

def browse b-link
    query q-link no-lock displ
    v-temp.crc      column-label "Валюта" format "x(3)"
    bxcif.rem       label        "Примечание" format "x(25)"
    bxcif.whn       column-label "Дата!образования!задолженности" format "99/99/9999"
    bxcif.aaa       label        "№ счета клиента" format "x(20)"
    bxcif.amount    column-label "Сумма в!валюте" format ">>>>>9.99"
    v-temp.sumten   column-label "Сумма в!тенге" format ">>>>>9.99"
    v-temp.checks   column-label "Необходимо!отметить" format "x(4)"
with 12 down separators no-assign no-hide.

def frame cif
    v-cif     label "Код клиента" format "x(6)" validate(can-find(cif where cif.cif = v-cif), "Клиент не найден !!! Попробуйте еще раз !") help "Нажмите клавишу (F2) для быстрого поиска клиента !!!" skip
    v-cifname label "Наименование клиента" format "x(60)" skip(2)
with side-labels width 104 title "ОБНУЛЕНИЕ ЗАДОЛЖЕННОСТИ ПО СЧЕТАМ КЛИЕНТА".

def frame arrears
    skip(1)
    b-link skip(2)
    v-accept label "Выберите (D) - обнулить" format "x(1)" validate(v-accept = "D", "Выберите < D > !!! ") skip(1)
with side-labels width 105 no-box no-hide.

def frame show
    skip(1)
    bxcif.rem   label "Примечание" format "x(80)" skip(1)
with side-labels width 104.

hide frame show.
hide frame cif.
close query q-link.
hide browse b-link.
hide frame arrears.

on help of v-cif in frame cif do:
    hide message. pause 0.
    run h-cif persistent set phand.
    v-cif = frame-value.
    displ v-cif with frame cif.
    delete procedure phand.
end.

update v-cif with frame cif.

find first cif where cif.cif = v-cif  no-lock no-error.
if avail cif then do:
    v-cifname = trim(cif.prefix) + " " + trim(cif.name).
    displ v-cifname with frame cif.
end.

hide message. pause 0.

release v-temp.
empty temp-table v-temp.

for each b-bxcif where b-bxcif.cif = v-cif no-lock use-index delidx:
    create v-temp.
    assign
    v-temp.cif = b-bxcif.cif
    v-temp.aaa = b-bxcif.aaa
    v-temp.rem = b-bxcif.rem
    v-temp.whn = b-bxcif.whn.
    if b-bxcif.del = yes then v-temp.checks = "null".
    else v-temp.checks = "".
    find first crc where crc.crc = b-bxcif.crc no-lock no-error.
    if avail crc then v-temp.crc = crc.code.
    if b-bxcif.crc <> 1 then do:
        find last crchis where crchis.crc = b-bxcif.crc and crchis.rdt <= b-bxcif.whn no-lock no-error.
        if avail crchis then v-temp.sumten = b-bxcif.amount * crchis.rate[1].
    end.
    else v-temp.sumten = b-bxcif.amount.
end.

find first cif where cif.cif = v-cif  no-lock no-error.

find first bxcif where trim(bxcif.cif) = trim(cif.cif) no-lock no-error.
if not avail bxcif then do:
    message "У данного клиента не имеется задолженности !!!" view-as alert-box.
    apply "endkey" to frame arrears.
end.

close query q-link.
hide browse b-link.
hide frame arrears.

open query q-link for each bxcif where trim(bxcif.cif) = trim(cif.cif) no-lock use-index delidx,
each v-temp where trim(v-temp.aaa) = trim(bxcif.aaa) and trim(v-temp.rem) = trim(bxcif.rem) and v-temp.whn = bxcif.whn no-lock
use-index idx.

enable b-link with frame arrears.
browse b-link:sensitive = true.

on "insert" of b-link in frame arrears do:
    update v-temp.checks = "null".
    displ v-temp.checks with browse b-link.
end.

on "delete" of b-link in frame arrears do:
    update v-temp.checks = "".
    displ v-temp.checks with browse b-link.
end.

on "return" of b-link in frame arrears do:
    apply "go" to frame arrears.
    hide frame show.
end.

on up of b-link in frame arrears do:
    GET PREV q-link.
    if avail bxcif then displ bxcif.rem with frame show.
end.
on down of b-link in frame arrears do:
    GET NEXT q-link.
    if avail bxcif then displ bxcif.rem with frame show.
end.

message ("Чтобы отметить запись нажмите клавишу < INSERT >, а чтобы удалить запись нажмите клавишу < DELETE > ! ").
message ("После того, как отметили нужные записи, нажмите < Enter > и выберите букву < D > (англ.) !").
update b-link with frame arrears.

do transaction on error undo, retry:
    hide message. pause 0.
    update v-accept with frame arrears.
    displ  v-accept with frame arrears.
    if v-accept = "D" then do:
        for each v-temp no-lock use-index idx, each bxcif where trim(bxcif.aaa) = trim(v-temp.aaa) and
        trim(bxcif.rem) = trim(v-temp.rem) and bxcif.whn = v-temp.whn exclusive-lock use-index delidx:
            if v-temp.checks = "null" then do:
                assign
                bxcif.del       = yes
                bxcif.delchoose = g-ofc
                bxcif.delwhn    = g-today.
            end.
            else do:
                assign
                bxcif.del       = no
                bxcif.delchoose = ""
                bxcif.delwhn    = ?.
            end.
        end.
    end.
end.

enable all with frame arrears.
apply "endkey" to frame arrears.
wait-for "endkey" of frame arrears focus b-link in frame arrears.
apply "close" to this-procedure.
return.






