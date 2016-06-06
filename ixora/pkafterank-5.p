/* pk-afterank-5.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
      Определение причин отказа, расчет суммы и вывод на экран для  БД 
       копия "Быстрых кредитов"
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-13-1
 * AUTHOR
        22.02.07
 * CHANGES
        19/03/07 marinav - включила ГЦВП
        06/07/2007 madiyar - изменение программ кредитования
*/

{global.i}
{pk.i}
{pk-sysc.i}

/*s-credtype = "6".
s-pkankln = 1076.
*/

def var flc as char.
def var fl as inte.
def var v-sumrat as inte.
def var v-parammaxsrok as integer init 12. /* по умолчанию 12 месяцев */.
def var v-parammaxsum as decimal init 156000. /* по умолчанию 750000 KZT */.
def var v-paramminsum as decimal init 40000. /* по умолчанию 40000 KZT */.
def var v-crcname as char.
def var v-summax as decimal.

def var v-sum as decimal.
def var v-job as int.
def var v-str as char.
def var v-i as integer.

def var v-dohod as decimal.
def var v-dohods as decimal.
def var v-gcvpl as logical init no.
def var v-street as char.
def var v-hom as char.
def var v-city as char.

/* рефинансирование */
def var v-reflon as char.
def var v-refkk as char.
def var v-refsum as deci.


if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  if lookup(g-ofc, "superman") = 0 then message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-inet as logical no-undo init no.
if pkanketa.id_org = "inet" or pkanketa.id_org = "wclient" then v-inet = yes.

/* ставка по повторным кредитам */
def var v-discount as integer init 0.
if pkanketa.id_org = '' then do: /* только для обычных и интернет-анкет */
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
  if avail pkanketh then
    if trim(pkanketh.rescha[3]) <> '' then v-discount = integer(trim(pkanketh.rescha[3])).
end.

flc = "". fl = 0.
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
if not avail pkanketh or (avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?)) then flc = flc + "01,".
else do:
  if pkanketh.rescha[1] <> '' and pkanketh.resdec[1] > 0 then do:
    v-discount = 0. /* на всякий случай зануляем признак льгот по повторным анкетам */
    v-reflon = entry(1,pkanketh.rescha[1]).
    if num-entries(pkanketh.rescha[1]) > 1 then v-refkk = entry(2,pkanketh.rescha[1]).
    else v-refkk = '1'. /* на кредком */
    v-refsum = pkanketh.resdec[1].
  end.
end.
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobs" no-lock no-error.
if avail pkanketh then v-job = int(pkanketh.value1).


find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "sik" no-lock no-error.
if not avail pkanketh or (avail pkanketh and ((int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?) and v-job <> 40)) then flc = flc + "02,".
else do:
   v-gcvpl = num-entries(pkanketh.rescha[3],";") > 1 .
   if v-job = 40 and not v-inet then do transaction:
      v-gcvpl = yes.
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype
           and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.
      v-sum = decimal(pkanketh.value1).
      update v-sum label " Внесите сумму дохода по данным справки о доходах " format ">>>,>>>,>>9.99" skip
         with side-label row 5 centered frame gcvp .
      pkanketh.value1 = string(v-sum).

      find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
      pkanketh.value3 = "1".
      pkanketh.value4 = "0".
      pkanketh.rating = pkkrit.rating_y.

      find current pkanketh no-lock.
   end.
end.

/*
      v-gcvpl = yes.
if not v-inet then do:
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype
           and  pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" exclusive-lock no-error.
      v-sum = decimal(pkanketh.value1).
      update v-sum label " Внесите сумму дохода по данным справки о доходах " format ">>>,>>>,>>9.99" skip
         with side-label row 5 centered frame gcvp .
      pkanketh.value1 = string(v-sum).

      find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
      pkanketh.value3 = "1".
      pkanketh.value4 = "0".
      pkanketh.rating = pkkrit.rating_y.
      find current pkanketh no-lock.
end.
*/

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
   if not avail pkanketh or (avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?)) then  flc = flc + "03,".


