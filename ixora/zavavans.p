/* zavavans.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Ввод авансовых сумм для кассиров
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
 with frame f-zavkas title "Выдача аванса кассиру".

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
   displ "Текущее состояние кассы:" skip.
   displ ofc.name with no-label no-box.
  
   for each cashofc where 
                   cashofc.ofc eq v-ofc and
                   cashofc.whn eq today
                   and cashofc.sts eq 2
                   by cashofc.crc:
                   
    find first crc where crc.crc eq cashofc.crc no-lock no-error.
    if avail crc then
    displ crc.crc crc.code cashofc.amt.

    end.

/*-----------------------------------------------------------------------*/
procedure add_record.
   def input parameter crcnum like crc.crc.
   def input parameter crcamt like cashofc.amt.

   /* check if there exist avans ...*/
   find last cashofc where cashofc.ofc eq v-ofc
                       and cashofc.whn eq today
                       and cashofc.crc eq crcnum
                       and cashofc.sts eq 1 /*avans - ?*/
                       no-error.

   find first crc where crc.crc eq crcnum no-lock no-error.
      
   if not avail cashofc then 
   do:
   create cashofc.
   cashofc.ofc = v-ofc.
   cashofc.crc = crcnum.
   cashofc.amt = crcamt.
   cashofc.whn = today.
   cashofc.who = g-ofc.
   cashofc.sts = 1.          /* 1 = avans, 
                                2 = current value
                                3 = podkr
                                4 = returned */
   end. 
   else cashofc.amt = cashofc.amt + crcamt.
                                
   /* look for record with current value */
   find last cashofc where cashofc.ofc eq v-ofc
                       and cashofc.whn eq today
                       and cashofc.crc eq crcnum
                       and cashofc.sts eq 2 /* current */
                       exclusive-lock no-error.
   
   if not avail cashofc then do: create cashofc. cashofc.amt = 0.0. end.

   cashofc.ofc = v-ofc.
   cashofc.who = g-ofc.
   cashofc.crc = crcnum.
   cashofc.amt = cashofc.amt + crcamt.
   cashofc.whn = today.
   cashofc.sts = 2.
   

   release cashofc.
   
   hide all.

end.

