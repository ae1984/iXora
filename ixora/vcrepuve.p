/* vcrepuve.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Уведомление по ЛКБК
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        20.07.2012 - подредактировал текст,формат.
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/

{vc.i}
{global.i}

def shared var s-contract like vccontrs.contract.
def shared var s-cif like cif.cif.

def var v-client as char.
def var v-filial as char.
def var v-city as char.
def var v-contr as char.
def var v-ctdate as date.
def var v-psnum as char.
def var v-num as integer.
def var v-psdate as date.
def var v-partner as char.
def var v-partner1 as char.
def var v-ofc as char.
def var v-ofc1 as char.
def var v-depart as integer.
def var v-ps as char.
def var v-day as integer format "99".
def var v-month as char format "x(2)".
def var v-year as integer format "9999".
def var v-dayps as char format "x(2)".
def var v-monthps as char format "x(2)".
def var v-yearps as char format "x(4)".
def var v-dayct as char format "x(2)".
def var v-monthct as char format "x(2)".
def var v-yearct as char format "x(4)".
def var v-file as char init "vcrepuved.htm".

def stream vcrep.

def var v-sel as char.
def var v-head as char init "vcrepuve".

run sel("ВЫБЕРИТЕ","1.Сформировать уведомление по ЛКБК|2.Просмотр документа|3.Сканировать|4.Выход").
v-sel = trim(return-value).

case v-sel:
    when "1" then run ViewDoc.
    when "2" then run vc-oper("1",trim(string(s-contract)),v-head).
    when "3" then run vc-oper("2",trim(string(s-contract)),v-head).
    when "4" then return.
end case.

procedure ViewDoc:
    v-day = day(g-today). v-year = year(g-today). v-month = substr(string(g-today),4,2).

    find first cif where cif.cif = s-cif no-lock no-error.
    if avail cif then do:
        v-depart = integer(cif.jame) mod 1000.
        v-client = trim(trim(cif.prefix) + " " + trim(cif.name)).
    end.

    def var s-ourbank as char.
    find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
    if avail sysc then s-ourbank = trim(sysc.chval).

    if s-ourbank <> "" then do:
        find first cmp no-lock no-error.
        if avail cmp then do:
            v-filial = cmp.name.
        end.
    end.

    find first vccontrs where vccontrs.contract = s-contract and vccontrs.cttype = "1" no-lock no-error.
    if avail vccontrs then do:
        assign
        v-contr   = vccontrs.ctnum
        v-ctdate  = vccontrs.ctdate
        v-partner = vccontrs.partner
        v-ofc     = vccontrs.cwho.

        v-dayct = substr(string(v-ctdate),1,2).
        v-monthct = substr(string(v-ctdate),4,2).
        v-yearct = substr(string(v-ctdate),7,4).
    end.
    else message "У этого контракта не имеется паспорта сделки !" view-as alert-box buttons ok.

    find first vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock no-error.
    if avail vcps then do:
        assign
        v-psnum = vcps.dnnum
        v-num = vcps.num
        v-psdate = vcps.dndate.
        v-ps = v-psnum + trim(string(v-num)).

        v-dayps = substr(string(v-psdate),1,2).
        v-monthps = substr(string(v-psdate),4,2).
        v-yearps = substr(string(v-psdate),7,4).
    end.

    find vcpartners where vcpartners.partner = v-partner no-lock no-error.
    if avail vcpartners then v-partner1 = vcpartners.formasob + " " + vcpartners.name.

    find ofc where ofc.ofc = v-ofc no-lock no-error.
    if avail ofc then v-ofc1 = ofc.name.

    output stream vcrep to value(v-file).
    {html-title.i &stream = "stream vcrep"}

    put stream vcrep unformatted
        "<P class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify'><img src=top_logo_bw.jpg></P>" skip.

    put stream vcrep unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream vcrep unformatted
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "</TABLE>" skip.

    put stream vcrep unformatted
    "<P class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify;font-size:10.0pt'>№________от &nbsp;"
    string(v-day) + "." + v-month + "." string(v-year) "&nbsp; года</P>" skip
    "<P class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify;font-size:10.0pt'>__________&nbsp;" v-client "</P>" skip.

    put stream vcrep unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream vcrep unformatted
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "</table>" skip.

    put stream vcrep unformatted
        "<P class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify;font-size:10.0pt'>"   v-filial  "&nbsp; сообщает,&nbsp;
        что в соответствии с пунктом 11 Правил осуществления экспортно-импортного контроля в Республике Казахстан и получения резидентами учетных
        номеров контрактов по экспорту и импорту (далее - Правила), Вам необходимо в течение 10 календарных дней с момента получения данного запроса в
        письменном виде предоставить в Банк документы, подтверждающие исполнение обязательств сторонами либо обстоятельства, влияющие на сроки
        и условия исполнения обязательств нерезидентом по контракту &nbsp;" v-contr "&nbsp; от &nbsp;" v-dayct + "." + v-monthct + ".20" + v-yearct
        "&nbsp; учетный номер контракта &nbsp;" v-ps "&nbsp; от &nbsp;" v-dayps + "." + v-monthps + ".20" + v-yearps ", заключенному с &nbsp;" v-partner1
        ", в связи с истечением срока репатриации.</P>" skip.

    put stream vcrep unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream vcrep unformatted
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "</TABLE>" skip.

    put stream vcrep unformatted
        "<P class=MsoNormal style='margin:0cm;margin-bottom:.0001pt;text-align:justify;font-size:10.0pt'>При непредставлении вышеуказанных
        документов до последнего числа текущего месяца,&nbsp; Банком,&nbsp; в соответствии с пунктом 51 Правил,&nbsp; будет направлена лицевая
        карточка банковского контроля о нарушении срока репатриации по контракту в Национальный Банк Республики Казахстан.</P>" skip.


    put stream vcrep unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream vcrep unformatted
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip.

    put stream vcrep unformatted
        "<TR style='font-size:10.0pt'>" skip
        "<TD>Уполномоченное лицо Банка</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip.

    put stream vcrep unformatted
        "<TR style='font-size:10.0pt'>" skip
        "<TD align=center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;____________________________________</TD>" skip
        "<TD align=center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;______________________________</TD>" skip
        "</tr><TR style='font-size:10.0pt'>" skip
        "<TD align=center>Должность</TD>" skip
        "<TD align=center>(Ф.И.О.)</TD>" skip
        "</TR>"
        "<TR>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "</TR>" skip
        "<TR style='font-size:10.0pt'>" skip
        "<TD align=center>&nbsp;</TD>" skip
        "<TD align=center>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;______________________________</TD>" skip
        "</TR><TR style='font-size:10.0pt'>" skip
        "<TD align=center>&nbsp;</TD>" skip
        "<TD align=center>Подпись</TD>" skip
        "</TR>" skip
        "</TABLE>" skip.

    put stream vcrep unformatted
        "<P style='font-size:10.0pt'>Исполнитель: &nbsp;&nbsp;Нигматуллина М.М.</P>" skip.

    {html-end.i "stream vcrep"}
    output stream vcrep close.

    unix silent cptwin value(v-file) winword.
end procedure.