if not v-inet then do:
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "city1" no-lock no-error.
   if not avail pkanketh or (avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?)) then fl = fl + 1.
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "street1" no-lock no-error.
   if not avail pkanketh or (avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?)) then fl = fl + 1.
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "house1" no-lock no-error.
   if not avail pkanketh or (avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?)) then fl = fl + 1.
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "apart1" no-lock no-error.
   if avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?) then fl = fl + 1.
   if fl > 1 then flc = flc + "04,".
end.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "blacklst" no-lock no-error.
   if avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ?) then flc = "09," + flc.

/*find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2" no-lock no-error.
   if avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ? or pkanketh.value1 = "")
     then flc = "11," + flc.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2s" no-lock no-error.
   if avail pkanketh and (int(pkanketh.value3) = 0 or int(pkanketh.value3) = ? or pkanketh.value1 = "")
     then flc = "11," + flc.
*/

  /* определение совокупного чистого дохода */
  find first bookcod where bookcod.bookcod = "pkankdoh" no-lock no-error.

  if avail bookcod then do:
    /* найти среднюю сумму чистого дохода самого заемщика как среднее по цифрам в справочнике */
    v-dohod = 0.
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
       find bookcod where bookcod.bookcod = "pkankdoh" and bookcod.code = pkanketh.value1 no-lock no-error.
       if entry(3, bookcod.name, " ") = "..." then v-dohod = decimal (entry(1, bookcod.name, " ")).
       else v-dohod = (decimal (entry(1, bookcod.name, " ")) + decimal (entry(3, bookcod.name, " "))) / 2.
    end.

    v-dohods = 0.
    /* указан супруг? */
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "lnames" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      /* найти среднюю сумму чистого дохода супруга заемщика как среднее по цифрам в справочнике */
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
             pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2s" no-lock no-error.
      if avail pkanketh and pkanketh.value1 <> "" then do:
        find bookcod where bookcod.bookcod = "pkankdoh" and bookcod.code = pkanketh.value1 no-lock no-error.
        if entry(3, bookcod.name, " ") = "..." then v-dohods = decimal (entry(1, bookcod.name, " ")).
        else v-dohods = (decimal (entry(1, bookcod.name, " ")) + decimal (entry(3, bookcod.name, " "))) / 2.
      end.
    end.

   find sysc where sysc.chval = "6" and sysc.sysc = "pkminz" no-lock no-error .
   if v-dohod + v-dohods <  sysc.deval then flc = "11," + flc.
  end.

   find sysc where sysc.chval = "6" and sysc.sysc = "pkminz" no-lock no-error .
   find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
   if avail pkanketh then v-sum = decimal(pkanketh.value1). else v-sum = 0.
   if v-gcvpl and (not avail pkanketh or (avail pkanketh and (int(pkanketh.value1) < sysc.deval or int(pkanketh.value1) = ?))) then flc = flc + "12,".

   if v-gcvpl and flc = "" then do:
     /* Найдем, сколько человек платит по другим обязательствам ежемесячно и вычтем из чистого дохода*/
     find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
        pkanketh.ln = s-pkankln and pkanketh.kritcod = "sumob" no-lock no-error.
     if avail pkanketh and trim(pkanketh.value1) <> "" then v-sum = v-sum - deci(pkanketh.value1).
     if int(v-sum) < sysc.deval then  flc = flc + "14,".
   end.

/* определить рейтинг - для отказа/разрешения */
for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln no-lock.
    v-sumrat = v-sumrat + pkanketh.rating.
end.

do transaction:
    find current pkanketa exclusive-lock.
    pkanketa.rating = v-sumrat.
    find current pkanketa no-lock.
end. /* transaction */

/*
if pkanketa.bank = "txb00" then do:
*/
  find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "minra1" no-lock no-error.
  if avail pksysc and v-sumrat < pksysc.inval and v-gcvpl then flc = "05," + flc.
  else do:
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "minrat" no-lock no-error.
    if avail pksysc and v-sumrat < pksysc.inval and v-gcvpl then do:
      do transaction:
          /* социальный рейтинг */
          for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln exclusive-lock:
            if pkanketh.rating = 0 and pkanketh.resdec[5] <> 0 then do:
              pkanketh.rating = pkanketh.resdec[5].
              v-sumrat = v-sumrat + pkanketh.resdec[5].
            end.
          end.
          
          find current pkanketa exclusive-lock.
          pkanketa.rating = v-sumrat.
          find current pkanketa no-lock.
          
          find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "commentary" exclusive-lock no-error.
          if avail pkanketh then do:
            if trim(pkanketh.value2) <> '' then pkanketh.value2 = pkanketh.value2 + "; ".
            pkanketh.value2 = pkanketh.value2 + "Соц.рейтинг".
          end.
      end. /* transaction */
      if v-sumrat < pksysc.inval and v-gcvpl then flc = "05," + flc.
    end.
  end.
