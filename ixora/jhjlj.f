/* jhjlj.f
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

form jh.jh jh.jdt jh.who
     with overlay row 3  col 1 no-label
          title "Опер.Nr. Дата     Исполн. "
          frame jh.
form vbal label "ОСТ"
     with overlay row 6 no-box side-label
          frame bal.
form vdam label "Д " space(0) vcam label "К "
     with overlay row 6 col 30 no-box side-label
          frame tot.
form jh.cif jh.party space(10) jh.crc
     with overlay row 3 col 29 width 52 no-label
     title "    #                                         Вал "
          frame party.
form  space(1)
     jl.ln form "999"
     jl.gl
     gl.sname
     jl.crc
     jl.acc skip space(32) 
     jl.dam 
     jl.cam
     with  row 7 width 80 4
      down no-label title
"Nr. Счет   Название             " +
"   Субсчет   #  Дебет               Кредит "
          frame jl.
form jl.rem[1] format "x(71)" label "Описан." skip
     jl.rem[2] label "" colon 8 "              " skip
     jl.rem[3] label "" colon 8 "              " skip
     jl.rem[4] label "" colon 8 "              " skip
     jl.rem[5] label "" colon 8 "              " skip
     with overlay row 17 no-box side-label frame rem.
