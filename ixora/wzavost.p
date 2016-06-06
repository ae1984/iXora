/* wzavost.p
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
       23.08.2004 tsoy
 * CHANGES
*/


/* =============================================================== */
/*         ZAVOST  -  current status of cash of all cashiers       */
/* =============================================================== */
def shared var g-ofc like ofc.ofc.
define shared variable g-today as date.
def temp-table tmp field ofc like ofc.ofc.
        
/* найдем всех кассиров */
for each cwayofc where cwayofc.sts eq 2 and cwayofc.whn eq g-today no-lock:
    if avail cwayofc then do:
       find first tmp where tmp.ofc eq cwayofc.ofc no-error.
       if not avail tmp then
       do:
          create tmp.
          tmp.ofc = cwayofc.ofc.
       end.
    end.
end.

find first tmp no-lock no-error.
if avail tmp then do:
for each tmp:    

  find ofc where ofc.ofc eq tmp.ofc no-lock no-error.
  if avail ofc then do:
  displ space(25) "кассир : "  ofc.name with no-label no-box.
        for each cwayofc where 
                   cwayofc.ofc eq tmp.ofc and
                   cwayofc.whn eq g-today
                   and cwayofc.sts eq 2
                   by cwayofc.crc:
                    
        find first crc where crc.crc eq cwayofc.crc no-lock no-error.
        if avail crc then displ crc.crc crc.code cwayofc.amt with centered.
      end. /* each cwayofc. */
  end. /* ofc */
end.
end.
else /* none of TMP is avail */
do:
   displ "НЕ НАЙДЕНА ИНФОРМАЦИЯ О КАССИРАХ" with row 10 centered no-label 
        no-box.
end.
for each tmp: delete tmp. end.