/*
end.
else do:
  find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "minrat" no-lock no-error.
  if avail pksysc and v-sumrat < pksysc.inval and v-gcvpl then flc = "05," + flc.
end.
*/

/* 16.11.2004 saltanat - Отказ по проблемным районам */
/* Г О Р О Д */
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "city1" no-lock no-error.
   if avail pkanketh then v-city = pkanketh.value1.
   else v-city = ''.
/* У Л И Ц А */
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "street1" no-lock no-error.
   if avail pkanketh then v-street = pkanketh.value1.
   else v-street = ''.
/* Д О М */
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "house1" no-lock no-error.
   if avail pkanketh then v-hom = pkanketh.value1.
   else v-hom = ''.

for each troublestr where if v-street <> '' then v-street = troublestr.street else true
                      and if v-city   <> '' then v-city matches troublestr.dop    + '*' else true
                      no-lock:
    /* Возможен следующий вариант */
    if troublestr.street = '' and troublestr.dop = '' and troublestr.homenum =  '' then leave.

    /* Остальные случаи обрабатываются */
    if troublestr.homenum <> '' then do:
       if lookup(v-hom,troublestr.homenum) > 0 then do:
          flc = "15," + flc.
          leave.
       end.
    end.
    else do:
     flc = "15," + flc.
     leave.
    end.
end.

/* причины отказов определены */

if flc = "" then flc = "00".

do transaction:
    find current pkanketa exclusive-lock.
    pkanketa.refusal = flc.
    find current pkanketa no-lock.
end.

/*
if pkanketa.bank = "txb00" then do:
*/

