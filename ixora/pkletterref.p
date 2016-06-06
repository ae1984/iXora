/* pkletterref.p
 * MODULE
        Потреб. кредитование, модуль задолжников
 * DESCRIPTION
        Формирование письма клиенту с предложением рефинансирования
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
        08/08/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/

{global.i}
{pk.i}
{nbankBik.i}

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
def var v-dolgsumkzt as char no-undo.
def var v-dolgbase as char no-undo.
def var v-dolgproc as char no-undo.
def var v-dolgpena as char no-undo.
def var v-dolgkom as char no-undo.
def var v-dolgsumwrd as char no-undo.
def var v-dolgsumkztwrd as char no-undo.
def var v-dolgbasewrd as char no-undo.
def var v-dolgprocwrd as char no-undo.
def var v-dolgpenawrd as char no-undo.
def var v-dolgkomwrd as char no-undo.
def var v-letterdtstr as char no-undo.
def var v-ankln as integer no-undo.

def var i as integer no-undo.

find first lon where lon.lon = s-lon no-lock no-error.
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
v-summa = replace(trim(string(pkanketa.summa, ">>>,>>>,>>9.99")), ",", "&nbsp;").
run Sm-vrd(pkanketa.summa, output v-summawrd).
find first crc where crc.crc = pkanketa.crc no-lock no-error.
if crc.crc = 1 then v-crccode = lc(crc.des).
               else v-crccode = crc.code.

v-dolgbase = replace(trim(string(p-dolgbase, ">>>,>>>,>>9.99")), ",", "&nbsp;").
v-dolgproc = replace(trim(string(p-dolgproc, ">>>,>>>,>>9.99")), ",", "&nbsp;").
v-dolgpena = replace(trim(string(p-dolgpena, ">>>,>>>,>>9.99")), ",", "&nbsp;").
v-dolgkom = replace(trim(string(p-dolgkom, ">>>,>>>,>>9.99")), ",", "&nbsp;").
run Sm-vrd(p-dolgbase, output v-dolgbasewrd).
run Sm-vrd(p-dolgproc, output v-dolgprocwrd).
run Sm-vrd(p-dolgpena, output v-dolgpenawrd).
run Sm-vrd(p-dolgkom, output v-dolgkomwrd).

if pkanketa.crc = 1 then do:
    v-dolgsum  = replace(string(p-dolgbase + p-dolgproc + p-dolgpena + p-dolgkom, ">>>,>>>,>>9.99"), ",", " ").
    run Sm-vrd(p-dolgbase + p-dolgproc + p-dolgpena + p-dolgkom, output v-dolgsumwrd).
    v-dolgsumkzt = ''.
    v-dolgsumkztwrd = ''.
end.
else do:
    v-dolgsum  = replace(trim(string(p-dolgbase + p-dolgproc + p-dolgkom, ">>>,>>>,>>9.99")), ",", "&nbsp;").
    v-dolgsumwrd = ''.
    if p-dolgbase + p-dolgproc + p-dolgkom > 0 then run Sm-vrd(p-dolgbase + p-dolgproc + p-dolgkom, output v-dolgsumwrd).
    v-dolgsumkzt = replace(trim(string(p-dolgpena, ">>>,>>>,>>9.99")), ",", "&nbsp;").
    v-dolgsumkztwrd = ''.
    if p-dolgpena > 0 then run Sm-vrd(p-dolgpena, output v-dolgsumkztwrd).
end.

/* если новое письмо - создать запись в истории писем */
if p-letternom = "" then do:
  run pknewletter (s-ourbank, s-paramnom, replace(s-codemask, "*", "cl"), p_newved, s-lon, lon.rdt, output p-letternom).

  do transaction:
      find letters where letters.bank = s-ourbank and letters.docnum = p-letternom exclusive-lock no-error.
      if avail letters then do:
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
  end. /* transaction */
end.

find first letters where letters.docnum = p-letternom no-lock no-error.
p-roll = letters.roll.

run pkdefdtstr(letters.rdt, output v-letterdtstr, output v-datastrkz).

