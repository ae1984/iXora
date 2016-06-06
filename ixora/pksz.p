/* pksz.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Формирование СЗ на реструктуризацию, рефинансирование и списание комиссии
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        15/10/2009 galina
 * BASES
        BANK COMM
 * CHANGES
       24/11/2009 galina - не перевожу сумму дохода в decimal
       11/02/2010 galina - добавила информацию по погашению текущего кредита и историю по погашенным кредитам
       12/02/2010 galina - поправила историю оплаты ОД
       07/04/2010 galina - сумму по процентам берем из графика
       29/04/2010 galina - добавила дни просрочки по %% и провизии
       19/10/2010 madiyar - изменения по тексту; поменялся директор ДМиВК
       29/10/2010 madiyar - добавил отсроченную неустойку
*/

{global.i}

{comm-txb.i}
{sysc.i}

def shared var s-lon like lon.lon.
def var v-credtype as char no-undo.
def var v-select as integer no-undo.
def var v-dirname as char no-undo.
def var v-dirname1 as char no-undo.
def var v-date as char no-undo.
def var v-clname as char no-undo.
def var v-proc1 as char no-undo.
def var v-proc2 as char no-undo.
def var v-proc3 as char no-undo.
def var v-cradtype  as char no-undo.
def var v-crc as char no-undo.
def var v-sum as deci no-undo.
def var v-rate as deci no-undo.
def var v-strdt as char no-undo.
def var v-expdt as char no-undo.
def var v-plod as deci no-undo.
def var v-plprc as deci no-undo.
def var v-plcom as deci no-undo.
def var v-daypros as char no-undo.
def var v-sumod as deci no-undo.
def var v-prosprc as deci no-undo.
def var v-prosod as deci no-undo.
def var v-totsum as deci no-undo.
def var v-prc as deci no-undo.
def var v-nbalprc as deci no-undo.
def var v-comdolg as deci no-undo.
def var v-pen as deci no-undo.
def var v-balpen as deci no-undo.
def var v-nbalpen as deci no-undo.

def var v-penot as deci no-undo.
def var v-penotdt0 as date no-undo.
def var v-penotdt as char no-undo.

def var v-jbname as char no-undo.
def var v-trade as char no-undo.
def var v-family as char no-undo.
def var v-mprof as char no-undo.
def var v-othprofit as char no-undo.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-ourbank as char no-undo.
def var v-dog as char no-undo.
def var v-clcode as char no-undo.
def var v-str as char no-undo.
def var v-penoplat as deci no-undo.
def var v-pendel as deci no-undo.
def var v-ofc as char no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-sumtot_od as deci no-undo.
def var v-sumtot_prc as deci no-undo.
def var v-realp as char no-undo.
def var v-movp as char no-undo.


def var v-crcold as char no-undo.
def var v-sumold as deci no-undo.
def var v-rateold as deci no-undo.
def var v-strdtold as char no-undo.
def var v-expdtold as char no-undo.
def var v-plodold as deci no-undo.
def var v-plprcold as deci no-undo.
def var v-plcomold as deci no-undo.
def var v-plsumold as deci no-undo.
def var v-dayold as intege no-undo.
def var v-penoplold as deci no-undo.
def var v-pendelold as deci no-undo.
def var v-bal as deci no-undo.
def var v-pay as longchar.
def var k as integer.
def var v-provsum as deci no-undo.
def var v-provprc as integer no-undo.

def temp-table t-plat
    field num as integer
    field dt_od as date
    field od as deci
    field dt_prc as date
    field prc as deci
    field jh like jl.jh
    index num num.

def buffer b-jl for jl.
def stream v-out.
def buffer b-lon for lon.
def buffer b-lnsch for lnsch.
def buffer b-lnsci for lnsci.

v-ourbank = comm-txb().

v-select = 0.
run sel2 (" СЛУЖЕБНЫЕ ЗАПИСКИ ", " 1. СЗ на рефинансирование| 2. СЗ на реструктуризацию| 3. СЗ по переносу неустойки| ВЫХОД ", output v-select).
if v-select = 0 then return.
if v-select = 1 then v-infile = "/data/docs/pksz.htm".
if v-select = 2 or v-select = 3 then v-infile = "/data/docs/pksz1.htm".
v-ofile = "pksz.htm".

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
   message "Не найден кредит " + s-lon  view-as alert-box.
   return.
end.

if lon.grp <> 90 and lon.grp <> 92 then do:
   message "СЗ формируется только по потребительским кредитам" view-as alert-box.
   return.
end.

