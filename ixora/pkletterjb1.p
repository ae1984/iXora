/* pkletterjb1.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Формирование письма для рассылки работодателям клиентов-должников ЖЕСТКОЕ
 * RUN

 * CALLER
        pkletter.p
        pkdebt1.p
 * SCRIPT

 * INHERIT
        pknewletter.p
 * MENU
        4-14-6
 * AUTHOR
        11.12.2003 nadejda
 * CHANGES
        06.01.2003 nadejda - слегка изменен текст письма - падежи
        01.02.2004 nadejda - адреса брать из cif.dnb (pkdefadrcif.p), место работы - cif.ref[8], cif.item
        05.04.2004 tsoy    - немного изменен текст письма
        25/06/2004 madiyar - принимается еще один параметр (p_newved) - создавать новую ведомость или нет
                             в pknewletter третьим параметром передавался всегда (во всех типах писем) replace(s-codemask, "*", "cl"), исправил
        10/10/2005 madiyar - добавил внизу ФИО исполнителя и телефон
        03/10/2006 madiyar - в вызов добавил параметр с суммой долга по комиссии; no-undo
        07.11.07 marinav - поменялись реквизиты для оплаты
        10/01/2008 madiyar - исправил в письме "Реквизиты МКО" на "Реквизиты"
        13/11/2008 madiyar - картинка с печатью, номер телефона из шаренной переменной
        19/02/2009 madiyar - изменил поиск анкеты (чтобы работало и в МКО)
        24/01/2011 evseev -  исправил "Не верно считается сумма задолженности. Суммируются цифры вне зависимости от валюты"
*/

{global.i}
{pk.i}
{sysc.i}

def input parameter p-newfile as logical no-undo.
def input parameter p-lastletter as logical no-undo.
def input parameter p-letternom as char no-undo.
def input parameter p-nom as integer no-undo.
def input parameter p-dolgday as integer no-undo.
def input parameter p-dolgbase as decimal no-undo.
def input parameter p-dolgproc as decimal no-undo.
def input parameter p-dolgpena as decimal no-undo.
def input parameter p-dolgkom as decimal no-undo.
def input parameter p_newved as logical no-undo.
def output parameter p-roll as integer no-undo.

def shared var s-lettersign as char.
def shared var s-letterphone as char.
def shared var s-filename as char.
def shared var s-filelabel as char.
def shared var s-codemask as char.
def shared var s-paramnom as char.

def var v-datastrkz as char no-undo.
def var v-letternom as char no-undo.
def var v-letterdat as char no-undo.
def var v-sname as char no-undo.
def var v-name as char no-undo.
def var v-chiefpos as char no-undo.
def var v-chief as char no-undo.
def var v-adres as char no-undo extent 2.
def var v-dognom as char no-undo.
def var v-dogdtstr as char no-undo.
def var v-srok as char no-undo.
def var v-month as decimal no-undo.
def var v-summa as char no-undo.
def var v-summawrd as char no-undo.
def var v-crccode as char no-undo.
def var v-dolgsum as char no-undo.
def var v-dolgbase as char no-undo.
def var v-dolgproc as char no-undo.
def var v-dolgpena as char no-undo.
def var v-dolgkom as char no-undo.
def var v-monthsum as char no-undo.
def var v-dolgsumwrd as char no-undo.
def var v-dolgbasewrd as char no-undo.
def var v-dolgprocwrd as char no-undo.
def var v-dolgpenawrd as char no-undo.
def var v-dolgkomwrd as char no-undo.
def var v-monthsumwrd as char no-undo.
def var v-letterdtstr as char no-undo.
def var v-aaa as char no-undo.
def var v-rnn as char no-undo.
def var v-acctxb as char no-undo.
def var v-ankln as integer no-undo.
def var v-jobname as char no-undo.
def var v-jobadres as char no-undo.
def var v-comved as deci no-undo.

find lon where lon.lon = s-lon no-lock no-error.
if not avail lon then return.

v-ankln = 0.
find first loncon where loncon.lon = s-lon no-lock no-error.
if avail loncon then do:
    for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = lon.cif no-lock:
        if entry(1,pkanketa.rescha[1]) = loncon.lcnt then do:
            assign v-ankln = pkanketa.ln s-credtype = pkanketa.credtype.
            leave.
        end.
    end.
end.

if v-ankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = v-ankln no-lock no-error.

find first sysc where sysc.sysc = "pkletn" no-lock no-error.
if not avail sysc then do:
  message " Нет настроек номера письма!". pause 20.
  return.
