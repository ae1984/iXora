/* rep9PB.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет о состоянии финансовых требований к нерезидентам и обязательств перед ними
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
        28/12/2012 Luiza
 * CHANGES
*/


{mainhead.i}

def new shared var vasof_f as date no-undo.
def new shared var vasof as date no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def new shared var v-ful as logic format "да/нет" no-undo.

def stream v-out.
def stream v-ost.
def stream v-sal.
def stream v-ostin.
def stream v-cng.
def stream v-ru.
def var prname as char.
def new shared var v-select1 as int no-undo.
def var v-ful1 as int no-undo.


displ vasof_f label   " С " format "99/99/9999" validate(vasof_f < g-today, "Некорректная дата!") skip
      vasof label   " По" format "99/99/9999" validate(vasof < g-today and vasof > vasof_f, "Некорректная дата!") skip
      v-ful label " С расшифровкой" skip
with side-label row 4 centered frame dat.

update vasof_f with frame dat.
update vasof v-ful with frame dat.

v-ful1 = 0.
if v-ful then do:
    /*run sel2 (" Выберите ", "1. Все |2. Обороты |3. Остатки |4. Доходы/Расходы |5. Остатки доходы/расходы |6. ВЫХОД ", output v-ful1).*/
    run sel2 (" Выберите ", "1. Все |2. Обороты |3. Остатки |4. Доходы/Расходы |5. ВЫХОД ", output v-ful1).
    if keyfunction (lastkey) = "end-error" or v-ful1 = 5 then return.
end.

v-select1 = 0.
def var v-raz as char  no-undo.

run sel2 (" Выберите ", "1. В тыс.долл.США |2. В долл.США |3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "тыс.долл.США". else v-raz = "долл.США".

function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.

define new shared temp-table wrk1 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk1.
    wrk1.num = "10".
    wrk1.vid = "Наличная иностранная валюта".
    wrk1.str1 = "10012,10022,10032,10042,10052".
    create wrk1.
    wrk1.num = "20".
    wrk1.vid = "Чеки и другие платежные документы, выпущенные нерезидентами".
    /*wrk1.str1 = "10062,10082".*/
    create wrk1.
    wrk1.num = "30".
    wrk1.vid = "Корреспондентские счета в банках- нерезидентах".
    wrk1.str1 = "10522".
    wrk1.str2 = "17052".
    create wrk1.
    wrk1.num = "40".
    wrk1.vid = "Краткосрочные (не более 1 года)  депозиты, размещенные в банках - нерезидентах ".
    /*wrk1.str1 = "10132,12512,12522,12532,12542,12562,12642,12672".
    wrk1.str2 = "172524,17272,172824".*/
    create wrk1.
    wrk1.num = "50".
    wrk1.vid = "Долгосрочные (более 1 года) депозиты в банках- нерезидентах ".
    /*wrk1.str1 = "12552".
    wrk1.str2 = "172524".*/

define new shared temp-table wrk2 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field crc as int
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk2.
    wrk2.num = "60".
    wrk2.vid = "Ценные бумаги  объектов прямого инвестирования  банком".
    /*wrk2.str1 = "14712,14722,14732".
    wrk2.str2 = "17472,17712".*/
    create wrk2.
    wrk2.num = "61".
    wrk2.vid = "простые акции ".
    create wrk2.
    wrk2.num = "62".
    wrk2.vid = "привилегированные акции".
    create wrk2.
    wrk2.num = "63".
    wrk2.vid = "прочие ценные бумаги".
    create wrk2.
    wrk2.num = "70".
    wrk2.vid = "Ценные бумаги прямых инвесторов банка".
    create wrk2.
    wrk2.num = "71".
    wrk2.vid = "простые акции ".
    create wrk2.
    wrk2.num = "72".
    wrk2.vid = "привилегированные акции".
    create wrk2.
    wrk2.num = "73".
    wrk2.vid = "прочие ценные бумаги".
    create wrk2.
    wrk2.num = "80".
    wrk2.vid = "Ценные бумаги прямых инвесторов банка".
    create wrk2.
    wrk2.num = "81".
    wrk2.vid = "простые акции ".
    create wrk2.
    wrk2.num = "82".
    wrk2.vid = "привилегированные акции".
    create wrk2.
    wrk2.num = "83".
    wrk2.vid = "прочие ценные бумаги".

define new shared temp-table wrk3 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field crc as int
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk3.
    wrk3.num = "90".
    wrk3.vid = "Ценные бумаги (облигации, ноты и др.),  обращаю-щиеся депозитные сертификаты  со  сроком пога-шения более 1 года".
    create wrk3.
    wrk3.num = "91".
    wrk3.vid = "из них выпущенные: органами госуправления".
    /*wrk3.str1 = "12012,14052,14062,14252,14522,14812,(-) 1205000, 1206000, 1208000, 1209000, (-)1432000, 1433000, (-)1453000, 1454000, 1456000, 1457000, (-)1482000, 1483000, 1484000".
    wrk3.str2 = "1744,1745,1746,1752".*/
    create wrk3.
    wrk3.num = "92".
    wrk3.vid = "предприятиями специального назначения".
    /*wrk3.str1 = "12012,14052,14062,14252,14522,14812,(-) 1205000, 1206000, 1208000, 1209000, (-)1432000, 1433000, (-)1453000, 1454000, 1456000, 1457000, (-)1482000, 1483000, 1484000".
    wrk3.str2 = "1744,1745,1746,1752".*/
    create wrk3.
    wrk3.num = "100".
    wrk3.vid = "Инструменты денежного рынка (казначейские векселя, коммерческие бумаги, обращающиеся депозитные сертификаты, ноты и др.) со сроком".
    /*wrk3.str1 = "12012,14052,14062,14252,14522,14812,1205000,1206000,1208000,1209000,1432000,1433000,1453000,1454000,1456000,1457000,1482000,1483000,1484000".
    wrk3.str2 = "17442,17452,17462,17522".*/
    create wrk3.
    wrk3.num = "110".
    wrk3.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)".
    wrk3.str1 = "18942".  /*"17532,18912,18922,18932,18942,18952,18992".*/

define new shared temp-table wrk4 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk4.
    wrk4.num = "120".
    wrk4.vid = 'Операции "обратное  РЕПО"'.
   /* wrk4.str1 = "14612".
    wrk4.str2 = "17482".*/
    create wrk4.
    wrk4.num = "130".
    wrk4.vid = "Краткосрочные (не более 1 года)  ссуды".
    /*wrk4.str1 = "13012,130224,130324,132125,132225,14012,14032,14072,14112,14222,14292,14262".
    wrk4.str2 = "17302,173325,17402".*/
    create wrk4.
    wrk4.num = "140".
    wrk4.vid = "Финансовый лизинг".
    /*wrk4.str1 = "130524,132625,14202".
    wrk4.str2 = "17302,173325,17402".*/
    create wrk4.
    wrk4.num = "150".
    wrk4.vid = "Долгосрочные (более 1 года)  ссуды".
    /*wrk4.str1 = "130424, 132325, 14172, 14752".
    wrk4.str2 = "17302,173325,17402,17472,17712".*/

define new shared temp-table wrk5 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk5.
    wrk5.num = "160".
    wrk5.vid = "Прочие инвестиции в капитал".
    /*wrk5.str1 = "14762".
    wrk5.str2 = "17472".*/
    create wrk5.
    wrk5.num = "200".
    wrk5.vid = "Предоплата вознаграждения и расходов".
    /*wrk5.str1 = "17922,17992".
    wrk5.str2 = "".*/
    create wrk5.
    wrk5.num = "210".
    wrk5.vid = "Просроченная задолженность  по выданным кредитам и депозитам".
    /*wrk5.str1 = "12022,12572,13062,130924,132725,132825,14092,14212,14232,14242,14272,14592,14622,14852,17262,17312,173425,
                17412,17492,17502,17722,1831200,1833200,1834200,1835200,1836200,1837200,1838200,1839200,1840200,1841200,1842200,1843200,1844200".
    wrk5.str2 = "".*/
    create wrk5.
    wrk5.num = "220".
    wrk5.vid = "Блокированная задолженность  по выданным кредитам и депозитам".
    wrk5.str1 = "".
    wrk5.str2 = "".
    create wrk5.
    wrk5.num = "230".
    wrk5.vid = "Прочая задолженность дебиторов".
    wrk5.str1 = "1860".
    /*wrk5.str1 = "10072,10092,14452,15512,15522,16042,1793000,185121,18522,18552,18562,18602,18612,18642,18672,18702,18792,18802".
    wrk5.str2 = "17552,17562".*/


