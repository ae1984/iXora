/* pkcash_mko.i
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Подборка временной таблицы для списка задолжников по БД и БК
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-16
 * AUTHOR
        06/05/2008 madiyar - скопировал из pkcash.i с изменениями
 * CHANGES
*/


def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
def var v-aaa as char no-undo.

def temp-table wrk no-undo
    field lon    like lon.lon
    field cif    like lon.cif
    field name   like cif.name
    field dt1    as   inte
    field bal1   like lon.opnamt /* пеня 16 ур*/
    field bal2   like lon.opnamt /* %%  9 ур */
    field bal3   like lon.opnamt /* ОД 7 ур */
    field balmon   like lon.opnamt /* размер ежемес платежа */
    field bal13  as deci   
    field bal14  as deci
    field bal4  as deci
    field bal30  as deci
    field bal5  as deci
    field aaabal as decimal
    field tel as char
    field type as char
    field stype as char
    field day as integer
    field expdt as date
    field sts as char
    field note as char
    field prem as deci
    field pen_prc as deci
    field com_acc as deci
    field prkol as integer
    index name is primary name.

def var v-am1 as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.
def var m-payment as decimal no-undo init 0.

def var v-bal as decimal no-undo format "->,>>>,>>>,>>9.99" extent 2.
/*
def var bilance   as decimal format "->,>>>,>>>,>>9.99".
def var bilancepl as decimal format "->,>>>,>>9.99".
*/
def var bil1 as decimal no-undo format "->,>>>,>>9.99".
def var bil2 as decimal no-undo format "->,>>>,>>9.99".
def var vcu like lon.opnamt no-undo extent 6 decimals 2.
def var f-dat1 as date no-undo.
def var tempdt as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var v-credtype as char no-undo.
def var v-ankln as integer no-undo.

def var v-respr as integer no-undo.
def var v-maxpr as integer no-undo.
def var v-lnlast as integer no-undo.

def var counn as integer no-undo init 0.

for each londebt where {&param} no-lock:
     
     if not (londebt.grp = 90 or londebt.grp = 92) then next.
     
     find first lon where lon.lon = londebt.lon no-lock no-error.
     
     v-ankln = 0. v-credtype = ''.
     find first loncon where loncon.lon = lon.lon no-lock no-error.
     if avail loncon then do:
         for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = lon.cif no-lock:
             if entry(1,pkanketa.rescha[1]) = loncon.lcnt then assign v-ankln = pkanketa.ln v-credtype = pkanketa.credtype.
         end.
     end.
     if v-ankln = 0 then next.
     else find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = v-credtype and pkanketa.ln = v-ankln no-lock no-error.
     
     run lonbalcrc('lon',lon.lon,datums,"1,7,2,4,9,13,14",yes,lon.crc,output v-bal[1]).
     run lonbalcrc('lon',lon.lon,datums,"5,16,30",yes,1,output v-bal[2]).
     if v-bal[1] + v-bal[2] <= 0 then next.

     find cif where cif.cif = lon.cif no-lock.
     
     find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
     find first loncon where loncon.lon = lon.lon no-lock no-error.
     create wrk.
     assign wrk.cif = lon.cif
            wrk.lon = lon.lon
            wrk.name = cif.name
            wrk.tel = trim(cif.tel) + "," + trim(cif.tlx) + "," + trim(cif.fax)  + "," + trim(cif.btel)
            wrk.dt1 = londebt.days_od
            wrk.type = bookcod.name
            wrk.day = lon.day
            wrk.expdt = lon.duedt
            wrk.prem = lon.prem
            wrk.pen_prc = loncon.sods1.
    
    if pkanketa.id_org = '' then wrk.stype = bookcod.info[1].
    else if pkanketa.id_org = "kazpost" then wrk.stype = "kp".

    run lonbalcrc('lon',lon.lon,datums,"13",yes,lon.crc,output wrk.bal13).
    run lonbalcrc('lon',lon.lon,datums,"14",yes,lon.crc,output wrk.bal14).
    run lonbalcrc('lon',lon.lon,datums,"30",yes,1,output wrk.bal30).
    run lonbalcrc('lon',lon.lon,datums,"4",yes,lon.crc,output wrk.bal4).
    run lonbalcrc('lon',lon.lon,datums,"5",yes,1,output wrk.bal5).

    if num-entries(cif.dnb, "|") > 2 then wrk.note = entry(3, cif.dnb, "|").
    
    find first lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then do:
      find first lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
      if avail lnsci then wrk.balmon = lnsci.iv-sc.
      find next lnsci where lnsci.lni = lon.lon and lnsci.flp = 0 and lnsci.fpn = 0 and lnsci.f0 > 0 no-lock no-error.
      if avail lnsci then wrk.balmon = lnsci.iv-sc.
      wrk.balmon = wrk.balmon + lnsch.stval.
    end.

     wrk.bal1 = londebt.penalty.
     wrk.bal2 = londebt.prc.
     wrk.bal3 = londebt.od.
     
     run pkdiscount(pkanketa.rnn, -1, no, output v-respr, output wrk.prkol, output v-maxpr, output v-lnlast).
     
     if pkanketa.crc = 1 then v-aaa = pkanketa.aaa.
                         else v-aaa = pkanketa.aaaval.
     find aaa where aaa.aaa = v-aaa no-lock no-error.
     wrk.aaabal = aaa.cr[1] - aaa.dr[1].
     
     if pkanketa.rdt >= 05/17/2005 then do:
       for each bxcif where bxcif.cif = cif.cif no-lock:
         wrk.com_acc = wrk.com_acc + bxcif.amount.
       end.
     end.
     
     counn = counn + 1.
     /*
     hide message no-pause.
     message ' ' counn ' '.
     */
     
end.

/* округлить все суммы задолженности в сторону ближайшего большего целого значения */
for each wrk where wrk.bal1 + wrk.bal2 + wrk.bal3 > 0:
    if (wrk.bal1) > 0 and (wrk.bal1 - truncate (wrk.bal1, 0) > 0) then wrk.bal1 = truncate (wrk.bal1, 0) + 1.
    if (wrk.bal2) > 0 and (wrk.bal2 - truncate (wrk.bal2, 0) > 0) then wrk.bal2 = truncate (wrk.bal2, 0) + 1.
    if (wrk.bal3) > 0 and (wrk.bal3 - truncate (wrk.bal3, 0) > 0) then wrk.bal3 = truncate (wrk.bal3, 0) + 1.
end.

/*
for each wrk where wrk.bal1 + wrk.bal2 + wrk.bal3 + wrk.bal13 + wrk.bal14 + wrk.bal30 <= 0:
  delete wrk.
end.
*/
