/* tltrx1_1.f
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
            tmpaal.aah format 'zzzzzzz9'
            tmpaal.ln FORMAT "zzzz"
            tmpaal.jh
            tmpaal.aax
            aax.des
            tmpaal.aaa
            tmpaal.amt format "z,zzz,zzz,zzz,zz9.99-"
            tmpaal.teller
            m-stn
            m-stsstr format "x(3)"
    header skip(1)
            with width 132 down frame aaltl no-box no-label.
