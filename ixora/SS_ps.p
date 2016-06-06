/* SS_ps.p
 * MODULE
        Селектор платежей по источнику
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
        22.04.2003 nadejda - добавлен источник DPK для внешних платежей потребкредитов
        01.11.2004 suchkov - добавлен источник SCN для платежей со сканера
        23.02.2005 kanat   - добавлен источник DIRIN для платежей с корр. счетов
        03.08.2005 dpuchkov- добавил источник для платежей по инкассовым распоряжениям
        09.12.2005 dpuchkov- добавил источник для платежей по депозитам юр.лиц.
        08.10.2012 evseev - ТЗ-797
*/

{global.i}
{lgps.i }
def var exitcod as cha .
def var v-sqn as cha .


 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .
   /*  Beginning of main program body */


   /*  End of program body */
   que.dp = today.
   que.tp = time.
   que.con = "F".
   if remtrz.source = "SVL" then que.rcod = "1".
   else if remtrz.source = "H"
     or remtrz.source = "IBH"  then que.rcod = "0".
   else if remtrz.source = "A" and remtrz.info[1] eq "" then que.rcod = "2".
   else if remtrz.source = "A" and remtrz.info[1] ne "" then que.rcod = "7".
   else if remtrz.source = "O" then que.rcod = "3".
   else if remtrz.source = "I" then que.rcod = "4".
   else if remtrz.source = "UI" then que.rcod = "10".
   else if remtrz.source = "LON" then que.rcod = "5".
   else if remtrz.source begins "P" then que.rcod = "6".
   else if remtrz.source = "SW" then que.rcod = "8".
   else if remtrz.source = "AB" then que.rcod = "9".
   else if remtrz.source = "PNJ" then que.rcod = "11".
   else if remtrz.source = "MDL" or remtrz.source = "MDD" then que.rcod = "12".
   /* by ja on 24/06/2001 */
   else if remtrz.source = "LBI" then que.rcod = "13".
   /* end by ja */
   else if remtrz.source = "DPK" then que.rcod = "14".
   else if remtrz.source = "SCN" then que.rcod = "15".
   else if remtrz.source = "DIR" then que.rcod = "16".
   else if remtrz.source = "INK" then que.rcod = "6".
   else if remtrz.source = "DEP" then que.rcod = "6".
   else if remtrz.source = "mt103" then do:
      find first swift_sts where swift_sts.swift_id = int(remtrz.ref) and swift_sts.sts = "warning" no-lock no-error.
      if avail swift_sts then do: que.rcod = "17". remtrz.source = "O". end. else que.rcod = "3".
   end. else que.rcod = "20".

   v-text = " Remtrz " + remtrz.remtrz +
     " обработан код завершения  = " + que.rcod .
   if remtrz.source = "PNJ" then v-text = v-text + ", дата 2 " + string(remtrz.valdt2, "99/99/99").
   run lgps.
  end.
 end.
