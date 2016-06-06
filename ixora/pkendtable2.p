/* pkendtable2.p
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
        15/07/2009 madiyar - скопировал с изменениями из pkendtable.p
 * BASES
        BANK COMM
 * CHANGES
        02/10/2009 galina - выводим созаемщика
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
        19/01/2010 galina - добавила ИИН
        05/05/2010 madiyar - изменения по тексту
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

/*galina*/
/* сведения об анкете - общие для всех видов кредитов */
def shared var v-names as char.
def shared var v-rnns as char.
def shared var v-docnums as char.
def shared var v-docdts as char.
def shared var v-adress as char extent 2.
def shared var v-telefons as char.
def shared var v-nameshorts as char.
/**/
def var v-iin as char.
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-iin = pkanketh.value1.

/* печать таблицы реквизитов банка и клиента */
def stream v-out.
output stream v-out to value(p-file) append.

put stream v-out unformatted
        "<table width=100% border=0 cellspacing=0 cellpadding=0 align=center valign=top " + p-style + ">" skip
        "<tbody>" skip
        "<tr style=""mso-yfti-irow: 0; mso-yfti-firstrow: yes"">" skip
            "<td width=""48%""><br><b>" + p-bank + ":</b></td>" skip
            "<td width=""1%""></td>" skip
            "<td width=""51%""><br><b>" + p-bank + ":</b></td>" skip
        "</tr>"
        "<tr valign=""top"">" skip
            "<td>" + v-banknameKZ "</td>" skip
            "<td></td>" skip
            "<td>" + v-bankname + "</td>" skip
        "</tr>"
        "<tr valign = top align = left>" skip
            "<td>" + v-bankadreskz + "</td>" skip
            "<td></td>" skip
            "<td>" + v-bankadres + "</td>" skip
        "</tr>" skip
        "<tr valign = top align = left>" skip
            "<td>СТН " + v-bankrnn + "</td>" skip
            "<td></td>" skip
            "<td>РНН " + v-bankrnn + "</td>" skip
        "</tr>" skip
        "<tr valign = top align = left>" skip
            "<td>ЌР Ўлттыќ Банкініѕ Монетарлыќ операцияларды есепке алу басќармасындаєы (ООКСП) корреспонденттік есепшоты ЖИК " + v-bankiik + "<br>БЖК  " + v-bankbik + "</td>" skip
            "<td></td>" skip
            "<td>ИИК " + v-bankiik + " в Управлении учета монетарных операций (ООКСП) Национального Банка Республики Казахстан<br>БИК " + v-bankbik + "</td>" skip
        "</tr>" skip

        "<tr valign=""top"">" skip
            "<td width=""50%""><br><b>" + p-clientkz + ":</b></td>" skip
            "<td width=""1%""></td>" skip
            "<td width=""49%""><br><b>" + p-client + ":</b></td>" skip
        "</tr>"
        "<tr valign=""top"">" skip
            "<td>" + v-name + "</td>" skip
            "<td></td>" skip
            "<td>" + v-name + "</td>" skip
        "</tr>"
        "<tr valign=""top"" align=""left"">" skip
            "<td>СТТН " + v-rnn + "</td>" skip
            "<td></td>" skip
            "<td>РНН " + v-rnn + "</td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>ЖСН " + v-iin + "</td>" skip
            "<td></td>" skip
            "<td>ИИН " + v-iin + "</td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Жеке кујлiк N " + v-docnum + ", " + v-docdt + " ж. ЌР IIМ (ЌР ЈМ) берген</td>" skip
            "<td></td>" skip
            "<td>Удостоверение личности N "  v-docnum + " выдано МВД РК (МЮ РК) от " + v-docdt + " г. </td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Тўраќты тiркеу мекенжайы: " + v-adres[1] + "</td>" skip
            "<td></td>" skip
            "<td>Адрес постоянной регистрации : " + v-adres[1] + "</td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Наќты тўратын жерініѕ мекенжайы: " + v-adres[2] + "<br>Тел.:" + v-telefon + "</td>" skip
            "<td></td>" skip
            "<td>Адрес фактического проживания: " + v-adres[2] + "<br>Тел.:" + v-telefon + "</td>" skip
        "</tr>" skip.

        if v-names <> '' then put stream v-out unformatted
         "<tr valign=""top"">" skip
            "<td width=""50%""><br><b>ЌОСАЛЌЫ ЌАРЫЗ АЛУШЫ:</b></td>" skip
            "<td width=""1%""></td>" skip
            "<td width=""49%""><br><b>СОЗАЕМЩИК:</b></td>" skip
        "</tr>"
        "<tr valign=""top"">" skip
            "<td>" + v-names + "</td>" skip
            "<td></td>" skip
            "<td>" + v-names + "</td>" skip
        "</tr>"
        "<tr valign=""top"" align=""left"">" skip
            "<td>СТТН " + v-rnns + "</td>" skip
            "<td></td>" skip
            "<td>РНН " + v-rnns + "</td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Жеке кујлiк N " + v-docnums + ", " + v-docdts + " ж. ЌР IIМ (ЌР ЈМ) берген</td>" skip
            "<td></td>" skip
            "<td>Удостоверение личности N "  v-docnums + " выдано МВД РК (МЮ РК) от " + v-docdts + " г. </td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Тўраќты тiркеу мекенжайы: " + v-adress[1] + "</td>" skip
            "<td></td>" skip
            "<td>Адрес постоянной регистрации : " + v-adress[1] + "</td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>Наќты тўратын жерініѕ мекенжайы: " + v-adress[2] + "<br>Тел.:" + v-telefons + "</td>" skip
            "<td></td>" skip
            "<td>Адрес фактического проживания: " + v-adress[2] + "<br>Тел.:" + v-telefons + "</td>" skip
        "</tr>" skip.

