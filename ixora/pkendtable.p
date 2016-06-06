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
        23.04.2008 alex - добавил параметры для казахского языка.
        23.04.2008 alex - добавил поле для ввода Ф.И.О.
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
        19/01/2010 galina - добавила ИИН
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
def input parameter p-clientkz as char.
def input parameter p-podp as logical.
def input parameter p-style as char.
def input parameter p-prtbdt as logical.
def input parameter p-prtname as logical.
def input parameter p-prtstamp as logical.

def shared var v-stamp as char.

/* сведения о банке */
def shared var v-bankname as char.
def shared var v-banknamekz as char.
def shared var v-bankface as char.
def shared var v-bankfacekz as char.
def shared var v-bankadres as char.
def shared var v-bankadreskz as char.
def shared var v-bankiik as char.
def shared var v-bankbik as char.
def shared var v-bankups as char.
def shared var v-bankrnn as char.
def shared var v-bankpodp as char.
def shared var v-bankpodpkz as char.
def shared var v-bankcontact as char.

/* сведения об анкете - общие для всех видов кредитов */
def shared var v-name as char.
def shared var v-rnn as char.
def shared var v-docnum as char.
def shared var v-docdt as char.
def shared var v-adres as char extent 2.
def shared var v-telefon as char.
def shared var v-nameshort as char.
def shared var v-iin as char.

/* печать таблицы реквизитов банка и клиента */
def stream v-out.
output stream v-out to value(p-file) append.

put stream v-out unformatted
    "<table width = 100% border= 0 cellspacing = 0 cellpadding = 0 align = center valign = top " + p-style + ">" skip
        "<tr>" skip
            "<td colspan=5>&nbsp;</td>" skip
        "</tr>" skip
        "<tr valign = top align = center>" skip
            "<td width = 18%><b>" + p-bank + "</b></td>" skip
            "<td width = 31%><b>" + p-clientkz + "</b></td>" skip
            "<td width = 1%></td>" skip
            "<td width = 18%><b>" + p-bank + "</b></td>" skip
            "<td width = 31%><b>" + p-client + "</b></td>" skip
        "</tr>"
        "<tr valign = top>" skip
            "<td>" + v-banknameKZ "</td>" skip
            "<td>" + v-name + "</td>" skip
            "<td></td>" skip
            "<td>" + v-bankname + "</td>" skip
            "<td>" + v-name + "</td>" skip
        "</tr>"
        "<tr valign = top align = left>" skip
            "<td>СТТН " + v-bankrnn + "</td>" skip
            "<td>СТТН " + v-rnn + "</td>" skip
            "<td></td>" skip
            "<td>РНН " + v-bankrnn + "</td>" skip
            "<td>РНН " + v-rnn + "</td>" skip
        "</tr>" skip
        "<tr valign = top align = left>" skip
            "<td></td>" skip
            "<td>ЖСН " + v-iin + "</td>" skip
            "<td></td>" skip
            "<td></td>" skip
            "<td>ИИН " + v-iin + "</td>" skip
        "</tr>" skip

        "<tr valign = top align = left>" skip
            "<td>ЖИК " + v-bankiik + "<br>БИК  " + v-bankbik + "</td>" skip
            "<td>Жеке ку&#1241;лiк N " + v-docnum + ", " + v-docdt + " ж. &#1178;Р IIМ (&#1178;Р &#1240;дiлет министрлiгiмен) берiлген</td>" skip
            "<td></td>" skip
            "<td>ИИК " + v-bankiik + "<br>БИК " + v-bankbik + "</td>" skip
            "<td>Удостоверение личности N "  v-docnum + " выдано МВД РК (МЮ РК) от " + v-docdt + " г. </td>" skip
        "</tr>" skip
        
        "<tr valign = top align = left>" skip
            "<td></td>" skip
            "<td>Т&#1201;р&#1171;ылы&#1179;ты тiркелген жерiнi&#1187; мекенежайы: " + v-adres[1] + "</td>" skip
            "<td></td>" skip
            "<td></td>" skip 
            "<td>Адрес регистрации по месту жительства: " + v-adres[1] + "</td>" skip
        "</tr>" skip
        "<tr valign = top align = left>" skip
            "<td> " + v-bankadreskz + "</td>" skip
            "<td>На&#1179;ты т&#1201;ратын жерiнi&#1187; мекен-жайы: " + v-adres[2] + " Тел.:" + v-telefon + "</td>" skip
            "<td></td>" skip
            "<td> " + v-bankadres + "</td>" skip
            "<td>Адрес фактического проживания: " + v-adres[2] + " Тел.:" + v-telefon + "</td>" skip
        "</tr>" skip
        "<tr valign= top align= center>" skip
            "<td colspan= 2><b>&#1178;ОЛДАРЫ МЕН М&#1256;РЛЕРI</b></td>" skip
            "<td></td>" skip
            "<td colspan= 2><b>ПОДПИСИ И ПЕЧАТИ</b></td>" skip
        "</tr>" skip
        "<tr valign= top align= center>" skip
            "<td colspan= 2>" skip
                "<table width= 100% border= 0 cellspacing = 0 cellpadding= 0 align= center valign= top " + p-style + ">" skip
                    "<tr align= center>" skip
                        "<td width= 10%>Банктi&#1187; атынан</td>" skip.
                  if s-ourbank = "TXB00" then  
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .

                    put stream v-out unformatted
                        "<td width= 15%>Заем алушы</td>" skip
                        "<td width= 48% align= right>________________<br>(&#1179;олы)</td>" skip
                    "</tr>" skip
                    "<tr align= right>" skip
                        "<td colspan= 2>(" + v-bankpodpkz + ")</td>" skip
                        "<td colspan= 2>_____________________________</td>" skip
                    "</tr>" skip
                    
                   
                "</table>" skip
            "</td>" skip
            "<td></td>" skip
            "<td colspan = 2>" skip
                "<table width = 100% border= 0 cellspacing = 0 cellpadding = 0 align = center valign = top " + p-style + ">" skip
                    "<tr align = center>" skip
                        "<td width= 10%>От Банка</td>" skip.
                  if s-ourbank = "TXB00" then  
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .

                    put stream v-out unformatted
                        "<td width= 15%>Заемщик</td>" skip
                        "<td width= 48% align= right>_________________<br>(подпись)</td>" skip
                    "</tr>" skip
                    "<tr align= right>" skip
                        "<td colspan= 2>( " + v-bankpodp + " )</td>" skip
                        "<td colspan= 2>_____________________________</td>" skip
                    "</tr>" skip
                    
                    
                "</table>" skip
            "</td>" skip
        "</tr>" skip
        "<tr align= left>" skip
            "<td align= center><IMG border= 0 src= pkstamp.jpg width= 160 height= 160></td>" skip
            "<td align= right valign= top>_____________________________<br>_____________________________<br>(Аты-ж&#1257;нi толы&#1171;ымен)</td>" skip
            "<td></td>" skip
            "<td align= center><IMG border= 0 src= pkstamp.jpg width= 160 height= 160></td>" skip
            "<td align= right valign= top>_____________________________<br>_____________________________<br>(Ф.И.О. полностью)</td>" skip
        "</td>" skip
"</table>" skip.

output stream v-out close.