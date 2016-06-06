/* vcsprcur.p
 * MODULE
        Валютный контроль
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
        31/12/99 tsoy
 * BASES
        BANK COMM
 * CHANGES
        25/02/2004 tsoy доработал интерфейс справки
        25/04/2004 tsoy примечания печатать для всех видов сделок импорт и експорт
        29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        09.10.2013 damir - Внедрено Т.З. № 1670..
*/
{vc.i}
{global.i}
{functions-def.i}
{sum2strd.i}

def shared var s-contract like vccontrs.contract.
def shared var v-cifname  as char.
def shared var s-vcourbank as char.

def var s-vbank as char.
def var decAmount as deci.
def var intot as dec decimals 2.
def var strAmount as char.
def var str1 as char.
def var str2 as char.
def var temp as char.
def var strTemp as char.
def var v-ncrccod like ncrc.code.
def var v-sum as deci.
def var v-psnum as char.
def var v-dep2 as char.
def var v-ans  as logical.
def var v-ans1 as logical.
def var v-contrtype as char.
def var v-partnername as char.
def var v-requestno as char.
def var v-requestdt as date.
def var v-isfinish as char.
def var v-strTotSum as char.

def temp-table t-dntype
  field dntype as char
  field dnvid as char
  field name as char format "x(60)"
  index dntype is primary dntype.

def temp-table t-docs
  field docs like vcdocs.docs
  field dntype like vcdocs.dntype
  field dnvid as char
  field dndate like vcdocs.dndate
  field dnnum like vcdocs.dnnum
  field sum like vcdocs.sum
  field pcrc like vcdocs.pcrc
  field cursdoc-con like vcdocs.cursdoc-con
  field prim like vcdocs.info[1]
  index main is primary dnvid dntype dndate dnnum sum docs.

def stream vcrpt.
output stream vcrpt to vcrptpl.htm.

def var v-select as integer.
v-select = 0.

run sel2 (" Отчеты ", " 1. Ответ на запрос клиента| 2. Ответ на запрос другого банка| 3. ВЫХОД ", output v-select).

case v-select:
   when 1 then run vcrpt_1.
   when 2 then run vcrpt_2.
   when 3 then return.
end.

procedure vcrpt_1:

v-ans1 = true.
form
  v-requestno  format "x(45)" label " Номер запроса "
  help " Введите номер запроса клиента" skip

  v-requestdt  format "99/99/9999" label " Дата запроса "
    help " Введите дату начала периода"
    validate (v-requestdt <= g-today, " Дата не может быть больше сегодняшней!") skip

  v-isfinish  format "x(1)" label " Текущая (Y) Для закрытия (N) "
  help " Введите тип справки" skip
  with overlay width 78 centered row 6 side-label title " СПРАВКА  " frame f-sprav.

v-isfinish  = "Y".
v-requestdt = g-today.
v-requestno = "N ".

  update v-requestno  v-requestdt v-isfinish with frame f-sprav.
  hide frame f-sprav.


find vccontrs where vccontrs.contract = s-contract no-lock no-error.
find cif where cif.cif = vccontrs.cif no-lock no-error.
find vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock no-error.

find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
if avail vccontrs then v-contrtype = vccontrs.expimp.

find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
  if avail vcpartners then
    v-partnername = trim(trim(vcpartners.name) + ' ' + trim(vcpartners.formasob)).
  else  v-partnername = ''.


if avail vcps then v-psnum = vcps.dnnum.
find ofc where ofc.ofc = g-ofc no-lock no-error.
find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
if avail ncrc then v-ncrccod = ncrc.code. else v-ncrccod = "".

{html-title.i
 &stream = " stream vcrpt "
 &title = " Справка"
 &size-add = "xx-"
}
  put stream vcrpt unformatted
     "<BR><BR><BR><BR><BR><BR><BR><BR>" skip
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
     "<TR><TD><BR>" skip
       "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
         "<TR valign=""top"">" skip
           "<TD width=""60%"" align=""left""></TD>" skip
           "<TD width=""40%"" align=""center""><FONT size=""3"">"
            trim(cif.prefix) "&nbsp;"  trim(cif.name)
           "</FONT><BR><BR><BR><BR>"
           "</TD>" skip
         "</TR>"
       "</TABLE></TR>" skip.

s-vbank ="".

find bankl where bankl.bank = s-vcourbank no-lock no-error.
if avail bankl then
    s-vbank =  bankl.name.

