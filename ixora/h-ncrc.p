/* h-ncrc.p
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

/* h-ncrc.p Валютный контроль
   help на валюты НБ РК

   18.10.2002 nadejda создан
*/

{global.i}
{itemlist.i 
       &file = "ncrc"
       &frame = "width 67 row 4 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = "' ' ncrc.crc LABEL 'ВАЛ' ' '
                   ncrc.code format 'xxx' LABEL 'КОД' ' '
                   ncrc.des FORMAT 'x(30)' LABEL 'НАИМЕНОВАНИЕ' ' '
                   ncrc.stn format '999' label 'ЦФР' ' ' 
                   ncrc.rate[1] format '>>>,>>9.99' label 'КУРС' ' '
                   " 
       &chkey = "crc"
       &chtype = "integer"
       &index  = "crc" }



