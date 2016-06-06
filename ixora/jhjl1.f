/* jhjl1.f
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
*/

/* jhjl.f
*/

def {1} shared frame jh.
def {1} shared frame bal.
def {1} shared frame tot.
def {1} shared frame party.
def {1} shared frame jl.
def {1} shared frame rem1.
def {1} shared frame rem.

form {2}jh.jh {2}jh.jdt {2}jh.who
     with overlay row 3  col 1 no-label
          title "НОМ-ОПЕР ОПР-ДАТ. ИСПОЛН. "
          frame jh.
form vbal label "ОСТ"
     with overlay row 6 no-box side-label
          frame bal.
form vdam label "DR" space(0) vcam label "CR"
     with overlay row 6 col 30 no-box side-label
          frame tot.
form {2}jh.cif {2}jh.party space(10) {2}jh.crc
     with overlay row 3 col 29 width 52 no-label
     title "КЛИЕНТ                                        ВАЛ "
          frame party.
form  space(1)
     {2}jl.ln form "999"
     {2}jl.gl
     gl.sname
     {2}jl.crc
     {2}jl.acc skip space(32) 
     {2}jl.dam 
     {2}jl.cam
     with  row 7 width 80 4
      down no-label title
"ЛНO Г/К КТ  НАЗВАНИЕ СЧЕТА     В" +
"АЛ   СУБСЧЕТ#  ДЕБЕТ              КРЕДИТ"
          frame jl.
form vrem[1] format "x(71)" label "ОПИСАН." skip
     vrem[2] label "" colon 8 "              " skip
     vrem[3] label "" colon 8 "              " skip
     vrem[4] label "" colon 8 "              " skip
     vrem[5] label "" colon 8 "              " skip
     with overlay row 17 no-box side-label frame rem1.

form jl.rem[1] format "x(71)" label "ОПИСАН." skip
     jl.rem[2] label "" colon 8 "              " skip
     jl.rem[3] label "" colon 8 "              " skip
     jl.rem[4] label "" colon 8 "              " skip
     jl.rem[5] label "" colon 8 "              " skip
     with overlay row 17 no-box side-label frame rem.
