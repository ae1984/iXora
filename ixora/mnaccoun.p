/* mnaccoun.p
 * MODULE
        Мониторинг заемщика
        ЭКД  Мониторинг
 * DESCRIPTION
        Расчет остатков и оборотов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
    06/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}

{kdaccoun.i kdaffilh kdcifhis "kdaffilh.nom = s-nom" "kdcifhis.nom  = s-nom"  kdsysc2}


find first kdaffilh where kdaffilh.kdcif = s-kdcif  and kdaffilh.nom = s-nom and  kdaffilh.code = '09'  
                         and kdaffilh.bank = s-ourbank and kdaffilh.name matches '*TEXAKABANK*'  no-lock no-error.

if avail kdaffilh and kdaffilh.info[4] = '' then do:

 if s-ourbank = kdaffilh.bank then do:
  
   d3 = d1 - (d2 - d1).

   repeat i = 1 to num-entries(v-list): 
        v-sum[i] = 0. v-sums[i] = 0.
   end.

  repeat i = 1 to num-entries(v-list):
   find last crchis where crchis.crc = inte(entry(i,v-list)) and crchis.regdt <= d1 no-lock no-error.
   if avail crchis then do:
     v-crc[i] = crchis.code.
     
     for each aaa where aaa.cif = s-kdcif and aaa.crc = crchis.crc no-lock:
       if aaa.lgr begins '5' then next.
       for each jl where jl.acc = aaa.aaa and jl.gl = aaa.gl and jl.jdt >= d3 and jl.jdt <= d1 no-lock.
         if not (jl.crc = crchis.crc and jl.lev = 1) then next.
         accumulate jl.cam (TOTAL).
       end.
       v-sum[i] = v-sum[i] + accum total jl.cam. /* полный кредитовый оборот */
     end.
     
     for each lon where lon.cif = s-kdcif and lon.crc = crchis.crc no-lock:
        for each lnscg where lnscg.lng = lon.lon and lnscg.stdat >= d3 and lnscg.stdat <= d1 no-lock:
           if lnscg.jh > 0 then v-sums[i] = v-sums[i] + lnscg.paid. /* дебетовый оборот по ссудным счетам */
        end.
     end.
     
     v-sums[i] = v-sum[i] - v-sums[i].
    
   end.
   find current kdaffilh exclusive-lock no-error.
   if kdaffilh.info[4] = '' 
     then kdaffilh.info[4] = v-crc[i]  + ',' + string(v-sum[i] / ((d1 - d3) / 30)).
     else kdaffilh.info[4] = kdaffilh.info[4] + ',' + v-crc[i] + ',' + string(v-sum[i] / ((d1 - d3) / 30)).
                         
   
   if kdaffilh.info[5] = ''
     then kdaffilh.info[5] = v-crc[i] + ',' + string(v-sums[i] / ((d1 - d3) / 30)).
     else kdaffilh.info[5] = kdaffilh.info[5] + ',' + v-crc[i] + ',' + string(v-sums[i] / ((d1 - d3) / 30)).
   find current kdaffilh no-lock no-error.
  
  end.
 end. 
end.
