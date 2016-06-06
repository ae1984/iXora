/* PD1_ps.p
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

 {global.i}
 {lgps.i }
def var exitcod as cha .
def var brnch as log initial false . 
def shared var n-list as int . 
def var vsh as inte initial 5.
def var v-qqqq as char initial ',' format "x(1)".

def var v-sqn as cha .
def var buf as cha .
def buffer our for sysc .
def stream m-doc.

def var v-rbank like remtrz.rbank .
def var v-mudate as char format "x(20)".  /* v-valdt ? */
def var v-ref  as char format "x(12)".
def var v-m1 as char format "x(32)".  /* v-ord */
def var v-m2 as char format "x(43)".  /* v-ord */
def var v-m3 as char format "x(43)".  /* v-ord */
def var v-bm1 as char format "x(28)". /* v-ordins */
def var v-bm2 as char format "x(43)". /* v-ordins */
def var v-bm3 as char format "x(43)". /* v-ordins */
def var v-bbbb as char format "x(43)".
def var v-crccode like crc.code.
def var v-km as char format "x(15)".  /* номер счета плательщика */
def var v-km1 as char format "x(15)".  /* номер счета плательщика */
def var v-kbm as char format "x(9)".  /* код банка плательщика */
def var v-sm as char format "x(16)".  /* v-payment */
def var v-s1 as char format "x(33)".  /* v-bn */
def var v-s2 as char format "x(43)".  /* v-bn */
def var v-s3 as char format "x(43)".  /* v-bn */
def var v-bs1 as char format "x(28)".  /* v-bb */
def var v-bs2 as char format "x(43)".  /* v-bb */
def var v-bs3 as char format "x(43)".  /* v-bb */
def var v-ks as char format "x(15)".   /* v-ba */
def var v-ks1 as char format "x(15)".  /* v-ba */
def var v-ks3 as  char  format "x(15)".
def var v-kbs as char format "x(9)".   /* v-bb */
def var v-strtmp as char.
def var v-detpay like remtrz.detpay.
def var v-rcvinfo like remtrz.rcvinfo.
def var v-sumt as char extent 6 format "x(56)".
def var v-numurs as char format "x(19)".
def var ourbcode like sysc.chval.
def var ourbank like sysc.chval.


find sysc where sysc.sysc = "CLECOD" no-lock no-error.
 if not avail sysc then do:
   v-text = " Записи CLECOD нет в файле sysc  " .  run lgps.
   return .
 end.
 ourbcode = trim(sysc.chval).

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Записи OURBNK нет в файле sysc !! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "clcen" no-lock no-error .
if avail sysc and trim(sysc.chval) ne trim(ourbank) then  brnch = true .

 do transaction :
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".

   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .

   /*  Beginning of main program body */

 find jh where jh.jh = remtrz.jh1 no-lock no-error.
 if not available jh then do :
   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "1".
   v-text = " 1TRX is absent for remtrz " + remtrz.remtrz.
   run lgps.
   return.
 end.

 /* KOVAL 
find first sysc where sysc.sysc = "PR-DIR" no-lock no-error .
 if not avail sysc then do:
  v-text = " Записи PR-DIR нет в файле sysc  " .  run lgps.
  return .
 end.

 if search ( sysc.chval + "/PDPR1.log" )
        <> ( sysc.chval + "/PDPR1.log" )
 then 
  do:
   output stream m-doc to value( sysc.chval + "/PDPR1.log" ) .
   n-list = 1 . 
  end.
 else output stream m-doc to value( sysc.chval + "/PDPR1.log" ) append .

def var vdatu as char format "x(13)".
def var i as int.
def var j as int.
def var ij as int.

run stampdatp(output vdatu).

find crc where crc.crc = remtrz.tcrc no-lock.
 /*
 v-mudate = string(jh.jdt) . /*Дата платежки*/
 */
 v-mudate = string(remtrz.rdt) .
 v-ref = remtrz.remtrz.

 v-numurs = trim(substring(remtrz.sqn,19)).
 if v-numurs <> ' ' then
 v-ref = '(' + v-ref + ')'.
 else do:
 v-numurs = v-ref.
 v-ref = ''.
 end.
  v-numurs = "Nr." + v-numurs.
 v-m1 = substr(remtrz.ord,1,35)
 + " " + substr(remtrz.ord,36,35)
 + " " + substr(remtrz.ord,71,35)
 + " " + substr(remtrz.ord,104,35)
 + " " .
