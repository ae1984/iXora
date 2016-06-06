/* rml.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

  def shared var v-crc like remtrz.tcrc.
  def shared var v-amt like remtrz.payment.
  def shared var v-acc like remtrz.dracc.
  def shared var v-ref like remtrz.sqn.
  def shared var s-remtrz like remtrz.remtrz.

def shared temp-table wrem
    field remtrz like remtrz.remtrz
    field sbank like remtrz.sbank
    field ref like remtrz.ref
    field ofc like remtrz.rwho
    field sname like cif.sname.




  def var h as int .
  h = 12 .

       {browpnp.i
        &h = "h"
        &where = "true"
        &frame-phrase = "row 1 centered scroll 1 h down overlay "
        &seldisp = "wrem.remtrz"
        &file = "wrem"
        &disp = "wrem.remtrz column-label ""Платеж""
          wrem.sbank column-label ""БанкО""
          wrem.ref column-label ""Ссыл N""
          wrem.sname column-label ""Имя"" "
        &addupd = "wrem.remtrz"
        &upd    = " wrem.remtrz"
        &postupd = " hide all. "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = wrem.remtrz . "
       }
