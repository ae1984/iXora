/* 13lv_r.p
 * MODULE
        Депозитарий
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM TXB
 * AUTHOR
        28/04/08 bankadm
 * CHANGES
        25.05.2009 galina - исключила 20-тизназные счета
        30.03.10 id00004 - добавил группы для учета счетов KASSANOVA
        30.05.11 evseev - добавил группы для учета счетов Метролюкс A22,A23,A24
*/






def shared var g_date as date.
def shared var d_date as date.
def shared var v-paramt as integer.

def buffer b-aaa for txb.aaa.
def var v-idep as integer.

def var ttts as integer.

def shared temp-table t-zzz
       field  txb as char
       field  crc as integer
       field  sum as decimal
       field  rate as decimal
       field  lgr as char
       field  dep as integer
       field  ppoint as char
       field type as char
       field  ddt as date
       field  jur as char
       field  luksK as integer
       field  luksS as decimal
       field  vipK as integer
       field  vipS as decimal
       field  classK as integer
       field  classS as decimal
       field  standK as integer
       field  standS as decimal
       field  supeK as integer
       field  supeS as decimal
       field  metroK as integer
       field  metroS as decimal
       field  pensK as integer
       field  pensS as decimal
       field  kztK_ur as integer
       field  kztS_ur as decimal
       field  usdK_ur as integer
       field  usdS_ur as decimal
       field  eurK_ur as integer
       field  eurS_ur as decimal
       field  rubK_ur as integer
       field  rubS_ur as decimal
       field  kztK_fz as integer
       field  kztS_fz as decimal
       field  usdK_fz as integer
       field  usdS_fz as decimal
       field  eurK_fz as integer
       field  eurS_fz as decimal
       field  rubK_fz as integer
       field  rubS_fz as decimal
       field  nakK as integer
       field  nakS as decimal
       field  srochK as integer
       field  citi as char
       field  srochS as decimal.

def buffer bss for txb.sysc.


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






def var sm as decimal.
def var vpoint as integer.



def var dtt as date.
def var dttcnt as date.
def var v-accept as integer.
def var v-cls as integer.


           if v-paramt = 2 then   dttcnt = 03.17.08.
           if v-paramt = 1 then   dttcnt = date("8." + string(month(g_date)) + "." + string(year(g_date))).

do dtt = 03.17.08 to g_date:




              v-accept = 0.
              if v-paramt = 2 then do: /*Еженедельный */

                 if dttcnt = dtt then do:
                    dttcnt = dtt + 7.
                    v-accept = 1.
                 end.
              end.
              if v-paramt = 1 then do: /*Ежемесячный*/
                if day(dtt) = 1  then  v-accept = 1.
                else do:
                   if month(g_date) = month(dtt) and day(dtt) <> 1 then do:
                      if dttcnt = dtt then do:
                         dttcnt = dtt + 7.
                         v-accept = 1.
                      end.
                   end.
                end.

              end.


   if v-accept = 1 then do: /*формируем отчет за данную дату*/


      find last txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.

      find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= dtt no-lock no-error.



 for each txb.ppoint no-lock:
      if txb.sysc.chval <> "TXB16" then do:
         if txb.ppoint.depart > 1 then next.
      end.


       find last bss where bss.sysc = "citi" no-lock no-error.
       if not avail bss then do:
       message txb.sysc.chval. pause 444.
       end.

      create t-zzz.
             t-zzz.txb = txb.sysc.chval.
             t-zzz.ddt = dtt.
             t-zzz.rate = txb.crchis.rate[1].
             t-zzz.ppoint = txb.ppoint.name.
             t-zzz.dep = txb.ppoint.depart.
             t-zzz.citi = bss.chval.


       for each txb.aaa where txb.aaa.stadt < dtt /* and txb.aaa.sta <> "C" or (txb.aaa.sta = "C" and txb.aaa.aaa = "199759319") */  no-lock:
           /*galina временно до перехода на 20-тизначные счета*/
/*           if length(txb.aaa.aaa) = 20 then next. */
           v-cls = 0.
           find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
           if not avail txb.cif then next.
              if txb.cif.jame <> '' then do:
                 vpoint = integer(txb.cif.jame) / 1000 - 0.5.
                 v-idep = integer(txb.cif.jame) - vpoint * 1000.
              end. else
              do:
                find last txb.ofchis where txb.ofchis.ofc = txb.aaa.who no-lock.
                v-idep = txb.ofchis.dep.
              end.


              if txb.sysc.chval = "TXB16" then do:
                 if txb.ppoint.depart <> v-idep then do:
                    next.
                 end.
              end.

/*Изменил чтобы данные бились с другими отчетами операционного департамента*/

/*if txb.aaa.sta = "C" then v-cls = 1. */

/*
if txb.aaa.sta = "C" then do:
   if txb.aaa.whn = aaa.regdt then do:
      if txb.aaa.ddt < dtt then v-cls = 1.
   end.
   else
   do:
      if txb.aaa.whn < dtt then v-cls = 1.
   end.
end.
*/

find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa no-lock no-error.
if avail txb.aadrt then do:
  if txb.aadrt.who = "C" and txb.aadrt.whn < dtt then v-cls = 1.
end.
else do:
/*   message "ОШИБКА 125:  Счет закрыт некорректно возможны расхождения.". pause.  */
end.





