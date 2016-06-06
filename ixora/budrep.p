/* budrep.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчет по бюджетной позиции
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
 * BASES
	BANK COMM

 * AUTHOR
        14/07/2012 Luiza
 * CHANGES

*/


{mainhead.i}

def var v-year   as int.
def var v-txb  as char.
def var v-txbname  as char.
def var v-month as int.
def var v-monthname as char.
def var v-check as int.
def var v-date as int.
def var v-date2 as int.
def var v-datb as char.
def var v-datf as char.
run sel2 ("Выбор типа отчета :", " 1. Полный | 2. Частичный | 3. Доходы-расходы по кодам операций | 4. Выход ", output v-check).
if keyfunction (lastkey) = "end-error" then return.
if (v-check < 1) or (v-check > 4) then return.
if v-check = 3 then do:
    run budrep1.
    return.
end.
def stream v-out.

define temp-table t-year no-undo
field year as int
index ind2 is primary  year.

find first budget   no-lock no-error.
if available budget then do:
    v-year = budget.year.
    create t-year.
    t-year.year = v-year.
    for each budget no-lock.
        if budget.year <> v-year then do:
            v-year = budget.year.
            create t-year.
            t-year.year = v-year.
        end.
    end.
end.
else do:
    message "Данные для бюджетных позиций не сформированы!".
    return.
end.

DEFINE QUERY q-year FOR t-year.

DEFINE BROWSE b-year QUERY q-year
DISPLAY t-year.year no-label format "9999" WITH  5 DOWN.
DEFINE FRAME f-year b-year  WITH overlay row 5 COLUMN 25 width 15 title "Выберите год".
/***********************************************************************************************************/

/* выбор года -------------------------- */
OPEN QUERY  q-year FOR EACH t-year no-lock.
ENABLE ALL WITH FRAME f-year.
wait-for return of frame f-year
FOCUS b-year IN FRAME f-year.
v-year = t-year.year.
hide frame f-year.


