/* pksski.p
 * MODULE
        Потребкредитование
 * DESCRIPTION
        Формирование согласий субъекта кредитной истории
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
        18/05/2006 madiyar
 * BASES
        bank, comm
 * CHANGES
        13/04/07 marinav - добавлено "Подтверждение"
        19/04/2007 marinav - убрано Согласие на выдачу кредита
        24/04/2007 madiyar - веб-анкеты
        25/04/2007 marinav - поменялся внешний вид Согласия
        03/01/08   marinav - переделано на Метрокомбанк
        04/11/2009 galina - поправила вывод даты рождения
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        27/04/2012 evseev  - повтор
*/

{global.i}
{pk.i}
{pk-sysc.i}
{nbankBik.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def var v-ofile as char.
def stream v-out.

def var v-inet as logi no-undo.
def var v-stamp as char no-undo.
if pkanketa.id_org = "inet" then do:
    v-inet = yes.
    v-stamp = "c:\\tmp\\pkstamp.jpg".
end.
else do:
    v-inet = no.
    v-stamp = get-pksysc-char ("dcstmp").
end.


def shared var v-name as char.
def shared var v-adres as char extent 2.
def shared var v-docnum as char.
def shared var v-docdt as char.
def shared var v-docvyd as char.
def shared var v-bankpodp as char.

def var v-bdt as char.
def var v-bplace as char.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and  pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "bdt" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,".") > 0 then v-bdt = replace(pkanketh.value1,'.','/').
  else do:
    if index(pkanketh.value1,"/") > 0 then v-bdt = pkanketh.value1.
    else v-bdt = string(pkanketh.value1, "99/99/9999").
  end.
end.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "bplace" no-lock no-error.
if avail pkanketh then v-bplace = pkanketh.value1.
find first cmp no-lock no-error.

v-ofile = "kredzayav2.htm".

output stream v-out to value(v-ofile).
put stream v-out unformatted "<!-- Согласия субъекта кредитной истории -->" skip.
{html-title.i
 &stream = " stream v-out "
 &title = " "
 &size-add = "xx-"
}

put stream v-out unformatted
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip

  "<TR><TD align=""center"" colspan=2><br><B>Согласие<BR>субъекта кредитной истории на предоставление <br> информации о нем в кредитные бюро</B><BR><BR>" skip
  "</TD></TR>" skip

  "<TR><TD><BR><BR>" today " </TD><TD align=""right""> местное время " substr(string(time,"hh:MM"),1,2) " часов " substr(string(time,"hh:MM"),4,2) " минут " skip
  "</TD></TR>" skip

  "<TR><TD colspan=2><br><br><i><u>&nbsp;" v-name "&nbsp;</i></u>, дата рождения <i><u> " v-bdt "</i></u>, место рождения <i><u> " v-bplace "</i></u>, адрес <i><u>&nbsp;" v-adres[1] "&nbsp;</i></u>, удостоверение личности N  <i><u>&nbsp;" v-docnum "&nbsp;</i></u> выдано " v-docvyd " <i><u>&nbsp;" trim(string(v-docdt,"x(40)")) "&nbsp;</i></u>,<br>" skip
  " дает настоящее согласие в том, что информация о нем, касающаяся его (ее) финансовых и других обязательств имущественного характера, находящаяся в " + v-nbankru + " и во всех возможных источниках, и которая поступит в указанные источники в будущем  <BR><BR>" skip

  "____________________________________________________________________________________________________________________________________________<BR>" skip
  "</TD></TR>" skip

  "<TR><TD align=""center"" colspan=2><i>(в случае согласия на раскрытие информации, которая поступит в будущем, <br> необходимо поставить подпись; в случае несогласия с раскрытием информации, <br> которая поступить в будущем, необходимо поставить прочерк),</i><BR><BR><br>" skip
  "</TD></TR>" skip

  "<TR><TD align=""justify"" colspan=2>будет предоставлена во все кредитные бюро__________________________________________________________________________________________________ <br>" skip
  "</TD></TR>" skip

  "<TR><TD align=""center"" colspan=2><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(ФИО полностью, подпись)</i><BR><BR><br>" skip
  "</TD></TR>" skip

  "<TR><TD align=""justify"" colspan=2><br>" cmp.name  skip
  "</TD></TR>" skip.

put stream v-out unformatted
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD width=""40%"">&nbsp;<br>" + s-dogsign + "<br>(" + v-bankpodp + ")</TD>" skip
  "<TD width=""60%""><IMG border=""0"" src=""" + v-stamp + """ width=""140"" height=""140"" ></TD></TR>" skip
  "</TABLE>" skip.

put stream v-out unformatted
  "</TD></TR></TABLE>" skip.

{html-end.i "stream v-out" }

output stream v-out close.
if v-inet then unix silent value("mv " + v-ofile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-ofile).
else unix silent value("cptwin " + v-ofile + " iexplore").



