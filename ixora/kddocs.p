/* kddocs.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
        Настройка списка документов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
         
 * AUTHOR
        11.01.04 marinav
 * CHANGES
      30.09.2005 marinav - изменения для бизнес-кредитов

*/

{global.i}
{pksysc.f}
{kd.i "new"}

def var v-cod as char.
define variable s_rowid as rowid.

form "ДОКУМЕНТ" skip kddocs.name VIEW-AS EDITOR SIZE 60 by 5 skip(1)
     "ТРЕБОВАНИЕ" skip kddocs.info[1] VIEW-AS EDITOR SIZE 60 by 5 
 with frame y  overlay  row 6  centered top-only no-label.

on help of kddocs.type in frame kddocs do: 
  run uni_book ("zalog", "*", output v-cod).  
  kddocs.type = entry(1, v-cod).
  displ kddocs.type with frame kddocs.
end.

on help of kddocs.fu in frame kddocs do: 
  run uni_book ("kdfu", "*", output v-cod).  
  kddocs.fu = inte(entry(1, v-cod)).
  displ kddocs.fu with frame kddocs.
end.

on help of kddocs.zaemfu in frame kddocs do: 
  run uni_book ("kdfu", "*", output v-cod).  
  kddocs.zaemfu = inte(entry(1, v-cod)).
  displ kddocs.zaemfu with frame kddocs.
end.

on help of kddocs.kb in frame kddocs do: 
  run uni_book ("kdbk", "*", output v-cod).  
  kddocs.kb = entry(1, v-cod).
  displ kddocs.kb with frame kddocs.
end.


{jabrw.i 
&start     = " "
&head      = "kddocs"
&headkey   = "ln"
&index     = "lnfutype"

&formname  = "pksysc"
&framename = "kddocs"
&where     = " "

&addcon    = "true"
&deletecon = "true"
&precreate = " "
&postadd   = "  update kddocs.ln kddocs.kb kddocs.zaemfu kddocs.fu kddocs.type 
                with scrollable frame kddocs.
                update kddocs.name kddocs.info[1] with frame y scrollable.
                hide frame y no-pause.                               
                displ kddocs.ln kddocs.fu kddocs.type kddocs.name with frame kddocs. "       
       
&prechoose = "message 'F4-Выход,INS-Вставка.'."

&postdisplay = " "

&display   = "kddocs.ln kddocs.kb kddocs.zaemfu kddocs.fu kddocs.type kddocs.name " 

&highlight = " kddocs.ln "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                              update kddocs.ln kddocs.kb kddocs.zaemfu kddocs.fu kddocs.type 
                              with scrollable frame kddocs .
                              message 'TAB - переход м/у полями, F1 - Сохранить,   F4 - Выход без сохранения'.
                              update kddocs.name kddocs.info[1] with frame y scrollable.
                              hide frame y no-pause.  displ kddocs.ln kddocs.kb kddocs.zaemfu kddocs.fu kddocs.type kddocs.name with frame kddocs.                              
                      end. "

&end = "hide frame kddocs. 
        hide frame y. "
}
hide message.


            

