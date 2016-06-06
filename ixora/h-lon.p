/* h-lon.p
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
*/

/* h-lon.p
*/
define shared variable s-lon like lon.lon.
define variable lon-all as logical.
define variable dam-cam1 as decimal.
if s-lon = "1"
then lon-all = no.
else lon-all = yes.
{global.i}
{itemlist.i
       &updvar = "def var vlon like lon.lon. {imesg.i 3807} update vlon.
                  message 'Все кредиты ?' update lon-all format
                  'Все/Непогашеные'. "
       &file = "lon"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "lon.lon ge vlon and (not lon-all and 
       lon.dam[1] - lon.cam[1] > 0 or lon-all)"
       {h-lon.f}
       &chkey = "lon"              
       &chtype = "string"
       &index  = "lon"
       &findadd = "find cif where cif.cif = lon.cif no-lock. find crc where
                   crc.crc = lon.crc no-lock. dam-cam1 = lon.dam[1] - 
                   lon.cam[1]. "
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
