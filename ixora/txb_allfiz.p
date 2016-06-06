/*txb_allfiz.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сведения о размещенных вкладах физ.лиц в разбивке филиалов
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
        03/02/2009 galina
 * BASES
        BANK TXB
 * CHANGES
        06/05/2010 galina - исправила согласно замечаниям НБ РК
        02/07/2010 galina - выводми 20-тизначые счета
        13/08/2013 galina - ТЗ1938 добавила вывод данных по карточным счетам
*/

def input parameter p-dt as date.
def input parameter p-bank as char.

define shared var g-today  as date.
def var v-aaalist as char.
def var v-ammount as deci.
def var v-depsumm as deci.
def var v-cartsumm as deci.
def var v-cifgeo as char.
def var v-crc as char.
def var i as integer.
def var v-crcrate as deci.

def var v-docnum as char.
def var v-docdt as char.
def var v-docvyd as char.
def var v-bspr as char no-undo.

def shared temp-table t-rep
  field bank as char
  field cif as char
  field cifname as char
  field cifps1 as char
  field cifps2 as char
  field cifrnn as char
  field cifadr as char
  field docnum as char
  field docdt as date
  field crc as char
  field gl as char /*ГК для ОД/Суммы депозита на 1 уровне*/
  field gl2 as char /*ГК для просроченного ОД*/
  field glprc as char /*ГК для процентов*/
  field glprc2 as char  /*ГК для просроч. процентов*/
  field acc as char
  field amt as deci
  field amt2 as deci /*Сумма просроч. ОД*/
  field amt_kz as deci
  field amt_kz2 as deci  /*Сумма просроч. ОД в тенге*/
  field pamt as deci
  field pamt_kz as deci
  field pamt2 as deci /*Сумма просроч %%*/
  field pamt_kz2 as deci /*Сумма просроч %% в тенге*/
  field sub as char
  field bnkbic as char
  field iin as char
  index main is primary bank cif sub
  index iin iin sub
  index cif cif.
def var v-bic as char.

function get_amt returns deci (p-acc as char, p-gl as integer, p-lev as integer, p-dt as date, p-sub as char, p-crc as integer).
  def var v-amt as deci.
  v-amt = 0.
  if p-dt < g-today then do:
    find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = p-lev and txb.histrxbal.crc = p-crc and txb.histrxbal.dt <= p-dt  no-lock no-error.
    if avail txb.histrxbal then do:
      find txb.gl where txb.gl.gl  = p-gl no-lock no-error.
      if not avail txb.gl then message "Не найден счет главной книги" + string(p-gl) view-as alert-box title "Внимание".
      if txb.gl.type eq "A" or txb.gl.type eq "E" then
           v-amt = txb.histrxbal.dam - txb.histrxbal.cam.
      else v-amt = txb.histrxbal.cam - txb.histrxbal.dam.
    end.

  end.
  if p-dt = g-today then do:
    find first txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc and txb.trxbal.level = p-lev and txb.trxbal.crc = p-crc no-lock no-error.
    if avail txb.trxbal then do:
      find txb.gl where txb.gl.gl  = p-gl no-lock no-error.
      if not avail txb.gl then message "Не найден счет главной книги" + string(p-gl) view-as alert-box title "Внимание".
      if txb.gl.type eq "A" or txb.gl.type eq "E" then
           v-amt = txb.trxbal.dam - txb.trxbal.cam.
      else v-amt = txb.trxbal.cam - txb.trxbal.dam.
    end.
    /*else  message "Информация об остатках на счете " + p-acc + " отсутствуе"  view-as alert-box title "Внимание".*/
  end.
  return v-amt.
end.

find first txb.sysc where txb.sysc.sysc = 'CLECOD' no-lock no-error.
if avail txb.sysc then v-bic = txb.sysc.chval.


v-aaalist = "220420,220520,220530,220620,220720,220820,220830,220840,221330,220430,220431,220850".

