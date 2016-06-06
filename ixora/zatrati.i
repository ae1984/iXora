/* zatrati.i
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        04/02/06 nataly
 * CHANGES
        22.06.2006 nataly был довавлена обработка склада, Прилож 12,13,14.
*/


def var v-pr3 as char no-undo.
def var v-pr3_7 as char no-undo.
def var v-pr3_8 as char no-undo.
def var v-pr3_9 as char no-undo.
def var v-pr3_10 as char no-undo.
def var v-pr3_11 as char no-undo.
def var v-pr3_12 as char no-undo.
def var v-pr3_13 as char no-undo.
def var v-pr3_14 as char no-undo.

def var v-pr4 as char no-undo.
def var v-pr4_7 as char no-undo.
def var v-pr4_8 as char no-undo.
def var v-pr4_9 as char no-undo.
def var v-pr4_10 as char no-undo.
def var v-pr4_11 as char no-undo.
def var v-pr4_12 as char no-undo.
def var v-pr4_14 as char no-undo.
def var v-pr4_15 as char no-undo.
def var v-pr4_16 as char no-undo.

def var v-pr5 as char no-undo.
def var v-pr5_9 as char no-undo.
def var v-pr5_10 as char no-undo.
def var v-pr5_11 as char no-undo.
def var v-pr5_13 as char no-undo.
def var v-pr5_14 as char no-undo.
def var v-pr5_15 as char no-undo.
def var v-pr5_16 as char no-undo.
def var v-pr5_17 as char no-undo.
def var v-pr5_18 as char no-undo.
def var v-pr5_19 as char no-undo.
def var v-pr5_20 as char no-undo.
def var v-pr5_21 as char no-undo.
def var v-pr5_22 as char no-undo.

def var v-pr6 as char no-undo.
def var v-pr6_7 as char no-undo.
def var v-pr6_8 as char no-undo.

def var v-pr7 as char no-undo.
def var v-pr7_6 as char no-undo.
def var v-pr7_7 as char no-undo.
def var v-pr7_8 as char no-undo.
def var v-pr7_9 as char no-undo.

def var v-pr8 as char no-undo.
def var v-pr8_4 as char no-undo.
def var v-pr8_5 as char no-undo.
def var v-pr8_6 as char no-undo.
def var v-pr8_7 as char no-undo.
def var v-pr8_8 as char no-undo.
def var v-pr8_9 as char no-undo.
def var v-pr8_10 as char no-undo.
def var v-pr8_11 as char no-undo.

def var v-pr9 as char no-undo.
def var v-pr9_4 as char no-undo.
def var v-pr9_5 as char no-undo.
def var v-pr9_6 as char no-undo.
def var v-pr9_7 as char no-undo.

def var v-pr10 as char no-undo.
def var v-pr10_4 as char no-undo.
def var v-pr10_5 as char no-undo.
def var v-pr10_6 as char no-undo.
def var v-pr10_7 as char no-undo.
def var v-pr10_8 as char no-undo.
def var v-pr10_9 as char no-undo.
def var v-pr1010 as char no-undo.
def var v-pr1011 as char no-undo.

def var v-pr11 as char no-undo.
def var v-pr11_4 as char no-undo.
def var v-pr11_5 as char no-undo.
def var v-pr11_6 as char no-undo.
def var v-pr11_7 as char no-undo.
def var v-pr11_8 as char no-undo.
def var v-pr11_9 as char no-undo.
def var v-pr1110 as char no-undo.
def var v-pr1111 as char no-undo.
def var v-pr1112 as char no-undo.
def var v-pr1113 as char no-undo.
def var v-pr1114 as char no-undo.
def var v-pr1115 as char no-undo.
def var v-pr1116 as char no-undo.
def var v-pr1117 as char no-undo.
def var v-pr1118 as char no-undo.
def var v-pr1119 as char no-undo.
def var v-pr1120 as char no-undo.
def var v-pr1121 as char no-undo.
def var v-pr1122 as char no-undo.
def var v-pr1123 as char no-undo.
def var v-pr1124 as char no-undo.
def var v-pr1125 as char no-undo.
def var v-pr1126 as char no-undo.
def var v-pr1127 as char no-undo.

def var v-pr12 as char no-undo.
def var v-pr12_4 as char no-undo.
def var v-pr12_5 as char no-undo.
def var v-pr12_6 as char no-undo.
def var v-pr12_7 as char no-undo.
def var v-pr12_8 as char no-undo.
def var v-pr12_9 as char no-undo.
def var v-pr1210 as char no-undo.