define new shared temp-table wrk6 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk6.
    wrk6.num = "240".
    wrk6.vid = "Корреспондентские счета  банков- нерезидентов".
    wrk6.str1 = "20132". /*"201223,201324,201425,222124".*/
    wrk6.str2 = "27012,272624".
    create wrk6.
    wrk6.num = "250".
    wrk6.vid = "Депозиты до востребования и текущие счета".
    /*wrk6.str1 = "22032,22042,22052,22092".
    wrk6.str2 = "2718,2720,2726".*/
   create wrk6.
    wrk6.num = "251".
    wrk6.vid = "юридических лиц (кроме банков, посольств иностранных государств и представительств международных организаций)".
    wrk6.str1 = "22032". /*"22032,22112,222121,222122,222125,222126,222127,222128".*/
    /*wrk6.str2 = "271821,271822,271825,271826,271827,271828,272021,272022,272025,272026,272027,272028,272621,272622,272625,272626,272627,272628".*/
    create wrk6.
    wrk6.num = "253".
    wrk6.vid = "филиалов и представительств юридических лиц (кроме посольств иностранных государств и представительств международных организаций),                                                          осуществляющих деятельность в РК".
    /*wrk6.str1 = "22032".*/
    /*wrk6.str1 = "22032,22112,222121,222122,222125,222126,222127,222128".
    wrk6.str2 = "271821,271822,271825,271826,271827,271828,272021,272022,272025,272026,272027,272028,272621,272622,272625,272626,272627,272628".
    */
    create wrk6.
    wrk6.num = "255".
    wrk6.vid = "физических лиц".
    wrk6.str1 = "22042,22052,22092".
    /*wrk6.str1 = "22042,22052". */ /*"220429,220529,220929".*/
    /*wrk6.str2 = "271829,272029,272629".*/
    create wrk6.
    wrk6.num = "257".
    wrk6.vid = "посольств иностранных государств и представительств международных организаций".
    /*wrk6.str1 = "22032,22112,222121,222122,222125,222126,222127,222128".
    wrk6.str2 = "271821,271822,271825,271826,271827,271828,272021,272022,272025,
                 272026,272027,272028,272621,272622,272625,272626,272627,272628".*/
    create wrk6.
    wrk6.num = "258".
    wrk6.vid = "из них: посольств иностранных государств и представительств международных организаций (стран не СНГ)".
    /*wrk6.str1 = "22032,22112,222121,222122,222125,222126,222127,222128".
    wrk6.str2 = "271821,271822,271825,271826,271827,271828,272021,272022,272025,
                 272026,272027,272028,272621,272622,272625,272626,272627,272628".*/
    create wrk6.
    wrk6.num = "260".
    wrk6.vid = "Краткосрочные (не более 1 года)  депозиты".
    /*wrk6.str1 = "22062".
    wrk6.str2 = "5215".*/
    create wrk6.
    wrk6.num = "261".
    wrk6.vid = "банков - нерезидентов".
    /*wrk6.str1 = "202223,202324,212223,212324,212424,212524,213324".
    wrk6.str2 = "27022,27122,271424".*/
    create wrk6.
    wrk6.num = "263".
    wrk6.vid = "юридических лиц (кроме банков) и филиалов и представительств юридических лиц, осуществляющих деятельность в РК	".
    /*wrk6.str1 = "22152,22192".
    wrk6.str2 = "27022,27122,271424".*/
    create wrk6.
    wrk6.num = "267".
    wrk6.vid = "физических лиц".
    wrk6.str1 = "22062". /*"220629,220829".*/
    /*wrk6.str2 =   "271929,272129".*/
    create wrk6.
    wrk6.num = "270".
    wrk6.vid = "Долгосрочные (более 1 года)  депозиты ".
    /*wrk6.str1 = "22072".
    wrk6.str2 = "5217".*/
    create wrk6.
    wrk6.num = "271".
    wrk6.vid = "банков - нерезидентов".
    /*wrk6.str1 = "212223,212724".
    wrk6.str2 = "27122".*/
    create wrk6.
    wrk6.num = "272".
    wrk6.vid = "юридических лиц (кроме банков) и филиалов и представительств юридических лиц, осуществляющих деятельность в РК".
    /*wrk6.str1 = "22172".
    wrk6.str2 = "272121,272122,272125,272126,272127,272128".*/
    create wrk6.
    wrk6.num = "273".
    wrk6.vid = "физических лиц ".
    wrk6.str1 = "22072".  /*"220729".*/
    wrk6.str2 = "27212,27072".
    create wrk6.
    wrk6.num = "280".
    wrk6.vid = 'Операции "РЕПО"'.
    wrk6.str1 = "225529".
    wrk6.str2 = "272529".
    create wrk6.
    wrk6.num = "282".
    wrk6.vid = "Прочие депозиты клиентов-нерезидентов".
    wrk6.str1 = "24022". /*"201624,212624,213024,21312,22122,221329,22162,22232,22402,22452".*/
    wrk6.str2 = "27402". /*,27082,271324,27172,27232".*/

define new shared temp-table wrk7 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk7.
    wrk7.num = "290".
    wrk7.vid = "Находящиеся у прямых инвесторов банка".
    wrk7.str1 = "".
    wrk7.str2 = "".

    create wrk7.
    wrk7.num = "291".
    wrk7.vid = "простые акции".
    /*wrk7.str1 = "часть 3001 минус часть 3003 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "292".
    wrk7.vid = "привилегированные акции".
    /*wrk7.str1 = "часть 3025 минус часть 3027 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "293".
    wrk7.vid = "прочие ценные бумаги".
    /*wrk7.str1 = "".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "300".
    wrk7.vid = "Находящиеся у  объектов прямого инвестирования  банком	".
    /*wrk7.str1 = "".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "301".
    wrk7.vid = "простые акции".
    /*wrk7.str1 = "часть 3001 минус часть 3003 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "302".
    wrk7.vid = "привилегированные акции".
    /*wrk7.str1 = "часть 3025 минус часть 3027 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "303".
    wrk7.vid = "прочие ценные бумаги".
    /*wrk7.str1 = "".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "310".
    wrk7.vid = "Находящиеся у прочих нерезидентов".
    /*wrk7.str1 = "часть 3001 минус часть 3003 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "311".
    wrk7.vid = "простые акции".
    /*wrk7.str1 = "часть 3025 минус часть 3027 плюс часть 3101".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "312".
    wrk7.vid = "привилегированные акции".
    /*wrk7.str1 = "".
    wrk7.str2 = "часть 3580000, 3599000".*/
    create wrk7.
    wrk7.num = "313".
    wrk7.vid = "прочие ценные бумаги".
    /*wrk7.str1 = "".
    wrk7.str2 = "часть 3580000, 3599000".*/


define new shared temp-table wrk8 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk8.
    wrk8.num = "320".
    wrk8.vid = "Ценные бумаги (облигации, ноты и др.),  обращаю-щиеся депозитные сертификаты  со  сроком пога-шения более 1 года".
    /*wrk8.str1 = "23012**, 23032**, (-) 23062**, (-) 24052**, 24062**, часть по ЦБ, находящимся у нерезидентов: 2304000, (-) 2305000, 2403000, (-) 2404000,часть 24512** (в части бессрочных ЦБ)".
    wrk8.str1 = "27302**, 27562**, часть 27572** (в части бессрочных ЦБ)".*/
    create wrk8.
    wrk8.num = "330".
    wrk8.vid = "Инструменты денежного рынка (казначейские векселя, коммерческие бумаги, обращающиеся депозитные сертификаты, ноты и др.) со сроком  погашения не более 1 года".
    /*wrk8.str1 = "23012**, 23032**, (-) 23062**, (-) 24052**, 24062**, часть по ЦБ, находящимся у нерезидентов: 2304000, (-) 2305000, 2403000, (-) 2404000,часть 24512** (в части бессрочных ЦБ)".
    wrk8.str1 = "27302**, 27562**, часть 27572** (в части бессрочных ЦБ)".*/
    create wrk8.
    wrk8.num = "350".
    wrk8.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)".
    wrk8.str1 = "27272,28912,28922,28932,28942,28952,28992".
    wrk8.str1 = "".

define new shared temp-table wrk9 no-undo
    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim extent 12 format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk9.
    wrk9.num = "400".
    wrk9.vid = "Прочие инвестиции в капитал  банка".
    wrk9.str1 = "".
    wrk9.str2 = "".
    create wrk9.
    wrk9.num = "450".
    wrk9.vid = "Просроченная  задолженность по кредитам и депозитам, включая просроченное вознаграждение".
    wrk9.str1 = "20242,21352,213824,22242,22252,22262,22282,22322,27422,27432,27442,27462,27472,27482,27492,2831200,2833200,2834200,2835200,
    2836200,2838200,2839200".
    wrk9.str2 = "".
    create wrk9.
    wrk9.num = "460".
    wrk9.vid = "Прочая  задолженность кредиторам	".
    wrk9.str1 = "2551". /*"22102,22372,25512,25522,27922,27932,27702,27992,28522,28552,28532,28562,28602,28622,28632,28642,28672,28682,28692,28702,28712,28802".*/
    wrk9.str2 = "27312,27552,27942".

define new shared temp-table wrk10 no-undo

    field num as char
    field vid as char
    field str1 as char
    field str2 as char
    field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

    create wrk10.
    wrk10.num = "470".
    wrk10.vid = "1.Поступления от нерезидентов".
    create wrk10.
    wrk10.num = "471".
    wrk10.vid = "доходы в виде вознаграждения по размещенным депозитам (факт)".
    wrk10.str1 = "4052,4251,4252,4253,4254,4255,4256,4257".
    create wrk10.
    wrk10.num = "472".
    wrk10.vid = "доходы в виде вознаграждения по выданным кредитам (факт)".
    wrk10.str1 = "4301,4302,4303,4304,4305,4306,4321,4322,4323,4326,4327,4328,4401,44403,4405,4407,4411,4417,4420,4422,4424,4426,4427,4428,4465".
    create wrk10.
    wrk10.num = "473".
    wrk10.vid = "доходы по инвестициям в капитал	".
    wrk10.str1 = "4470,4471,4472,4475,4476".
    create wrk10.
    wrk10.num = "474".
    wrk10.vid = "прочие доходы от ценных бумаг".
    wrk10.str1 = "4201,4202,4452,4453,4481,4482".
    create wrk10.
    wrk10.num = "475".
    wrk10.vid = "комиссионные доходы".
    wrk10.str1 = "4601,4602,4603,4607,4605,4606,4607,4608,4609,4610,4611,4612,4613,4614,4615,4616,4617,4618".
    create wrk10.
    wrk10.num = "476".
    wrk10.vid = "прочие поступления".
    wrk10.str1 = "".
    create wrk10.
    wrk10.num = "480".
    wrk10.vid = "2. Платежи нерезидентам:".
    wrk10.str1 = "".
    create wrk10.
    wrk10.num = "481".
    wrk10.vid = "расходы в виде вознаграждения по полученным  депозитам (факт)".
    wrk10.str1 = "5022,5023,5024,5123,5124,5125,5126,5127,5129,5130,5133,5203,5211,5212,5215,5216,5217,5219,5221,5222,5223,5224,5226,5229".
    create wrk10.
    wrk10.num = "482".
    wrk10.vid = "расходы по аудиту и консультационным услугам".
    wrk10.str1 = "5750".
    create wrk10.
    wrk10.num = "483".
    wrk10.vid = "распределенный чистый доход  и дивиденды".
    wrk10.str1 = "".
    create wrk10.
    wrk10.num = "484".
    wrk10.vid = "прочие расходы по выпущенным ценным  бумагам".
    wrk10.str1 = "5301,5303,5307,5401,5402,5404,5406".
    create wrk10.
    wrk10.num = "485".
    wrk10.vid = "комиссионные расходы".
    wrk10.str1 = "5601,5602,5603,5604,5605,5606,5607,5608,5609".
    create wrk10.
    wrk10.num = "486".
    wrk10.vid = "налоги".
    wrk10.str1 = "5761,5762,5763,5764,5765,5766,5767,5768".
    create wrk10.
    wrk10.num = "487".
    wrk10.vid = "прочие выплаты".
    wrk10.str1 = "".