end.

find first cmp no-lock no-error.
find sysc where sysc.sysc = "CHIEF" no-lock no-error.
if avail sysc then do:
  v-chiefpos = sysc.des.
  v-chief = sysc.chval.
  v-acctxb = cmp.name + "<BR>".
end.

find first point where point.point = 1 no-lock no-error.
v-acctxb =  v-acctxb + "РНН " + cmp.addr[2] + "<BR>ИИК " + get-sysc-cha ("bnkiik") + " " + trim(point.Termlist) +
                                              "<BR>БИК " + get-sysc-cha ("clecod") + "<BR>".
v-acctxb =  v-acctxb +  "Республика Казахстан<BR>" + cmp.addr[1]  .

v-sname = pkanketa.name.
run pkdefadrcif (pkanketa.ln, no, output v-adres[1], output v-adres[2]).
v-dognom = entry(1, pkanketa.rescha[1]).
run pkdefdtstr(pkanketa.docdt, output v-dogdtstr, output v-datastrkz).
v-srok = string(pkanketa.srok, ">>9").
v-summa = replace(string(pkanketa.summa, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(pkanketa.summa, output v-summawrd).
find crc where crc.crc = pkanketa.crc no-lock no-error.
if crc.crc = 1 then v-crccode = lc(crc.des).
               else v-crccode = crc.code.

v-dolgsum  = replace(string(p-dolgbase + p-dolgproc + p-dolgkom, ">>>,>>>,>>9.99"), ",", " ").
v-dolgbase = replace(string(p-dolgbase, ">>>,>>>,>>9.99"), ",", " ").
v-dolgproc = replace(string(p-dolgproc, ">>>,>>>,>>9.99"), ",", " ").
v-dolgpena = replace(string(p-dolgpena, ">>>,>>>,>>9.99"), ",", " ").
v-dolgkom = replace(string(p-dolgkom, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(p-dolgbase + p-dolgproc + p-dolgkom, output v-dolgsumwrd).
run Sm-vrd(p-dolgbase, output v-dolgbasewrd).
run Sm-vrd(p-dolgproc, output v-dolgprocwrd).
run Sm-vrd(p-dolgpena, output v-dolgpenawrd).
run Sm-vrd(p-dolgkom, output v-dolgkomwrd).

/* найти ежемесячный платеж */
v-comved = 0.
if (pkanketa.bank = "txb00" and pkanketa.docdt >= 05/16/2005) or (pkanketa.bank <> "txb00" and pkanketa.docdt >= 10/03/2005) then do:
  find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
  if avail pksysc then v-comved = pksysc.deval. else v-comved = 400.
end.

find first lnsch where lnsch.lnn = pkanketa.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error.
find next lnsch where lnsch.lnn = pkanketa.lon and lnsch.flp = 0 and lnsch.f0 > 0 no-lock no-error. /* т.к. в первый месяц проценты могут быть не за 30 дней */
find first lnsci where lnsci.lni = pkanketa.lon and lnsci.flp = 0 and lnsci.f0 > 0 and lnsci.idat = lnsch.stdat no-lock no-error.

v-month = lnsch.stval + lnsci.iv-sc + v-comved.
v-monthsum = replace(string(v-month, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(v-month, output v-monthsumwrd).

v-aaa = pkanketa.aaa.
v-rnn = pkanketa.rnn.

find cif where cif.cif = pkanketa.cif no-lock no-error.
v-jobname = cif.ref[8].
if cif.item <> "" and num-entries(cif.item, "|") > 1 then v-jobadres = entry(2, cif.item, "|").
else do:
  find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-ankln
       and pkanketh.kritcod = "jobadd" no-lock no-error.
  if avail pkanketh then v-jobadres = pkanketh.value1.
end.


/* если новое письмо - создать запись в истории писем */
if p-letternom = "" then do:
  run pknewletter (s-ourbank, s-paramnom, replace(s-codemask, "*", "jb1"), p_newved, s-lon, lon.rdt, output p-letternom).
  find letters where letters.bank = s-ourbank and letters.docnum = p-letternom exclusive-lock no-error.
  if avail letters then do transaction:
    letters.name = v-sname.
    letters.addr[10] = caps(entry(1, cmp.addr[1])) + ", " + v-jobadres.
    letters.info[1] = pkanketa.credtype + "," + string(pkanketa.ln).
    letters.info[2] = v-jobname.
  end.
  else do:
    message " Произошла ошибка при формировании номера письма!".
    pause 10.
    return.
  end.
end.


find letters where letters.docnum = p-letternom no-lock no-error.
p-roll = letters.roll.

run pkdefdtstr(letters.rdt, output v-letterdtstr, output v-datastrkz).

def stream rep.
if p-newfile then do:
  output stream rep to value(s-filename + "jb1.html").
  output stream rep close.
end.

output stream rep to value(s-filename + "jb1.html") append.

if p-newfile then do:
  {html-title.i &stream = "stream rep" &title = " " &size-add = "x-"}
end.
else
  put stream rep unformatted
    "<P><BR clear=all style=""page-break-before:always""></P>" skip.


put stream rep unformatted
"<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR><TD><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR valign=""top""><TD width=""30%""><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font:bold"">" skip
      "<TR><TD align=""center"">" cmp.name "</TD></TR>" skip
      "<TR><TD align=""center"">" cmp.addr[1] "</TD></TR>" skip
      "<TR><TD>&nbsp;</TD></TR>" skip
      "<TR><TD>Исх. N <U>" letters.docnum "</U></TD></TR>" skip
      "<TR><TD><U>" v-letterdtstr "&nbsp;г.</U></TD></TR></TABLE>" skip
    "</TD>"
    "<TD width=""25%"">&nbsp;</TD>"
    "<TD>" skip
      "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font:bold"" align=""right"">" skip
      "<TR align=""center""><TD>" v-jobname "</TD></TR>" skip
      "<TR align=""center""><TD>Адрес: " entry(1, cmp.addr[1]) "<BR>" skip
          v-jobadres "</U></TD></TR></TABLE>" skip
    "</TD>" skip
    "</TR></TABLE></TD></TR>" skip
  "<TR><TD>" skip
    "<P>&nbsp;</P>" skip
    "<P>Уважаемый (-ая) господин (-жа),</P>" skip.

put stream rep unformatted
    "<P align=""justify"">"
      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Сотрудник Вашей организации " v-sname " получил(-а) банковский займ в " cmp.name " в соответствии с Договором " skip
      "N&nbsp;" v-dognom " о предоставлении потребительского кредита от " v-dogdtstr "&nbsp;года.<BR>" skip
      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Согласно условиям данного договора, Ваш сотрудник взял на себя обязательство ежемесячно погашать " skip
      "полученный заем равными долями по " v-monthsum " (" v-monthsumwrd ")&nbsp;" v-crccode ". " skip
      "На текущий момент не уплаченная в срок сумма  задолженности перед Банком составляет " skip
      v-dolgsum " (" v-dolgsumwrd ")&nbsp;" v-crccode ",сумма неустойки (штрафных санкций, пени) составляет в размере " v-dolgpena " (" v-dolgpenawrd ")&nbsp;тенге" skip
      ", а задержка своевременной выплаты данной задолженности составляет " skip
      p-dolgday "&nbsp;дней. В случае непогашения Вашим сотрудником в течение следующих 10 (Десяти) дней данной просроченной задолженности, Банк намерен начать процедуру судебного исполнения обязательств " skip
      "заемщика.<BR>" skip
      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Во избежание вовлечения сотрудника Вашей организации в судебное разбирательство, просим Вас оказать содействие во взыскании " skip
      "вышеуказанных сумм путем ежемесячного перечисления бухгалтерией Вашей организации части заработной платы Вашего сотрудника на погашение его(-ее) задолженности перед Банком по нижеуказанным реквизитам:<BR><BR>" skip
      "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
        "<TR valign=""top""><TD>Реквизиты: </TD><TD>" v-acctxb "</TD></TR>" skip
      "</TABLE>"
      "</P></TD></TR>" skip.

put stream rep unformatted
    "<TR><TD><P>&nbsp;</P>" skip
    "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
      "<TR><TD colspan=""3"">С уважением,</TD></TR>" skip
      "<TR><TD>" v-chiefpos "</TD>" skip
      "<TD align=""center"">" s-lettersign "</TD>" skip
      "<TD>" v-chief "</TD></TR>" skip
      "<tr><td></td><TD align=""center""><IMG border=0 src=pkstamp.jpg width=160 height=160></TD><td></td></tr>" skip
    "</TABLE></TD></TR>" skip.

def var usrnm as char.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then usrnm = ofc.name. else usrnm = g-ofc.

put stream rep unformatted
    "<TR><TD>" skip
    "Исполнитель: " usrnm "<br>Тел. " + s-letterphone skip
    "</TD></TR></TABLE>" skip.

if p-lastletter then do:
  {html-end.i "stream rep"}
end.

output stream rep close.


