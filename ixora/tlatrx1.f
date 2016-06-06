/* tlatrx1.f
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
            aal.who
    column-label "Исполн."
            aal.aah format 'zzzzzzz9'
    column-label "ИПР"
            aal.ln
    column-label "Лин"
            aal.jh
    column-label "Пров.#"
            aal.aax
    column-label "Код опер."
            aax.des
    column-label "Операция "
            aal.aaa
    column-label "Счет "
            m-amtd format "z,zzz,zzz,zzz,zz9.99-"
    column-label "Дебет "
            m-amtk format "z,zzz,zzz,zzz,zz9.99-"
    column-label "Кредит "
            aal.teller
    column-label "Акцепт "
            aah.stn
    column-label "СТС"
    header skip(1)
            with  down frame aaltl no-box  .
