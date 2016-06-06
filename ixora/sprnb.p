/* sprnb.p
 * MODULE
        Операционист
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * CONNECT
        bank, comm

 * AUTHOR
        18.06.2004 dpuchkov
 * CHANGES
        27.12.04 dpuchkov добавил рекурсивный поиск
        t-fnd -> t2 -> waaatbl
        31.12.04 dpuchkov убрал фразу "сообщаем что"
        12.01.05 dpuchkov добавил запятые в отчет.
        22.06.05 dpuchkov добавил фразу "сообщаем что" и пару запятых
        13.09.05 dpuchkov добавил поиск информации по филиалам!
        06.05.06 dpuchkov Поменял надпись управляющий директор.
        23.08.06 dpuchkov Оптимизация
        13/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН
        15/12/2011 evseev - установил ширину фрейма fr1 = 100
        15/03/2012 id00810 - добавила v-bankname для печати
        05/05/2012 evseev - название из banknameDgv
        27.08.2012 evseev - иин/бин
*/

{global.i}
{chbin.i}

def stream v-out.
def var s-okn as char.
def new shared temp-table t2
    field number  as integer
    field number2 as integer
    field jss     like cif.jss
    field bin     like cif.bin
    field name    like cif.name
    field cif     like cif.cif
    field prefix  like cif.prefix
    field closed  as char.

def new shared temp-table t-fnd
    field number   as integer
    field name     like cif.name
    field fullname like cif.name
    field jss      like cif.jss
    field bin      like cif.bin
    field fnd      as logical init false.
def new shared var i-tmpidx as integer init 0.
def new shared var vtmen    as char.


def new shared temp-table waaatbl like aaa
    field number2 as integer
    field closed  as char.


def temp-table wciftbl like cif.

def var sumchartmp  as char.
def var i-ind       as integer init 0.
def var sumchartmp2 as char.

def var sumdec      as decimal.
def var l-found     as logical init False.

def var sumchartmp1 as char.

def var v-valut     as char.
def var v-valut1    as char.
def var v-dep       as integer.
def var v-cont      as integer init 0.
def var i1          as integer init 0.


def var l_fnd       as logical init False.

def stream rep.
def stream repG.
def stream clsd.

def var ch_num_mail  as char.
def var dt_date_mail as date.
def var ch_name      as char.
def var ch_address   as char.
def var ch_name1     as char.
def var ch_name2     as char.
def var ch_name3     as char.
def var ch_name4     as char.
def var ch_name5     as char.
def var ch_name6     as char.
def var ch_name7     as char.
def var ch_name8     as char.
def var ch_name9     as char.

def var ch_address1  as char.
def var ch_address2  as char.
def var ch_address3  as char.
def var v-bankname   as char no-undo.

define frame getlist2
    ch_num_mail format "x(30)" label "Введите номер письма НБ  " skip
    dt_date_mail  label              "Введите дату письма НБ   " skip
    ch_name format "x(69)" label     "Адресат"  skip
    ch_name1 format "x(69)" label    "Адресат" skip
    ch_name2 format "x(69)" label    "Адресат" skip
    ch_name3 format "x(69)" label    "Адресат" skip
    ch_name4 format "x(69)" label    "Адресат" skip
    ch_name5 format "x(69)" label    "Адресат" skip
    ch_name6 format "x(69)" label    "Адресат" skip
    ch_name7 format "x(69)" label    "Адресат" skip
    ch_name8 format "x(69)" label    "Адресат" skip
    ch_name9 format "x(69)" label    "Адресат" skip

    ch_address format "x(69)" label  "Адрес  " skip
    ch_address1 format "x(69)" label "Адрес  "  skip
    ch_address2 format "x(69)" label "Адрес  "  skip
    ch_address3 format "x(69)" label "Адрес  "  skip

    with side-labels centered row 6.


DEFINE QUERY q1 FOR t-fnd.
define buffer buf for t-fnd.

DEFINE QUERY q2 FOR t2.
define buffer buf1 for t2.

define frame getlist1
    t-fnd.fullname label  "Ф.И.О. полное" format 'x(59)' validate(t-fnd.fullname <> "", 'Необходимо ввести наменование клиента!  ') help "Полное Ф.И.О. клиента - для отображения при неудачном поиске!" skip
    t-fnd.name label      "Ф.И.О (поиск)" format 'x(59)' help "Фрагмент Ф.И.О. клиента (поиск по частичному совпадению)" skip
    t-fnd.bin label       "ИИН/БИН      " format 'x(12)' validate( (length(t-fnd.bin) = 12 or t-fnd.bin = "") , 'ИИН/БИН должен содержать 12 символов!  ')  help "ИИН/БИН клиента (поиск по полному совпадению)" skip
    with side-labels centered row 9.

