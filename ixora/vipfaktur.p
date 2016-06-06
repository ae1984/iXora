/* vipfaktur.p
 * MODULE
        Выписки по счетам клиентов
 * DESCRIPTION
        for Bank Commision (CHG)
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
        31/12/99 pragma
 * CHANGES
                   sasco - выписка по дилингу 
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
        01.01.2004 nadejda - изменила ставку НДС - брать из sysc
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        29/10/2008 madiyar - поменял кода символов псевдографики
*/


def input parameter p-vid as char. /*  mem ili memf vid dokumenta*/
def input parameter s-hacc like jl.acc.
def input parameter s-jh like jl.jh.
def input parameter s-ln like jl.ln.
def input parameter s-sumv like jl.dam.
def var s-crc like crc.crc.
def var s-code like crc.code.
def var v-ln as log .
def var v-tmp as cha.
def shared var g-today as date .
def shared var g-batch as log .
def var s-cif like cif.cif.
def var v-point like point.point.
def var v-regno like point.regno.
def var in_cif like cif.cif.
def var in_account like aaa.aaa.
def var v-nazn1 as cha format 'x(60)'.
def var in_command as char init "joe".
def var in_destination as char init "mem.img".
def var MyMonths as char extent 12
init ["января","февраля","марта","апреля","мая","июня","июля","августа",
"сентября","октября","ноября","декабря"].
def var v-pnal as integ . /* Postavit v input parametr */
def var partkom as char.
def var v-datword as char format "X(30)".
def var v-rate as deci.
def buffer b-jh for jh.
def buffer b-jl for jl.
def buffer c-aaa for aaa.
def shared var flg1 as log initial true.

def var s-jl like jl.ln.
def var s-date as date format "99/99/9999".
def var s-jdt as date format "99/99/9999".
def var s-glcom like gl.gl.
def var v-sumword as char format "X(60)".
def var sumword1 as char.
def var sumword2 as char.
def var vcrc1 as char. def var vcrc2 as char.
def var v-bankcode as char format "X(9)" init "XXX".
def var v-ordnum as integer.
def var v-fakturnum as integer.
def var v-platcode as char format "X(15)".
def var s-amt like jl.dam. 
def var v-amt like jl.dam.
def var s-gl like gl.gl.
def var sc-name like cif.name.
def var s-sts as char format "X(3)".
def var m-rtn as log.
def var ipos as integer init 0.
def var i as integer.
define variable s-trx like jl.trx.
define variable v-nazn as character.
/*
form cif.cif label "Клиент"
cif.name format "X(50)" label "Наименование"
s-hacc label "Счет"
with side-label 1 column centered frame cif.
displ s-hacc s-jh s-ln .
pause 112.
*/

def var v-nds as decimal.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds = sysc.deval.

   
   flg1 = true.
find point where point.point eq v-point no-lock no-error.
  if available point then v-regno = point.regno.
  else do:
   find first point no-lock no-error.
   if available point then v-regno = point.regno.
   else v-regno = "".
  end.


do while index("1234567890",substring(v-regno,1,1)) eq 0:
v-regno = substring(v-regno,2).
end.
i = 1.
do while index("1234567890",substring(v-regno,i,1)) ne 0:
i = i + 1.
end.

v-regno = substring(v-regno,1,i).

find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
if available sysc then v-bankcode = substring(trim(sysc.chval),7,3).


 find jl where jl.jh = s-jh and jl.ln = s-ln no-lock no-error.
  if available jl then do:
     s-trx =  jl.trx.
     s-glcom  = jl.gl.
    /* s-sumv   = jl.dam + jl.cam.*/
  end.


/* -------------------- HOBOE ----------------------------- */
find first jh where jh.jh = jl.jh no-lock no-error.

/*-------------------------------------------------------------*/
if jh.sub <> 'dil' then 
    find first fakturis where fakturis.jh = s-jh and fakturis.trx = s-trx and
        fakturis.ln = s-ln use-index jhtrxln no-lock no-error.

if available fakturis then do:
    s-sts      = fakturis.sts.
    s-jdt      = fakturis.jdt.
    s-date     = fakturis.rdt.
    s-cif      = fakturis.cif.
    in_account = fakturis.acc.
    v-amt      = fakturis.amt.
    v-ordnum   = fakturis.order.
    v-fakturnum = fakturis.faktura.
