/* finkoef.p
 * MODULE
        Финансовые коэффициенты
 * DESCRIPTION
        Дополнительные данные по клиентам
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        01/04/2013 Luiza ТЗ № 1504
 * CHANGES
        23/05/2013 Luiza ТЗ № 1775 отчет.

*/


{mainhead.i}

def var v-cif as char no-undo.
DEFINE VARIABLE phand AS handle.
def var v-name as char no-undo.
def var v-period as char no-undo.
def var v-speed as decim no-undo.
def var v-profit as decim no-undo.
def var v-margin as decim no-undo.
def var v-aspeed as decim no-undo.
def var v-aprofit as decim no-undo.
def var v-price as decim no-undo.
def var v-rem as char no-undo.
def var v-rem1 as char no-undo.
def var v-rem2 as char no-undo.
def var v-rem3 as char no-undo.
def var v-rem4 as char no-undo.
def var v-rem5 as char no-undo.
def var v-rem6 as char no-undo.
def var v-rem7 as char no-undo.
def var v-ja as logic  no-undo format "Да/Нет" init yes.
def var v-yes as logic  no-undo format "Да/Нет" init yes.
def var v_title as char no-undo. /*наименование */
v_title = "Финансовые коэффициенты".
def  var vj-label as char no-undo.
def  var v-bank as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.


def stream r-out.
def new shared temp-table wrk no-undo
    field idotr as int
    field otr   as char
    field code1 as char
    field code2 as char.

def new shared temp-table lst no-undo
    field txb     as char
    field fil     as char
    field code    as decim
    field idotr   as int
    field cif     as char
    field name    as char
    field otr     as char
    field period  as char
    field speed   as decim
    field profit  as decim
    field margin  as decim
    field aspeed  as decim
    field aprofit as decim
    field price   as decim
    field rem     as char.

create wrk.
wrk.idotr = 1.
wrk.otr   = "Торговля".
wrk.code1 = "45.00,47.99".
create wrk.
wrk.idotr = 2.
wrk.otr   = "Производство".
wrk.code1 = "05.00,39.99" .
create wrk.
wrk.idotr = 3.
wrk.otr   = "Услуги".
wrk.code1 = "49.00,99.99".
create wrk.
wrk.idotr = 4.
wrk.otr   = "Строительство".
wrk.code1 = "41.00,43.99".
create wrk.
wrk.idotr = 5.
wrk.otr   = "Аренда".
wrk.code1 = "".
create wrk.
wrk.idotr = 6.
wrk.otr   = "Сельское хозяйство".
wrk.code1 = "01.00,03.99".
define button b1 label "СОЗДАТЬ".
define button b2 label "ПРОСМОТР".
define button b3 label "РЕДАКТИРОВАТЬ".
define button b4 label "УДАЛИТЬ".
define button b6 label "ОТЧЕТ".
define button b5 label "ВЫХОД".

define frame a2
    b1 b2 b3 b4 b6 b5
    with side-labels row 4 column 5 no-box.

     Form
        v-cif      label " Клиент       " format "x(9)" skip
        v-name     label " Наименование " format "x(50)" skip(1)
        v-period   LABEL " Срок кредитования, месяцев         " format "x(3)" validate(int(v-period) > 0,"Неверный срок!") help " Введите код клиента, F2-помощь, F4-выход" skip
        v-speed    LABEL " Скорость товарооборота, дней       " format ">>>,>>9.9" validate(v-speed >= 0,"Неверное значение скорости!")  skip
        v-profit   LABEL " Рентабельность по чистой прибыли, %" format ">>>,>>9.9" validate(v-profit >= 0,"Проверьте значение !") skip
        v-margin   LABEL " Маржа, %                           " format ">>>,>>9.9" validate(v-margin >= 0,"Проверьте значение маржи!") skip
        v-aprofit  LABEL " Рентабельность активов, %          " format ">>>,>>9.9" validate(v-aprofit >= 0,"Проверьте значение !") skip
        v-aspeed   LABEL " Скорость оборачиваемости активов   " format ">>>,>>9.99" validate(v-aspeed >= 0,"Проверьте значение !") skip
        v-price    LABEL " Стоимость аренды 1 кв. м, тенге    " format ">>>,>>>,>>>,>>9.9" validate(v-price >= 0,"Проверьте значение стоимости!") skip(1)
        v-rem1     label " Примечание " format "X(60)" skip
        v-rem2     no-label colon 13 format "X(60)" skip
        v-rem3     no-label colon 13 format "X(60)" skip
        v-rem4     no-label colon 13 format "X(60)" skip
        v-rem5     no-label colon 13 format "X(60)" skip
        v-rem6     no-label colon 13 format "X(60)" skip
        v-rem7     no-label colon 13 format "X(60)" skip(1)
        vj-label no-label format "x(38)" v-ja no-label
    WITH  SIDE-LABELS  ROW 7 column 10 TITLE v_title width 80 FRAME f_main.

