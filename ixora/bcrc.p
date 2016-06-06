/* bcrc.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2008 alex
 * BASES
        BANK
 * CHANGES
*/


def stream r-in.
def stream v-out.
def var v-tsnum     as int no-undo.
def var v-str       as char no-undo.
def var v-txt       as char no-undo.
def temp-table t-crc no-undo
    field num as int
    field str as char format "x(100)"
    index idx is primary num.

def var v-old_rate as char extent 3.
def var v-new_rate as deci extent 3.

{mainhead.i}
unix silent value('echo "" >> /data/export/currency/bcrc.js'). /* на случай если нет возврата каретки в последней строке - добавляем */

empty temp-table t-crc.
v-tsnum = 0.
v-str = "".

input stream r-in from value('/data/export/currency/bcrc.js').
repeat:
    import stream r-in unformatted v-txt.
    if v-txt ne "" then do:
        create t-crc.
        assign t-crc.num = v-tsnum
            t-crc.str = v-txt.
    end.
    v-tsnum = v-tsnum + 1.
end.
input stream r-in close.

find first t-crc where t-crc.str begins "var USD_TOD =" no-lock no-error.
if avail t-crc then v-old_rate[1] = entry(2, t-crc.str, '"').
find first t-crc where t-crc.str begins "var EUR_TOD =" no-lock no-error.
if avail t-crc then v-old_rate[2] = entry(2, t-crc.str, '"').
find first t-crc where t-crc.str begins "var RUR_TOD =" no-lock no-error.
if avail t-crc then v-old_rate[3] = entry(2, t-crc.str, '"').

form
    v-old_rate[1] label "USD_last"
    v-new_rate[1] format ">>9.9999" label "USD_new" skip
    v-old_rate[2] label "EUR_last"
    v-new_rate[2] format ">>9.9999" label "EUR_new" skip
    v-old_rate[3] label "RUR_last"
    v-new_rate[3] format ">>9.9999" label "RUR_new" skip
with frame f-nrate title "Биржевой курс" row 8 side-label centered width 40.

displ v-old_rate[1] v-old_rate[2] v-old_rate[3] with frame f-nrate.
update v-new_rate[1] v-new_rate[2] v-new_rate[3] with frame f-nrate.

message "Внимание! Биржевые курсы будут обновлены." view-as alert-box question buttons yes-no update b as logical.
if not b then do: undo, return. end.

/* displ v-old_rate[1] v-old_rate[2] v-old_rate[3] skip v-new_rate[1] v-new_rate[2] v-new_rate[3]. */

output stream v-out to bcrc.js.
put stream v-out unformatted
    "var USD_TOD = """ + trim(string(v-new_rate[1], ">>9.9999")) + """;" skip
    "var USD_YST = """ + trim(v-old_rate[1]) + """;" skip

    "var EUR_TOD = """ + trim(string(v-new_rate[2], ">>9.9999")) + """;" skip
    "var EUR_YST = """ + trim(v-old_rate[2]) + """;" skip

    "var RUR_TOD = """ + trim(string(v-new_rate[3], ">>9.9999")) + """;" skip
    "var RUR_YST = """ + trim(v-old_rate[3]) + """;" skip.
output stream v-out close.
unix silent value("cp bcrc.js /data/export/currency/").