def var v-pr13 as char no-undo.
def var v-pr13_4 as char no-undo.
def var v-pr13_5 as char no-undo.
def var v-pr13_6 as char no-undo.
def var v-pr13_7 as char no-undo.
def var v-pr13_8 as char no-undo.
def var v-pr13_9 as char no-undo.
def var v-pr1310 as char no-undo.
def var v-pr1311 as char no-undo.
def var v-pr1312 as char no-undo.
def var v-pr1313 as char no-undo.
def var v-pr1314 as char no-undo.
def var v-pr1315 as char no-undo.
def var v-pr1316 as char no-undo.

def var v-pr14 as char no-undo.
def var v-pr14_4 as char no-undo.
def var v-pr14_5 as char no-undo.
def var v-pr14_6 as char no-undo.
def var v-pr14_7 as char no-undo.
def var v-pr14_8 as char no-undo.

def var v-pr15 as char no-undo.
def var v-pr15_4 as char no-undo.
def var v-pr15_5 as char no-undo.
def var v-pr15_6 as char no-undo.
def var v-pr15_7 as char no-undo.
def var v-pr15_8 as char no-undo.
def var v-pr15_9 as char no-undo.

def var v-pr16 as char no-undo.
def var v-pr16_4 as char no-undo.
def var v-pr16_5 as char no-undo.
def var v-pr16_6 as char no-undo.
def var v-pr16_7 as char no-undo.
def var v-pr16_8 as char no-undo.
def var v-pr16_9 as char no-undo.
def var v-pr1610 as char no-undo.
def var v-pr1611 as char no-undo.
def var v-pr1612 as char no-undo.

def var v-pr17 as char no-undo.
def var v-pr17_4 as char no-undo.
def var v-pr17_5 as char no-undo.
def var v-pr17_6 as char no-undo.
def var v-pr17_7 as char no-undo.
def var v-pr17_8 as char no-undo.
def var v-pr17_9 as char no-undo.
def var v-pr1710 as char no-undo.
def var v-pr1711 as char no-undo.

def var v-pr18 as char no-undo.
def var v-pr18_4 as char no-undo.
def var v-pr18_5 as char no-undo.
def var v-pr18_6 as char no-undo.

def var v-pr19 as char no-undo.
def var v-pr19_4 as char no-undo.
def var v-pr19_5 as char no-undo.
def var v-pr19_6 as char no-undo.
def var v-pr19_7 as char no-undo.

def var v-pr20 as char no-undo.
def var v-pr20_4 as char no-undo.
def var v-pr20_5 as char no-undo.
def var v-pr20_6 as char no-undo.
def var v-pr20_7 as char no-undo.
def var v-pr20_8 as char no-undo.
def var v-pr20_9 as char no-undo.
def var v-pr2010 as char no-undo.
def var v-pr2011 as char no-undo.

def var v-pr30 as char no-undo.
def var v-pr30_4 as char no-undo.
def var v-pr30_5 as char no-undo.
def var v-pr30_6 as char no-undo.
def var v-pr30_7 as char no-undo.
def var v-pr30_8 as char no-undo.
def var v-pr30_9 as char no-undo.
def var v-pr30_10 as char no-undo.
def var v-pr30_11 as char no-undo.
def var v-pr30_12 as char no-undo.
def var v-pr30_13 as char no-undo.
def var v-pr30_14 as char no-undo.
def var v-pr30_15 as char no-undo.
def var v-pr30_16 as char no-undo.
def var v-pr30_17 as char no-undo.
def var v-pr30_18 as char no-undo.
def var v-pr30_19 as char no-undo.
def var v-pr30_20 as char no-undo.
def var v-pr30_21 as char no-undo.
def var v-pr30_22 as char no-undo.
def var v-pr30_23 as char no-undo.
def var v-pr30_24 as char no-undo.
def var v-pr30_25 as char no-undo.
def var v-pr30_26 as char no-undo.
def var v-pr30_27 as char no-undo.
def var v-pr30_28 as char no-undo.
def var v-pr30_29 as char no-undo.
def var v-pr30_30 as char no-undo.
def var v-pr30_31 as char no-undo.
def var v-pr30_32 as char no-undo.
def var v-pr30_33 as char no-undo.
def var v-pr30_34 as char no-undo.
def var v-pr30_35 as char no-undo.
def var v-pr30_36 as char no-undo.

def var v-pr31 as char no-undo.
def var v-pr31_4 as char no-undo.
def var v-pr31_5 as char no-undo.
def var v-pr31_6 as char no-undo.
def var v-pr31_7 as char no-undo.
def var v-pr31_8 as char no-undo.
def var v-pr31_9 as char no-undo.
def var v-pr31_10 as char no-undo.
def var v-pr31_11 as char no-undo.
def var v-pr31_12 as char no-undo.
def var v-pr31_13 as char no-undo.
def var v-pr31_14 as char no-undo.
def var v-pr31_15 as char no-undo.

