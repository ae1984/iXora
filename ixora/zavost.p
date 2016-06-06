/* zavost.p
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
        27.01.2004 sasco    - убрал today для cashofc
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/


/* =============================================================== */
/*         ZAVOST  -  current status of cash of all cashiers       */
/* =============================================================== */
def shared var g-ofc like ofc.ofc.
define shared variable g-today as date.
def temp-table tmp field ofc like ofc.ofc.
        
/* найдем всех кассиров */
for each cashofc where cashofc.sts eq 2 and cashofc.whn eq g-today no-lock:
    if avail cashofc then do:
       find first tmp where tmp.ofc eq cashofc.ofc no-error.
       if not avail tmp then
       do:
          create tmp.
          tmp.ofc = cashofc.ofc.
       end.
    end.
end.

find first tmp no-lock no-error.
if avail tmp then do:
for each tmp:    

  find ofc where ofc.ofc eq tmp.ofc no-lock no-error.
  if avail ofc then do:
  displ space(25) "кассир : "  ofc.name with no-label no-box.
        for each cashofc where 
                   cashofc.ofc eq tmp.ofc and
                   cashofc.whn eq g-today
                   and cashofc.sts eq 2
                   by cashofc.crc:
                    
        find first crc where crc.crc eq cashofc.crc no-lock no-error.
        if avail crc then displ crc.crc crc.code cashofc.amt with centered.
      end. /* each cashofc. */
  end. /* ofc */
end.
end.
else /* none of TMP is avail */
do:
   displ "НЕ НАЙДЕНА ИНФОРМАЦИЯ О КАССИРАХ" with row 10 centered no-label 
        no-box.
end.
for each tmp: delete tmp. end.
