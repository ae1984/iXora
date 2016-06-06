/* tar_br.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Настройка тарификатора
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        tar2_br.p, tar2_b.p
 * MENU
        9-1-2-6-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.08.2004 saltanat - отменила какое-либо редактирование, удаление либо внесение данных.
                              внесла просмотр краткой истории.
                              сделала поиск.
*/

{global.i}

def new shared var stnum like tarif2.num.
def new shared var paka like tarif.pakalp.
def new shared var len as int.
def new shared var rr4 as int.
def var i as char format 'x(3)' init ''. 
def buffer ftarif for tarif.

{apbra.i

&start     = " "
&head      = "tarif"
&headkey   = "tarif"
&index     = "nr"

&formname  = "tarif"
&framename = "tarif"
&where     = "tarif.stat = 'r' and (if i <> '' then tarif.num begins i else true) "

&addcon    = "false"
&deletecon = "false"



&precreate = " "

&postadd   = " "
&prechoose = 
 " message ' F4-выход, TAB-выбор, H-история, F-поиск'."
&predisplay = " "

&display   = " tarif.num
               tarif.nr
               tarif.pakalp "

&highlight = " tarif.num tarif.nr tarif.pakalp "


&postkey   = "else if keyfunction(lastkey) = 'TAB' THEN DO on endkey undo, leave: 
               paka = tarif.pakalp. 
               stnum = tarif.num. 
               rr4 = tarif.nr. 
               len = length(num). 
               if rr4 <> 0 then RUN tar2_br. 
                           else run tar2_b. 
             end.
             else if keyfunction(lastkey) = 'H' then do on endkey undo, leave:
               displ tarif.who label 'Внес.' 
                     tarif.whn label 'Дата вн.' 
                     tarif.akswho label 'Акцепт.' 
                     tarif.akswhn label 'Дата акц.' 
               with overlay centered row 8 title 'История' frame df.
               hide frame df. 
             end. 
             else if keyfunction(lastkey) = 'F' then do on endkey undo, leave:
                 run proc_find.
 	         clin = 0. blin = 0.
	         next upper.
                 hide frame fri.
             end. 
            "

&end = "hide frame tarif."
}
hide message.

/* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# --- FIND --- #-#-#-#-#-#-#-#-#-#-#-#-#-#-# */
procedure proc_find.
update i no-label
with frame fri with overlay centered row 10 title 'Введите номер группы:'.
if i <> '' then do:
   find first ftarif where ftarif.num begins i and ftarif.stat = 'r' no-lock no-error.
   if not avail ftarif then do:
     i = ''.
     message ('Такого номера здесь нет ! ').
   end.
end. /* if */
end procedure.

