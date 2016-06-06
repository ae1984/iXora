/* s-remtrzs.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

/* s-rotlxzi.p*/
{mainhead.i}
/*
{global.i} */
def var ys as log .
def buffer tgl for gl.
def shared var v-option as cha .
def shared var s-remtrz like remtrz.remtrz .
def var t-pay like remtrz.amt.
def var prilist as cha.
define new shared frame remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def var fu as int.
{lgps.i}
{rmzi.f}


 find first remtrz where remtrz.remtrz = s-remtrz no-lock .

 find first que where que.remtrz = remtrz.remtrz no-lock no-error .
 if avail que then do:
 if ( que.con ne "W" or que.pid ne  m_pid  ) and m_pid ne "PS_"
  then do:
   Message " Обработка невозможна !! " . pause .
   return.
   end.
 find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) 
                     and tarif2.stat = 'r' no-lock no-error .
 if avail tarif2 then pakal = tarif2.pakalp .
  else pakal = ' ' .
 find gl where gl.gl = remtrz.drgl no-lock no-error.
 find tgl where tgl.gl = remtrz.crgl no-lock no-error.
 find crc where crc.crc = remtrz.fcrc no-lock no-error .
  if avail crc then acode = crc.code .
 find crc where crc.crc = remtrz.tcrc no-lock no-error .
  if avail crc then bcode = crc.code .
 t-pay = remtrz.margb + remtrz.margs .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 if avail ptyp then display ptyp.des with frame remtrz.
find sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display ' Записи PRI_PS нет в sysc файле  !! '.
 pause . undo . return .
end.
prilist = sysc.chval.
find first que where que.remtrz = remtrz.remtrz no-lock no-error .
if avail que then
   v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
   else
   v-priory = entry(1,prilist) .
end .
do trans :

 v-psbank = remtrz.sbank .
 v-ref = substr(remtrz.sqn,19). 
 dtt1 = remtrz.detpay[1] + remtrz.detpay[2].
 if dtt1  begins remtrz.racc  then
 dtt1 = substr(dtt1,length(remtrz.racc) + 2 )  .
 fu = index(remtrz.detpay[4], trim(remtrz.bi)).
 if fu <= 2 then
 dtt2 = remtrz.detpay[3].
 else
 dtt2 = remtrz.detpay[3] + substr(remtrz.detpay[4],1,(fu - 2)).
 if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then do :
  v-kind = "TAX" .
 end .
 else 
  v-kind = "PAY" .
  
      display remtrz.remtrz v-ref remtrz.rdt
       remtrz.valdt1  remtrz.valdt2 remtrz.jh1      remtrz.jh2
       v-psbank remtrz.rbank remtrz.scbank remtrz.rcbank
       remtrz.sacc remtrz.racc rsub
       remtrz.drgl remtrz.crgl remtrz.dracc remtrz.cracc
       remtrz.fcrc acode remtrz.tcrc bcode remtrz.amt remtrz.payment
       remtrz.ptype remtrz.cover remtrz.svccgr  pakal
       remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
       remtrz.bb[1]  remtrz.bn[1] remtrz.bn[2]  dtt1 dtt2
       remtrz.ord remtrz.ordins[1]
       vpname remtrz.bi  v-priory v-kind
       with frame remtrz .                          /*
       if avail tgl then  display tgl.sub with frame remtrz .      
       if avail gl then  display gl.sub with frame remtrz . */
   release remtrz .
   release que .
end .

{subzs.i
&head = remtrz
&headkey = remtrz
&framename = remtrz
&formname = rmzi
&updatecon = true
&deletecon = true
&postrun = "
     if m_pid ne  ""PS_"" then do:
     find first que where que.remtrz = s-remtrz
              no-lock no-error.
     if not avail que then return .
   if avail que and  not ( que.pid eq m_pid and que.con eq  ""W"" )
             then do: release remtrz.
             release que. return . end.  end  . "
&predelete = "
               find first que where que.remtrz = s-remtrz
               exclusive-lock no-error.
              find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock.
               if remtrz.jh1 ne ? or remtrz.jh2 ne ? or m_pid ne que.pid
                 or que.con ne ""W"" or que.pid = ""3"" or m_pid = ""IC""
                 then do:
                Message "" Удалить невозможно ! "" . bell.
                release que . undo, retry.
               end. else do: run delnbal.
                if avail que then delete que . end . "
&postdelete = " v-text = s-remtrz + "" удален  "" . run lgps . "

&postupdate = "
    find first que where que.remtrz = s-remtrz no-lock no-error .
    if ( avail que and que.con ne ""F"" and que.pid = m_pid
     and  m_pid ne ""v1""  and  m_pid ne ""v2""
     and  m_pid ne ""3""  and  m_pid ne ""3W"" and u_pid ne ""inw_Icps""
        and m_pid ne ""NC"" )  then
        do: run rotlxzi .
         release remtrz.
         release que .
        end .
     else message "" У Вас нет прав на выполнение этой операции !!!  "".
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error .
    find first que where que.remtrz = s-remtrz no-lock no-error .
    if not avail que then do:
     find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock  .
     delete remtrz .
     clear frame remtrz all . return . end . " }
