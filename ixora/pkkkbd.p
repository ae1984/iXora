/* pkkkbd.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Решение кредитного комитета
 * RUN
        верхнее меню 4.x.2
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.x.2 -> КредКом
 * AUTHOR
        09.10.03  marinav
 * CHANGES
        15.01.2004 nadejda - проверка суммы запроса на превышение максимальной с учетом суммы комиссии
                             возможность расчета суммы запроса по общей сумме кредита, если сумма запроса задана 0
        26.01.2004 nadejda - позволить менять макс. сумму всегда
        28.01.2004 sasco   - запрос на цель кредита + партнера
        25.11.2004 saltanat - Добавлено поле "Примечание".
        24/05/2005 madiyar - В Алматы ставка 30
        19/08/2005 madiyar - Повторный кредит - скидка по ставке
        27/08/2005 madiyar - миллион на 3 года (Алматы)
        31/08/2005 madiyar - миллион на 3 года (Алматы) - изменения в расчете сумм
        01/09/2005 madiyar - миллион на 3 года (Алматы) - убрал сумму, максимальную для данного срока
        21/11/2005 madiyar - максимальная сумма кредита в Актобе - 750000
        16/01/2006 madiyar - максимальная сумма кредита в Актобе - 1000000
        28/02/2006 madiyar - казпочта
        03/03/2006 madiyar - по анкетам казпочты процентная ставка 18 для получающих зарплату через казпочту
        03/03/2006 madiyar - по анкетам казпочты сумма кредита сразу прописывается в pkanketa.summa
        13/03/2006 madiyar - по анкетам казпочты сумма комиссии сразу прописывается в pkanketa.sumcom
        12/04/07 marinav -  id_org любое
        12/10/2007 madiyar - по повторным кредитам ставка - из справочника
        30/05/2008 madiyar - по Алматы ставка 22
        04.06.2008 madiyar - валютный контроль
        17/07/2008 madiyar - по Алматы ставка 22 иногда не проставляется, произвел небольшие изменения
        19.09.2008 galina проверка на наличие РНН в справочнке организаций, с которыми есть договоренности. проставляем ставку из справочника
        02.06.2009 galina - по рефининсированию не подтягиваем спец.условия
*/

{global.i}
{pk.i}
{pk-sysc.i}
{pkanklon.f}

{pkcifnew.i}

define var v-dat as date.
define var v-sum  as deci.
define var v-srok as inte.
define var v-sroku as inte.
v-dat = g-today.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

if pkanketa.sts <> "04" then do:
    message skip " Заявка не рассматривается на Кредитном комитете! " skip(1) view-as alert-box buttons ok .
    return.
end.

/* проверка на допустимые валюты */
if pkanketa.crc < 1 or pkanketa.crc > 3 then do:
    message skip " Некорректная валюта выдачи! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

def var v-sel as char.
run sel2 ("Выдача :", " 1. Наличными | 2. Картой ", output v-sel).
if v-sel = "2" then do: run pkkkbdc. return. end.
else if v-sel <> "1" then return.

def var v-sumcom as decimal.
def var v-sumfin as decimal.
def var v-summin as decimal.
def var v-summax as decimal.
find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksum" no-lock no-error.
v-summin = deci(entry(1,entry(pkanketa.crc,pksysc.chval,"|"))).
v-summax = deci(entry(2,entry(pkanketa.crc,pksysc.chval,"|"))).


def var v-srokmin as decimal.
def var v-srokmax as decimal.
find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksrk" no-lock no-error.
v-srokmin = int(entry(1,entry(pkanketa.crc,pksysc.chval,"|"))).
v-srokmax = int(entry(2,entry(pkanketa.crc,pksysc.chval,"|"))).


function chk-sum returns logical (p-value as decimal).
  if p-value = 0 then return true.
        
  if p-value + pk-tarif (p-value) > pkanketa.summax then do:
    v-msgerr = "Сумма кредита превысит максимальную ! " +
          "(с учетом комиссии " + trim (string (pk-tarif (p-value), ">>>,>>>,>>>,>>9.99")) + ")".
    return false.
  end.
  
  
  if p-value + pk-tarif (p-value) < v-summin then do:
    v-msgerr = "Сумма кредита будет меньше минимальной ! " + trim (string (v-summin - pk-tarif (p-value), ">>>,>>>,>>>,>>9.99"))
               + "(с учетом комиссии " + trim (string (pk-tarif (p-value), ">>>,>>>,>>>,>>9.99")) + ")".
    return false.
  end.

  return true.

end function.

