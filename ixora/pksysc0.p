/* pksysc0.p
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Редактирование общего банковского справочника
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
 * BASES
        BANK COMM
 * CHANGES
        11/10/2011 madiyar - скопировал из pksysc.p с изменениями
*/

{mainhead.i}

define new shared var s-credtype as char.
s-credtype = '0'.

do transaction:
    for each pksysc where pksysc.sysc = "".
        delete pksysc.
    end.
end.

form pksysc.chval format "x(312)" with frame y overlay row 14 centered top-only no-label.

define variable s_rowid as rowid.
def var v-ans as logical.

{jabrw.i
&start     = " "
&head      = "pksysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "pksysc"
&framename = "pksysc"
&where     = " pksysc.credtype = s-credtype "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  pksysc.credtype = s-credtype.
                update pksysc.sysc pksysc.des pksysc.daval pksysc.deval
                pksysc.inval pksysc.loval pksysc.general with frame pksysc .
                update pksysc.chval with frame y. "


&prechoose = "message 'F4-Выход,INS-Вставка,P-Печать.'."

&postdisplay = " "

&display   = "pksysc.sysc pksysc.des pksysc.daval pksysc.deval
              pksysc.inval pksysc.loval pksysc.general"

&highlight = " pksysc.sysc pksysc.des  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                    then do:
                        update pksysc.sysc pksysc.des pksysc.daval pksysc.deval
                        pksysc.inval pksysc.loval pksysc.general with frame pksysc .
                        update pksysc.chval with frame y scrollable.
                        hide frame y no-pause.
                    end.
                    else
                    if keyfunction(lastkey) = 'P' then do:
                        s_rowid = rowid(sysc).
                        output to pksysc.img.
                        for each pksysc no-lock:
                            display pksysc.sysc pksysc.des pksysc.daval pksysc.deval pksysc.inval pksysc.loval pksysc.chval.
                        end.
                        output close.
                        output to terminal.
                        run menu-prt('pksysc.img').
                        find pksysc where rowid(pksysc) = s_rowid no-lock.
                    end. "

&end = "hide frame pksysc.
hide frame y."
}
hide message.


