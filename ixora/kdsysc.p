/* kdsysc.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Настройка параметров кредитного досье
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-4-1 
 * AUTHOR
        03.12.03 marinav
 * CHANGES
        30/04/2004 madiar - изменил pksysc на sysc
*/

{global.i}
{pksysc.f}
{kd.i "new"}

/*for each sysc where sysc.sysc = "" . 
 delete sysc . 
end.*/

form sysc.chval format "x(312)"
 with frame y  overlay  row 14  centered top-only no-label.

define variable s_rowid as rowid.


{jabrw.i 
&start     = " "
&head      = "sysc"
&headkey   = "sysc"
&index     = "sysc"

&formname  = "pksysc"
&framename = "kdsysc"
&where     = " sysc.stc = 'kd_stc' "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  sysc.stc = 'kd_stc'.
                update sysc.sysc sysc.des sysc.daval sysc.deval
                sysc.inval sysc.loval with frame kdsysc .
                update sysc.chval with frame y. "
            
       
&prechoose = "message 'F4-Выход,INS-Вставка.'."

&postdisplay = " "

&display   = "sysc.sysc sysc.des sysc.daval sysc.deval
              sysc.inval sysc.loval " 

&highlight = " sysc.sysc sysc.des  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update sysc.sysc sysc.des sysc.daval sysc.deval
                              sysc.inval sysc.loval with frame kdsysc .
                              update sysc.chval with frame y scrollable.
                              hide frame y no-pause. 
                      end. "

&end = "hide frame pksysc. 
         hide frame y."
}
hide message.


            