/*           if lookup(txb.aaa.lgr,"A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36") <> 0 then do:
                 find last txb.cls no-lock no-error.
               if (txb.aaa.cltdt < dtt and  txb.aaa.cltdt < txb.cls.whn) then do:
                   v-cls = 1.
                 end.
              end.
              else
              do:
                 if txb.aaa.cltdt <> ? then do:
                    if txb.aaa.cltdt < dtt then v-cls = 1.
                 end.

              end.
*/




              sm = 0.
              run lonbal3('cif', txb.aaa.aaa, dtt - 1, "1", yes, output sm).

              find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif  and txb.sub-cod.d-cod = "clnsts" no-lock no-error.
              if not avail txb.sub-cod then do:
                 message txb.cif.cif. pause 555.
              end.


             if lookup(txb.aaa.lgr,"A01,A02,A03,A04,A05,A06") <> 0 then do: /*стандарт*/
                if v-cls <> 1 then t-zzz.standK = t-zzz.standK + 1.
                t-zzz.standS = t-zzz.standS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.


             if lookup(txb.aaa.lgr,"A13,A14,A15") <> 0 then do: /*классик*/
                if v-cls <> 1 then t-zzz.classK = t-zzz.classK + 1.
                t-zzz.classS = t-zzz.classS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.

             if lookup(txb.aaa.lgr,"A19,A20,A21,A22,A23,A24") <> 0 then do: /*Люкс*/
                if v-cls <> 1 then t-zzz.luksK = t-zzz.luksK + 1.
                t-zzz.luksS = t-zzz.luksS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.


             if lookup(txb.aaa.lgr,"A25,A26,A27") <> 0 then do: /*vip*/
                if v-cls <> 1 then t-zzz.vipK = t-zzz.vipK + 1.
                t-zzz.vipS = t-zzz.vipS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.



             if lookup(txb.aaa.lgr,"A28,A29,A30") <> 0 then do: /*супер*/
                if v-cls <> 1 then t-zzz.supeK = t-zzz.supeK + 1.
                t-zzz.supeS = t-zzz.supeS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.

             if lookup(txb.aaa.lgr,"A31,A32,A33") <> 0 then do: /*метрошка*/
                if v-cls <> 1 then t-zzz.metroK = t-zzz.metroK + 1.
                t-zzz.metroS = t-zzz.metroS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.

             if lookup(txb.aaa.lgr,"A34,A35,A36") <> 0 then do: /*пенсионный*/
                if v-cls <> 1 then t-zzz.pensK = t-zzz.pensK + 1.
                t-zzz.pensS = t-zzz.pensS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
             end.



            /*текущие юр лиц*/
            if (txb.cif.type = "b" or (txb.cif.type = "p" and txb.sub-cod.ccode = "0")) and lookup(txb.aaa.lgr,"151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,249,250") <> 0 then do:

                if txb.aaa.crc = 1 then do:
                   if v-cls <> 1 then t-zzz.kztK_ur = t-zzz.kztK_ur + 1.
                   t-zzz.kztS_ur = t-zzz.kztS_ur + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
                end.
                if txb.aaa.crc = 2 then do:
                   if v-cls <> 1 then t-zzz.usdK_ur = t-zzz.usdK_ur + 1.
                   t-zzz.usdS_ur = t-zzz.usdS_ur + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
                end.
                if txb.aaa.crc = 3 then do:
                   if v-cls <> 1 then t-zzz.eurK_ur = t-zzz.eurK_ur + 1.
                   t-zzz.eurS_ur = t-zzz.eurS_ur + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
                end.

                if txb.aaa.crc = 4 then do:
                   if v-cls <> 1 then t-zzz.rubK_ur = t-zzz.rubK_ur + 1.
                   t-zzz.rubS_ur = t-zzz.rubS_ur + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
                end.
/*
if dtt = 03.24.08 then do:
message t-zzz.kztK_ur + t-zzz.usdK_ur + t-zzz.eurK_ur + .
pause 444.
end.
*/

            end.




           if (txb.cif.type = "p" and txb.sub-cod.ccode <> "0") and lookup(txb.aaa.lgr,"246,151,152,153,154,155,156,157,158,171,172,173,204,202,208,222,232,242,247,248,249,250") <> 0 then do:
               if txb.aaa.crc = 1 then do:
                  if v-cls <> 1 then t-zzz.kztK_fz = t-zzz.kztK_fz + 1.
                  t-zzz.kztS_fz = t-zzz.kztS_fz + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
               end.
               if txb.aaa.crc = 2 then do:
                  if v-cls <> 1 then t-zzz.usdK_fz = t-zzz.usdK_fz + 1.
                  t-zzz.usdS_fz = t-zzz.usdS_fz + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
               end.
               if txb.aaa.crc = 3 then do:
                  if v-cls <> 1 then t-zzz.eurK_fz = t-zzz.eurK_fz + 1.
                  t-zzz.eurS_fz = t-zzz.eurS_fz + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
               end.

               if txb.aaa.crc = 4 then do:
                  if v-cls <> 1 then t-zzz.rubK_fz = t-zzz.rubK_fz + 1.
                  t-zzz.rubS_fz = t-zzz.rubS_fz + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1),2).
               end.
           end.


           if lookup(txb.aaa.lgr,"484,485,486,487,488,489") <> 0 then do: /*Депозиты юр лиц Накопительный*/

              if v-cls <> 1 then t-zzz.nakK = t-zzz.nakK + 1.
              t-zzz.nakS = t-zzz.nakS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1), 2).
           end.

           if lookup(txb.aaa.lgr,"478,479,480,481,482,483") <> 0 then do: /*Депозиты юр лиц Срочный*/
              if v-cls <> 1 then t-zzz.srochK = t-zzz.srochK + 1.
              t-zzz.srochS = t-zzz.srochS + round(crc-crc-date(decimal(sm), txb.aaa.crc, 1, dtt - 1), 2).
           end.

       end. /*for each txb*/

       end. /*for each ppoint*/

   end. /* v-accept = 1 */
end.  /* dtt = 03.17.08 to g_date */








































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