v-m2 = v-m1.
 v-m1 = substring(v-m1,1,32).
 i = r-index(v-m1," ").
 if i ne 0 then do:
    v-m1 = substring(v-m1,1,i - 1).
    v-m2 = substring(v-m2,i + 1).
 end.
 else  v-m2 = substring(v-m2,33).

 v-m3 = v-m2.
 v-m2 = substring(v-m2,1,43).
 i = r-index(v-m2," ").
 if i ne 0 then do:
    v-m2 = substring(v-m2,1,i - 1).
    v-m3 = substring(v-m3,i + 1).
 end.
 else  v-m3 = substring(v-m3,77).


v-bm1 = remtrz.ordins[1] + " "
+ " " + remtrz.ordins[2] + " " + remtrz.ordins[3] + " " + remtrz.ordins[4].
v-bbbb = v-bm1.

v-bm2 = v-bm1.
v-bm1 = substring(v-bm1,1,29).
i = r-index(v-bm1," ").
if i ne 0 then do:
    v-bm1 = substring(v-bm1,1,i - 1).
    v-bm2 = substring(v-bm2,i + 1).
end.
else  v-bm2 = substring(v-bm2,29,43).

v-bm3 = v-bm2.
v-bm2 = substring(v-bm2,1,43).
i = r-index(v-bm2," ").
if i ne 0 then do:
    v-bm2 = substring(v-bm2,1,i - 1).
    v-bm3 = substring(v-bm3,i + 1).
end.
else  v-bm3 = substring(v-bm3,73).

v-crccode = crc.code.

  v-kbm = ourbcode.

/*  
  v-km = trim(remtrz.dracc).
*/

if remtrz.sacc ne "" then  v-km = trim(remtrz.sacc) . 
 else v-km = trim(remtrz.dracc) .
 v-km1 = v-km.
if index(v-km1,"/") ne 0 then do :
        v-km = entry(1,v-km,"/").
        v-km1 = entry(2,v-km1,"/").
end.
else do:
       if index(v-km1," ") ne 0 then do:
          v-km  = entry(1,v-km," ").
          v-km1 = entry(2,v-km1," ").
       end. 
  else do:
   if length(v-km1) > 15 then do:
      v-km1 = substr(v-km1,16,15).
      v-km  = substr(v-km,1,15). 
      end.
  else
    v-km1 = " ".
  end.
end.
 

  
 v-sm = string(remtrz.payment,">>>>>>>>>>>>9.99").
 v-s1 = remtrz.bn[1] + " " + remtrz.bn[2] + " " + remtrz.bn[3] + " ".
 v-s2 = v-s1.
 v-s1 = substring(v-s1,1,34).
 i = r-index(v-s1," ").
 if i ne 0 then do:
    v-s1 = substring(v-s1,1,i - 1).
    v-s2 = substring(v-s2,i + 1).
 end.
 else v-s2 = substring(v-s2,34,43).

 v-s3 = v-s2.
 v-s2 = substring(v-s2,1,43).
 i = r-index(v-s2," ").
 if i ne 0 then do:
    v-s2 = substring(v-s2,1,i - 1).
    v-s3 = substring(v-s3,i + 1).
 end.
 else v-s3 = substring(v-s3,78).

 find bankl where bankl.bank = remtrz.rbank no-lock no-error.
 if available bankl and bankl.bank = ourbank then v-bs1 = v-bbbb.
 else
 v-bs1 = substr(remtrz.bb[1],2) + " " + remtrz.bb[2] + " "
        + remtrz.bb[3] + " ".

  v-bs2 = v-bs1.
 v-bs1 = substring(v-bs1,1,29).
 i = r-index(v-bs1," ").
 if i ne 0 then do:
    v-bs1 = substring(v-bs1,1,i - 1).
    v-bs2 = substring(v-bs2,i + 1).
 end.
 else  v-bs2 = substring(v-bs2,29,43).
 v-bs3 = v-bs2.
 v-bs2 = substring(v-bs2,1,43).
 i = r-index(v-bs2," ").
 if i ne 0 then do:
    v-bs2 = substring(v-bs2,1,i - 1).
    v-bs3 = substring(v-bs3,i + 1).
 end.
 else  v-bs3 = trim(substring(v-bs3,73)).


