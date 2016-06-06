/* trx-pay.i
 * MODULE
        Переводы
 * DESCRIPTION
        Переводы (выгрузка в файл)
 * RUN
        payment-file.p, payment-file.p
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        .
 * AUTHOR
        18/07/05 nataly
 * CHANGES
        07/10/05 nataly добавлена обработка курса покупки-продажи безналичности в RUR
        11/08/08 marinav - в назначение добавлена дата и место выдачи документа
        14.12.09 marinav - jh.party = "MXP"
        01.02.2012 lyubov - изменила символ кассплана (500 на 300)
*/

 if r-translat.crc = r-translat.crc-cash
   then do: /*валюта перевода = валюте внесения наличности*/
  if g-today - r-translat.date > 5 then arpper = arpper2. /*выплата идет по возмещению*/
   vparam = string(r-translat.summa)+ vdel + arpper +
              vdel + r-translat.rec-fam + " " + r-translat.rec-name + " " +  r-translat.rec-otch + vdel +
               r-translat.rec-type-doc + " "  + r-translat.rec-series +  " "  + r-translat.rec-nom-doc + " от " + string(r-translat.rec-dt-doc) + " " + r-translat.rec-vid-doc
               + vdel +  string(v-comis / 2) + vdel  + arpper .
         run trxgen("uni0178", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 300).
      find first jh where jh.jh = s-jh. jh.party = "MXP".
   end. /* валюты одинаковы */
   else do:

     find b-crc where b-crc.crc = r-translat.crc-cash no-lock no-error.
   if r-translat.crc <> 4 then do:
     sum = r-translat.summa * crc.rate[2].
     sumcom = v-comis * crc.rate[2] .
     sumraz = (r-translat.summa ) * (crc.rate[2] - crc.rate[1]).
     if crc.rate[2]  = 0
         then do:
             message 'Не задан курс продажи для ' v-crc ' !!! Отмена проводки.'. pause 3.
             return.
         end.
  end.
   else do:   /*для рублей берем курс покупки безналичности*/
     sum = r-translat.summa * crc.rate[4].
     sumcom = v-comis * crc.rate[4] .
     sumraz = (r-translat.summa ) * (crc.rate[4] - crc.rate[1]).
     if crc.rate[4]  = 0
         then do:
             message 'Не задан курс продажи для ' v-crc ' !!! Отмена проводки.'. pause 3.
             return.
         end.
   end.



  if g-today - r-translat.date > 5 then arpper = arpper2. /*выплата идет по возмещению*/
    vparam = string(r-translat.summa)  + vdel + arpper +
              vdel + r-translat.rec-fam + " " + r-translat.rec-name + " " +  r-translat.rec-otch + vdel +
               r-translat.rec-type-doc + " "  + r-translat.rec-series +  " "  + r-translat.rec-nom-doc + " от " + string(r-translat.rec-dt-doc) + " " + r-translat.rec-vid-doc
               + vdel + string(sum) + vdel + string(v-comis / 2) + vdel  + arpper  + vdel + string(sumraz).
         run trxgen("uni0181", vdel, vparam, "", arpper, output rcode,output rdes, input-output s-jh).
         if rcode ne 0 then do:
           message rdes view-as alert-box title "".
           return.
         end.
      run setcsymb (s-jh, 300).
      find first jh where jh.jh = s-jh. jh.party = "MXP".
   end.