put stream v-out unformatted
        "<tr valign=""top"">" skip
            "<td><br><b>ЌОЙЫЛЄАН ЌОЛДАРЫ МЕН МҐРЛЕРI</b></td>" skip
            "<td></td>" skip
            "<td><br><b>ПОДПИСИ И ПЕЧАТИ</b></td>" skip
        "</tr>" skip
        "<tr valign=""top"" align=""left"">" skip
            "<td>" skip
                "<table width=100% border=0 cellspacing=1 cellpadding=0 align=center valign=top " + p-style + ">" skip
                    "<tr valign=""top"">" skip
                        "<td width=50%>" skip
                          "Банктіѕ атынан<br>" skip.
                  if s-ourbank = "TXB00" then
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .
                        put stream v-out unformatted
                          "(" + v-bankpodpkz + ")<br>" skip
                          "<center><IMG border=0 src=pkstamp.jpg width=160 height=160></center>" skip
                        "</td>" skip
                        "<td width=50%>" skip
                          p-clientkz + "<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(Аты-жґнi толыєымен, Ќолы)" skip
                        "</td>" skip
                    "</tr>" skip.
                    if v-names <> '' then put stream v-out unformatted
                    "<tr valign=""top"">" skip
                        "<td width=50%>" skip

                        "</td>" skip
                        "<td width=50%>Ќосалќы ќарыз алушы<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(Аты-жґнi толыєымен, Ќолы)" skip
                        "</td>" skip
                    "</tr>" skip.

               put stream v-out unformatted "</table>" skip
            "</td>" skip
            "<td></td>" skip
            "<td>" skip
                "<table width=100% border=0 cellspacing=0 cellpadding=0 align=center valign=top " + p-style + ">" skip
                    "<tr valign=""top"">" skip
                        "<td width=50%>" skip
                          "От Банка<br>" skip.
                  if s-ourbank = "TXB00" then
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .
                        put stream v-out unformatted
                         "(" + v-bankpodp + ")<br>" skip
                          "<center><IMG border=0 src=pkstamp.jpg width=160 height=160></center>" skip
                        "</td>" skip
                        "<td width=50%>" skip
                          p-client + "<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(ФИО полностью, Подпись)" skip
                        "</td>" skip
                    "</tr>" skip.

                    if v-names <> '' then put stream v-out unformatted "<tr valign=""top"">" skip
                        "<td width=50%></td>" skip
                        "<td width=50%>Созаемщик<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(ФИО полностью, Подпись)" skip
                        "</td>" skip
                    "</tr>" skip.

                put stream v-out unformatted "</table>" skip
            "</td>" skip
        "</tr>" skip
"</tbody></table>" skip.

put stream v-out unformatted "</body></html>" skip.

output stream v-out close.
