/* rep10CB.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        отчеты Отчет об оборотах наличных денег
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
        25/10/2012 Luiza
 * CHANGES
*/


{mainhead.i}

def var v-op as int.
def var v-op1 as int.
def var v-op3 as int.
def new shared var vmonth as int.
def new shared var vyear as int.
def new shared var dt1 as date no-undo.
def new shared var dt2 as date no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def var ch as char.
def new shared var v-sh as char.
def new shared var v-ful as logic format "да/нет" no-undo.

def stream v-out.
def var prname as char.
def var v-select1 as int no-undo.
def var lll as int.

function ddd returns char (input p1 as int).
    def var res as char.
    res = string(p1).
    if string(p1) = "1" then res = " январь " .
    if string(p1) = "2" then res = " февраль " .
    if string(p1) = "3" then res = " март " .
    if string(p1) = "4" then res = " апрель " .
    if string(p1) = "5" then res = " май " .
    if string(p1) = "6" then res = " июнь " .
    if string(p1) = "7" then res = " июль " .
    if string(p1) = "8" then res = " августа " .
    if string(p1) = "9" then res = " сентябрь " .
    if string(p1) = "10" then res = " октябрь " .
    if string(p1) = "11" then res = " ноябрь " .
    if string(p1) = "12" then res = " декабрь " .
    return res.
end function.

def frame f-date
   vmonth label " Номер месяца" format "99" validate(vmonth > 0 and vmonth <= 12, "Некорректный месяц!") skip
   vyear label  " Год   " format "9999" validate(vyear >= 2000 and vyear <= year(today),"Некорректная год!") skip
   v-ful label " С расшифровкой" skip
with side-labels centered row 7 title "Параметры отчета".


update  vmonth vyear v-ful with frame f-date.
dt1 = date(vmonth,1,vyear).
if vmonth < 12 then dt2 = date(vmonth + 1,1,vyear) - 1.
else dt2 = date(1,1,vyear + 1) - 1.

v-select1 = 0.
def var v-raz as char  no-undo.

