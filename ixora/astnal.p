/* astnal.p
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

/* astnal.p
~*/
define shared var v-god as integ format "zzz9".
define var otv as logical .
define new shared var s-astnal as integ.

{mainhead.i}

{astnal.f}
 hide frame astg. pause 0.
{jabrw.i 
&head = "astnal"
&headkey = "astnal"
&index = "ggr" 
&where = "astnal.god = v-god  "  
&addcon = "true"
 &prechoose = "message color normal
' <Enter>-просмотр,редактирование,  <1> - перенос информации из операций, '      
'  <Insert> - новая запись,  <F10> - удаление записи,  <F4>-izeja '.
               
      "  
 
&predisplay = " "        

&deletecon = "true"
&start = " "
&formname = "astnal"
&framename = "astnal"
&postadd = "  hide message no-pause.
              message color normal
              '       <Enter>-ievads <F1>-saglab–t <F4>-atteikties'.
                astnal.god =v-god.
                update astnal.nrst astnal.grup  astnal.ast 
                       astnal.amn astnal.ston
                with frame astnal."
                                                                                  update  tarifs.dat tarifs.tarifs with frame tarifs."
&display   = " astnal.nrst astnal.grup  astnal.ast   
               astnal.amn astnal.ston astnal.stok  "    
              
&highlight = "astnal.nrst astnal.grup  astnal.ast  
               astnal.amn astnal.ston astnal.stok  " 
&postkey = "else if keyfunction(lastkey) = 'Return' then do: 
              s-astnal = recid(astnal).
               
               hide frame astnal no-pause.     
               run astned. 
               find astnal where recid(astnal) = s-astnal no-lock no-error.                
                   displ astnal.nrst astnal.grup  astnal.ast   
                       astnal.amn astnal.ston astnal.stok  
                            with frame astnal.
              next upper. 
                    
            end. 
            else if keyfunction(lastkey) = '1' then do: 
              s-astnal=recid(astnal).
               
               hide frame astnal no-pause.     
              
               run astnper. 
                
               find astnal where recid(astnal) = s-astnal no-lock no-error.
                
               displ astnal.nrst astnal.grup  astnal.ast   
                     astnal.amn astnal.ston astnal.stok  
                         with frame astnal.
              next upper.
             End."
&end = "hide message no-pause. hide frame astnal. "

}