if v-check = 2 then do:

    define temp-table t-month no-undo
    field num as int
    field monthb as char
    field monthf as char.

    create t-month.
    t-month.num = 1.
    t-month.monthb = "Января".
    t-month.monthf = "Январь".
    create t-month.
    t-month.num = 2.
    t-month.monthb = "Февраля".
    t-month.monthf = "Февраль".
    create t-month.
    t-month.num = 3.
    t-month.monthb = "Марта".
    t-month.monthf = "Март".
    create t-month.
    t-month.num = 4.
    t-month.monthb = "Апреля".
    t-month.monthf = "Апрель".
    create t-month.
    t-month.num = 5.
    t-month.monthb = "Майя".
    t-month.monthf = "Май".
    create t-month.
    t-month.num = 6.
    t-month.monthb = "Июня".
    t-month.monthf = "Июнь".
    create t-month.
    t-month.num = 7.
    t-month.monthb = "Июля".
    t-month.monthf = "Июль".
    create t-month.
    t-month.num = 8.
    t-month.monthb = "Августа".
    t-month.monthf = "Август".
    create t-month.
    t-month.num = 9.
    t-month.monthb = "Сентября".
    t-month.monthf = "Сентябрь".
    create t-month.
    t-month.num = 10.
    t-month.monthb = "Октября".
    t-month.monthf = "Октябрь".
    create t-month.
    t-month.num = 11.
    t-month.monthb = "Ноябрь".
    t-month.monthf = "Ноябрь".
    create t-month.
    t-month.num = 12.
    t-month.monthb = "Декабря".
    t-month.monthf = "Декабрь".

    define temp-table t-txb no-undo
    field txb as char
    field name as char.

    create t-txb.
    t-txb.txb = "TXB99".
    t-txb.name = "Консолидированный".
    for each txb where txb.bank begins "TXB" no-lock.
        create t-txb.
        t-txb.txb = txb.bank.
        case txb.bank:
            when "TXB00" then t-txb.name = "Центральный офис".
            when "TXB01" then t-txb.name = "Актобе".
            when "TXB02" then t-txb.name = "Костанай".
            when "TXB03" then t-txb.name = "Тараз".
            when "TXB04" then t-txb.name = "Уральск".
            when "TXB05" then t-txb.name = "Караганда".
            when "TXB06" then t-txb.name = "Семей".
            when "TXB07" then t-txb.name = "Кокшетау".
            when "TXB08" then t-txb.name = "Астана".
            when "TXB09" then t-txb.name = "Павлодар".
            when "TXB10" then t-txb.name = "Петропавловск".
            when "TXB11" then t-txb.name = "Атырау".
            when "TXB12" then t-txb.name = "Актау".
            when "TXB13" then t-txb.name = "Жезказган".
            when "TXB14" then t-txb.name = "Усть-Каменогорск".
            when "TXB15" then t-txb.name = "Шымкент".
            when "TXB16" then t-txb.name = "Алматы".
            OTHERWISE  t-txb.name = txb.name.
        end case.
    end.

    DEFINE QUERY q-txb FOR t-txb.

    DEFINE BROWSE b-txb QUERY q-txb
    DISPLAY t-txb.txb label "Код  "format "x(5)" t-txb.name label "Подразделение" format "x(35)"  WITH  15 DOWN.
    DEFINE FRAME f-txb b-txb  WITH overlay row 8 COLUMN 25 width 60 title "Выберите филиал".

    define temp-table wrk  no-undo
      field gl         as   int
      field coder      as   char
      field code      as   char
      field name       as   char
      field rem        as   char
      field plan       as   decimal
      field fact       as   decimal
      field budget     as   decimal
      field overdraft  as   decimal
      index ind is primary  gl.

    /* выбор филиала ------------------------------  */
    OPEN QUERY  q-txb FOR EACH t-txb no-lock.
    ENABLE ALL WITH FRAME f-txb.
    wait-for return of frame f-txb
    FOCUS b-txb IN FRAME f-txb.
    v-txb = t-txb.txb.
    v-txbname = t-txb.name.
    hide frame f-txb.

     update v-date label 'ЗАДАЙТЕ МЕСЯЦ С'
         validate(v-date >= 1 and v-date <= 12, "неверный номер месяца. ")
         help "Введите номер месяца начала периода."
         v-date2 label 'ПО'
         validate(v-date2 >= 1 and v-date2 <= 12, "неверный номер месяца. ")
         help "Введите номер месяца конца периода." with row 8 centered  side-label frame opt.
    if v-date2 < v-date then do:
         message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
         undo,retry.
    end.
    /* расчет---------------------------------------*/
    displ  "Ждите идет подготовка данных для отчета"  WITH FRAME a overlay COLUMN 10 ROW 10 width 50.
    pause 0.
    /*if v-txb = "TXB00" then do:*/  /* если ЦО */
        /*for each budget use-index budyear where (not substring(budget.coder,8,5) begins "TXB" or substring(budget.coder,8,5) begins
            "TXB00") and not substring(budget.coder,8,5) begins "___" and budget.coder <> "" and not budget.code begins "TXB" no-lock .
            if budget.plan[v-month] <> 0 or budget.fact[v-month] <> 0 or budget.budget[v-month] <> 0 or budget.overdraft[v-month] <> 0 then do:
                create wrk.
                wrk.gl = budget.gl.
                wrk.coder = budget.coder.
                wrk.code = substring(budget.coder,1,7).
                wrk.name = budget.name.
                wrk.rem = budget.txbname.
                wrk.plan = budget.plan[v-month].
                wrk.fact = budget.fact[v-month].
                wrk.budget = budget.budget[v-month].
                wrk.overdraft = budget.overdraft[v-month].
            end.
        end.
    end.
    else do:*/

        if v-txb = "TXB99" then do:  /* если консолид */
            for each t-txb where t-txb.txb <> "TXB99". /* Консолид */
                for each budget use-index budyear where budget.year = v-year and substring(budget.coder,8,5) = t-txb.txb  no-lock.
                    v-month = v-date.
                    do while v-month <= v-date2:
                        if budget.fact[v-month] <> 0 or budget.plan[v-month] <> 0 or budget.budget[v-month] <> 0 then do:
                            find first wrk where wrk.gl = budget.gl and wrk.code = substring(budget.coder,1,7) no-error.
                            if available wrk then do:
                                wrk.plan = wrk.plan + budget.plan[v-month].
                                wrk.fact = wrk.fact + budget.fact[v-month].
                                wrk.budget = wrk.budget + budget.budget[v-month].
                                wrk.overdraft = (wrk.fact + wrk.budget) / wrk.plan * 100.
                            end.
                            else do:
                                create wrk.
                                wrk.gl = budget.gl.
                                wrk.coder = budget.coder.
                                wrk.code = substring(budget.coder,1,7).
                                wrk.name = budget.name.
                                wrk.plan = wrk.plan + budget.plan[v-month].
                                wrk.fact = wrk.fact + budget.fact[v-month].
                                wrk.budget = wrk.budget + budget.budget[v-month].
                                wrk.overdraft = (wrk.fact + wrk.budget) / wrk.plan * 100.
                            end.
                        end.
                        v-month = v-month + 1.
                    end. /* do while  */
                end.
            end.
        end.
        else do:
            for each budget use-index budyear where budget.year = v-year and substring(budget.coder,8,5) = v-txb  no-lock.
                v-month = v-date.
                do while v-month <= v-date2:
                    if budget.fact[v-month] <> 0 or budget.plan[v-month] <> 0 or budget.budget[v-month] <> 0 then do:
                        find first wrk where wrk.gl = budget.gl and wrk.code = substring(budget.coder,1,7) no-error.
                        if available wrk then do:
                            wrk.plan = wrk.plan + budget.plan[v-month].
                            wrk.fact = wrk.fact + budget.fact[v-month].
                            wrk.budget = wrk.budget + budget.budget[v-month].
                            wrk.overdraft = (wrk.fact + wrk.budget) / wrk.plan * 100.
                        end.
                        else do:
                            create wrk.
                            wrk.gl = budget.gl.
                            wrk.coder = budget.coder.
                            wrk.code = substring(budget.coder,1,7).
                            wrk.name = budget.name.
                            wrk.plan = wrk.plan + budget.plan[v-month].
                            wrk.fact = wrk.fact + budget.fact[v-month].
                            wrk.budget = wrk.budget + budget.budget[v-month].
                            wrk.overdraft = (wrk.fact + wrk.budget) / wrk.plan * 100.
                        end.
                    end.
                    v-month = v-month + 1.
                end. /* do while  */
            end.
        end.
   /* end.*/
    find first t-month where t-month.num = v-date no-error.
    if available t-month then v-datb = t-month.monthb.
    find first t-month where t-month.num = v-date2 no-error.
    if available t-month then v-datf = t-month.monthf.

    if v-txb = "TXB99" then v-txbname = "Консолидированный отчет".

    output stream v-out to budrep.html.
    put stream v-out unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    if v-date = v-date2 then put stream v-out unformatted  "<h3>Отчет по бюджетной позиции АО 'FORTEBANK' за "  v-datf  " (" v-txbname ")""</h3>" skip.
    else put stream v-out unformatted  "<h3>Отчет по бюджетной позиции АО 'FORTEBANK' с "  v-datb " по "  v-datf  " (" v-txbname ")""</h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.


    put stream v-out unformatted "<tr align=center>"
        "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B>Счет ГЛ</B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> Код расхода </B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> Наименование кода расхода</B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> План </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> Факт </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> Сверх бюджет </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> % Исполнения </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""4""><B> Примечание </B></FONT></TD>" skip
        "</tr>" skip.
    for each wrk break by wrk.gl:

        put stream v-out  unformatted "<TR> <TD align=""left""><FONT size=""3"">" wrk.gl "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" wrk.code "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" wrk.name "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(wrk.plan,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(wrk.fact,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(wrk.budget,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(wrk.overdraft,'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""left"">" wrk.rem "</TD> </TR>" skip.
        if last-of(wrk.gl) then do:
            put stream v-out unformatted "<TR> <TD> </TD></TR>" skip.
        end.

    end.
    put stream v-out unformatted "</table>".
