/* zp1-rotrz.p
 * MODULE
	Создание и отправка платежей по ЗП проектам Народного банка
 * DESCRIPTION

 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-3 
 * AUTHOR
        02/10/2006 tsoy
 * CHANGES
*/

{global.i}
def var ys as log .
def buffer tgl for gl.
def shared var v-ref as cha format "x(10)". 
def shared var v-pnp like remtrz.dracc. 
def shared var v-reg5 as cha . 
def shared var pakal as cha .              
def shared var v-option as cha .
def shared var s-remtrz like remtrz.remtrz .
def shared var v-chg  as int .
def var t-pay like remtrz.amt.
def var v-priory as cha . 
def var prilist as cha.
define new shared frame remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def var vpname as cha . 
{lgps.i}
{psror.f}


 find first remtrz where remtrz.remtrz = s-remtrz no-lock .

 find first que where que.remtrz = remtrz.remtrz no-lock no-error .
 if avail que then do:
 if ( que.con ne "W" or que.pid ne  m_pid  ) and m_pid ne "PS_"  
 and not ( que.con = "W" and m_pid = "O" and que.pid = "G" 
  and remtrz.rwho = g-ofc  )  
  then do:
   Message " Невозможно обработать !! " . pause .
   return.
   end.
 find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) 
                     and tarif2.stat = 'r' no-lock no-error .
 if avail tarif2 then pakal = tarif2.pakalp .
  else pakal = ' ' .
 find gl where gl.gl = remtrz.drgl no-lock no-error.
  if avail gl and gl.sub = "dfb" then 
  find first dfb where dfb.dfb = remtrz.dracc no-lock no-error . 
 find tgl where tgl.gl = remtrz.crgl no-lock no-error.
 find crc where crc.crc = remtrz.fcrc no-lock no-error .
  if avail crc then acode = crc.code .
 
 find crc where crc.crc = remtrz.svcrc no-lock no-error .
  if avail crc then bcode = crc.code .

 find crc where crc.crc = remtrz.tcrc no-lock no-error .
  
 t-pay = remtrz.margb + remtrz.margs .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 
 if remtrz.svcaaa ne "" then  v-chg = 3 .
 else
 if remtrz.svcgl  ne 0  then  v-chg = 1 .
 

/* 
 if avail ptyp then display ptyp.des with frame remtrz.
  */

find sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display ' Запись PRI_PS отсутствует в файле sysc !! '.
 pause . undo . return .
end.

prilist = sysc.chval.

find first que where que.remtrz = remtrz.remtrz no-lock no-error .
if avail que then
   v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
   else
   v-priory = entry(1,prilist) .
end .

/* 07.06.2005 tsoy */
find sub-cod where sub-cod.acc = remtrz.remtrz and 
            sub-cod.sub = 'rmz'and 
            sub-cod.d-cod = "urgency" no-lock no-error.

if not avail sub-cod then 
    v-priory = 'o'.
else
    v-priory = sub-cod.ccode.


vpname = ''.
find first aaa where aaa.aaa  = remtrz.cracc no-lock no-error . 
if avail aaa then find cif of aaa no-lock no-error . 

if avail cif then do:
   find ppoint where ppoint.point = integer(integer(cif.jame) / 1000 - 0.5) and 
   ppoint.dep = integer(cif.jame) - integer((integer(cif.jame) / 1000 - 0.5)) 
    * 1000  no-lock no-error.    
   if available ppoint then vpname = ppoint.name + ', '.
   find point where point.point = integer(integer(cif.jame) / 1000 - 0.5)
   no-lock    no-error.   
   if available point then vpname = vpname + point.addr[1].
end .

