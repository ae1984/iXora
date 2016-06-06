/* acc_cls1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.1.8.14
 * BASES
        TXB COMM
 * AUTHOR
        06/03/09 id00004
 * CHANGES
        25.05.2009 galina - исключила 20-тизназные счета
        27.01.10 marinav - расширение поля счета до 20 знаков
        30.03.10 id00004 - добавил группы для учета счетов KASSANOVA
        17.01.11 evseev - добавил группы для учета счетов Недропользователь 518,519,520
        30.05.11 evseev - добавил группы для учета счетов Метролюкс A22,A23,A24
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
        24.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
*/

def shared var g_date as date.
def shared var v-dbeg as date.
def shared var v-dend as date.
def shared var v-tp as integer.

def var t-aaa as char.
def var v-cls as integer.
def buffer b-aaa for txb.aaa.
def var sm as decimal.
def var smvl as decimal.
def var mnth as integer.
def buffer ss for txb.aaa.
def buffer ff for txb.lgr.
def shared temp-table t-clients
    field  cif as char
    field  name as char
    field  aaa like txb.aaa.aaa
    field  who as char
    field  whn as date
    field  whncls as date
    field  crc as integer

    field  stchet as char  /*D-депозит  T-текущий*/
    field  stpp as char  /*U-юридическое лицо P-физическое лицо*/
    field  txb as char
    field  konv as char
    field  prim as char
    field  sumvval as decimal
    field  sumvtng as decimal
    field  rte as char
    field  ddes as char.



function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for txb.crchis.
define buffer bcrc2 for txb.crchis.



if d1 = 10.01.08 or d1 = 12.01.08 then do:
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.

end.
do:
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.
end.

end.

   for each txb.aaa where txb.aaa.sta = "C" no-lock:
       v-cls = 0.


if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
          if txb.aaa.cltdt >= v-dbeg and txb.aaa.cltdt <= v-dend then v-cls = 1.
          sm = 0. smvl = 0. mnth = 0.
          run lonbal3('cif', txb.aaa.aaa, txb.aaa.cltdt - 1, "1", yes, output sm).

          mnth = month(txb.aaa.cltdt).
          if mnth <> 12 then
             mnth = mnth + 1. else mnth = 1.
             smvl = round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, date("1." + string(mnth) + "." + string(year(txb.aaa.cltdt))) ), 2).
end.
else do:
       find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
       if avail txb.aadrt then do:
          if txb.aadrt.who = "C" and txb.aadrt.whn >= v-dbeg and txb.aadrt.whn <= v-dend then v-cls = 1.
          sm = 0. smvl = 0. mnth = 0.
          run lonbal3('cif', txb.aaa.aaa, txb.aadrt.whn - 1, "1", yes, output sm).

          mnth = month(txb.aadrt.whn).
          if mnth <> 12 then
             mnth = mnth + 1. else mnth = 1.
             smvl = round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, date("1." + string(mnth) + "." + string(year(txb.aadrt.whn))) ), 2).
       end.
end.
       if v-cls <> 1 then next.


       find last txb.aaa_conv where txb.aaa_conv.aaaold = txb.aaa.aaa  no-lock no-error.
       if avail txb.aaa_conv then next. /*если он не закрылся а закрылся для конвертации то не учитываем*/


       find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error .



       find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif  and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
       if not avail txb.sub-cod then do:
          message txb.aaa.cif. pause 555.
       end.


       find last txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

       if v-tp = 1 then do:
          if lookup(txb.aaa.lgr,"A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36,A38,A39,A40") <> 0 then do:
             t-aaa = txb.aaa.aaa.

             create t-clients.
                    t-clients.konv = txb.aaa.aaa.
                    t-clients.cif = txb.aaa.cif.
                    t-clients.name = txb.cif.name.
                    t-clients.who = txb.aaa.who.
                    t-clients.whn = txb.aaa.stadt.
                    t-clients.crc = txb.aaa.crc.
                    t-clients.stchet = "D".
                    t-clients.stpp = "P".
                    t-clients.txb = txb.sysc.chval.
                    t-clients.prim = "обычный".


t-clients.sumvval = sm.
t-clients.sumvtng = smvl.

if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
t-clients.whncls = txb.aaa.cltdt.
end.
else
t-clients.whncls = txb.aadrt.whn.



                   repeat: /*выбор конвертаций*/
                      find last aaa_conv where aaa_conv.aaa = t-aaa  no-lock no-error.
                      if not avail aaa_conv then leave.
                      if avail aaa_conv then do:
                         t-clients.prim = "конвертирован".
                         t-aaa = aaa_conv.aaaold.
                      end.
                   end.
find last ss where ss.aaa = t-aaa no-lock no-error.
if avail ss then do:
    find last ff where ff.lgr = ss.lgr no-lock no-error.
   t-clients.rte = string(txb.ss.rate).
    t-clients.ddes = ff.des.
end.

                   t-clients.aaa = t-aaa.
          end.

          else
          if (txb.cif.type = "p" and txb.sub-cod.ccode <> "0") and lookup(txb.aaa.lgr,"246,151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,249") <> 0 then do:
