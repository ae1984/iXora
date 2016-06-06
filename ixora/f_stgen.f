/* f_stgen.f
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
    stml.active  no-label
    stml.seq  	 label "Nr." 
    stml.d_from  label "С"   
    stml.d_to    label "По"
    stml.sts     label "Стс"
    stml.who     label "Исполн."
    stml.whn     label "Когда"
with 10 down title "Доступные выписки" overlay row 7 column 25 frame f_stgen.	