if substr(remtrz.ba,1,1) = "/" then v-ks = trim(substr(remtrz.ba,2)).
else v-ks = trim(remtrz.ba).

v-ks1 = v-ks.
if index(v-ks1,"/") ne 0 then do :
    v-ks = substring(v-ks,1,index(v-ks,"/") - 1).
    v-ks1 = substring(v-ks1,index(v-ks1,"/") + 1).
    if index (v-ks1,"/") ne 0 then do :
       v-ks3 =  v-ks1.
       v-ks1 = substr(v-ks1,1,index(v-ks1,"/") - 1).
       v-ks3 = substr(v-ks3,index(v-ks3,"/") +  1).
    end.
end.
else do:
       if index(v-ks1," ") ne 0 then do:
          v-ks = substring(v-ks,1,index(v-ks," ") - 1).
          v-ks1 = substring(v-ks1,index(v-ks1," ") + 1).
             if index (v-ks1," ") ne 0 then do :
               v-ks3 =  v-ks1.
               v-ks1 = substr(v-ks1,1,index(v-ks1," ") - 1).
               v-ks3 = substr(v-ks3,index(v-ks3," ") +  1).
             end.
       end.
  else do:
     if length(v-ks1) > 15 then do:
       v-ks3 = substr(v-ks,31,15).
       v-ks1 = substr(v-ks,16,15).
       v-ks  = substr(v-ks,1,15).
     end.
     else
     v-ks1 = " ".
  end.
end.

/*
v-kbs = substring(rem.actinsact,1,10).
*/

v-kbs = ourbcode.

run Sm-vrd(input truncate(remtrz.payment,0),output v-strtmp).
v-strtmp = v-strtmp + " " + substring(v-crccode,1,3) +
string(remtrz.payment - truncate(remtrz.payment,0),".99")
 + ".".

i = 1.
v-sumt[1] = "" .
j = 4.
repeat while i <= 2:
    ij = index(v-strtmp," ").
    if ij = 0 then ij = length(v-strtmp).
    if j + ij > 56 then do:
        i = i + 1.
        j = 0 .
    end.
    v-sumt[i] = v-sumt[i] + substring(v-strtmp,1,ij).
    j = j + ij.
    v-strtmp = substring(v-strtmp,ij + 1).
    if length(v-strtmp) = 0 then leave.
end.

v-detpay[1] = remtrz.detpay[1].
v-detpay[2] = remtrz.detpay[2].
v-detpay[3] = remtrz.detpay[3].
v-detpay[4] = remtrz.detpay[4].

v-rcvinfo[1] = remtrz.rcvinfo[1] .
v-rcvinfo[2] = remtrz.rcvinfo[2] .
v-rcvinfo[3] = remtrz.rcvinfo[3] .
v-rcvinfo[4] = remtrz.rcvinfo[4] .
v-rcvinfo[5] = remtrz.rcvinfo[5] .
v-rcvinfo[6] = remtrz.rcvinfo[6] .

v-rbank = remtrz.rbank .
if v-rbank begins "RKB" then v-rbank = ourbcode .


 {ppmuj2.f} 

pause 0.
output close .

KOVAL */

   /*  End of program body */

   que.dp = today.
   que.tp = time.
   que.con = "F".
   que.rcod = "0".
  /* v-text = " Payment document was formed for remtrz " + remtrz.remtrz.
   run lgps. */
   release remtrz.
  end.
 end.
