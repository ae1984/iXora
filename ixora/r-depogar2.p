/* r-depogar2.p
 * MODULE
        Отчет по фонду гарантирования вкладов
 * DESCRIPTION
        Отчет по фонду гарантирования вкладов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        r-depogar1.p
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07/10/03 nataly отчет доработан в связи с изменениями, высланными НБ РК от 04.07.04
        21/10/03 nataly было закомментировано условие  and aaa.regdt >= 07/01/02, тем самым все суммы 1.2
        перераспределились на 1.1.1 и 1.1.2
        08/01/04 nataly была доработана с новым ПС
        26/05/06 MARINAV - валюта берется < даты отчета
        29/03/08 marinav - изменения отчетности
        27/04/09 marinav - изменения суммы до 5 млн
        18/05/10 marinav - добавлен счет 221330
        13/01/12 evseev - валюта берется <= даты отчета
        05.07.2013 dmitriy - ТЗ 1424. Для карт-счетов добавил 220430
*/

 def var m-rate like txb.aaa.rate.
 def var s-intday as int.
 def var m-int as int.
 def var i as int initial 0.
 def var j as int initial 0.
 def var v-inc as int.
 def var v-accrued like txb.aaa.accrued.
 def var m-sum like txb.aab.bal.
 def var m-summa like txb.aab.bal.
 def var m-summap like txb.aab.bal.
 def var m-summag like txb.aab.bal.
 def var m-kol as int.
 def var v-tmpbal like txb.glbal.bal.
 def var v-intbal like txb.glbal.bal.
 def var v-min like txb.glbal.bal.
 def var v-max like txb.glbal.bal.
 def var m-first as log initial false.
 def var v-srok as int init 0.
 define variable v-name as character.
 define variable v-name1 as character.
 def buffer b-crchis for txb.crchis.

def  shared var m-dt as date.
def  shared stream m-out.

def var v-bal as decimal.
def shared temp-table vdepo
    field nm as char
    field name as char form "x(132)"
    field kol as int
    field summ as decimal format 'zzz,zzz,zzz,zz9.99'
    field summ_p as decimal format 'zzz,zzz,zzz,zz9.99'
    field summ_g as decimal format 'zzz,zzz,zzz,zz9.99'.


for each txb.aaa where aaa.regdt le m-dt no-lock:
  find last txb.aab where aab.aaa = aaa.aaa and fdt <= m-dt no-lock no-error.
   if not avail aab or aab.bal = 0 then next.

    m-rate = 0.
    v-accrued = 0.
    m-sum = aab.bal.
    s-intday = m-dt - aaa.regdt + 2.
    find txb.lgr where lgr.lgr = aaa.lgr no-lock no-error.
       if lookaaa then m-rate = aaa.rate.
                  else if avail txb.lgr then m-rate = lgr.rate.
       if lgr.led = 'TDA' then m-rate = aaa.rate.
       if s-intday >= 0  then
           v-accrued = m-sum * m-rate * s-intday / 100.00 / lgr.base.

    if aaa.crc > 1 then do:
    find last txb.crchis where crchis.crc = aaa.crc and crchis.whn <= m-dt no-lock no-error.
      if avail crchis then do:
         m-sum = m-sum * crchis.rate[1].
         v-accrued =  v-accrued * crchis.rate[1].
      end.
    end.
    if aaa.crc > 1 then v-accrued = 0.


/*до востребования*/
   if  aaa.gl = 220520  or aaa.gl = 220530 then do:
      find first vdepo where vdepo.nm = '0' no-lock no-error.
      kol = kol + 1.
      summ = summ + m-sum.

      if aaa.crc = 1   then do:
          find first vdepo where vdepo.nm = '1.1' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          if m-sum > 5000000 then summ_g = summ_g + 5000000.
                            else summ_g = summ_g + m-sum.
      end.

      if aaa.crc > 1  then do:
          find first vdepo where vdepo.nm = '1.2' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          if m-sum > 5000000 then summ_g = summ_g + 5000000.
                            else summ_g = summ_g + m-sum.
      end.

      find first vdepo where vdepo.nm = '1' no-lock no-error.
      kol = kol + 1.
      summ = summ + m-sum.
      if m-sum > 5000000 then summ_g = summ_g + 5000000.
                        else summ_g = summ_g + m-sum.

   end.
/*до востребования*/