def browse b1
    query q1
    displ
    t-fnd.bin  label "ИИН/БИН"  format 'x(12)'
    t-fnd.name label "Ф.И.О" format 'x(59)'
 with 9 down title "Критериии поиска" overlay.

def browse b2
    query q2
    displ
    t2.cif  label "CIF"  format 'x(12)'
    t2.prefix label "Ф.Соб."  format 'x(3)'
    t2.name label "Наименование клиента" format 'x(52)'
 with 9 down title "Результат поиска клиентов" overlay.


DEFINE BUTTON bedt   LABEL "См.\Изм.".
DEFINE BUTTON bnew   LABEL "Создать".
DEFINE BUTTON bdel   LABEL "Удалить".
DEFINE BUTTON bfnd   LABEL "Поиск".
DEFINE BUTTON bext   LABEL "Выход".
DEFINE BUTTON bdispl LABEL "Отобразить справку".

def frame fr1
    b1
    skip
    bnew
    bedt
    bdel
    bfnd
    bext with centered overlay row 5 width 100 top-only.

def frame fr2
    b2
    skip
    bdel
    bdispl with centered overlay row 5 top-only.


ON CHOOSE OF bdispl IN FRAME fr2
    do:
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
    end.


ON CHOOSE OF bdel IN FRAME fr2
    do:
        def var a1 as integer init 0.
        for each buf1:
            a1 = a1 + 1.
        end.
        if a1 = 1 then
        do: /* message " Невозможно удалить единственную запись.". pause. */
            find buf1 where rowid (buf1) = rowid (t2) exclusive-lock.
            delete buf1.
            close query q2.
                open query q2 for each t2.
        end.
        else
            if a1 = 0 then
            do:
                message " Нет записей для удаления".
                pause.
            end.
            else
            do:
                find buf1 where rowid (buf1) = rowid (t2) exclusive-lock.
                delete buf1.
                close query q2.
                    open query q2 for each t2.
                browse b2:refresh().
            end.
    end.


ON CHOOSE OF bext IN FRAME fr1
    do:
        hide frame getlist1.
        APPLY "WINDOW-CLOSE" TO BROWSE b1.
    end.


ON CHOOSE OF bdel IN FRAME fr1
    do:
        find buf where rowid (buf) = rowid (t-fnd) exclusive-lock.
        delete buf.
        close query q1.
            open query q1 for each t-fnd.
        browse b1:refresh().
    end.


ON CHOOSE OF bedt IN FRAME fr1
    do:
        find buf where rowid (t-fnd) = rowid (buf) exclusive-lock.
        update t-fnd.fullname t-fnd.name t-fnd.bin with frame getlist1.
        close query q1.
            open query q1 for each t-fnd.
        browse b1:refresh().
    end.


ON CHOOSE OF bnew IN FRAME fr1
    do:
        create t-fnd.
        update t-fnd.fullname t-fnd.name t-fnd.bin with frame getlist1.
        close query q1.
            open query q1 for each t-fnd.
        browse b1:refresh().
    end.


ON CHOOSE OF bfnd IN FRAME fr1
    do:
        message "Идет поиск..".
        run FindClients.
        hide frame getlist1.
        APPLY "WINDOW-CLOSE" TO BROWSE b1.
    end.

run sel2 ("", " 1.Справка с указ. нескольких клиентов | 2. Справка с указ. одного клиента | ВЫХОД", output v-dep).
if v-dep = 0 then return.
case v-dep:
    when 1 then
        do:
                open query q1 for each t-fnd .
            b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
            ENABLE all with frame fr1 centered overlay top-only.
            apply "value-changed" to b1 in frame fr1.
            WAIT-FOR WINDOW-CLOSE of frame fr1.
            hide frame fr1.
        end.

    when 2 then
        do:
            for each t-fnd :
                delete t-fnd.
            end.

            create t-fnd.
            update t-fnd.fullname t-fnd.name t-fnd.bin  with frame getlist1.
            message "Идет поиск..".
            run FindClients.
        end.


    when 3 then
        do:
            return.
        end.
end.

