/* acc_opn2.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Отчет по депозитам по одному филиалу.
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
        BANK COMM
 * AUTHOR
        27/05/2011 dmitriy
 * CHANGES
        01/06/2011 evseev - добавил группы A22 A23 A24
        03.07.2012 Lyubov - добавила валюту ZAR
        10.08.2012 Lyubov - добавила валюту CAD
*/

def shared var g_date as date.
def shared var v-dbeg as date.
def shared var v-dend as date.
def shared var v-tp as integer.

def var t-aaa as char.
def var sm as decimal.
def var smvl as decimal.
def var mnth as integer.
def buffer b-aaa for aaa.
def buffer b-sub-cod for sub-cod.

def shared temp-table t-clients
    field  cif as char
    field  name as char
    field  aaa like aaa.aaa
    field  who as char
    field  whn as date
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
define buffer bcrc1 for crchis.
define buffer bcrc2 for crchis.

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

   for each aaa where aaa.stadt >= v-dbeg and aaa.stadt <= v-dend no-lock:

       if aaa.stadt <> aaa.regdt then next.      /* исключаем конвертированные */

       find last cif where cif.cif = aaa.cif no-lock no-error .

       find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif  and sub-cod.d-cod = "clnsts" no-lock no-error.
       if not avail sub-cod then do:
          message cif.cif. pause 555.
       end.

          sm = 0. smvl = 0. mnth = 0.

          run lonbal3('cif', aaa.aaa, aaa.stadt, "1", yes, output sm).

          mnth = month(aaa.stadt).
          if mnth <> 12 then
             mnth = mnth + 1. else mnth = 1.

           smvl = round(crc-crc-date(decimal(sm), aaa.crc, 1, date("1." + string(mnth) + "." + string(year(aaa.stadt))) ), 2).

       find last sysc where sysc.sysc = "ourbnk" no-lock no-error.
find last lgr where lgr.lgr = aaa.lgr no-lock.
       if v-tp = 1 then do:
          if lookup(aaa.lgr,"A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36") <> 0 then do:
             t-aaa = aaa.aaa.
             create t-clients.
                    t-clients.konv = aaa.aaa.
                    t-clients.cif = aaa.cif.
                    t-clients.name = cif.name.
                    t-clients.who = aaa.who.
                    t-clients.whn = aaa.stadt.
                    t-clients.crc = aaa.crc.
                    t-clients.stchet = "D".
                    t-clients.stpp = "P".
                    t-clients.txb = sysc.chval.
                    t-clients.prim = "обычный".
                    t-clients.aaa = aaa.aaa.
t-clients.rte = string(aaa.rate).
t-clients.ddes = lgr.des.

                    find last aaa_conv where aaa_conv.aaaold = aaa.aaa  no-lock no-error.
                    if avail aaa_conv then do:
                       t-clients.prim = "конвертирован".
                    end.
    t-clients.sumvval = sm.
    t-clients.sumvtng = smvl.

          end.
          else
          if (cif.type = "p" and sub-cod.ccode <> "0") and lookup(aaa.lgr,"246,151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,249") <> 0 then do:
             create t-clients.
                    t-clients.konv = aaa.aaa.
                    t-clients.cif = aaa.cif.
                    t-clients.name = cif.name.
                    t-clients.who = aaa.who.
                    t-clients.whn = aaa.stadt.
                    t-clients.crc = aaa.crc.
                    t-clients.stchet = "T".
                    t-clients.stpp = "P".
                    t-clients.txb = sysc.chval.
                    t-clients.prim = "обычный".
                    t-clients.aaa = aaa.aaa.
t-clients.rte = string(aaa.rate).
t-clients.ddes = lgr.des.

t-clients.sumvval = sm.
t-clients.sumvtng = smvl.

          end.
      end.
      else

      if v-tp = 2 then do:
         if (cif.type = "b" or (cif.type = "p" and sub-cod.ccode = "0")) and lookup(aaa.lgr,"151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,160,161,176,177,130,131,132,137,142") <> 0 then do:

             t-aaa = aaa.aaa.
             create t-clients.

                    t-clients.cif = aaa.cif.
                    t-clients.name = cif.name.
                    t-clients.who = aaa.who.
                    t-clients.whn = aaa.stadt.
                    t-clients.crc = aaa.crc.
                    t-clients.stchet = "T".
                    t-clients.stpp = "U".
                    t-clients.txb = sysc.chval.
                    t-clients.prim = "обычный".
                    t-clients.aaa = aaa.aaa.
