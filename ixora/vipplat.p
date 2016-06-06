/* vipplat.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        29/10/2008 madiyar - поменял кода символов псевдографики
        17.02.2011 marinav - поле счета до 20 знаков
*/

/* v-mem-or.p  for Bank Commision (CHG)

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
   12.04.2011 ruslan - разделил мемориальный ордер и платежное поручение, изменил формат платежного поручения
   20.04.2011 ruslan - прописал v-platbname и v-polbname как 'АО "МЕТРОКОМБАНК"'.
   17/11/2011 evseev - переход на ИИН/БИН. Вывод БИН вместо РНН
   15/03/2012 id00810 - добавила v-bankname для печати
   05/05/2012 evseev - подключил {nbankBik.i}
   05/05/2012 evseev - при формировании ПП удалять город и при дате до 07/05/2012 использовать МЕТРОКОМ
   07/05/2012 evseev - подключил replacebnk.i
*/
{chbin.i}
{nbankBik.i}
{replacebnk.i}
def input parameter p-vid as char . /*  pl ili mem, memf */
def input parameter rec_id as recid.
def input parameter v-plnr as char format "x(15)".
def input parameter v-platcode like cif.jss format "x(15)".
def input parameter v-platname like cif.name.
def input parameter v-platacc like  aaa.aaa.
def input parameter v-platacc1 like  aaa.aaa.
def input parameter v-bankplat as char format "x(9)".
def input parameter v-platbname as char format "x(50)".
def input parameter v-polcode like cif.jss format "x(15)".
def input parameter v-polname like cif.name.
def input parameter v-polacc like  aaa.aaa.
def input parameter v-polacc1 like  aaa.aaa.
def input parameter v-bankpol as char format "x(9)".
def input parameter v-polbname as char format "x(50)".
def input parameter v-nazn as char.
def shared var flg1 as log initial true.

def var v-nazn1 as char format "x(71)".
def var v-nazn2 as char format "x(71)".
def var v-nazn3 as char format "x(71)".

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
def var in_command as char init "joe".
def var in_destination as char init "plat.img".
def var MyMonths as char extent 12
init ["января","февраля","марта","апреля","мая","июня","июля","августа",
"сентября","октября","ноября","декабря"].

def var partkom as char.
def var v-datword as char format "X(30)".
def var v-rate as deci.
def var s-date as date format "99/99/9999".

def var v-kas like gl.gl.

def var v-sumword as char format "X(60)".
def var sumword1 as char.
def var sumword2 as char.
def var vcrc1 as char. def var vcrc2 as char.
def var v-bankcode as char format "X(9)".
def var s-amt like jl.dam.
def var v-amt like jl.dam.
def var s-gl like gl.gl.
def var sc-name like cif.name.
def var s-sts as char format "X(3)".
def var m-rtn as log.
def var ipos as integer init 0.
def var i as integer.
define variable s-trx like jl.trx.
def var ruk as char.
def var buh as char.
def var tim like jl.tim.
def var nnum like joudoc.num.



find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if avail sysc then v-kas = sysc.inval.
   flg1 = true.

if  v-platacc = string(v-kas) then do:
   p-vid ="mem".
   find first point no-lock no-error.
   if available point then v-regno = point.regno.
   else v-regno = "".

    do while index("1234567890",substring(v-regno,1,1)) eq 0:
       v-regno = substring(v-regno,2).
    end.
     i = 1.
    do while index("1234567890",substring(v-regno,i,1)) ne 0:
       i = i + 1.
    end.
    v-regno = substring(v-regno,1,i).
    v-platcode= v-regno.
    find first cmp no-lock no-error.
    v-platname = /*cmp.name*/ v-nbankDgv.
end.
if v-polacc =string(v-kas) then do:
   p-vid = "mem".
   find first point no-lock no-error.
   if available point then v-regno = point.regno.
   else v-regno = "".

    do while index("1234567890",substring(v-regno,1,1)) eq 0:
       v-regno = substring(v-regno,2).
    end.
     i = 1.
    do while index("1234567890",substring(v-regno,i,1)) ne 0:
       i = i + 1.
    end.
    v-regno = substring(v-regno,1,i).
    v-polcode= v-regno.
    find first cmp no-lock no-error.
    v-polname = /*cmp.name*/ v-nbankDgv.