def var v-refuse as integer init 0.
def var v-minrat as integer init 0.
def var v-minsum as decimal init 0.
def var v-maxsum_12month as decimal init 0.
def var v-maxsum_wo_kk as decimal init 0.
if flc <> "00" then do:
  /* есть повод отказать */
  v-refuse = 2.
  
  do v-i = 1 to num-entries(flc):
    if trim(entry(v-i, flc)) <> '' and lookup(entry(v-i, flc),'11,12,14') = 0 then v-refuse = 1.
  end.
  
  if v-refuse = 2 then do:
    find first pkkrit where pkkrit.kritcod = "nedvstreet" no-lock no-error.
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "nedvstreet" no-lock no-error.
    if avail pkanketh then do:
      if (pkanketh.rating <> 0 and pkanketh.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))) or
         (pkanketh.resdec[5] <> 0 and pkanketh.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])))
      then v-refuse = 3.
    end.
    find first pkkrit where pkkrit.kritcod = "auto" no-lock no-error.
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "auto" no-lock no-error.
    if avail pkanketh then do:
      if (pkanketh.rating <> 0 and pkanketh.rating = integer(entry(integer(s-credtype),pkkrit.rating_yc[1]))) or
         (pkanketh.resdec[5] <> 0 and pkanketh.resdec[5] = integer(entry(integer(s-credtype),pkkrit.rating_yc[2])))
      then v-refuse = 3.
    end.
    
    if v-refuse = 3 then do:
       v-crcname = get-pksysc-char ("pkcrc").
       
       find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "minrat" no-lock no-error.
       if avail pksysc then v-minrat = pksysc.inval. else v-minrat = 60.
       find sysc where sysc.chval = "6" and sysc.sysc = "pkmins" no-lock no-error.
       if avail sysc then v-minsum = sysc.deval.
       else do:
         v-minsum = 50000.
       end.
       /*
       find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "minsum" no-lock no-error.
       if avail pksysc then v-minsum = pksysc.deval. else v-minsum = 40000.
       */
       
       v-summax = v-minsum + (pkanketa.rating - v-minrat) * 2000.
       
       find sysc where sysc.chval = "6" and sysc.sysc = "pkms12" no-lock no-error.
       if avail sysc then v-maxsum_12month = sysc.deval.
       else do:
         v-maxsum_12month = 50000.
       end.
       /*
       find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "msum12" no-lock no-error.
       if avail pksysc then v-maxsum_12month = pksysc.deval. else v-maxsum_12month = 50000.
       */
       
       if v-summax <= v-maxsum_12month then v-parammaxsrok = 12.
       else v-parammaxsrok = 36.
       
       find sysc where sysc.chval = "6" and sysc.sysc = "pkmskk" no-lock no-error.
       if avail sysc then v-maxsum_wo_kk = sysc.deval.
       else do:
         v-maxsum_wo_kk = 60000.
       end.
       /*
       find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "msumkk" no-lock no-error.
       if avail pksysc then v-maxsum_wo_kk = pksysc.deval. else v-maxsum_wo_kk = 60000.
       */
       
       do transaction:
           find current pkanketa exclusive-lock.
           /* определить статус анкеты */
           pkanketa.sts = "10".
           if v-summax > v-maxsum_wo_kk then  pkanketa.sts = "04".
           if not v-gcvpl then pkanketa.sts = "03".
           else do:
             find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
                 pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
             if trim(pkanketh.rescha[3]) = "1" then pkanketa.sts = "04".
           end.
           
           /* 01/07/2005 madiyar - кредит как-бы разрешен - нужно проставить проц. ставку */
           pkanketa.rateq = get-pksysc-dec ("lon%").
           
           /* message "s0..... " + trim(string(v-summax,">>>,>>>,>>9.99")) + " " + string(v-parammaxsrok) view-as alert-box. */
           
           if v-discount > 0 then do:
             pkanketa.rateq = get-pksysc-dec ("lon%r").
             if v-discount = 2 then pkanketa.sts = "04".
           end.
           else do:
             /* рефинансирование */
             /* message "s1..... " + trim(string(v-summax,">>>,>>>,>>9.99")) + " " + " " + v-reflon + " " + trim(string(v-refsum,">>>,>>>,>>9.99")) view-as alert-box. */
             if v-reflon <> '' and v-refsum > 0 then do:
               if v-refsum > v-summax then do:
                 v-summax = v-refsum.
                 if v-refkk = '1' then pkanketa.sts = "04".
                 /* заново пересмотрим срок */
                 if v-summax <= v-maxsum_12month then v-parammaxsrok = 12.
                 else v-parammaxsrok = 36.
               end.
               find first lon where lon.lon = v-reflon no-lock no-error.
               if lon.prem <> 0 then pkanketa.rateq = lon.prem.
               else if not v-inet then message " Ставка рефинансируемого кредита нулевая ~n Проверьте правильность ставки нового кредита " view-as alert-box warning.
             end.
             /* message "s2..... " + trim(string(v-summax,">>>,>>>,>>9.99")) + " " + string(v-parammaxsrok) view-as alert-box. */
           end.
           
           pkanketa.summax = v-summax.
           pkanketa.srok = v-parammaxsrok.
           pkanketa.kkdt = today.
           pkanketa.kkwho = g-ofc.
           
           /* 01/07/2005 madiyar - end */
           find current pkanketa no-lock.
       end. /* transaction */
       
       if not v-inet then
          if pkanketa.sts = "10" then
             displ  s-pkankln           label "  Номер анкеты " format ">>>>>9" skip
                    pkanketa.name  label "           ФИО " format "x(60)" skip(1)
                    v-summax       label " Максим. сумма " format "->>>,>>>,>>9.99" v-crcname no-label skip
                    v-parammaxsrok label "    на месяцев " format ">>>>9" skip
                    with side-label row 5 centered frame a1.
          else
             displ s-pkankln      label "   Номер анкеты " format ">>>>>9" skip
                   pkanketa.name  label "            ФИО " format "x(60)" skip
                   pkanketa.rnn   label "            РНН " format "x(12)" skip(1)
                   "  ЗАЯВКА ВЫНЕСЕНА НА КРЕДИТНЫЙ КОМИТЕТ  " skip
                   with side-label row 5 centered frame a3.
       return.
    end.
  end. /* if v-refuse = 2 */
end. /* if flc <> "00" */

