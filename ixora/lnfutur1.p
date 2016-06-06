/* lnfutur1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Будущие платежи по кредитам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        4-4-3-8 
 * AUTHOR
        09/12/09 galina - скопировала из lnfutur.p
 * BASES
        BANK TXB       
 * CHANGES
        27/01/2011 madiyar - разбивка розница, МСБ, корпоративные
*/



def shared var g-today as date.
def var coun as int init 1.
define variable bil1 as decimal format '->,>>>,>>>,>>9.99' init 0.
define variable bil2 as decimal format '->,>>>,>>>,>>9.99' init 0.
define variable bilance as decimal format '->,>>>,>>>,>>9.99' init 0.
define variable bilance_prog as decimal format '->,>>>,>>>,>>9.99' init 0.
def var predopl as deci.
def var v-proc as deci.
def var dt_st as date.
def var dn1 as integer.
def var dn2 as deci.

def input parameter dat1 as date.
def input parameter dat2 as date.
def input parameter v-crc like txb.crc.crc.

def shared var s-reptype as integer no-undo.

def shared temp-table wrk
    field dt    like txb.lon.rdt
    field cif   like txb.cif.cif
    field name  like txb.cif.name
    field mon   as inte
    field yer   as inte
    field od    as deci
    field prc   as deci
    index dt dt cif.

def temp-table wrk2
    field dt    like txb.lon.rdt
    field od    as deci
    index dt dt.

function getCIFType returns integer (input p-cif as char).
    def var res as integer no-undo.
    res = -1.
    find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
    if avail txb.cif then do:
        if txb.cif.type = 'P' then res = 1. /* retail */
        else do:
            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
            if (avail txb.sub-cod) and ((txb.sub-cod.ccode = "02") or (txb.sub-cod.ccode = "03") or (txb.sub-cod.ccode = "04")) then res = 2. /* sme */
            else res = 3. /* corporate */
        end.
    end.
    return res. 
end function.

function f-od returns decimal (input parm1 as character, input parm2 as decimal, input parm3 as date, input parm4 as decimal).
  def var bb1 as decimal.
  for each txb.lnsch where txb.lnsch.lnn = parm1 and txb.lnsch.f0 > 0 and txb.lnsch.stdat < parm3 no-lock:
    bb1 = bb1 + txb.lnsch.stval.
  end.
  if parm2 < parm4 - bb1 then return parm2.
  else return parm4 - bb1.
end function.

