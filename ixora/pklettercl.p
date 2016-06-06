/* pklettercl.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Формирование письма для рассылки клиентам-должникам
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
 * BASE
        BANK COMM
 * CHANGES
        01.02.2004 nadejda - адреса брать из cif.dnb (pkdefadrcif.p)
        05.04.2004 tsoy    - немного изменен текст письма
        25/06/2004 madiyar - принимается еще один параметр (p_newved) - создавать новую ведомость или нет
        10/10/2005 madiyar - добавил внизу ФИО исполнителя и телефон
        03/10/2006 madiyar - в вызов добавил параметр с суммой долга по комиссии; no-undo
        13/11/2008 madiyar - картинка с печатью, номер телефона из шаренной переменной
        19/02/2009 madiyar - изменил поиск анкеты (чтобы работало и в МКО)
        24/01/2011 evseev -  исправил "Не верно считается сумма задолженности. Суммируются цифры вне зависимости от валюты"
        27.08.2013 damir - Внедрено Т.З. № 1985.
*/

{global.i}
{pk.i}


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
def var v-summa as char no-undo.
def var v-summawrd as char no-undo.
def var v-crccode as char no-undo.
def var v-dolgsum as char no-undo.
def var v-dolgbase as char no-undo.
def var v-dolgproc as char no-undo.
def var v-dolgpena as char no-undo.
def var v-dolgkom as char no-undo.
def var v-dolgsumwrd as char no-undo.
def var v-dolgbasewrd as char no-undo.
def var v-dolgprocwrd as char no-undo.
def var v-dolgpenawrd as char no-undo.
def var v-dolgkomwrd as char no-undo.
def var v-letterdtstr as char no-undo.
def var v-ankln as integer no-undo.

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

find sysc where sysc.sysc = s-paramnom no-lock no-error.
if not avail sysc then do:
  message " Нет настроек номера письма!". pause 20.
  return.
end.

find first cmp no-lock no-error.
find first sysc where sysc.sysc = "CHIEF" no-lock no-error.
if avail sysc then do:
  v-chiefpos = sysc.des.
  v-chief = sysc.chval.
end.

/*run pkdefsfio (pkanketa.ln, output v-sname).*/
v-sname = pkanketa.name.
run pkdefadrcif (pkanketa.ln, no, output v-adres[1], output v-adres[2]).
v-dognom = entry(1, pkanketa.rescha[1]).
run pkdefdtstr(pkanketa.docdt, output v-dogdtstr, output v-datastrkz).
v-srok = string(pkanketa.srok, ">>9").
v-summa = replace(string(pkanketa.summa, ">>>,>>>,>>9.99"), ",", " ").
run Sm-vrd(pkanketa.summa, output v-summawrd).
find first crc where crc.crc = pkanketa.crc no-lock no-error.
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

/* если новое письмо - создать запись в истории писем */
if p-letternom = "" then do:
  run pknewletter (s-ourbank, s-paramnom, replace(s-codemask, "*", "cl"), p_newved, s-lon, lon.rdt, output p-letternom).

  find letters where letters.bank = s-ourbank and letters.docnum = p-letternom exclusive-lock no-error.
  if avail letters then do transaction:
    letters.name = v-sname.
    letters.addr[10] = v-adres[2].
    letters.info[1] = pkanketa.credtype + "," + string(pkanketa.ln).

    v-name = "".
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-ankln
         and pkanketh.kritcod = "lname" no-lock no-error.
    if avail pkanketh then v-name = pkanketh.value1.
    run pkdeffio (input-output v-name).
    letters.info[2] = v-name.

    v-name = "".
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-ankln
         and pkanketh.kritcod = "fname" no-lock no-error.
    if avail pkanketh then v-name = pkanketh.value1.
    run pkdeffio (input-output v-name).
    letters.info[2] = letters.info[2] + "," + v-name.

    v-name = "".
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = v-ankln
         and pkanketh.kritcod = "mname" no-lock no-error.
    if avail pkanketh then v-name = pkanketh.value1.
    run pkdeffio (input-output v-name).
    letters.info[2] = letters.info[2] + "," + v-name.
  end.
  else do:
    message " Произошла ошибка при формировании номера письма!".
    pause 10.
    return.
  end.
end.

find first letters where letters.docnum = p-letternom no-lock no-error.
p-roll = letters.roll.

run pkdefdtstr(letters.rdt, output v-letterdtstr, output v-datastrkz).

def stream rep.

if p-newfile then do:
  output stream rep to value(s-filename + "cl.html").
  output stream rep close.
end.

output stream rep to value(s-filename + "cl.html") append.