end.


find first cmp no-lock no-error.

find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
if available sysc then v-bankcode = trim(sysc.chval).
if s-date < 05/06/2012 then v-bankcode = "MEOKKZKA".

find jl where recid(jl) =rec_id no-lock no-error.
if not available jl then return.


if jl.dam > 0 then do:
      s-date = jl.jdt.
       v-amt = jl.dam.
       s-crc = jl.crc.
   v-platacc = jl.acc.
     if s-crc ne 1 then do:
      find crc where crc.crc eq s-crc no-lock.
       s-code = crc.code.
     end.
       v-bankplat = v-bankcode.
     v-platbname = 'АО ' + v-nbankDgv.
    if s-date < 05/06/2012 then v-platbname = 'АО "МЕТРОКОМБАНК"'.
    find aaa where aaa.aaa = jl.acc no-lock no-error.
    if available aaa then do:
     find cif where cif.cif = aaa.cif no-lock no-error.
     if available cif then do:
      if v-bin then v-platcode = cif.bin.
      else v-platcode = cif.jss.
      v-platname = trim(trim(cif.prefix) + " " + trim(cif.name)).
     end.
    end.
    if v-bankpol = substring(v-bankcode,7,3) then do:
        v-bankpol = v-bankcode.
        v-polbname = /*trim(cmp.name)*/ 'АО ' + v-nbankDgv.
        if s-date < 05/06/2012 then v-polbname = 'АО "МЕТРОКОМБАНК"'.
    end.
    if v-bankpol = v-bankcode then do:
       v-polbname = 'АО ' + v-nbankDgv.
       if s-date < 05/06/2012 then v-polbname = 'АО "МЕТРОКОМБАНК"'.
    end.



end.
else do:
   s-date = jl.jdt.
    v-amt = jl.cam.
    s-crc =jl.crc.
    v-polacc = jl.acc.
     if s-crc ne 1 then do:
      find crc where crc.crc eq s-crc no-lock.
       s-code = crc.code.
     end.
     v-polacc = jl.acc.
     v-bankpol = v-bankcode.
     v-polbname = 'АО ' + v-nbankDgv.
     if s-date < 05/06/2012 then v-polbname = 'АО "МЕТРОКОМБАНК"'.
    find aaa where aaa.aaa = jl.acc no-lock no-error.
    if available aaa then do:
     find cif where cif.cif = aaa.cif no-lock no-error.
     if available cif then do:
      if v-bin then v-polcode = cif.bin.
      else v-polcode = cif.jss.
      v-polname = trim(trim(cif.prefix) + " " + trim(cif.name)).
     end.
    end.
    if v-bankplat = substring(v-bankcode,7,3) then do:
        v-bankplat = v-bankcode.
        v-platbname = /*trim(cmp.name)*/ 'АО ' + v-nbankDgv.
        if s-date < 05/06/2012 then v-platbname = 'АО "МЕТРОКОМБАНК"'.
    end.
    if v-bankplat = v-bankcode then do:
       v-platbname = 'АО ' + v-nbankDgv.
       if s-date < 05/06/2012 then v-platbname = 'АО "МЕТРОКОМБАНК"'.
    end.
end.
/* naznachenie plateza*/

if  v-nazn = " " then
    v-nazn = trim (jl.rem[1]) + " " +
             trim (jl.rem[2]) + " " +
             trim (jl.rem[3]) + " " +
             trim (jl.rem[4]).
 if v-nazn ne "" then do:
      v-nazn1=v-nazn .
   if length(v-nazn1) > 71 then
     v-nazn1 = substr(v-nazn,71,71).
   else v-nazn1 =" ".
   if v-nazn1 ne "" and length(v-nazn1) > 71 then
    v-nazn2 = substr(v-nazn,142,71).
   else v-nazn2 = " ".
   if v-nazn2 ne "" and length(v-nazn2) > 71 then
    v-nazn3 = substr(v-nazn,213,71).
   else v-nazn3 = " ".
  end.