if v-crc = 0 then do: /*если ввели 0, то делаем общий сбор и конвертим все в тенге*/
  for each txb.lon no-lock:
    if txb.lon.opnamt = 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output bilance).
    if bilance <= 0 then next.
    
    if not((s-reptype = 0) or (getCIFType(txb.lon.cif) = s-reptype)) then next.

    for each wrk2:
      delete wrk2.
    end.
    
    find txb.crc where txb.crc.crc = txb.lon.crc no-lock.
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
    
    bil1 = 0.
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat < g-today no-lock:
      bil1 = bil1 + txb.lnsch.stval.
    end. /* for each lnsch */
    predopl = (lon.opnamt - bilance) - bil1.
    if predopl < 0 then predopl = 0.
    
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= g-today and txb.lnsch.stdat < dat1 no-lock:
      predopl = predopl - txb.lnsch.stval.
    end. /* for each lnsch */
    if predopl < 0 then predopl = 0.
    
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= dat1 and txb.lnsch.stdat <= dat2 no-lock:
      if txb.lnsch.stval > predopl then do:
        
        create wrk2.
        wrk2.dt = txb.lnsch.stdat.
        wrk2.od = (txb.lnsch.stval - predopl) * txb.crc.rate[1].
        
        find first wrk where wrk.dt = txb.lnsch.stdat and wrk.cif = '' no-lock no-error.
        if not avail wrk then do:
          create wrk.
          wrk.dt = txb.lnsch.stdat.
          wrk.mon = month(txb.lnsch.stdat).
          wrk.yer = year(txb.lnsch.stdat).
        end.
        wrk.od = wrk.od + (txb.lnsch.stval - predopl) * txb.crc.rate[1].
        if (txb.lnsch.stval - predopl) * crc.rate[1] > 3000000 then do:
          find wrk where wrk.dt = txb.lnsch.stdat and wrk.cif = txb.lon.cif no-error.
          if not avail wrk then do:
            create wrk.
            wrk.dt = txb.lnsch.stdat.
            wrk.mon = month(txb.lnsch.stdat).
            wrk.yer = year(txb.lnsch.stdat).
            wrk.cif = txb.lon.cif.
            wrk.name = txb.cif.name.
          end.
          wrk.od = wrk.od + (txb.lnsch.stval - predopl) * txb.crc.rate[1].
        end.
      end.
      predopl = predopl - txb.lnsch.stval.
      if predopl < 0 then predopl = 0.
    end. /* for each lnsch */
    
    find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat < dat1 no-lock no-error.
    if avail txb.lnsci then do:
      if txb.lnsci.idat < g-today then do:
        dt_st = g-today.
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-proc).
      end.
      else do:
        dt_st = txb.lnsci.idat.
        v-proc = 0.
      end.
      bilance_prog = f-od(txb.lon.lon,bilance,dt_st + 1, txb.lon.opnamt). /* остаток ОД, на который при закрытии сегодняшнего дня начислятся проценты */
    end.
    else do:
      dt_st = txb.lon.rdt.
      v-proc = 0.
      bilance_prog = txb.lon.opnamt.
    end.
    
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= dat1 and txb.lnsci.idat <= dat2 no-lock:
      
      bil2 = bilance_prog.
      for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dt_st and txb.lnsch.stdat < txb.lnsci.idat no-lock:
        run day-360(dt_st,txb.lnsch.stdat - 1,txb.lon.basedy,output dn1,output dn2).
        v-proc = v-proc + dn1 * bil2 * txb.lon.prem / 100 / txb.lon.basedy.
        
        bil2 = f-od(txb.lon.lon,bilance,txb.lnsch.stdat + 1, txb.lon.opnamt).
        
        dt_st = txb.lnsch.stdat.
      end.
      run day-360(dt_st,/*dat2*/ txb.lnsci.idat - 1,txb.lon.basedy,output dn1,output dn2).
      v-proc = v-proc + dn1 * bil2 * txb.lon.prem / 100 / txb.lon.basedy.
      
      find first wrk where wrk.dt = txb.lnsci.idat and wrk.cif = '' no-lock no-error.
      if not avail wrk then do:
        create wrk.
        wrk.dt = txb.lnsci.idat.
        wrk.mon = month(txb.lnsci.idat).
        wrk.yer = year(txb.lnsci.idat).
      end.
      wrk.prc = wrk.prc + v-proc * txb.crc.rate[1].
      
      find wrk where wrk.dt = txb.lnsci.idat and wrk.cif = txb.lon.cif no-error.
      if avail wrk then wrk.prc = wrk.prc + v-proc * txb.crc.rate[1].
      else do:
        if v-proc * txb.crc.rate[1] > 3000000 then do:
            create wrk.
            wrk.dt = txb.lnsci.idat.
            wrk.mon = month(txb.lnsci.idat).
            wrk.yer = year(txb.lnsci.idat).
            wrk.cif = txb.lon.cif.
            wrk.name = txb.cif.name.
            wrk.prc = v-proc * txb.crc.rate[1].
            find wrk2 where wrk2.dt = txb.lnsci.idat no-lock no-error.
            if avail wrk2 then wrk.od = wrk2.od.
        end.
      end.
      
      
      dt_st = txb.lnsci.idat.
      v-proc = 0.
      
    end.
    
  end. /* for each lon */
