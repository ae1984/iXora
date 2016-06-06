/* jhjl.f
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
        29.04.2004 nadejda - увеличен формат вывода строк комментариев
        24.11.09 marinav - увеличена форма
        12/07/2012 Luiza - добавила переменную v-rmzdoc в frame party
        19/07/2012 Luiza - увеличила формат jh.party format "x(20)" в фрейме party
*/


def {1} shared frame jh.
def {1} shared frame bal.
def {1} shared frame tot.
def {1} shared frame party.
def {1} shared frame jl.
def {1} shared frame rem.
def var v-rmzdoc as char init "".

form {2}jh.jh {2}jh.jdt {2}jh.who
     with overlay row 3  col 1 no-label
          title "НОМ-ОПЕР ОПР-ДАТ. ИСПОЛН. "
          frame jh.
form vbal label "ОСТ"
     with overlay row 6 no-box side-label
          frame bal.
form vdam label "DR" space(7) vcam label "CR"
     with overlay row 6 col 30 no-box side-label
          frame tot.
form {2}jh.cif {2}jh.party format "x(20)" space(10) v-rmzdoc format "x(20)" space(10) {2}jh.crc
     with overlay row 3 col 29 width 72 no-label
     title "КЛИЕНТ                                                            ВАЛ "
          frame party.
form  space(1)
     {2}jl.ln form "99"
     {2}jl.gl
     gl.sname
     {2}jl.crc
     {2}jl.acc format "x(20)"
     {2}jl.dam
     {2}jl.cam
     with  row 8 width 102 8 down no-label title " ЛН  Г/К     НАЗВАНИЕ СЧЕТА    ВАЛ        СУБСЧЕТ                  ДЕБЕТ                 КРЕДИТ   "
          frame jl.

form {2}jl.rem[1] format "x(90)" label "ОПИСАН." skip
     {2}jl.rem[2] format "x(90)" label "" colon 8 skip
     {2}jl.rem[3] format "x(90)" label "" colon 8 skip
     {2}jl.rem[4] format "x(90)" label "" colon 8 skip
     {2}jl.rem[5] format "x(90)" label "" colon 8 skip
     with overlay row 20 width 105 no-box side-label frame rem.