procedure FindClients.
    def var i-number as integer init 0.
    i-number = 1.
    for each waaatbl:
        delete waaatbl.
    end.
    for each wciftbl:
        delete wciftbl.
    end.

    for each t-fnd:
        t-fnd.number = i-number.
        i-number = i-number + 1.
    end.

    hide frame getlist1.

    {r-branch.i &proc = "sprnb1"}

    message "".
    pause 0.
        open query q2 for each t2.
    ENABLE all with frame fr2 centered overlay top-only.
    apply "value-changed" to b2 in frame fr2.
    WAIT-FOR WINDOW-CLOSE of frame fr2.


    for each t-fnd:
        find last t2 where t2.number = t-fnd.number no-error.
        if avail t2 then
            t-fnd.fnd = true.
        else t-fnd.fnd = false.
    end.

    i-number = 1.
    for each t2:
        t2.number2 = i-number.
        i-number = i-number + 1.
    end.


    /*   {r-branch.i &proc = "sprnb2"}*/

    for each comm.txb where comm.txb.consolid = true no-lock:

        if connected ("txb") then disconnect "txb".
        /*    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). */
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run sprnb2.
    end.

    if connected ("txb") then disconnect "txb".
    if connected ("comm") then disconnect "comm".



    update ch_num_mail dt_date_mail ch_name ch_name1 ch_name2 ch_name3 ch_name4 ch_name5 ch_name6 ch_name7 ch_name8 ch_name9  ch_address ch_address1 ch_address2 ch_address3 with frame getlist2.

    hide frame getlist2.

    find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
    if avail sysc then v-bankname = sysc.chval.

    output stream rep to value("sprav300.htm").
    output stream repG to value("spravG00.htm").
    output stream clsd to value("spravCLS.htm").
    {html-title.i &stream = "stream rep" &title = " " &size-add = " "}
    {html-title.i &stream = "stream repG" &title = " " &size-add = " "}
    {html-title.i &stream = "stream clsd" &title = " " &size-add = " "}
    put stream rep unformatted
        "<TABLE class=""MsoTableGrid"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""border-collapse:collapse;border:none;"" align=""right"">"
        "<TR align=""right"" style=""font-size:12.0pt;background:white"">" skip.

    put stream repG unformatted
        "<TABLE class=""MsoTableGrid"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""border-collapse:collapse;border:none;"" align=""right"">"
        "<TR align=""right"" style=""font-size:12.0pt;background:white"">" skip.

    put stream clsd unformatted
        "<TABLE class=""MsoTableGrid"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""border-collapse:collapse;border:none;"" align=""right"">"
        "<TR align=""right"" style=""font-size:12.0pt;background:white"">" skip.




    def var i-k as integer init 0.
    put stream rep unformatted "<TD  align=""left""> " .
    put stream repG unformatted "<TD  align=""left""> " .
    put stream clsd unformatted "<TD  align=""left""> " .

    if ch_name <> "" then
    do:
        put stream rep unformatted ch_name " <br> ".
        put stream repG unformatted ch_name " <br> ".
        put stream clsd unformatted ch_name " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name1 <> "" then
    do:
        put stream rep unformatted ch_name1 " <br> ".
        put stream repG unformatted ch_name1 " <br> ".
        put stream clsd unformatted ch_name1 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name2 <> "" then
    do:
        put stream rep unformatted ch_name2 " <br> ".
        put stream repG unformatted ch_name2 " <br> ".
        put stream clsd unformatted ch_name2 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name3 <> "" then
    do:
        put stream rep unformatted ch_name3 " <br> ".
        put stream repG unformatted ch_name3 " <br> ".
        put stream clsd unformatted ch_name3 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name4 <> "" then
    do:
        put stream rep unformatted ch_name4 " <br> ".
        put stream repG unformatted ch_name4 " <br> ".
        put stream clsd unformatted ch_name4 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name5 <> "" then
    do:
        put stream rep unformatted ch_name5 " <br> ".
        put stream repG unformatted ch_name5 " <br> ".
        put stream clsd unformatted ch_name5 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name6 <> "" then
    do:
        put stream rep unformatted ch_name6 " <br> ".
        put stream repG unformatted ch_name6 " <br> ".
        put stream clsd unformatted ch_name6 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name7 <> "" then
    do:
        put stream rep unformatted ch_name7 " <br> ".
        put stream repG unformatted ch_name7 " <br> ".
        put stream clsd unformatted ch_name7 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name8 <> "" then
    do:
        put stream rep unformatted ch_name8 " <br> ".
        put stream repG unformatted ch_name8 " <br> ".
        put stream clsd unformatted ch_name8 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_name9 <> "" then
    do:
        put stream rep unformatted ch_name9 " <br> ".
        put stream repG unformatted ch_name9 " <br> ".
        put stream clsd unformatted ch_name9 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_address <> "" then
    do:
        put stream rep unformatted ch_address " <br> ".
        put stream repG unformatted ch_address " <br> ".
        put stream clsd unformatted ch_address " <br> ".
        i-k = i-k + 1.
    end.
    if ch_address1 <> "" then
    do:
        put stream rep unformatted ch_address1 " <br> ".
        put stream repG unformatted ch_address1 " <br> ".
        put stream clsd unformatted ch_address1 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_address2 <> "" then
    do:
        put stream rep unformatted ch_address2 " <br> ".
        put stream repG unformatted ch_address2 " <br> ".
        put stream clsd unformatted ch_address2 " <br> ".
        i-k = i-k + 1.
    end.
    if ch_address3 <> "" then
    do:
        put stream rep unformatted ch_address3 " <br> ".
        put stream repG unformatted ch_address3 " <br> ".
        put stream clsd unformatted ch_address3 " <br> ".
        i-k = i-k + 1.
    end.
    put stream rep unformatted " </TD>" skip.
    put stream repG unformatted " </TD>" skip.
    put stream clsd unformatted " </TD>" skip.

    put stream rep unformatted "</TR>" skip.
    put stream rep unformatted "</TABLE>" skip.
    put stream repG unformatted "</TR>" skip.
    put stream repG unformatted "</TABLE>" skip.

    put stream clsd unformatted "</TR>" skip.
    put stream clsd unformatted "</TABLE>" skip.


    def var i-k1 as integer.
    do i-k1 = 1 to i-k :
        put stream rep unformatted "<br>   </br>" skip.
        put stream repG unformatted "<br>   </br>" skip.

        put stream clsd unformatted "<br>   </br>" skip.
    end.

    put stream rep unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream repG unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream clsd unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.


    def var v-c1 as integer init 0.
    def var v-c2 as integer init 0.
    def var v-c3 as integer init 0.

    find last t-fnd where t-fnd.fnd = true no-error.
    if avail t-fnd then v-c1 = 1.

    find last t-fnd where t-fnd.fnd = false no-error.
    if avail t-fnd then v-c2 = 1.

    def var i_ao     as integer init 0.
    def var i_clsdao as integer init 0.
    /*   if (v-c1 > 0 and v-c2 = 0) then do: */
    if (v-c1 > 0 and v-c2 = 0) or (v-c1 > 0 and v-c2 > 0)  then
    do:                                                                                                                 /*  сообщаем, что */
        put stream clsd unformatted " <P style=""font-size:12.0pt; ""> <span>       </span> На запрос Национального Банка Республики Казахстан N " ch_num_mail " от " dt_date_mail "г. ".
        put stream rep unformatted " <P style=""font-size:12.0pt; ""> <span>       </span> На запрос Национального Банка Республики Казахстан N " ch_num_mail " от " dt_date_mail "г. ".
        for each t2:
            find last t-fnd where t-fnd.number = t2.number and t-fnd.fnd = true.
            if not avail t-fnd then next.

            if t2.jss <> "" or t2.bin <> "" then
            do: /* отображать РНН */
                if t2.closed = "C"  then
                do:
                    v-c3 = 1.
                    if i_clsdao = 0 then put stream clsd unformatted "АО " v-bankname " подтверждает что на имя " t2.prefix " " t2.name ", ИИН/БИН "t2.bin ", был открыт счет" .
                    i_clsdao = 1.
                end.
                else
                do:
                    if i_ao = 0 then put stream rep unformatted "АО " v-bankname " подтверждает наличие у " t2.prefix " " t2.name ", ИИН/БИН "t2.bin .
                    if i_ao > 0 then put stream rep unformatted ", " t2.prefix " " t2.name  ", ИИН/БИН "t2.bin .
                    i_ao = 1.
                end.
                for each waaatbl where waaatbl.number2 = t2.number2 /*and waaatbl.sta <> 'C' and waaatbl.sta <> 'E' */ :
                    find last crc where crc.crc = waaatbl.crc no-lock no-error.
                    if crc.crc = 1 then
                    do:
                        v-valut = "тенге".
                        v-valut1 = "тиын.".
                    end.
                    if crc.crc = 2 then
                    do:
                        v-valut = "доллары США".
                        v-valut1 = "цента.".
                    end.
                    if crc.crc = 3 then
                    do:
                        v-valut = "евро".
                        v-valut1 = "".
                    end.
                    if crc.crc = 4 then
                    do:
                        v-valut = "рублей".
                        v-valut1 = "копеек".
                    end.
                    run Sm-vrd(waaatbl.cr[1] - waaatbl.dr[1], output sumchartmp).
                    if sumchartmp = "Ноль" then
                    do:
                        s-okn = substr(string(waaatbl.cr[1] - waaatbl.dr[1]), length(string(truncate(waaatbl.cr[1] - waaatbl.dr[1], 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "долларов США".
                            if crc.crc = 4 then  v-valut = "рублей." .
                        end.
                        sumchartmp1 = "".
                        v-valut1 = "".
                        sumchartmp2 = "0.00".
                        sumchartmp = "".
                    end.
                    else
                    do:
                        run frac (waaatbl.cr[1] - waaatbl.dr[1], output sumdec).
                        if sumdec = 0.0 then sumchartmp1 = "00".
                        else sumchartmp1 = string(sumdec * 100).
                        s-okn = substr(string(sumdec), length(string(truncate(sumdec, 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "центов".
                            if crc.crc = 4 then  v-valut = "копеек" .
                            if crc.crc = 3 then  v-valut = "центов".
                        end.

                        if s-okn = "1" then
                        do:
                            if crc.crc = 2 then v-valut = "цент".
                            if crc.crc = 4 then v-valut = "копейка".
                            if crc.crc = 3 then v-valut = "цент".
                        end.

                        if s-okn = "2" or s-okn = "3" or s-okn = "4" then
                        do:
                            if crc.crc = 2 then v-valut = "цента".
                            if crc.crc = 4 then v-valut = "копейки" .
                            if crc.crc = 3 then v-valut = "цента".
                        end.
                        s-okn = substr(string(waaatbl.cr[1] - waaatbl.dr[1]), length(string(truncate(waaatbl.cr[1] - waaatbl.dr[1], 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "долларов США".
                            if crc.crc = 4 then  v-valut = "рублей." .
                        end.

                        if s-okn = "1" then
                        do:
                            if crc.crc = 2 then v-valut = "доллар США".
                            if crc.crc = 4 then v-valut = "рубль.".
                        end.

                        if s-okn = "2" or s-okn = "3" or s-okn = "4" then
                        do:
                            if crc.crc = 2 then v-valut = "доллара США".
                            if crc.crc = 4 then v-valut = "рубля." .
                        end.

                        sumchartmp2 = string(waaatbl.cr[1] - waaatbl.dr[1]).
                        if sumchartmp = "" then
                        do:
                            sumchartmp = "Ноль".
                            sumchartmp2 = "0" + sumchartmp2.
                        end.
                    end.
                    if t2.closed = "C"  then
                    do:
                        put stream clsd unformatted ", ИИК " waaatbl.aaa " в " waaatbl.lgr  " от " waaatbl.stadt ". Счет закрыт от "  waaatbl.cltdt " г.".

                    end.
                    else
                    do:
                        if sumchartmp2 = "0.00" then
                            put stream rep unformatted ", ИИК " waaatbl.aaa " в " waaatbl.lgr  " с остатком денежных средств на " g-today "г.- " sumchartmp2 " " sumchartmp " " v-valut /* " " sumchartmp1 " " v-valut1 ""*/ .
                        else
                            put stream rep unformatted ", ИИК " waaatbl.aaa " в " waaatbl.lgr  " с остатком денежных средств на " g-today "г.- " sumchartmp2 " (" sumchartmp " " v-valut " " sumchartmp1 " " v-valut1 ")" .
                    end.
                end.
            end.
            else
            do: /* не отображать РНН */
                if t2.closed = "C"  then
                do:
                    v-c3 = 1.
                    put stream clsd unformatted "АО " v-bankname " подтверждает что на имя " t2.prefix " " t2.name  ", был открыт счет".

                end.
                else
                    put stream rep unformatted "АО " v-bankname " подтверждает наличие у " t2.prefix " " t2.name .
                for each waaatbl where waaatbl.number2 = t2.number2 /*and  waaatbl.sta <> 'C' and waaatbl.sta <> 'E' */ :
                    find last crc where crc.crc = waaatbl.crc no-lock no-error.
                    if crc.crc = 1 then
                    do:
                        v-valut = "тенге".
                        v-valut1 = "тиын".
                    end.
                    if crc.crc = 2 then
                    do:
                        v-valut = "доллары США".
                        v-valut1 = "цента".
                    end.
                    if crc.crc = 3 then
                    do:
                        v-valut = "евро".
                        v-valut1 = "цента".
                    end.
                    if crc.crc = 4 then
                    do:
                        v-valut = "рублей".
                        v-valut1 = "копеек".
                    end.
                    run Sm-vrd(waaatbl.cr[1] - waaatbl.dr[1], output sumchartmp).
                    if sumchartmp = "Ноль" then
                    do:
                        s-okn = substr(string(waaatbl.cr[1] - waaatbl.dr[1]), length(string(truncate(waaatbl.cr[1] - waaatbl.dr[1], 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "долларов США".
                            if crc.crc = 4 then  v-valut = "рублей." .
                        end.
                        sumchartmp1 = "".
                        v-valut1 = "".
                        sumchartmp2 = "0.00".
                        sumchartmp  = "".
                    end.
                    else
                    do:
                        run frac (waaatbl.cr[1] - waaatbl.dr[1], output sumdec).
                        if sumdec = 0.0 then sumchartmp1 = "00".
                        else sumchartmp1 = string(sumdec * 100).
                        s-okn = substr(string(sumdec), length(string(truncate(sumdec, 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "центов".
                            if crc.crc = 4 then  v-valut = "копеек" .
                            if crc.crc = 3 then  v-valut = "центов".
                        end.

                        if s-okn = "1" then
                        do:
                            if crc.crc = 2 then v-valut = "цент".
                            if crc.crc = 4 then v-valut = "копейка".
                            if crc.crc = 3 then v-valut = "цент".
                        end.

                        if s-okn = "2" or s-okn = "3" or s-okn = "4" then
                        do:
                            if crc.crc = 2 then v-valut = "цента".
                            if crc.crc = 4 then v-valut = "копейки" .
                            if crc.crc = 3 then v-valut = "цента".
                        end.
                        s-okn = substr(string(waaatbl.cr[1] - waaatbl.dr[1]), length(string(truncate(waaatbl.cr[1] - waaatbl.dr[1], 0))), 1) .
                        if s-okn = "0" or s-okn = "5" or s-okn = "6" or s-okn = "7" or s-okn = "8" or s-okn = "9" then
                        do:
                            if crc.crc = 2 then  v-valut = "долларов США".
                            if crc.crc = 4 then  v-valut = "рублей." .
                        end.

                        if s-okn = "1" then
                        do:
                            if crc.crc = 2 then v-valut = "доллар США".
                            if crc.crc = 4 then v-valut = "рубль.".
                        end.

                        if s-okn = "2" or s-okn = "3" or s-okn = "4" then
                        do:
                            if crc.crc = 2 then v-valut = "доллара США".
                            if crc.crc = 4 then v-valut = "рубля.".
                        end.

                        sumchartmp2 = string(waaatbl.cr[1] - waaatbl.dr[1]).
                    end.

                    if t2.closed = "C"  then
                    do:
                        put stream clsd unformatted ", ИИК " waaatbl.aaa " в " waaatbl.lgr  " от " waaatbl.stadt ". Счет закрыт от "  waaatbl.cltdt " г.".

                    end.
                    else
                    do:

                        if sumchartmp2 = "0.00" then
                            put stream rep unformatted ", ИИК " waaatbl.aaa  " с остатком денежных средств на " g-today "г.- " sumchartmp2 " " sumchartmp " "  v-valut /* " " sumchartmp1 " " v-valut1 ""*/ .
                        else
                            put stream rep unformatted ", ИИК " waaatbl.aaa  " с остатком денежных средств на " g-today "г.- " sumchartmp2 " (" sumchartmp " "  v-valut " " sumchartmp1 " " v-valut1 ")".
                    end.
                end.
            end.
        end.
        put stream rep unformatted " </P>".
    end.

    i-ind = 0.
    /*      if (v-c1 = 0 and v-c2 = 0) or (v-c1 > 0 and v-c2 > 0) or (v-c1 = 0 and v-c2 > 0) then  */
    if (v-c1 = 0 and v-c2 = 0) or (v-c1 > 0 and v-c2 > 0) or (v-c1 = 0 and v-c2 > 0) then


    do: /*не найдены*/
        i-ind = 0.

        put stream repG unformatted "<P><span>       </span> На запрос  Национального Банка Республики Казахстан N "
            ch_num_mail " от " dt_date_mail "г. сообщаем, что".  /*: <br>". */


        def var x-dex as integer init 0.
        for each t-fnd where t-fnd.fnd = false:
            x-dex = x-dex + 1.
        end.
        if x-dex = 1 then
        do:
            for each t-fnd where t-fnd.fnd = false:
                if t-fnd.jss <> "" or t-fnd.bin <> "" then
                    put stream repG unformatted " " t-fnd.fullname  ", ИИН/БИН " t-fnd.bin.
                else
                    put stream repG unformatted " " t-fnd.fullname.
                i-ind = i-ind + 1.
            end.
        end.
        else
        do:
            put stream repG unformatted ": <br>" .

            for each t-fnd where t-fnd.fnd = false:
                if t-fnd.jss <> "" or t-fnd.bin <> "" then
                do:
                    if i-ind = x-dex - 1 then
                        put stream repG unformatted "<span>       </span>- " t-fnd.fullname  ", ИИН/БИН " t-fnd.bin "<br>".
                    else
                        put stream repG unformatted "<span>       </span>- " t-fnd.fullname  ", ИИН/БИН " t-fnd.bin ";<br>".
                end.
                else
                do:
                    if i-ind = x-dex - 1 then
                        put stream repG unformatted "<span>       </span>- " t-fnd.fullname  "<br>".
                    else
                        put stream repG unformatted "<span>       </span>- " t-fnd.fullname  ";<br>".
                end.
                i-ind = i-ind + 1.
            end.
        end.
        if i-ind > 1 then
            put stream repG unformatted " в списках  клиентов АО " v-bankname " не значатся. </P>" skip.
        else
            put stream repG unformatted " в списках  клиентов АО " v-bankname " не значится. </P>" skip.
    end.

    output stream v-out to rpt.img.
    if (v-c1 > 0  and v-c2 > 0) then
        for each t-fnd where t-fnd.fnd = true:
            for each t2 where t2.number = t-fnd.number:
                if t-fnd.jss <> "" or t-fnd.bin <> "" then
                    put stream v-out unformatted " - " t2.name  ", ИИН/БИН " t2.bin " является клиентом" skip.
                else
                    put stream v-out unformatted " - " t2.name " является клиентом" skip.
            end.
        end.
    output stream v-out close.
    hide all.


    find last ofc where ofc.ofc = g-ofc no-lock no-error.
    put stream rep unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream repG unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream clsd unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.


    put stream rep unformatted  "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream repG unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.
    put stream clsd unformatted "<br>   </br>" skip
        "<br>   </br>" skip
        "<br>   </br>" skip.


    put stream rep unformatted "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
        "<TR align=""right"" style=""background:white"">" skip.

    put stream repG unformatted "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
        "<TR align=""right"" style=""background:white"">" skip.

    put stream clsd unformatted "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""right"">" skip
        "<TR align=""right"" style=""background:white"">" skip.

    put stream rep unformatted  "<TD width=""50%"" align=""left"" style=""font-size:10"" > Исп: " ofc.name " </TD></TR> " skip.
    put stream repG unformatted "<TD width=""50%"" align=""left"" style=""font-size:10"" > Исп: " ofc.name " </TD></TR> " skip.
    put stream clsd unformatted "<TD width=""50%"" align=""left"" style=""font-size:10"" > Исп: " ofc.name " </TD></TR> " skip.


    put stream rep unformatted "</body></html>" skip.
    put stream repG unformatted "</body></html>" skip.
    put stream clsd unformatted "</body></html>" skip.

    output stream rep close.
    output stream repG close.
    output stream clsd close.


    if v-c1 > 0 then
    do:
        find last t2 where t2.closed = "" no-error.
        if avail t2 then
        do:
            unix silent value("cptwin sprav300.htm winword").
        end.
    end.
    if v-c3 > 0 then
        unix silent value("cptwin spravCLS.htm winword").

    if (v-c1 > 0 and v-c2 > 0) or (v-c2 > 0) then
    do:
        unix silent value("cptwin spravG00.htm winword").
        run menu-prt('rpt.img').
    end.
end Procedure.







