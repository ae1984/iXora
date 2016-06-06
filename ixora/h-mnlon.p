/* h-mnlon.p
 * MODULE
        HELP
 * DESCRIPTION
        HELP
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        оттуда где есть mnlon  
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        21.02.2005 marinav
 * CHANGES
*/

{global.i}
{kd.i}




 {itemlist.i 
   &file = "lon"
   &frame = "  row 5 centered scroll 1 10 down overlay title ' МОНИТОРИНГ ' "
   &where = " lon.cif = s-kdcif and lon.dam[1] - lon.cam[1] > 0 "
   &flddisp = "lon.lon 
               lon.opnamt " 
   &chkey = "lon "
   &chtype = "string"
   &index  = "lon" }


return frame-value.