/* для СНГ */
    define new shared temp-table wrk15 no-undo /*Раздел I. Требования к  нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk15.
        wrk15.num = "490".
        wrk15.vid = "Наличная валюта стран СНГ".
        create wrk15.
        wrk15.num = "500".
        wrk15.vid = "Корреспондентские счета в банках  стран СНГ".
        create wrk15.
        wrk15.num = "510".
        wrk15.vid = "Краткосрочные (не более 1 года) депозиты в банках стран СНГ".
        create wrk15.
        wrk15.num = "520".
        wrk15.vid = "Долгосрочные (более 1 года)  депозиты в банках стран СНГ".
        create wrk15.
        wrk15.num = "530".
        wrk15.vid = "Акции и другие ценные бумаги нерезидентов, обеспечивающие участие в капитале".
        create wrk15.
        wrk15.num = "531".
        wrk15.vid = "из них: объектов прямого инвестирования  банком".
        create wrk15.
        wrk15.num = "532".
        wrk15.vid = "прямых инвесторов банка	".
        create wrk15.
        wrk15.num = "540".
        wrk15.vid = "Долговые ценные бумаги, выпущенные нерезидентами".
        create wrk15.
        wrk15.num = "541".
        wrk15.vid = "из них: со сроком погашения  более 1 года ".
        create wrk15.
        wrk15.num = "542".
        wrk15.vid = "выпущенные органами госуправления  стран СНГ  ".
        create wrk15.
        wrk15.num = "545".
        wrk15.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)".
        create wrk15.
        wrk15.num = "550".
        wrk15.vid = "Ссуды, выданные нерезидентам (включая 'обратное РЕПО')".
        create wrk15.
        wrk15.num = "551".
        wrk15.vid = "из них со сроком погашения более 1 года  ".
        create wrk15.
        wrk15.num = "560".
        wrk15.vid = "Финансовый лизинг нерезидентам ".
        create wrk15.
        wrk15.num = "570".
        wrk15.vid = "Прочие требования к нерезидентам ".
        create wrk15.
        wrk15.num = "571".
        wrk15.vid = "прочие инвестиции в капитал".
        create wrk15.
        wrk15.num = "573".
        wrk15.vid = "просроченная задолженность  по выданным кредитам и депозитам".
        create wrk15.
        wrk15.num = "574".
        wrk15.vid = "блокированная задолженность  по выданным кредитам и депозитам".
        create wrk15.
        wrk15.num = "575".
        wrk15.vid = "прочая  задолженность дебиторов".

    define new shared temp-table wrk16 no-undo /*Раздел II. Обязательства  банка перед нерезидентами*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk16.
        wrk16.num = "580".
        wrk16.vid = "Корреспондентские счета  банков стран СНГ".
        create wrk16.
        wrk16.num = "590".
        wrk16.vid = "Краткосрочные (не более 1 года)  депозиты банков стран СНГ ".
        create wrk16.
        wrk16.num = "600".
        wrk16.vid = "Депозиты до востребования, текущие счета и краткосрочные (не более 1 года) депозиты".
        create wrk16.
        wrk16.num = "601".
        wrk16.vid = "юридических лиц (кроме банков) и филиалов и представительств юридических лиц, осуществляющих деятельность в РК	".
        create wrk16.
        wrk16.num = "603".
        wrk16.vid = "физических лиц".
        create wrk16.
        wrk16.num = "610".
        wrk16.vid = "Долгосрочные (более 1 года)  депозиты ".
        create wrk16.
        wrk16.num = "611".
        wrk16.vid = "банков стран СНГ".
        create wrk16.
        wrk16.num = "612".
        wrk16.vid = "юридических лиц (кроме банков)  и филиалов и представительств юридических лиц, осуществляющих деятельность в РК	".
        create wrk16.
        wrk16.num = "613".
        wrk16.vid = "физических лиц".
        create wrk16.
        wrk16.num = "620".
        wrk16.vid = "Операции 'РЕПО'  с нерезидентами".
        create wrk16.
        wrk16.num = "630".
        wrk16.vid = "Прочие депозиты клиентов-нерезидентов".
        create wrk16.
        wrk16.num = "640".
        wrk16.vid = "Акции и другие ценные бумаги  банка, обеспечивающие участие в капитале и находящиеся у  нерезидентов".
        create wrk16.
        wrk16.num = "641".
        wrk16.vid = "из них: объектов прямого инвестирования  банком".
        create wrk16.
        wrk16.num = "642".
        wrk16.vid = "прямых инвесторов банка".
        create wrk16.
        wrk16.num = "650".
        wrk16.vid = "Долговые ценные бумаги выпущенные  банком, находящиеся у нерезидентов".
        create wrk16.
        wrk16.num = "651".
        wrk16.vid = "из них со сроком погашения более 1 года".
        create wrk16.
        wrk16.num = "660".
        wrk16.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)".
        create wrk16.
        wrk16.num = "680".
        wrk16.vid = "Прочие обязательства перед нерезидентами".
        create wrk16.
        wrk16.num = "681".
        wrk16.vid = "прочие инвестиции в капитал  банка".
        create wrk16.
        wrk16.num = "683".
        wrk16.vid = "просроченная  задолженность по кредитам и депозитам, включая просроченное вознаграждение".
        create wrk16.
        wrk16.num = "684".
        wrk16.vid = "прочая  задолженность кредиторам".

    define new shared temp-table wrk17 no-undo /* Поступления от нерезидентов*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk17.
        wrk17.num = "690".
        wrk17.vid = "Доходы в виде вознаграждения по размещенным депозитам и выданным кредитам (факт)".
        wrk17.numo = "471".
        create wrk17.
        wrk17.num = "700".
        wrk17.vid = "Доходы по инвестициям в капитал".
        wrk17.numo = "473".
        create wrk17.
        wrk17.num = "710".
        wrk17.vid = "Прочие доходы от ценных бумаг".
        wrk17.numo = "474".
        create wrk17.
        wrk17.num = "720".
        wrk17.vid = "Прочие поступления".
        wrk17.numo = "476".

    define new shared temp-table wrk18 no-undo /*Платежи нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk18.
        wrk18.num = "725".
        wrk18.vid = "Расходы в виде вознаграждения по полученным кредитам и депозитам (факт)".
        wrk18.numo = "481".
        create wrk18.
        wrk18.num = "730".
        wrk18.vid = "Расходы по аудиту и консультационным услугам".
        wrk18.numo = "482".
        create wrk18.
        wrk18.num = "740".
        wrk18.vid = "Распределенный чистый доход  и дивиденды".
        wrk18.numo = "483".
        create wrk18.
        wrk18.num = "750".
        wrk18.vid = "Прочие расходы по ценным  бумагам".
        wrk18.numo = "484".
        create wrk18.
        wrk18.num = "760".
        wrk18.vid = "Налоги".
        wrk18.numo = "486".
        create wrk18.
        wrk18.num = "770".
        wrk18.numo = "487".
        wrk18.vid = "Прочие выплаты".

/* для России */
    define new shared temp-table wrk11 no-undo /*Раздел I. Требования к  нерезидентам*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk11.
        wrk11.num = "780".
        wrk11.vid = "Наличные российские рубли".
        create wrk11.
        wrk11.num = "790".
        wrk11.vid = "Корреспондентские счета в банках  России".
        create wrk11.
        wrk11.num = "800".
        wrk11.vid = "Краткосрочные (не более 1 года) депозиты в банках  России".
        create wrk11.
        wrk11.num = "810".
        wrk11.vid = "Долгосрочные (более 1 года)  депозиты в банках России".
        create wrk11.
        wrk11.num = "820".
        wrk11.vid = "Акции и другие ценные бумаги нерезидентов, обеспечивающие участие в капитале".
        create wrk11.
        wrk11.num = "821".
        wrk11.vid = "из них: объектов прямого инвестирования  банком".
        create wrk11.
        wrk11.num = "".
        wrk11.vid = "прямых инвесторов банка	822".
        create wrk11.
        wrk11.num = "830".
        wrk11.vid = "Долговые ценные бумаги, выпущенные нерезидентами".
        create wrk11.
        wrk11.num = "831".
        wrk11.vid = "из них: со сроком погашения  более 1 года ".
        create wrk11.
        wrk11.num = "832".
        wrk11.vid = "выпущенные органами госуправления  России".
        create wrk11.
        wrk11.num = "835".
        wrk11.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)".
        create wrk11.
        wrk11.num = "840".
        wrk11.vid = "Ссуды, выданные нерезидентам (включая 'обратное РЕПО')".
        create wrk11.
        wrk11.num = "841".
        wrk11.vid = "из них со сроком погашения более 1 года".
        create wrk11.
        wrk11.num = "850".
        wrk11.vid = "Финансовый лизинг нерезидентам".
        create wrk11.
        wrk11.num = "860".
        wrk11.vid = "Прочие требования к нерезидентам ".
        create wrk11.
        wrk11.num = "861".
        wrk11.vid = "прочие инвестиции в капитал".
        create wrk11.
        wrk11.num = "863".
        wrk11.vid = "просроченная задолженность  по выданным кредитам и депозитам".
        create wrk11.
        wrk11.num = "864".
        wrk11.vid = "блокированная задолженность  по выданным кредитам и депозитам".
        create wrk11.
        wrk11.num = "865".
        wrk11.vid = "прочая  задолженность дебиторов	".

    define new shared temp-table wrk12 no-undo /* Раздел II. Обязательства  банка перед нерезидентами  */
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim extent 7 format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk12.
        wrk12.num = "870".
        wrk12.vid = "Корреспондентские счета  банков России".
        create wrk12.
        wrk12.num = "880".
        wrk12.vid = "Краткосрочные (не более 1 года)  депозиты банков России".
        create wrk12.
        wrk12.num = "890".
        wrk12.vid = "Депозиты до востребования, текущие счета и краткосрочные (не более 1 года) депозиты".
        create wrk12.
        wrk12.num = "891".
        wrk12.vid = "юридических лиц (кроме банков) и филиалов и представительств юридических лиц, осуществляющих деятельность в РК".
        create wrk12.
        wrk12.num = "893".
        wrk12.vid = "физических лиц".
        create wrk12.
        wrk12.num = "900".
        wrk12.vid = "Долгосрочные (более 1 года)  депозиты".
        create wrk12.
        wrk12.num = "901".
        wrk12.vid = "банков России".
        create wrk12.
        wrk12.num = "902".
        wrk12.vid = "юридических лиц (кроме банков)  и филиалов и представительств юридических лиц, осуществляющих деятельность в РК".
        create wrk12.
        wrk12.num = "903".
        wrk12.vid = "физических лиц".
        create wrk12.
        wrk12.num = "910".
        wrk12.vid = "Операции 'РЕПО'  с нерезидентами".
        create wrk12.
        wrk12.num = "920".
        wrk12.vid = "Прочие депозиты клиентов-нерезидентов".
        create wrk12.
        wrk12.num = "930".
        wrk12.vid = "Акции и другие ценные бумаги  банка, обеспечивающие участие в капитале и находящиеся у  нерезидентов".
        create wrk12.
        wrk12.num = "931".
        wrk12.vid = "из них: объектов прямого инвестирования  банком".
        create wrk12.
        wrk12.num = "932".
        wrk12.vid = "прямых инвесторов банка".
        create wrk12.
        wrk12.num = "940".
        wrk12.vid = "Долговые ценные бумаги выпущенные  банком, находящиеся у нерезидентов ".
        create wrk12.
        wrk12.num = "941".
        wrk12.vid = "из них со сроком погашения более 1 года".
        create wrk12.
        wrk12.num = "950".
        wrk12.vid = "Производные финансовые инструменты (опционы, финансовые фьючерсы, валютные свопы, форварды)	".
        create wrk12.
        wrk12.num = "970".
        wrk12.vid = "Прочие обязательства перед нерезидентами".
        create wrk12.
        wrk12.num = "971".
        wrk12.vid = "прочие инвестиции в капитал  банка".
        create wrk12.
        wrk12.num = "973".
        wrk12.vid = "просроченная  задолженность по депозитам, включая просроченное вознаграждение".
        create wrk12.
        wrk12.num = "974".
        wrk12.vid = "прочая  задолженность кредиторам".

    define new shared temp-table wrk13 no-undo /* Поступления от нерезидентов*/
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk13.
        wrk13.num = "980".
        wrk13.vid = "Доходы в виде вознаграждения по размещенным депозитам и выданным кредитам (факт)".
        wrk13.numo = "471".
        create wrk13.
        wrk13.num = "990".
        wrk13.vid = "Доходы по инвестициям в капитал".
        wrk13.numo = "473".
        create wrk13.
        wrk13.num = "1000".
        wrk13.vid = "Прочие доходы от ценных бумаг".
        wrk13.numo = "474".
        create wrk13.
        wrk13.num = "1010".
        wrk13.vid = "Прочие поступления".
        wrk13.numo = "476".

    define new shared temp-table wrk14 no-undo /* Платежи нерезидентам */
        field num as char
        field numo as char
        field vid as char
        field str1 as char
        field str2 as char
        field sum as decim  format ">>>,>>>,>>>,>>>,>>9.99".

        create wrk14.
        wrk14.num = "1015".
        wrk14.vid = "Расходы в виде вознаграждения по полученным кредитам и депозитам (факт)".
        wrk14.numo = "481".
        create wrk14.
        wrk14.num = "1020".
        wrk14.vid = "Расходы по аудиту и консультационным услугам".
        wrk14.numo = "482".
        create wrk14.
        wrk14.num = "1030".
        wrk14.vid = "Распределенный чистый доход  и дивиденды".
        wrk14.numo = "483".
        create wrk14.
        wrk14.num = "1040".
        wrk14.vid = "Прочие расходы по ценным  бумагам".
        wrk14.numo = "484".
        create wrk14.
        wrk14.num = "1050".
        wrk14.vid = "Налоги".
        wrk14.numo = "486".
        create wrk14.
        wrk14.num = "1060".
        wrk14.vid = "Прочие выплаты".
        wrk14.numo = "487".