end.

else do:
    displ  "Ждите идет подготовка данных для отчета"  WITH FRAME a overlay COLUMN 10 ROW 10 width 50.
    pause 0.
    output stream v-out to budrep.html.
    put stream v-out unformatted "<html><head><title>FORTEBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h3>Отчет по бюджетной позиции АО 'FORTEBANK' за " v-year  " г. </h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.


    put stream v-out unformatted "<tr align=center>"
        "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B>Счет ГЛ</B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Наименование счета </B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Код расхода </B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Подразделение &nbsp</B></FONT></TD>"  skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Наимен кода расхода &nbsp</B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Контрол.подразд </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План<br>январь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт<br>январь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет<br>январь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения<br>январь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>февраль</B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>февраль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>февраль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>февраль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>март </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>март  </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет  <br>март </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>март  </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>апрель </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>апрель </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>апрель </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>апрель </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>май </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>май </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>май </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>май </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>июнь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>июнь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>июнь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>июнь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>июль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>июль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>июль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>июль </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>август </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>август </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>август </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>август </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>сентябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>сентябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>сентябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>сентябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>октябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>октябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>октябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>октябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>ноябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>ноябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>ноябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>ноябрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> План <br>декабрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Факт <br>декабрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> Сверх бюджет <br>декабрь </B></FONT></TD>" skip
             "<TD bgcolor=""#C0C0C0""><FONT size=""3""><B> % Исполнения <br>декабрь </B></FONT></TD>" skip
        "</tr>" skip.
    for each budget use-index budyear where budget.year = v-year no-lock.

        put stream v-out  unformatted "<TR> <TD align=""left""><FONT size=""3"">" budget.gl "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" budget.des "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" budget.coder "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" budget.txbname "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" budget.name "</TD>" skip
            "<TD align=""left""><FONT size=""3"">" budget.depname "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[1],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[1],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[2],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[2],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[3],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[3],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[4],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[4],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[5],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[5],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[6],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[6],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[7],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[7],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[8],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[8],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[9],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[9],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[10],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[10],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[11],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[11],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.plan[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.fact[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.budget[12],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
            "<TD align=""right""><FONT size=""3"">" replace(trim(string(budget.overdraft[12],'->>>>>>>>>>>9')),'.',',') "</TD>" skip
            "</TR>" skip.
    end.
    put stream v-out unformatted "</table>".
end.
output stream v-out close.
unix silent value("cptwin budrep.html excel").
hide message no-pause.
return.
