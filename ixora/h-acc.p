/* h-acc.p
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

/* h-rmz5.p */
{global.i}
{lgps.i }
def var h as int .
h = 12 .
def var bname as cha format "x(40)" label "Beneficiary BANK" . 
/*def shared var s-remtrz like que.remtrz . */
def var v-amt like remtrz.amt .
def var v-cif like cif.cif .
def var v-date as  date .
def var v-ref like remtrz.ref.
def var ourbank like remtrz.sbank.
def var v-sqn like remtrz.sqn  .
def var vsel6 like remtrz.rsub.
def  shared var intv as  int.
def shared var s-gl like gl.gl.

vsel6 = string (intv).

if s-gl = intv then do:

       {browpnp.i
        &h = "h"
        &where = " que.pid = '2l' and que.con <> 'F'         
        and  (can-find(remtrz where remtrz.remtrz = que.remtrz and 
         remtrz.rsub eq  vsel6 )) use-index fprc "
        &frame-phrase = "row 1 centered scroll 1 h down"
         &predisp =  "find remtrz where remtrz.remtrz = que.remtrz
          no-lock no-error .
          bname = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) +
          trim(remtrz.bb[3]).  
          display remtrz.source remtrz.ptype
          remtrz.rdt remtrz.valdt1 remtrz.valdt2 remtrz.sbank
          remtrz.rbank with row 17. 
          pause 0 .
          display que.pid que.con with row 17. 
          pause 0. "

        &seldisp = "que.remtrz"
        &file = "que"
        &disp = "que.remtrz  bname 
        remtrz.payment remtrz.tcrc label 'CRC'"
        &addupd = " que.remtrz "
        &upd    = "  "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &enderr = " hide all.  "
        &befret = " frame-value = que.remtrz . 
                    hide all. "
                              }

   end.
