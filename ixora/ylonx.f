/* ylonx.f
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

form
vlcnt label "LЁgums....." skip
s-longrp format "zz9" label "Grupa......" longrp.des label "Nosaukums.." skip
lon.lon label "KredЁts...." lon.gl label "Bilances k." skip
lon.cif label "Klients...." cif.name label "Nosaukums.." skip
lon.crc label "Val­ta....." lon.opnamt label "Summa......" skip
lon.rdt label "Re¦.dat...." lon.duedt label "Termi‡Ѕ...." skip
lon.base label "B–ze......." lon.prem label "Procents..." skip
lon.ptype label "Izd.forma.." vpy label "Nosaukums.." skip
xacc label "Rё±ina #..." lon.loncat label "Mёr±is....." skip
lon.basedy label "Dienas gad–" lon.lcr label "Kred.vёst.." skip
/*
lon.srv[1] label "Komisija..." lon.srv[2] label "Komisija..." skip
lon.srv[3] label "Komisija..."
*/
xjh label "Transakc..." with    frame lon centered  row 3 3 col.