find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.lon = s-lon no-lock no-error.
if not avail pkanketa then do:
   message "Не найдена анкета для кредита " + s-lon  view-as alert-box.
   return.
end.

v-dirname = ''.
v-dirname1 = ''.
if v-ourbank = 'txb00' or v-ourbank = 'txb16' then do:
   v-dirname = 'Директора ДМ и ВК Мухамедиева Б.Ж.'.
   v-dirname1 = 'Директор ДМ и ВК Мухамедиев Б.Ж.'.
end.
else do:
  find first txb where txb.consolid and txb.bank = v-ourbank no-lock no-error.
  v-dirname = entry(2,get-sysc-cha ("dkface")) + ' ' + entry(1,get-sysc-cha ("dkface")).
  v-dirname1 = 'Директор (И.О. Директора) филиала в ' + txb.info + ' ' + get-sysc-cha ("DKPODP").
end.
v-date = replace(string(g-today,'99/99/9999'),'/','.') + 'г.'.

v-proc1 = ''.
v-proc2 = ''.
if v-select = 2 then do:
   v-proc1 = 'реструктуризация'.
   v-proc2 = 'реструктуризации'.
   v-proc3 = ''.
end.
if v-select = 3 then do:
   v-proc1 = 'перенос начисленной неустойки'.
   v-proc2 = 'переноса начисленной неустойки в статус "отсроченная неустойка" (33 уровень)'.
   v-proc3 = ''.
end.

v-clname = ''.
v-clcode = ''.
v-clname = pkanketa.name.
v-clcode = '(' + lon.cif + ')'.
v-credtype = ''.
v-credtype = 'Потребительский кредит'.

v-dog = ''.
find first loncon where loncon.lon = lon.lon no-lock no-error.
if avail loncon then v-dog = loncon.lcnt + ' ' + replace(string(pkanketa.docdt,'99/99/9999'),'/','.').

v-crc = ''.
find first crc where crc.crc = lon.crc no-lock no-error.
if avail crc then v-crc = crc.code.

v-sum = 0.
v-sum = pkanketa.summa.
v-rate = 0.
v-rate = pkanketa.rateq.
v-strdt = ''.
v-expdt = ''.
v-strdt = string(lon.rdt,'99/99/9999') + 'г.'.
v-expdt = string(lon.duedt,'99/99/9999') + 'г.'.

/*рсумма ежемес.платежа*/
v-plprc = 0.
v-plod = 0.
find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.flp = 0 and lnsch.stdat >= g-today and lnsch.stval > 0 no-lock no-error.
if avail lnsch then do:
   find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.flp = 0 and lnsci.idat >= g-today and lnsci.iv-sc > 0 no-lock no-error.
   if avail lnsci then do:
      if lnsch.stdat > lnsci.idat then do:
         find first b-lnsch where b-lnsch.lnn = lon.lon and b-lnsch.f0 > 0 and b-lnsch.flp = 0 and b-lnsch.stdat = lnsci.idat no-lock no-error.
         if avail b-lnsch then v-plod = b-lnsch.stval.
         v-plprc = lnsci.iv-sc.
      end.
      if lnsch.stdat <= lnsci.idat then do:
         find first b-lnsci where b-lnsci.lni = lon.lon and b-lnsci.f0 > 0 and b-lnsci.flp = 0 and b-lnsci.idat = lnsch.stdat no-lock no-error.
         if avail b-lnsci then v-plprc = b-lnsci.iv-sc.
         v-plod = lnsch.stval.
      end.
   end.
   else v-plod = lnsch.stval.
end.
else do:
   find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.flp = 0 and lnsci.idat >= g-today and lnsci.iv-sc > 0 no-lock no-error.
   if avail lnsci then v-plprc = lnsci.iv-sc.
end.


find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-plcom = tarifex2.ost. else v-plcom = 0.

run lonbalcrc('lon', lon.lon, g-today, "1,7", yes, lon.crc, output v-sumod).
run lonbalcrc('lon', lon.lon, g-today, "7", yes, lon.crc, output v-prosod).
run lonbalcrc('lon', lon.lon, g-today, "9", yes, lon.crc, output v-prosprc).
run lonbalcrc('lon', lon.lon, g-today, "2", yes, lon.crc, output v-prc).
run lonbalcrc('lon', lon.lon, g-today, "4", yes, lon.crc, output v-nbalprc).

v-comdolg = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.crc = lon.crc no-lock:
   v-comdolg = v-comdolg + bxcif.amount.
end.