run sel2 (" Выберите ", "1.В тыс.тенге |2.В тенге|3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "тыс.тенге". else v-raz = "тенге".

if v-ful then do:
    def var v-tdam as deci no-undo.
    def var v-tcam as deci no-undo.
    def var v-tdam_KZT as deci no-undo.
    def var v-tcam_KZT as deci no-undo.
    def var v-dam_in as deci no-undo.
    def var v-cam_in as deci no-undo.
    def var v-dam_out as deci no-undo.
    def var v-cam_out as deci no-undo.
    def var v-dam_out_KZT as deci no-undo.
    def var v-cam_out_KZT as deci no-undo.
    def var v-tdam1 as deci no-undo.
    def var v-tcam1 as deci no-undo.
    def var v-tdam_KZT1 as deci no-undo.
    def var v-tcam_KZT1 as deci no-undo.
    def var v-td        as logi no-undo.
    def var v-aktiv     as logi no-undo.

    def new shared temp-table wrk no-undo
      field bank as char
      field bankn as char
      field gl as integer
      field crc as integer
      field crc_code as char
      field jdt as date
      field jh as integer
      field glcorr as integer
      field glcorr_des as char
      field acc_corr as char
      field dam as deci
      field cam as deci
      field dam_KZT as deci
      field cam_KZT as deci
      field rem as char
      field who as char
      field glcorr2 as integer
      field glcorr_des2 as char
      field acc2 as char
      field cod as char
      field kbe as char
      field knp as char
      field rez as char
      field rez1 as char
      field cassp as char
      index idx is primary bank gl crc jdt jh.

    def new shared temp-table wrk_ost no-undo
      field bank as char
      field gl as integer
      field crc as integer
      field dam_in as deci
      field cam_in as deci
      field dam_out as deci
      field cam_out as deci
      field dam_in_KZT as deci
      field cam_in_KZT as deci
      field dam_out_KZT as deci
      field cam_out_KZT as deci
      index idx is primary bank gl crc.

    def new shared temp-table ttt no-undo
      field bank as char
      field name as char.

    for each txb no-lock.
        create ttt.
        ttt.bank = txb.bank.
        ttt.name = txb.info.
    end.


    def var cons_type as int.
    def new shared var v-from as date .
    def new shared var v-to as date .
    def new shared var v-list as char .
    cons_type = 1.
    v-from = dt1.
    v-to = dt2.
    v-list = "100100,100500".
    def new shared var v-valuta as int .
    def new shared var v-valuta_code as char .
    def new shared var v-glacc as int format ">>>>>>".
    def new shared var v-dt as dec format "->>>,>>>,>>>,>>9.99".
    def new shared var v-ct like v-dt.
end.

define new shared temp-table wrk1 no-undo
    field num1 as char
    field vid1 as char
    field sum1 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field cassp1 as char
    field num2 as char
    field vid2 as char
    field sum2 as decim format ">>>,>>>,>>>,>>>,>>9.99"
    field sumtxb1 as decim extent 17 format ">>>,>>>,>>>,>>>,>>9.99"
    field sumtxb2 as decim extent 17 format ">>>,>>>,>>>,>>>,>>9.99"
    field cassp2 as char.

create wrk1.
wrk1.num1 = "01".
wrk1.vid1 = "Тауарлар, ќызмет кґрсету жјне орындалєан жўмыс ґткізуден заѕды тўлєалардан тїскен тїсімдер
Поступления от реализации товаров, услуг и выполненных работ юридическими лицами".
wrk1.cassp1 = "10".
wrk1.num2 = "21".
wrk1.vid2 = "Тауарлар, ќызмет кґрсету жјне орындалєан жўмыс їшін аќы тґлеу їшін заѕды тўлєаларєа аќша беру
Выдачи на оплату товаров, услуг и выполненных работ юридическими лицами".
wrk1.cassp2 = "210".

create wrk1.
wrk1.num1 = "02".
wrk1.vid1 = "Жеке тўлєалардыѕ шоттарына тїскен тїсімдер
Поступления на счета физических лиц".
wrk1.cassp1 = "20".
wrk1.num2 = "22".
wrk1.vid2 = "Жеке тўлєалардыѕ шоттарынан аќша беру
Выдачи со счетов физических лиц".
wrk1.cassp2 = "220".

create wrk1.
wrk1.num1 = "03".
wrk1.vid1 = " Ујкілетті банктердіѕ айырбастау пункттерініѕ шетел валютасын сатуынан тїскен тїсімдер
Поступления от продажи иностранной валюты обменными пунктами уполномоченных банков".
wrk1.cassp1 = "30".
wrk1.num2 = "23".
wrk1.vid2 = "їшін меншікті айырбастау пункттеріне ујкілетті банктердіѕ аќша беруі
Выдачи на покупку иностранной валюты уполномоченными банками собственным обменным пунктам".
wrk1.cassp2 = "230".

create wrk1.
wrk1.num1 = "04".
wrk1.vid1 = " Ќолма-ќол шетел валютасымен айырбастау операцияларын жїргізуге лицензиясы бар ујкілетті
ўйымдардыѕ шетел валютасын сатуынан тїскен тїсімдер Поступления от продажи иностранной валюты уполномоченными организациями,
имеющими лицензию на проведение обменных операций с наличной иностранной валютой".
wrk1.cassp1 = "40".
wrk1.num2 = "24".
wrk1.vid2 = "Ќолма-ќол шетел валютасымен айырбастау операцияларын жїргізуге лицензиясы бар ујкілетті ўйымдардыѕ шетел валютасын сатып алуы їшін аќша беру
Выдачи на покупку иностранной валюты уполномоченным органи- зациям, имеющим лицензию на проведение обменных операций с наличной иностранной валютой".
wrk1.cassp2 = "240".

create wrk1.
wrk1.num1 = "05".
wrk1.vid1 = "Аќша аударымдарыныѕ жїйелері арќылы (шот ашпай) Ќазаќстан бойынша біржолєы аударым їшін жеке тўлєалардан тїскен тїсімдер
Поступления от физических лиц для разового перевода по Казахстану посредством систем денежных переводов (без открытия счета)".
wrk1.cassp1 = "50".
wrk1.num2 = "25".
wrk1.vid2 = "Аќша аударымдарыныѕ жїйелері арќылы (шот ашпай) Ќазаќстан бойынша біржолєы аударым бойынша жеке тўлєаларєа беру
Выдачи физическим лицам по разовому переводу по Казахстану посредством систем денежных переводов (без открытия счета)".
wrk1.cassp2 = "250".

create wrk1.
wrk1.num1 = "06".
wrk1.vid1 = "Аќша аударымдарыныѕ жїйелері арќылы (шот ашпай) шетелге біржолєы аударым їшін жеке тўлєалардан тїскен тїсімдер
Поступления от физических лиц для разового перевода за рубеж посредством систем денежных переводов (без открытия счета)".
wrk1.cassp1 = "60".
wrk1.num2 = "26".
wrk1.vid2 = "Аќша аударымдарыныѕ жїйелері арќылы (шот ашпай) шетелден біржолєы аударым бойынша жеке тўлєаларєа беру
Выдачи физическим лицам по разовому переводу из-за рубежа посредством систем денежных переводов (без открытия счета)".
wrk1.cassp2 = "260".

create wrk1.
wrk1.num1 = "07".
wrk1.vid1 = "Еѕбекаќы їшін алынєан аќшаны ќайтару
Возврат денег, полученных на оплату труда".
wrk1.cassp1 = "70".
wrk1.num2 = "27".
wrk1.vid2 = "Еѕбекаќы, зейнетаќы жјне жјрдемќаќы тґлеу їшін аќша беру
Выдачи на оплату труда,  пенсий и пособий".
wrk1.cassp2 = "270".

create wrk1.
wrk1.num1 = "08".
wrk1.vid1 = "".
wrk1.cassp1 = "80".
wrk1.num2 = "28".
wrk1.vid2 = "Банкоматтарды ныєайту їшін аќша беру
Выдачи для подкрепления банкоматов".
wrk1.cassp2 = "280".

create wrk1.
wrk1.num1 = "09".
wrk1.vid1 = "Заемдарды ґтеу
Погашение займов".
wrk1.cassp1 = "90".
wrk1.num2 = "29".
wrk1.vid2 = "Заемдар беру
Выдачи займов ".
wrk1.cassp2 = "290".

create wrk1.
wrk1.num1 = "10".
wrk1.vid1 = "Басќа да тїсімдер
Прочие поступления".
wrk1.cassp1 = "100".
wrk1.num2 = "30".
wrk1.vid2 = "Басќа да шыєыстар
Прочие расходы".
wrk1.cassp2 = "300".

create wrk1.
wrk1.num1 = "55".
wrk1.vid1 = "КІРІС БОЙЫНША ЖИЫНТЫЄЫ (01-10)
ИТОГО ПО ПРИХОДУ (01-10)".
wrk1.cassp1 = "".
wrk1.num2 = "56".
wrk1.vid2 = "ШЫЄЫС БОЙЫНША ЖИЫНТЫЄЫ (21-30)
ИТОГО ПО РАСХОДУ (21-30)".
wrk1.cassp2 = "".

create wrk1.
wrk1.num1 = "11".
wrk1.vid1 = "Екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операциялыќ кассасындаєы есепті кезеѕ басындаєы ќолма-ќол аќша ќалдыєы
Остаток наличных денег в операционной кассе банков второго уровня, организаций на начало отчетного периода".
wrk1.cassp1 = "".
wrk1.num2 = "31".
wrk1.vid2 = "Екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операциялыќ кассасындаєы есепті кезеѕ аяєындаєы ќолма-ќол аќша ќалдыєы
Остаток наличных денег в операционной кассе банков второго уровня, организаций на конец отчетного периода".
wrk1.cassp2 = "".

create wrk1.
wrk1.num1 = "12".
wrk1.vid1 = "ЌР ЎБ филиалдарыныѕ айналым кассасынан екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операциялыќ кассасына ќолма-ќол аќшаныѕ тїсуі
Поступления наличных денег в операционную кассу банков второго уровня из оборотной кассы филиалов Национального Банка".
wrk1.cassp1 = "120".
wrk1.num2 = "32".
wrk1.vid2 = "Екінші деѕгейдегі банктердіѕ Ўлттыќ Банк филиалдарыныѕ айналым кассасына ќолма-ќол аќша тапсыруы
Сдача наличных денег  банками второго уровня организациями в оборотную кассу филиалов Национального Банка".
wrk1.cassp2 = "320".

create wrk1.
wrk1.num1 = "13".
wrk1.vid1 = "Екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операциялыќ кассасына оныѕ касса бґлімшелерінен,
басќа екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операция  Поступления наличных денег в операционную кассу банков второго уровня,
организаций из его кассовых подразделений и из операционных касс других банков второго уровня, организаций".
wrk1.cassp1 = "130".
wrk1.num2 = "33".
wrk1.vid2 = "Екінші деѕгейдегі банктердіѕ, ўйымдардыѕ операция кассасынан оныѕ касса бґлімшелеріне жјне басќа екінші деѕгейдегі банктерге, ўйымдарєа ќолма-ќол аќша беру
Выдачи наличных денег из операционной кассы банков второго уровня, организаций в его кассовые поздразделения и другим банкам второго уровня, организациям".
wrk1.cassp2 = "330".

create wrk1.
wrk1.num1 = "14".
wrk1.vid1 = "Ўлттыќ Банк филиалдарыныѕ айналым кассасына резервтік ќорлардан ќолма-ќол аќшаныѕ тїсуі
Поступления из резервных фондов в оборотную кассу филиалов Национального Банка".
wrk1.cassp1 = "140".
wrk1.num2 = "34".
wrk1.vid2 = "Ўлттыќ Банк филиалдарыныѕ айналым кассасынан резервтік ќорларєа ќолма-ќол аќша аудару
Перечисления наличных денег из оборотной кассы филиалов Национального Банка в резервные фонды".
wrk1.cassp2 = "340".

create wrk1.
wrk1.num1 = "57".
wrk1.vid1 = "БАЛАHС (символдар жиынтыєы 01-14=21-34)
(итог символов 01-14=21-34)".
wrk1.cassp1 = "".
wrk1.num2 = "58".
wrk1.vid2 = "БАЛАHС (символдар жиынтыєы 01-14=21-34)
(итог символов 01-14=21-34".
wrk1.cassp2 = "".


{r-brfilial.i &proc = "rep10CB1"}.

/* подведем итоги  */
def buffer b-wrk1 for wrk1.
find first wrk1 where wrk1.num1 = "55".
wrk1.sum1 = 0.
wrk1.sumtxb1 = 0.
for each b-wrk1 where int(b-wrk1.num1) >= 1 and int(b-wrk1.num1) <= 10.
    wrk1.sum1 =  wrk1.sum1 + b-wrk1.sum1.
    lll = 1.
    do while lll <= 17:
        wrk1.sumtxb1[lll] =  wrk1.sumtxb1[lll] + b-wrk1.sumtxb1[lll].
        lll = lll + 1.
    end.
end.
find first wrk1 where wrk1.num1 = "57".
wrk1.sum1 = 0.
wrk1.sumtxb1 = 0.
for each b-wrk1 where (int(b-wrk1.num1) >= 11 and int(b-wrk1.num1) <= 14).
    wrk1.sum1 =  wrk1.sum1 + b-wrk1.sum1.
    lll = 1.
    do while lll <= 17:
        wrk1.sumtxb1[lll] =  wrk1.sumtxb1[lll] + b-wrk1.sumtxb1[lll].
        lll = lll + 1.
    end.
end.
/* сложим суммы с 1 по 10 */
find first b-wrk1 where int(b-wrk1.num1) = 55.
wrk1.sum1 =  wrk1.sum1 + b-wrk1.sum1.
lll = 1.
do while lll <= 17:
    wrk1.sumtxb1[lll] =  wrk1.sumtxb1[lll] + b-wrk1.sumtxb1[lll].
    lll = lll + 1.
end.


find first wrk1 where wrk1.num2 = "56".
wrk1.sum2 = 0.
wrk1.sumtxb2 = 0.
for each b-wrk1 where int(b-wrk1.num2) >= 21 and int(b-wrk1.num2) <= 30.
    wrk1.sum2 =  wrk1.sum2 + b-wrk1.sum2.
    lll = 1.
    do while lll <= 17:
        wrk1.sumtxb2[lll] =  wrk1.sumtxb2[lll] + b-wrk1.sumtxb2[lll].
        lll = lll + 1.
    end.
end.

find first wrk1 where wrk1.num2 = "58".
wrk1.sum2 = 0.
wrk1.sumtxb2 = 0.
for each b-wrk1 where (int(b-wrk1.num2) >= 31 and int(b-wrk1.num2) <= 34).
    wrk1.sum2 =  wrk1.sum2 + b-wrk1.sum2.
    lll = 1.
    do while lll <= 17:
        wrk1.sumtxb2[lll] =  wrk1.sumtxb2[lll] + b-wrk1.sumtxb2[lll].
        lll = lll + 1.
    end.
end.
/* сложим суммы с 21 по 30 */
find first b-wrk1 where int(b-wrk1.num2) = 56.
wrk1.sum2 =  wrk1.sum2 + b-wrk1.sum2.
lll = 1.
do while lll <= 17:
    wrk1.sumtxb2[lll] =  wrk1.sumtxb2[lll] + b-wrk1.sumtxb2[lll].
    lll = lll + 1.
end.

/* вывод в тыс тенге   */
if v-select1 = 1 then do:
    for each wrk1.
        if wrk1.sum1 > 0 then wrk1.sum1 = wrk1.sum1 / 1000.
        if wrk1.sum2 > 0 then wrk1.sum2 = wrk1.sum2 / 1000.
        lll = 1.
        do while lll <= 17:
            if wrk1.sumtxb1[lll] > 0 then wrk1.sumtxb1[lll] = wrk1.sumtxb1[lll] / 1000.
            if wrk1.sumtxb2[lll] > 0 then wrk1.sumtxb2[lll] = wrk1.sumtxb2[lll] / 1000.
            lll = lll + 1.
        end.
    end.
end.


ch = ddd(vmonth).
if v-fil-int > 1 then v-fil-cnt = 'АО "ForteBank"'.



output stream v-out to a_rep.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr><TD colspan=6 align=right > Приложение № 11 </TD> </tr>" skip
         "<tr><TD colspan=6 align=right > к Инструкции о перечне, формах и сроках </TD> </tr>" skip
         "<tr><TD colspan=6 align=right > предоставления банками второго уровня и организациями, </TD> </tr>" skip
         "<tr><TD colspan=6 align=right > осуществляющих отдельные виды банковских операций, </TD> </tr>" skip
         "<tr><TD colspan=6 align=right > отчетности об основных видах деятельности </TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<h3>Форма № 11  Сводный отчет об оборотах наличных денег" "<br>"
                                    "(кассовые обороты) банков и организаций, осуществляющих"  "<br>"
                                    "отдельные виды банковских операций"  "<br>"
                                    v-fil-cnt "<br>"
                                    "за " ch "   " vyear " года " "</h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD colspan=6 align=right > в " v-raz "</TD> </tr>"  skip.
    put stream v-out unformatted
         "<tr><TD colspan=3 align=center > Приход наличных денег </TD>"   skip
         "<TD colspan=3 align=center > Расход наличных денег </TD>"   skip.
         if v-fil-int > 1 then do:
            for each txb where txb.bank begins "txb" no-lock.
                put stream v-out unformatted "<TD colspan=2 align=center >" txb.info "</TD>" skip.
            end.
         end.
    put stream v-out unformatted "</tr>" skip.
         put stream v-out unformatted "<tr><TD align=center > Символ </TD>"   skip
         "<TD align=center > Статьи </TD>"   skip
         "<TD align=center > Сумма </TD>"   skip
         "<TD align=center > Символ </TD>"   skip
         "<TD align=center > Статьи </TD>"   skip
         "<TD align=center > Сумма </TD>" skip.
    if v-fil-int > 1 then do:
        for each txb where txb.bank begins "txb" no-lock.
            put stream v-out unformatted "<TD align=center > сумма <br> приход </TD>" skip.
            put stream v-out unformatted "<TD align=center > сумма <br> расход </TD>" skip.
        end.
    end.
    put stream v-out unformatted "</tr>" skip.

    for each wrk1 .
        if wrk1.num1 = "55" or wrk1.num1 = "57" then put stream v-out  unformatted "<TR> <TD><align=""left"">"  "</TD>" skip.
        else put stream v-out  unformatted "<TR> <TD><align=""left"">" wrk1.num1 "</TD>" skip.
        put stream v-out  unformatted "<TD align=""left"">" wrk1.vid1 "</TD>" skip
        "<TD align=""right"">" replace(trim(string(wrk1.sum1,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
        if wrk1.num2 = "56" or wrk1.num2 = "58" then put stream v-out  unformatted "<TD><align=""left"">"  "</TD>" skip.
        else put stream v-out  unformatted "<TD><align=""left"">" wrk1.num2 "</TD>" skip.
        put stream v-out  unformatted "<TD align=""left"">" wrk1.vid2 "</TD>" skip
        "<TD align=""right"">" replace(trim(string(wrk1.sum2,'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.

        if v-fil-int > 1 then do:
            lll = 1.
            do while lll <= 17:
                put stream v-out unformatted "<TD align=center >" replace(trim(string(wrk1.sumtxb1[lll],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                                             "<TD align=center >" replace(trim(string(wrk1.sumtxb2[lll],'->>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
                lll = lll + 1.
            end.
        end.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>".

    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
        "<tr> </tr>" skip
        "<tr> </tr>" skip
        "<tr> </tr>" skip
        "<tr> </tr>" skip
        "<tr> </tr>" skip
        "<tr> </tr>" skip
        "<tr> </tr>" skip
         "<tr><TD colspan=6 align=left > Председатель Правления________________ _________________ </TD> </tr>" skip
         "<tr><TD colspan=6 align=left > Главный бухгалтер__________________ ____________________ </TD> </tr>" skip
         "<tr><TD colspan=6 align=left > Исполнитель:  </TD> </tr>" skip
         "</table>"  skip.

    output stream v-out close.
    unix silent value("cptwin a_rep.html excel").
    hide message no-pause.

if v-ful then do:
    def stream m-out.
    output stream m-out to r-gl.htm.

    put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    find first cmp no-lock no-error.
    put stream m-out unformatted "<br><br>" cmp.name "<br>" skip.

    for each wrk no-lock break by wrk.gl by wrk.crc by wrk.bank :
        /*if first-of(wrk.bank) then do:
            put stream m-out unformatted "<br><br>" wrk.bankn "<br><br>" skip.
        end.*/
        if first-of(wrk.gl) then do:
            put stream m-out unformatted "<br>" "ОБОРОТЫ ПО СЧЕТУ " + string(wrk.gl).
            find first gl where gl.gl = wrk.gl no-lock no-error.
            if avail gl then do:
                v-aktiv = if can-do('A,O,E',gl.type) then true else false.
                put stream m-out unformatted " " + gl.des.
            end.
            put stream m-out unformatted
                "<br>" skip
                "ЗА ПЕРИОД С " v-from " ПО " v-to "<br>" skip.
        end.
        if first-of(wrk.crc) then do:
            assign v-tdam      = 0
                   v-tcam      = 0
                   v-tdam_KZT  = 0
                   v-tcam_KZT  = 0
                   v-tdam1     = 0
                   v-tcam1     = 0
                   v-tdam_KZT1 = 0
                   v-tcam_KZT1 = 0.
            put stream m-out unformatted "<br>Валюта: " + wrk.crc_code + "<br>" skip.
            put stream m-out unformatted
                "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                "<tr><td colspan=7>Входящий остаток </td>" skip.

            for each wrk_ost where /*wrk_ost.bank = wrk.bank and*/ wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
                accum wrk_ost.dam_in (total by wrk_ost.gl) wrk_ost.cam_in (total by wrk_ost.gl) wrk_ost.dam_in_KZT (total by wrk_ost.gl) wrk_ost.cam_in_KZT (total by wrk_ost.gl).
                if last-of(wrk_ost.gl) then
                put stream m-out unformatted
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_in_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
            end.

            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
            put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                      "<tr style=""font:bold"">"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дата</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Филиал</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Транз</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК Наим</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Корр Счет</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Валюта</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Дт_KZT</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кт_KZT</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примеч</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ID</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК2</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КоррГК Наим2</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Корр Счет2</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Код</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Кбе</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">КНП</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство <br> КоррГК</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Резидентство <br> КоррГК2</td>"
                      "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Символ <br> кассплана </td>"

                      "</tr>" skip.
        end.

        put stream m-out unformatted
                  "<tr>"
                  "<td>" wrk.jdt "</td>"
                  "<td>" wrk.bankn "</td>"
                  "<td>" wrk.jh "</td>"
                  "<td>" wrk.glcorr "</td>"
                  "<td>" wrk.glcorr_des "</td>"
                  "<td>&nbsp;" wrk.acc_corr "</td>"
                  "<td>" wrk.crc_code "</td>"
                  "<td>" replace(trim(string(wrk.dam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(wrk.cam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(wrk.dam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(wrk.cam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" wrk.rem "</td>"
                  "<td>" wrk.who "</td>"
                  "<td>" wrk.glcorr2 "</td>"
                  "<td>" wrk.glcorr_des2 "</td>"
                  "<td>" wrk.acc2 "</td>"
                  "<td>" wrk.cod "</td>"
                  "<td>" wrk.kbe "</td>"
                  "<td>" wrk.knp "</td>"
                  "<td align=""center"">" wrk.rez "</td>"
                  "<td align=""center"">" wrk.rez1 "</td>"
                  "<td align=""center"">" wrk.cassp "</td>"
                  "</tr>" skip.

        v-tdam = v-tdam + wrk.dam. v-tcam = v-tcam + wrk.cam.
        v-tdam_KZT = v-tdam_KZT + wrk.dam_KZT. v-tcam_KZT = v-tcam_KZT + wrk.cam_KZT.
        if v-td and wrk.jdt = g-today
        then assign
            v-tdam1 = v-tdam1 + wrk.dam
            v-tcam1 = v-tcam1 + wrk.cam
            v-tdam_KZT1 = v-tdam_KZT1 + wrk.dam_KZT
            v-tcam_KZT1 = v-tcam_KZT1 + wrk.cam_KZT.

        if last-of(wrk.crc) then do:
            put stream m-out unformatted
                  "<tr>"
                  "<td colspan=7>ИТОГО ОБОРОТЫ</td>"
                  "<td>" replace(trim(string(v-tdam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(v-tcam,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(v-tdam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td>" replace(trim(string(v-tcam_KZT,">>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                  "<td></td>"
                  "<td></td>"
                  "</tr>" skip.
            put stream m-out unformatted "</table><br>" skip.
            put stream m-out unformatted
                "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                "<tr><td colspan=7>Исходящий остаток </td>" skip.
            for each wrk_ost where /*wrk_ost.bank = wrk.bank and*/ wrk_ost.gl = wrk.gl and wrk_ost.crc = wrk.crc no-lock break by wrk_ost.gl.
                accum wrk_ost.dam_out (total by wrk_ost.gl) wrk_ost.cam_out (total by wrk_ost.gl) wrk_ost.dam_out_KZT (total by wrk_ost.gl) wrk_ost.cam_out_KZT (total by wrk_ost.gl).
                if last-of(wrk_ost.gl) then do:
                    if v-aktiv then
                    put stream m-out unformatted
                    "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out)  + v-tdam1 - v-tcam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT) + v-tdam_kzt1 - v-tcam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                    else
                    put stream m-out unformatted
                    "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out) + v-tcam1 - v-tdam1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string(accum total by (wrk_ost.gl) wrk_ost.dam_out_KZT,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>"
                    "<td>" replace(trim(string((accum total by (wrk_ost.gl) wrk_ost.cam_out_KZT) + v-tcam_kzt1 - v-tdam_kzt1,"->>>>>>>>>>>>>>9.99")),'.',',') "</td>".
                end.
            end.

            put stream m-out unformatted "</tr></table>" skip.
            put stream m-out unformatted "<br>" skip.
        end.
    end.

    output stream m-out close.
    unix silent cptwin r-gl.htm excel.



end.

return.