/* расчет сумм для приложения */
def var v-od as deci no-undo extent 2.
def var v-psrok as integer no-undo extent 2.
def var v-prem as deci no-undo extent 2.
def var v-comprem as deci no-undo extent 2.
def var v-mpay as deci no-undo extent 2.
def var v-mpayod as deci no-undo extent 2.
def var v-mpayprc as deci no-undo extent 2.
def var v-mpaycom as deci no-undo extent 2.
def var v-sum as deci no-undo.

v-od[1] = lon.opnamt.
run lonbalcrc('lon',lon.lon,g-today,"1,7,2,9",yes,lon.crc,output v-od[2]).
v-sum = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.crc = lon.crc no-lock:
    v-sum = v-sum + bxcif.amount.
end.
v-od[2] = v-od[2] + v-sum.
if lon.crc = 1 then v-od[2] = v-od[2] + p-dolgpena.
else do:
    find first crc where crc.crc = lon.crc no-lock no-error.
    v-sum = p-dolgpena / crc.rate[1].
    if v-sum - truncate(v-sum,0) > 0 then v-sum = truncate(v-sum,0) + 1.
    v-od[2] = v-od[2] + v-sum.
end.

v-psrok[1] = pkanketa.srok.
v-psrok[2] = 36.

v-prem[1] = lon.prem.
if v-prem[1] = 0 then v-prem[1] = lon.prem1.
if v-prem[1] = 0 then v-prem[1] = pkanketa.rateq.
v-prem[2] = 19.

find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then do:
    v-mpaycom[1] = tarifex2.ost.
    v-comprem[1] = round(tarifex2.ost / lon.opnamt * 100,2).
end.
v-comprem[2] = 0.5.

v-mpayod[1] = truncate(v-od[1] / v-psrok[1],0).
v-mpayprc[1] = round(v-od[1] * v-prem[1] / 1200,2).
v-mpay[1] = v-mpayod[1] + v-mpayprc[1] + v-mpaycom[1].

form "Заемщик:" lon.cif no-label v-sname no-label format "x(40)" skip(1)
     v-psrok[2] label "Срок нового кредита" format ">9" validate(v-psrok[2] > 0,"Некорректный срок!") skip
     v-comprem[2] label "Ставка по комиссии нового кредита" format "9.9" validate(v-comprem[2] > 0,"Некорректная ставка!") skip
     with centered side-labels row 13 overlay title "Письмо - рефинансирование" frame fr.

displ lon.cif v-sname with frame fr.
update v-psrok[2] v-comprem[2] with frame fr.
v-mpaycom[2] = round(v-od[2] / 100 * v-comprem[2],2).

v-mpayod[2] = truncate(v-od[2] / v-psrok[2],0).
v-mpayprc[2] = round(v-od[2] * v-prem[2] / 1200,2).
v-mpay[2] = v-mpayod[2] + v-mpayprc[2] + v-mpaycom[2].
/* расчет сумм для приложения - end */



def stream rep.

if p-newfile then do:
  output stream rep to value(s-filename + "ref.html").
  output stream rep close.
end.

output stream rep to value(s-filename + "ref.html") append.


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
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Сообщаем Вам, что в виду образования просроченной задолженности у Вас складывается отрицательная кредитная история, что может в дальнейшем стать причиной отказа в предоставлении Вам кредитов во всех банках в Республике Казахстан.<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;По состоянию на " skip
       v-letterdtstr skip
       " Вы несвоевременно выполняете свои обязательства по погашению кредита и вознаграждению, в связи с чем Ваша задолженность по Договору составляет " skip.

if v-dolgsumwrd <> '' then put stream rep unformatted v-dolgsum " (" v-dolgsumwrd ")&nbsp;" v-crccode skip.

if (v-dolgsumwrd <> '') and (v-dolgsumkztwrd <> '') then put stream rep unformatted " и " skip.

if v-dolgsumkztwrd <> '' then put stream rep unformatted v-dolgsumkzt " (" v-dolgsumkztwrd ")&nbsp;тенге".

