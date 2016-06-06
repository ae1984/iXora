/* pkzapr-6.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Запрос на определение суммы и срока кредита для Быстрые деньги (s-credtype = "6")
        копия "Быстрых кредитов"
 * RUN
      
 * CALLER
        pkzapr.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-13-2
 * AUTHOR
        03.07.2003 marinav
 * CHANGES
        09.10.2003 marinav - вынесение заявки на кредитный комитет
        31.10.2003 marinav - замена pkanketh.rescha[3] вместо yes на "1"
        15.01.2004 nadejda - проверка суммы запроса на превышение максимальной с учетом суммы комиссии
        28.01.2004 sasco   - запрос на предприятие - партнера
        18.08.2004 madiar  - проверка правильности ввода менеджером запрашиваемой суммы
        20/05/2005 madiar  - пока жестко прописал минимум суммы кредита для Алматы
        27/08/2005 madiar  - миллион на 3 года (Алматы)
        31/08/2005 madiar  - миллион на 3 года (Алматы) - изменения в расчете сумм
        01/09/2005 madiar  - миллион на 3 года (Алматы) - убрал перерасчет срока v-srmin
        21/11/2005 madiar  - максимальная сумма кредита в Актобе - 750000
        26/12/2005 madiar  - округление максимальной суммы для срока
        16/01/2006 madiar  - максимальная сумма кредита в Актобе - 1000000
*/

{global.i}
{pk.i}

{pk-sysc.i}

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-error.

if entry(1,pkanketh.rescha[3]) = "1" then do:
  message skip " Решение о сумме и сроке должно быть принято в пункте ""КредКом"" !" skip(1) view-as alert-box buttons ok .
  return.
end.

def var v-sel as char.
run sel2 ("Выдача :", " 1. Наличными | 2. Картой ", output v-sel).
if v-sel = "2" then do: run pkzaprc. return. end.
else if v-sel <> "1" then return.

def var v-srmin as decimal.
def var v-sroktemp as deci.
def var v-summin as deci.
def var v-summax as deci.
def var v-summax4srok as deci.
def var v-srokmin as decimal.
def var v-srokmax as decimal.
def var v-sumcom as deci.
def var v-sumfin as deci.
define var v-sroku as inte.

def shared frame pkank.


{pkanklon.f}
{pkcifnew.i}

function chk-sum returns logical (p-value as decimal).
  if p-value = 0 then return true.

  if p-value + pk-tarif (p-value) > v-summax4srok then do:
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
  pkanketa.srok label "        СРОК КРЕДИТА " format "z9"
     validate (pkanketa.srok >= v-srokmin and pkanketa.srok <= v-sroku, "Срок кредита должна быть >= " + trim(string(v-srokmin,">>9")) + " и <= " + trim(string(v-sroku,">>9")))
  " "
  skip
  v-summax4srok label "  МАКСИМАЛЬНАЯ СУММА " format "zzz,zzz,zzz,zz9.99"
     validate (v-summax4srok >= v-summin and v-summax4srok <= v-summax,
         "Сумма кредита должна быть >= " + trim (string (v-summin, ">>>,>>>,>>>,>>9.99")) +
         " и <= " + trim (string (v-summax, ">>>,>>>,>>>,>>9.99")))
  " "
  skip
  pkanketa.sumq   label "  УТВЕРЖДЕННАЯ СУММА "
     validate (chk-sum (pkanketa.sumq), v-msgerr)
     format "zzz,zzz,zzz,zz9.99" " " skip
  v-sumcom        label "      СУММА КОМИССИИ " format "zzz,zzz,zzz,zz9.99" skip
  v-sumfin        label "       СУММА КРЕДИТА " format "zzz,zzz,zzz,zz9.99"
     validate (v-sumfin = 0 or (v-sumfin >= v-summin and v-sumfin <= pkanketa.summax),
          "Сумма кредита должна быть >= " + trim (string (v-summin, ">>>,>>>,>>>,>>9.99")) +
          " и <= " + trim (string (pkanketa.summax, ">>>,>>>,>>>,>>9.99")))
  with centered overlay row 13 side-labels frame pkank1.


find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksum" no-lock no-error.
if avail pksysc then do:
  v-summin = deci(entry(1,pksysc.chval)).
  v-summax = deci(entry(2,pksysc.chval)).
end.
else assign v-summin = 29999 v-summax = 750000.


find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksrk" no-lock no-error.
if avail pksysc then do:
  v-srokmin = int(entry(1, pksysc.chval)).
  v-srokmax = int(entry(2, pksysc.chval)).
end.
else assign v-srokmin = 6 v-srokmax = 24.
if s-ourbank = 'txb00' then v-srokmax = 36.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln exclusive-lock no-error.
if not avail pkanketa then return.

v-sroku = v-srokmax.
if pkanketa.srok < v-srokmax then v-sroku = pkanketa.srok.

/*
find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksrk" no-lock no-error.
*/

do transaction on error undo, return:
   
   update pkanketa.srok with frame pkank1.
   v-summax4srok = round(pkanketa.summax / v-sroku * pkanketa.srok,2).
   
   displ v-summax4srok with frame pkank1.
   
   update pkanketa.sumq
          validate(chk-sum (pkanketa.sumq), v-msgerr)
      with frame pkank1.
   
   v-sumfin = pkanketa.sumq + pk-tarif (pkanketa.sumq).
   displ pk-tarif (pkanketa.sumq) @ v-sumcom v-sumfin with frame pkank1.
   pause.

   if pkanketa.rescha[3] <> '' then do:
     find first bkcard where bkcard.bank = s-ourbank and bkcard.contract_number = pkanketa.rescha[3] exclusive-lock no-error.
     if avail bkcard then assign bkcard.anketa = 0 bkcard.whoout = '' bkcard.whnout = ?.
     pkanketa.rescha[3] = ''.
   end.

   if pkanketa.sumq > 0 then do:
      v-sroktemp = pkanketa.sumq / (pkanketa.summax / v-srokmax).
              if v-sroktemp - trunc(v-sroktemp, 0) > 0
                 then v-srmin = trunc(v-sroktemp + 1, 0).
                 else v-srmin = v-sroktemp.
              
              if v-srmin < v-srokmin and v-srmin > 0 then v-srmin = v-srokmin.
              
              pkanketa.srokmin = v-srmin.
              /* pkanketa.srok = v-srmin. */
              
      displ  pkanketa.sumq
             pkanketa.srokmin
             pkanketa.srok with frame pkank.
      
      /*
      update pkanketa.srok validate(pkanketa.srok >= pkanketa.srokmin and pkanketa.srok <= v-srokmax,
                             "Срок должен быть больше минимального и меньше " + trim(string(v-summax4srok,">>9")) + " месяцев") with frame pkank.
      
      displ pkanketa.srok with frame pkank.
      */

   end.

   /* запрос на цель кредита + парнтера */
   v-pkpartner = pkanketa.partner.
   update v-pkpartner with frame pkank.
   if v-pkpartner <> "" then do:
      update pkanketa.billsum
             pkanketa.goal
             with frame pkank.
      repeat:
        update pkanketa.billnom with frame f-dop.
        if pkanketa.billnom <> "" then leave.
      end.
      hide frame f-dop.
   end.
   pkanketa.partner = v-pkpartner.

/*   v-pkpartner = pkanketa.partner.
   update pkanketa.billsum pkanketa.goal
          v-pkpartner with frame pkank.
   pkanketa.partner = v-pkpartner.

   repeat:
     update pkanketa.billnom with frame f-dop.
     if pkanketa.billnom <> "" then leave.
   end.
*/
end.
release pkanketa.
