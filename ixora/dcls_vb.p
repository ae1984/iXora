/* dcls_vb.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Перенос на внебаланс остатка по 15 уровню кредита
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.08.2003 nadejda - посильная оптимизация
        03.06.2004 nadejda - разбила одну общую проводку на разные - по каждому счету отдельно
        04/11/2004 madiar  - если закрывается день "Выбрать до" или установлен признак "clsarep" - уровень 15 зануляется
*/

{global.i}
{lonlev.i}

def var vparam as char.
def var rcode as int.
def var rdes as char format "x(100)".
def new shared var s-jh like jh.jh.
def var vdel as character initial "^".
def var v-ost like jl.dam.
def var v-dolg as deci.
def var v-sum as deci.
def var v-sumbal as deci.
def var v-sumakkr as deci.
def var v-ost15 as deci.
def var dlong as date.
def var v-teml as char.
def var i-dt as date.
def var empty15 as logi.

def stream rep.
output stream rep to rptvn.img.


for each lon no-lock.
  /* один счет - одна проводка */
  s-jh = 0.

  dlong = lon.duedt.

  v-sum = 0.
  v-dolg = 0.

  v-sumbal = 0.
  for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon and trxbal.crc eq lon.crc no-lock :
    if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then 
      v-sumbal = v-sumbal + (trxbal.dam - trxbal.cam).
  end.

  v-dolg = v-sumbal.

  v-sumakkr = 0.
  for each lnakkred where lnakkred.lon = lon.lon no-lock:
     if lnakkred.crc = lon.crc then 
       v-sumakkr = v-sumakkr + lnakkred.amount.
     else do:
       find last crc where crc.crc = lnakkred.crc no-lock no-error.

       if lon.crc = 1 then
          v-sumakkr = v-sumakkr + lnakkred.amount * crc.rate[1].
       else do:
          v-sum = lnakkred.amount * crc.rate[1].

          find last crc where crc.crc = lon.crc no-lock no-error.
          v-sumakkr = v-sumakkr + v-sum / crc.rate[1].
       end.
     end.
  end. 

  v-dolg = v-dolg + v-sumakkr.

  if dlong > g-today and v-dolg > 0 then do:

    v-ost = lon.opnamt.
    if lon.gua = "CL" then do:
       v-ost = v-ost - v-sumbal.

       for each lnsch where lnsch.lnn = lon.lon and lnsch.stdat le g-today no-lock.
           if lnsch.flp = 0 and lnsch.f0 > 0 then v-ost = v-ost - lnsch.paid.
       end.
       
    end.
    if lon.gua = "LO" then do:
         for each lnscg where lnscg.lng = lon.lon no-lock:
             if lnscg.flp > 0 and lnscg.f0 > -1 then v-ost = v-ost - lnscg.paid.
         end.
    end.

    /* Учет выданных аккредитивов и гарантий*/

    v-ost = v-ost - v-sumakkr.

    if v-ost < 0 then v-ost = 0.
    
    
    /* 04/11/2004 madiar */
  /*  if lon.gua = "CL" then do:*/
       
       empty15 = no.
       find loncon where loncon.lon = lon.lon no-lock no-error.
       if avail loncon then do:
         if index(loncon.rez-char[10],"&") > 0 then do:
            i-dt = date(integer(substring(loncon.rez-char[10],4,2)),
                        integer(substring(loncon.rez-char[10],1,2)),
                        integer(substring(loncon.rez-char[10],7,4))).
            if g-today = i-dt then empty15 = yes.
         end.
       end.
       
       find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "clsarep" no-lock no-error.
       if avail sub-cod then if sub-cod.ccode <> "msc" then empty15 = yes.
       
       if empty15 then v-ost = 0.
       
  /*  end.*/
    /* 04/11/2004 madiar - end */
    

    find first trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
        and trxbal.crc eq lon.crc and trxbal.level = 15 no-error.
    if avail trxbal then v-ost15 = trxbal.cam - trxbal.dam.
                    else v-ost15 = 0.

    if v-ost - v-ost15 > 0 then do:
         vparam = string(v-ost - v-ost15) + vdel + lon.lon. 
         run trxgen("lon0055", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
         displ stream rep "Перенос  " lon.cif lon.lon   
                   v-ost format "->>>,>>>,>>>,>>9.99"  v-ost15 format "->>>,>>>,>>>,>>9.99" 
                   v-ost - v-ost15 format "->>>,>>>,>>>,>>9.99" s-jh rcode rdes skip with width 300.
    end.
    if v-ost - v-ost15 < 0 then do:
         vparam = string((v-ost - v-ost15) * (-1)) + vdel + lon.lon. 
         run trxgen("lon0056", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
         displ stream rep "Списание " lon.cif lon.lon  
                   v-ost format "->>>,>>>,>>>,>>9.99" v-ost15 format "->>>,>>>,>>>,>>9.99" 
                   v-ost - v-ost15 format "->>>,>>>,>>>,>>9.99" s-jh rcode rdes skip with width 300.
    end.
  end.
  else do:
    find first trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
          and trxbal.crc eq lon.crc and trxbal.level = 15 no-error.
    if avail trxbal and trxbal.cam - trxbal.dam > 0 then do: 
       v-ost15 = trxbal.cam - trxbal.dam.
       vparam = string(v-ost15) + vdel + lon.lon. 
       run trxgen("lon0056", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
       displ stream rep "Закрытие линии " lon.cif lon.lon   
                 v-ost format "->>>,>>>,>>>,>>9.99" v-ost15 format "->>>,>>>,>>>,>>9.99" 
                 v-ost - v-ost15 format "->>>,>>>,>>>,>>9.99" s-jh rcode rdes skip with width 300.
    end.
  end.

  if rcode = 0 then run lonresadd(s-jh).
end.  /* по lon */

output stream rep close.