v-totsum = 0.
v-totsum = v-sumod + v-prosprc + v-prc + v-nbalprc + v-comdolg.
run lonbalcrc('lon', lon.lon, g-today, "5,16", yes, 1, output v-pen).
run lonbalcrc('lon', lon.lon, g-today, "16", yes, 1, output v-balpen).
run lonbalcrc('lon', lon.lon, g-today, "5", yes, 1, output v-nbalpen).
run lonbalcrc('lon', lon.lon, g-today, "33", yes, 1, output v-penot).

v-penotdt0 = ?.
if v-penot > 0 then do:
    find last lnprohis where lnprohis.lon = lon.lon and lnprohis.type = "prolong" and lnprohis.penAmt > 0 no-lock no-error.
    if avail lnprohis then v-penotdt0 = lnprohis.whn.
    else do:
        find last lonres where lonres.lon = lon.lon and lonres.lev = 33 and lonres.dc = 'd' no-lock no-error.
        if avail lonres then v-penotdt0 = lonres.jdt.
    end.
end.
if v-penotdt0 <> ? then v-penotdt = string(v-penotdt0,"99/99/9999").
else v-penotdt = ''.

v-jbname = ''.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
   pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
if avail pkanketh then v-jbname = pkanketh.value1.

v-trade = ''.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
   pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobsn" no-lock no-error.
if avail pkanketh then v-trade = pkanketh.value1.

v-family = ''.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
   pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "family" no-lock no-error.
if avail pkanketh then do:
  case pkanketh.value1:
       when '00' then v-family = "холостяк/не замужем".
       when '01' then v-family = "женат/замужем".
       when '02' then v-family = "в разводе".
       when '03' then v-family = "вдова/вдовец".
  end.
end.
if v-family <> "холостяк/не замужем" then do:
   find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lnames" no-lock no-error.
   if avail pkanketh and trim(pkanketh.value1) <> '' then v-family = v-family + ', ' + pkanketh.value1.

   find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fnames" no-lock no-error.
   if avail pkanketh then v-family = v-family + ' ' + pkanketh.value1.

   find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "mnames" no-lock no-error.
   if avail pkanketh then v-family = v-family + ' ' + pkanketh.value1.

   find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "child" no-lock no-error.
   if avail pkanketh and trim(pkanketh.value1) <> '' then do:
      v-family = v-family + ', ' + pkanketh.value1.
      if pkanketh.value1 = '1' then v-family = v-family + ' ребенок'.
      if int(pkanketh.value1) > 1 then v-family = v-family + ' детей'.
   end.
end.

v-mprof = ''.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and  pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobpr" no-lock no-error.
if avail pkanketh then v-mprof = pkanketh.value1.

v-othprofit = ''.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobpr2s" no-lock no-error.
if avail pkanketh then do:
   find first  bookcod where bookcod.bookcod = 'pkankdoh' and bookcod.code = pkanketh.value1 no-lock no-error.
   if avail bookcod then v-othprofit = bookcod.name.
end.

/* штрафы, оплаченные в тек. году */
v-penoplat = 0.

for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 16 no-lock:
  if lonres.dc = 'c' then do:
     find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
     if avail jl then do:
        if jl.acc = lon.aaa then v-penoplat = v-penoplat + jl.dam.
        if jl.gl = 490000 then v-pendel = v-pendel + jl.dam.
     end.
  end.
end.

/*удаленные штрафы*/
v-pendel = 0.
for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 5 no-lock:
   if lonres.dc = 'c' then do:
      find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
      if avail jl then do:
         if jl.gl = 788000 then do:
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
            if avail b-jl and b-jl.gl = 718000 then v-pendel = v-pendel + jl.dam.
         end.
      end.
   end.
end.

v-daypros = ''.
run lndaysprf(lon.lon,g-today, no, output v-days_od, output v-days_prc).

find last lonhar where lonhar.lon = lon.lon and lonhar.fdt < g-today no-lock no-error.
find first lonstat where lonstat.lonstat = lonhar.lonstat no-lock no-error.
if avail lonstat then v-provprc = lonstat.prc.
run lonbalcrc('lon', lon.lon, g-today, "3,6", yes, lon.crc, output v-provsum).
v-provsum = v-provsum * -1.

v-daypros = string(v-days_od).
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofc = ofc.name.

