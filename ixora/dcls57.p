/* dcls57.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Автоматическое начисление комисси за неиспольз кред линию
 * RUN
        
 * CALLER
        dayclose.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        02.03.2004 marinav
 * CHANGES
        20/08/2004 madiyar - комиссия не начисляется если установлен признак закрытия счета (clsarep)
        12/10/2004 madiyar - комиссия теперь начисляется в валюте кредита
                             комиссия начисляется с базой 360, а не за каждый календарный день, как раньше
                             для физ.лиц открыт отдельный счет ГК для комиссий - 442920
        10.01.2005 saltanat - проверка на дату: Выбрать до..
        12/10/2004 madiyar - комиссия теперь начисляется в валюте кредита
        25/04/2006 madiyar - раскидка по кодам доходов-расходов
        14/06/2006 madiyar - подправил раскидку по кодам доходов-расходов
*/


{global.i}
{lonlev.i}

define new shared var s-jh  like jh.jh.

 /*!!!!*/
define shared var s-target as date.  /**/
define shared var s-bday as log.  /**/
define shared var s-intday as int. /**/

def var dn1 as integer.
def var dn2 as decimal.

/*
s-bday = true.                       
s-target = g-today + 1.
s-intday = 1.
*/  

def var glkomiss as int.

def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var s-glremx as char extent 5.

define var sumcl as deci format '->>>,>>>,>>>,>>9.99'.
define var sumkom as deci format '->>>,>>>,>>>,>>9.99'.
define var v-sum as deci format '->>>,>>>,>>>,>>9.99'.
def var v-crc like crc.crc.
def var v-rate like crc.rate[1].
define var v-komcl as deci format '->>>,>>>,>>>,>>9.99'.
define var i-dt as date init ?.

def var v-code as char.
def var v-dep as char.
def buffer bjl for jl.
{getdep.i}

define stream m-out.
output stream m-out to value("lonkomcl" + 
        string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".txt").


for each lon where upper(lon.gua) = 'CL' no-lock:

       sumcl = lon.opnamt.
       for each trxbal where trxbal.subled eq "LON" and trxbal.acc eq lon.lon
           and trxbal.crc eq lon.crc no-lock :
           if lookup(string(trxbal.level) , v-lonprnlev , ";") gt 0 then 
              sumcl = sumcl - (trxbal.dam - trxbal.cam).
       end.
       if lon.duedt < g-today then sumcl = 0.

       /*10.01.2005 saltanat - проверка на дату: Выбрать до..*/
       i-dt = ?.
       find loncon where loncon.lon = lon.lon no-lock no-error.
       if avail loncon and index(loncon.rez-char[10],'&') > 0 then do: 
          i-dt = date(integer(substring(loncon.rez-char[10],4,2)),
                      integer(substring(loncon.rez-char[10],1,2)),
                      integer(substring(loncon.rez-char[10],7,4))).
          if i-dt <= g-today then sumcl = 0.
       end.
       
       /* 20/08/2004 madiyar */
       find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "clsarep" no-lock no-error.
       if avail sub-cod then do:
         if sub-cod.ccode = '01' then next.
       end.
       /* 20/08/2004 madiyar - end */
       
      /* Учет выданных аккредитивов и гарантий*/
       for each lnakkred where lnakkred.lon = lon.lon no-lock:
         if lnakkred.crc ne lon.crc then  do:  
               if lon.crc = 1 then do:
                  find last crc where crc.crc = lnakkred.crc no-lock no-error.
                  sumcl = sumcl - lnakkred.amount * crc.rate[1].
               end.
               if lon.crc ne 1 then do:
                  find last crc where crc.crc = lnakkred.crc no-lock no-error.
                  v-sum = lnakkred.amount * crc.rate[1].
            
                  find last crc where crc.crc = lon.crc no-lock no-error.
                  sumcl = sumcl - v-sum / crc.rate[1].
               end.
         end.
         else sumcl = sumcl - lnakkred.amount.
       end.
       for each lnsch where lnn = lon.lon and lnsch.flp = 0 and lnsch.f0 > 0 
                          and lnsch.stdat <= g-today no-lock.
              sumcl = sumcl - lnsch.paid.
       end.
       
       if sumcl < 0 then sumcl = 0.
    
    find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
    if avail lonhar then v-komcl = lonhar.rez-dec[2].
    
    run day-360(g-today,s-target - 1,lon.basedy,output dn1,output dn2).
    
    sumkom = round((sumcl * v-komcl / 100) / lon.basedy * dn1,2).
    
    if sumkom > 0 then do:
       
       find longrp where longrp.longrp = lon.grp no-lock no-error.
       glkomiss = 0.
       if avail longrp then do:
         if substr(string(longrp.stn),1,1) = '1' then glkomiss = 442920.
         if substr(string(longrp.stn),1,1) = '2' then glkomiss = 442910.
       end.
       if glkomiss = 0 then do:
         put stream m-out unformatted
            lon.lon ' ' sumcl ' ' v-komcl ' ' sumkom " - Проверьте настройку группы кредита!" skip.
         next.
       end.
       
       find first crc where crc.crc = lon.crc no-lock no-error.
       find first cif where cif.cif = lon.cif no-lock no-error.
       if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel + string(glkomiss) + vdel + string(sumkom).
       else v-param = string(sumkom) + vdel + lon.lon + vdel + string(glkomiss) + vdel + "0".
      
       s-glremx[1] = "Начисление комиссии за неисп КЛ " + lon.lon + " " + 
            trim(string(lon.opnamt,">>>,>>>,>>>,>>9.99-")) 
            + " " + crc.code + " "   
            + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss . 
       s-glremx[2] = " Комиссия " + 
            trim(string(sumkom,">>>,>>>,>>9.99-"))  + " " + crc.code.
       s-glremx[3] = "".
       s-glremx[4] = "".
       s-glremx[5] = "".
       
       
       v-param = v-param + vdel +
                 s-glremx[1] + vdel +
                 s-glremx[2] + vdel +
                 s-glremx[3] + vdel +
                 s-glremx[4] + vdel +
                 s-glremx[5].
       
       s-jh = 0.
       run trxgen ("lon0077", vdel, v-param, "lon" , lon.lon , output rcode,
           output rdes, input-output s-jh).
       
          if rcode ne 0 then do:
             message rdes.
             pause 1000.
             next.
          end.
          run lonresadd(s-jh).
          
          {upd-dep2.i}
          
       put stream m-out unformatted  
                  lon.lon ' ' sumcl ' ' v-komcl ' ' sumkom ' ' s-jh skip.
    end.       
end.

output close.