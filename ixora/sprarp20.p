/* sprarp20.p
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{global.i}

define query qc for sprarp20.
define browse bc query qc
       displ
             sprarp20.acc9
             sprarp20.acc20 
             sprarp20.who 
             sprarp20.whn 
             with centered no-label row 2 25 down no-box.
define frame fc 
"  Старый счет           Новый счет          Менеджер  Дата" skip
"  -------------------- -------------------- -------- -----------" skip
bc help "F4 - Конец, ENTER - Изменить, F1 - Создать"
with row 4 no-label title "   Соответствие 9-зн. и 20-зн. ARP счетов   " centered.


define buffer b-arp for arp.
 
define frame getkont
             sprarp20.acc9  label "Старый счет" 
                      validate (can-find(first arp where arp.arp = sprarp20.acc9), "Старый счет не найден в базе!") skip
             sprarp20.acc20 label "Новый счет" 
                      validate (can-find(first arp where arp.arp = sprarp20.acc20) , "Новый счет не найден в базе!") skip
             with centered row 4 side-labels
             1 column.

on "go" of browse bc
do:
   create sprarp20.
   update sprarp20.acc9 sprarp20.acc20 with frame getkont.
   hide frame getkont.
   sprarp20.whn = g-today.
   sprarp20.who = g-ofc.
   close query qc. 
   open query qc for each sprarp20 no-lock.
   browse bc:refresh().
end.


on "return" of browse bc
do:
   if avail sprarp20 then do:
       find current sprarp20 exclusive-lock.
       update sprarp20.acc9 sprarp20.acc20 with frame getkont.
       hide frame getkont.
       sprarp20.whn = g-today.
       sprarp20.who = g-ofc.
       release sprarp20.
       close query qc. 
       open query qc for each sprarp20 no-lock.
       browse bc:refresh().
   end.
end.

on 'end-error' of browse bc do:
    for each sprarp20 no-lock.
      find arp where arp.arp = sprarp20.acc9 no-lock no-error.
      find b-arp where b-arp.arp = sprarp20.acc20 no-lock no-error.
      if avail arp and avail b-arp then do:
         if arp.crc ne b-arp.crc then do:
            message "Несоответствие валют счетов " arp.arp " и " b-arp.arp  view-as alert-box.
         end.
         if arp.gl ne b-arp.gl then do:
            message "Несоответствие ГК счетов " arp.arp " и " b-arp.arp  view-as alert-box.
         end.
      end.
    end.
    hide frame fc.
end.

open query qc for each sprarp20.
enable all with frame fc.
wait-for window-close of frame fc focus browse bc.
release sprarp20.

  

