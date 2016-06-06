/* grupa41.f
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

                display stream m-out aaa.lgr column-label "Группа"
                accum count by lgr dr[1] column-label "Колич."
                (m-c - m-d)
                format "z,zzz,zzz,zzz,zz9.99-" column-label "Сумма"
                m-count10000 format "zzzzzz9" column-label "Колич.>10000 KZT"
                m-atl10000
                format "z,zzz,zzz,zzz,zz9.99-" column-label "Сумма > 10000 KZT"
                crc.code column-label "ВАЛ"
                with frame c1 down.
