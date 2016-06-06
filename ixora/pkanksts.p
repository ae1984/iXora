/* pkanksts.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Изменение статуса анкеты
 * RUN
        верхнее меню "Статус"
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-3
 * AUTHOR
        18.02.2003 nadejda
 * CHANGES
        18.01.2004 nadejda - проставить ставку вознаграждения, если = 0
        11.04.05 saltanat - Добавила сохранение истории при закрытии анкеты.
        24/05/2005 madiyar - В Алматы ставка 30
        19/08/2005 madiyar - Повторный кредит - скидка по ставке
        19/08/2005 madiyar - убрал явное проставление ставки для ЦО, новое значение статуса пишется в rescha[1]
        12/10/2007 madiyar - по повторным кредитам ставка - из справочника
        17/07/2008 madiyar - по Алматы ставка 22
        19.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. проставляем ставку из справочника
        02.06.2009 galina - по рефининсированию не подтягиваем спец.условия
*/


{global.i}
{pk.i}
{pk-sysc.i}

def var pk-sts as char no-undo.
def var pknew-sts as char no-undo.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def shared frame pkank. 

{pkanklon.f}

do transaction on error undo, retry:

  find current pkanketa exclusive-lock.
  pk-sts = pkanketa.sts. 
  update pkanketa.sts with frame pkank.
  pknew-sts = pkanketa.sts.

  /* 18.01.2004 nadejda - а вдруг это раньше был отказ? тогда там ставка не проставлена! */
  if pkanketa.sts <> "00" and pkanketa.rateq = 0 then do:
    pkanketa.rateq = deci(entry(pkanketa.crc,get-pksysc-char("lon%"),"|")).
    if lookup(s-ourbank,"txb00,txb16") > 0 then pkanketa.rateq = 22.
    
    /* 10% скидка ставки */
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
    if avail pkanketh then
      if trim(pkanketh.rescha[3]) <> '' then do:
        pkanketa.rateq = deci(entry(pkanketa.crc,get-pksysc-char("lon%r"),"|")).
        if lookup(s-ourbank,"txb00,txb16") > 0 then pkanketa.rateq = 22.
      end.
  end.
  /*02.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. проставляем ставку из справочника*/
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
  if not avail pkanketh or pkanketh.rescha[1] = '' or pkanketh.resdec[1] = 0 then do:
      find last lnpriv where lnpriv.credtype = s-credtype and lnpriv.bank = s-ourbank and (g-today >= lnpriv.dtb and lnpriv.dte > g-today) and lnpriv.rnn = trim(pkanketa.jobrnn) no-lock no-error.
       if avail lnpriv then do:
          pkanketa.rateq = lnpriv.rateq.
          find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "dogorg" exclusive-lock no-error.
          if not avail pkanketh then do:
             create pkanketh.
             assign pkanketh.bank = s-ourbank 
                    pkanketh.credtype = s-credtype 
                    pkanketh.ln = s-pkankln 
                    pkanketh.kritcod = "dogorg".
           end.   
           pkanketh.value1 = "1".
           find current pkanketh no-lock.
       end.     
  end.  
  
  /* 11.04.05 saltanat - Сохранять историю закрытия работы с анкетой */
  run pkhis.
  find current pkanketa no-lock.
  
end.

procedure pkhis.
    create pkankhis.
    assign pkankhis.bank = s-ourbank
           pkankhis.credtype = s-credtype
           pkankhis.ln = s-pkankln
           pkankhis.type = 'sts'
           pkankhis.chval = pk-sts
           pkankhis.who = g-ofc
           pkankhis.whn = g-today
           pkankhis.rescha[1] = pknew-sts.
end procedure.


