/* pkkkbdc.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Запрос на определение суммы и срока кредита для Быстрые деньги (s-credtype = "6") кредит-карта
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
        22/02/2006 madiyar
 * BASES
        bank, comm, cards
 * CHANGES
        02/03/2006 madiyar - убрал отладочное сообщение
        12/10/2007 madiyar - по повторным кредитам ставка - из справочника
        04.06.2008 madiyar - валютный контроль 
*/

{global.i}
{pk.i}

{pk-sysc.i}

message " В данный момент выдача кредитов картой не работает! " view-as alert-box error.
return.

def shared frame pkank.

{pkanklon.f}
{pkcifnew.i}
{get-dep.i}

def var v-sumcom as deci.
def var v-sumfin as deci.
def var v-sumabn as deci.
def var v-sroku as inte.
def var v-skip as logical.
def var v-dat as date.
def var v-dpt as integer.

def temp-table t-lnf
  field nominal as deci
  index main is primary nominal.

for each spr where spr.sprcod = "bknomin" no-lock:
  create t-lnf. t-lnf.nominal = deci(spr.code).
end.

def temp-table t-ln
  field nominal as deci
  index main is primary nominal.

form
  pkanketa.summax label "  МАКСИМАЛЬНАЯ СУММА " format "zzz,zzz,zzz,zz9.99" " " skip
  pkanketa.srok   label "        СРОК КРЕДИТА " format "z9" " " skip
  v-dat           label "  ДАТА КРЕД КОМИТЕТА " format "99/99/9999"
     validate (v-dat >= pkanketa.rdt, " Дата кред.комитета не может быть меньше даты регистрации анкеты") " " skip
  pkanketa.sumq   label "  УТВЕРЖДЕННАЯ СУММА " format "zzz,zzz,zzz,zz9.99" help "F2 - справочник"
     validate(can-find(t-ln where t-ln.nominal = pkanketa.sumq), " Нет карты с таким номиналом! ") " " skip
  v-sumcom        label "      СУММА КОМИССИИ " format "zzz,zzz,zzz,zz9.99" " " skip
  v-sumabn        label "        КОМИССИЯ ABN " format "zzz,zzz,zzz,zz9.99" " " skip
  v-sumfin        label "       СУММА КРЕДИТА " format "zzz,zzz,zzz,zz9.99"
  pkanketa.rescha[3] label "               КАРТА " format "x(18)" " " skip
  with centered overlay row 11 side-labels frame pkank1.

on help of pkanketa.sumq in frame pkank1 do:
  find first t-ln no-error.
  if not avail t-ln then do:
    message skip " Список соответствующих номиналов пуст! " skip(1) view-as alert-box button ok title "".
    return.
  end.
{itemlist.i 
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.nominal label 'НОМИНАЛ' format '>>>,>>>,>>>,>>9' "
       &chkey = "nominal"
       &chtype = "deci"
       &index  = "main"
       &end = "if keyfunction(lastkey) = 'end-error' then return."
  }
  pkanketa.sumq = t-ln.nominal.
  displ pkanketa.sumq with frame pkank1.
end.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln exclusive-lock no-error.
if not avail pkanketa then return.

do transaction on error undo, return:

   v-dpt = get-dep(g-ofc,g-today).

   update pkanketa.summax with frame pkank1.
   update pkanketa.srok with frame pkank1.
   update v-dat with frame pkank1.

   for each t-ln: delete t-ln. end.
   v-skip = no.
   for each t-lnf no-lock:
     if v-skip then next.
     create t-ln. t-ln.nominal = t-lnf.nominal.
     if t-lnf.nominal >= pkanketa.summax then v-skip = yes.
   end.

   for each t-ln:
     find first bkcard where bkcard.bank = s-ourbank and bkcard.nominal = integer(t-ln.nominal) and bkcard.point = v-dpt
                         and bkcard.who1 <> '' and bkcard.who2 <> '' and bkcard.anketa = 0 no-lock no-error.
     if not avail bkcard then delete t-ln.
   end.

   update pkanketa.sumq with frame pkank1.

   find first tarif2 where tarif2.str5 = "039" and tarif2.stat = 'r' no-lock no-error.
   if avail tarif2 then v-sumabn = tarif2.ost.
   else v-sumabn = 350.

   v-sumfin = pkanketa.sumq + pk-tarif (pkanketa.sumq) + v-sumabn.
   displ pk-tarif (pkanketa.sumq) @ v-sumcom v-sumabn v-sumfin with frame pkank1.

   find first bkcard where bkcard.bank = s-ourbank and bkcard.nominal = integer(pkanketa.sumq) and bkcard.point = v-dpt
                         and bkcard.who1 <> '' and bkcard.who2 <> '' and bkcard.anketa = 0 exclusive-lock no-error.
   if avail bkcard then do:
     pkanketa.rescha[3] = bkcard.contract_number.
     displ pkanketa.rescha[3] with frame pkank1.
     bkcard.anketa = pkanketa.ln.
     bkcard.whoout = g-ofc.
     bkcard.whnout = g-today.
   end.
   else do:
     message " Свободные карты с данным номиналом отсутствуют! " view-as alert-box buttons ok.
     undo, return.
   end.

   if pkanketa.sumq = 0 then pkanketa.sts = "00".
   else do:
     pkanketa.sts = "10".

     /* а вдруг это раньше был отказ? тогда там ставка не проставлена! */
     if pkanketa.rateq = 0 then do:
       pkanketa.rateq = deci(entry(pkanketa.crc,get-pksysc-char("lon%"),"|")).

       /* 10% скидка ставки */
       find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
       if avail pkanketh then
         if trim(pkanketh.rescha[3]) <> '' then pkanketa.rateq = deci(entry(pkanketa.crc,get-pksysc-char("lon%r"),"|")).

     end.
   end.

   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-error.
   pkanketh.rescha[3] = entry(1, pkanketh.rescha[3]) + ',' + string(v-dat) + ',' + string(pkanketa.sumq) + ',' + string(pkanketa.srok) + ',' + string(g-today) + ',' + g-ofc.

end.

/*release pkanketa.*/
find current pkanketa no-lock.
pause.
