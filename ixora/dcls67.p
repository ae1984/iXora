/* dcls67.p
 * MODULE
        Закрытие дня. Учет остатков займов по выкупленным кредитам КИК (26 уровень)
 * DESCRIPTION
        daily interest accr
 * RUN
     dayclose.p 
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        05.04.2006 Natalya D.
 * CHANGES
        21.04.2006 Natalya D. - добавила сравнение суммы остатка по графику и суммы остатка на 26 уровне 
        24.04.2006 Natalya D. - если признак счёт закрыть, то сумма остатка = 0 
        25.04.2006 Natalya D. - исправила вычисление суммы остатка осн.долга по графику      
*/

{global.i}
def var v-lntreb as char no-undo. /*признак сооиветсвия требованиям КИК*/
def var v-kdkik  as char no-undo. /*признак продажи в КИК*/
def var v-ost as deci no-undo.    /*сумма остатка по осн.долгу*/
def var v-bal26 as deci no-undo.  /*сумма остатка на 26 уровне*/
def var v-dfrc as deci no-undo.   /*разница м/у сумми остатка по осн.долгу и отстатка по 26 ур*/
def var rcode as int no-undo.
def var rdes as char no-undo.
def var s-glremx as char extent 5.
def var vdel as char initial "^".
def var v-param as char no-undo.
def var v-crc like crc.code no-undo.
def var s-lon like lon.lon no-undo.
def var s-jh  like jh.jh no-undo.
def var v-clsarep as char no-undo.  /*признак закрытия счета*/
define stream m-out.
output stream m-out to value("saleKIK.log" + 
        string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99")).

/*только по кредитам 27 и 67 групп*/
for each lon where lon.grp = 27 or lon.grp = 67 /*and lon.lon = '064157566'*/ no-lock.
/*проверяем на наличие признака соответствия требованиям КИК*/
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lntreb' 
                 and sub-cod.ccode = '1' no-lock no-error.
  if avail sub-cod then v-lntreb = sub-cod.ccode.
  else next.
/*проверяем на наличие признака продажи КИК*/
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'kdkik' 
                 and sub-cod.ccode = '01' no-lock no-error.
  if avail sub-cod then v-kdkik = sub-cod.ccode.
  else next.
/*проверяем на наличие признака закрытия или открытия счета*/
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'clsarep' no-lock no-error.
  if avail sub-cod then v-clsarep = sub-cod.ccode.
  else next.

  v-ost = lon.opnamt.
  s-lon = lon.lon.
/*вычисляем остаток по графику погашения осн.суммы до текущей даты*/
  for each lnsch where lnsch.lnn = lon.lon and lnsch.flp = 0 and lnsch.fpn = 0 and lnsch.f0 > 0 and lnsch.stdat <= g-today no-lock.
      v-ost = v-ost - lnsch.stval.
/*displ lnsch.stdat lnsch.stval format ">>>,>>>,>>9.99" lnsch.paid format ">>>,>>>,>>9.99" v-ost format ">>>,>>>,>>9.99" skip.*/
  end.
/*вычисляем остаток на 26 уровне*/    
  run lonbalcrc('lon',lon.lon,g-today,"26",yes,lon.crc,output v-bal26).	
  if v-clsarep = '01' then do:
     v-dfrc = v-bal26.   /*если признак "Счет закрыт", то сумма корректировке = сумме остатка на 26 уровне*/
     v-ost = 0.
  end.
  else v-dfrc = abs(v-ost - v-bal26).          /*иначе сумма корректировки = разнице м/у остатком осн.долга и остатком на 26 ур*/
  if v-dfrc = 0 then next.

  find crc where crc.crc = lon.crc no-lock no-error.
  v-crc = crc.code.
  if v-ost = v-bal26 then next.
/*если остаток на 26 ур. есть или > остатка по графику, то делаем корректировку(списание) на сумму погашения по графику, т.е.на сумму корректировки*/
  if v-ost < v-bal26 then do:    
/*displ s-lon string(v-bal26) string(v-ost) string(v-dfrc) skip.*/
     
          s-glremx[1] = "Сумма корректировки по остаткам кредитов КИК " +
                           trim(string(v-dfrc,">>>,>>>,>>9.99-"))
                           + " " + v-crc.

      v-param = string(v-dfrc) + vdel + s-lon + vdel + s-glremx[1].                                
                      s-jh = 0.
                      run trxgen ("lon0124", vdel, v-param, "lon" ,s-lon , output rcode,
                      output rdes, input-output s-jh).

                     if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                     end.

                     run lonresadd(s-jh).
put stream m-out 'JH: ' s-jh ' LON: ' s-lon ' SUM corr: ' v-dfrc format ">>>,>>>,>>9.99"  ' TRX: lon0124' skip.
 
  end. 
/*если остаток на 26 отсутствует или < остатка по графику, то делаем начисление на 26 ур. на сумму корректировки*/
  else do:
/*displ s-lon string(v-bal26) string(v-ost) string(v-dfrc) skip.*/
            s-glremx[2] = "Сумма по остаткам кредитов КИК " +
                             trim(string(v-dfrc,">>>,>>>,>>9.99-"))
                             + " " + v-crc.
        v-param = string(v-dfrc) + vdel + s-lon + vdel + s-glremx[2].                                
                        s-jh = 0.
                        run trxgen ("lon0123", vdel, v-param, "lon" ,s-lon , output rcode,
                        output rdes, input-output s-jh).
     
                       if rcode ne 0 then do:
                          message rdes.
                          pause 1000.
                          next.
                       end.

                       run lonresadd(s-jh).
put stream m-out 'JH: ' s-jh 'LON: ' s-lon ' SUM corr: ' v-dfrc format '>>>,>>>,>>9.99' ' TRX: lon0123' skip.     
  end.      
end.
output close.
/*
{global.i}
def var v-lntreb as char no-undo. 
def var v-kdkik  as char no-undo. 
def var v-ost as deci no-undo.    
def var v-bal26 as deci no-undo.  
def var v-dfrc as deci no-undo.   
def var rcode as int no-undo.
def var rdes as char no-undo.
def var s-glremx as char extent 5.
def var vdel as char initial "^".
def var v-param as char no-undo.
def var v-crc like crc.code no-undo.
def var s-lon like lon.lon no-undo.
def var s-jh  like jh.jh no-undo.
def var v-clsarep as char no-undo.  
for each lon where lon.lon = '084157614' no-lock.
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lntreb' 
                 and sub-cod.ccode = '1' no-lock no-error.
  if avail sub-cod then v-lntreb = sub-cod.ccode.
  else next.
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'kdkik' 
                 and sub-cod.ccode = '01' no-lock no-error.
  if avail sub-cod then v-kdkik = sub-cod.ccode.
  else next.
  find sub-cod where sub-cod.sub = 'LON' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'clsarep' no-lock no-error.
  if avail sub-cod then v-clsarep = sub-cod.ccode.
  else next.
  v-ost = lon.opnamt.
  s-lon = lon.lon.

  for each lnsch where lnsch.lnn = lon.lon and jh = 0 and lnsch.stdat <= g-today no-lock.
      v-ost = v-ost - lnsch.paid.
  end.
  run lonbalcrc('lon',lon.lon,g-today,"26",yes,lon.crc,output v-bal26).	
  if v-clsarep = '01' then do: v-dfrc = v-bal26.
     v-ost = 0. 
  end.   
  else v-dfrc = abs(v-ost - v-bal26).          
  if v-dfrc = 0 then leave.
end.
displ v-ost format ">>>,>>>,>>9.99" v-bal26 format ">>>,>>>,>>9.99" v-dfrc format ">>>,>>>,>>9.99" skip.
if v-ost < v-bal26 then do:
displ "LON124" skip.
end.
else do:
displ "LON123" skip.
end.

*/