end.
else do:
    /* ----------------------------- HOBOE -----------------*/
    find first dealing_doc where dealing_doc.docno = jh.ref no-lock no-error.
    if dealing_doc.doctype eq 1 or dealing_doc.doctype eq 2 then 
      in_account = dealing_doc.tclientaccno.
    else 
      in_account = dealing_doc.vclientaccno.
    v-ordnum = integer(jh.ref).
    find aaa where aaa.aaa = s-hacc no-lock no-error.
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if avail cif then do:
       v-platcode = trim(cif.jss).
       sc-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
    end.
    s-date = jh.whn.
end. 
   
find aaa where aaa.aaa = s-hacc no-lock no-error.
   if available aaa then s-crc = aaa.crc.
   if s-crc ne 1 then do:
     find crc where crc.crc eq s-crc no-lock.
     s-code = crc.code.
   end.

   if s-jdt eq g-today and s-crc ne 1 then do:
    find crc where crc.crc = s-crc no-lock no-error.
     if avail crc then
         v-rate = crc.rate[1] / crc.rate[9].
   end.

   if s-jdt ne g-today and s-crc ne 1 then do:
    find last crchis where crchis.crc eq s-crc
      and crchis.rdt <= s-jdt no-lock no-error.
      if avail crchis then
       v-rate = crchis.rate[1] / crchis.rate[9].
   end.

 find cif where cif.cif = s-cif no-lock no-error.
 if avail cif then do:
   v-platcode = cif.jss.
   sc-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
 end.

  Run PrintOrder in This-Procedure.