if p-newfile then do:
  {html-title.i &stream = "stream rep" &title = " " &size-add = "x-"}
end.
else
  put stream rep unformatted
    "<P><BR clear=all style=""page-break-before:always""></P>" skip.


put stream rep unformatted
"<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR valign=""top""><TD><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR><TD width=""30%""><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font:bold"">" skip
      "<TR><TD align=""center"">" cmp.name "</TD></TR>" skip
      "<TR><TD align=""center"">" cmp.addr[1] "</TD></TR>" skip
      "<TR><TD>&nbsp;</TD></TR>" skip
      "<TR><TD>Исх. N <U>" letters.docnum "</U></TD></TR>" skip
      "<TR><TD><U>" v-letterdtstr "&nbsp;г.</U></TD></TR></TABLE>" skip
    "</TD>"
    "<TD width=""20%"">&nbsp;</TD>"
    "<TD><TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font:bold"">" skip
      "<TR><TD>г-ну (г-же) <U>" v-sname "</U></TD></TR>" skip
      "<TR><TD>адрес прописки: <U>" v-adres[1] "</U></TD></TR>" skip
      "<TR><TD>адрес фактического проживания: <U>" v-adres[2] "</U></TD></TR></TABLE>" skip
    "</TD>" skip
    "</TR></TABLE></TD></TR>" skip
  "<TR><TD>" skip
    "<P>&nbsp;</P>" skip
    "<P align=""center"">Уважаемый (-ая) " v-sname "!</P>" skip.
put stream rep unformatted
  "<P align=""justify"">"
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Между Вами и "  cmp.name " " v-dogdtstr " года был заключен договор банковского займа   " skip
       "N&nbsp;" v-dognom " о предоставлении потребительского кредита (далее - Договор), в соответствии с которым                   " skip
       "Вам был предоставлен банковский заем сроком на " v-srok " месяцев в сумме " v-summa "(" v-summawrd ")&nbsp;" v-crccode " на  " skip
       "&nbsp;потребительские цели.      Согласно статьи 4 вышеуказанного Договора, Вы приняли на себя обязательство погашать сумму       " skip
       "кредита и вознаграждение по нему ежемесячно, равными долями в соответствии с графиком платежей, указанным в                 " skip
       "Приложении N 1 к Договору.      Однако по состоянию на " v-letterdtstr "&nbsp;  года на протяжении " p-dolgday " дней     " skip
       "Вы не выполняете своих обязательств по погашению кредита и вознаграждения, в связи с чем Ваша задолженность по            " skip
       "Договору составляет " v-dolgsum " (" v-dolgsumwrd ")&nbsp;" v-crccode ", из них:<BR>                                                         " skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма задолженности по основному долгу составляет " v-dolgbase " (" v-dolgbasewrd ")&nbsp;" v-crccode ".<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма задолженности по вознаграждению  " v-dolgproc " (" v-dolgprocwrd ")&nbsp;" v-crccode ".<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма комиссии " v-dolgkom " (" v-dolgkomwrd ")&nbsp;" v-crccode ".<BR>" skip
       "а также сумма неустойки (штрафных санкций, пени) составляет в размере " v-dolgpena " (" v-dolgpenawrd ")&nbsp;тенге.<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Несмотря на принятые                          " skip
       "нами меры, Вами не были предприняты какие-либо действия по погашению задолженности перед Банком.                          " skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Напоминаем Вам, что согласно Договору о предоставлении потребительского кредита       " skip
       "N&nbsp;" v-dognom ", заключенному " v-dogdtstr skip
       "года между Банком и Вами, Банк имеет право предпринять следующие действия:         <BR>   " skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. уведомить Вашего работодателя о нарушении Вами принятых на себя обязательств;  <BR>    " skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. обратить взыскание на любое иное принадлежащее Вам имущество;                  <BR>    " skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. обратиться в суд о принудительном взыскании просроченной задолженности,          " skip
       "с отнесением государственной пошлины, судебных и иных расходов на Ваш счет.           <BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;На основании вышеизложенного, Вам необходимо в течение 5 (Пяти) рабочих  дней         " skip
       "погасить просроченную задолженность. В случае не исполнения данной просьбы, к Вам могут быть применены меры, " skip
       "предусмотренные действующим законодательством и вышеуказанным Договором.                                     " skip
       "<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" cmp.name " информирует Вас и настоятельно просит: «Очередные платежи или любые иные платежи по кредиту (в том числе и <B><U>погашение
       задолженности</B></U>) оплачивать путем внесения наличных денег на счет Заемщика <B><U>только через кассу Банка</B></U>».".

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