hide message no-pause.
message "Филиал " + p-bank.
do i = 1 to num-entries(v-aaalist):
aa:
 for each txb.aaa where txb.aaa.regdt <= p-dt and txb.aaa.gl = integer(entry(i,v-aaalist)) no-lock use-index aaa-idx4:

   if txb.aaa.sta = "C" then do:
     find first txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa and txb.aadrt.prim = p-bank and txb.aadrt.prim2 = txb.aaa.cif no-lock no-error.
     if avail txb.aadrt and txb.aadrt.who = txb.aaa.sta then if txb.aadrt.whn <= p-dt then do:
        find first txb.jl where  txb.jl.jdt >= txb.aadrt.whn and txb.jl.acc  = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl no-lock no-error.
        if not avail txb.jl then do:
           find first cartost where cartost.bank = p-bank and cartost.acc = txb.aaa.aaa and cartost.dtost = p-dt and cartost.sub = 'aaa' no-lock no-error.
           if not avail cartost or cartost.sumost <= 0 then next.
        end.
      end.
   end.

   v-cifgeo = "".
   v-crc = "".
   find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
   if not avail txb.cif then  next aa.


   v-depsumm = 0.
   v-cartsumm = 0.
   v-depsumm = get_amt(txb.aaa.aaa,txb.aaa.gl,1,p-dt, "cif", txb.aaa.crc).

   /*if v-depsumm <= 0 then next.*/
   /*if v-depsumm <= 0 then do:*/
       find first cartost where cartost.bank = p-bank and cartost.acc = txb.aaa.aaa and cartost.dtost = p-dt and cartost.sub = 'aaa' no-lock no-error.
       if avail cartost then v-cartsumm = v-depsumm + cartost.sumost.
       /*else  next.*/
   /*end.*/
   /*else v-depsumm = 0.*/
   v-depsumm = v-depsumm + get_amt(txb.aaa.aaa,txb.aaa.gl,2,p-dt, "cif", txb.aaa.crc).
   if v-depsumm <= 0 and v-cartsumm <= 0 then next.
   /*if v-depsumm > 0 and v-cartsumm > 0 then message txb.aaa.aaa view-as alert-box.*/

   if substr(txb.cif.geo,3,1) <> "1" then v-cifgeo = "2".
   else v-cifgeo = "1".
   find first txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
   find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
   v-crc = "".

   create t-rep.
   assign
    t-rep.bnkbic = v-bic
    t-rep.bank = p-bank
    t-rep.cif = txb.aaa.cif
    t-rep.cifname = txb.cif.name
    t-rep.cifps1 = replace(substring(trim(txb.cif.pss),1,9),'№','N')
    t-rep.cifps2 = substring(trim(txb.cif.pss),10,length(trim(txb.cif.pss)) - 9)
    t-rep.cifrnn = txb.cif.jss
    t-rep.iin = txb.cif.bin
    t-rep.cifadr = replace(txb.cif.addr[1] + " " + txb.cif.addr[2],'№','N')
    t-rep.docdt = txb.aaa.regdt
    t-rep.acc = txb.aaa.aaa
    t-rep.sub = "aaa".
    if avail txb.lgr then t-rep.docnum = txb.lgr.des.
    if avail txb.crc then  t-rep.crc  = txb.crc.code.
    if trim(t-rep.iin) = '' then t-rep.iin = trim(txb.aaa.cif).

    find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= p-dt no-lock no-error.
    if avail txb.crchis then v-crcrate = txb.crchis.rate[1].
    else v-crcrate = 1.

    if v-cartsumm = 0 then t-rep.amt = get_amt(txb.aaa.aaa,txb.aaa.gl,1,p-dt, "cif", txb.aaa.crc).
    else t-rep.amt = v-cartsumm.
    t-rep.amt_kz = t-rep.amt * v-crcrate.
    t-rep.pamt = get_amt(txb.aaa.aaa,txb.aaa.gl,2,p-dt, "cif", txb.aaa.crc).
    t-rep.pamt_kz = t-rep.pamt * v-crcrate.

    if avail  txb.crc then do:
      if txb.crc.crc = 2 or txb.crc.crc = 3 then v-crc = "2".
      if txb.crc.crc = 4 then v-crc = "3".
      if txb.crc.crc = 1 then v-crc = "1".
    end.
    t-rep.gl = substr(string(txb.aaa.gl),1,4) + v-cifgeo + "9" + v-crc.
    find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled = 'cif' and txb.trxlevgl.level = 2 no-lock no-error.
    if avail txb.trxlevgl then t-rep.gl2 = substr(string(trxlevgl.glr),1,4) + v-cifgeo + "9" + v-crc.
    if v-cartsumm > 0 then t-rep.gl = t-rep.gl.
 end.
end. /*do*/


def var v-lonlist as char init '141120,141720,140140,140160,140320,140720,140920,142420,142462'.