define new shared temp-table sootv no-undo
    field sng as char
    field ru as char
    field kz as char
    index idx  kz.

    create sootv. sootv.sng = "490". sootv.ru = "780". sootv.kz = "10".
    create sootv. sootv.sng = "500". sootv.ru = "790". sootv.kz = "30".
    create sootv. sootv.sng = "510". sootv.ru = "800". sootv.kz = "40".
    create sootv. sootv.sng = "520". sootv.ru = "810". sootv.kz = "50".
    create sootv. sootv.sng = "530". sootv.ru = "820". sootv.kz = "60".
    create sootv. sootv.sng = "530". sootv.ru = "820". sootv.kz = "70".
    create sootv. sootv.sng = "530". sootv.ru = "820". sootv.kz = "80".
    create sootv. sootv.sng = "531". sootv.ru = "821". sootv.kz = "60".
    create sootv. sootv.sng = "532". sootv.ru = "822". sootv.kz = "70".
    create sootv. sootv.sng = "540". sootv.ru = "830". sootv.kz = "90".
    create sootv. sootv.sng = "540". sootv.ru = "830". sootv.kz = "100".
    create sootv. sootv.sng = "541". sootv.ru = "831". sootv.kz = "90".
    create sootv. sootv.sng = "541". sootv.ru = "831". sootv.kz = "100".
    create sootv. sootv.sng = "542". sootv.ru = "832". sootv.kz = "91".
    create sootv. sootv.sng = "545". sootv.ru = "835". sootv.kz = "110".
    create sootv. sootv.sng = "550". sootv.ru = "840". sootv.kz = "120".
    create sootv. sootv.sng = "550". sootv.ru = "840". sootv.kz = "130".
    create sootv. sootv.sng = "550". sootv.ru = "840". sootv.kz = "150".
    create sootv. sootv.sng = "551". sootv.ru = "841". sootv.kz = "150".
    create sootv. sootv.sng = "560". sootv.ru = "850". sootv.kz = "140".
    create sootv. sootv.sng = "570". sootv.ru = "860". sootv.kz = "160".
    create sootv. sootv.sng = "570". sootv.ru = "860". sootv.kz = "200".
    create sootv. sootv.sng = "570". sootv.ru = "860". sootv.kz = "210".
    create sootv. sootv.sng = "570". sootv.ru = "860". sootv.kz = "220".
    create sootv. sootv.sng = "570". sootv.ru = "860". sootv.kz = "230".
    create sootv. sootv.sng = "571". sootv.ru = "861". sootv.kz = "160".
    create sootv. sootv.sng = "573". sootv.ru = "863". sootv.kz = "210".
    create sootv. sootv.sng = "574". sootv.ru = "864". sootv.kz = "220".
    create sootv. sootv.sng = "575". sootv.ru = "865". sootv.kz = "230".
    create sootv. sootv.sng = "580". sootv.ru = "870". sootv.kz = "240".
    create sootv. sootv.sng = "590". sootv.ru = "880". sootv.kz = "260".
    create sootv. sootv.sng = "600". sootv.ru = "890". sootv.kz = "250".
    create sootv. sootv.sng = "601". sootv.ru = "891". sootv.kz = "253".
    create sootv. sootv.sng = "603". sootv.ru = "893". sootv.kz = "255".
    create sootv. sootv.sng = "610". sootv.ru = "900". sootv.kz = "270".
    create sootv. sootv.sng = "611". sootv.ru = "901". sootv.kz = "271".
    create sootv. sootv.sng = "612". sootv.ru = "902". sootv.kz = "272".
    create sootv. sootv.sng = "613". sootv.ru = "903". sootv.kz = "273".
    create sootv. sootv.sng = "620". sootv.ru = "910". sootv.kz = "280".
    create sootv. sootv.sng = "630". sootv.ru = "920". sootv.kz = "282".
    create sootv. sootv.sng = "640". sootv.ru = "930". sootv.kz = "290".
    create sootv. sootv.sng = "640". sootv.ru = "930". sootv.kz = "300".
    create sootv. sootv.sng = "640". sootv.ru = "930". sootv.kz = "310".
    create sootv. sootv.sng = "641". sootv.ru = "931". sootv.kz = "300".
    create sootv. sootv.sng = "642". sootv.ru = "932". sootv.kz = "290".
    create sootv. sootv.sng = "650". sootv.ru = "940". sootv.kz = "320".
    create sootv. sootv.sng = "650". sootv.ru = "940". sootv.kz = "330".
    create sootv. sootv.sng = "650". sootv.ru = "940". sootv.kz = "350".
    create sootv. sootv.sng = "651". sootv.ru = "941". sootv.kz = "320".
    create sootv. sootv.sng = "651". sootv.ru = "941". sootv.kz = "330".
    create sootv. sootv.sng = "660". sootv.ru = "950". sootv.kz = "350".
    create sootv. sootv.sng = "680". sootv.ru = "970". sootv.kz = "400".
    create sootv. sootv.sng = "680". sootv.ru = "970". sootv.kz = "450".
    create sootv. sootv.sng = "680". sootv.ru = "970". sootv.kz = "460".
    create sootv. sootv.sng = "681". sootv.ru = "971". sootv.kz = "400".
    create sootv. sootv.sng = "683". sootv.ru = "973". sootv.kz = "450".
    create sootv. sootv.sng = "684". sootv.ru = "974". sootv.kz = "460".


for each wrk15. /* заполнение шифра основной таблицы для СНГ */
    find first sootv where  sootv.sng = wrk15.num no-error.
    if available sootv then wrk15.numo = sootv.kz.
end.
for each wrk16. /* заполнение шифра основной таблицы для СНГ */
    find first sootv where  sootv.sng = wrk16.num no-error.
    if available sootv then wrk16.numo = sootv.kz.
end.
for each wrk11. /* заполнение шифра основной таблицы для России */
    find first sootv where  sootv.ru = wrk11.num no-error.
    if available sootv then wrk11.numo = sootv.kz.
end.
for each wrk12. /* заполнение шифра основной таблицы для России */
    find first sootv where  sootv.ru = wrk12.num no-error.
    if available sootv then wrk12.numo = sootv.kz.
end.
define new shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define new shared temp-table tglf
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .


/* таблицы для расшифровки  */
/* обороты */
define new shared temp-table t-salde no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field dt as decimal
    field dttng as decimal
    field dtus as decimal
    field ct as decimal
    field cttng as decimal
    field ctus as decimal
    field rdt as date
    field rate as decimal
    field rateus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field jh as int
    field dc as char
    field ln as int
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb jh
    INDEX indwrk wrk num.

/* остатки */
define new shared temp-table t-ost no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field b as decimal
    field btng as decimal
    field bus as decimal
    field e as decimal
    field etng as decimal
    field eus as decimal
    field rateb as decimal
    field ratebus as decimal
    field ratee as decimal
    field rateeus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb
    INDEX indwrk wrk num.

/* доходы-расходы */
define new shared temp-table t-income no-undo
    field num as char
    field num1 as char
    field num2 as char
    field oper as char
    field oper1 as char
    field oper2  as char
    field gl as int
    field dt7 as int
    field ct7 as int
    field jh as int
    field rdt as date
    field name as char
    field dtacc as char
    field ctacc as char
    field sum1 as decimal   /* остаток на начало */
    field sumus1 as decimal
    field rateus1 as decimal
    field sumdt as decimal   /* обороты дебет */
    field sumusdt as decimal
    field rateus as decimal
    field sumct as decimal   /* обороты кредит */
    field sumusct as decimal
    field sum2 as decimal    /* остаток на конец */
    field sumus2 as decimal
    field rateus2 as decimal
    field rem as char
    field country as char
    field cng as char
    field txb as char
    field txbname as char
    field wrk as char
    field crc as int
    index ind is primary oper.

define new shared temp-table wgl no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field num as char
    field wrk as char
    field df as char
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.

define new shared temp-table wgl1 no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field num as char
    field wrk as char
    field df as char
    index wgl-idx1 is unique primary gl.

 /* формируется рабочая таблица */
def var vprgl as logic.
def var lst as char.
def var v-grp as char.
def var v-df as char.
def var i as int.

for each gl where gl.totlev = 1 and gl.totgl <> 0 and gl.gl < 300000 no-lock:
    vprgl = no.
    v-df = "".
    for each wrk1.
        if vprgl then leave.
        lst = wrk1.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk1.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk1.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk1".
        end.
    end. /* for each wrk1. */
    for each wrk3.
        if vprgl then leave.
        lst = wrk3.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk3.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk3.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk3".
        end.
    end. /* for each wrk3. */
    for each wrk5.
        if vprgl then leave.
        lst = wrk5.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk5.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk5.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk5".
        end.
    end. /* for each wrk5. */
    for each wrk6.
        if vprgl then leave.
        lst = wrk6.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk6.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk6.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk6".
        end.
    end. /* for each wrk6. */
    for each wrk8.
        if vprgl then leave.
        lst = wrk8.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk8.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk8.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk8".
        end.
    end. /* for each wrk8. */
    for each wrk9.
        if vprgl then leave.
        lst = wrk9.str1. /* по долгу */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "d". end.
        end.   /*  do i = 1 to num-entries(lst) */

        lst = wrk9.str2. /* по вознаграждению */
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            if string(gl.gl) begins substr(v-grp,1,4) then do: vprgl = yes. v-df = "f". end.
        end.   /*  do i = 1 to num-entries(lst) */
        if vprgl then do:
            create wgl.
            wgl.num = wrk9.num.
            wgl.df = v-df.
            wgl.gl = gl.gl.
            wgl.subled = gl.subled.
            wgl.des = gl.des.
            wgl.lev = gl.level.
            wgl.type = gl.type.
            wgl.code = gl.code.
            wgl.grp = gl.grp.
            wgl.wrk = "wrk9".
        end.
    end. /* for each wrk9. */
end.
/* Раздел III. Текущие операции банка с нерезидентами за отчетный период*/
    for each wrk10.
        lst = wrk10.str1.
        do i = 1 to num-entries(lst):
            v-grp = entry(i,lst).
            for each gl where string(gl.gl) begins substr(v-grp,1,4) no-lock.
                find first wgl1 where wgl1.gl = gl.gl no-error.
                if not available wgl1 then do:
                    create wgl1.
                    wgl1.num = wrk10.num.
                    wgl1.df = v-df.
                    wgl1.gl = gl.gl.
                    wgl1.subled = gl.subled.
                    wgl1.des = gl.des.
                    wgl1.lev = gl.level.
                    wgl1.type = gl.type.
                    wgl1.code = gl.code.
                    wgl1.grp = gl.grp.
                    wgl1.wrk = "wrk10".
                end.
            end.
        end.   /*  do i = 1 to num-entries(lst) */
    end. /* for each wrk10. */

/* для остатков  на начало*/
def var RepName as char.
def var RepPath as char init "/data/reports/array/".
def new shared var v-gldate as date.
v-gldate = vasof_f - 1.
RepName = "array000" + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
    def new shared var v-gl1 as int no-undo.
    def new shared var v-gl2 as int  no-undo.
    def new shared var v-gl-cl as int  no-undo.
    v-gl1 = 0.
    v-gl2 = 0.
    v-gl-cl = 0.
    run array-create.
end.
else do:
    display '   Ждите...   '  with row 5 frame ww centered .
    run ImportData.
end.
/* данные по остаткам на начало копируем в tglf*/
for each tgl no-lock:
    create tglf.
    buffer-copy tgl to tglf.
end.
for each tglf.
    tglf.prod = "no".
end.
/*---------------------------------------------------------------------------------------------------------*/
/* для остатков  на конец*/
empty temp-table tgl.
v-gldate = vasof.
RepName = "array000" + replace(string(v-gldate,"99/99/9999"),"/","-") + ".rep".
if not FileExist(RepPath + RepName) then do:
    v-gl1 = 0.
    v-gl2 = 0.
    v-gl-cl = 0.
    run array-create.
end.
else do:
    display '   Ждите...   '  with row 5 frame ww centered .
    run ImportData.
end.
/*---------------------------------------------------------------------------------------------------------*/
/*for each wgl.
displ wgl.
end.*/
{r-brfilial.i &proc = "rep9PBtxb"}.
run rep9PBost.

if v-fil-int > 1 then v-fil-cnt = 'АО "ForteBank"'.



output stream v-out to a_rep.html.
    put stream v-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<h3>9-ПБ «Отчет о состоянии финансовых требований к нерезидентам и обязательств перед ними» <br>"
                                    v-fil-cnt " с " vasof_f " по " vasof "</h3>" skip.
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr><TD colspan=14 align=center > <b> Раздел I. Требования банка к  нерезидентам. </b> </TD> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть I. Наличные деньги, корреспондентские счета и депозиты. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=right > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.
    for each wrk1 .
        put stream v-out unformatted "<tr> <td> " wrk1.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk1.num "</td>" skip.
        if wrk1.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[1],0) "</td>" skip.
        if wrk1.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[2],0) "</td>" skip.
        if wrk1.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[3],0) "</td>" skip.
        if wrk1.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[4],0) "</td>" skip.
        if wrk1.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[5],0) "</td>" skip.
        if wrk1.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[6],0) "</td>" skip.
        if wrk1.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[7],0) "</td>" skip.
        if wrk1.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[8],0) "</td>" skip.
        if wrk1.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[9],0) "</td>" skip.
        if wrk1.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[10],0) "</td>" skip.
        if wrk1.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[11],0) "</td>" skip.
        if wrk1.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk1.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* приложение 2   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть II.  Ценные бумаги нерезидентов, обеспечивающие участие в капитале. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk2 .
        put stream v-out unformatted
        "<tr> <td> " wrk2.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk2.num "</td>" skip.
        if wrk2.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[1],0) "</td>" skip.
        if wrk2.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[2],0) "</td>" skip.
        if wrk2.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[3],0) "</td>" skip.
        if wrk2.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[4],0) "</td>" skip.
        if wrk2.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[5],0) "</td>" skip.
        if wrk2.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[6],0) "</td>" skip.
        if wrk2.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[7],0) "</td>" skip.
        if wrk2.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[8],0) "</td>" skip.
        if wrk2.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[9],0) "</td>" skip.
        if wrk2.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[10],0) "</td>" skip.
        if wrk2.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[11],0) "</td>" skip.
        if wrk2.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk2.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* приложение 3   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть III.  Долговые ценные бумаги  нерезидентов, депозитные сертификаты,векселя. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk3 .
        put stream v-out unformatted
        "<tr> <td> " wrk3.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk3.num "</td>" skip.
        if wrk3.sum[1] = 0 or wrk3.sum[1] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[1],0) "</td>" skip.
        if wrk3.sum[2] = 0 or wrk3.sum[2] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[2],0) "</td>" skip.
        if wrk3.sum[3] = 0 or wrk3.sum[3] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[3],0) "</td>" skip.
        if wrk3.sum[4] = 0 or wrk3.sum[4] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[4],0) "</td>" skip.
        if wrk3.sum[5] = 0 or wrk3.sum[5] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[5],0) "</td>" skip.
        if wrk3.sum[6] = 0 or wrk3.sum[6] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[6],0) "</td>" skip.
        if wrk3.sum[7] = 0 or wrk3.sum[7] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[7],0) "</td>" skip.
        if wrk3.sum[8] = 0 or wrk3.sum[8] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[8],0) "</td>" skip.
        if wrk3.sum[9] = 0 or wrk3.sum[9] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[9],0) "</td>" skip.
        if wrk3.sum[10] = 0 or wrk3.sum[10] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[10],0) "</td>" skip.
        if wrk3.sum[11] = 0 or wrk3.sum[11] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[11],0) "</td>" skip.
        if wrk3.sum[12] = 0 or wrk3.sum[12] = ? then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk3.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.


