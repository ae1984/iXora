/* carddepo.p
 * MODULE
        Работа с клиентами
 * DESCRIPTION
        При открытии депозита предлагать плат карточку
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
        25.07.2005 marinav
 * CHANGES
*/

{global.i}

def shared var s-aaa like aaa.aaa.
def var v-card as char.
def var v-limit as decimal.
def var v-limitmax as decimal.


find first crc where crc.crc = 2 no-lock no-error.
if avail crc then v-limitmax = 5000 * crc.rate[1].


   find aaa where aaa.aaa = s-aaa  no-lock no-error.

   if avail aaa and aaa.cla >= 12 then do:

      if aaa.crc = 1 then do: 
         find first crc where crc.crc = 2 no-lock no-error.
         if avail crc and aaa.opnamt >= 1000 * crc.rate[1] then do:
            if aaa.opnamt < 7500000 then v-card = 'VISA CLASSIC'.
                                    else v-card = 'VISA GOLD'.
            v-limit = aaa.opnamt * 0.9.
            if v-limit > v-limitmax then v-limit = v-limitmax.
         end.
      end.
      else do:
         if aaa.opnamt >= 1000 then do:
            if aaa.opnamt < 50000 then v-card = 'VISA CLASSIC'.
                                  else v-card = 'VISA GOLD'.
            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then v-limit = round((aaa.opnamt * 0.9) * crc.rate[1] , 0). 
            if v-limit > v-limitmax then v-limit = v-limitmax.
         end.
      end.
   end.

   find first crc where crc.crc = 2 no-lock no-error.

   find first pksysc where pksysc.credtype = '4' and pksysc.sysc = 'step' no-lock no-error.


   if avail crc and avail pksysc and v-limit > 0 then 
                    message skip "Предложите клиенту оформить карту " + v-card skip  
                                 "с максимальным кредитным лимитом " + string(pksysc.deval * trunc(v-limit / pksysc.deval , 0)) +  " тенге" skip 
                                 "( " + string(pksysc.inval * trunc((v-limit / crc.rate[1]) / pksysc.inval, 0)) + " долларов США )" skip 
                                 "без оплаты первого года обслуживания" skip(1) view-as alert-box title "Н А П О М И Н А Н И Е".