/*Движимое и недвижимое имущество*/
v-realp = ''.
v-movp = ''.
for each property where property.cif = lon.cif no-lock:
  if property.type = 'real' then do:
     if v-realp <> '' then v-realp = v-realp + '<br>'.
     v-realp = v-realp + 'Исх.номер ' + property.outnum + ' дата '.
     if property.outdt <> ? then v-realp = v-realp + string(property.outdt,'99/99/9999').
     else v-realp = v-realp + ' (не указана)'.
     v-realp = v-realp + ' Вход.номер ответа ' + property.innum + ' дата '.
     if property.indt <> ? then v-realp = v-realp + string(property.indt,'99/99/9999').
     else v-realp = v-realp + ' (не указана)'.
     if property.des <> '' then v-realp = v-realp + ' Сведения о наличии имущества: ' + property.des.
  end.
  if property.type = 'mov' then do:
     if v-movp <> '' then v-movp = v-movp + '<br>'.
     v-movp = v-movp + 'Исх.номер ' + property.outnum + ' дата '.
     if property.outdt <> ? then v-movp = v-movp + string(property.outdt,'99/99/9999').
     else v-movp = v-movp + ' (не указана)'.
     v-movp = v-movp + ' Вход.номер ответа ' + property.innum + ' дата '.
     if property.indt <> ? then v-movp = v-movp + string(property.indt,'99/99/9999').
     else v-movp = v-movp + ' (не указана)'.
     if property.des <> '' then v-movp = v-movp + ' Сведения о наличии имущества: ' + property.des.
  end.
end.