/*
end. -- if pkanketa.bank = "txb00" --
*/

if flc <> "00" then do:
  /* есть повод отказать */
  do transaction:
      find current pkanketa exclusive-lock.
      pkanketa.sts = "00".
      find current pkanketa no-lock.
  end.
  
  if v-inet then return.
  
  v-str = "".
  do v-i = 1 to num-entries(pkanketa.refusal):
    for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(v-i, pkanketa.refusal) no-lock:
      if v-str <> "" then v-str = v-str + ", ".
      v-str = v-str + bookcod.name.
    end.
  end.

  displ s-pkankln      label "   Номер анкеты " format ">>>>>9" skip
        pkanketa.name  label "            ФИО " format "x(60)" skip
        pkanketa.rnn   label "            РНН " format "x(12)" skip(1)

        "     В ВЫДАЧЕ КРЕДИТА ОТКАЗАНО !!!      " skip(1)
        v-str        label " Причины отказа " format "x(60)"
     with side-label row 5 centered frame a3.
end.
else do:
  /* кредит разрешен */
  do transaction:
    find current pkanketa exclusive-lock.
    
    /* определить статус анкеты */
    if not v-gcvpl then pkanketa.sts = "03".
    else do:
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
         pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-lock no-error.

      if trim(pkanketh.rescha[3]) = "1" then pkanketa.sts = "04".
                                        else pkanketa.sts = "10".
    end.

    /* 14.09.2004 saltanat - Если клиент имеет карточку Texakabank с кредитным лимитом заявка выносится на кред.комитет */
  
    pkanketa.kkdt = today.
    pkanketa.kkwho = g-ofc.
    pkanketa.rateq = get-pksysc-dec ("lon%").
    
    
    if v-discount > 0 then pkanketa.rateq = get-pksysc-dec ("lon%r").
    if v-discount = 2 then pkanketa.sts = "04".
    
    find current pkanketa no-lock.
  end.

  if v-gcvpl then do:
    /* автоматическое определение максимальной суммы */

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "gcvpsum" no-lock no-error.

    v-summax = decimal(pkanketh.value1).

     /* Найдем, сколько человек платит по другим обязательствам ежемесячно и вычтем из чистого дохода*/
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "sumob" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> '' then v-summax = v-summax - deci(pkanketh.value1).

    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
           pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobpr2" no-lock no-error.

    find bookcod where bookcod.bookcod = "pkankdoh" and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod and entry(3, bookcod.name, " ") <> "..." and v-summax > decimal (entry(3, bookcod.name, " ")) then
       v-summax = decimal (entry(3, bookcod.name, " ")).
 
    for each bookcod where bookcod.bookcod = "pkankddd" no-lock.
       if  decimal (entry(1, bookcod.name, " ")) <= v-summax
           and decimal (entry(3, bookcod.name, " ")) >= v-summax
       then v-summax = v-summax * dec(bookcod.info[1]).
    end.
  
    /* расчет ежемесячного лимита в зависимости от рейтинга */
    /* if v-sumrat > 130 then v-summax так и остается с коэффициентом 1 */
    if v-sumrat > 115 and v-sumrat <= 130 then v-summax = v-summax * 0.9.
    if v-sumrat > 99 and v-sumrat <= 115 then v-summax = v-summax * 0.8.
    if v-sumrat > 83 and v-sumrat <= 99 then v-summax = v-summax * 0.7.
    if v-sumrat > 67 and v-sumrat <= 83 then v-summax = v-summax * 0.6.
    if v-sumrat <= 67 then v-summax = v-summax * 0.5.


    /* максимальная сумма кредита = ежемес.лимит * максимальный срок кредита */
    find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksrk" no-lock no-error.
    if avail pksysc then
      v-parammaxsrok = int(entry(2,pksysc.chval)).
    else do:
      if not v-inet then message skip " Параметр ANKSRK не найден для данного вида кредита !" skip(1)
         view-as alert-box buttons ok title " ОШИБКА ! ".
      v-parammaxsrok = 36.
    end.

    v-summax = v-summax * v-parammaxsrok.

    /* включаем только на декабрь 2005 - увеличение суммы на 10% */
    /*v-summax = v-summax * 1.1.*/
    /* включаем только на декабрь 2005 - end */
    
    find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "anksum" no-lock no-error.
    if avail pksysc then do:
      v-paramminsum = deci(entry(1,pksysc.chval)).
      v-parammaxsum = deci(entry(2,pksysc.chval)).
    end.
    else do:
      if not v-inet then message skip " Параметр ANKSUM не найден для данного вида кредита !" skip(1)
         view-as alert-box buttons ok title " ОШИБКА ! ".
      v-paramminsum = 50000.
      v-parammaxsum = 1000000.
    end.
    
    if v-summax > v-parammaxsum then v-summax = v-parammaxsum.
    
    /* message "u0..... " + trim(string(v-summax,">>>,>>>,>>9.99")) + " " + string(v-parammaxsrok) view-as alert-box. */
    
    /* рефинансирование */
    if v-reflon <> '' and v-refsum > 0 then do:
      if v-refsum > v-summax then do:
        v-summax = v-refsum.
        if v-refkk = '1' then do transaction:
           find current pkanketa exclusive-lock.
           pkanketa.sts = "04".
           find current pkanketa no-lock.
        end.
      end.
      find first lon where lon.lon = v-reflon no-lock no-error.
      if lon.prem <> 0 then do transaction:
        find current pkanketa exclusive-lock.
        pkanketa.rateq = lon.prem.
        find current pkanketa no-lock.
      end.
      else if not v-inet then message " Ставка рефинансируемого кредита нулевая ~n Проверьте правильность ставки нового кредита " view-as alert-box warning.
    end.
    
    /*
    if s-ourbank = 'txb00' then do:
    */
      if v-summax < v-paramminsum then do:
        do transaction:
            find current pkanketa exclusive-lock.
            pkanketa.refusal = "17,".
            pkanketa.sts = "00".
            find current pkanketa no-lock.
        end. /* transaction */
        if v-inet then return.

        v-str = "".
        do v-i = 1 to num-entries(pkanketa.refusal):
          for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(v-i, pkanketa.refusal) no-lock:
            if v-str <> "" then v-str = v-str + ", ".
            v-str = v-str + bookcod.name.
          end.
        end.
        
        displ s-pkankln      label "   Номер анкеты " format ">>>>>9" skip
              pkanketa.name  label "            ФИО " format "x(60)" skip
              pkanketa.rnn   label "            РНН " format "x(12)" skip(1)
              "     В ВЫДАЧЕ КРЕДИТА ОТКАЗАНО !!!      " skip(1)
              v-str        label " Причины отказа " format "x(60)"
              with side-label row 5 centered frame a3.
        return.
      end.
    /*
    end. --if s-ourbank = 'txb00'--
    */

    v-crcname = get-pksysc-char ("pkcrc").
    
    /* записать сумму в анкету */
    do transaction:
      find current pkanketa exclusive-lock.
      pkanketa.summax = v-summax.
      pkanketa.srok = v-parammaxsrok.
      find current pkanketa no-lock.
    end.

    if v-inet then return.

    if pkanketa.sts = "04" then do:
       displ s-pkankln      label "   Номер анкеты " format ">>>>>9" skip
             pkanketa.name  label "            ФИО " format "x(60)" skip
             pkanketa.rnn   label "            РНН " format "x(12)" skip(1)

             "  ЗАЯВКА ВЫНЕСЕНА НА КРЕДИТНЫЙ КОМИТЕТ  " skip
             with side-label row 5 centered frame a3.
      
      /* если большая сумма -> лист согласования на большой КредКом */
      /* 18/11/2004 madiyar - отменяем печать листа согласования
      find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "kksum" no-lock no-error.
      if not avail pksysc or
         (pkanketa.crc = 1 and pkanketa.summax >= pksysc.deval) or
         (pkanketa.crc <> 1 and pkanketa.summax >= pksysc.inval) then
        run pkkksogl. */
    end.
    else
     displ  s-pkankln           label "  Номер анкеты " format ">>>>>9" skip
            pkanketa.name  label "           ФИО " format "x(60)" skip(1)
            v-summax       label " Максим. сумма " format "->>>,>>>,>>9.99" v-crcname no-label skip
            v-parammaxsrok label "    на месяцев " format ">>>>9" skip
        with side-label row 5 centered frame a1.
  end.

end.