form
     v-rem no-label VIEW-AS EDITOR SIZE 60 by 6
     with frame detpay row 19 overlay centered title "Примечание" .

/*обработка вызова помощи*/

on help of v-cif in frame f_main do:
    run h-cif PERSISTENT SET phand.
    v-cif = frame-value.
    displ v-cif with frame f_main.
    DELETE PROCEDURE phand.
end.

/*выбор кнопки Создать*/
on choose of b1 in frame a2 do:

    clear frame f_main.
    v-cif = "".
    v-period = "".
    v-speed = 0.
    v-profit = 0.
    v-margin = 0.
    v-aspeed = 0.
    v-aprofit = 0.
    v-price = 0.
    v-rem = "".
    v-rem1 = "".
    v-rem2 = "".
    v-rem3 = "".
    v-rem4 = "".
    v-rem5 = "".
    v-rem6 = "".
    v-rem7 = "".
    vj-label = " Сохранить?........................." .

 update v-cif with frame f_main.
 find first cif where cif.cif = v-cif no-lock no-error.
 if available cif then v-name = cif.name.
 else do:
    message "Клиент не найден!." view-as alert-box.
    undo,return.
 end.
 displ v-name vj-label with frame f_main.
 find first finkoef where finkoef.cif = v-cif no-lock no-error.
 if available finkoef then do:
    message "Финансовые коэффициенты по данному клиенту уже заполнены! ~n Выберите меню <просмотр> или <редактирование>." view-as alert-box.
    undo,return.
 end.
 update v-period v-speed v-profit v-margin v-aprofit v-aspeed v-price  with frame f_main.
    repeat:
        update v-rem go-on("return") with frame detpay.
        if length(v-rem) > 420 then message 'Примечание превышает 420 символов!'.
        else leave.
    end.
    v-rem1 = substring(v-rem,1,60).
    v-rem2 = substring(v-rem,61,60).
    v-rem3 = substring(v-rem,121,60).
    v-rem4 = substring(v-rem,181,60).
    v-rem5 = substring(v-rem,241,60).
    v-rem6 = substring(v-rem,301,60).
    v-rem7 = substring(v-rem,361,60).
    displ  v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7 with frame f_main.
    pause 0.
    v-ja = yes.
    update v-ja with frame f_main.
    if v-ja then do:
        find first finkoef where finkoef.cif = v-cif exclusive-lock no-error.
        if not available finkoef then do:
            create finkoef.
            finkoef.cif = v-cif.
        end.
        finkoef.period = v-period.
        finkoef.speed = v-speed.
        finkoef.profit = v-profit.
        finkoef.margin = v-margin.
        finkoef.aspeed = v-aspeed.
        finkoef.aprofit = v-aprofit.
        finkoef.price = v-price.
        finkoef.rem[1] = v-rem1.
        finkoef.rem[2] = v-rem2.
        finkoef.rem[3] = v-rem3.
        finkoef.rem[4] = v-rem4.
        finkoef.rem[5] = v-rem5.
        finkoef.rem[6] = v-rem6.
        finkoef.rem[7] = v-rem7.
        finkoef.regdt = today.
        finkoef.who = g-ofc.
        finkoef.tim = time.
        finkoef.del = no.
     end.
     else hide frame f_main.
end. /*конец кнопки новый*/

on choose of b2 in frame a2 do: /* кнопка просмотр*/
    clear frame f_main.
    v-cif = "".
    v-period = "".
    v-speed = 0.
    v-profit = 0.
    v-margin = 0.
    v-aspeed = 0.
    v-aprofit = 0.
    v-price = 0.
    v-rem1 = "".
    v-rem2 = "".
    v-rem3 = "".
    v-rem4 = "".
    v-rem5 = "".
    v-rem6 = "".
    v-rem7 = "".
    vj-label = " ..................................." .
    update v-cif with frame f_main.
    find first cif where cif.cif = v-cif no-lock no-error.
    if available cif then v-name = cif.name.
    else do:
        message "Клиент не найден!." view-as alert-box.
        undo,return.
    end.
    displ v-name with frame f_main.
    find first finkoef where finkoef.cif = v-cif no-lock no-error.
    if not available finkoef then do:
        message "Финансовые коэффициенты по данному клиенту не заполнены! ~n Выберите меню <создать> ." view-as alert-box.
        undo,return.
    end.
    v-period = finkoef.period.
    v-speed = finkoef.speed.
    v-profit = finkoef.profit.
    v-margin = finkoef.margin.
    v-aspeed = finkoef.aspeed.
    v-aprofit = finkoef.aprofit.
    v-price = finkoef.price.
    v-rem1 = finkoef.rem[1].
    v-rem2 = finkoef.rem[2].
    v-rem3 = finkoef.rem[3].
    v-rem4 = finkoef.rem[4].
    v-rem5 = finkoef.rem[5].
    v-rem6 = finkoef.rem[6].
    v-rem7 = finkoef.rem[7].

    displ v-period v-speed v-profit v-margin v-aprofit v-aspeed v-price v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7  with frame f_main.
