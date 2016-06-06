/* zavrecas.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27/01/04 sasco Добавил валюту РУБЛЬ
*/


/* ===================================================== */
/*        ZAVRECAS.P - возврат кассирами подкреплений    */
/* ===================================================== */

{zavkas.f}

def shared var g-ofc like ofc.ofc.
def var avans as integer.

update v-ofc with frame f-zavkas.
find ofc where ofc.ofc eq v-ofc no-lock no-error.
if not avail ofc then do:
    message "Неправильный ввод! Такого пользователя не существует".
    return.                  
end.                             

update v[1] v[2] v[3] v[4]
       with frame f-zavkas title "Возврат подкреплений".

update can-go with frame f-can-go.

if can-go then
do transaction: 
   do i = 1 to 12:
      if v[i] ne 0.0 then
          run add_record (i, v[i]).
   end.
end.

release cashofc.

hide all.

   find ofc where ofc.ofc eq v-ofc no-lock.
   displ " " + v-ofc + ", валюты в кассе:"format "x(40)" at 1 with no-label no-box.

   for each cashofc where
                   cashofc.ofc eq v-ofc and
                   cashofc.whn eq today
                   and cashofc.sts eq 2
                   by cashofc.crc:

find first crc where crc.crc eq cashofc.crc no-lock no-error.
if avail crc then
displ crc.crc crc.code cashofc.amt.
 
end.                     

procedure add_record.
   def input parameter crcnum like crc.crc.
   def input parameter crcamt like cashofc.amt.

   /* look for current value */
   find last cashofc where cashofc.whn eq today 
                       and cashofc.ofc eq v-ofc
                       and cashofc.crc eq crcnum
                       and cashofc.sts eq 2 /* current value */
                       no-error.
        
   if not avail cashofc then 
   do: 
        create cashofc.
        cashofc.whn = today.
        cashofc.who = g-ofc.
        cashofc.ofc = v-ofc.
        cashofc.crc = crcnum.
        cashofc.sts = 2.
        cashofc.amt = 0.0.
   end.                   
   
      
   cashofc.amt = cashofc.amt - crcamt.
   
   /* make a record with RETURNED cash */
   find last cashofc no-error.
   create cashofc.
   cashofc.ofc = v-ofc.
   cashofc.whn = today.
   cashofc.who = g-ofc.
   cashofc.crc = crcnum.
   cashofc.amt = crcamt.
   cashofc.sts = 4. /* return */

   hide all.
end.

