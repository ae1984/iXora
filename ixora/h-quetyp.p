/* h-quetyp.p
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

/* h-quetyp.p */
{global.i}

def shared var s-remtrz like que.remtrz .
define var vselect as cha format "x".
def var s-typeps like que.ptype.
define var vgrp like bill.itype format "x(7)".
def var h as int .
h = 12 .
def var v-rrr as cha  format "x(10)" column-label "REF"   .

  do:
       update s-typeps label " Type ? " with side-label overlay row 19 frame tt.
       vselect = s-typeps .

       {browpnp.i
        &h = "h"
        &where = "vselect = que.ptype or vselect = ""0"""
        &frame-phrase = "row 1 centered scroll 1 h down overlay "
        &predisp = "find remtrz where remtrz.remtrz = que.remtrz
         no-lock no-error .
          v-rrr = substr(remtrz.sqn,19) . 
          display remtrz.source remtrz.ptype remtrz.rdt
          remtrz.valdt1 remtrz.valdt2 remtrz.sbank remtrz.rbank
          with row 17 . pause 0 .
          if avail que then display que.pid  que.con
          with row 17 . pause 0 . "
        &seldisp = "que.remtrz"
        &file = "que"
        &disp = "que.remtrz v-rrr  remtrz.fcrc
         remtrz.amt remtrz.tcrc remtrz.payment "
        &addupd = " que.remtrz "
        &upd    = " "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = que.remtrz . hide all . "
       }

end.