for each codfr where codfr.codfr = "vcdoc" and
    ((index("p", codfr.name[5]) > 0)) no-lock:
  create t-dntype.
  assign t-dntype.dntype = codfr.code
         t-dntype.dnvid  = codfr.name[5]
         t-dntype.name   = codfr.name[1].
end.

for each vcdocs where vcdocs.contract = s-contract and
   can-find(t-dntype where t-dntype.dntype = vcdocs.dntype) no-lock :
  create t-docs.
  buffer-copy vcdocs to t-docs.
  if vcdocs.payret then t-docs.sum = - t-docs.sum.
  find t-dntype where t-dntype.dntype = vcdocs.dntype no-lock no-error.
  t-docs.dnvid = t-dntype.dnvid.
  t-docs.prim = vcdocs.info[1].
end.

put stream vcrpt unformatted
  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""3"" align=""center"" >" skip
    "<TR><TD colspan=""6"">" skip
    "<P align =""justify""><FONT size=""3"">" skip
    "Согласно вашему запросу " v-requestno " " skip
    "от " + string (v-requestdt, "99.99.9999") + " " skip
    s-vbank  + " подтверждает, что " + trim(cif.prefix) "&nbsp;"  trim(cif.name)   skip
    "по контракту " + trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99.99.9999") + " " skip
    "c " +  v-partnername + " (паспорт сделки " + trim(v-psnum) + ")" skip.

if CAPS(v-contrtype) = "E" then
   put stream vcrpt unformatted
    "поступила следующая экспортная выручка" skip.
else
put stream vcrpt unformatted
    "произвело следующие платежи" skip.

put stream vcrpt unformatted
    "</FONT></P>" skip
    "</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

for each t-docs break by t-docs.dndate by t-docs.dnnum :

  find ncrc where ncrc.crc = t-docs.pcrc no-lock no-error.

  put stream vcrpt unformatted
    "<TR>" skip
    "<TD align=""left"" colspan=""1"" ></TD>" skip
      "<TD align=""left"" colspan=""5"" ><FONT size=""3"">" + string(t-docs.dndate, "99.99.9999") + " &nbsp&nbsp&nbsp  " + sum2strd(t-docs.sum, 2) + "  " + ncrc.code skip.

  if ncrc.code <> v-ncrccod then do:
       put stream vcrpt unformatted
       "&nbsp(" + sum2strd(t-docs.sum / t-docs.cursdoc-con, 2) + " " + v-ncrccod + ")" skip.
       v-sum = v-sum + (t-docs.sum / t-docs.cursdoc-con).
  end.
  else do:
       v-sum = v-sum + t-docs.sum.
  end.

  if t-docs.sum <0 then
     put stream vcrpt unformatted
        " возврат " skip.

  if t-docs.prim <> "" then
     put stream vcrpt unformatted
        "(" t-docs.prim ")</FONT></TD></TR>" skip.
  else
     put stream vcrpt unformatted
        "</FONT></TD></TR>" skip.

end.

  put stream vcrpt unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

    intot     =  v-sum.
    decAmount =  v-sum.

    temp = sum2strd(v-sum, 2).

    if num-entries(temp,".") = 2 then do:
       temp = substring(temp, length(temp) - 1, 2).
       if num-entries(temp,".") = 2 then
       temp = substring(temp,2,1) + "0".
    end.
    else temp = "00".

    strTemp = string(truncate(intot,0)).

    run Sm-vrd    (
                    input decAmount,
                    output strAmount
                  ).

    run sm-wrdcrc (
                    input strTemp,
                    input temp,
                    input vccontrs.ncrc,
                    output str1,
                    output str2
                  ).

    strAmount = strAmount + " " + str1 + " " + temp + " " + str2.


if v-sum = 0 then
   v-strTotSum = "0".
else
   v-strTotSum = sum2strd(v-sum, 2).


put stream vcrpt unformatted
    "<TR><TD colspan=""6""><P align =""left""><FONT size=""3"">" skip
    "ИТОГО : " + v-strTotSum + " " + v-ncrccod  skip
    " (" +  strAmount + ")" skip
    "</P></FONT></TD></TR>" skip.

if CAPS(v-isfinish) = "Y" then do:
    put stream vcrpt unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.
end.
else do:
    put stream vcrpt unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6""><FONT size=""3""><P align =""left"">" s-vbank " согласен с закрытием паспорта сделки " trim(v-psnum) "</FONT></P></TD></TR>" skip.
