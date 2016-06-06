/* vcs-rotrz.p
 * MODULE
        Вал.кон.
 * DESCRIPTION
        Акцепт платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        vcremtrz
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.11
 * AUTHOR
        24.10.2008 galina - аналог s-rotrz
 * BASES
        BANK
 * CHANGES
        03.09.2012 evseev - иин/бин
*/

{global.i}


def buffer tgl for gl.
def var v-ref as cha format "x(10)".
def var v-pnp like remtrz.dracc.
def var v-reg5 as cha .
def var v-bin5 as cha .
def var pakal as cha .
def shared var v-option as cha .
def var v-chg  as int .

def shared var s-remtrz like remtrz.remtrz .
def var t-pay like remtrz.amt.
def var v-priory as cha .
def var prilist as cha.
define new shared frame remtrz.
def var acode like crc.code.
def var bcode like crc.code.
def var vpname as cha .
def var v-rbank as char.
def var v-rbcoutry as char.

{vcpsror.f}

 find first remtrz where remtrz.remtrz = s-remtrz no-lock .
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
 v-ref = substr(remtrz.sqn,19).
 if index(remtrz.sacc,"/") <> 0 then do :
  v-pnp = substr(remtrz.sacc,1,index(remtrz.sacc,"/") - 1) .
  v-sub5 = substr(remtrz.sacc,index(remtrz.sacc,"/") + 1) .
 end .
 else do :
  v-pnp = remtrz.sacc.
  v-sub5 = "" .
 end .
 v-rbank = "".
 v-rbcoutry = "".
 find bankl where bankl.bank = remtrz.rbank no-lock no-error.
 if avail bankl then do:
    v-rbank = bankl.name.
    if bankl.frbno <> "" then do:
       find codfr where codfr.codfr = "iso3166" and codfr.code = trim(bankl.frbno) no-lock no-error.
       if avail codfr then v-rbcoutry = codfr.name[1].
    end.
    else if substr(bankl.bank,1,2) = "19" or substr(bankl.bank,1,3) = "TXB" then do:
       find codfr where codfr.codfr = "iso3166" and codfr.code = "KZ" no-lock no-error.
       v-rbcoutry = codfr.name[1].
    end.
 end.

 v-bin5 = " ".
 if index(remtrz.ord,"/ID/") ne 0 then
  v-bin5 = substr(remtrz.ord,index(remtrz.ord,"/ID/") + 4).
 find first aaa where aaa.aaa  = remtrz.dracc no-lock no-error .
 if avail aaa then find cif of aaa no-lock no-error.
 if avail cif then  v-bin5 = trim(substr(cif.bin,1,13)).

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
     remtrz.ord  v-bin5 v-sub5
     remtrz.svcrc bcode  remtrz.svccgr  pakal
     remtrz.svca  remtrz.svccgl v-chg
     remtrz.svcaaa  remtrz.detpay[1]  remtrz.detpay[2]
     remtrz.detpay[3] remtrz.detpay[4]
     with frame remtrz  .
     if avail dfb then display dfb.name with frame remtrz .
     display v-rbank v-rbcoutry with frame remtrz.
   release remtrz .
   release que .
end .

{subz.i
&head = remtrz
&headkey = remtrz
&framename = remtrz
&formname = psror
&updatecon = false
&deletecon = false
&postrun = " "
&predelete = " "
&postdelete = " "
&postupdate = " "
}
