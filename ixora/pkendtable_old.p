/* pkendtable.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Печать реквизитов банка и заемщика во всех договорах
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
 * BASES
        BANK COMM
 * CHANGES
        14.03.2003 nadejda
        07.11.2003 marinav Добавление признака - печатать ФИО или нет в реквизитах
        07.09.2004 saltanat - Добавила в сведения о банке контактные номера только для Быстрых денег.
        02/03/2005 madiyar - изменения в тексте (УПС НБ РК)
        13/05/2005 madiyar - изменения, подпись клиента
        16.05.2005 marinav - изменения в подписях - для кред карт убрано факт место проживания
        21/12/2005 madiyar - электронная печать
        28/02/2006 madiyar - казпочта: электронная печать
        10/08/2006 madiyar - ссылки на картинки для казпочты - по справочнику
        12/09/2006 madiyar - электронная печать - филиалы
        24/10/2006 madiyar - инвертировал справочник kppeng
        24/04/2007 madiyar - веб-анкеты
        07/11/07   marinav - банк берется из point.Termlist
        03/01/2008 madiyar - поменял текст "От МКО" на "От Банка"
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
*/


{global.i}
{pk.i}
{pk-sysc.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.

def input parameter p-file as char.
def input parameter p-bank as char.
def input parameter p-client as char.
def input parameter p-podp as logical.
def input parameter p-style as char.
def input parameter p-prtbdt as logical.
def input parameter p-prtname as logical.
def input parameter p-prtstamp as logical.

def shared var v-stamp as char.

/* сведения о банке */
def shared var v-bankname as char.
def shared var v-bankadres as char.
def shared var v-bankiik as char.
def shared var v-bankbik as char.
def shared var v-bankups as char.
def shared var v-bankrnn as char.
def shared var v-bankpodp as char.
def shared var v-bankcontact as char.

/* сведения об анкете - общие для всех видов кредитов */
def shared var v-name as char.
def shared var v-rnn as char.
def shared var v-docnum as char.
def shared var v-adres as char extent 2.
def shared var v-telefon as char.
def shared var v-nameshort as char.

/* печать таблицы реквизитов банка и клиента */
def stream v-out.
output stream v-out to value(p-file) append.

put stream v-out unformatted
  "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" valign=""top""" + p-style + ">" skip
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%"">" + p-bank + "</TD>" skip
      "<TD width=""50%"">" + p-client + "</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""left"">" skip
      "<TD>"
      v-bankname
      "</TD>" skip.
   if p-prtname then
     put stream v-out unformatted
        "<TD>" v-name "</TD>" skip.
    else
     put stream v-out unformatted
        "<TD>___________________________________________________________</TD>" skip.
     put stream v-out unformatted
    "</TR>" skip
    "<TR valign=""top"" align=""left"">" skip
      "<TD>РНН "
      v-bankrnn
      "</TD>" skip
      "<TD>РНН "
      v-rnn
      "</TD>" skip
    "</TR>" skip.

if p-prtbdt then do:
  find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and
       pkanketh.ln = s-pkankln and pkanketh.kritcod = "bdt" no-lock no-error.

  put stream v-out unformatted
    "<TR valign=""top"" align=""left"">" skip
      "<TD>&nbsp;</TD>" skip
      "<TD>Дата рождения "
      string (date (pkanketh.value1), "99/99/9999")
      "</TD>" skip
    "</TR>" skip.
end.


find first point where point.point = 1 no-lock no-error.
if avail point then do:

  put stream v-out unformatted
    "<TR valign=""top"" align=""left"">" skip
      "<TD>ИИК "
      v-bankiik " " trim(point.Termlist)
      " , БИК "
      v-bankbik
      "</TD>" skip
      "<TD>Удостоверение личности N "
      v-docnum
      "</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""left"">" skip
      "<TD> Республика Казахстан </TD>"  skip
      "<TD>Адрес регистрации по месту жительства: "
      v-adres[1]
      "</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""left"">" skip
      "<TD>"
      v-bankadres 
      skip
      "</TD>" skip.
end.

      if s-credtype ne '4' then
put stream v-out unformatted
      "<TD>Адрес фактического проживания: "
      v-adres[2] + "<BR>Тел.: " skip  v-telefon skip.
else
put stream v-out unformatted  "<TD>Тел.: ______________"  skip.

put stream v-out unformatted
      "</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"">" skip
      "<TD colspan=""2"">&nbsp;</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"">" skip
      "<TD colspan=""2"">ПОДПИСИ И ПЕЧАТИ</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""left"">" skip
      "<TD>" skip
        "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""left""" + p-style + ">" skip
          "<TR valign=""middle"" align=""left"">" skip
            "<TD width=""20"">" skip.

          if p-podp then
            put stream v-out unformatted "<NOBR>От Банка</NOBR>" skip.
          else
            put stream v-out unformatted "&nbsp;" skip.

          put stream v-out unformatted
            "</TD>" skip
            "<TD height=""50"">&nbsp;" + s-dogsign + "</TD>" skip
          "</TR>" skip
          "<TR valign=""top"" align=""left"">" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>(" + v-bankpodp + ")</TD>" skip
          "</TR>" skip.

if p-prtstamp then do:
  put stream v-out unformatted
          "<TR valign=""top"">" skip
          "<TD colspan=2 align=""center""><IMG border=""0"" src=""" + v-stamp + """ width=""160"" height=""160""></TD>" skip
          "</TR>" skip.
end.

put stream v-out unformatted
        "</TABLE></TD>" skip
      "<TD>"
        "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""2"" align=""left""" + p-style + ">" skip
          "<TR valign=""middle"" align=""left"">" skip
            "<TD width=""20"">" skip.

          if p-podp then
            put stream v-out unformatted "Заемщик" skip.
          else
            put stream v-out unformatted "&nbsp;" skip.

          put stream v-out unformatted
            "</TD>" skip
            "<TD height=""50"">&nbsp;</TD>" skip
          "</TR>" skip
          
          "<TR valign=""top"" align=""left"">" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>_____________________________________</TD>" skip
          "</TR>" skip
          
          "<TR valign=""top"" align=""left"">" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>(Подпись)</TD>" skip
          "</TR>" skip
          
          "<TR valign=""top"" align=""left"">" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>_____________________________________</TD>" skip
          "</TR>" skip
          
          "<TR valign=""top"" align=""left"">" skip
            "<TD>&nbsp;</TD>" skip
        /*    "<TD>(" + v-nameshort + ")</TD>" skip */
            "<TD>(Ф.И.О. полностью)</TD>" skip
          "</TR>" skip
          
        "</TABLE></TD>" skip
    "</TR>"
  "</TABLE>" skip.

output stream v-out close.