t-clients.rte = string(aaa.rate).
t-clients.ddes = lgr.des.

t-clients.sumvval = sm.
t-clients.sumvtng = smvl.

         end.

         if lookup(aaa.lgr,"484,485,486,487,488,489,478,479,480,481,482,483,518,519,520") <> 0 then do:
            t-aaa = aaa.aaa.
            create t-clients.
                   t-clients.cif = aaa.cif.
                   t-clients.name = cif.name.
                   t-clients.who = aaa.who.
                   t-clients.whn = aaa.stadt.
                   t-clients.crc = aaa.crc.
                   t-clients.stchet = "D".
                   t-clients.stpp = "U".
                   t-clients.txb = sysc.chval.
                   t-clients.prim = "обычный".
                   t-clients.aaa = aaa.aaa.
t-clients.rte = string(aaa.rate).
t-clients.ddes = lgr.des.

t-clients.sumvval = sm.
t-clients.sumvtng = smvl.

         end.
      end.
   end.

procedure lonbal3.

define input  parameter p-sub like trxbal.subled.
define input  parameter p-acc as char.
define input  parameter p-dt like jl.jdt.
define input  parameter p-lvls as char.
define input  parameter p-includetoday as logi.
define output parameter res as decimal.

def var i as integer.

res = 0.

if p-dt > g_date then p-dt = g_date. /*return.*/

if p-includetoday then do: /* за дату */
  if p-dt = g_date then do:
     for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
         if lookup(string(trxbal.level), p-lvls) > 0 then do:

            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + trxbal.dam - trxbal.cam.
	    else res = res + trxbal.cam - trxbal.dam.

	    find b-sub-cod where b-sub-cod.sub eq "gld" and b-sub-cod.d-cod eq "gldic"
	                   and b-sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available b-sub-cod and b-sub-cod.ccode eq "01" then res = - res.

	    /* ------------------------------------------------------------ */
	    for each jl where jl.acc = p-acc
                          and jl.jdt >= p-dt
                          and jl.lev = 1 no-lock:
	    if gl.type eq "A" or gl.type eq "E" then res = res - jl.dam + jl.cam.
            else res = res + jl.dam - jl.cam.
            end.

         end.
     end.
  end.
  else do:
     do i = 1 to num-entries(p-lvls):
        find last histrxbal where histrxbal.subled = p-sub
                              and histrxbal.acc = p-acc
                              and histrxbal.level = integer(entry(i, p-lvls))
                              and histrxbal.dt <= p-dt no-lock no-error.
        if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find b-sub-cod where b-sub-cod.sub eq "gld" and b-sub-cod.d-cod eq "gldic"
	                   and b-sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available b-sub-cod and b-sub-cod.ccode eq "01" then res = - res.

        end.
     end.
  end.
end. /* if p-includetoday */
else do: /* на дату */
   do i = 1 to num-entries(p-lvls):
       find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                 and histrxbal.dt < p-dt no-lock no-error.
       if avail histrxbal then do:
            find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
            if not avail b-aaa then return.

	    find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                            and trxlevgl.subled eq p-sub
                            and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
            if not avail trxlevgl then return.

	    find gl where gl.gl eq trxlevgl.glr no-lock no-error.
	    if not avail gl then return.

	    if gl.type eq "A" or gl.type eq "E" then res = res + histrxbal.dam - histrxbal.cam.
	    else res = res + histrxbal.cam - histrxbal.dam.

	    find b-sub-cod where b-sub-cod.sub eq "gld" and b-sub-cod.d-cod eq "gldic"
	                   and b-sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
	    if available b-sub-cod and b-sub-cod.ccode eq "01" then res = - res.

       end.
   end.
end.

end.