/* h-period.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Выбор периода (применяется при выборе срока дебитора)
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
        suchkov - добавил номер
*/


def shared var g-lang as char.

{itemlist.i   &start = " "
              &file = "codfr"
              &where = " codfr.codfr = 'debsrok' and codfr.code <> 'msc' "
              &frame = "row 3 centered scroll 1 8 down overlay
                        title "" ВЫБЕРИТЕ КОД - СРОК ДЕБИТОРА "" "
              &flddisp = " codfr.name[2] format 'x(1)' label 'N' codfr.name[1] label 'Наименование' code label 'Код' "
              &chkey = "code"
              &chtype = "string"
              &index  = "cdco_idx"
              &funadd = "if frame-value = "" "" then
                             do:
                                {imesg.i 9205}.
                                pause 1.
                                next.
                             end."
                             }