/* приложение 4   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr> </tr>" skip
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть IV. Ссуды, выданные нерезидентам. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk4 .
        put stream v-out unformatted
        "<tr> <td> " wrk4.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk4.num "</td>" skip.
        if wrk4.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[1],0) "</td>" skip.
        if wrk4.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[2],0) "</td>" skip.
        if wrk4.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[3],0) "</td>" skip.
        if wrk4.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[4],0) "</td>" skip.
        if wrk4.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[5],0) "</td>" skip.
        if wrk4.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[6],0) "</td>" skip.
        if wrk4.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[7],0) "</td>" skip.
        if wrk4.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[8],0) "</td>" skip.
        if wrk4.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[9],0) "</td>" skip.
        if wrk4.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[10],0) "</td>" skip.
        if wrk4.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[11],0) "</td>" skip.
        if wrk4.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk4.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.


/* приложение 5   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть V.  Прочие требования к нерезидентам. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk5 .
        put stream v-out unformatted
        "<tr> <td> " wrk5.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk5.num "</td>" skip.
        if wrk5.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[1],0) "</td>" skip.
        if wrk5.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[2],0) "</td>" skip.
        if wrk5.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[3],0) "</td>" skip.
        if wrk5.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[4],0) "</td>" skip.
        if wrk5.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[5],0) "</td>" skip.
        if wrk5.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[6],0) "</td>" skip.
        if wrk5.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[7],0) "</td>" skip.
        if wrk5.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[8],0) "</td>" skip.
        if wrk5.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[9],0) "</td>" skip.
        if wrk5.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[10],0) "</td>" skip.
        if wrk5.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[11],0) "</td>" skip.
        if wrk5.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk5.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.


/* часть 2 приложение 1   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr><TD colspan=14 align=center > <b> Раздел II. Обязательства банка перед нерезидентами. </b> </TD> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть I. Корреспондентские счета и депозиты нерезидентов в банке. </b> </TD>" skip

         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk6 .
        put stream v-out unformatted
        "<tr> <td> " wrk6.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk6.num "</td>" skip.
        if wrk6.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[1],0) "</td>" skip.
        if wrk6.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[2],0) "</td>" skip.
        if wrk6.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[3],0) "</td>" skip.
        if wrk6.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[4],0) "</td>" skip.
        if wrk6.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[5],0) "</td>" skip.
        if wrk6.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[6],0) "</td>" skip.
        if wrk6.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[7],0) "</td>" skip.
        if wrk6.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[8],0) "</td>" skip.
        if wrk6.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[9],0) "</td>" skip.
        if wrk6.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[10],0) "</td>" skip.
        if wrk6.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[11],0) "</td>" skip.
        if wrk6.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk6.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* часть 2 приложение 2   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть II.  Ценные бумаги,  обеспечивающие участие нерезидентов  в капитале банка. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk7 .
        put stream v-out unformatted
        "<tr> <td> " wrk7.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk7.num "</td>" skip.
        if wrk7.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[1],0) "</td>" skip.
        if wrk7.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[2],0) "</td>" skip.
        if wrk7.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[3],0) "</td>" skip.
        if wrk7.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[4],0) "</td>" skip.
        if wrk7.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[5],0) "</td>" skip.
        if wrk7.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[6],0) "</td>" skip.
        if wrk7.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[7],0) "</td>" skip.
        if wrk7.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[8],0) "</td>" skip.
        if wrk7.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[9],0) "</td>" skip.
        if wrk7.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[10],0) "</td>" skip.
        if wrk7.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[11],0) "</td>" skip.
        if wrk7.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk7.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* часть 2 приложение 3  */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть III.  Долговые ценные бумаги и депозитные сертификаты,  выпущенные  банком. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk8 .
        put stream v-out unformatted
        "<tr> <td> " wrk8.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk8.num "</td>" skip.
        if wrk8.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[1],0) "</td>" skip.
        if wrk8.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[2],0) "</td>" skip.
        if wrk8.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[3],0) "</td>" skip.
        if wrk8.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[4],0) "</td>" skip.
        if wrk8.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[5],0) "</td>" skip.
        if wrk8.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[6],0) "</td>" skip.
        if wrk8.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[7],0) "</td>" skip.
        if wrk8.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[8],0) "</td>" skip.
        if wrk8.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[9],0) "</td>" skip.
        if wrk8.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[10],0) "</td>" skip.
        if wrk8.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[11],0) "</td>" skip.
        if wrk8.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk8.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* часть 2 приложение 5 */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=13 align=left > <b> Часть V. Прочие обязательства перед  нерезидентами. </b> </TD>" skip
         "<TD align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD rowspan=3 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=3 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=3 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=6 align=center > Изменения  за период </TD>" skip
         "<TD rowspan=3 align=center > на конец <br> периода </TD>" skip
         "<TD colspan=4 align=center > Доходы к получению </TD></tr>" skip
         "<tr><TD colspan=3 align=center > в результате операций </TD>" skip
         "<TD rowspan=2 align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD rowspan=2 align=center > курсовые <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > прочие <br> изменения </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD rowspan=2 align=center > начислено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > оплачено в отчетном <br> периоде </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD></tr>" skip
         "<tr><TD align=center > поступило </TD>" skip
         "<TD align=center > списано </TD>" skip
         "<TD align=center > нетто </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD>" skip
         "<TD align=center > 8 </TD>" skip
         "<TD align=center > 9 </TD>" skip
         "<TD align=center > 10 </TD>" skip
         "<TD align=center > 11 </TD>" skip
         "<TD align=center > 12 </TD></tr>" skip.

    for each wrk9 .
        put stream v-out unformatted
        "<tr> <td> " wrk9.vid "</td>" skip.
        put stream v-out unformatted "<td> " wrk9.num "</td>" skip.
        if wrk9.sum[1] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[1],0) "</td>" skip.
        if wrk9.sum[2] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[2],0) "</td>" skip.
        if wrk9.sum[3] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[3],0) "</td>" skip.
        if wrk9.sum[4] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[4],0) "</td>" skip.
        if wrk9.sum[5] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[5],0) "</td>" skip.
        if wrk9.sum[6] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[6],0) "</td>" skip.
        if wrk9.sum[7] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[7],0) "</td>" skip.
        if wrk9.sum[8] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[8],0) "</td>" skip.
        if wrk9.sum[9] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[9],0) "</td>" skip.
        if wrk9.sum[10] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[10],0) "</td>" skip.
        if wrk9.sum[11] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[11],0) "</td>" skip.
        if wrk9.sum[12] = 0 then put stream v-out unformatted "<td> " "</td>" skip. else put stream v-out unformatted "<td> " round(wrk9.sum[12],0) "</td>" skip.
        put stream v-out unformatted "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.