output stream v-out to value(v-ofile).
input from value(v-infile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).

    repeat:
        if v-str matches "*\{\&v-dirname\}*" then do:
           v-str = replace (v-str, "\{\&v-dirname\}", v-dirname).
           next.
        end.

        if v-str matches "*\{\&v-dirname1\}*" then do:
           v-str = replace (v-str, "\{\&v-dirname1\}", v-dirname1).
           next.
        end.

        if v-str matches "*\{\&v-date\}*" then do:
           v-str = replace (v-str, "\{\&v-date\}", v-date).
           next.
        end.

        if v-str matches "*\{\&v-dog\}*" then do:
           v-str = replace (v-str, "\{\&v-dog\}", v-dog).
           next.
        end.

        if v-str matches "*\{\&v-proc1\}*" then do:
           v-str = replace (v-str, "\{\&v-proc1\}", v-proc1).
           next.
        end.

        if v-str matches "*\{\&v-proc2\}*" then do:
           v-str = replace (v-str, "\{\&v-proc2\}", v-proc2).
           next.
        end.

        if v-str matches "*\{\&v-clname\}*" then do:
           v-str = replace (v-str, "\{\&v-clname\}", v-clname).
           next.
        end.

        if v-str matches "*\{\&v-clcode\}*" then do:
           v-str = replace (v-str, "\{\&v-clcode\}", v-clcode).
           next.
        end.

        if v-str matches "*\{\&v-credtype\}*" then do:
           v-str = replace (v-str, "\{\&v-credtype\}", v-credtype).
           next.
        end.

        if v-str matches "*\{\&v-crc\}*" then do:
           v-str = replace (v-str, "\{\&v-crc\}", v-crc).
           next.
        end.

        if v-str matches "*\{\&v-sum\}*" then do:
           v-str = replace (v-str, "\{\&v-sum\}", trim(string(v-sum,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-rate\}*" then do:
           v-str = replace (v-str, "\{\&v-rate\}", trim(string(v-rate,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-strdt\}*" then do:
           v-str = replace (v-str, "\{\&v-strdt\}", v-strdt).
           next.
        end.

        if v-str matches "*\{\&v-expdt\}*" then do:
           v-str = replace (v-str, "\{\&v-expdt\}", v-expdt).
           next.
        end.

        if v-str matches "*\{\&v-plod\}*" then do:
           v-str = replace (v-str, "\{\&v-plod\}", trim(string(v-plod,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-plprc\}*" then do:
           v-str = replace (v-str, "\{\&v-plprc\}", trim(string(v-plprc,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-plcom\}*" then do:
           v-str = replace (v-str, "\{\&v-plcom\}", trim(string(v-plcom,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-plsum\}*" then do:
           v-str = replace (v-str, "\{\&v-plsum\}", trim(string(v-plcom + v-plprc + v-plod,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-sumod\}*" then do:
           v-str = replace (v-str, "\{\&v-sumod\}", trim(string(v-sumod,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-prosod\}*" then do:
           v-str = replace (v-str, "\{\&v-prosod\}", trim(string(v-prosod,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-daypros\}*" then do:
           v-str = replace (v-str, "\{\&v-daypros\}", v-daypros).
           next.
        end.

        if v-str matches "*\{\&v-prosprc\}*" then do:
           v-str = replace (v-str, "\{\&v-prosprc\}", trim(string(v-prosprc,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-prc\}*" then do:
           v-str = replace (v-str, "\{\&v-prc\}", trim(string(v-prc,'>>>>>>>>>>>>>9.99'))).
            next.
        end.

        if v-str matches "*\{\&v-nbalprc\}*" then do:
           v-str = replace (v-str, "\{\&v-nbalprc\}", trim(string(v-nbalprc,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-comdolg\}*" then do:
           v-str = replace (v-str, "\{\&v-comdolg\}", trim(string(v-comdolg,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-totsum\}*" then do:
           v-str = replace (v-str, "\{\&v-totsum\}", trim(string(v-totsum,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-pen\}*" then do:
           v-str = replace (v-str, "\{\&v-pen\}", trim(string(v-pen,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-balpen\}*" then do:
           v-str = replace (v-str, "\{\&v-balpen\}", trim(string(v-balpen,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-nbalpen\}*" then do:
           v-str = replace (v-str, "\{\&v-nbalpen\}", trim(string(v-nbalpen,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-penot\}*" then do:
           v-str = replace (v-str, "\{\&v-penot\}", trim(string(v-penot,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-penotdt\}*" then do:
           v-str = replace (v-str, "\{\&v-penotdt\}", trim(v-penotdt)).
           next.
        end.

        if v-str matches "*\{\&v-jbname\}*" then do:
           v-str = replace (v-str, "\{\&v-jbname\}", v-jbname).
           next.
        end.

        if v-str matches "*\{\&v-trade\}*" then do:
           v-str = replace (v-str, "\{\&v-trade\}", v-trade).
           next.
        end.

        if v-str matches "*\{\&v-family\}*" then do:
           v-str = replace (v-str, "\{\&v-family\}", v-family).
           next.
        end.

        if v-str matches "*\{\&v-mprof\}*" then do:
           v-str = replace (v-str, "\{\&v-mprof\}", trim(v-mprof)).
           next.
        end.

        if v-str matches "*\{\&v-othprofit\}*" then do:
           v-str = replace (v-str, "\{\&v-othprofit\}", v-othprofit).
           next.
        end.

        if v-str matches "*\{\&v-penoplat\}*" then do:
           v-str = replace (v-str, "\{\&v-penoplat\}", trim(string(v-penoplat,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-pendel\}*" then do:
           v-str = replace (v-str, "\{\&v-pendel\}", trim(string(v-pendel,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-realp\}*" then do:
           v-str = replace (v-str, "\{\&v-realp\}", v-realp).
           next.
        end.

        if v-str matches "*\{\&v-movp\}*" then do:
           v-str = replace (v-str, "\{\&v-movp\}", v-movp).
           next.
        end.

        if v-str matches "*\{\&v-provsum\}*" then do:
           v-str = replace (v-str, "\{\&v-provsum\}", trim(string(v-provsum,'>>>>>>>>>>>>>9.99'))).
           next.
        end.

        if v-str matches "*\{\&v-provprc\}*" then do:
           v-str = replace (v-str, "\{\&v-provprc\}", string(v-provprc) + ' %').
           next.
        end.

        if v-str matches "*\{\&v-days_prc\}*" then do:
           v-str = replace (v-str, "\{\&v-days_prc\}", string(v-days_prc)).
           next.
        end.

        leave.
    end. /* repeat */

    put stream v-out unformatted v-str skip.
end. /* repeat */
input close.
output stream v-out close.

output stream v-out to value(v-ofile) append.


empty temp-table t-plat.
k = 0.
for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 no-lock by lnsch.flp:
   k = k + 1.
   create t-plat.
   assign t-plat.dt_od = lnsch.stdat
          t-plat.jh = lnsch.jh
          t-plat.num = k
          t-plat.od = lnsch.paid.
end.


k = 0.
for each lnsci where lnsci.lni = lon.lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
   k = k + 1.
   find first t-plat where t-plat.num = k exclusive-lock no-error.
   if not avail t-plat then do:
       create t-plat.
       assign
       t-plat.num = k
       t-plat.dt_prc = lnsci.idat
       t-plat.prc = lnsci.paid-iv
       t-plat.jh = lnsci.jh.

   end.
   else assign t-plat.dt_prc = lnsci.idat
               t-plat.prc = lnsci.paid-iv
               t-plat.jh = lnsci.jh.

end.

v-sumtot_od = 0.
v-sumtot_prc = 0.


put stream v-out unformatted  "<br><table class=MsoNormalTable style='WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm' cellSpacing=0 cellPadding=0 width='100%'>" +
                            "<tr style='font-size:9.0pt' ><td width=311 colspan=2 valign=top style='width:233.4pt;text-align:center' ><b>История платежей по погашению основного долга</b></td>" +
                            "<td width=32 valign=top style='width:24.0pt'></td><td width=311 colspan=2 valign=top style='width:233.4pt;text-align:center' ><b>История платежей по погашению вознаграждения</b></td></tr>" +
                            "<tr style='font-size:9.0pt;' ><td width=32 valign=top style='width:30.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Дата</b></td>" +
                            "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Сумма</b></td>" +
                            "<td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:30.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Дата</b></td>" +
                            "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Сумма</b></td></tr>".
for each t-plat no-lock:
     put stream v-out unformatted "<tr style='font-size:9.0pt'>"
                                  "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.dt_od = ? then '' else string(t-plat.dt_od,'99/99/9999')) "</td>"
                                  "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.od > 0 then trim(string(t-plat.od,'>>>>>>>>>>>>>9.99')) else '') "</td>"
                                  "<td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.dt_prc = ? then '' else string(t-plat.dt_prc,'99/99/9999')) "</td>"
                                  "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.prc > 0 then trim(string(t-plat.prc,'>>>>>>>>>>>>>9.99')) else '') "</td></tr>".
     v-sumtot_od = v-sumtot_od + t-plat.od.
     v-sumtot_prc = v-sumtot_prc + t-plat.prc.
end.
put stream v-out unformatted "<tr style='font-size:9.0pt'><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>Итого"
                           + "</td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" + trim(string(v-sumtot_od,'>>>>>>>>>>>>>9.99'))
                           + "</td><td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'> Итого"
                           + "</td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" + trim(string(v-sumtot_prc,'>>>>>>>>>>>>>9.99'))
                           + "</td></tr>".


put stream v-out unformatted "</table><p class=MsoNormal style='font-size:9.0pt'>За весь период кредитования клиентом было произведено:<br>" +
                            "-оплаты пени на сумму – " + trim(string(v-penoplat,">>>>>>>>>>>>>9.99")) + "<br>-списано начисленной пени в размере " + trim(string(v-pendel,">>>>>>>>>>>>>9.99")) + "</p>".



for each lon where lon.lon <> s-lon and lon.cif = pkanketa.cif no-lock:
   if lon.opnamt <= 0 then next.
   run lonbal('lon',lon.lon,g-today,'1,7,2,9,5,16',yes,output v-bal).
   if v-bal > 0 then next.

   find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.lon = lon.lon no-lock no-error.
   if not avail pkanketa then next.

   v-crcold = ''.
   find first crc where crc.crc = lon.crc no-lock no-error.
   if avail crc then v-crcold = crc.code.

   v-sumold = 0.
   v-sumold = pkanketa.summa.
   v-rateold = 0.
   v-rateold = pkanketa.rateq.
   v-strdtold = ''.
   v-expdtold = ''.
   v-strdtold = string(lon.rdt,'99/99/9999') + ' г.'.
   v-expdtold = string(lon.duedt,'99/99/9999') + ' г.'.

   v-plodold = 0.
   find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.flp = 0 and lnsch.stdat >= g-today no-lock no-error.
   if avail lnsch then v-plodold = lnsch.stval.

   v-plprcold = 0.
   v-plprcold = round(lon.opnamt * pkanketa.rateq / 1200,2).

   find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
   if avail tarifex2 then v-plcomold = tarifex2.ost. else v-plcomold = 0.

   v-penoplold = 0.
   v-pendelold = 0.
   for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 16 no-lock:
     if lonres.dc = 'c' then do:
        find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
        if avail jl then do:
           if jl.acc = lon.aaa then v-penoplold = v-penoplold + jl.dam.
           if jl.gl = 490000 then v-pendelold = v-pendelold + jl.dam.
        end.
     end.
   end.
   for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 5 no-lock:
      if lonres.dc = 'c' then do:
         find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
         if avail jl then do:
            if jl.gl = 788000 then do:
               find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
               if avail b-jl and b-jl.gl = 718000 then v-pendel = v-pendelold + jl.dam.
            end.
         end.
      end.
   end.

   v-dayold = lon.day.
   v-plsumold = v-plodold + v-plprcold + v-plcomold.
   run hispog(v-crcold,v-sumold,v-rateold,v-strdtold,v-expdtold,v-plodold,v-plprcold,v-plcomold,v-plsumold,v-dayold ).

   empty temp-table t-plat.
   k = 0.
   for each lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 no-lock by lnsch.flp:
      k = k + 1.
      create t-plat.
      assign t-plat.dt_od = lnsch.stdat
             t-plat.jh = lnsch.jh
             t-plat.num = k
             t-plat.od = lnsch.paid.
   end.

   k = 0.
   for each lnsci where lnsci.lni = lon.lon and lnsci.fpn = 0 and lnsci.flp > 0 no-lock:
      k = k + 1.
      find first t-plat where t-plat.num = k exclusive-lock no-error.
      if not avail t-plat then do:
          create t-plat.
          assign t-plat.num = k
                 t-plat.dt_prc = lnsci.idat
                 t-plat.prc = lnsci.paid-iv
                 t-plat.jh = lnsci.jh.

      end.
      else assign t-plat.dt_prc = lnsci.idat
                  t-plat.prc = lnsci.paid-iv
                  t-plat.jh = lnsci.jh.
   end.


   v-sumtot_od = 0.
   v-sumtot_prc = 0.


   put stream v-out unformatted  "<br><table class=MsoNormalTable style='WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm' cellSpacing=0 cellPadding=0 width='100%'>" +
                                 "<tr style='font-size:9.0pt' ><td width=311 colspan=2 valign=top style='width:233.4pt;text-align:center' ><b>История платежей по погашению основного долга</b></td>" +
                                 "<td width=32 valign=top style='width:24.0pt'></td><td width=311 colspan=2 valign=top style='width:233.4pt;text-align:center' ><b>История платежей по погашению вознаграждения</b></td></tr>" +
                                 "<tr style='font-size:9.0pt;' ><td width=32 valign=top style='width:30.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Дата</b></td>" +
                                 "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Сумма</b></td>" +
                                 "<td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:30.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Дата</b></td>" +
                                 "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'><b>Сумма</b></td></tr>".
   for each t-plat no-lock:
      put stream v-out unformatted "<tr style='font-size:9.0pt'>"
                                   "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.dt_od = ? then '' else string(t-plat.dt_od,'99/99/9999')) "</td>"
                                   "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.od > 0 then trim(string(t-plat.od,'>>>>>>>>>>>>>9.99')) else '') "</td>"
                                   "<td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.dt_prc = ? then '' else string(t-plat.dt_prc,'99/99/9999')) "</td>"
                                   "<td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" (if t-plat.prc > 0 then trim(string(t-plat.prc,'>>>>>>>>>>>>>9.99')) else '') "</td></tr>".
      v-sumtot_od = v-sumtot_od + t-plat.od.
      v-sumtot_prc = v-sumtot_prc + t-plat.prc.
   end.
   put stream v-out unformatted "<tr style='font-size:9.0pt'><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>Итого"
                                + "</td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" + trim(string(v-sumtot_od,'>>>>>>>>>>>>>9.99'))
                                + "</td><td width=32 valign=top style='width:24.0pt'></td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'> Итого"
                                + "</td><td width=32 valign=top style='width:24.0pt;border-style:solid;border-width: 1px;border-collapse:collapse'>" + trim(string(v-sumtot_prc,'>>>>>>>>>>>>>9.99'))
                                + "</td></tr>".


   put stream v-out unformatted "</table><p class=MsoNormal style='font-size:9.0pt'>За весь период кредитования клиентом было произведено:<br>" +
                                "-оплаты пени на сумму – " + trim(string(v-penoplold,">>>>>>>>>>>>>9.99")) + "<br>-списано начисленной пени в размере " + trim(string(v-pendelold,">>>>>>>>>>>>>9.99")) + "</p>".
end.

put stream v-out unformatted "<p class=MsoNormal style='font-size:9.0pt'>".

case v-select:
    when 1 then put stream v-out unformatted
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;На основании вышеизложенного считаю целесообразным рефинансировать кредит на следующих основаниях:"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Сумма кредитования - не более _________________________; (с учетом начисления % и комиссии за 3 дня вперед)"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Срок кредитования - _____ месяцев;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Вид кредитования – потребительский кредит;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ставка вознаграждения - ___% в год;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Целевое назначение – рефинансирование ссудной задолженности;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Погашение основного долга - ежемесячно равными долями;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Погашение вознаграждения - ежемесячно;"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Комиссия за ведение счета – _____% от суммы кредита, ежемесячно"
                    "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;При этом сумма ежемесячного платежа примерно составит".
    when 2 then put stream v-out unformatted
                    "<br>На основании вышеизложенного считаю возможным предоставить отсрочку по выплате основного долга и вознаграждения сроком до _________________ года заемщику " +
                    v-clname + ' ' + v-clcode + ' договор ' + v-dog + '.'.
    when 3 then put stream v-out unformatted
                    "<br>На основании вышеизложенного считаю возможным перенести начисленную неустойку в статус ""отсроченная неустойка"" (33 уровень) по заемщику " +
                    v-clname + ' ' + v-clcode + ' договор ' + v-dog + '.'.
end case.

put stream v-out unformatted "<br><br>" + v-dirname1 + "<br><br><b>Исп.: " + v-ofc + "<br>Тел:</b></p></body></html>".

output stream v-out close.
unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).


procedure hispog.

  def input parameter p-crcold as char no-undo.
  def input parameter p-sumold as deci no-undo.
  def input parameter p-rateold as deci no-undo.
  def input parameter p-strdtold as char no-undo.
  def input parameter p-expdtold as char no-undo.
  def input parameter p-plodold as deci no-undo.
  def input parameter p-plprcold as deci no-undo.
  def input parameter p-plcomold as deci no-undo.
  def input parameter p-plsumold as deci no-undo.
  def input parameter p-dayold as intege no-undo.


  put stream v-out unformatted  "<table class=MsoNormalTable style='WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm' cellSpacing=0 cellPadding=0 width='100%' border=1>" +
                                "<caption class=MsoNormal style='font-size:10.0pt;text-align:left'><b>Информация по погашенным кредитам:</b></caption>" +
                                "<tr style='font-size:9.0pt'><td width=379 valign=top style='width:284.4pt'>Наименование продукта / Валюта кредита</td>" +
                                "<td width=100 valign=top style='width:75.0pt'> Потребительский кредит </td>" +
                                "<td width=90 valign=top style='width:67.2pt'>" + p-crcold + "</td></tr>" +
                                "<tr style='font-size:9.0pt'><td width=379 valign=top style='width:284.4pt'>Одобренная сумма / Ставка вознаграждения </td>" +
                                "<td width=100 valign=top style='width:75.0pt'>" + trim(string(p-sumold,'>>>>>>>>>>>>>9.99')) + "</td>" +
                                "<td width=90 valign=top style='width:67.2pt'>" + trim(string(p-rateold,'>>>>>>>>>>>>>9.99')) + " %</td></tr>" +
                                "<tr style='font-size:9.0pt'>" +
                                "<td width=379 valign=top style='width:284.4pt'>Дата выдачи / Дата погашения</td>" +
                                "<td width=100 valign=top style='width:75.0pt'>" + p-strdtold + "</td>" +
                                "<td width=90 valign=top style='width:67.2pt'>" + p-expdtold + "</td></tr>" +
                                "<tr style='font-size:9.0pt'>" +
                                "<td>Размер ежемесячного взноса</td>" +
                                "<td width=569 colspan=2 valign=top style='width:426.6pt'>" +
                                "<table class=MsoNormalTable style='WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm' cellSpacing=0 cellPadding=0 width='100%' border=1> " +
                                "<tr style='font-size:9.0pt'>" +
                                "<td width=96 valign=top style='width:72.0pt'>ОД</td>" +
                                "<td width=96 valign=top style='width:72.0pt'>%</td>" +
                                "<td width=96 valign=top style='width:72.0pt'>Комиссия</td>" +
                                "<td width=96 valign=top style='width:72.0pt'><b>Всего</b></td></tr>" +
                                "<tr style='font-size:9.0pt'>" +
                                "<td width=96 valign=top style='width:72.0pt'>" + trim(string(p-plodold,'>>>>>>>>>>>>>9.99')) + "</td>" +
                                "<td width=96 valign=top style='width:72.0pt'>" + trim(string(p-plprcold,'>>>>>>>>>>>>>9.99')) + "</td>" +
                                "<td width=96 valign=top style='width:72.0pt'>" + trim(string(p-plcomold,'>>>>>>>>>>>>>9.99')) + "</td>" +
                                "<td width=96 valign=top style='width:72.0pt'><b>" + trim(string(p-plsumold,'>>>>>>>>>>>>>9.99')) + "</b></td></tr></table></td></tr>" +
                                "<tr style='font-size:9.0pt'>" +
                                "<td width=379 valign=top style='width:284.4pt'>Число по погашению кредита</td>" +
                                "<td width=190 colspan=2 valign=top style='width:142.2pt'>" + string(p-dayold,'99') + "</td></tr></table>".
end.