def var v-pr32 as char no-undo.
def var v-pr32_4 as char no-undo.
def var v-pr32_5 as char no-undo.
def var v-pr32_6 as char no-undo.
def var v-pr32_7 as char no-undo.
def var v-pr32_8 as char no-undo.
def var v-pr32_9 as char no-undo.
def var v-pr32_10 as char no-undo.
def var v-pr32_11 as char no-undo.
def var v-pr32_12 as char no-undo.
def var v-pr32_13 as char no-undo.
def var v-pr32_14 as char no-undo.
def var v-pr32_15 as char no-undo.
def var v-pr32_16 as char no-undo.
def var v-pr32_17 as char no-undo.
def var v-pr32_18 as char no-undo.
def var v-pr32_19 as char no-undo.
def var v-pr32_20 as char no-undo.
def var v-pr32_21 as char no-undo.
def var v-pr32_22 as char no-undo.
def var v-pr32_23 as char no-undo.
def var v-pr32_24 as char no-undo.
def var v-pr32_25 as char no-undo.

def var v-pr33 as char no-undo.
def var v-pr33_4 as char no-undo.
def var v-pr33_5 as char no-undo.
def var v-pr33_6 as char no-undo.
def var v-pr33_7 as char no-undo.
def var v-pr33_8 as char no-undo.
def var v-pr33_9 as char no-undo.
def var v-pr33_10 as char no-undo.
def var v-pr33_11 as char no-undo.
def var v-pr33_12 as char no-undo.
def var v-pr33_13 as char no-undo.
def var v-pr33_14 as char no-undo.
def var v-pr33_15 as char no-undo.
def var v-pr33_16 as char no-undo.

def var v-pr34 as char no-undo.
def var v-pr34_4 as char no-undo.
def var v-pr34_5 as char no-undo.
def var v-pr34_6 as char no-undo.
def var v-pr34_7 as char no-undo.
def var v-pr34_8 as char no-undo.
def var v-pr34_9 as char no-undo.
def var v-pr34_10 as char no-undo.
def var v-pr34_11 as char no-undo.

def {1} shared var totgl as char extent 56 init ["503600","505400", "511000", "512000", "520000", "525000","530000",
                                                 "540000","545000", "550000", "560000", "570000", "572000","576300",
                                                 "574100","574199", "574230", "574240", "574240", "574900","575399",
					         "578000","574310", "574220", "574220", "574240", "574810", "574410",
                                                 "574420","574430","574500", "574699", "574820", "574811" ,"575010",
                                                 "575200","576100","576300", "576400", "576500", "576700", "576600",
                                                 "576800","585200","589000", "590099", "592100", "592110", "592200",
                                                 "592200","592240","592399", "592400", "594000", "599910", "599920"].
def {1} shared var des as char extent 56 init  [
                                    "Расходы по займам от правительства","Расходы по займам от др банков",
                                    "Расходы по займам оверн","Расходы по вкладам др банков",
                                    "Расходы по депозитам клиентов","Расходы по РЕПО",
                                    "Расходы по ЦБ","Расходы по субор долгу",
                                    "Ассигнования на обеспечение","Потери по дил опер",
                                    "Комис расходы банка","Убытки банка от переоценки",
                                    "Затраты на опл. труда персонала",
                                    "Соц налог",
                                    "Расходы на ГСМ","Расходы на ГСМ(начисл)",
                                    "Затраты на товарно-материальные ценности(запасы)",
                                    "Затраты, связ. с обучением персонала(подготовка и переподготовка кадров)",
                                    "Прочие адм расходы",
                                    "Затраты при выезде работников в служ.командировки",
                                    "Затраты на услуги связи",
                                    "Затраты на амортизацию ОС",
                                    "Затраты на инкассацию",
                                 /*   "Затраты на амортизацию НМА, в части ПО",*/
                                    "Затраты на бланочную продукцию",
                                    "Затраты на канц.товары",
                                    "Затраты на приобр. печатной продукции",
                                    "Затраты по коммун. услугам",
                                    "Затраты по кап. ремонту ОС",
                                    "Затраты по тек. ремонту и осмотру ОС",
                                    "Затраты по ремонт автотранспорта",
                                    "Реклама","Раходы по обслуж пожарно-охран сигнализации",
                                    "Прочие админ затраты",
                                    "Начисленные коммунальные услуги",
                                    "Аудиторские и консалт услуги","Расходы по страхованию",
                                    "НДС","Соц отчисления","Расходы по зем налогу",
                                    "Расходы по налогу на имущество","Расходы по налогу на транспортные ср-ва",
                                    "Сбор с аукцион продаж","Гос пошлина и прочее",
                                    "По реализации ОС и НМА","По форвардам и фьючерсам",
                                    "Штрафы,пени","прочие расходы от банковск деят-ти",
                                    "Расходы по гарант страхованию вкладов", 
                                    "Представит.затраты, связ. с проведением праздничных мероприятий, соревнований и др.",
                                    "Оплаченные подох налог на нерез",
                                    "Прочие расходы не связан с банк деят-тью",
 				    "Расходы по аренде","Расходы по акцептам",
  		                    "Чрезвычайные расходы",
                                    "КНП, уплачен в бюджет","Кнп удержан нерезидентом"]. /*счета доходов*/

