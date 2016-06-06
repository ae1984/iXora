/* fproc.f
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
        06.10.2003 nadejda  - изменила формат вывода (побольше символов для кода процесса)
*/

form 
    fproc.pid column-label "КОД" format "x(8)" 
    fproc.des format "x(35)"
    column-label "   Описание         " 
    fproc.sname column-label "Краткое имя"
    fproc.nprc format "x(15)" column-label "Программа"
    fproc.tout column-label "Пауза"
    with centered row 4 down frame fproc .
