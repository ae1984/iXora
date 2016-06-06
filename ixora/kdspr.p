/* kdspr.p 

 * MODULE
      Электронное кредитное досье
 * DESCRIPTION
        Настройка параметров для фин отчетности
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-4-2  
 * AUTHOR
        29.12.03 marinav
 * CHANGES
      30.09.2005 marinav - изменения для бизнес-кредитов
*/

{global.i}
{pksysc.f}
{kd.i "new"}

for each kdspr where kdspr.nom = "" . 
 delete kdspr . 
end.

define variable s_rowid as rowid.

{jabrw.i 
&start     = " "
&head      = "kdspr"
&headkey   = "nom"
&index     = "nom"

&formname  = "pksysc"
&framename = "kdspr"
&where     = " kdspr.nom begins 'z' "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  update kdspr.nom kdspr.name with frame kdspr . "
            
       
&prechoose = "message 'F4-Выход,INS-Вставка.'."

&postdisplay = " "

&display   = " kdspr.nom kdspr.name " 

&highlight = " kdspr.nom kdspr.name  "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update kdspr.nom kdspr.name with frame kdspr .
                      end. "

&end = "hide frame kdspr."
}
hide message.


            