put stream rep unformatted
       ", из них:<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма задолженности по основному долгу составляет " v-dolgbase " (" v-dolgbasewrd ")&nbsp;" v-crccode ".<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма задолженности по вознаграждению " v-dolgproc " (" v-dolgprocwrd ")&nbsp;" v-crccode ".<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма неустойки (штрафных санкций, пени) " v-dolgpena " (" v-dolgpenawrd ")&nbsp;тенге.<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- сумма комиссии " v-dolgkom " (" v-dolgkomwrd ")&nbsp;" v-crccode ".<BR>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;По требованиям законодательства " + v-nbankru + " может инициировать взыскание с Вас задолженности в судебном порядке.<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Однако, " + v-nbankru + " понимает, что в условиях негативного влияния мирового кризиса на экономику страны, необходимо учитывать объективные причины невозможности вовремя погашать кредит.<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Тем не менее, в " + v-nbankru + " уверены, что любой кризис – это всего лишь временное явление, а то каким будет завтрашний день, во многом зависит от наших совместных действий и решений. Поэтому мы, со своей стороны, приняли решение пойти навстречу своим Клиентам.<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Обратившись в Банк до 15 сентября 2009 года с заявлением, Вы можете:<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1) Полностью досрочно погасить весь кредит без штрафных санкций. В этом случае Банк готов произвести списание всей начисленной неустойки (пени).<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2) Получить льготный период, в течение которого кредит будет погашаться минимальными взносами (гибкий график с учетом Ваших фактических доходов).<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3) Рефинансировать ссудную задолженность со следующими преимуществами:<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- снижение ставки вознаграждения;<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- уменьшение размера ежемесячного платежа;<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- возможность предоставления льготного периода, в течение которого кредит погашается минимальными взносами;<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- списание большей части всей неустойки (пени), начисленной за весь период просрочки.<br>" skip
       "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Представители " + v-nbankru + " ответят на все возникшие у Вас вопросы по следующим телефонам 59-99-99.<br>" skip
  "</P>" skip.

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

output stream rep to pril.htm.

put stream rep unformatted "<html><head><title>Письмо - рефинансирование</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>" v-sname "</b><BR>" skip
    v-letterdtstr "<BR>" skip
    "&nbsp;<br>" skip
    "<table border=0 cellpadding=0 cellspacing=0 width=50%>" skip
    "<tr>" skip.

do i = 1 to 2:
  put stream rep unformatted
    "<td width=50% align=""left"">" skip
        "<b>" if i = 1 then "До" else "После" " рефинансирования:</b><br>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr>" skip
        "<td colspan=2>Сумма займа:</td>" skip
        "<td colspan=2 align=""right"">" replace(trim(string(v-od[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td colspan=2>Срок кредитования:</td>" skip
        "<td colspan=2 align=""right"">" replace(trim(string(v-psrok[i], ">>9")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td colspan=2>Ставка в год:</td>" skip
        "<td colspan=2 align=""right"">" replace(trim(string(v-prem[i], ">9.99")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td colspan=2>комиссия в месяц:</td>" skip
        "<td colspan=2 align=""right"">" replace(trim(string(v-comprem[i], "9.99")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td colspan=2>Ежемесячный платеж:</td>" skip
        "<td colspan=2 align=""right"">" replace(trim(string(v-mpay[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "<tr>" skip
        "<td colspan=4>&nbsp;</td>" skip
        "</tr>" skip
        "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td>Основной<br>долг</td>" skip
        "<td>Вознаграж<br>дение</td>" skip
        "<td>Комиссия по<br>кредиту</td>" skip
        "<td>Итого<br>платеж</td>" skip
        "</tr>" skip
        "<tr align=""right"">" skip
        "<td>" replace(trim(string(v-mpayod[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "<td>" replace(trim(string(v-mpayprc[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "<td>" replace(trim(string(v-mpaycom[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "<td>" replace(trim(string(v-mpay[i], ">>>,>>>,>>9.99")), ",", "&nbsp;") "</td>" skip
        "</tr>" skip
        "</table>" skip
    "</td>" skip.
 end. /* do i = 1 to 2 */

put stream rep unformatted
    "</tr></table><br>" skip
    "</body></html>" skip.

output stream rep close.

unix silent cptwin pril.htm excel.







