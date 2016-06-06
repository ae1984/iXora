/* repFS_BB.p

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Сведения по остаткам на балансовых счетах за вычетом специальных резервов (провизий)
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
        26/11/2012 Luiza
 * CHANGES
        28/11/2012 Luiza уменьшила формат вывода сообщения до 70 символов
        10/01/2013 Luiza изменила присвоение значения v-gldate
        23/01/2013 Luiza изменила присвоение значения v-gldate
*/


{mainhead.i}

def new shared var dt1 as date no-undo.
def new shared var v-fil-cnt as char.
def new shared var v-fil-int as int init 0.
def new shared var v-ful as logic format "да/нет" no-undo.
def new shared var v-ful1 as logic format "да/нет" no-undo.

def stream v-out.
def var prname as char.
def var v-select1 as int no-undo.
def var lll as int.


def frame f-date
   dt1   label " Дата отчета за " format "99/99/9999" validate(dt1 <= g-today, "Некорректная дата!")  skip
   v-ful label " С расшифровкой" skip
   v-ful1 label " С расшифровкой по займам" skip
with side-labels centered row 7 title "Параметры отчета".


update  dt1 v-ful v-ful1 with frame f-date.

v-select1 = 0.
def var v-raz as char  no-undo.

run sel2 (" Выберите ", "1.В тыс.тенге |2.В тенге|3. ВЫХОД ", output v-select1).
if keyfunction (lastkey) = "end-error" or v-select1 = 3 then return.
if v-select1 = 1 then v-raz = "тыс.тенге". else v-raz = "тенге".

def temp-table dif  /* для расчета расхождений  */
      field gl like gl.gl
      field crc like crc.crc
      field sum_gl as deci
      field sum_gl_kzt as deci
      field sum_lon as deci
      index gl_idx is primary gl
      index glcrc_idx is unique gl crc.