end.

put stream vcrpt unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<TR><TD colspan=""2"" align=""left""><FONT size=""3"">" entry(2, sysc.chval)  skip
    "<BR>"  s-vbank  "</FONT>" skip
    "<TD colspan=""2""></TD>" skip
    "<TD colspan=""2"" align=""left""><FONT size=""3"">" entry(1, sysc.chval)  skip
    "</TR>" skip.*/

/*  find cif where cif.cif = t-dolgs.cif no-lock no-error.*/
  v-dep2 = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .

  if avail codfr and codfr.name[1] <> "" then
  put stream vcrpt unformatted
    "<TR><TD colspan=""2"" align=""left""><FONT size=""3"">" entry(1, trim(codfr.name[1]))  skip
    "<BR>"  s-vbank  "</FONT>" skip
    "<TD colspan=""2""></TD>" skip
    "<TD colspan=""2"" align=""left""><FONT size=""3"">" entry(2, trim(codfr.name[1]))  skip
    "</TR>" skip.



put stream vcrpt unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""2"" align=""left""><FONT size=""3""> Исполнитель : " + ofc.name + "<BR>" skip
    "тел : " + ofc.tel[2] + "</FONT></TD></TR>" skip.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcrptpl.htm winword").

message skip " Удержать комиссию за выдачу справки ?" skip(1)
          view-as alert-box buttons yes-no title "" update v-ans.

if v-ans then do:
    if can-find(  first vcctcoms where vcctcoms.contract   = s-contract and
                                       vcctcoms.codcomiss  = "com-spr" and
                                       vcctcoms.datecomiss = g-today no-lock
               ) then
         message skip " Сегодня уже выдавалась справка, снять комиссию повторно ?" skip(1)
              view-as alert-box buttons yes-no title "" update v-ans1.
end.

if v-ans and v-ans1  then run vcctcom ('spr', s-contract, 0).

end procedure.


procedure vcrpt_2:

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
if vccontrs.sts <> "C" then return.

def var s-dnvid1 as char init "p".
def var s-dnvid2 as char init "g,o".
def var s-vcdoctypes1 as char.
def var s-vcdoctypes2 as char.
def var v-sum1 as deci.
def var v-dt as date.

def buffer b-ncrc for ncrc.

v-dt = today.
def frame vcrpt1
    v-num as char   label "                       Номер исход" format "x(70)" skip
    v-dt            label "                        Дата исход" format "99/99/9999" skip
    v-namub as char label "                   Наименование УБ" format "x(70)" skip
    v-who as char   label "              Кому(должность, ФИО)" format "x(70)" skip
    v-from as char  label "Подписано от банка (должность ФИО)" format "x(70)" skip
    v-tel as char   label "               Телефон исполнителя" format "x(70)" skip
with side-labels width 110 row 5 centered title "ВВЕДИТЕ".

displ v-num v-dt v-namub v-who v-from v-tel with frame vcrpt1.
set v-num v-dt v-namub v-who v-from v-tel with frame vcrpt1.

find cmp no-lock no-error.
find cif where cif.cif = vccontrs.cif no-lock no-error.
find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
find b-ncrc where b-ncrc.crc = vccontrs.ncrc no-lock no-error.
find ofc where ofc.ofc = g-ofc no-lock no-error.

s-vcdoctypes1 = "".
for each codfr where codfr.codfr = "vcdoc" and lookup(trim(codfr.name[5]),s-dnvid1) > 0 no-lock:
    s-vcdoctypes1 = s-vcdoctypes1 + codfr.code + ",".
end.
s-vcdoctypes2 = "".
for each codfr where codfr.codfr = "vcdoc" and lookup(trim(codfr.name[5]),s-dnvid2) > 0 no-lock:
    s-vcdoctypes2 = s-vcdoctypes2 + codfr.code + ",".
end.

output to value("vcrpt1.htm").
{html-title.i}