Procedure PrintOrder:
 /*  find first fakturis where fakturis.jh = s-jh and fakturis.trx = s-trx and
        fakturis.ln = s-jl no-lock no-error.
   if not available fakturis
   then  v-ordnum = next-value(vptrx).  /* Change Sequence */
   else v-ordnum = fakturis.order. */
   output to value(in_destination) append.
   find first cmp no-lock.

     put skip '"' + trim(cmp.name) + '"' format "X(60)".
     put skip "+" format "x" at 54 fill("-",16) format "X(16)"
     "+" format "x" space (13)
     "+" format "x"  fill("-",7) format "X(7)"
     "+" format "x"  .
   put skip space(30) "МЕМОРИАЛЬНЫЙ ОРДЕР  N " format "X(23)".
   
   
   /*------------------------------- HOBOE ----------------------*/
   if jh.sub <> 'dil' then

   put "|" format "x" " " string(v-ordnum) format "X(15)"
       "|" format "x" space(13)  "|" format "x" "0401009"
       "|" format "x" .
   
   else  put "|" format "x" " " trim(jh.ref) format "X(15)"
          "|" format "x" space(13)  "|" format "x" "0401009"
                 "|" format "x" .
   /*------------------------------------------------------------*/                       
   put skip space(53) "+" format "x" fill("-",16) format "X(16)"
        "+" format "x"  space (13) "+" format "x"
       fill("-",7) format "X(7)"  "+" format "x".
   put skip space(34) s-date format "99/99/9999" "г.".
   put skip "Плательщик" space(55) "Дебет" space(10) "Сумма".
   put skip "+" format "x" fill("-",12) format "x(12)"
            "+" format "x"  space(46) "+" format "x" fill("-",15) format "X(15)"
             "+" format "x" fill("-",15) format "X(15)"
             "+" format "x".
   put skip "|" format "x"  v-platcode format "X(12)"  "|" format "x"
             trim(sc-name) format "x(46)" "|" format "x"
       space(15) "|" format "x" space(15) "|" format "x".

   put skip "+" format "x"  fill("-",12) format "X(12)"
           "+" format "x"  fill ("-",46) format "x(46)"
           "|" format "x" space(15) "|" format "x" space(15)
           "|" format "x".
   put skip "Банк плательщика" format "X(60)" "|" format "x" space(15)
            "|" format "x"  space(15) "|" format "x".
   put skip space(50) "+"format "x" fill("-",9) format "x(9)"
            "|" format "x" space(15) "|" format "x" space(15)
            "|" format "x".
   put skip cmp.name format "X(50)" "|" format "x" v-bankcode format "X(9)"
            "|" format "x" "сч.N " in_account format "X(10)"
            "|" format "x" string(s-sumv,"-zzz,zzz,zz9.99") format "X(15)"
            "|" format "x" .
   put skip fill("-",50) format "X(50)" "+" format "x"
            fill("-",9) format "X(9)"  "+" format "x"
            fill("-",15) format "X(15)" "+" format "x"
            space(15) "|" format "x".

   put skip "Получатель" format "X(60)"  "     Кредит     "
       "|" format "x"  space(15) "|" format "x".
   put skip "+" format "x" fill("-",12) format "x(12)"
            "+" format "x"  space(46) "+" format "x"
            fill("-",15) format "X(15)" "+" format "x"
            space(15) "|" format "x".

   put skip "|" format "x" string(v-regno) format "X(12)"
            "|" format "x" cmp.name format "X(46)" "|" format "x"
            space(15) "|" format "x" space(15) "|" format "x".
  put skip "+" format "x"  fill("-",12) format "X(12)"
           "+" format "x"  fill ("-",46) format "x(46)"
           "|" format "x" space(15) "|" format "x" space(15)
           "|" format "x".
   put skip "Банк получателя" format "X(60)" "|" format "x" space(15)
            "|" format "x"  space(15) "|" format "x".
   put skip space(50) "+"format "x" fill("-",9) format "x(9)"
            "|" format "x" space(15) "|" format "x" space(15)
            "|" format "x".
   put skip cmp.name format "X(50)"  "|" format "x"
        v-bankcode format "X(9)"  "|" format "x"
       "сч.N " if s-glcom ne 0 then string(s-glcom) else "" format "X(10)"
        "|" format "x"  space(15)  "|" format "x" .


   v-sumword = ''.



   if s-crc eq 1
   then do:

        vcrc1 = " " + "тенге" + " ".
        vcrc2 = " " + "тиын".
   end.
   else do:

        vcrc1 = " " + s-code + " ".
        vcrc2 = "".
   end.

   Run sr-vrd(input s-sumv, output sumword1, input no).
   if sumword1 ne "nulle" and sumword1 ne ""
   then v-sumword = trim(sumword1) + vcrc1.
   else v-sumword = "ноль" + vcrc1.
   Run sr-vrd(input (100 * (s-sumv - truncate(s-sumv,0))),
              output sumword2, input no).
   if sumword2 begins "nulle"
   then sumword2 = "ноль".
   v-sumword = v-sumword + sumword2 + vcrc2.
   v-sumword = caps(substring(v-sumword,1,1)) + substring(v-sumword,2).

   sumword1 = "".
   sumword2 = "".
   if length(v-sumword) gt 60
   then do:
        sumword2 = v-sumword.
        ipos = r-index(substring(v-sumword,1,60)," ").

        if ipos gt 0
        then do:
             v-sumword = substring(v-sumword,1,ipos).
             sumword1 = substring(sumword2, ipos + 1).
        end.

        if length(sumword1) gt 76
        then do:
             sumword2 = sumword1.
             ipos = r-index(substring(sumword1,1,76), " ").
             if ipos gt 0
             then do:
                  sumword1 = substring(sumword1,1,ipos).
                  sumword2 = substring(sumword2, ipos + 1).
             end.
        end.
        else sumword2 = "".
   end.  /* length > 60 */
   put skip fill("-",50) format "X(50)" "+" format "x"
            fill("-",9) format "x(9)" "+" format "x"
            fill("-",15) format "x(15)" "+" format "x"
            fill("-",4) format "x(4)" "+" format "x"
            fill("-",10) format "x(10)" "|" format "x".

   put skip "Сумма прописью: " v-sumword format "X(60)" "|" format "x"
            "В.о." "|" format "x" space(10) "|" format "x".
   put skip sumword1 format "X(76)" "|" format "x"
             fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "|" format "x".
   put skip sumword2 format "X(76)" "|" format "x" "Н.п."
           "|" format "x" space(10)  "|" format "x".

    put skip fill("-",76) format "X(76)" "+" format "x"
            fill("-",4) format "x(4)" "+" format "x"
            fill("-",10) format "x(10)" "|" format "x".

   v-nazn = "Назначение платежа: ".
   find jh where jh.jh = s-jh no-lock.
   find first jl where jl.jh = s-jh and jl.ln = s-ln no-lock no-error .

   if trim(jl.rem[1]) begins "409 -" or trim(jl.rem[1]) begins "419 -"
   or trim(jl.rem[1]) begins "429 -" or trim(jl.rem[1]) begins "430 -"
   then do:
        v-nazn = v-nazn + string(jl.rem[1],"x(37)").
   end.
   else if jh.sub = "jou"
   then do:
        find first joudoc where jh.ref  = joudoc.docnum
        /* = substr(jh.ref,1,10) */
        no-lock no-error .
        if avail joudoc then
        find tarif2 where tarif2.str5 = joudoc.comcode
                      and tarif2.kont = s-glcom 
                      and tarif2.stat = 'r' no-lock no-error.
        if not available tarif2
        then v-nazn = v-nazn + string(jl.rem[5],"x(37)").
        else v-nazn = v-nazn + string(tarif2.pakalp,"x(37)").
   end.                 


