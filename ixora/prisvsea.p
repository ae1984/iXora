/* prisvsea.p
 * MODULE
        Особые отношения
 * DESCRIPTION
        Поиск по базе
 * BASES
        BANK COMM
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
        30/04/2008 alex
 * CHANGES
        07/05/2008 alex - добавил COMM
        13/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН

*/

{mainhead.i}
{chbin.i}

def var v-rnn as char.
def var v-name as char.
def var krit as char.

define frame f
    v-rnn label  "РНН............." format "x(12)" skip
    v-name label "Наименование/ФИО" format "x(200)" view-as fill-in size 50 by 1 skip
with side-labels row 12 overlay centered.

define frame fbin
    v-rnn label  "ИИН/БИН........." format "x(12)" skip
    v-name label "Наименование/ФИО" format "x(200)" view-as fill-in size 50 by 1 skip
with side-labels row 12 overlay centered.

procedure rdisp.
if v-bin then
 display prisv.rnn label "ИИН/БИН..........." skip
    prisv.name label    "Наименование/ФИО " skip
    prisv.specrel label "Признак.........." skip
    codfr.name[1] label "Описание признака" format "x(2000)" view-as editor size 70 by 5 skip
    with side-label row 12 centered title "Результат поиска" overlay width 92 frame f1bin.
else display prisv.rnn label "РНН.............." skip
    prisv.name label    "Наименование/ФИО " skip
    prisv.specrel label "Признак.........." skip
    codfr.name[1] label "Описание признака" format "x(2000)" view-as editor size 70 by 5 skip
    with side-label row 12 centered title "Результат поиска" overlay width 92 frame f1.
end.

procedure rhist.
    create svhist.
    assign svhist.rwho = g-ofc
        svhist.rdt = today
        svhist.rtm = time
        svhist.oprt = krit
        svhist.toprt = "sea".
end.

repeat:
    v-rnn = "".
    v-name = "".

    if v-bin then do:
        update v-rnn v-name with frame fbin.
        hide frame fbin.
    end. else do:
        update v-rnn v-name with frame f.
        hide frame f.
    end.
        if v-rnn ne "" then do:
            find first prisv where prisv.rnn = v-rnn no-error.
                if avail(prisv) then do:
                    find first codfr where codfr.code = prisv.specrel no-lock.
                    krit = "rnn|" + v-rnn + "|+".
                    run rdisp.
                    run rhist.
                end.
                else do:
                    krit = "rnn|" + v-rnn + "|-".
                    message "нет данных" view-as alert-box buttons ok.
                    run rhist.
                end.
        end.
        else if v-name ne "" then do:
            find first prisv where prisv.name matches "*" + v-name + "*" no-error.
                if avail(prisv) then do:
                    find first codfr where codfr.code = prisv.specrel.
                    krit = "name|" + v-name + "|+".
                    run rdisp.
                    run rhist.
                end.
                else do:
                    krit = "name|" + v-name + "|-".
                    message "нет данных" view-as alert-box buttons ok.
                    run rhist.
                end.
        end.
        else message "нет ключевых слов для поиска" view-as alert-box buttons ok.
end.