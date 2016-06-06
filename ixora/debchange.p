/* debchange.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату (с незакрытыми приходами по срокам)
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
        02/11/04 tsoy
 * CHANGES

*/

{global.i}
{debls.f}

def temp-table wrkgrp
         field grp  like debls.grp          label "GRP"
         field ls   like debls.ls           label "NN"
         field arp  like debgrp.arp.


hide all. pause 0.

update v-grp with frame get-grp-all.

find debgrp where debgrp.grp = v-grp no-lock.
displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

if v-grp <> 0 then do:
update v-ls with frame get-grp-all.
find debls where debls.grp = v-grp and debls.ls = v-ls no-lock.
displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.
end.

hide frame get-grp-all.


update v-d1 v-d2 with frame get-dates.

if v-grp = 0 then
   for each debls where debls.grp ne 0 and debls.ls ne 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock.
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls  = debls.ls
              wrkgrp.arp = debgrp.arp.
   end.
else

if v-ls = 0 then 
   for each debls where debls.grp = v-grp and debls.ls ne 0  no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock.
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls  = debls.ls
              wrkgrp.arp = debgrp.arp.
   end.
else
   for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock.
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls  = debls.ls
              wrkgrp.arp = debgrp.arp.
   end.

output to debchange.img.

put unformatted skip
                "        ИЗМЕНЕНИЯ СРОКОВ: " v-dat skip
                "        ГРУППА  : " get-grp-des (v-grp) skip
                "        ДЕБИТОР : " get-ls-name (v-grp, v-ls) skip(1).

put unformatted fill ("- ", 174) format "x(174)" skip
"| ДАТА     | ДЕБИТОР                   | ЛОГИН  |    СУММА           | СТАРЫЙ СРОК     | НОВЫЙ СРОК      |    ОСНОВАНИЕ                                                      | " skip.

for each wrkgrp.
       for each dbsrhis where dbsrhis.grp     = wrkgrp.grp      
                              and dbsrhis.ls  = wrkgrp.ls       
                              and dbsrhis.cdate >= v-d1
                              and dbsrhis.cdate <= v-d2 no-lock     break by grp by ls by cdate by ctime .

                              put unformatted 
                                   "| " dbsrhis.cdate  format "99/99/99" " | "   
                                   get-ls-name (dbsrhis.grp, dbsrhis.ls) format "x(25)" " | "   
                                   dbsrhis.cwho  format "x(6)" " | "   
                                   dbsrhis.amt format ("->>,>>>,>>>,>>9.99")   " | "   
                                   dbsrhis.oldsr format "x(15)"  " | "    
                                   dbsrhis.newsr format "x(15)"  " | "    
                                   dbsrhis.res   format "x(65)"  " | " skip. 
       end.
end. 

put unformatted fill ("- ", 174) format "x(174)" skip.

output close.
run menu-prt ("debchange.img").

