/*  01.02.2012 lyubov - изменила символ кассплана (200 на 100)*/

  if translat.crc = translat.crc-cash   /*валюта перевода = валюте внесения наличности*/
   then do:
  if g-today - translat.date > 5 then arpper = arpper2. /*выплата идет по возмещению*/
       vparam = string(translat.summa)+ vdel + arpper +  vdel  + translat.fam + " " + translat.name + " "
                  +  translat.otch + vdel +  translat.type-doc + " "  + translat.series +  " "  + translat.nom-doc + " от " + string(translat.dt-doc) + " выдан " + translat.vid-doc.
         run trxgen("uni0179", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 100).
      find first jh where jh.jh = s-jh. jh.party = "MXP".

  end.
  else do:
     sum = translat.summa * crc.rate[2].
     sumraz = (translat.summa ) * (crc.rate[2] - crc.rate[1]).
     if crc.rate[2]  = 0
         then do:
             message 'Не задан курс продажи для ' v-crc ' !!! Отмена проводки.'. pause 3.
             return.
         end.

  if g-today - translat.date > 5 then arpper = arpper2. /*выплата идет по возмещению*/
    vparam = string(translat.summa)  + vdel + arpper +
              vdel + translat.fam + " " + translat.name + " " +  translat.otch + vdel +
               translat.type-doc + " "  + translat.series +  " "  + translat.nom-doc + " от " + string(translat.dt-doc) + " выдан " + translat.vid-doc
               + vdel + string(sum) + vdel  + string(sumraz).
         run trxgen("uni0182", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 100).
      find first jh where jh.jh = s-jh. jh.party = "MXP".
   end.