form
  pkanketa.summax label "  МАКСИМАЛЬНАЯ СУММА " format "zzz,zzz,zzz,zz9.99"
     validate (pkanketa.summax >= v-summin and pkanketa.summax <= v-summax,
         "Сумма кредита должна быть >= " + trim (string (v-summin, ">>>,>>>,>>>,>>9.99")) +
         " и <= " + trim (string (v-summax, ">>>,>>>,>>>,>>9.99")))
  " " skip
  pkanketa.srok   label "        СРОК КРЕДИТА " format ">>>>>9"
     validate (pkanketa.srok >= v-srokmin and pkanketa.srok <= v-srokmax,
         "Срок кредита должен быть >= " + trim (string (v-srokmin, ">>>>9")) +
         " и <= " + trim (string (v-srokmax, ">>>>>9")))
  "" skip
  v-dat           label "  ДАТА КРЕД КОМИТЕТА "
     validate (v-dat >= pkanketa.rdt, " Дата кред.комитета не может быть меньше даты регистрации анкеты")
  skip
  pkanketa.sumq   label "  УТВЕРЖДЕННАЯ СУММА "
     validate (chk-sum (pkanketa.sumq), v-msgerr)
     format "zzz,zzz,zzz,zz9.99" " " skip
  v-sumcom        label "      СУММА КОМИССИИ " format "zzz,zzz,zzz,zz9.99" skip
  v-sumfin        label "       СУММА КРЕДИТА " format "zzz,zzz,zzz,zz9.99"
     validate (v-sumfin = 0 or (v-sumfin >= v-summin and v-sumfin <= pkanketa.summax),
          "Сумма кредита должна быть >= " + trim (string (v-summin, ">>>,>>>,>>>,>>9.99")) +
          " и <= " + trim (string (pkanketa.summax, ">>>,>>>,>>>,>>9.99")))
  skip
  v-pkpartner label "ПРЕДПРИЯТИЕ" format "x(10)" help " F2 - справочник"
               validate (checkpartn(v-pkpartner, output v-msgerr), v-msgerr)
  pkanketa.billsum format "zzz,zzz,zz9.99" label "СТОИМОСТЬ"
    help " Введите цену приобретения"
    validate (pkanketa.billsum <> 0, " Обязательная информация - 0 не допускается !")
  "    "
  pkanketa.rescha[4] label "ПРИМЕЧАНИЕ" format "x(30)"
  skip
  pkanketa.goal label "ЦЕЛЬ КРЕДИТА" help " Введите наименование товара"
                validate (pkanketa.goal <> "", " Обязательная информация - пустая строка не допускается !")  skip
  with centered overlay row 11 side-labels frame pkank1.

v-sroku = v-srokmax.
find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if pkanketa.srok < v-srokmax and not(pkanketa.srok = 1) then v-sroku = pkanketa.srok.

do transaction:
   find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
       pkanketa.ln = s-pkankln exclusive-lock no-error.
   
   displ pkanketa.summax with frame pkank1.
   update pkanketa.summax with frame pkank1.
   
   update pkanketa.srok with frame pkank1.

   update v-dat pkanketa.sumq with frame pkank1.
   
   v-sumcom = pk-tarif (pkanketa.sumq).
   v-sumfin = pkanketa.sumq + v-sumcom.
   displ pk-tarif (pkanketa.sumq) @ v-sumcom v-sumfin with frame pkank1.
   
   if pkanketa.rescha[3] <> '' then do:
     find first bkcard where bkcard.bank = s-ourbank and bkcard.contract_number = pkanketa.rescha[3] exclusive-lock no-error.
     if avail bkcard then assign bkcard.anketa = 0 bkcard.whoout = '' bkcard.whnout = ?.
     pkanketa.rescha[3] = ''.
   end.
   
   /* если сумма запроса 0 -> попробовать определить сумму запроса по сумме кредита */
   if pkanketa.sumq = 0 then update v-sumfin with frame pkank1.
   if v-sumfin > 0 then do:
     pkanketa.sumq = pk-tariffin (v-sumfin).
     v-sumcom = pk-tarif (pkanketa.sumq).
     displ pkanketa.sumq v-sumcom with frame pkank1.
   end.

   /* sasco : запрос на цель кредита + парнтера */
   v-pkpartner = pkanketa.partner.
   update v-pkpartner with frame pkank1.
   if v-pkpartner <> "" then update pkanketa.goal with frame pkank1.
   pkanketa.partner = v-pkpartner.

   v-pkpartner = pkanketa.partner.
   update v-pkpartner with frame pkank.
   if v-pkpartner <> "" then do:
      update pkanketa.billsum
             pkanketa.goal
             with frame pkank1.
      repeat:
        update pkanketa.billnom with frame f-dop.
        if pkanketa.billnom <> "" then leave.
      end.
      hide frame f-dop.
   end.
   pkanketa.partner = v-pkpartner.

   update pkanketa.rescha[4] with frame pkank1.

   if pkanketa.sumq = 0 then pkanketa.sts = "00".
   else do:
       pkanketa.sts = "10".
       /* а вдруг это раньше был отказ? тогда там ставка не проставлена! */
       if pkanketa.rateq = 0 then do:
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
       if pkanketa.id_org = "inet" then pkanketa.sts = "12".
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
   
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-error.
   pkanketh.rescha[3] = entry(1, pkanketh.rescha[3]) + ',' + string(v-dat) + ',' + string(pkanketa.sumq) + ',' + string(pkanketa.srok) + ',' + string(g-today) + ',' + g-ofc.

end.

release pkanketa.