end. /*конец кнопки finkoef.*/

on choose of b3 in frame a2 do:
    clear frame f_main.
    v-cif = "".
    v-period = "".
    v-speed = 0.
    v-profit = 0.
    v-margin = 0.
    v-aspeed = 0.
    v-aprofit = 0.
    v-price = 0.
    v-rem1 = "".
    v-rem2 = "".
    v-rem3 = "".
    v-rem4 = "".
    v-rem5 = "".
    v-rem6 = "".
    v-rem7 = "".
    vj-label = " Сохранить?........................." .
    update v-cif with frame f_main.
     find first cif where cif.cif = v-cif no-lock no-error.
     if available cif then v-name = cif.name.
     else do:
        message "Клиент не найден!." view-as alert-box.
        undo,return.
     end.
    displ v-name vj-label with frame f_main.
    find first finkoef where finkoef.cif = v-cif no-lock no-error.
    if not available finkoef then do:
        message "Финансовые коэффициенты по данному клиенту не заполнены! ~n Выберите меню <создать> ." view-as alert-box.
        undo,return.
    end.
    v-period = finkoef.period.
    v-speed = finkoef.speed.
    v-profit = finkoef.profit.
    v-margin = finkoef.margin.
    v-aspeed = finkoef.aspeed.
    v-aprofit = finkoef.aprofit.
    v-price = finkoef.price.
    v-rem1 = finkoef.rem[1].
    v-rem2 = finkoef.rem[2].
    v-rem3 = finkoef.rem[3].
    v-rem4 = finkoef.rem[4].
    v-rem5 = finkoef.rem[5].
    v-rem6 = finkoef.rem[6].
    v-rem7 = finkoef.rem[7].
    displ v-period v-speed v-profit v-margin v-aprofit v-aspeed v-price v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7  with frame f_main.

    update v-period v-speed v-profit v-margin v-aprofit v-aspeed v-price with frame f_main.
    v-rem = v-rem1 + v-rem2 + v-rem3 + v-rem4 + v-rem5 + v-rem6 + v-rem7.
    repeat:
        update v-rem go-on("return") with frame detpay.
        if length(v-rem) > 420 then message 'Примечание превышает 420 символов!'.
        else leave.
    end.
    v-rem1 = substring(v-rem,1,60).
    v-rem2 = substring(v-rem,61,60).
    v-rem3 = substring(v-rem,121,60).
    v-rem4 = substring(v-rem,181,60).
    v-rem5 = substring(v-rem,241,60).
    v-rem6 = substring(v-rem,301,60).
    v-rem7 = substring(v-rem,361,60).
    displ  v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7 with frame f_main.
    pause 0.
    v-ja = yes.
    update v-ja with frame f_main.
    if v-ja then do:
        find first finkoef where finkoef.cif = v-cif exclusive-lock no-error.
        finkoef.period = v-period.
        finkoef.speed = v-speed.
        finkoef.profit = v-profit.
        finkoef.margin = v-margin.
        finkoef.aspeed = v-aspeed.
        finkoef.aprofit = v-aprofit.
        finkoef.price = v-price.
        finkoef.rem[1] = v-rem1.
        finkoef.rem[2] = v-rem2.
        finkoef.rem[3] = v-rem3.
        finkoef.rem[4] = v-rem4.
        finkoef.rem[5] = v-rem5.
        finkoef.rem[6] = v-rem6.
        finkoef.rem[7] = v-rem7.
        finkoef.updt = today.
        finkoef.upwho = g-ofc.
        find first finkoef where finkoef.cif = v-cif no-lock no-error.
    end.
end.  /*конец кнопки редактирование*/