do trans :
 run start.
 /*
   v-psbank = remtrz.sbank .
 */
 v-ref = substr(remtrz.sqn,19).
 if index(remtrz.sacc,"/") <> 0 then do :
  v-pnp = substr(remtrz.sacc,1,index(remtrz.sacc,"/") - 1) .
  v-sub5 = substr(remtrz.sacc,index(remtrz.sacc,"/") + 1) .
 end .
 else do :
  v-pnp = remtrz.sacc.
  v-sub5 = "" .
 end .
 v-reg5 = " ".
 if index(remtrz.ord,"/ID/") ne 0 then
  v-reg5 = substr(remtrz.ord,index(remtrz.ord,"/ID/") + 4).
 find first aaa where aaa.aaa  = remtrz.dracc no-lock no-error .
 if avail aaa then find cif of aaa no-lock no-error.
 if avail cif then  v-reg5 = trim(substr(cif.jss,1,13)).
 /*
 remtrz.cover = 1.
   */
/****************************/
      find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
      if avail aaa then 
      do:
         find cif where cif.cif = aaa.cif  no-lock no-error.
         find last cifsec where cifsec.cif = cif.cif no-lock no-error.
         if avail cifsec then
         do:
           find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
           if not avail cifsec then
           do:
              create ciflog.
              assign
                ciflog.ofc = g-ofc
                ciflog.jdt = today
                ciflog.cif = cif.cif
                ciflog.sectime = time
                ciflog.menu = "Регистрация исходящих платежей".
                release ciflog.
                message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
                undo,retry.
           end.
           else
           do:
                create ciflogu.
                assign
                  ciflogu.ofc = g-ofc
                  ciflogu.jdt = today
                  ciflogu.sectime = time
                  ciflogu.cif = cif.cif
                  ciflogu.menu = "Регистрация исходящих платежей".
                  release ciflogu.
           end.
         end.
      end.
/****************************/

 display
     v-ref  v-priory remtrz.remtrz  remtrz.cover 
     remtrz.rdt   remtrz.jh1 
     remtrz.fcrc  
     acode  remtrz.amt  
     remtrz.tcrc 
     crc.code remtrz.payment 
     remtrz.outcode v-pnp 
     remtrz.ord  v-reg5 v-sub5
     remtrz.svcrc bcode  remtrz.svccgr  pakal 
     remtrz.svca  remtrz.svccgl v-chg 
     remtrz.svcaaa  remtrz.detpay[1]  remtrz.detpay[2] 
     remtrz.detpay[3] remtrz.detpay[4]
     with frame remtrz  .
     if avail dfb then display dfb.name with frame remtrz . 
   release remtrz .
   release que .
end .


{subz.i 
&head = remtrz
&headkey = remtrz
&framename = remtrz
&formname = psror-2
&updatecon = true
&deletecon = false
&postrun = "
     if m_pid ne  ""PS_"" 
     then 
     do: 
     find first que where que.remtrz = s-remtrz
               no-lock no-error.
     if not avail que then return .
     
   if avail que and  not ( que.pid eq m_pid and que.con eq  ""W"" ) 
    and m_pid = ""O"" 
             then do: 
                      release remtrz.
                      release que. return . 
                  end.  
     end  . 
if m_pid eq 'P' then do:
         find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
         if avail remtrz then
          display remtrz.cover 
          remtrz.amt remtrz.tcrc 
          remtrz.payment remtrz.outcode remtrz.ord  
          remtrz.detpay[1]  remtrz.detpay[2]
          remtrz.detpay[3]  remtrz.detpay[4] 
          with frame remtrz  .
      end.  "
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
&postdelete = " v-text = s-remtrz + "" удалена "" . run lgps . run comm-dr(s-remtrz)."

&postupdate = "
    find first que where que.remtrz = s-remtrz no-lock no-error .
    if ( avail que and que.con ne ""F"" and que.pid = m_pid
     and  m_pid ne ""v1""  and  m_pid ne ""v2""
     and  m_pid ne ""3""  and  m_pid ne ""3W"" and u_pid ne ""inw_Icps""
        and m_pid ne ""NC"" )  then
        do: run zp-rotrz.
         release remtrz.
         release que .
        end .
     else message "" У Вас нет прав сделать это !!!  "".
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error .
    find first que where que.remtrz = s-remtrz no-lock no-error .
    if not avail que then do:
     find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock  .
     delete remtrz .
     clear frame remtrz all . return . end . " }