find first aaa where aaa.aaa = v-platacc no-lock no-error.
if avail aaa then do:
    for each sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = aaa.cif no-lock:
        if avail sub-cod then do:
            if sub-cod.ccode = "chief" then
                ruk = sub-cod.rcode.
            if sub-cod.ccode =  "mainbk" then
                buh = sub-cod.rcode.
        end.
    end.
end.

def var ofcname as char.
if jl.who <> "SUPERMAN" then do:
        find first ofc where ofc.ofc = jl.who no-lock no-error.
    if avail ofc then
        ofcname = ofc.name.
end.
else do:
    ofcname = "___________________________".
end.
def var kod as char.
def var kbe as char.
def var knp as char.

for each trxcod where trxcod.TRXH = jl.jh no-lock:
    if trxcod.trxln = 1 then do:
        if trxcod.codfr = "locat" then
        kod = trxcod.code.
        if trxcod.codfr = "secek" then
        kod = kod + trxcod.code.
        if trxcod.codfr = "spnpl" then
        knp = trxcod.code.
    end.
    else do:
        if trxcod.codfr = "locat" then
        kbe = trxcod.code.
        if trxcod.codfr = "secek" then
        kbe = kbe + trxcod.code.
    end.
end.

find first joudoc where joudoc.jh = jl.jh no-lock no-error.
if avail joudoc then do:
    nnum = joudoc.num.
    tim = joudoc.tim.
end.

  Run PrintOrder in This-Procedure.

Procedure PrintOrder:

    v-platbname    = del_city(v-platbname    ).
    v-polbname    = del_city(v-polbname    ).

    v-platbname  = replace_bnamebik(v-platbname , s-date).
    v-bankplat  = replace_bnamebik(v-bankplat , s-date).
    v-polbname  = replace_bnamebik(v-polbname , s-date).
    v-bankpol  = replace_bnamebik(v-bankpol , s-date).

