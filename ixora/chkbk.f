/* chkbk.f
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
chkbk.chkbk chkbk.aaa skip
chkbk.saddr[1] label "S®T PIE"
chkbk.saddr[2] label ""
chkbk.saddr[3] label ""
chkbk.saddr[4] label ""
chkbk.saddr[5] label ""
chkbk.addr[1]  label "V…RDS  "
chkbk.addr[2] label ""
chkbk.addr[3] label ""
chkbk.addr[4] label ""
chkbk.addr[5] label ""
chkbk.odate chkbk.chkbkby chkbk.bydes chkbk.byfee
chkbk.chkbktp chkbk.tpdes chkbk.qty chkbk.chkfee chkbk.deldt
chkbk.sdate chkbk.chkfrm chkbk.chkto
chkbk.chkbksts
chkbk.pbdt skip chkbk.probm
with  2 col   frame chkbk no-box row 3.