def new shared temp-table wrkt no-undo
    field cod as int
    field des as char
    field sum as decim
    field sumv as decim
    field sum1 as decim /* резидент */
    field sumv1 as decim /* резидент */
    field sum2 as decim /* не резидент */
    field sumv2 as decim /* не резидент */
    index idx is primary cod.

    create wrkt.
    wrkt.cod = 1. wrkt.des = "Активы".
    create wrkt.
    wrkt.cod = 2. wrkt.des = "Вклады в Национальном Банке Республики Казахстан".
    create wrkt.
    wrkt.cod = 3. wrkt.des = "Корреспонденские счета (за вычетом резервов (провизий)), в том числе".
    create wrkt.
    wrkt.cod = 4. wrkt.des = "– у резидентов Республики Казахстан  (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 5. wrkt.des = "- у нерезидентов Республики Казахстан (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 6. wrkt.des = "Вклады, размещенные в других банках (за вычетом резервов (провизий)), в том числе".
    create wrkt.
    wrkt.cod = 7. wrkt.des = "- у резидентов Республики Казахстан (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 8. wrkt.des = "- у нерезидентов Республики Казахстан (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 9. wrkt.des = "Займы, предоставленные  банкам и организациям, осуществляющим отдельные виды банковских операций (за вычетом (провизий)), в том числе".
    create wrkt.
    wrkt.cod = 10. wrkt.des = "- резидентам Республики Казахстан (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 11. wrkt.des = "- нерезидентам Республики Казахстан (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 12. wrkt.des = "Ценные бумаги, учитываемые по справедливой стоимости через прибыль или убыток (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 13. wrkt.des = "Ценные бумаги, имеющиеся в наличие для продажи (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 14. wrkt.des = "Ценные бумаги, удерживаемые до погашения (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 15. wrkt.des = "Операции 'Обратное РЕПО' с ценными бумагами (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 16. wrkt.des = "Займы, предоставленные юридическим лицам (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 17. wrkt.des = "Займы, предоставленные физическим лицам (за вычетом резервов (провизий)), в том числе".
    create wrkt.
    wrkt.cod = 18. wrkt.des = "на потребительские цели (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 19. wrkt.des = "на строительство, покупку и (или) ремонт жилья (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 20. wrkt.des = "прочие займы (за вычетом резервов (провизий))".
    create wrkt.
    wrkt.cod = 21. wrkt.des = "Инвестиции в капитал".
    create wrkt.
    wrkt.cod = 22. wrkt.des = "Субординированный долг".
    create wrkt.
    wrkt.cod = 23. wrkt.des = "Итого активы, приносящие доход".
    create wrkt.
    wrkt.cod = 24. wrkt.des = "Деньги".
    create wrkt.
    wrkt.cod = 25. wrkt.des = "Аффинированные драгоценные металлы".
    create wrkt.
    wrkt.cod = 26. wrkt.des = "Обязательные резервы в Национальном Банке Республики Казахстан".
    create wrkt.
    wrkt.cod = 27. wrkt.des = "Основные средства (за вычетом амортизации)".
    create wrkt.
    wrkt.cod = 28. wrkt.des = "Нематериальные активы (за вычетом амортизации)".
    create wrkt.
    wrkt.cod = 29. wrkt.des = "Прочие активы, в том числе".
    create wrkt.
    wrkt.cod = 30. wrkt.des = "- требования по производным финансовым инструментам".
    create wrkt.
    wrkt.cod = 31. wrkt.des = "- требования по операциям спот".
    create wrkt.
    wrkt.cod = 32. wrkt.des = "- отсроченный подоходный налог".
    create wrkt.
    wrkt.cod = 33. wrkt.des = "- начисленные проценты к получению".
    create wrkt.
    wrkt.cod = 34. wrkt.des = "- предоплата  (расходы)".
    create wrkt.
    wrkt.cod = 35. wrkt.des = "Справочно: резервы (провизии)".
    create wrkt.
    wrkt.cod = 36. wrkt.des = "Справочно: амортизация".
    create wrkt.
    wrkt.cod = 37. wrkt.des = "Обязательства".
    create wrkt.
    wrkt.cod = 38. wrkt.des = "Обязательства перед Национальным Банком Республики Казахстан".
    create wrkt.
    wrkt.cod = 39. wrkt.des = "Обязательства перед банками второго уровня и организациями, осуществляющими отдельные виды банковских операций, в том числе".
    create wrkt.
    wrkt.cod = 40. wrkt.des = "- корреспонденские счета".
    create wrkt.
    wrkt.cod = 41. wrkt.des = "резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 42. wrkt.des = "нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 43. wrkt.des = "- займы, полученные".
    create wrkt.
    wrkt.cod = 44. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 45. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 46. wrkt.des = "- вклады, привлеченные".
    create wrkt.
    wrkt.cod = 47. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 48. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 49. wrkt.des = "Займы, полученные от иностранных центральных банков".
    create wrkt.
    wrkt.cod = 50. wrkt.des = "Займы, полученные от международных финансовых организаций".
    create wrkt.
    wrkt.cod = 51. wrkt.des = "Вклады, привлеченные от физических лиц, в том числе".
    create wrkt.
    wrkt.cod = 52. wrkt.des = "- текущие и карт-счета".
    create wrkt.
    wrkt.cod = 53. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 54. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 55. wrkt.des = "Справочно: суммы подлежащие гарантированию".
    create wrkt.
    wrkt.cod = 56. wrkt.des = "- вклады до востребования".
    create wrkt.
    wrkt.cod = 57. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 58. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 59. wrkt.des = "Справочно: суммы подлежащие гарантированию".
    create wrkt.
    wrkt.cod = 60. wrkt.des = "- условные вклады".
    create wrkt.
    wrkt.cod = 61. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 62. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 63. wrkt.des = "Справочно: суммы подлежащие гарантированию".
    create wrkt.
    wrkt.cod = 64. wrkt.des = "- срочные вклады".
    create wrkt.
    wrkt.cod = 65. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 66. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 67. wrkt.des = "Справочно: суммы подлежащие гарантированию".
    create wrkt.
    wrkt.cod = 68. wrkt.des = "Вклады, привлеченные от юридических лиц, в том числе".
    create wrkt.
    wrkt.cod = 69. wrkt.des = "- текущие и карт-счета".
    create wrkt.
    wrkt.cod = 70. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 71. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 72. wrkt.des = "- вклады до востребования".
    create wrkt.
    wrkt.cod = 73. wrkt.des = "от резидентов   Республики Казахстан".
    create wrkt.
    wrkt.cod = 74. wrkt.des = "от нерезидентов  Республики Казахстан".
    create wrkt.
    wrkt.cod = 75. wrkt.des = "- условные вклады".
    create wrkt.
    wrkt.cod = 76. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 77. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 78. wrkt.des = "- срочные вклады".
    create wrkt.
    wrkt.cod = 79. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 80. wrkt.des = "от нерезидентов  Республики Казахстан".
    create wrkt.
    wrkt.cod = 81. wrkt.des = "- вклады дочерних организаций специального назначения".
    create wrkt.
    wrkt.cod = 82. wrkt.des = "от резидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 83. wrkt.des = "от нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 84. wrkt.des = "Деньги, принятые в качестве обеспечения (заклад, задаток) обязательств клиентов".
    create wrkt.
    wrkt.cod = 85. wrkt.des = "Займы, полученные от Правительства Республики Казахстан и местных органов власти Республики Казахстан".
    create wrkt.
    wrkt.cod = 86. wrkt.des = "Ценные бумаги, выпущенные в обращение".
    create wrkt.
    wrkt.cod = 87. wrkt.des = "Операции 'РЕПО' с ценными бумагами".
    create wrkt.
    wrkt.cod = 88. wrkt.des = "с резидентами  Республики Казахстан".
    create wrkt.
    wrkt.cod = 89. wrkt.des = "с нерезидентами  Республики Казахстан".
    create wrkt.
    wrkt.cod = 90. wrkt.des = "Субординированный долг".
    create wrkt.
    wrkt.cod = 91. wrkt.des = "у резидентов  Республики Казахстан".
    create wrkt.
    wrkt.cod = 92. wrkt.des = "у нерезидентов Республики Казахстан".
    create wrkt.
    wrkt.cod = 93. wrkt.des = "Итого обязательства, влекущие расход".
    create wrkt.
    wrkt.cod = 94. wrkt.des = "Специальные резервы на покрытие убытков по условным обязательствам".
    create wrkt.
    wrkt.cod = 95. wrkt.des = "Прочие обязательства, в том числе".
    create wrkt.
    wrkt.cod = 96. wrkt.des = "обязательства по производным финансовым инструментам".
    create wrkt.
    wrkt.cod = 97. wrkt.des = "обязательства по операциям спот".
    create wrkt.
    wrkt.cod = 98. wrkt.des = "обязательства по подоходному налогу".
    create wrkt.
    wrkt.cod = 99. wrkt.des = "начисленные проценты к оплате".
    create wrkt.
    wrkt.cod = 100. wrkt.des = "предоплата (доходы)".
    create wrkt.
    wrkt.cod = 101. wrkt.des = "Собственный капитал".
    create wrkt.
    wrkt.cod = 102. wrkt.des = "Уставный капитал".
    create wrkt.
    wrkt.cod = 103. wrkt.des = "Дополнительный капитал".
    create wrkt.
    wrkt.cod = 104. wrkt.des = "Нераспределенный чистый доход и резерв капитала:".
    create wrkt.
    wrkt.cod = 105. wrkt.des = "доход (непокрытый убыток) предыдущих лет".
    create wrkt.
    wrkt.cod = 106. wrkt.des = "доход (непокрытый убыток) текущего года".
    create wrkt.
    wrkt.cod = 107. wrkt.des = "резерв капитала".
    create wrkt.
    wrkt.cod = 108. wrkt.des = "Резервы переоценки основных средств".
    create wrkt.
    wrkt.cod = 109. wrkt.des = "Резервы переоценки стоимости ценных бумаг, имеющихся в наличии для продажи".
    create wrkt.
    wrkt.cod = 110. wrkt.des = "Резервы (провизии) на общебанковские риски".
    create wrkt.
    wrkt.cod = 111. wrkt.des = "Счет корректировки резервов (провизий)".
    create wrkt.
    wrkt.cod = 112. wrkt.des = "Резервы по прочей переоценке".
    create wrkt.
    wrkt.cod = 113. wrkt.des = "Выкупленные банком собственные акции".
    create wrkt.
    wrkt.cod = 114. wrkt.des = "Итого обязательства и капитал".
    create wrkt.
    wrkt.cod = 115. wrkt.des = "Справочно: активы, номинированные в тенге, индексированные к иностранной валюте".
    create wrkt.
    wrkt.cod = 116. wrkt.des = "Справочно: обязательства, номинированные в тенге, индексированные к иностранной валюте".


def new shared temp-table sootv no-undo
    field tot as int  /* код справочника */
    field cod as int  /* код отчета  */
    field gl4 as char
    index idx is primary cod.


    /*sootv.cod = ГР	1000*/
    create sootv. sootv.cod = 24.	sootv.gl4 = "1001".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1002".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1003".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1004".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1005".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1006".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1007".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1008".
    create sootv. sootv.cod = 24.	sootv.gl4 = "1009".
    /*sootv.cod = ГР.	sootv.gl4 = "1010".*/
    create sootv. sootv.cod = 25.	sootv.gl4 = "1011".
    create sootv. sootv.cod = 25.	sootv.gl4 = "1012".
    create sootv. sootv.cod = 25.	sootv.gl4 = "1013".
    /*sootv.cod = ГР.	sootv.gl4 = "1050".*/
    create sootv. sootv.cod = 2.	sootv.gl4 = "1051".
    create sootv. sootv.cod = 3.	sootv.gl4 = "1052".
    create sootv. sootv.tot = 35. sootv.cod = 3.	sootv.gl4 = "1054".
    /*sootv.cod = ГР.	sootv.gl4 = "1100".*/
    create sootv. sootv.cod = 2.	sootv.gl4 = "1101".
    create sootv. sootv.cod = 2.	sootv.gl4 = "1102".
    create sootv. sootv.cod = 2.	sootv.gl4 = "1103".
    create sootv. sootv.cod = 26.	sootv.gl4 = "1104".
    create sootv. sootv.cod = 2.	sootv.gl4 = "1105".
    create sootv. sootv.cod = 2.	sootv.gl4 = "1106".
    /*sootv.cod = НК.	sootv.gl4 = "1150".*/
    /*sootv.cod = ГР.	sootv.gl4 = "1200".*/
    create sootv. sootv.cod = 12.	sootv.gl4 = "1201".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1202".
    create sootv. sootv.tot = 35. sootv.cod = 12.	sootv.gl4 = "1204".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1205".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1206".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1207".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1208".
    create sootv. sootv.cod = 12.	sootv.gl4 = "1209".
    /*sootv.cod = ГР.	sootv.gl4 = "1250".*/
    create sootv. sootv.cod = 6.	sootv.gl4 = "1251".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1252".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1253".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1254".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1255".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1256".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1257".
    create sootv. sootv.tot = 35. sootv.cod = 6.	sootv.gl4 = "1259".
    /*sootv.cod = ГР.	sootv.gl4 = "1260".*/
    create sootv. sootv.cod = 6.	sootv.gl4 = "1261".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1262".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1263".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1264".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1265".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1266".
    create sootv. sootv.cod = 6.	sootv.gl4 = "1267".
    /*sootv.cod = ГР.	sootv.gl4 = "1300".*/
    create sootv. sootv.cod =  9.	sootv.gl4 = "1301".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1302".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1303".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1304".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1305".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1306".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1309".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1310".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1311".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1312".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1313".
    create sootv. sootv.tot = 35. sootv.cod =  9.	sootv.gl4 = "1319".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1320".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1321".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1322".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1323".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1324".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1325".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1326".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1327".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1328".
    create sootv. sootv.tot = 35. sootv.cod =  9.	sootv.gl4 = "1329".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1330".
    create sootv. sootv.cod =  9.	sootv.gl4 = "1331".
    /*sootv.cod =  ГР.	sootv.gl4 = "1350".*/
    /*sootv.cod =  ГР.	sootv.gl4 = "1400".*/
    /*create sootv. sootv.cod = 16.	sootv.gl4 = "1401".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1403".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1405".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1406".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1407".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1409".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1411".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1417".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1420".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1421".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1422".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1423".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1424".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1425".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1426".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1427".
    create sootv. sootv.tot = 35. sootv.cod = 16.	sootv.gl4 = "1428".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1429".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1430".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1431".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1432".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1433".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1434".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1435".
    create sootv. sootv.cod = 16.	sootv.gl4 = "1445".*/

    create sootv. sootv.cod = 17.	sootv.gl4 = "1401".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1403".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1405".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1406".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1407".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1409".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1411".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1417".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1420".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1421".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1422".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1423".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1424".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1425".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1426".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1427".
    create sootv. sootv.tot = 35. sootv.cod = 17.	sootv.gl4 = "1428".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1429".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1430".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1431".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1432".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1433".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1434".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1435".
    create sootv. sootv.cod = 17.	sootv.gl4 = "1445".

    create sootv. sootv.cod = 13.	sootv.gl4 = "1450".
    create sootv. sootv.tot = 35. sootv.cod = 13.	sootv.gl4 = "1451".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1452".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1453".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1454".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1455".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1456".
    create sootv. sootv.cod = 13.	sootv.gl4 = "1457".
    create sootv. sootv.cod = 15.	sootv.gl4 = "1458".
    /*sootv.cod = ГР.	sootv.gl4 = "1470".*/
    create sootv. sootv.cod = 21.	sootv.gl4 = "1471".
    create sootv. sootv.cod = 21.	sootv.gl4 = "1472".
    /*sootv.cod = НК.	sootv.gl4 = "1473".*/
    create sootv. sootv.cod = 22.	sootv.gl4 = "1475".
    create sootv. sootv.cod = 21.	sootv.gl4 = "1476".
    create sootv. sootv.cod = 14.	sootv.gl4 = "1480".
    create sootv. sootv.cod = 14.	sootv.gl4 = "1481".
    create sootv. sootv.cod = 14.	sootv.gl4 = "1482".
    create sootv. sootv.cod = 14.	sootv.gl4 = "1483".
    create sootv. sootv.cod = 14.	sootv.gl4 = "1484".
    /*sootv.cod = ГР.	sootv.gl4 = "1550".*/
    /*sootv.cod = ГР.	sootv.gl4 = "1600".*/
    create sootv. sootv.cod = 29.	sootv.gl4 = "1601".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1602".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1603".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1604".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1610".
    /*sootv.cod = ГР.	sootv.gl4 = "1650".*/
    /*sootv.cod = ГР.	sootv.gl4 = "1690".*/
    create sootv. sootv.cod = 27.	sootv.gl4 = "1651".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1652".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1653".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1654".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1655".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1656".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1657".
    create sootv. sootv.cod = 27.	sootv.gl4 = "1658".
    create sootv. sootv.cod = 28.	sootv.gl4 = "1659".
    create sootv. sootv.cod = 28.	sootv.gl4 = "1660".
    create sootv. sootv.cod = 28.	sootv.gl4 = "1661".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1692".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1693".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1694".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1695".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1696".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1697".
    create sootv. sootv.tot = 36. sootv.cod = 27.	sootv.gl4 = "1698".
    create sootv. sootv.tot = 36. sootv.cod = 28.	sootv.gl4 = "1699".
    /*sootv.cod = ГР.	sootv.gl4 = "1700*/
    create sootv. sootv.cod = 33.	sootv.gl4 = "1705".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1710".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1725".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1726".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1727".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1728".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1730".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1731".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1733".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1734".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1735".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1740".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1741".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1744".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1745".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1746".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1747".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1748".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1749".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1752".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1753".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1755".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1756".
    /*sootv.cod = НК.	sootv.gl4 = "1771".
    create sootv. sootv.cod = НК.	sootv.gl4 = "1772".*/
    /*sootv.cod = ГР.	sootv.gl4 = "1790".*/
    create sootv. sootv.cod = 34.	sootv.gl4 = "1792".
    create sootv. sootv.cod = 34.	sootv.gl4 = "1793".
    create sootv. sootv.cod = 34.	sootv.gl4 = "1799".
    /*sootv.cod = ГР.	sootv.gl4 = "1810".*/
    create sootv. sootv.cod = 33.	sootv.gl4 = "1811".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1812".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1813".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1814".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1815".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1816".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1817".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1818".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1819".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1820".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1821".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1822".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1823".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1824".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1825".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1826".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1827".
    /*sootv.cod = ГР.	sootv.gl4 = "1830".*/
    create sootv. sootv.cod = 33.	sootv.gl4 = "1831".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1832".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1833".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1834".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1835".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1836".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1837".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1838".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1839".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1840".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1841".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1842".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1843".
    create sootv. sootv.cod = 33.	sootv.gl4 = "1844".
    /*sootv.cod = ГР.	sootv.gl4 = "1850".*/
    create sootv. sootv.cod = 29.	sootv.gl4 = "1851".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1852".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1853".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1854".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1855".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1856".
    create sootv. sootv.cod = 32.	sootv.gl4 = "1857".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1860".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1861".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1864".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1867".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1870".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1873".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1874".
    create sootv. sootv.tot = 35. sootv.cod = 29.	sootv.gl4 = "1876".
    create sootv. sootv.tot = 35. sootv.cod = 29.	sootv.gl4 = "1877".
    create sootv. sootv.tot = 35. sootv.cod = 29.	sootv.gl4 = "1878".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1879".
    create sootv. sootv.cod = 29.	sootv.gl4 = "1880".
    /* sootv.cod = ГР.	sootv.gl4 = "1890". */
    create sootv. sootv.cod = 30.	sootv.gl4 = "1891".
    create sootv. sootv.cod = 30.	sootv.gl4 = "1892".
    create sootv. sootv.cod = 30.	sootv.gl4 = "1893".
    create sootv. sootv.cod = 31.	sootv.gl4 = "1894".
    create sootv. sootv.cod = 30.	sootv.gl4 = "1895".
    create sootv. sootv.cod = 30.	sootv.gl4 = "1899".
    /* sootv.cod = ГР.	sootv.gl4 = "2010 */
    create sootv. sootv.cod = 38.	sootv.gl4 = "2011".
    create sootv. sootv.cod = 40.	sootv.gl4 = "2012".
    create sootv. sootv.cod = 40.	sootv.gl4 = "2013".
    create sootv. sootv.cod = 40.   sootv.gl4 = "2014".
    create sootv. sootv.cod = 40.	sootv.gl4 = "2016".
    /* sootv.cod = ГР.	sootv.gl4 = "2020 */
    create sootv. sootv.cod = 38.	sootv.gl4 = "2021".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2022".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2023".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2024".
    /* sootv.cod = ГР.	sootv.gl4 = "2030". */
    create sootv. sootv.cod = 85.   sootv.gl4 = "2034".
    create sootv. sootv.cod = 85.	sootv.gl4 = "2035".
    create sootv. sootv.cod = 85.	sootv.gl4 = "2036".
    create sootv. sootv.cod = 85.	sootv.gl4 = "2037".
    create sootv. sootv.cod = 85.	sootv.gl4 = "2038".
    /*sootv.cod = ГР.	sootv.gl4 = "2040".*/
    create sootv. sootv.cod = 50.	sootv.gl4 = "2044".
    create sootv. sootv.cod = 50.	sootv.gl4 = "2045".
    create sootv. sootv.cod = 50.	sootv.gl4 = "2046".
    create sootv. sootv.cod = 50.	sootv.gl4 = "2047".
    create sootv. sootv.cod = 50.	sootv.gl4 = "2048".
    /*sootv.cod = НК.	sootv.gl4 = "2050".*/
    create sootv. sootv.cod = 38.	sootv.gl4 = "2051".
    create sootv. sootv.cod = 49.	sootv.gl4 = "2052".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2054".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2055".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2056".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2057".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2058".
    create sootv. sootv.cod = 38.	sootv.gl4 = "2059".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2064".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2065".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2066".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2067".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2068".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2069".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2070".
    /*sootv.cod = ГР.	sootv.gl4 = "2110".*/
    create sootv. sootv.cod = 38.	sootv.gl4 = "2111".
    create sootv. sootv.cod = 49.	sootv.gl4 = "2112".
    create sootv. sootv.cod = 43.	sootv.gl4 = "2113".
    /*sootv.cod = ГР.	sootv.gl4 = "2120".*/
    create sootv. sootv.cod = 38.	sootv.gl4 = "2121".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2122".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2123".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2124".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2125".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2126".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2127".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2128".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2129".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2130".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2131".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2133".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2135".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2136".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2137".
    create sootv. sootv.cod = 46.	sootv.gl4 = "2138".
    create sootv. sootv.cod = 38.	sootv.gl4 = "2139 ".
    create sootv. sootv.cod = 38.	sootv.gl4 = "2140".
    /*sootv.cod = ГР.	sootv.gl4 = "2150".*/
    /*sootv.cod = ГР.	sootv.gl4 = "2200".*/
    /*sootv.cod = НК.	sootv.gl4 = "2201".*/
    create sootv. sootv.cod = 69.	sootv.gl4 = "2203".
    create sootv. sootv.cod = 52.	sootv.gl4 = "2204".
    create sootv. sootv.cod = 56.	sootv.gl4 = "2205".
    create sootv. sootv.cod = 64.	sootv.gl4 = "2206".
    create sootv. sootv.cod = 64.	sootv.gl4 = "2207".
    create sootv. sootv.cod = 60.	sootv.gl4 = "2208".
    create sootv. sootv.cod = 52.	sootv.gl4 = "2209".
    /*sootv.cod = НК.	sootv.gl4 = "2210".*/
    create sootv. sootv.cod = 72.	sootv.gl4 = "2211".
   create sootv.  sootv.tot = 56. sootv.cod = 72.	sootv.gl4 = "2212".
    create sootv. sootv.cod = 84.	sootv.gl4 = "2213".
    create sootv. sootv.cod = 78.	sootv.gl4 = "2215".
    create sootv. sootv.tot = 64. sootv.cod = 78.	sootv.gl4 = "2216".
    create sootv. sootv.cod = 78.	sootv.gl4 = "2217".
    create sootv. sootv.cod = 75.	sootv.gl4 = "2219".
    create sootv. sootv.cod = 69.	sootv.gl4 = "2221".
    create sootv. sootv.cod = 81.	sootv.gl4 = "2222".
    create sootv. sootv.cod = 84.	sootv.gl4 = "2223".
    create sootv. sootv.tot = 56. sootv.cod = 72.	sootv.gl4 = "2224".
    /*sootv.cod = НК.	sootv.gl4 = "2225".*/
    create sootv. sootv.tot = 64. sootv.cod = 78.	sootv.gl4 = "2226".
    /*sootv.cod = НК.	sootv.gl4 = "2227".
    create sootv. sootv.cod = НК.	sootv.gl4 = "2228".
    create sootv. sootv.cod = НК.	sootv.gl4 = "2230".*/
    create sootv. sootv.tot = 60. sootv.cod = 75.	sootv.gl4 = "2232".
   /* create sootv. sootv.cod = НК.	sootv.gl4 = "2233".
    create sootv. sootv.cod = НК.	sootv.gl4 = "2234".
    create sootv. sootv.cod = НК.	sootv.gl4 = "2235".
    create sootv. sootv.cod = НК.	sootv.gl4 = "2236".*/
    create sootv. sootv.cod = 95.	sootv.gl4 = "2237".
    create sootv. sootv.cod = 81.	sootv.gl4 = "2238".
    create sootv. sootv.cod = 81.	sootv.gl4 = "2239".
    create sootv. sootv.cod = 84.	sootv.gl4 = "2240".
    /*sootv.cod = НК.	sootv.gl4 = "2245".*/
    create sootv. sootv.cod = 87.	sootv.gl4 = "2255".
    /*sootv.cod = ГР.	sootv.gl4 = "2300".*/
    create sootv. sootv.cod = 86.	sootv.gl4 = "2301".
    create sootv. sootv.cod = 86.	sootv.gl4 = "2303".
    create sootv. sootv.cod = 86.	sootv.gl4 = "2304".
    create sootv. sootv.cod = 86.	sootv.gl4 = "2305".
    create sootv. sootv.cod = 86.	sootv.gl4 = "2306".
    /*sootv.cod = ГР.	sootv.gl4 = "2400".*/
    create sootv. sootv.cod = 90.	sootv.gl4 = "2401".
    create sootv. sootv.cod = 90.	sootv.gl4 = "2402".
    create sootv. sootv.cod = 90.	sootv.gl4 = "2403".
    create sootv. sootv.cod = 90.	sootv.gl4 = "2404".
    create sootv. sootv.cod = 90.	sootv.gl4 = "2405".
    create sootv. sootv.cod = 90.	sootv.gl4 = "2406".
    /*sootv.cod = НК.	sootv.gl4 = "2451".*/
    /*sootv.cod = ГР.	sootv.gl4 = "2550*/
    create sootv. sootv.cod = 95.	sootv.gl4 = "2551".
    /*sootv.cod = НК.	sootv.gl4 = "2552".*/
    /*sootv.cod = ГР.	sootv.gl4 = "2700".*/
    create sootv. sootv.cod = 99.	sootv.gl4 = "2701".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2702".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2703".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2704".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2705".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2706".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2707".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2708".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2711".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2712".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2713".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2714".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2715".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2717".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2718".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2719".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2720".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2721".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2722".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2723".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2725".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2726".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2727".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2730".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2731".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2740".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2741".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2742".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2743".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2744".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2745".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2746".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2747".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2748".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2749".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2755".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2756".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2757".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2770".
    /*sootv.cod = ГР.	sootv.gl4 = "2790".*/
    create sootv. sootv.cod = 100.	sootv.gl4 = "2792".
    create sootv. sootv.cod = 100.	sootv.gl4 = "2793".
    create sootv. sootv.cod = 100.	sootv.gl4 = "2794".
    create sootv. sootv.cod = 100.	sootv.gl4 = "2799".
    /*sootv.cod = ГР.	sootv.gl4 = "2810".*/
    create sootv. sootv.cod = 99.	sootv.gl4 = "2811".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2812".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2813".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2814".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2815".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2816".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2817".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2818".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2819".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2820".
    /*sootv.cod = ГР.	sootv.gl4 = "2830".*/
    create sootv. sootv.cod = 99.	sootv.gl4 = "2831".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2832".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2833".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2834".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2835".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2836".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2838".
    create sootv. sootv.cod = 99.	sootv.gl4 = "2839".
    /*sootv.cod = ГР.	sootv.gl4 = "2850".*/
    create sootv. sootv.cod = 95.	sootv.gl4 = "2851".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2852".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2853".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2854".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2855".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2856".
    create sootv. sootv.cod = 98.	sootv.gl4 = "2857".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2860".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2861".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2862".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2863".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2864".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2867".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2868".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2869".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2870".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2871".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2872".
    create sootv. sootv.cod = 95.	sootv.gl4 = "2873".
    create sootv. sootv.cod = 94.	sootv.gl4 = "2875".
    /*sootv.cod = НК.	sootv.gl4 = "2880".*/
    /*sootv.cod = ГР.	sootv.gl4 = "2890".*/
    create sootv. sootv.cod = 96.	sootv.gl4 = "2891".
    create sootv. sootv.cod = 96.	sootv.gl4 = "2892".
    create sootv. sootv.cod = 96.	sootv.gl4 = "2893".
    create sootv. sootv.cod = 97.   sootv.gl4 = "2894".
    create sootv. sootv.cod = 96.	sootv.gl4 = "2895".
    create sootv. sootv.cod = 96.	sootv.gl4 = "2899".
    /*sootv.cod = ГР.	sootv.gl4 = "3000". */
    create sootv. sootv.cod = 102.	sootv.gl4 = "3001".
    create sootv. sootv.cod = 113.	sootv.gl4 = "3003".
    create sootv. sootv.cod = 102.	sootv.gl4 = "3025".
    create sootv. sootv.cod = 113.	sootv.gl4 = "3027".
    /*sootv.cod = ГР.	sootv.gl4 = "3100".*/
    create sootv. sootv.cod = 103.	sootv.gl4 = "3101".
    create sootv. sootv.cod = 110.	sootv.gl4 = "3200".
    /*sootv.cod = ГР.	sootv.gl4 = "3300".*/
    create sootv. sootv.cod = 111.	sootv.gl4 = "3301".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3302".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3303".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3304".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3305".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3306".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3307".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3308".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3309".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3310".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3311".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3312".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3313".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3314".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3315".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3316".
    /*sootv.cod = ГР.	sootv.gl4 = "3500".*/
    create sootv. sootv.cod = 107.	sootv.gl4 = "3510".
    create sootv. sootv.cod = 108.	sootv.gl4 = "3540".
    create sootv. sootv.cod = 109.	sootv.gl4 = "3561".
    create sootv. sootv.cod = 105.	sootv.gl4 = "3580".
    create sootv. sootv.cod = 112.	sootv.gl4 = "3589".
    create sootv. sootv.cod = 111.	sootv.gl4 = "3590".
    create sootv. sootv.cod = 106.	sootv.gl4 = "3599".


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

def var r-type as char.
def var vs-sum as decim.
def var ss as decim.
def var list-pos as int.
def var list-summ as deci extent 17.
def var all-list-summ as deci.

/************************************************************************************************/
function FileExist returns log (input v-name as char).
 def var v-result as char init "".
 input through value ("cat " + v-name + " &>/dev/null || (NO)").
 repeat:
   import unformatted v-result.
 end.
 if v-result = "" then return true.
 else return false.
end function.
/************************************************************************************************/


def var RepName as char.
def var RepPath as char init "/data/reports/array/".
def new shared var v-gldate as date.
find last cls where cls.cls < dt1.
v-gldate = cls.cls.
/*v-gldate = dt1.*/
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
/* счет 1264242 меняем на 1264142 */
for each tgl where string(tgl.gl7) begins "1264" .
    tgl.gl7 = int("126414" + substring(string(tgl.gl7),7,1)).
end.
displ  "Ждите, идет сбор данных для расшифровки № 2 " format "x(70)".

    def var cntsum as decimal no-undo extent 19.
    def new shared var v-reptype as integer no-undo.
    v-reptype = 5.

    def new shared temp-table wrk no-undo
        field bank as char
        field gl like lon.gl
        field name as char
        field schet_gk as char
        field cif like lon.cif
        field lon like lon.lon
        field grp like lon.grp
        field clnsegm as char
        field pooln as char
        field bankn as char
        field crc like crc.crc
        field rdt like lon.rdt
        field isdt as date
        field duedt like lon.duedt
        field dprolong as date
        field prolong as int
        field opnamt as deci
        field opnamt_kzt as deci
        field ostatok as deci
        field pogosh as deci
        field prosr_od as deci
        field dayc_od as int
        field ind_od as deci
        field ostatok_kzt as deci
        field prosr_od_kzt as deci
        field ind_od_kzt as deci
        field pogashen as logi format "да/нет"
        field prem as deci
        field prem_his as deci
        field nach_prc as deci
        field pol_prc as deci
        field prosr_prc as deci
        field dayc_prc as int
        field ind_prc as deci
        field nach_prc_kzt as deci
        field pol_prc_kzt as deci
        field pol_prc_kzt_all as deci
        field prosr_prc_kzt as deci
        field prosr_prc_zabal as deci
        field prosr_prc_zab_kzt as deci
        field ind_prc_kzt as deci
        field prcdt_last as date
        field penalty as deci
        field penalty_zabal as deci
        field penalty_otsr as deci
        field uchastie as logi format "да/нет"
        field obessum_kzt as deci
        field obesdes as char
        field sumgarant as deci
        field sumdepcrd as deci
        field obesall as deci
        field obesall_lev19 as deci
        field neobesp as deci
        field otrasl as char
        field otrasl1 as char
        field finotrasl as char
        field finotrasl1 as char
        field rezprc_afn as deci
        field rezsum_afn as deci
        field rezsum_od as deci
        field rezsum_prc as deci
        field rezsum_pen as deci
        field rezsum_msfo as deci
        field num_dog like loncon.lcnt  /* номер договора */
        field tgt   as char
        field dtlpay as date
        field lpaysum as deci
        field kdstsdes as char
        field kodd  as char
        field rate  as char
        field valdesc  as char
        field valdesc_ob  as char
        field dt  as date
        field rel as char
        field bal11 as deci
        field lneko as char
        field rezid as char
        field val as char
        field scode as char
        field dpnv as date
        field nvng as deci
        field amr_dk  as deci /*Амортизация дисконта*/
        field zam_dk  as deci /*Дисконт по займам*/
        field bal34 as deci
        field lnprod as char
        field napr as char
        field nsumkr as deci
        field nsumkr_kzt as deci
        index ind is primary bank cif.


    def new shared var d-rates as deci no-undo extent 20.
    def new shared var c-rates as deci no-undo extent 20.

    /*find last cls where cls.whn < dt1.
    v-gldate = cls.cls.*/
    v-gldate = dt1.
    for each crc no-lock:
      find last crchis where crchis.crc = crc.crc and crchis.rdt < dt1 no-lock no-error.
      if avail crchis then d-rates[crc.crc] = crchis.rate[1].
      c-rates[crc.crc] = crc.rate[1].
    end.

    def new shared var v-sum_msb as deci no-undo.
    def new shared var v-dt as date no-undo.
    v-sum_msb = 0.
    v-dt = dt1.

    def new shared var v-pool as char no-undo extent 10.
    def new shared var v-poolName as char no-undo extent 10.
    def new shared var v-poolId as char no-undo extent 10.

    v-pool[1] = "27,67".
    v-poolName[1] = "Ипотечные займы".
    v-poolId[1] = "ipoteka".
    v-pool[2] = "28,68".
    v-poolName[2] = "Автокредиты".
    v-poolId[2] = "auto".
    v-pool[3] = "20,60".
    v-poolName[3] = "Прочие потребительские кредиты".
    v-poolId[3] = "flobesp".
    v-pool[4] = "90,92".
    v-poolName[4] = "Потребительские кредиты Бланковые 'Метрокредит'".
    v-poolId[4] = "metro".
    v-pool[5] = "81,82".
    v-poolName[5] = "Потребительские кредиты Бланковые 'Сотрудники'".
    v-poolId[5] = "sotr".
    v-pool[6] = "16,26,56,66".
    v-poolName[6] = "Метро-экспресс МСБ".
    v-poolId[6] = "express-msb".
    v-pool[7] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
    v-poolName[7] = "Кредиты МСБ".
    v-poolId[7] = "msb".
    v-pool[8] = "10,14,15,24,25,50,54,55,64,65,13,23,53,63".
    v-poolName[8] = "Инидивид. МСБ".
    v-poolId[8] = "individ-msb".
    v-pool[9] = "11,21,70,80".
    v-poolName[9] = "факторинг, овердрафты".
    v-poolId[9] = "factover".
    v-pool[10] = "95,96".
    v-poolName[10] = "Ипотека «Астана бонус»".
    v-poolId[10] = "astana-bonus".


    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run msfosk2.
    end.
    if connected ("txb") then disconnect "txb".

    v-sum_msb = round(v-sum_msb / 20,2).
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        displ  "Ждите, идет сбор данных для расшифровки № 2 " + comm.txb.info format "x(70)".
        pause 0.
        run repFS_BB1(v-gldate).
    end.
    if connected ("txb")  then disconnect "txb".

/* вручную добавляем запись в wrk*/
find first tgl where tgl.gl = 143422 no-error. /* ищем Дисконт по долгосрочным займам,предоставленным физич.лицам на счете 143422 */
run differ(142420,v-gldate,output ss).

create wrk.
wrk.bank = 'АО "ForteBank"'.
wrk.schet_gk = "1420191".
wrk.name = "МКО".
/*wrk.cif  = "".
wrk.bankn
wrk.pooln
wrk.grp
wrk.clnsegm
wrk.num_dog*/
wrk.crc = 1.
wrk.tgt = "Гражданам на потребительские цели".
wrk.ostatok_kzt = ss.
wrk.prosr_od_kzt = ss.
wrk.nach_prc_kzt = 0.
wrk.prosr_prc_kzt = 0.
if available tgl then wrk.zam_dk = tgl.sum.
else wrk.zam_dk = 0.
wrk.rezprc_afn = ss.
wrk.rezsum_afn = ss.
wrk.rezsum_od = ss.
wrk.rezsum_prc = 0.
wrk.rezsum_pen = 0.
wrk.rezsum_msfo = ss.
wrk.prem_his = 0.

/*-------------------------------------------------------------------*/
/* заполнение таблицы wrkt данные из tgl*/
/* по настоянию Актолкын добавляем записи в tgl сумму расхождений по счету 142820 и 142420 */
    create tgl.
        tgl.txb = "TXB00".
        tgl.gl4 = 1424.
        tgl.gl7 = 1424191.
        tgl.acc = "".
        tgl.geo = "".
        tgl.acc-des = "МКО".
        tgl.crc = 1.
        tgl.sum = ss .
        tgl.sum-val = ss .
        tgl.odt = ?.
        tgl.cdt = ?.
        tgl.sub = "".
        tgl.gl = 142420.
run differ(142820,v-gldate,output ss).
    create tgl.
        tgl.txb = "TXB00".
        tgl.gl4 = 1428.
        tgl.gl7 = 1428191.
        tgl.acc = "".
        tgl.geo = "".
        tgl.acc-des = "МКО".
        tgl.crc = 1.
        tgl.sum = ss.
        tgl.sum-val = ss.
        tgl.odt = ?.
        tgl.cdt = ?.
        tgl.sub = "".
        tgl.gl = 142820.
    for each wrkt.
        for each sootv where sootv.cod = wrkt.cod no-lock.
            for each tgl where string(tgl.gl7) begins sootv.gl4.
                wrkt.sum = wrkt.sum + tgl.sum.
                if tgl.crc <> 1 then wrkt.sumv = wrkt.sumv + tgl.sum.
                if substring(string(tgl.gl7),5,1) = "1" then do:
                    wrkt.sum1 = wrkt.sum1 + tgl.sum.
                    if tgl.crc <> 1 then wrkt.sumv1 = wrkt.sumv1 + tgl.sum.
                end.
                else do:
                    wrkt.sum2 = wrkt.sum2 + tgl.sum.
                    if tgl.crc <> 1 then wrkt.sumv2 = wrkt.sumv2 + tgl.sum.
                end.
            end.
        end.  /*  for each sootv where sootv.cod = wrkt.cod */
    end.

    /*  для total */
    for each sootv where sootv.tot > 0 no-lock.
        find first wrkt where wrkt.cod = sootv.tot.
        for each tgl where string(tgl.gl7) begins sootv.gl4.
            wrkt.sum = wrkt.sum + tgl.sum.
            if tgl.crc <> 1 then wrkt.sumv = wrkt.sumv + tgl.sum.
            if substring(string(tgl.gl7),5,1) = "1" then do:
                wrkt.sum1 = wrkt.sum1 + tgl.sum.
                if tgl.crc <> 1 then wrkt.sumv1 = wrkt.sumv1 + tgl.sum.
            end.
            else do:
                wrkt.sum2 = wrkt.sum2 + tgl.sum.
                if tgl.crc <> 1 then wrkt.sumv2 = wrkt.sumv2 + tgl.sum.
            end.
        end.
    end. /*  for each sootv where sootv.tot > 0 */

    /* обнуляем суммы в валюте для wrkt.cod >= 101 and wrkt.cod <= 113 */
    for each wrkt where wrkt.cod >= 101 and wrkt.cod <= 113 .
        wrkt.sumv = 0.
    end.

/*  расчет данных из расшифр №2 для 16-20*/

    def var smsfo as decim. /* собираем суммы клонки Резерв МСФО% из займов*/
    def var smsfov as decim. /* собираем суммы клонки Резерв МСФО% из займов for crc <> 1*/
    smsfo = 0.
    smsfov = 0.

    def buffer b-wrkt for wrkt.
    find first wrkt where  wrkt.cod = 16. /* юр */
    wrkt.sum = 0.
    wrkt.sumv = 0.
    for each wrk where substring(wrk.schet_gk,6,1) <> "9" :
        wrkt.sum = wrkt.sum + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od - wrk.rezsum_pen.
        if wrk.crc <> 1 then wrkt.sumv = wrkt.sumv + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od /*- wrk.rezsum_pen.*/.
        smsfo = smsfo +  wrk.rezsum_prc.
        if wrk.crc <> 1 then smsfov = smsfov + wrk.rezsum_prc.
    end.
    find first wrkt where  wrkt.cod = 17. /* физ */
    wrkt.sum = 0.
    wrkt.sumv = 0.
    for each wrk where substring(wrk.schet_gk,6,1) = "9":
        wrkt.sum = wrkt.sum + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od - wrk.rezsum_pen.
        if wrk.crc <> 1 then wrkt.sumv = wrkt.sumv + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od /*- wrk.rezsum_pen.*/.
        smsfo = smsfo +  wrk.rezsum_prc.
        if wrk.crc <> 1 then smsfov = smsfov + wrk.rezsum_prc.
    end.
    find first wrkt where  wrkt.cod = 18.
    wrkt.sum = 0.
    wrkt.sumv = 0.
    for each wrk where substring(wrk.schet_gk,6,1) = "9" and wrk.tgt begins "Гражданам на потребительские цели" :
        wrkt.sum = wrkt.sum + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od - wrk.rezsum_pen.
        if wrk.crc <> 1 then wrkt.sumv = wrkt.sumv + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od /*- wrk.rezsum_pen.*/.
    end.
    find first wrkt where  wrkt.cod = 19.
    wrkt.sum = 0.
    wrkt.sumv = 0.
    for each wrk where substring(wrk.schet_gk,6,1) = "9" and wrk.tgt begins "Гражданам на строительство и приобретение жилья"  :
        wrkt.sum = wrkt.sum + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od - wrk.rezsum_pen.
        if wrk.crc <> 1 then wrkt.sumv = wrkt.sumv + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od /*- wrk.rezsum_pen.*/.
    end.
    find first wrkt where  wrkt.cod = 20.
    wrkt.sum = 0.
    wrkt.sumv = 0.
    for each wrk where substring(wrk.schet_gk,6,1) = "9" and not wrk.tgt begins "Гражданам на строительство и приобретение жилья" and not wrk.tgt begins "Гражданам на потребительские цели" .
        wrkt.sum = wrkt.sum + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od - wrk.rezsum_pen.
        if wrk.crc <> 1 then wrkt.sumv = wrkt.sumv + wrk.ostatok_kzt + wrk.zam_dk - wrk.rezsum_od /*- wrk.rezsum_pen.*/.
    end.
/* разделение данных по резидентам */
    find first wrkt where  wrkt.cod = 3.
    find first b-wrkt where  b-wrkt.cod = 4.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 5.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.

    find first wrkt where  wrkt.cod = 6.
    find first b-wrkt where  b-wrkt.cod = 7.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 8.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.

    find first wrkt where  wrkt.cod = 9.
    find first b-wrkt where  b-wrkt.cod = 10.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 11.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.

    find first wrkt where  wrkt.cod = 40.
    find first b-wrkt where  b-wrkt.cod = 41.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 42.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 43.
    find first b-wrkt where  b-wrkt.cod = 44.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 45.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 46.
    find first b-wrkt where  b-wrkt.cod = 47.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 48.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 52.
    find first b-wrkt where  b-wrkt.cod = 53.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 54.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 56.
    find first b-wrkt where  b-wrkt.cod = 57.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 58.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 60.
    find first b-wrkt where  b-wrkt.cod = 61.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 62.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 64.
    find first b-wrkt where  b-wrkt.cod = 65.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 66.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 69.
    find first b-wrkt where  b-wrkt.cod = 70.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 71.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 72.
    find first b-wrkt where  b-wrkt.cod = 73.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 74.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 75.
    find first b-wrkt where  b-wrkt.cod = 76.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 77.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 78.
    find first b-wrkt where  b-wrkt.cod = 79.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 80.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 81.
    find first b-wrkt where  b-wrkt.cod = 82.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 83.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 87.
    find first b-wrkt where  b-wrkt.cod = 88.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 89.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.


    find first wrkt where  wrkt.cod = 90.
    find first b-wrkt where  b-wrkt.cod = 91.
        b-wrkt.sum = wrkt.sum1.
        b-wrkt.sumv = wrkt.sumv1.
    find first b-wrkt where  b-wrkt.cod = 92.
        b-wrkt.sum = wrkt.sum2.
        b-wrkt.sumv = wrkt.sumv2.

/* total-------------------------------------------------------------*/
    /* от суммы  33 отнимаем провизии, сумму колонки Резерв МСФО% из займов  */
    find first wrkt where  wrkt.cod = 33. /* начисленные проценты к получению */
        wrkt.sum = wrkt.sum - smsfo .
        wrkt.sumv = wrkt.sumv - smsfov .

    find first wrkt where  wrkt.cod = 23. /* Итого активы, приносящие доход */
    for each b-wrkt where  b-wrkt.cod = 2 or b-wrkt.cod = 3 or b-wrkt.cod = 6 or b-wrkt.cod = 9 or b-wrkt.cod = 12 or b-wrkt.cod = 13
                           or b-wrkt.cod = 14 or b-wrkt.cod = 15 or b-wrkt.cod = 16 or b-wrkt.cod = 17 or b-wrkt.cod = 21 or b-wrkt.cod = 22.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.

    find first wrkt where  wrkt.cod = 29. /* Прочие активы к тому что есть еще добавляем*/
    for each b-wrkt where  b-wrkt.cod = 30 or b-wrkt.cod = 31 or b-wrkt.cod = 32 or b-wrkt.cod = 33 or b-wrkt.cod = 34.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.

    find first wrkt where  wrkt.cod = 1. /* деньги */
    for each b-wrkt where  b-wrkt.cod >= 23 and b-wrkt.cod <= 29.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.

    find first wrkt where  wrkt.cod = 39.
    for each b-wrkt where  b-wrkt.cod = 40 or b-wrkt.cod = 43 or b-wrkt.cod = 46.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 51.
    for each b-wrkt where  b-wrkt.cod = 52 or b-wrkt.cod = 56 or b-wrkt.cod = 60 or b-wrkt.cod = 64.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 55. /* Справочно: суммы подлежащие гарантированию */
    for each b-wrkt where  b-wrkt.cod = 52.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 59.
    for each b-wrkt where  b-wrkt.cod = 56.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 63.
    for each b-wrkt where  b-wrkt.cod = 60.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 67.
    for each b-wrkt where  b-wrkt.cod = 64.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 68.
    for each b-wrkt where  b-wrkt.cod = 69 or b-wrkt.cod = 72 or b-wrkt.cod = 75 or b-wrkt.cod = 78.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 93. /* Итого обязательства, влекущие расход*/
    for each b-wrkt where  b-wrkt.cod = 38 or b-wrkt.cod = 39 or b-wrkt.cod = 49 or b-wrkt.cod = 50 or b-wrkt.cod = 51
                            or b-wrkt.cod = 68 or b-wrkt.cod = 84 or b-wrkt.cod = 85 or b-wrkt.cod = 87 or b-wrkt.cod = 90.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 104. /* Нераспределенный чистый доход и резерв капитала:*/
    for each b-wrkt where  b-wrkt.cod = 105 or b-wrkt.cod = 107 or b-wrkt.cod = 106.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 101. /* Собственный капитал*/
    for each b-wrkt where  b-wrkt.cod = 102 or b-wrkt.cod = 103 or b-wrkt.cod = 104 or b-wrkt.cod = 108 or b-wrkt.cod = 109
                           or b-wrkt.cod = 111 or b-wrkt.cod = 113.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 95. /* Прочие обязательства, к тому что есть еще добавляем */
    for each b-wrkt where  b-wrkt.cod = 96 or b-wrkt.cod = 97 or b-wrkt.cod = 98 or b-wrkt.cod = 99 or b-wrkt.cod = 100.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.

    find first wrkt where  wrkt.cod = 37. /* Обязательства */
    for each b-wrkt where  b-wrkt.cod >= 93 and b-wrkt.cod <= 95.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
    find first wrkt where  wrkt.cod = 114. /* Итого обязательства и капитал*/
    for each b-wrkt where  b-wrkt.cod = 37 or b-wrkt.cod = 101.
        wrkt.sum = wrkt.sum + b-wrkt.sum .
        wrkt.sumv = wrkt.sumv + b-wrkt.sumv .
    end.
/*-------------------------------------------------------------------------------------------*/
/* заполнение расшифровки № 1  */
if v-ful then do:
    define  temp-table tgl2
        field txb as character
        field fil as char
        field cod as int
        field tot as int
        field gl4 as integer
        field gl7 as integer
        field acc as character
        field acc-des as character
        field rez as char
        field ek as char
        field geo as char
        field name as char
        field crc   as integer
        field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
        field sumv as decimal     format "->>>>>>>>>>>>>>9.99"
        field odt as date
        field cdt as date
        field sub as char
        field type as char
        field gl as int
        index tgl2-id1 is primary txb gl7 .

    for each wrkt.
        for each sootv where sootv.cod = wrkt.cod no-lock.
            for each tgl where string(tgl.gl7) begins sootv.gl4.
                create tgl2.
                tgl2.txb = tgl.txb.
                find first comm.txb where comm.txb.bank = tgl.txb no-lock no-error.
                if available comm.txb then tgl2.fil = comm.txb.info.
                tgl2.cod = sootv.cod.
                tgl2.tot = sootv.tot.
                tgl2.gl4 = tgl.gl4.
                tgl2.gl7 = tgl.gl7.
                tgl2.acc = tgl.acc.
                tgl2.rez = substring(string(tgl.gl7),5,1).
                tgl2.ek = substring(string(tgl.gl7),6,1).
                tgl2.geo = "02" + substring(string(tgl.gl7),5,1).
                tgl2.name = tgl.acc-des.
                tgl2.crc = tgl.crc.
                tgl2.sum = tgl.sum.
                tgl2.sumv = tgl.sum-val.
                tgl2.odt = tgl.odt.
                tgl2.cdt = tgl.cdt.
                tgl2.sub = tgl.sub-type.
                tgl2.gl = tgl.gl.
            end.
        end.
    end.
end.
/*---------------------------------------------------------------------------------------------*/
/* вывод в тыс тенге   */
if v-select1 = 1 then do:
    for each wrkt.
        if wrkt.sum <> 0 then wrkt.sum = round((wrkt.sum / 1000),0).
        if wrkt.sumv <> 0 then wrkt.sumv = round((wrkt.sumv / 1000),0).
    end.
    /*for each tgl2.
        if tgl2.sum <> 0 then tgl2.sum = round((tgl2.sum / 1000),0).
        if tgl2.sumv <> 0 then tgl2.sumv = round((tgl2.sumv / 1000),0).
    end.*/
end.


if v-fil-int > 1 then v-fil-cnt = 'АО "ForteBank"'.



output stream v-out to a_rep.html.
    put stream v-out unformatted "<html><head><title>ForteBank</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream v-out unformatted  "<table>" skip.
    put stream v-out unformatted
         "<tr><TD colspan=4 align=right > Приложение 14 к Правилам </TD> </tr>" skip
         "<tr><TD colspan=4 align=right > представления отчетности банками </TD> </tr>" skip
         "<tr><TD colspan=4 align=right > второго уровня Республики </TD> </tr>" skip
         "<tr><TD colspan=4 align=right > Казахстан </TD> </tr>" skip
         "</table>"  skip.

    put stream v-out unformatted  "<h3> Сведения по остаткам на балансовых счетах за вычетом специальных резервов (провизий) <br>"
                                    v-fil-cnt "<br>"
                                    "АО 'ForteBank' <br>"
                                    "по состоянию на " dt1  "</h3>" skip.

    put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream v-out unformatted
         "<tr><TD colspan=4 align=right > <B> в " v-raz "</B> </TD> </tr>"  skip.
         put stream v-out unformatted "<tr><TD align=center >  <B> № </B> </TD>"   skip
         "<TD align=center >  <B> Наименование показателя </B> </TD>"   skip
         "<TD align=center >  <B> Всего </B> </TD>"   skip
         "<TD align=center >  <B> Из них в иностранной валюте </B> </TD>"   skip.
    put stream v-out unformatted "</tr>" skip.
    put stream v-out unformatted "<tr><TD  > </TD>"   skip
         "<TD align=center > A </TD>"   skip
         "<TD align=center >  </TD>"   skip
         "<TD align=center > </TD>"   skip.
    put stream v-out unformatted "</tr>" skip.

    for each wrkt .
        put stream v-out  unformatted "<tr> <TD align=""left"">" wrkt.cod "</TD>" skip
        "<TD align=""left"">" wrkt.des "</TD>" skip
        "<TD align=""right"">" replace(trim(string(wrkt.sum,'->>>>>>>>>>>9')),'.',',') "</TD>" skip.
        if wrkt.cod >= 101 and wrkt.cod <= 113 then put stream v-out unformatted "<TD align=""right"">"  "</TD>" skip.
        else put stream v-out unformatted "<TD align=""right"">" replace(trim(string(wrkt.sumv,'->>>>>>>>>>>9')),'.',',') "</TD>" skip.
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
         "</table>"  skip.

    output stream v-out close.
    unix silent value("cptwin a_rep.html excel").
    hide message no-pause.

if v-ful then do:
    def stream m-out.
    output stream m-out to rep1.htm.

    put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

    put stream m-out unformatted  "<h3> Расшифровка к отчету ФС_ББ <br>"
                                    v-fil-cnt "<br>"
                                    "по состоянию на " dt1  "</h3>" skip.

    put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip.
    put stream m-out unformatted
         "<tr><TD colspan=14 align=right > <B> в " v-raz "</B> </TD> </tr>"  skip.
         put stream m-out unformatted "<tr><TD align=center >  <B> Филиал </B> </TD>"   skip
         "<TD align=center >  <B> Код <br> отчета </B> </TD>"   skip
         "<TD align=center >  <B> Код отчета <br> справочн </B> </TD>"   skip
         "<TD align=center >  <B> Балансовый счет, <br>  4 знака счета </B> </TD>"   skip
         "<TD align=center >  <B> Балансовый счет, <br>  7 знака счета </B> </TD>"   skip
         "<TD align=center >  <B> Лицевой счет  </B> </TD>"   skip
         "<TD align=center >  <B> Признак <br>  резидентства </B> </TD>"   skip
         "<TD align=center >  <B> Сектор <br>  экономики </B> </TD>"   skip
         "<TD align=center >  <B> Наименование <br> клиента </B> </TD>"   skip
         "<TD align=center >  <B> Гео код <br> клиента </B> </TD>"   skip
         "<TD align=center >  <B> Валюта </B> </TD>"   skip
         "<TD align=center >  <B> Сумма </B> </TD>"   skip
         "<TD align=center >  <B> Сумма в тенге </B> </TD>"   skip
         "<TD align=center >  <B> sub </B> </TD>"   skip
         "<TD align=center >  <B> счет ГК </B> </TD>"   skip
   "</tr>" skip.

    for each tgl2 .
        put stream m-out  unformatted "<tr> <TD align=""left"">" tgl2.fil "</TD>" skip
        "<TD align=""left"">" tgl2.cod "</TD>" skip
        "<TD align=""left"">" tgl2.tot "</TD>" skip
        "<TD align=""left"">" tgl2.gl4 "</TD>" skip
        "<TD align=""left"">" tgl2.gl7 "</TD>" skip
        "<TD align=""left"">" tgl2.acc "</TD>" skip
        "<TD align=""left"">" tgl2.rez "</TD>" skip
        "<TD align=""left"">" tgl2.ek "</TD>" skip
        "<TD align=""left"">" tgl2.name "</TD>" skip
        "<TD align=""left"">" tgl2.geo "</TD>" skip
        "<TD align=""left"">" tgl2.crc "</TD>" skip
        "<TD align=""right"">" replace(trim(string(tgl2.sumv,'->>>>>>>>>>>9')),'.',',') "</TD>" skip
        "<TD align=""right"">" replace(trim(string(tgl2.sum,'->>>>>>>>>>>9')),'.',',') "</TD>" skip
        "<TD align=""left"">" tgl2.sub "</TD>" skip
        "<TD align=""left"">" tgl2.gl "</TD>" skip.
         put stream m-out unformatted "</tr>" skip.
    end.
    output stream m-out close.
    unix silent cptwin rep1.htm excel.
end.

if v-ful1 then do:
    define stream ln-out.
    output stream ln-out to ln.htm.
    put stream ln-out unformatted "<html><head><title>Портфель</title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream ln-out unformatted  "<h3> Расшифровка по займам к отчету ФС_ББ на " string(dt1) "</h3><br>" skip.

       put stream ln-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
    /*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Филиал</td>"
    /*1 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N бал. счета</td>"
    /*2 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
    /*3 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код<BR>заемщика</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Пул МСФО</td>"
    /*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Группа</td>"
    /*5 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Код сегментации</td>"
    /*6 */                  "<td bgcolor=""#C0C0C0"" align=""center"">N договора<BR>банк. займа</td>"
    /*7 */                  "<td bgcolor=""#C0C0C0"" align=""center"">Объект<BR>кредитования</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
    /*19*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Остаток ОД<BR>(в тенге)</td>"
    /*20*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. ОД(в тенге)</td>"

    /*28*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Начисл. %<BR>(в тенге)</td>"
    /*29*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Проср. %<BR>(в тенге)</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Дисконт<BR>по займам</td>"
    /*44*/                  "<td bgcolor=""#C0C0C0"" align=""center"">%<BR>резерва АФН</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Резерв<BR>АФН (KZT)</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО ОД,<BR>(KZT)</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО %%,<BR>(KZT)</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Резерв МСФО Пеня,<BR>(KZT)</td>"
    /*45*/                  "<td bgcolor=""#C0C0C0"" align=""center"">Общая сумма резерва МСФО,<BR>(KZT)</td>"
                            "<td bgcolor=""#C0C0C0"" align=""center"">Истор.<br>ставка</td>"
                            "</tr>" skip.


    for each wrk no-lock. /*break by wrk.bank by wrk.cif:*/

      /*if first-of(wrk.bank) then put stream ln-out unformatted "<tr style=""font:bold""><td colspan=40>" wrk.bank "</td></tr>".
      find first crc where crc.crc = wrk.crc no-lock no-error.*/

      put stream ln-out unformatted
                "<tr>" skip
                     "<td align=""left"">" wrk.bank "</td>" skip
    /*1 */            "<td align=""center"">" wrk.schet_gk "</td>" skip
    /*2 */            "<td>" wrk.name "</td>" skip
    /*3 */            "<td>" wrk.cif "</td>" skip
                      "<td>" wrk.pooln "</td>" skip
    /*5 */            "<td>" wrk.grp "</td>" skip
    /*5_1 */          "<td>" wrk.clnsegm "</td>" skip
    /*6 */            "<td>&nbsp;" wrk.num_dog "</td>" skip
    /*7 */            "<td>" wrk.tgt "</td>" skip
                      "<td>" wrk.crc "</td>" skip
    /*19*/            "<td align=""right"">" replace(trim(string(wrk.ostatok_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*20*/            "<td align=""right"">" replace(trim(string(wrk.prosr_od_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*28*/            "<td align=""right"">" replace(trim(string(wrk.nach_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*29*/            "<td align=""right"">" replace(trim(string(wrk.prosr_prc_kzt,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.zam_dk,'->>>>>>>>>>>9.99')),'.',',') "</td>" skip

    /*44*/            "<td align=""right"">" replace(trim(string(wrk.rezprc_afn,'>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.rezsum_afn,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
    /*45*/            "<td align=""right"">" replace(trim(string(wrk.rezsum_od,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.rezsum_prc,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.rezsum_pen,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.rezsum_msfo,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip
                      "<td align=""right"">" replace(trim(string(wrk.prem_his,'>>>9.99')),'.',',') "</td>" skip
                      "</tr>" skip.

    end. /* for each wrk */

    put stream ln-out "</table></body></html>" skip.
    output stream ln-out close.
    hide message no-pause.

    unix silent cptwin ln.htm excel.

end.

return.

/***************************************************************************************************************/
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
/***************************************************************************************************************/

procedure differ:
def input parameter gll as int.
def input parameter dat as date.
def output parameter sum as decim.
empty temp-table dif.

    def var v-bal as deci.
    def var mesa as integer.
    /*dat = dat - 1.*/

    def var rates as deci extent 20.

    for each crc no-lock:
      find last crchis where crchis.crc = crc.crc and crchis.rdt < dat no-lock no-error.
      rates[crc.crc] = crchis.rate[1].
    end.

    for each gl where gl.subled = 'lon' no-lock:
      for each crc no-lock:
        create dif.
        dif.gl = gl.gl.
        dif.crc = crc.crc.
        find last glday where glday.gl = gl.gl and glday.crc = crc.crc and glday.gdt < dat no-lock no-error.
        if avail glday then do:
          dif.sum_gl = glday.dam - glday.cam.
          dif.sum_gl_kzt = dif.sum_gl * rates[dif.crc].
        end.
      end.
    end.

    mesa = 0.
    for each lon no-lock:

      for each trxbal where trxbal.subled = "lon" and trxbal.acc = lon.lon no-lock:

        find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = trxbal.level and histrxbal.crc = trxbal.crc and histrxbal.dt < dat no-lock no-error.
        if avail histrxbal then do:
          if histrxbal.dam - histrxbal.cam = 0 then next.
          find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = histrxbal.level no-lock no-error.
          find first dif where dif.gl = trxlevgl.glr and dif.crc = histrxbal.crc no-error.
          dif.sum_lon = dif.sum_lon + histrxbal.dam - histrxbal.cam.
        end.

      end.

      mesa = mesa + 1.
      hide message no-pause.
      message " " mesa " ".

    end. /* for each lon */


    for each dif where dif.gl = gll and dif.crc = 1:
      sum = dif.sum_gl - dif.sum_lon .
    end.
end procedure.