def {1} shared var totgl2 as char extent 32 init ["405000","410000","420100","425000","435000","440100","440300","441100",
                                       "441700","442800","442900","445000","446500","450000","460100",
                                       "460200","460300", "460400", "460600","460700",
                                       "460800", "461000","461300","461400",
					"461100","461200", "470000","485000","489000", "490000","492000","494000" ].
def {1} shared var des2 as char extent 32 init  ["Доходы по корр счетам",
                                    "Доходы по вкладам размещенным в НБРК",
                                    "Доходы по ЦБ для торговли",
                                    "Доходы по вкладам размещенным в др банках",
                                    "Доходы по расчетам банка с филиалами",
                                    "По овердрафтам,предост клиентам",
                                    "Доход по кред картам",
                                    "Начислен и получен дох по краткоср кредитам (юр.физ л",
                                    "Начислен и получен дох по долгоср кредитам (юр.физ л)",
                                    "Доход по проч кред операциям" ,
                                    "Ком возн по займам, клиент юр/физ лиц",
                                    "Доходы по прочим ценным бумагам",
                                    "Возн по оп Обр РЕПО с ЦБ",
                                    "Доходы по дилинговым операциям", 
                                    "Комиссии по переводным операциям", 
                                    "Комис по реализации страх полисов",
                                    "Комисс по купле-продаже ЦБ",
                                    "Комисс по купле-продаже ин валюты",
                                    "Комис по выданным гарантиям без НДС", 
                                    "Комис по приему вкл. откр. и ведению счетов", 
                                    "Прочие комиссионные доходы банка", 
                                    "Доходы на акцепт чеков",
                                    "Комис дох по форфейт операц",
			            "Комис дох за усл банка по фактор операций",
                                    "Комисс вознагражд за услуги по кассовым операциям",
                                    "Комис дох по документарным операциям",
                                    "Доходы от переоценки",
                                    "Доходы от продаж ЦБ с нефиксир дох, осн ср-в",
                                    "Доход по операциям с производными инструментами",
                                    "Штрафы",
                                    "Прочие доходы ",
                                    "Чрезвычайные доходы"  ].
def {1} shared var months as char extent 12 init ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь","октябрь", "ноябрь", "декабрь"].

def {1} shared var names as char extent 35 init ["Списки сотрудников банка", 
                                      "Затраты на оплату труда одного работника Банка",
                                      "Затраты на амортизацию ОС, закрепленных за сотрудником", 
                                      "Затраты Банка на подготовку и переподготовку персонала", 
                                      "Расшифровка затрат на услуги связи, в части затрат на сотовые и персональные телефоны",
                                      "Прочие административные затраты Банка", 
                                      "Сведения по расходам по аренде", 
                                      "Сведения по расходам по текущему ремонту",
                                      "Затраты Банка на обеспечение персонала товарно-материальными ценностями (запасы), бланочной продукцией, канцелярскими товарами,приобретение печатной продукции",
                                      "Затраты  Банка  на коммунальные услуги", 
                          /*pril11*/  "Затраты Банка  на услуги", 
                          /*pril12*/  "Затраты Банка  на ТМЦ,ГСМ,запчасти, по реализации ОС", 
                          /*pril13*/  "Затраты Банка на налоги,штрафы,за гарантированные вклады", 
                          /*pril14*/  "Затраты Банка на прочие от банковской и небанковской деятельности",
                          /*pril15*/  "Расходы по межбанку", 
                          /*pril16*/  "Расходы по депозитам", 
                          /*pril17*/  "Расходы по ЦБ", 
                          /*pril18*/  "Расходы по провизиям", 
                          /*pril19*/  "Расходы по иностранной валюте", 
                          /*pril20*/  "Расходы по комиссиям",
                          /*pril21*/  "Ведомость персонифицируемых затрат по немонетарной деятельности", 
                                      "Персонификация затрат(затраты на одного работника Банка)",
                                      "Персонификация затрат  подразделения", 
                          /*pril24*/  "Карточка затрат",
                          /*pril25*/  "",
                          /*pril26*/  "",
                                      "",
                                      "",
                          /*pril29*/  "",
                          /*pril30*/  "Процентные доходы",
                          /*pril31*/  "Непроцентные доходы",
                                      "Комисионные доходы",
                                      "Прочие комиссионные доходы",
                          /*pril34*/  "Прочие доходы",
                          /*pril35*/  "Сводная ведомость доходов" ].