do i = 1 to num-entries(v-lonlist):

 for each txb.lon where txb.lon.gl = int(entry(i,v-lonlist)) and txb.lon.rdt <= p-dt no-lock use-index cif:
   if txb.lon.sts =  "C" then do:
      find last txb.lonres where txb.lonres.lon = txb.lon.lon use-index jdt no-lock no-error.
      if not avail txb.lonres then next.
      if txb.lonres.jdt <= p-dt then next.
   end.

   v-cifgeo = "".
   v-crc = "".
   find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
   if not avail txb.cif then do:
     message "Не найден клиент " + txb.lon.cif view-as alert-box title "Внимание".
     next.
   end.

   if substr(txb.cif.geo,3,1) <> "1" then v-cifgeo = "2".
   else v-cifgeo = "1".

   find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.

   find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
   v-ammount = 0.

   create t-rep.
   assign
    t-rep.bnkbic = v-bic
    t-rep.bank = p-bank
    t-rep.cif = txb.lon.cif
    t-rep.cifname = txb.cif.name
    t-rep.cifps1 = replace(substring(trim(txb.cif.pss),1,9),'№','N')
    t-rep.cifps2 = substring(trim(txb.cif.pss),10,length(trim(txb.cif.pss)) - 9)
    t-rep.cifrnn = txb.cif.jss
    t-rep.iin = txb.cif.bin
    t-rep.cifadr = replace(txb.cif.addr[1] + " " + txb.cif.addr[2],'№','N')
    t-rep.docdt = txb.lon.rdt
    t-rep.acc = txb.lon.lon
    t-rep.sub = "lon".

    v-docnum = ''.
    v-docdt = ''.
    v-docvyd = ''.
    find first pkanketa where pkanketa.bank = p-bank and pkanketa.lon = txb.lon.lon no-lock no-error.
    if availa pkanketa then do:
        v-docnum = replace(pkanketa.docnum,'№','N').

        find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
             pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
        if avail pkanketh then do:
          if index(pkanketh.value1,".") > 0 then v-docdt = replace(pkanketh.value1,'.','/').
          else do:
              if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
              else v-docdt = string(pkanketh.value1, "99/99/9999").
          end.
        end.

        v-docvyd = "МВД РК".
        find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
             pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
        if avail pkanketh and trim(pkanketh.value1) <> '' then do:
          find first txb.pkkrit where txb.pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
          if avail txb.pkkrit then do:
            if num-entries(txb.pkkrit.kritspr) > 1 then v-bspr = entry(integer(pkanketa.credtype),txb.pkkrit.kritspr).
            else v-bspr = txb.pkkrit.kritspr.
            find first bookcod where bookcod.bookcod = v-bspr and bookcod.code = pkanketh.value1 no-lock no-error.
            if avail bookcod then v-docvyd = trim(bookcod.name).
          end.
        end.
        t-rep.cifps1 = v-docnum .
        t-rep.cifps2 = v-docdt + ' ' + v-docvyd.
    end.
    if avail txb.loncon then t-rep.docnum =  replace(txb.loncon.lcnt,'№','N').
    if avail txb.crc then t-rep.crc  =  txb.crc.code.

    t-rep.amt = get_amt(txb.lon.lon,txb.lon.gl,1,p-dt,"lon", txb.lon.crc).
    t-rep.amt2 = get_amt(txb.lon.lon,txb.lon.gl,7,p-dt,"lon", txb.lon.crc).

    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= p-dt no-lock no-error.
    if avail txb.crchis then v-crcrate = txb.crchis.rate[1].
    else v-crcrate = 1.

    t-rep.amt_kz = t-rep.amt * v-crcrate.
    t-rep.amt_kz2 = t-rep.amt2 * v-crcrate.


    t-rep.pamt = get_amt(txb.lon.lon,txb.lon.gl,2,p-dt,"lon", txb.lon.crc).
    t-rep.pamt2 = get_amt(txb.lon.lon,txb.lon.gl,9,p-dt,"lon", txb.lon.crc).
    t-rep.pamt_kz = t-rep.pamt * v-crcrate.
    t-rep.pamt_kz2 = t-rep.pamt2 * v-crcrate.

    if avail txb.crc then do:
      if txb.crc.crc = 2 or txb.crc.crc = 3 then v-crc = "2".
      if txb.crc.crc = 4 then v-crc = "3".
      if txb.crc.crc = 1 then v-crc = "1".
    end.
    t-rep.gl = substr(string(txb.lon.gl),1,4) + v-cifgeo + "9" + v-crc.

    find first txb.trxlevgl where txb.trxlevgl.gl = txb.lon.gl and txb.trxlevgl.subled = 'lon' and txb.trxlevgl.level = 7 no-lock no-error.
    if avail txb.trxlevgl then t-rep.gl2 = substr(string(trxlevgl.glr),1,4) + v-cifgeo + "9" + v-crc.

    find first txb.trxlevgl where txb.trxlevgl.gl = txb.lon.gl and txb.trxlevgl.subled = 'lon' and txb.trxlevgl.level = 2 no-lock no-error.
    if avail txb.trxlevgl then t-rep.glprc = substr(string(trxlevgl.glr),1,4) + v-cifgeo + "9" + v-crc.

    find first txb.trxlevgl where txb.trxlevgl.gl = txb.lon.gl and txb.trxlevgl.subled = 'lon' and txb.trxlevgl.level = 9 no-lock no-error.
    if avail txb.trxlevgl then t-rep.glprc2 = substr(string(trxlevgl.glr),1,4) + v-cifgeo + "9" + v-crc.

 end.
