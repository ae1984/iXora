/* tlatrx2.f
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

form
 m-char
 column-label "Время"
            jl.who
 column-label "Исполн."
            jl.jh
 column-label "Пров.#"
            jl.ln
 column-label "Лин"
            jl.gl
 column-label "Балансов.счет" 
            jl.acc at 65
 column-label "Счет "
            m-amtd
 column-label "Дебет "
            m-amtk
 column-label "Кредит "
            jl.teller
 column-label "Акцепт "
            jh.sts
 column-label "СТС"
 header skip(1)
            with down frame jltl no-box overlay.