on choose of b4 in frame a2 do: /* кнопка УДАЛИТЬ*/
    clear frame f_main.
    v-cif = "".
    v-period = "".
    v-speed = 0.
    v-profit = 0.
    v-margin = 0.
    v-aspeed = 0.
    v-aprofit = 0.
    v-price = 0.
    v-rem1 = "".
    v-rem2 = "".
    v-rem3 = "".
    v-rem4 = "".
    v-rem5 = "".
    v-rem6 = "".
    v-rem7 = "".
    vj-label = " ..................................." .
    update v-cif with frame f_main.
    find first cif where cif.cif = v-cif no-lock no-error.
    if available cif then v-name = cif.name.
    else do:
        message "Клиент не найден!." view-as alert-box.
        undo,return.
    end.
    displ v-name with frame f_main.
    find first finkoef where finkoef.cif = v-cif no-lock no-error.
    if not available finkoef then do:
        message "Финансовые коэффициенты по данному клиенту не заполнены! ~n Выберите меню <создать> ." view-as alert-box.
        undo,return.
    end.
    v-period = finkoef.period.
    v-speed = finkoef.speed.
    v-profit = finkoef.profit.
    v-margin = finkoef.margin.
    v-aspeed = finkoef.aspeed.
    v-aprofit = finkoef.aprofit.
    v-price = finkoef.price.
    v-rem1 = finkoef.rem[1].
    v-rem2 = finkoef.rem[2].
    v-rem3 = finkoef.rem[3].
    v-rem4 = finkoef.rem[4].
    v-rem5 = finkoef.rem[5].
    v-rem6 = finkoef.rem[6].
    v-rem7 = finkoef.rem[7].

    displ v-period v-speed v-profit v-margin v-aprofit v-aspeed v-price v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7  with frame f_main.
    message "Финансовые коэффициенты по данному клиенту удалятся ~n без возможности восстановления! Вы уверены?"  view-as alert-box question buttons yes-no title "" update v-yes .
    if not v-yes then undo,return.
    find first finkoef where finkoef.cif = v-cif exclusive-lock .
    delete finkoef.
    find first finkoef no-lock no-error.
    clear frame f_main.

end. /*конец кнопки УДАЛИТЬ*/

