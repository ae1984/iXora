/* rmla.p
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
        17.11.09 marinav счет as cha format "x(20)" 
*/

  def shared var v-crc like remtrz.tcrc.
  def shared var v-amt like remtrz.payment.
  def shared var v-acc like remtrz.dracc.
  def shared var v-ref like remtrz.sqn.
  def shared var s-remtrz like remtrz.remtrz.
  def shared var suma like remtrz.amt .                          
  def shared var sump like remtrz.payment . 

  def shared var i  as int . 
  def shared temp-table wrem
    field remtrz like remtrz.remtrz
    field ref like remtrz.ref
    field amt like remtrz.amt label "Сумма"
    field crc like remtrz.fcrc label "Вал" .



  def var h as int .
  h = 12 .

       {browpnp.i
        &h = "h"
        &where = "true"
        &frame-phrase = "row 3
         centered scroll 1 h down title ' Итого: ' + string(i) 
         + ' СуммаД: ' + string(suma,'z,zzz,zzz,zzz,zz9.99-') + ' СуммаК: ' +
           string(sump,'z,zzz,zzz,zzz,zz9.99-') 
                     + ' ' overlay width 100 "
        &seldisp = "wrem.remtrz"
        &file = "wrem"
        &predisp = "find remtrz where remtrz.remtrz = wrem.remtrz no-lock 
        no-error.
        find que where que.remtrz = wrem.remtrz no-lock no-error.
        display remtrz.source column-label 'Источ.' 
                remtrz.ptype label 'Тип плат.'
                remtrz.rdt label 'Рег.дата' remtrz.valdt1 label '1 Дата'
                remtrz.valdt2 label '2 Дата' remtrz.sbank label 'БанкО'
                remtrz.rbank label 'БанкП' with row 20 centered width 80. pause 0 .
                if avail que then 
                display que.pid column-label ' Код ' format 'x(5)'
                        que.con label 'Сост.' with row 20. 
                pause 0. "
        &disp = "wrem.remtrz label 'Платеж' wrem.ref label 'Ссыл N' 
                 wrem.amt label 'СуммаД' wrem.crc label 'Вал' 
                 remtrz.sacc label 'Д.Сч.'
                 remtrz.cracc label 'К.Сч.' format 'x(20)' "
        &addupd = "wrem.remtrz"
        &upd    = " wrem.remtrz"
        &postupd = " hide all. "
        &addcon = "false"
        &updcon = "false"
        &delcon = "false"
        &retcon = "true"
        &befret = " s-remtrz = wrem.remtrz . hide all . "
       }                                                            