end. /* if v-crc = 0 */
else do:
  for each txb.lon where txb.lon.crc = v-crc no-lock:
    if txb.lon.opnamt = 0 then next.
    run lonbalcrc_txb('lon',txb.lon.lon,g-today,"1,7",yes,txb.lon.crc,output bilance).
    if bilance <= 0 then next.
    
    if not((s-reptype = 0) or (getCIFType(txb.lon.cif) = s-reptype)) then next.

    for each wrk2:
      delete wrk2.
    end.
    
    find txb.crc where txb.crc.crc = txb.lon.crc no-lock.
    find txb.cif where txb.cif.cif = txb.lon.cif no-lock.
    
    bil1 = 0.
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat < g-today no-lock:
      bil1 = bil1 + txb.lnsch.stval.
    end. /* for each lnsch */
    predopl = (txb.lon.opnamt - bilance) - bil1.
    if predopl < 0 then predopl = 0.
    
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= g-today and txb.lnsch.stdat < dat1 no-lock:
      predopl = predopl - txb.lnsch.stval.
    end. /* for each lnsch */
    if predopl < 0 then predopl = 0.
    
    for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat >= dat1 and txb.lnsch.stdat <= dat2 no-lock:
      if txb.lnsch.stval > predopl then do:
        
        create wrk2.
        wrk2.dt = txb.lnsch.stdat.
        wrk2.od = txb.lnsch.stval - predopl.
        
        find first wrk where wrk.dt = txb.lnsch.stdat and wrk.cif = '' no-lock no-error.
        if not avail wrk then do:
          create wrk.
          wrk.dt = txb.lnsch.stdat.
          wrk.mon = month(txb.lnsch.stdat).
          wrk.yer = year(txb.lnsch.stdat).
        end.
        wrk.od = wrk.od + (txb.lnsch.stval - predopl).
        
        /*
        if lon.lon = "000147640" then put stream err unformatted lon.cif " " cif.name " " lon.lon " " lnsch.stdat " " "od=" lnsch.stval - predopl format ">>>,>>>,>>9.99" skip.
        */
        
        if (txb.lnsch.stval - predopl) * txb.crc.rate[1] > 3000000 then do:
          find wrk where wrk.dt = txb.lnsch.stdat and wrk.cif = txb.lon.cif no-error.
          if not avail wrk then do:
            create wrk.
            wrk.dt = txb.lnsch.stdat.
            wrk.mon = month(txb.lnsch.stdat).
            wrk.yer = year(txb.lnsch.stdat).
            wrk.cif = txb.lon.cif.
            wrk.name = txb.cif.name.
          end.
          wrk.od = wrk.od + (txb.lnsch.stval - predopl).
        end.
      end.
      predopl = predopl - txb.lnsch.stval.
      if predopl < 0 then predopl = 0.
    end. /* for each lnsch */
    
    find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat < dat1 no-lock no-error.
    if avail txb.lnsci then do:
      if txb.lnsci.idat < g-today then do:
        dt_st = g-today.
        run lonbalcrc_txb('lon',txb.lon.lon,g-today,"2",yes,txb.lon.crc,output v-proc).
      end.
      else do:
        dt_st = txb.lnsci.idat.
        v-proc = 0.
      end.
      bilance_prog = f-od(txb.lon.lon,bilance,dt_st + 1, txb.lon.opnamt). /* остаток ОД, на который при закрытии сегодняшнего дня начислятся проценты */
    end.
    else do:
      dt_st = txb.lon.rdt.
      v-proc = 0.
      bilance_prog = txb.lon.opnamt.
    end.
    
    for each txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.f0 > 0 and txb.lnsci.idat >= dat1 and txb.lnsci.idat <= dat2 no-lock:
      
      bil2 = bilance_prog.
      for each txb.lnsch where txb.lnsch.lnn = txb.lon.lon and txb.lnsch.f0 > 0 and txb.lnsch.stdat > dt_st and txb.lnsch.stdat < txb.lnsci.idat no-lock:
        run day-360(dt_st,txb.lnsch.stdat - 1,txb.lon.basedy,output dn1,output dn2).
        v-proc = v-proc + dn1 * bil2 * txb.lon.prem / 100 / txb.lon.basedy.
        
        bil2 = f-od(txb.lon.lon,bilance,txb.lnsch.stdat + 1, txb.lon.opnamt).
        
        dt_st = txb.lnsch.stdat.
      end.
      run day-360(dt_st,txb.lnsci.idat - 1,txb.lon.basedy,output dn1,output dn2).
      
      /*
      if lon.lon = "000147640" then put stream err unformatted dn1 " " bil2 " " lon.basedy " " v-proc skip.
      */
      
      v-proc = v-proc + dn1 * bil2 * txb.lon.prem / 100 / txb.lon.basedy.
      
      /*
      if lon.lon = "000147640" then put stream err unformatted dn1 " " bil2 " " lon.basedy " " v-proc skip.
      */
      
      find first wrk where wrk.dt = txb.lnsci.idat and wrk.cif = '' no-lock no-error.
      if not avail wrk then do:
        create wrk.
        wrk.dt = txb.lnsci.idat.
        wrk.mon = month(txb.lnsci.idat).
        wrk.yer = year(txb.lnsci.idat).
      end.
      wrk.prc = wrk.prc + v-proc.
      
      find wrk where wrk.dt = txb.lnsci.idat and wrk.cif = txb.lon.cif no-error.
      if avail wrk then wrk.prc = wrk.prc + v-proc.
      else do:
        if v-proc * txb.crc.rate[1] > 3000000 then do:
            create wrk.
            wrk.dt = txb.lnsci.idat.
            wrk.mon = month(txb.lnsci.idat).
            wrk.yer = year(txb.lnsci.idat).
            wrk.cif = txb.lon.cif.
            wrk.name = txb.cif.name.
            wrk.prc = v-proc.
            find wrk2 where wrk2.dt = txb.lnsci.idat no-lock no-error.
            if avail wrk2 then wrk.od = wrk2.od.
        end.
      end.
      
      /*
      if lon.lon = "000147640" then put stream err unformatted lon.cif " " cif.name " " lon.lon " " lnsci.idat " " "percent=" v-proc format ">>>,>>>,>>9.99" skip.
      */
      
      dt_st = txb.lnsci.idat.
      v-proc = 0.
      
    end.
    
  end. /* for each lon */
end.