on choose of b6 in frame a2 do: /* кнопка ОТЧЕТ*/
    empty temp-table lst.
    {r-branch.i &proc = "finkoef_txb"}
    display '' format "x(50)" with row 8 frame ww centered no-box.
    pause 0.
    for each lst.
        find first txb where txb.bank = lst.txb no-lock no-error.
        if available txb then lst.fil = txb.info.
    end.
    def var nn as int.
    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream r-out unformatted "<br><br>  АО 'ForteBank' <br>" skip.
    put stream r-out unformatted "<br>" "Финансовые коэффициенты на " string(today) "<br>" skip.
    for each wrk no-lock .
        put stream r-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td> </td>"
                  "<td> </td>"
                  "<td> </td>"
                  "<td bgcolor=""#f5e856"" align=""center"" >" wrk.otr "</td>"
                  "</tr> </table>" skip.

                  case wrk.idotr:
                    when 1 or when 2 then do:
                        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                          "<tr style=""font:bold"">"
                          "<td align=""center"" valign=""top""> № </td>"
                          "<td align=""center"" valign=""top""> Код клиента</td>"
                          "<td align=""center"" valign=""top""> Наименование заемщика</td>"
                          "<td align=""center"" valign=""top""> Отрасль финансируемая</td>"
                          "<td align=""center"" valign=""top""> Скорость <br> товарооборота, <br> дней</td>"
                          "<td align=""center"" valign=""top""> Скорость <br> товарооборота, <br> месяцев</td>"
                          "<td align=""center"" valign=""top""> Рентабельность <br> по чистой <br> прибыли, % </td>"
                          "<td align=""center"" valign=""top""> Маржа, % </td>"
                          "<td align=""center"" valign=""top""> Срок <br> кредитования, <br> месяцев </td>"
                          "<td align=""center"" valign=""top""> Примечание </td>"
                          "<td align=""center"" valign=""top""> Регион </td>"
                          "<td align=""center"" valign=""top""> Код <br> отрасли </td>"
                          "</tr>" skip.
                    end.
                    when 3 or when 4 or when 6 then do:
                        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                          "<tr style=""font:bold"">"
                          "<td align=""center"" valign=""top""> № </td>"
                          "<td align=""center"" valign=""top""> Код клиента</td>"
                          "<td align=""center"" valign=""top""> Наименование заемщика</td>"
                          "<td align=""center"" valign=""top""> Отрасль финансируемая</td>"
                          "<td align=""center"" valign=""top""> Скорость <br> оборачиваемости <br> активов <br> (выручка / совокупные <br> активы) </td>"
                          "<td align=""center"" valign=""top""> Рентабельность <br> активов <br> (ЧП/Основные <br> средства), % </td>"
                          "<td align=""center"" valign=""top""> Рентабельность <br> по чистой <br> прибыли, % </td>"
                          "<td align=""center"" valign=""top""> Маржа, % </td>"
                          "<td align=""center"" valign=""top""> Срок <br> кредитования, <br> месяцев </td>"
                          "<td align=""center"" valign=""top""> Примечание </td>"
                          "<td align=""center"" valign=""top""> Регион </td>"
                          "<td align=""center"" valign=""top""> Код <br> отрасли </td>"
                          "</tr>" skip.
                    end.
                    when 5 then do:
                        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                              "<tr style=""font:bold"">"
                              "<td align=""center"" valign=""top""> № </td>"
                              "<td align=""center"" valign=""top""> Код клиента</td>"
                              "<td align=""center"" valign=""top""> Наименование заемщика</td>"
                              "<td align=""center"" valign=""top""> Отрасль финансируемая</td>"
                              "<td align=""center"" valign=""top""> Скорость <br> оборачиваемости <br> активов <br> (выручка / совокупные <br> активы) </td>"
                              "<td align=""center"" valign=""top""> Рентабельность <br> активов <br> (ЧП/Основные <br> средства), % </td>"
                              "<td align=""center"" valign=""top""> Рентабельность <br> по чистой <br> прибыли, % </td>"
                              "<td align=""center"" valign=""top""> Стоимость <br> аредны 1-го <br> кв.м. </td>"
                              "<td align=""center"" valign=""top""> Срок <br> кредитования, <br> месяцев </td>"
                              "<td align=""center"" valign=""top""> Примечание </td>"
                              "<td align=""center"" valign=""top""> Регион </td>"
                              "<td align=""center"" valign=""top""> Код <br> отрасли </td>"
                              "</tr>" skip.
                    end.

                  end case.
        nn = 0.
        for each lst where lst.idotr = wrk.idotr no-lock.
            nn = nn + 1.
            case wrk.idotr:
                when 1 or when 2 then do:
                    put stream r-out unformatted
                      "<tr>"
                      "<td>" nn "</td>"
                      "<td>" lst.cif "</td>"
                      "<td>" lst.name "</td>"
                      "<td>" lst.otr "</td>"
                      "<td>" replace(trim(string(lst.speed,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.speed / 30,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.profit,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.margin,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" lst.period "</td>"
                      "<td>" lst.rem "</td>"
                      "<td>" lst.fil "</td>"
                      "<td>" "'" + replace(trim(string(lst.code,  ">>>>>9.99")),'.',',') "</td>"
                      "</tr>" skip.
                end.
                when 3 or when 4 or when 6 then do:
                    put stream r-out unformatted
                      "<tr>"
                      "<td>" nn "</td>"
                      "<td>" lst.cif "</td>"
                      "<td>" lst.name "</td>"
                      "<td>" lst.otr "</td>"
                      "<td>" replace(trim(string(lst.aspeed,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.aprofit,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.profit,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.margin,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" lst.period "</td>"
                      "<td>" lst.rem "</td>"
                      "<td>" lst.fil "</td>"
                      "<td>" "'" + replace(trim(string(lst.code,  ">>>>>9.99")),'.',',') "</td>"
                      "</tr>" skip.
                end.
                when 5 then do:
                    put stream r-out unformatted
                      "<tr>"
                      "<td>" nn "</td>"
                      "<td>" lst.cif "</td>"
                      "<td>" lst.name "</td>"
                      "<td>" lst.otr "</td>"
                      "<td>" replace(trim(string(lst.aspeed,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.aprofit,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.profit,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" replace(trim(string(lst.price,  ">>>>>9.99")),'.',',') "</td>"
                      "<td>" lst.period "</td>"
                      "<td>" lst.rem "</td>"
                      "<td>" lst.fil "</td>"
                      "<td>" "'" + replace(trim(string(lst.code,  ">>>>>9.99")),'.',',') "</td>"
                      "</tr>" skip.
                end.

            end case.
        end.
        put stream r-out unformatted "</table>" skip.
        put stream r-out unformatted "<br><br>" skip.

    end.
    output stream r-out close.

    unix silent cptwin fin.htm excel.
end.
on choose of b5 in frame a2 do:
    hide frame a2.
    return.
end. /*конец кнопки выход*/

    enable all with frame a2.
    wait-for window-close of frame a2 or choose of b5 in frame a2.



