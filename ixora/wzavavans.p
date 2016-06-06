/* wzavavans.p
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
 * AUTHOR
        23.08.2004 tsoy
 * CHANGES
*/


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
 with frame f-zavkas title "Выдача аванса кассиру".

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
   displ "Текущее состояние кассы:" skip.
   displ ofc.name with no-label no-box.
  
   for each cwayofc where 
                   cwayofc.ofc eq v-ofc and
                   cwayofc.whn eq today
                   and cwayofc.sts eq 2
                   by cwayofc.crc:
                   
    find first crc where crc.crc eq cwayofc.crc no-lock no-error.
    if avail crc then
    displ crc.crc crc.code cwayofc.amt.

    end.

/*-----------------------------------------------------------------------*/
procedure add_record.
   def input parameter crcnum like crc.crc.
   def input parameter crcamt like cwayofc.amt.

   /* check if there exist avans ...*/
   find last cwayofc where cwayofc.ofc eq v-ofc
                       and cwayofc.whn eq today
                       and cwayofc.crc eq crcnum
                       and cwayofc.sts eq 1 /*avans - ?*/
                       no-error.

   find first crc where crc.crc eq crcnum no-lock no-error.
      
   if not avail cwayofc then 
   do:
   create cwayofc.
   cwayofc.ofc = v-ofc.
   cwayofc.crc = crcnum.
   cwayofc.amt = crcamt.
   cwayofc.whn = today.
   cwayofc.who = g-ofc.
   cwayofc.sts = 1.          /* 1 = avans, 
                                2 = current value
                                3 = podkr
                                4 = returned */
   end. 
   else cwayofc.amt = cwayofc.amt + crcamt.
                                
   /* look for record with current value */
   find last cwayofc where cwayofc.ofc eq v-ofc
                       and cwayofc.whn eq today
                       and cwayofc.crc eq crcnum
                       and cwayofc.sts eq 2 /* current */
                       exclusive-lock no-error.
   
   if not avail cwayofc then do: create cwayofc. cwayofc.amt = 0.0. end.

   cwayofc.ofc = v-ofc.
   cwayofc.who = g-ofc.
   cwayofc.crc = crcnum.
   cwayofc.amt = cwayofc.amt + crcamt.
   cwayofc.whn = today.
   cwayofc.sts = 2.
   

   release cwayofc.
   
   hide all.

end.

