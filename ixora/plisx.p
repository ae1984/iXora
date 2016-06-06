/* plisx.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Хочу собрать все исходящие платежи
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
        04/10/2004 saltanat
 * CHANGES
        18.12.2005 tsoy     - добавил время создания платежа.
*/

/* Исходящие платежи в очереди 5.3.8 */

{global.i}
def var m_pid like bank.que.pid.
def var u_pid as char.
def var h as inte init 12.
def shared var s-remtrz like que.remtrz .
def new shared var v-amt like remtrz.amt .
def new shared var v-cif like cif.cif .
def new shared var v-date as  date .
def new shared var v-ref like remtrz.ref.
def new shared var ourbank like remtrz.sbank.
def new shared var v-sqn like remtrz.sqn  .
def var v-rrr as cha  format "x(10)" column-label "REF"   .
def var v-all as cha init ''.
def var v-cur as int .
def var saaa as char.

def shared temp-table t-remtrz
    field  remtrz   like remtrz.remtrz
    field  rdt      like remtrz.rdt
    field  amt      like vcdocs.sum
    field  sacc     like remtrz.sacc
    field  scif     like cif.cif
    field  scifname like cif.name
    field  tcrc     like remtrz.tcrc.

def var v-dt as date.

find last cls no-lock no-error.
if avail cls then do:
   v-dt = cls.whn.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
display "Отсутствует запись OURBANK в таблице SYSC!".
pause . undo . return . end.
ourbank = sysc.chval.

if (m_pid =  "P" ) and u_pid ne "v-stat" then v-all = g-ofc.
if m_pid ne "R" then do:
def var v-dep as integer.
def var v-3G as integer init 2. /* RKO */
{get-dep.i}
v-dep = get-dep(g-ofc, g-today).
if ourbank <> 'TXB00' then v-dep = 1. /* check TXB00 */
if v-dep <> 1 then v-3G = 1. /* check HeadTXB00Office */
if m_pid <> '3G' then v-3G = 1. /* check 3G que */
if v-3G = 2 then do: v-3G = 1. message "1) Остальные 2) СПФ " update v-3G. hide
message. end.
if v-3G <> 1 and v-3G <> 2 then v-3G = 1.
m_pid = 'SWS'.
for each que where m_pid = que.pid
      and que.con ne "F" and
        ( can-find(remtrz where remtrz.remtrz = que.remtrz 
          and (m_pid = 'P' or m_pid = 'O' or
        ((v-3G = 2 and remtrz.rbank = """" and not remtrz.source = 'IBH') or
         (v-3G = 1 and (remtrz.rbank <> """" or remtrz.source = 'IBH' )))))
      or (v-all eq """" and can-find(remtrz where remtrz.remtrz = que.remtrz and
         (m_pid = 'P' or m_pid = 'O' or ((v-3G = 2 and remtrz.rbank = """" and
          not remtrz.source = 'IBH') or
         (v-3G = 1 and (remtrz.rbank <> """" or remtrz.source = 'IBH' )))))))
      use-index fprc no-lock.

   find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
   if avail remtrz and remtrz.tcrc <> 1 and remtrz.jh2 <> 0 and remtrz.valdt2 = v-dt then do:
      find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
      if avail aaa then do:
         saaa = aaa.cif.
         find cif where cif.cif = aaa.cif no-lock no-error.
         if avail cif then do:
            if cif.type = 'p' then next. 
         end.
         else next.
      end.
      else next.
      
      create t-remtrz.
      assign t-remtrz.remtrz   = remtrz.remtrz
             t-remtrz.rdt      = remtrz.rdt
             t-remtrz.amt      = remtrz.amt
             t-remtrz.sacc     = remtrz.sacc
             t-remtrz.scif     = saaa 
             t-remtrz.scifname = cif.name
             t-remtrz.tcrc     = remtrz.tcrc.
   end. 
end.
end.

