/* vcacplatnew-dat.p
 * MODULE
        Вал контроль
 * DESCRIPTION
        Отчет по всем акцептованым платежам
 * RUN
        vcacplatnew.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16.01.2012 aigul
 * BASES
        BANK COMM TXB
 * CHANGES
        07.03.2012 aigul - исправила выборку jou документов
*/
def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared var v-ourbank as char.
def shared var s-vcourbank as char.
def var v-bank   as char.
def shared temp-table t-actplat
   field plnum as char
   field plinout as char
   field pldt as date
   field plsum as deci
   field plcrc as char
   field plrem as char
   field plget as char
   field bank as char
   index dt is primary pldt.

find txb.cmp no-lock no-error.
v-bank = txb.cmp.name.




for each txb.joudoc where txb.joudoc.jh <> ?
/*and (date(entry(2,txb.joudoc.rescha[2])) > v-dt1 or date(entry(2,txb.joudoc.rescha[2])) < v-dt2 )*/
and (txb.joudoc.whn >= v-dt1 and txb.joudoc.whn <= v-dt2)
/*and txb.joudoc.rescha[2] <> ''*/ no-lock:
    find first txb.arp where txb.arp.arp = txb.joudoc.dracc and string(txb.arp.gl) matches "2237*" no-lock no-error.
    if not avail txb.arp then next.
    find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
    if not avail txb.aaa then next.
 /* if txb.joudoc.dracctype <> "2" or txb.joudoc.cracctype <> "2" then next.*/

  find first txb.jh where txb.jh.jh = txb.joudoc.jh no-lock no-error.
  if not avail txb.jh then next.

  find first txb.crc where txb.crc.crc = txb.joudoc.crcur no-lock no-error.
  if not avail txb.crc then next.
  create t-actplat.
  assign t-actplat.plnum =  string(txb.joudoc.jh) + ' ' + trim(txb.joudoc.num) + ' (' + txb.joudoc.docnum + ')'
         t-actplat.pldt = txb.joudoc.whn
         t-actplat.plsum = txb.joudoc.cramt
         t-actplat.plcrc = txb.crc.code
         t-actplat.plinout = 'Входящий'
         t-actplat.plrem = txb.joudoc.remark[1] + ' ' + txb.joudoc.remark[2].
         t-actplat.bank = v-bank.
         find first txb.aaa where txb.aaa.aaa = txb.joudoc.cracc no-lock no-error.
         if avail txb.aaa then do:
            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            if avail txb.cif then t-actplat.plget = txb.cif.name.
          end.
end.

for each vcblock where vcblock.bank = s-vcourbank and vcblock.sts = 'c' and vcblock.jh2 <> ? and
(vcblock.rdt >= v-dt1 or vcblock.rdt <= v-dt2) no-lock:

  find first txb.jh where txb.jh.jh = vcblock.jh2 no-lock no-error.
  if not avail txb.jh then next.

  find first txb.remtrz where txb.remtrz.remtrz = vcblock.remtrz no-lock no-error.
  if not avail txb.remtrz then next.

  find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
  if not avail txb.crc then next.

  create t-actplat.
  assign t-actplat.plnum =  trim( substring( txb.remtrz.sqn,19,8 )) + ' (' + txb.remtrz.remtrz + ')'
         t-actplat.pldt = txb.remtrz.rdt
         t-actplat.plsum = txb.remtrz.amt
         t-actplat.plcrc = txb.crc.code
         t-actplat.plrem = txb.remtrz.detpay[1] + ' ' + txb.remtrz.detpay[2] + ' ' + txb.remtrz.detpay[3] + ' ' + txb.remtrz.detpay[4]
         t-actplat.plinout = 'Входящий'.
         t-actplat.plget = remtrz.bn[1].
         t-actplat.bank = v-bank.
end.

