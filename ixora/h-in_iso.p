/* h-in_iso.p
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

/*  h-aaa.p  - просмотр счетов одного клиента
    14/02/95 - AGA
    20/08/98 - Changed By ANRI
*/

DEF shared var s-cif like cif.cif.


{global.i}
{itemlist.i
       &file = "codfr"
       &where = "codfr EQ 'iso3166'"
       &frame = "row 4 column 30 scroll 1 12 down overlay "
       &findadd = " "
       &flddisp = "codfr.code label 'Код' codfr.name[1] label 'Страна'"
       &chkey = "code"
       &chtype = "string"
       &index  = "cdco_idx"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
