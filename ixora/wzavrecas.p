/* wzavrecas.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Регистрация возвратов сумм кассирами
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
        23.08.2004 tsoy
 * CHANGES
*/


/* ===================================================== */
/*        wzavrecas.p - возврат кассирами подкреплений    */
/* ===================================================== */

{wzavkas.f}

def shared var g-ofc like ofc.ofc.
def var avans as integer.

update v-ofc with frame f-zavkas.
find ofc where ofc.ofc eq v-ofc no-lock no-error.
if not avail ofc then do:
    message "Неправильный ввод! Такого пользователя не существует".
    return.                  
end.                             

update v[1] v[2] v[11] v[4]
       with frame f-zavkas title "Возврат подкреплений".

update can-go with frame f-can-go.

if can-go then
do transaction: 
   do i = 1 to 12:
      if v[i] ne 0.0 then
          run add_record (i, v[i]).
   end.
end.

release cwayofc.

hide all.

   find ofc where ofc.ofc eq v-ofc no-lock.
   displ " " + v-ofc + ", валюты в кассе:"format "x(40)" at 1 with no-label no-box.

   for each cwayofc where
                   cwayofc.ofc eq v-ofc and
                   cwayofc.whn eq today
                   and cwayofc.sts eq 2
                   by cwayofc.crc:

find first crc where crc.crc eq cwayofc.crc no-lock no-error.
if avail crc then
displ crc.crc crc.code cwayofc.amt.
 
end.                     

procedure add_record.
   def input parameter crcnum like crc.crc.
   def input parameter crcamt like cwayofc.amt.

   /* look for current value */
   find last cwayofc where cwayofc.whn eq today 
                       and cwayofc.ofc eq v-ofc
                       and cwayofc.crc eq crcnum
                       and cwayofc.sts eq 2 /* current value */
                       no-error.
        
   if not avail cwayofc then 
   do: 
        create cwayofc.
        cwayofc.whn = today.
        cwayofc.who = g-ofc.
        cwayofc.ofc = v-ofc.
        cwayofc.crc = crcnum.
        cwayofc.sts = 2.
        cwayofc.amt = 0.0.
   end.                   
   
      
   cwayofc.amt = cwayofc.amt - crcamt.
   
   /* make a record with RETURNED cash */
   find last cwayofc no-error.
   create cwayofc.
   cwayofc.ofc = v-ofc.
   cwayofc.whn = today.
   cwayofc.who = g-ofc.
   cwayofc.crc = crcnum.
   cwayofc.amt = crcamt.
   cwayofc.sts = 4. /* return */

   hide all.
end.