/*срочные и условные вклады*/
   if aaa.gl = 220620 or aaa.gl = 220720 or aaa.gl = 220820 or aaa.gl = 221330 then do:

     /* v-srok = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).*/
    if aaa.crc = 1 then do:
       if m-sum <= 1000000 then do:
          find first vdepo where vdepo.nm = '2.1.a' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 1000000 and m-sum <= 3000000 then do:
          find first vdepo where vdepo.nm = '2.1.b' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 3000000 and m-sum <= 5000000 then do:
          find first vdepo where vdepo.nm = '2.1.c' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 5000000 and m-sum <= 10000000 then do:
          find first vdepo where vdepo.nm = '2.1.d' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.
       if m-sum > 10000000 and m-sum <= 15000000 then do:
          find first vdepo where vdepo.nm = '2.1.e' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.
       if m-sum > 15000000  then do:
          find first vdepo where vdepo.nm = '2.1.f' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.

       find first vdepo where vdepo.nm = '2.1' no-lock no-error.
       kol = kol + 1.
       summ = summ + m-sum.
       if m-sum > 5000000 then summ_g = summ_g + 5000000.
                         else summ_g = summ_g + m-sum.
    end.
    else do:
       if m-sum <= 1000000 then do:
          find first vdepo where vdepo.nm = '2.2.a' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 1000000 and m-sum <= 3000000 then do:
          find first vdepo where vdepo.nm = '2.2.b' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 3000000 and m-sum <= 5000000 then do:
          find first vdepo where vdepo.nm = '2.2.c' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + m-sum.
       end.
       if m-sum > 5000000 and m-sum <= 10000000 then do:
          find first vdepo where vdepo.nm = '2.2.d' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.
       if m-sum > 10000000 and m-sum <= 15000000 then do:
          find first vdepo where vdepo.nm = '2.2.e' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.
       if m-sum > 15000000  then do:
          find first vdepo where vdepo.nm = '2.2.f' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
          summ_g = summ_g + 5000000.
       end.

       find first vdepo where vdepo.nm = '2.2' no-lock no-error.
       kol = kol + 1.
       summ = summ + m-sum.
       if m-sum > 5000000 then summ_g = summ_g + 5000000.
                         else summ_g = summ_g + m-sum.
    end.

    find first vdepo where vdepo.nm = '2' no-lock no-error.
    kol = kol + 1.
    summ = summ + m-sum.
    if m-sum > 5000000 then summ_g = summ_g + 5000000.
                      else summ_g = summ_g + m-sum.

  end.

/*карт-счета*/

if aaa.gl = 220420 or aaa.gl = 220430 or aaa.gl = 220920  then do:
    if aaa.crc = 1 then do:
         find first vdepo where vdepo.nm = '3.1' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
         if m-sum > 5000000 then summ_g = summ_g + 5000000.
                           else summ_g = summ_g + m-sum.
    end.
    else do:
         find first vdepo where vdepo.nm = '3.2' no-lock no-error.
          kol = kol + 1.
          summ = summ + m-sum.
         if m-sum > 5000000 then summ_g = summ_g + 5000000.
                           else summ_g = summ_g + m-sum.
    end.

    find first vdepo where vdepo.nm = '3' no-lock no-error.
    kol = kol + 1.
    summ = summ + m-sum.
    if m-sum > 5000000 then summ_g = summ_g + 5000000.
                       else summ_g = summ_g + m-sum.

end.

/*карт-счета*/
end.  /*aaa*/



 m-summa = 0. m-kol = 0. m-summag = 0.
 find first vdepo where vdepo.nm = '1' no-lock no-error.
 m-summa = m-summa + vdepo.summ. m-kol = m-kol + vdepo.kol. m-summag = m-summag + vdepo.summ_g.
 find first vdepo where vdepo.nm = '2' no-lock no-error.
 m-summa = m-summa + vdepo.summ. m-kol = m-kol + vdepo.kol. m-summag = m-summag + vdepo.summ_g.
 find first vdepo where vdepo.nm = '3' no-lock no-error.
 m-summa = m-summa + vdepo.summ. m-kol = m-kol + vdepo.kol. m-summag = m-summag + vdepo.summ_g.
 find first vdepo where vdepo.nm = '0' no-lock no-error.
      kol = m-kol.
      summ = m-summa.
      summ_p = m-summap.
      summ_g = m-summag.