if p-vid ="pl" then do:
      output to value(in_destination) append.
   put skip "+" format "x" fill("-",68) format "x(68)" "+" format "x".
   put skip "|" format "x" " " "Поступило в банк-получатель:" format "x(28)" day(s-date) format "99" " " MyMonths[month(s-date)] format "x(8)" year(s-date) format "9999" "г." format "x(2)" space(21)"|" format "x".
   put skip "|" format "x" " " "Время приёма: " format "x(14)" string(tim, "hh:mm:ss") space(44) "|" format "x".
   put skip "+" format "x" fill ("-",68) format "x(68)" "+" format "x".
   put skip(1).
   put skip space(35) "ПЛАТЕЖНОЕ ПОРУЧЕНИЕ N" format "X(21)" nnum.
   put skip  space(39) day(s-date) format "99" " " MyMonths[month(s-date)] format "x(8)" year(s-date) format "9999" "г.".
   put skip "+" format "x" fill("-",106) format "x(106)" "+" format "x".
   put skip "|" format "x" "Отправитель денег:" space(22) "|" format "x" space(14) "ИИК" space(13) "|" format "x" space(8)"Код" space(7) "|" format "x" space(15) "|".
   put skip "|" format "x" trim(v-platname) format "x(40)" "|" format "x" space(6) v-platacc format "x(20)" space(4) "|" format "x" space(8) trim(kod) space(2) "|" format "x" string(v-amt,"-zzz,zzz,zz9.99") format "X(15)" "|" format "x".
   if v-bin then
   put skip "|" format "x" "БИН:" v-platcode format "x(12)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|" format "x".
   else
   put skip "|" format "x" "РНН:" v-platcode format "x(12)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|" format "x".
   put skip "+" format "x" fill("-",90) format "x(90)"
            "|" format "x" space (15) "|" format "x".
   put skip "|" format "x" "Банк получатель:" space(24) "|" format "x" space(22) "БИК" space(24) "|" format "x" space(15) "|".
   put skip "|" format "x" v-platbname format "x(40)" "|" format "x" space(20) v-bankplat format "x(9)" space(20) "|" format "x" space(15) "|".
   put skip "+" format "x" fill("-",90) format "x(90)"
            "|" format "x" space (15) "|".
   put skip "|" format "x" "Бенефициар:" space(29) "|" format "x" space(14) "ИИК" space(13) "|" format "x" space(8)"Кбе" space(7) "|" format "x" space(15) "|".
   put skip "|" format "x" trim(v-polname) format "x(40)" "|" format "x" space(6) v-polacc format "x(20)" space(4) "|" format "x" space(8) trim(kbe) space(2) "|" format "x" space(15) "|".
   if v-bin then
   put skip "|" format "x" "БИН:" v-polcode format "x(12)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|".
   else
   put skip "|" format "x" "РНН:" v-polcode format "x(12)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|".
   put skip "+" format "x" fill("-",90) format "x(90)"
            "|" format "x" space (15) "|".
   put skip "|" format "x" "Банк бенефициара:" space(23) "|" format "x" space(22) "БИК" space(24) "|" format "x" space(15) "|".
   put skip "|" format "x" v-polbname format "x(40)" "|" format "x" space(20) v-bankpol format "x(9)" space(20) "|" format "x" space(15) "|".
   put skip "+" format "x" fill("-",90) format "x(90)"
            "|" format "x" space (15) "|".
   put skip "|" format "x" "Банк посредник:" space(25) "|" format "x" space(14) "ИИК" space(13) "|" format "x" space(8)"БИК" space(7) "|" format "x" space(15) "|".
   if v-bin then
   put skip "|" format "x" "БИН:" format "x(16)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|".
   else
   put skip "|" format "x" "РНН:" format "x(16)" space(24) "|" format "x" space(30) "|" format "x" space(18) "|" format "x" space(15) "|".
   put skip "+" format "x" fill("-",106) format "x(106)"
            "+".

   v-sumword = ''.

 /*  find aaa where aaa.aaa eq in_account no-lock. */
   if s-crc eq 1
   then do:
        vcrc1 = " " + "тенге" + " ".
        vcrc2 = " " + "тиын".
   end.
   else do:
     /*  find crc where crc.crc eq aaa.crc no-lock.*/
        vcrc1 = " " + s-code + " ".
        vcrc2 = "".
   end.

   Run sr-vrd(input v-amt, output sumword1, input no).
   if sumword1 ne "nulle" and sumword1 ne ""
   then v-sumword = trim(sumword1) + vcrc1.
   else v-sumword = "ноль" + vcrc1.
   Run sr-vrd(input (100 * (v-amt - truncate(v-amt,0))),
              output sumword2, input no).
   if sumword2 begins "nulle"
   then sumword2 = "00".
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
   end.
   put skip "|" format "x" "Сумма прописью: " v-sumword format "x(90)" "|" format "x".

   put skip "+" format "x" fill("-",106) format "x(106)" "+" format "x".
   if length(sumword1) > 0 then do:
   put skip "|" format "x" sumword1 format "X(106)" "|" format "x" .
   put skip "+" fill("-",106) format "x(106)" "+" format "x".
   end.

   put skip "|" format "x" "Дата получения товара (оказания услуг): " format "x(71)" "|" format "x" "Код назначения" format "x(18)" "|" format "x" space(6) trim(knp) space(1) "|" format "x".
   put skip "+" format "x" fill("-",71) format "x(71)" "|" format "x" "платежа" format "x(18)" "|" format "x" space(15) "|" format "x".
   put skip "|" format "x" "Назначение платежа (с указанием наименования товара, выполненных работ," format "x(71)" "+" format "x" fill("-",34) format "x(34)" "+" format "x".
   put skip "|" format "x" "оказанных услуг, номеров и даты товарных документов, номера и " format "x(71)" "|" format "X" "Код бюдж." format "x(18)" "|" format "x" space(15) "|" format "X".
   put skip "|" format "x" "даты договора и иных реквизитов)" format "x(71)" "|" format "x" "классификации" format "x(18)" "|" format "x" space(15) "|" format "x".
   put skip "|" format "x" v-nazn format "x(71)" "+" format "x" fill("-",34) format "x(34)" "+" format "x".
   put skip "|" format "x" v-nazn1 format "x(71)" "|" format "x" "Дата" format "x(18)" "|" format "x" space(3) s-date space(2) "|" format "x".
   put skip "|" format "x" v-nazn2 format "x(71)" "|" format "x" "валютирования" format "x(18)" "|" format "x" space(15) "|" format "x".
   put skip "+" format "x" fill("-",106) format "x(106)" "+" format "x".
   put skip space(80) "Проведено банком получателем".
   put skip space(20) "Руководитель: " ruk format "x(35)" space(19) day(s-date) format "99" space(3) " " MyMonths[month(s-date)] format "x(8)" year(s-date) format "9999" "г.".
   put skip space(5) "+" format "x" fill("-",5) format "x(5)" "+" format "x" space(68) ofcname format "x(28)".
   put skip space(5) "|" format "x" "М.П. " format "x(5)" "|" format "x" space(8) "Гл. бухгалтер: " buh format "x(35)" space(11) fill("_",19) format "x(19)" "(подписи)" format "x(9)".
   put skip space(5) "+" format "x" fill("-",5) format "x(5)" "+" format "x".
   output close.
