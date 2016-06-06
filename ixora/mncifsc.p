/* mncifsc.p
 * MODULE
       Настройка ограничения доступов на просмотр клиентов
 * DESCRIPTION

 * RUN

 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
        31/08/2004 dpuchkov
 * CHANGES
        01.09.2004 dpuchkov - отображение логинов только для определённого клиента.
*/


def shared var s-cif like cif.cif.
def var str_p as char.
define frame getlist1
/* cifsec.cif label "Клиент" skip */
cifsec.ofc label "Логины офицеров" skip
with side-labels centered row 8.

{yes-no.i}
{global.i}

DEFINE QUERY q1 FOR cifsec.

define buffer buf for cifsec.

def browse b1
     query q1 
     displ 
     cifsec.ofc label "  " format "x(25)"
     with 7 down title s-cif overlay.


/* DEFINE BUTTON bedt LABEL "См.\Изм.".        */
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 
     skip
     bnew
/*   bedt */
     bdel
     bext with centered overlay row 5 top-only.  


ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bdel IN FRAME fr1
do:
   if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
   then do:
      find buf where rowid (buf) = rowid (cifsec) exclusive-lock.
      delete buf.
      close query q1.
      open query q1 for each cifsec where cifsec.cif = s-cif.
      browse b1:refresh().
   end.
end.

/*
ON CHOOSE OF bedt IN FRAME fr1
do:
   find buf where rowid (cifsec) = rowid (buf) exclusive-lock.
   update cifsec.ofc with frame getlist1.

   close query q1.
   open query q1 for each cifsec.
   browse b1:refresh().
end.
*/

ON CHOOSE OF bnew IN FRAME fr1
do:
   create cifsec.

   update cifsec.ofc with frame getlist1.
          cifsec.cif = s-cif.

   close query q1.
   open query q1 for each cifsec where cifsec.cif = s-cif.
   browse b1:refresh().
end.


open query q1 for each cifsec where cifsec.cif = s-cif. 


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