/* часть 3   */
    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr> </tr>" skip
         "<tr><TD colspan=6 align=left > <b> Раздел III. Текущие операции банка с нерезидентами за отчетный период. </b> </TD> </tr>" skip
         "<tr><TD  colspan=3 align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr> <TD  align=center > Наименование показателя </TD>" skip
         "<TD align=right > шифр <br> строки </TD>" skip
         "<TD align=center > всего </TD></tr>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD></tr>" skip.

    for each wrk10 .
        put stream v-out unformatted
        "<tr> <td> " wrk10.vid "</td>" skip
        "<td> " wrk10.num "</td>" skip
        "<td> " replace(trim(string(wrk10.sum ,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
        "</tr>" skip.
    end.
    put stream v-out unformatted "</table>" skip.


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

/* для СНГ */
/*---------------------------------------------------------------------------------------------------------------*/
output stream v-cng to sng.html.
    put stream v-cng unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-cng unformatted  "<h3>9-ПБ «Отчет о  состоянии финансовых требований к нерезидентам из стран СНГ и обязательств перед ними» <br>"
                                    v-fil-cnt " с " vasof_f " по " vasof "</h3>" skip.
    put stream v-cng unformatted  "<table>" skip.
    put stream v-cng unformatted
         "<tr><TD colspan=8 align=center > <b> Раздел I. Требования банка к  нерезидентам. </b> </TD> </tr>" skip
         "<tr><TD colspan=9 align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-cng unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-cng unformatted
         "<tr><TD rowspan=2 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=2 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=4 align=center > Изменения  за квартал </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD>" skip
         "<TD rowspan=2 align=center > Доходы/расходы <br> начисленные за период </TD></tr>" skip
         "<tr><TD align=center > в результате <br>  проведенных <br> операций </TD>" skip
         "<TD align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD align=center > курсовые <br> изменения </TD>" skip
         "<TD align=center > прочие <br> изменения </tr></TD>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD> </tr>" skip.

    for each wrk15 .
        put stream v-cng unformatted
        "<tr> <td> " wrk15.vid "</td>" skip.
        put stream v-cng unformatted "<td> " wrk15.num "</td>" skip.
        if wrk15.sum[1] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[1],0) "</td>" skip.
        if wrk15.sum[2] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[2],0) "</td>" skip.
        if wrk15.sum[3] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[3],0) "</td>" skip.
        if wrk15.sum[4] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[4],0) "</td>" skip.
        if wrk15.sum[5] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[5],0) "</td>" skip.
        if wrk15.sum[6] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[6],0) "</td>" skip.
        if wrk15.sum[7] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk15.sum[7],0) "</td>" skip.
        put stream v-cng unformatted "</tr>" skip.
    end.
    put stream v-cng unformatted "</table>" skip.

    put stream v-cng unformatted  "<table>" skip.
    put stream v-cng unformatted
         "<tr><TD colspan=8 align=center > <b> Раздел II. Обязательства банка перед нерезидентами. </b> </TD> </tr>" skip
         "<tr><TD colspan=9 align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-cng unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    for each wrk16 .
        put stream v-cng unformatted
        "<tr> <td> " wrk16.vid "</td>" skip.
        put stream v-cng unformatted "<td> " wrk16.num "</td>" skip.
        if wrk16.sum[1] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[1],0) "</td>" skip.
        if wrk16.sum[2] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[2],0) "</td>" skip.
        if wrk16.sum[3] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[3],0) "</td>" skip.
        if wrk16.sum[4] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[4],0) "</td>" skip.
        if wrk16.sum[5] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[5],0) "</td>" skip.
        if wrk16.sum[6] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[6],0) "</td>" skip.
        if wrk16.sum[7] = 0 then put stream v-cng unformatted "<td> " "</td>" skip. else put stream v-cng unformatted "<td> " round(wrk16.sum[7],0) "</td>" skip.
        put stream v-cng unformatted "</tr>" skip.
    end.
    put stream v-cng unformatted "</table>" skip.

    put stream v-cng unformatted  "<table>" skip.
    put stream v-cng unformatted
         "<tr><TD colspan=3 align=center > <b> Раздел III. Текущие операции банка с нерезидентами из стран СНГ за отчетный период. </b> </TD> </tr>" skip
         "<tr><TD colspan=2 align=center > <b> I. Поступления от нерезидентов </b> </TD> <TD align=right >" v-raz "</TD></tr>" skip
         "</table>"  skip.
    put stream v-cng unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-cng unformatted
         "<tr> <TD  align=center > Наименование показателя </TD>" skip
         "<TD align=right > шифр <br> строки </TD>" skip
         "<TD align=center > всего </TD>" skip
         "</tr>" skip.

    for each wrk17 .
        put stream v-cng unformatted
        "<tr> <td> " wrk17.vid "</td>" skip
        "<td> " wrk17.num "</td>" skip
        "<td> " replace(trim(string(wrk17.sum ,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
        "</tr>" skip.
    end.
    put stream v-cng unformatted
         "<tr><TD colspan=2 align=center > <b> II. Платежи нерезидентам </b> </TD> <TD align=right >" v-raz "</TD></tr>" skip
         "</table>"  skip.
    put stream v-cng unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-cng unformatted
         "<tr> <TD  align=center > Наименование показателя </TD>" skip
         "<TD align=right > шифр <br> строки </TD>" skip
         "<TD align=center > всего </TD>" skip
         "</tr>" skip.

    for each wrk18 .
        put stream v-cng unformatted
        "<tr> <td> " wrk18.vid "</td>" skip
        "<td> " wrk18.num "</td>" skip
        "<td> " replace(trim(string(wrk18.sum ,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
        "</tr>" skip.
    end.

    put stream v-cng unformatted "</table>" skip.


    put stream v-cng unformatted  "<table>" skip.
    put stream v-cng unformatted
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

    output stream v-cng close.
    unix silent value("cptwin sng.html excel").
    hide message no-pause.

/* для России */
output stream v-ru to ru.html.
    put stream v-ru unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-ru unformatted  "<h3>9-ПБ «Отчет о  состоянии финансовых требований к нерезидентам из стран России и обязательств перед ними» <br>"
                                    v-fil-cnt " с " vasof_f " по " vasof "</h3>" skip.
    put stream v-ru unformatted  "<table>" skip.
    put stream v-ru unformatted
         "<tr><TD colspan=8 align=center > <b> Раздел I. Требования банка к  нерезидентам. </b> </TD> </tr>" skip
         "<tr><TD colspan=9 align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-ru unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ru unformatted
         "<tr><TD rowspan=2 align=center > Наименование показателя </TD>" skip
         "<TD rowspan=2 align=right > шифр <br> строки </TD>" skip
         "<TD rowspan=2 align=center > на начало <br> периода </TD>" skip
         "<TD colspan=4 align=center > Изменения  за квартал </TD>" skip
         "<TD rowspan=2 align=center > на конец <br> периода </TD>" skip
         "<TD rowspan=2 align=center > Доходы/расходы <br> начисленные за период </TD></tr>" skip
         "<tr><TD align=center > в результате <br>  проведенных <br> операций </TD>" skip
         "<TD align=center > изменения <br>  стоимости <br> (цен) </TD>" skip
         "<TD align=center > курсовые <br> изменения </TD>" skip
         "<TD align=center > прочие <br> изменения </tr></TD>" skip
         "<tr><TD align=center > A </TD>" skip
         "<TD align=center > Б </TD>" skip
         "<TD align=center > 1 </TD>" skip
         "<TD align=center > 2 </TD>" skip
         "<TD align=center > 3 </TD>" skip
         "<TD align=center > 4 </TD>" skip
         "<TD align=center > 5 </TD>" skip
         "<TD align=center > 6 </TD>" skip
         "<TD align=center > 7 </TD> </tr>" skip.

    for each wrk11 .
        put stream v-ru unformatted
        "<tr> <td> " wrk11.vid "</td>" skip.
        put stream v-ru unformatted "<td> " wrk11.num "</td>" skip.
        if wrk11.sum[1] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[1],0) "</td>" skip.
        if wrk11.sum[2] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[2],0) "</td>" skip.
        if wrk11.sum[3] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[3],0) "</td>" skip.
        if wrk11.sum[4] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[4],0) "</td>" skip.
        if wrk11.sum[5] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[5],0) "</td>" skip.
        if wrk11.sum[6] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[6],0) "</td>" skip.
        if wrk11.sum[7] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk11.sum[7],0) "</td>" skip.
        put stream v-ru unformatted "</tr>" skip.
    end.
    put stream v-ru unformatted "</table>" skip.

    put stream v-ru unformatted  "<table>" skip.
    put stream v-ru unformatted
         "<tr><TD colspan=8 align=center > <b> Раздел II. Обязательства банка перед нерезидентами. </b> </TD> </tr>" skip
         "<tr><TD colspan=9 align=right >" v-raz "</TD> </tr>" skip
         "</table>"  skip.

    put stream v-ru unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.

    for each wrk12 .
        put stream v-ru unformatted
        "<tr> <td> " wrk12.vid "</td>" skip.
        put stream v-ru unformatted "<td> " wrk12.num "</td>" skip.
        if wrk12.sum[1] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[1],0) "</td>" skip.
        if wrk12.sum[2] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[2],0) "</td>" skip.
        if wrk12.sum[3] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[3],0) "</td>" skip.
        if wrk12.sum[4] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[4],0) "</td>" skip.
        if wrk12.sum[5] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[5],0) "</td>" skip.
        if wrk12.sum[6] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[6],0) "</td>" skip.
        if wrk12.sum[7] = 0 then put stream v-ru unformatted "<td> " "</td>" skip. else put stream v-ru unformatted "<td> " round(wrk12.sum[7],0) "</td>" skip.
        put stream v-ru unformatted "</tr>" skip.
    end.
    put stream v-ru unformatted "</table>" skip.

    put stream v-ru unformatted  "<table>" skip.
    put stream v-ru unformatted
         "<tr><TD colspan=3 align=center > <b> Раздел III. Текущие операции банка с нерезидентами из стран России за отчетный период. </b> </TD> </tr>" skip
         "<tr><TD colspan=2 align=center > <b> I. Поступления от нерезидентов </b> </TD> <TD align=right >" v-raz "</TD></tr>" skip
         "</table>"  skip.
    put stream v-ru unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ru unformatted
         "<tr> <TD  align=center > Наименование показателя </TD>" skip
         "<TD align=right > шифр <br> строки </TD>" skip
         "<TD align=center > всего </TD>" skip
         "</tr>" skip.

    for each wrk13 .
        put stream v-ru unformatted
        "<tr> <td> " wrk13.vid "</td>" skip
        "<td> " wrk13.num "</td>" skip
        "<td> " replace(trim(string(wrk13.sum ,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
        "</tr>" skip.
    end.
    put stream v-ru unformatted
         "<tr><TD colspan=2 align=center > <b> II. Платежи нерезидентам </b> </TD> <TD align=right >" v-raz "</TD></tr>" skip
         "</table>"  skip.
    put stream v-ru unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ru unformatted
         "<tr> <TD  align=center > Наименование показателя </TD>" skip
         "<TD align=right > шифр <br> строки </TD>" skip
         "<TD align=center > всего </TD>" skip
         "</tr>" skip.

    for each wrk14 .
        put stream v-ru unformatted
        "<tr> <td> " wrk14.vid "</td>" skip
        "<td> " wrk14.num "</td>" skip
        "<td> " replace(trim(string(wrk14.sum ,"->>>>>>>>>>>>>>>9.99")), ".", ",") "</td>" skip
        "</tr>" skip.
    end.

    put stream v-ru unformatted "</table>" skip.


    put stream v-ru unformatted  "<table>" skip.
    put stream v-ru unformatted
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

    output stream v-ru close.
    unix silent value("cptwin ru.html excel").
    hide message no-pause.

/*---------------------------------------------------------------------------------------------------------------*/

if v-ful1 = 1 or v-ful1 = 3 then do:
    output stream v-ost to ost.html.
    put stream v-ost unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-ost unformatted  "<table>" skip.
    put stream v-ost unformatted
         "<tr> </tr>" skip
         "<tr><TD align=left > <b> Расшифровка остатки к отчету 9-ПБ  с " vasof_f " по " vasof " </b> </TD>" skip
         "</table>"  skip.

    put stream v-ost unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ost unformatted
         "<tr><TD align=center > Филиал <br> </TD>" skip
         "<TD align=right > Шифр <br> Осн части  </TD>" skip
         "<TD align=right > Шифр <br> СНГ  </TD>" skip
         "<TD align=center > Шифр <br> России </TD>" skip
         "<TD align=center > Наименование <br> клиента </TD>" skip
         "<TD align=center > Счет ГК <br> '' </TD>" skip
         "<TD align=center > Балансовый <br> счет </TD>" skip
         "<TD align=center > Лицевой <br> счет </TD>" skip
         "<TD align=center > Валюта <br> </TD>" skip
         "<TD align=center > Вх остаток <br> в номинале </TD>" skip
         "<TD  align=center > Вх остаток <br>  в эквив в тенге  <br> (цен) </TD>" skip
         "<TD  align=center > Вх остаток <br>  в дол США  </TD>" skip
         "<TD  align=center > Курс валюты <br>  начало </TD>" skip
         "<TD  align=center > Курс доллара <br>  начало </TD>" skip
         "<TD  align=center > Исх остаток <br>  номинале </TD>" skip
         "<TD  align=center > Исх остаток <br> в эквив в тенге  </TD>" skip
         "<TD  align=center > Исх остаток <br> в дол США </TD>" skip
         "<TD align=center > Курс валюты <br> конец </TD>" skip
         "<TD align=center > Курс доллара <br> конец </TD>" skip
         "<TD align=center > Страна <br> </TD>" skip
         "<TD align=center > Признак <br> СНГ </TD>" skip
         "<TD align=center > Сектор <br> экономики  </TD>" skip
         "<TD align=center > Вид и форма <br> юр лица </TD>" skip
         "<TD align=center > Дата открытия <br> договора/сделки </TD>" skip
         "<TD align=center > Дата закрытия <br> договора/сделки </TD>" skip
         "<TD align=center > Количество <br> дней </TD>" skip
         "<TD align=center > Срок по <br> договору/сделки </TD>" skip
         "<TD align=center > Признак <br> резиденства </TD>" skip
         "<TD align=center > sub </TD>" skip
         "<TD align=center > df </TD></tr>" skip.

    for each t-ost .
        put stream v-ost unformatted
        "<tr> <td> " t-ost.txbname "</td>" skip
        "<td> &nbsp;" t-ost.num "</td>" skip
        "<td> &nbsp;" t-ost.num1 "</td>" skip
        "<td> &nbsp;" t-ost.num2 "</td>" skip
        "<td> " t-ost.name "</td>" skip
        "<td> " t-ost.gl "</td>" skip
        "<td> " t-ost.gl7 "</td>" skip
        "<td> " t-ost.acc "</td>" skip
        "<td> " t-ost.crc "</td>" skip
        "<td> " replace(trim(string(t-ost.b,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.btng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.bus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.rateb,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.ratebus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.e,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.etng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.eus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.ratee,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-ost.rateeus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-ost.country "</td>" skip
        "<td> " t-ost.cng "</td>" skip
        "<td> " t-ost.secek "</td>" skip
        "<td> " t-ost.vidur "</td>" skip
        "<td> " t-ost.dtop "</td>" skip
        "<td> " t-ost.dtcl "</td>" skip
        "<td> " t-ost.cntday "</td>" skip
        "<td> " t-ost.period "</td>" skip
        "<td> " t-ost.rez "</td>" skip
        "<td> " t-ost.sub "</td>" skip
        "<td> " t-ost.df "</td>" skip
        "</tr>" skip.
    end.
    put stream v-ost unformatted "</table>" skip.
    output stream v-ost close.
    unix silent value("cptwin ost.html excel").
    hide message no-pause.
end.

if v-ful1 = 1 or v-ful1 = 2 then do:
    output stream v-sal to tsal.html.
    put stream v-sal unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream v-sal unformatted  "<table>" skip.
    put stream v-sal unformatted
         "<tr> </tr>" skip
         "<tr><TD align=left > <b> Расшифровка обороты  к отчету 9-ПБ  с " vasof_f " по " vasof " </b> </TD>" skip
         "</table>"  skip.

    put stream v-sal unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-sal unformatted
         "<tr><TD align=center > Филиал <br> </TD>" skip
         "<TD align=right > Шифр <br> Осн части  </TD>" skip
         "<TD align=right > Шифр <br> СНГ  </TD>" skip
         "<TD align=center > Шифр <br> России </TD>" skip
         "<TD align=center > Наименование <br> клиента </TD>" skip
         "<TD align=center > Счет ГК <br> '' </TD>" skip
         "<TD align=center > Балансовый <br> счет </TD>" skip
         "<TD align=center > Лицевой <br> счет </TD>" skip
         "<TD align=center > Валюта <br> </TD>" skip
         "<TD align=center > Транз <br> </TD>" skip
         "<TD align=center > Обороты по дебету <br> в номинале </TD>" skip
         "<TD  align=center > Обороты по дебету  <br>  в эквив в тенге  <br> (цен) </TD>" skip
         "<TD  align=center > Обороты по дебету  <br>  в дол США  </TD>" skip
         "<TD  align=center > Обороты по кредиту <br>  в номинале </TD>" skip
         "<TD  align=center > Обороты по кредиту <br> в эквив в тенге  </TD>" skip
         "<TD  align=center > Обороты по кредиту <br> в дол США </TD>" skip
         "<TD  align=center > Кур <br>с валюты  </TD>" skip
         "<TD  align=center > Курс <br> доллара </TD>" skip
         "<TD align=center > Страна <br> </TD>" skip
         "<TD align=center > Признак <br> СНГ </TD>" skip
         "<TD align=center > Сектор <br> экономики  </TD>" skip
         "<TD align=center > Вид и форма <br> юр лица </TD>" skip
         "<TD align=center > Дата открытия <br> договора/сделки </TD>" skip
         "<TD align=center > Дата закрытия <br> договора/сделки </TD>" skip
         "<TD align=center > Количество <br> дней </TD>" skip
         "<TD align=center > Срок по <br> договору/сделки </TD>" skip
         "<TD align=center > Признак <br> резиденства </TD>" skip
         "<TD align=center > sub </TD>" skip
         "<TD align=center > wrk </TD>" skip
         "<TD align=center > df </TD></tr>" skip.

    for each t-salde .
        put stream v-sal unformatted
        "<tr> <td> " t-salde.txbname "</td>" skip
        "<td> &nbsp;" t-salde.num "</td>" skip
        "<td> &nbsp;" t-salde.num1 "</td>" skip
        "<td> &nbsp;" t-salde.num2 "</td>" skip
        "<td> " t-salde.name "</td>" skip
        "<td> " t-salde.gl "</td>" skip
        "<td> " t-salde.gl7 "</td>" skip
        "<td> " t-salde.acc "</td>" skip
        "<td> " t-salde.crc "</td>" skip
        "<td> " t-salde.jh "</td>" skip
        "<td> " replace(trim(string(t-salde.dt,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.dttng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.dtus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.ct,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.cttng,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.ctus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.rate,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-salde.rateus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-salde.country "</td>" skip
        "<td> " t-salde.cng "</td>" skip
        "<td> " t-salde.secek "</td>" skip
        "<td> " t-salde.vidur "</td>" skip
        "<td> " t-salde.dtop "</td>" skip
        "<td> " t-salde.dtcl "</td>" skip
        "<td> " t-salde.cntday "</td>" skip
        "<td> " t-salde.period "</td>" skip
        "<td> " t-salde.rez "</td>" skip
        "<td> " t-salde.sub "</td>" skip
        "<td> " t-salde.wrk "</td>" skip
        "<td> " t-salde.df "</td>" skip
        "</tr>" skip.
    end.
    put stream v-sal unformatted "</table>" skip.
    output stream v-sal close.
    unix silent value("cptwin tsal.html excel").
    hide message no-pause.
end.

if v-ful1 = 1 or v-ful1 = 4 then do:
    output stream v-ostin to tincome.html.
    put stream v-ostin unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream v-ostin unformatted  "<table>" skip.
    put stream v-ostin unformatted
         "<tr> </tr>" skip
         "<tr><TD align=left > <b> Расшифровка доходы/расходы к отчету 9-ПБ  с " vasof_f " по " vasof " </b> </TD>" skip
         "</table>"  skip.

    put stream v-ostin unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-ostin unformatted
         "<tr><TD align=center > Филиал <br> </TD>" skip
         "<TD align=right > Шифр <br> Осн части  </TD>" skip
         "<TD align=right > Шифр <br> СНГ  </TD>" skip
         "<TD align=center > Шифр <br> России </TD>" skip
         "<TD align=right > Операц  <br> Осн части  </TD>" skip
         "<TD align=right > Операц  <br> СНГ  </TD>" skip
         "<TD align=center > Операц  <br> России </TD>" skip
         "<TD align=center > Счет ГК <br> '' </TD>" skip
         "<TD align=center > Балансовый <br> счет ДТ</TD>" skip
         "<TD align=center > Балансовый <br> счет КТ</TD>" skip
         "<TD align=center > Наименование <br> счет КТ</TD>" skip
         "<TD align=center > Лицевой <br> счет ДТ</TD>" skip
         "<TD align=center > Лицевой <br> счет КТ</TD>" skip
         "<TD align=center > Валюта <br> </TD>" skip
         "<TD align=center > остаток вх в тенге <br> </TD>" skip
         "<TD align=center > остаток вх в долл США <br> </TD>" skip
         "<TD  align=center > Курс вх <br> доллара </TD>" skip

         "<TD align=center > Транз <br> </TD>" skip
         "<TD  align=center > Сумма ДТ в тенге </TD>" skip
         "<TD  align=center > Сумма ДТ в долл США  </TD>" skip
         "<TD  align=center > Курс <br> доллара </TD>" skip
         "<TD  align=center > Сумма КТ в тенге </TD>" skip
         "<TD  align=center > Сумма КТ в долл США  </TD>" skip
         "<TD align=center > остаток исх в тенге <br> </TD>" skip
         "<TD align=center > остаток исх в долл США <br> </TD>" skip
         "<TD  align=center > Курс исх <br> доллара </TD>" skip
         "<TD align=center > Страна <br> </TD>" skip
         "<TD align=center > Признак <br> СНГ </TD>" skip.

    for each t-income .
        put stream v-ostin unformatted
        "<tr> <td> " t-income.txbname "</td>" skip
        "<td> &nbsp;" t-income.oper "</td>" skip
        "<td> &nbsp;" t-income.oper1 "</td>" skip
        "<td> &nbsp;" t-income.oper2 "</td>" skip
        "<td> &nbsp;" t-income.num "</td>" skip
        "<td> &nbsp;" t-income.num1 "</td>" skip
        "<td> &nbsp;" t-income.num2 "</td>" skip
        "<td> " t-income.gl "</td>" skip
        "<td> " t-income.dt7 "</td>" skip
        "<td> " t-income.ct7 "</td>" skip
        "<td> " t-income.name "</td>" skip
        "<td> " t-income.dtacc "</td>" skip
        "<td> " t-income.ctacc "</td>" skip
        "<td> " t-income.crc "</td>" skip
        "<td> " replace(trim(string(t-income.sum1,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sumus1,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.rateus1,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-income.jh "</td>" skip
        "<td> " replace(trim(string(t-income.sumdt,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sumusdt,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.rateus,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sumct,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sumusct,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sum2,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.sumus2,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " replace(trim(string(t-income.rateus2,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip
        "<td> " t-income.country "</td>" skip
        "<td> " t-income.cng "</td>" skip
        "</tr>" skip.
    end.
    put stream v-ostin unformatted "</table>" skip.
    output stream v-ostin close.
    unix silent value("cptwin tincome.html excel").
    hide message no-pause.
end.
return.

procedure ImportData:
  INPUT FROM value(RepPath + RepName) NO-ECHO.
  LOOP:
  REPEAT TRANSACTION:
   REPEAT ON ENDKEY UNDO, LEAVE LOOP:
   CREATE tgl.
   IMPORT
     tgl.txb
     tgl.gl
     tgl.gl4
     tgl.gl7
     tgl.gl-des
     tgl.crc
     tgl.sum
     tgl.sum-val
     tgl.type
     tgl.sub-type
     tgl.totlev
     tgl.totgl
     tgl.level
     tgl.code
     tgl.grp
     tgl.acc
     tgl.acc-des
     tgl.geo
     tgl.odt
     tgl.cdt
     tgl.perc
     tgl.prod.
   END. /*REPEAT*/
  END. /*TRANSACTION*/
  input close.
end procedure.