for each txb.remtrz where /*txb.remtrz.ptype = '4' or txb.remtrz.ptype = '6' or txb.remtrz.ptype = 'M' or txb.remtrz.ptype = '3'
or txb.remtrz.ptype = '7' use-index ptype*/ txb.remtrz.rdt >= v-dt1 and txb.remtrz.rdt <= v-dt2 no-lock:
   if (txb.remtrz.ptype = '4' or txb.remtrz.ptype = '6' or txb.remtrz.ptype = 'M') then do:
      if substr(txb.remtrz.sqn,19) matches "ДПС*" then next.
      if trim(txb.remtrz.vcact) = '' then next.
      if num-entries(txb.remtrz.vcact) < 2 then next.
      if date(entry(2,txb.remtrz.vcact)) < v-dt1 or date(entry(2,txb.remtrz.vcact)) > v-dt2 then next.
   end.

   else if (txb.remtrz.ptype = '3' or txb.remtrz.ptype = '7') then do:
      if txb.remtrz.jh2 = ? then next.
      find first txb.sub-cod where txb.sub-cod.sub   = 'rmz' and txb.sub-cod.acc   = txb.remtrz.remtrz and txb.sub-cod.d-cod = 'eknp' no-lock  no-error.
      if not avail txb.sub-cod then next.
      if substr(txb.sub-cod.rcode,1,1) = "1" and substr(txb.sub-cod.rcode,4,1)= "1" and txb.remtrz.fcrc = 1 then next.
      find first txb.jh where txb.jh.jh = txb.remtrz.jh2 no-lock no-error.
      if not avail txb.jh then next.
      if txb.jh.jdt < v-dt1 or txb.jh.jdt > v-dt2 then next.
      find first txb.arp where txb.arp.arp = txb.remtrz.cracc and string(txb.arp.gl) matches "2237*"  no-lock no-error.
      if not avail txb.arp then do:
          find first txb.aaa where txb.aaa.aaa = txb.remtrz.cracc no-lock no-error.
          if not avail txb.aaa then next.
      end.
      if string(txb.remtrz.crgl) matches "2237*" then next.
   end.
   else if (txb.remtrz.ptype <> '4' or txb.remtrz.ptype <> '6' or txb.remtrz.ptype <> 'M' or txb.remtrz.ptype <> '3'
   or txb.remtrz.ptype <> '7') then next.

   if remtrz.drgl = 287033 or remtrz.drgl = 287034 or remtrz.drgl = 287035 or remtrz.drgl = 287036 or remtrz.drgl = 287037 or
   remtrz.drgl = 187033 or remtrz.drgl = 187034 or remtrz.drgl = 187035 or remtrz.drgl = 187036 or remtrz.drgl = 187037 then next.
   if remtrz.crgl = 287033 or remtrz.crgl = 287034 or remtrz.crgl = 287035 or remtrz.crgl = 287036 or remtrz.crgl = 287037 or
   remtrz.crgl = 187033 or remtrz.crgl = 187034 or remtrz.crgl = 187035 or remtrz.crgl = 187036 or remtrz.crgl = 187037 then next.

   find first txb.crc where txb.crc.crc = txb.remtrz.tcrc no-lock no-error.
   create t-actplat.
   assign t-actplat.plnum = trim( substring( txb.remtrz.sqn,19,8 )) + ' (' + txb.remtrz.remtrz + ')'
   t-actplat.pldt = txb.remtrz.rdt
   t-actplat.plsum = txb.remtrz.amt
   t-actplat.plcrc = txb.crc.code
   t-actplat.plrem = txb.remtrz.detpay[1] + ' ' + txb.remtrz.detpay[2] + ' ' + txb.remtrz.detpay[3] + ' ' + txb.remtrz.detpay[4].

   if (txb.remtrz.ptype = '4' or txb.remtrz.ptype = '6' or txb.remtrz.ptype = 'M') then t-actplat.plinout = 'Исходящий'.
   if (txb.remtrz.ptype = '3' or txb.remtrz.ptype = '7') then t-actplat.plinout = 'Входящий'.
   if t-actplat.plinout = 'Входящий' then t-actplat.plget = remtrz.bn[1].
   if t-actplat.plinout = 'Исходящий' then t-actplat.plget = remtrz.ord.
   t-actplat.bank = v-bank.
end.



/*find first t-actplat no-lock no-error.
if not avail t-actplat then return.*/