end.
if p-vid ="mem" then do:
      output to value(in_destination) append.
   put skip(1).
   put skip '"' + trim(cmp.name) + '"' format "X(60)"
       "+" format "x" at 59  fill("-",16) format "X(16)"
       "+" format "x"  space (18)
       "+" format "x" fill("-",7) format "X(7)" "+" format "x".
   put skip space(35) "МЕМОРИАЛЬНЫЙ ОРДЕР  N " format "x(23)".
   put "|" format "x" " " string(v-plnr) format "X(15)" "|" format "x"
       space(18) "|" format "x" "0401002" "|" format "x"  /*string(s-jh)*/ .
   put skip space(58) "+" format "x" fill("-",16) format "X(16)"
   "+" format "x"  space (18)
       "+" format "x"  fill("-",7) format "X(7)" "+" format "x".
   put skip  space(39) s-date format "99/99/9999" "г.".
   put skip "Плательщик" space(65) "Дебет" space(15) "Сумма".
   put skip "+" format "x" fill("-",12) format "x(12)"
            "+" format "x"  space(56) "+" format "x"
            fill("-",20) format "X(20)" "+" format "x"
            fill("-",15) format "X(15)" "+" format "x" .
   put skip "|" format "x"  v-platcode format "X(12)"  "|" format "x"
            trim(v-platname) format "x(56)"
             "|" format "x" space(20) "|" format "x"
             space(15) "|" format "x" .

   put skip "+" format "x" fill("-",12) format "X(12)"
            "+" format "x" fill("-",56) format "X(56)"
            "|" format "x" space(20)  "|" format "x" space(15)"|" format "x".
   put skip "Банк плательщика" format "X(70)"  "|" format "x" space(20) "|" format "x" space(15)  "|" format "x".
   put skip space(70)   "|" format "x" space(20)  "|" format "x" space(15)  "|" format "x".
   put skip space(60) "+" format "x" fill("-",9) format "x(9)" "|" format "x" .
   if v-platacc1 ne "" then put v-platacc1 format "x(20)"  "|" format "x"  space(15)  "|" format "x".
                       else put space(20)  "|" format "x" space(15)  "|" format "x".
   put skip v-platbname format "X(60)"  "|" format "x"
            v-bankplat format "X(9)"  "|" format "x"
            v-platacc format "X(20)"  "|" format "x"
            string(v-amt,"-zzz,zzz,zz9.99") format "X(15)" "|" format "x".
   put skip fill("-",60) format "X(60)" "+" format "x"
            fill("-",9) format "x(9)" "+" format "x"
            fill("-",20) format "x(20)" "|" format "x"
            space(15)  "|" format "x".

   put skip "Получатель" format "X(70)" "     Кредит          "
             "|" format "x" space(15) "|" format "x".
   put skip "+"  format "x" fill("-",12) format "x(12)" "+" format "x"
            space(56) "+" format "x"  fill("-",20) format "X(20)"
            "+" format "x" fill("-",15) format "X(15)" "|" format "x".
   put skip "|" format "x" v-polcode format "X(12)" "|" format "x"
            trim(v-polname) format "X(56)" "|" format "x" space(20)
            "|" format "x" space(15) "|" format "x".

   put skip "+" format "x" fill("-",12) format "X(12)"
            "+" format "x" fill("-",56) format "X(56)"
            "|" format "x" .
         if v-polacc1 ne " " then put string(v-polacc1) format "x(20)".
         else put space(20).
   put   "|" format "x" space(15) "|" format "x".

   put skip "Банк получателя" format "X(60)" "+" format "x"
            fill("-",9) format "x(9)" "|" format "x"  space(20)
            "|" format "x"  space(15) "|" format "x".
   put skip v-polbname format "X(60)" "|" format "x"
            v-bankpol format "X(9)" "|" format "x"
            string(v-polacc) format "x(20)" "|" format "x"
            space(15) "|" format "x".


   v-sumword = ''.

 /*  find aaa where aaa.aaa eq in_account no-lock. */

   if s-crc eq 1
   then do:
        vcrc1 = " " + "тенге" + " ".
        vcrc2 = " " + "тиын".
   end.
   else do:
     /*  find crc where crc.crc eq aaa.crc no-lock.*/
        vcrc1 = " " + s-code + " ".
        vcrc2 = "".
   end.

   Run sr-vrd(input v-amt, output sumword1, input no).
   if sumword1 ne "nulle" and sumword1 ne ""
   then v-sumword = trim(sumword1) + vcrc1.
   else v-sumword = "ноль" + vcrc1.
   Run sr-vrd(input (100 * (v-amt - truncate(v-amt,0))),
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
   put skip fill("-",60) format "X(60)" "+" format "x"
            fill("-",9) format "x(9)" "+" format "x"
            fill("-",20) format "x(20)" "+" format "x"
            fill("-",15) format "x(15)" "|" format "x".
   put skip "Сумма прописью: " v-sumword format "X(75)" "|" format "x"  "пеня за    дней" "|" format "x".
   put skip fill("-",88) format "x(88)" "   "           "|" format "x"  "из % P.        " "|" format "x".
   put skip sumword1 format "X(88)" space(3)  chr(147) format "x"
            fill("-",15) format "X(15)" "|" format "x" .
   put skip fill("-",88) format "x(88)" "   " "|" format "x" "               " "|" format "x".
   put skip sumword2 format "X(88)" space(3)  "|" format "x" " cумма с пеней " "|" format "x".

   put skip fill("-",91) format "X(91)" "+" format "x"  fill("-",4) format "x(4)" "+" format "x"  fill("-",10) format "x(10)" "|" format "x".
   put skip "Назначение платежа: наименование товара,выполненных работ,оказанных услуг,"
          space(17)  "|" format "x" "B.o." "|" format "x" space(10)
         "|" format "x".
   put skip " NN и суммы товарных документов" space(60)
    "|" format "x" fill("-",4) format "x(4)" "+" format "x"
    fill("-",10) format "x(10)" "|" format "x".
   put skip space (88) "   " "|" format "x" "H.п."  "|" format "x"
            space(10) "|" format "x".
   put skip space(5) v-nazn format "x(78)" space(8)  "|" format "x"
           fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "|" format "x".
   put skip space(5) v-nazn1 format "x(78)" space(8) "|" format "x" "C.п."
           "|" format "x" space(10)  "|" format "x".
   put skip space(5) v-nazn2 format "x(78)" space (8)  "|" format "x"
            fill("-",4) format "x(4)" "+" format "x"
            fill("-",10) format "x(10)" "|" format "x".
   put skip space(5) v-nazn3 format "x(78)"  space(8)  "|" format "x" "O.п."
             "|" format "x" space(10)  "|" format "x".
   put skip space(91)  "|" format "x" fill("-",4) format "X(4)"
            "+" format "x" fill("-",10) format "x(10)"
            "|" format "x".
     put skip space(91) "|" format "x" "N.б."
           "|" format "x" space(10)  "|" format "x".
     put skip space(91) "+" format "x"
           fill("-",4) format "x(4)" "+" format "x"
           fill("-",10) format "x(10)" "+" format "x".
    put skip "Приложение из 1-го листа                  Подписи" format "X(60)".
    put skip fill("-",93) format "X(93)".
   output close.
end.
End Procedure.
