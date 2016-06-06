/* tltrx2.f
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
        01.02.10 marinav - расширение поля счета до 20 знаков
*/

form
 m-char
 column-label "Время"
            jl.jh
 column-label "Пров.#"
            jl.ln  FORMAT "zzzz"
 column-label "Лин"
            jl.gl
 column-label "Счет Гл.Книги "
            jl.acc format "x(20)"
 column-label "Счет "
            m-amtd at 60
 column-label "Дебет "
            m-amtk
 column-label "Кредит "
            jl.teller
 column-label "Штамп  "
            m-sts
 column-label "Ст."
            m-stsstr format "x(3)" label "Ош."
 header skip(1)
            with width 132 row 7 4 down frame jltl no-box overlay.