/* ------------------------------ HOBOE -> DIL --------------- */
   else if jh.sub = "dil"
   then do:
        find first dealing_doc where jh.ref  = dealing_doc.docno
        no-lock no-error .
        if avail dealing_doc then
        v-nazn = v-nazn + string(jl.rem[5], "x(37)").
        v-nazn = v-nazn + trim (jl.rem[1]) + " " + 
                         trim (jl.rem[2]) + " " +
                         trim (jl.rem[3]) + " " +
                         trim (jl.rem[4]).
                         
        end.
/*-------------------------------------------------------------*/

   else if jh.sub = "RMZ"
   then do:
        find first remtrz where jh.ref = remtrz.remtrz no-lock
        no-error .
        if avail remtrz then
        find tarif2 where tarif2.str5 = string(remtrz.svccgr)
                      and tarif2.kont = s-glcom 
                      and tarif2.stat = 'r' no-lock no-error.
        if not available tarif2
        then v-nazn = v-nazn + string(jl.rem[5],"x(37)").
        else v-nazn = v-nazn + string(tarif2.pakalp,"x(37)").
   end.
   else do:
   if string(jl.rem[5],"x(45)") matches  "*долг*" then 
         v-nazn = v-nazn + substr(string(jl.rem[5],"x(45)"),6).
    else v-nazn = v-nazn + string(jl.rem[5],"x(37)").
  end.
    v-nazn1  = substr(v-nazn,21) . 

/*   v-nazn = v-nazn + string(jl.rem[5],"x(37)").
   v-nazn1  = substr(v-nazn,21) .*/
   if s-crc > 1
   then v-nazn = v-nazn + /* trim(string(s-sumv,"zzzzzz9.99")) + " "
        + s-code + */ " курс-"  + string(v-rate).
   put skip substring(trim(v-nazn),1,57) format "x(57)" space(19).

   put "|" format "x" "С.п." "|" format "x" space(10)
       "|" format "x".


    if trim(substring(v-nazn,58,76)) ne " " then do:
     put skip space(19) trim(substring(v-nazn,58,57)) format "x(57)".
    end.
    else put skip space(76).
    put  "|" format "x"
           fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "|" format "x".
   put skip space(76) "|" format "x" "O.п."
           "|" format "x" space(10)  "|" format "x".
   put skip space(76) "|" format "x"
           fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "|" format "x".
   put skip space(76) "|" format "x" "N.б."
           "|" format "x" space(10)  "|" format "x".
   put skip space(76) "+" format "x"
           fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "+" format "x".
   put skip "Приложение из 1-го листа                  Подписи" format "X(60)".
   put skip fill("-",93) format "X(93)" skip.

 /*  v-fakturnum = integer(substring(string(year(g-today),"9999"),3,2)
     + string(month(g-today),"99") + string(v-ordnum,"99999")).
                                     /* Change Sequence !!! */
