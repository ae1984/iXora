/* vcrmzshow.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Процедура просмотра и редактирования возвратного платежа
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
        28/07/2009 galina
 * BASES
        BANK COMM        
 * CHANGES
*/

/* s-remout.p*/

{global.i}
def var ys as log .
def shared var s-remtrz like remtrz.remtrz .
def shared var v-option as char.
def var t-pay like remtrz.amt.
def var prilist as cha.
def buffer  tgl  for  gl.
def var acode like crc.code.
def var bcode like crc.code.
def new shared frame remtrz.
{lgps.i}
{rmz.f}
find first que where que.remtrz = s-remtrz no-lock .
 if  que.pid ne m_pid then do:
  Message "Платеж находится в очереди = " + que.pid + 
          ", невозможно обработать " . 
  pause .
  return .
end.

find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then 
do:
  message "Отсутствует запись PRI_PS в таблице SYSC!" .
  pause .         
  undo .
  return .
end.
prilist = sysc.chval. 

if avail que then v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
else v-priory = entry(1, prilist).
    
find first remtrz where remtrz.remtrz = s-remtrz no-lock .
find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
v-psbank = remtrz.sbank .
 
if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then v-kind = "Налог".
else  v-kind = "Норм".

find gl where gl.gl = remtrz.drgl no-lock no-error.
find tgl where tgl.gl = remtrz.crgl no-lock no-error.

find crc where crc.crc = remtrz.fcrc no-lock no-error.
if avail crc then acode = crc.code.
find crc where crc.crc = remtrz.tcrc no-lock no-error.
if avail crc then bcode = crc.code.
 display
     remtrz.remtrz remtrz.sqn v-psbank remtrz.ptype ptyp.des
      remtrz.rdt
     remtrz.valdt1  remtrz.valdt2 remtrz.jh1      remtrz.jh2
     v-psbank remtrz.rbank remtrz.scbank remtrz.rcbank
     remtrz.sacc remtrz.racc rsub
     remtrz.drgl gl.sub remtrz.crgl tgl.sub remtrz.dracc  remtrz.cracc
     remtrz.fcrc acode remtrz.tcrc bcode remtrz.amt remtrz.payment
     remtrz.ptype remtrz.cover remtrz.svccgr  pakal
     remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
     remtrz.bb remtrz.ba remtrz.bn remtrz.ord remtrz.bi  v-priory v-kind
     with frame remtrz. 
     
{subz.i
&head = remtrz
&headkey = remtrz
&framename = remtrz
&formname = remtrz
&updatecon = false
&deletecon = true
&postrun = " "
&predelete = " find remtrz where remtrz.remtrz = s-remtrz no-lock no-error. if remtrz.jh1 <> ? then do: message 'Не возможно удалить платеж. Сделана первая проводка!'. undo, retry. end. if remtrz.jh1 = ? then do: find remtrz where remtrz.remtrz = s-remtrz exclusive-lock."
&postdelete = " s-remtrz = ''. hide all. pause 0."
&clearframe = " end."
&postupdate = " " 
}

find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if avail remtrz then do:
    if keyfunction(lastkey) eq "END-ERROR" and remtrz.jh1  = ? then do transaction:
      find current remtrz exclusive-lock. 
      delete remtrz.
      s-remtrz = ''.
    end.
    hide all.
    pause 0.
end.
  