put unformatted
    "<P align=right style='font-size:12pt'>Директору<br>" string(v-namub) "<br>" string(v-who) "</P>" skip
    "<P style='font-size:12pt'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" if avail cmp then trim(cmp.name) else '' " в ответ на Ваш запрос № " trim(v-num) " от " string(v-dt,"99/99/9999")
    " в соответствии с пунктом 32 Правил осуществления экспортно-импортного валютного контроля и получения резидентами учетных номеров контрактов по экспорту и импорту № 42 от 24.02.2012
    подтверждает снятие " string(vccontrs.stsdt,"99/99/9999") " с учетной регистрации контракта № " vccontrs.ctnum " от " string(vccontrs.ctdate,"99/99/9999") " заключенного между "
    if avail cif then (trim(cif.prefix) + ' ' + trim(cif.name)) else '' " и " if avail vcpartners then (trim(vcpartners.formasob) + ' ' + trim(vcpartners.name)) else '' " и направляет сведения "
    "о движении денег и товаров по контракту:</P>" skip.


put unformatted
    "<P align=center style='font-size:12pt;font:bold'>Информация по контракту</P>" skip.
put unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
    "<TD colspan=4>Движение денежных средств</TD>" skip
    "</TR>" skip
    "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
    "<TD>Дата</TD>" skip
    "<TD>Номер документа</TD>" skip
    "<TD>Признак</TD>" skip
    "<TD>Сумма</TD>" skip
    "</TR>" skip.
v-sum1 = 0.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype,s-vcdoctypes1) > 0 no-lock break by vcdocs.dntype:
    if vcdocs.payret then v-sum1 = v-sum1 - vcdocs.sum / vcdocs.cursdoc-con.
    else v-sum1 = v-sum1 + vcdocs.sum / vcdocs.cursdoc-con.

    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error.

    put unformatted
        "<TR align=""center"" style='font-size:10pt'>" skip
        "<TD>" + string(vcdocs.dndate, "99/99/9999") + "</TD>" skip
        "<TD>" + trim(vcdocs.dnnum) + "</TD>" skip
        "<TD>" + if avail codfr then codfr.name[1] else "в справочнике не найден" + "</TD>" skip
        "<TD>" + sum2strd(vcdocs.sum, 2) + "</TD>" skip
        "</TR>" skip.
end.
put unformatted
    "<TR style='font-size:10pt'>" skip
    "<TD colspan=""3"" align=""right""><B>ИТОГО : </B></TD>" skip
    "<TD align=""center""><B>" + sum2strd(v-sum1, 2) + "</B></TD>" skip
    "</TR>" skip.
put unformatted
    "</TABLE>" skip.

put unformatted
    "<P>&nbsp;</P>" skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
    "<TD colspan=4>Исполнение обязательств по поставке товара (оказанию услуг)</TD>" skip
    "</TR>" skip
    "<TR align=""center"" style='font-size:10pt;font:bold'>" skip
    "<TD>Дата</TD>" skip
    "<TD>Номер документа</TD>" skip
    "<TD>Тип</TD>" skip
    "<TD>Сумма</TD>" skip
    "</TR>" skip.
v-sum1 = 0.
for each vcdocs where vcdocs.contract = vccontrs.contract and lookup(vcdocs.dntype,s-vcdoctypes2) > 0 no-lock break by vcdocs.dntype:
    if vcdocs.payret then v-sum1 = v-sum1 - vcdocs.sum / vcdocs.cursdoc-con.
    else v-sum1 = v-sum1 + vcdocs.sum / vcdocs.cursdoc-con.

    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error.

    put unformatted
        "<TR align=""center"" style='font-size:10pt'>" skip
        "<TD>" + string(vcdocs.dndate, "99/99/9999") + "</TD>" skip
        "<TD>" + trim(vcdocs.dnnum) + "</TD>" skip
        "<TD>" + if avail codfr then codfr.name[1] else "в справочнике не найден" + "</TD>" skip
        "<TD>" + sum2strd(vcdocs.sum, 2) + "</TD>" skip
        "</TR>" skip.
end.
put unformatted
    "<TR style='font-size:10pt'>" skip
    "<TD colspan=""3"" align=""right""><B>ИТОГО : </B></TD>" skip
    "<TD align=""center""><B>" + sum2strd(v-sum1, 2) + "</B></TD>" skip
    "</TR>" skip.
put unformatted
    "</TABLE>" skip.
put unformatted
    "<P align=left style='font-size:12pt'>С уважением,<br>" trim(v-from) "</P>" skip
    "<P align=left style='font-size:12pt'>Исп.: " trim(ofc.name) "</P>" skip
    "<P align=left style='font-size:12pt'>Телефон: " trim(v-tel) "</P>" skip.

{html-end.i}
output close.

unix silent value("cptwin vcrpt1.htm winword").

end procedure.