*/

 if p-vid = "memf" then do:
   put skip(1) space(40) "НАЛОГОВЫЙ СЧЕТ-ФАКТУРА N " +
       string(v-fakturnum) format "X(50)".
   put skip space(45) "от " s-date format "99/99/9999".
   put skip(1).
   put skip "Оформлен на основании счета-фактуры N " + trim(string(v-ordnum))
       + " от " + string(s-date,"99/99/9999") format "X(93)".
   put skip "отгрузочных документов (накладных,".
   put skip "актов выполненных работ и т.д.)".
   put skip "Продавец   РНН N " v-regno format "X(12)" " "
       trim(cmp.name) format " X(50)" .

   /* ------------------------------- HOBOE ---------------------------- */
   if jh.sub <> 'DIL' then
     put skip "Покупатель РНН N " v-platcode format "X(12)" " "
              trim(trim(cif.prefix) + " " + trim(cif.name)) format "X(60)".
   else 
     put skip "Покупатель РНН N " v-platcode format "X(12)" " "
              trim(sc-name) format "X(60)".
              
   /*--------------------------------------------------------------------*/       
       
   put skip "Пункт назначения    _____ согласно тарифов на услуги _____".
   put skip space(70) /* vcrc1*/ "тенге"  .
   put skip fill("-",93) format "X(93)".
   put skip " N " "|" format "x" " Наименование товара работ услуг "
             "|" format "x"
       "    Стоимость  " "|" format "x" "         НДС         "
        "|" format "x" " Всего с НДС ".
   put skip "п/п" "|" format "x"  space(33)  "|" format "x"
       " без учета НДС "
       "|" format "x" " Ставка " "|" format "x"
       "   Сумма    "  "|" format "x" " к оплате    " .
   put skip fill("-",93) format "X(93)".

   put skip "1. " "|" format "x" " Наименование отгруженных товаров," format "X(50)".
   put skip "   " "|" format "x" " облагаемых НДС" format "X(50)".
   put skip "2. " "|" format "x" " Наименование отгруженных товаров," format "X(50)".
   put skip "   " "|" format "x" " необлагаемых НДС" format "X(50)".
   find first sub-cod where sub-cod.d-cod = "ndcgl" and
     sub-cod.ccode = "01" and sub-cod.sub = "gld" and
     sub-cod.acc = string(s-glcom) no-lock no-error .
   
   if avail sub-cod then do:
      put unformatted skip
          "3. " "|" format "x" " "  "Услуги банка по тарифу ," skip
          "   " "|" format "x" " облагаемые НДС :" skip  .
      put "   " "|" format "x"  string(v-nazn1)  format "x(56)" .

        if s-jdt < 01/01/2009 then v-nds = 0.13.

      put string(v-amt - round(v-amt * v-nds / (1 + v-nds), 2), "-z,zzz,zz9.99")
           format "X(13)".
      put "    " v-nds * 100 format "z9" "%" format "x".
      put string(v-amt * v-nds / (1 + v-nds), "-z,zzz,zz9.99") format "X(13)".
      put string(v-amt, "-z,zzz,zz9.99") format "X(13)".
      put skip "4. " "|" format "x" " Наименование выполненных работ и" format "X(50)".
      put skip "   " "|" format "x" " оказанных услуг, не облагаемых НДС" format "X(50)".
      put skip "" format "X(50)".
      put skip "   "  "    Итого по облагаемым оборотам" format "X(37)" ":"
               string(v-amt - round(v-amt * v-nds / (1 + v-nds), 2), "-z,zzz,zz9.99")
          format "X(13)"
          "    " v-nds * 100 format "z9" "%" format "x"
      string(v-amt * v-nds / (1 + v-nds), "-z,zzz,zz9.99") format "X(13)"
      string(v-amt, "-z,zzz,zz9.99") format "X(13)".
   end.
   else do:
      put skip "3. " "|" format "x"
               " Наименование выполненных работ и" format "X(50)".
      put skip "   " "|" format "x"
          " оказанных услуг, не облагаемых НДС" format "X(50)".
      put unformatted skip
          "4. " "|" format "x"  " Услуги банка по тарифу ," skip
          "   " "|" format "x" " не облагаемые НДС: "  skip  .
      put "   " "|" format "x"   string(v-nazn1)  format "x(56)".

 
      /* ----------------------------   HOBOE ----------------------------- */   
      if jh.sub <> 'dil' then  do:
         put string(v-amt ,"-z,zzz,zz9.99") format "X(13)".
         put "       "                                   format "X(7)".
         put " "                                         format "X(13)".
         put string(v-amt,"-z,zzz,zz9.99")               format "X(13)".
         put skip "" format "X(50)".
         put skip "    " "     Итого по не облагаемым оборотам:" format "X(37)"
           string(v-amt  ,"-z,zzz,zz9.99")
             format "X(13)"  "       "  format "X(7)" " "  format "X(13)"
             string(v-amt,"-z,zzz,zz9.99")  format "X(13)".
      end.
      else  do:
         put string(s-sumv ,"-z,zzz,zz9.99") format "X(13)".
         put "       "                                   format "X(7)".
         put " "                                         format "X(13)".
         put string(s-sumv,"-z,zzz,zz9.99")               format "X(13)".
         put skip "" format "X(50)".
         put skip "    " "     Итого по не облагаемым оборотам:" format "X(37)"
           string(s-sumv  ,"-z,zzz,zz9.99")
           format "X(13)"  "       "  format "X(7)" " "  format "X(13)"
           string(s-sumv,"-z,zzz,zz9.99") format "X(13)".
      end.     
      /* ------------------------------------------------------------------- */
   end.    


   v-datword = string(day(g-today)) + " " + MyMonths[month(g-today)] + " "
               + string(year(g-today),"9999") + " г.".

   put skip(1) v-datword format "X(30)".
   find ofc where ofc.ofc eq jl.who no-lock.
   put skip "Операционист " ofc.name format "X(30)" space(20)
       fill("-",17) format "X(17)" at 55.
   put skip space(60) "Подпись".
   put skip fill(chr(157),93) format "X(93)".
   put skip .
 end.
 output close.
End Procedure.