find last ff where ff.lgr = txb.aaa.lgr no-lock no-error.
             create t-clients.
                    t-clients.konv = txb.aaa.aaa.
                    t-clients.cif = txb.aaa.cif.
                    t-clients.name = txb.cif.name.
                    t-clients.who = txb.aaa.who.
                    t-clients.whn = txb.aaa.stadt.
                    t-clients.crc = txb.aaa.crc.
                    t-clients.stchet = "T".
                    t-clients.stpp = "P".
                    t-clients.txb = txb.sysc.chval.
                    t-clients.prim = "обычный".
                    t-clients.aaa = txb.aaa.aaa.
t-clients.ddes = ff.des.
t-clients.rte = string(txb.aaa.rate).



t-clients.sumvval = sm.
t-clients.sumvtng = smvl.
if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
t-clients.whncls = txb.aaa.cltdt.
end.
else
t-clients.whncls = txb.aadrt.whn.


          end.
      end.
      else

      if v-tp = 2 then do:
         if (txb.cif.type = "b" or (txb.cif.type = "p" and txb.sub-cod.ccode = "0")) and lookup(txb.aaa.lgr,"151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,176,177,130,131,132,137,142") <> 0 then do:
find last ff where ff.lgr = txb.aaa.lgr no-lock no-error.
             t-aaa = txb.aaa.aaa.
             create t-clients.

                    t-clients.cif = txb.aaa.cif.
                    t-clients.name = txb.cif.name.
                    t-clients.who = txb.aaa.who.
                    t-clients.whn = txb.aaa.stadt.
                    t-clients.crc = txb.aaa.crc.
                    t-clients.stchet = "T".
                    t-clients.stpp = "U".
                    t-clients.txb = txb.sysc.chval.
                    t-clients.prim = "обычный".
                    t-clients.aaa = txb.aaa.aaa.
t-clients.ddes = ff.des.
t-clients.rte = string(txb.aaa.rate).

t-clients.sumvval = sm.
t-clients.sumvtng = smvl.
if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
t-clients.whncls = txb.aaa.cltdt.
end.
else
t-clients.whncls = txb.aadrt.whn.


         end.

         if lookup(txb.aaa.lgr,"484,485,486,487,488,489,478,479,480,481,482,483,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 then do:
find last ff where ff.lgr = txb.aaa.lgr no-lock no-error.
            t-aaa = txb.aaa.aaa.
            create t-clients.
                   t-clients.cif = txb.aaa.cif.
                   t-clients.name = txb.cif.name.
                   t-clients.who = txb.aaa.who.
                   t-clients.whn = txb.aaa.stadt.
                   t-clients.crc = txb.aaa.crc.
                   t-clients.stchet = "D".
                   t-clients.stpp = "U".
                   t-clients.txb = txb.sysc.chval.
                   t-clients.prim = "обычный".
                   t-clients.aaa = txb.aaa.aaa.
t-clients.ddes = ff.des.
t-clients.rte = string(txb.aaa.rate).

t-clients.sumvval = sm.
t-clients.sumvtng = smvl.
if v-dbeg < 03.01.09  or v-dend < 03.01.09 then do:
t-clients.whncls = txb.aaa.cltdt.
end.
else
t-clients.whncls = txb.aadrt.whn.


         end.
      end.
   end.


procedure lonbal3.

define input  parameter p-sub like txb.trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like txb.jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc no-lock:
         if lookup(string(txb.trxbal.level), p-lvls) > 0 then do:

            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.trxbal.dam - txb.trxbal.cam.
	    else res = res + txb.trxbal.cam - txb.trxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
	    for each txb.jl where txb.jl.acc = p-acc
                          and txb.jl.jdt >= p-dt
                          and txb.jl.lev = 1 no-lock:
	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res - txb.jl.dam + txb.jl.cam.
            else res = res + txb.jl.dam - txb.jl.cam.
            end.

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last txb.histrxbal where txb.histrxbal.subled = p-sub
                              and txb.histrxbal.acc = p-acc
                              and txb.histrxbal.level = integer(entry(i, p-lvls))
                              and txb.histrxbal.dt <= p-dt no-lock no-error.
        if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = integer(entry(i, p-lvls))
                                 and txb.histrxbal.dt < p-dt no-lock no-error.
       if avail txb.histrxbal then do:
            find txb.b-aaa where txb.b-aaa.aaa = p-acc no-lock no-error.
            if not avail txb.b-aaa then return.

	    find txb.trxlevgl where txb.trxlevgl.gl     eq txb.b-aaa.gl
                            and txb.trxlevgl.subled eq p-sub
                            and lookup(string(txb.trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail txb.trxlevgl then return.

	    find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
	    if not avail txb.gl then return.

	    if txb.gl.type eq "A" or txb.gl.type eq "E" then res = res + txb.histrxbal.dam - txb.histrxbal.cam.
	    else res = res + txb.histrxbal.cam - txb.histrxbal.dam.

	    find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic"
	                   and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
	    if available txb.sub-cod and txb.sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.

end.