end.
/********кредиты по карточкам**********/
for each cartost where cartost.bank = p-bank and cartost.sub = 'lon' and cartost.dtost = p-dt no-lock:

   v-cifgeo = "".
   v-crc = "".
   find first txb.cif where txb.cif.cif = cartost.cif no-lock no-error.
   if not avail txb.cif then do:
     message "Не найден клиент " + cartost.cif view-as alert-box title "Внимание".
     next.
   end.

   if substr(txb.cif.geo,3,1) <> "1" then v-cifgeo = "2".
   else v-cifgeo = "1".

   find first txb.crc where txb.crc.crc = cartost.crc no-lock no-error.


   v-ammount = 0.

   create t-rep.
   assign
    t-rep.bnkbic = v-bic
    t-rep.bank = p-bank
    t-rep.cif = cartost.cif
    t-rep.cifname = txb.cif.name
    t-rep.cifps1 = replace(substring(trim(txb.cif.pss),1,9),'№','N')
    t-rep.cifps2 = substring(trim(txb.cif.pss),10,length(trim(txb.cif.pss)) - 9)
    t-rep.cifrnn = txb.cif.jss
    t-rep.iin = txb.cif.bin
    t-rep.cifadr = replace(txb.cif.addr[1] + " " + txb.cif.addr[2],'№','N')
    t-rep.docdt = date(string(day(cartost.lnrdt)) + '/' + string(month(cartost.lnrdt)) + '/' + string(year(cartost.lnrdt),'9999')).
    t-rep.acc = cartost.acc.
    t-rep.sub = "lon".

    v-docnum = ''.
    v-docdt = ''.
    v-docvyd = ''.
    find first pkanketa where pkanketa.bank = p-bank and pkanketa.cif = cartost.cif and pkanketa.credtype = '4' no-lock no-error.
    if availa pkanketa then do:
        t-rep.docnum = replace(pkanketa.rescha[1],'№','N').
        v-docnum = pkanketa.docnum.

        find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
             pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
        if avail pkanketh then do:
          if index(pkanketh.value1,".") > 0 then v-docdt = replace(pkanketh.value1,'.','/').
          else do:
              if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
              else v-docdt = string(pkanketh.value1, "99/99/9999").
          end.
        end.

        v-docvyd = "МВД РК".
        find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
             pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
        if avail pkanketh and trim(pkanketh.value1) <> '' then do:
          find first txb.pkkrit where txb.pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
          if avail txb.pkkrit then do:
            if num-entries(txb.pkkrit.kritspr) > 1 then v-bspr = entry(integer(pkanketa.credtype),txb.pkkrit.kritspr).
            else v-bspr = txb.pkkrit.kritspr.
            find first bookcod where bookcod.bookcod = v-bspr and bookcod.code = pkanketh.value1 no-lock no-error.
            if avail bookcod then v-docvyd = trim(bookcod.name).
          end.
        end.
        t-rep.cifps1 = v-docnum .
        t-rep.cifps2 = v-docdt + ' ' + v-docvyd.
    end.



    if avail txb.crc then t-rep.crc  =  txb.crc.code.

    t-rep.amt = cartost.sumost.
    t-rep.amt2 = cartost.sumost_pros.

    find last txb.crchis where txb.crchis.crc = cartost.crc and txb.crchis.rdt <= p-dt no-lock no-error.
    if avail txb.crchis then v-crcrate = txb.crchis.rate[1].
    else v-crcrate = 1.

    t-rep.amt_kz = t-rep.amt * v-crcrate.
    t-rep.amt_kz2 = t-rep.amt2 * v-crcrate.


    t-rep.pamt = cartost.sumproc.
    t-rep.pamt2 = cartost.sumproc_pros.
    t-rep.pamt_kz = t-rep.pamt * v-crcrate.
    t-rep.pamt_kz2 = t-rep.pamt2 * v-crcrate.

    if avail txb.crc then do:
      if txb.crc.crc = 2 or txb.crc.crc = 3 then v-crc = "2".
      if txb.crc.crc = 4 then v-crc = "3".
      if txb.crc.crc = 1 then v-crc = "1".
    end.
    t-rep.gl = '1403' + v-cifgeo + "9" + v-crc.


    if cartost.sumost_pros > 0 then t-rep.gl2 = '1424' + v-cifgeo + "9" + v-crc.
    if cartost.sumproc > 0 then t-rep.glprc = '1740' + v-cifgeo + "9" + v-crc.
    if cartost.sumproc_pros > 0 then t-rep.glprc2 = '1741' + v-cifgeo + "9" + v-crc.

end.
/********************/