/* r-PL.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        18.04.2013 dmitriy
 * BASES
        BANK COMM
 * CHANGES
*/

def var sum1 as deci.
def var sum2 as deci.
def var dt as date.
def var i as int.

create rep. rep.id = 1.  rep.point = "'1".          rep.name = "ЦЕННЫЕ БУМАГИ".
create rep. rep.id = 2.  rep.point = "'1.1".        rep.name = "ЦЕННЫЕ БУМАГИ, УДЕРЖИВАЕМЫЕ ДО ПОГАШЕНИЯ".
create rep. rep.id = 3.  rep.point = "'1.1.1".      rep.name = "процентные доходы/расходы".
create rep. rep.id = 4.  rep.point = "'1.1.2".      rep.name = "амортизация".
create rep. rep.id = 5.  rep.point = "'1.1.3".      rep.name = "купля-продажа".
create rep. rep.id = 7.  rep.point = "'1.1.5".      rep.name = "резервы (провизии)".
create rep. rep.id = 8.  rep.point = "'1.2".        rep.name = "ЦЕННЫЕ БУМАГИ, УЧИТЫВАЕМЫЕ ПО СПРАВЕДЛИВОЙ СТОИМОСТИ ЧЕРЕЗ ПРИБЫЛЬ ИЛИ УБЫТОК".
create rep. rep.id = 9.  rep.point = "'1.2.1".      rep.name = "процентные доходы/расходы".
create rep. rep.id = 10. rep.point = "'1.2.2".      rep.name = "амортизация".
create rep. rep.id = 11. rep.point = "'1.2.3".      rep.name = "купля-продажа".
create rep. rep.id = 12. rep.point = "'1.2.4".      rep.name = "переоценка, в т.ч.:".
create rep. rep.id = 13. rep.point = "'1.2.4.1".    rep.name = "    - нереализованная".
create rep. rep.id = 14. rep.point = "'1.2.4.2".    rep.name = "    - реализованная".
create rep. rep.id = 16. rep.point = "'1.3".        rep.name = "ЦЕННЫЕ БУМАГИ, ИМЕЮЩИЕСЯ В НАЛИЧИИ ДЛЯ ПРОДАЖИ".
create rep. rep.id = 17. rep.point = "'1.3.1".      rep.name = "процентные доходы/расходы".
create rep. rep.id = 18. rep.point = "'1.3.2".      rep.name = "амортизация".
create rep. rep.id = 19. rep.point = "'1.3.3".      rep.name = "купля-продажа".
create rep. rep.id = 20. rep.point = "'1.3.4".      rep.name = "переоценка, в т.ч.:".
create rep. rep.id = 21. rep.point = "'1.3.4.1".    rep.name = "    - нереализованная".
create rep. rep.id = 22. rep.point = "'1.3.4.2".    rep.name = "    - реализованная".
create rep. rep.id = 23. rep.point = "'1.3.6".      rep.name = "резервы (провизии)".
create rep. rep.id = 24. rep.point = "'1.4".        rep.name = "комиссионные".

create rep. rep.id = 25. rep.point = "'2".          rep.name = "ОПЕРАЦИИ С ИНОСТРАННОЙ ВАЛЮТОЙ".
create rep. rep.id = 26. rep.point = "'2.1".        rep.name = "купля-продажа".
create rep. rep.id = 27. rep.point = "'2.2".        rep.name = "комиссионные".
create rep. rep.id = 28. rep.point = "'2.3".        rep.name = "переоценка, в т.ч.:".
create rep. rep.id = 29. rep.point = "'2.3.1".      rep.name = "    - нереализованная".
create rep. rep.id = 30.  rep.point = "'2.3.2".     rep.name = "    - реализованная".

create rep. rep.id = 31. rep.point = "'3".          rep.name = "ОПЕРАЦИИ С ПРОИЗВОДНЫМИ ИНСТРУМЕНТАМИ ".
create rep. rep.id = 32.  rep.point = "'3.1".       rep.name = "процентные доходы/расходы".
create rep. rep.id = 33. rep.point = "'3.2".        rep.name = "купля-продажа, в т.ч.:".
create rep. rep.id = 34. rep.point = "'3.2.1".      rep.name = "фьючерс".
create rep. rep.id = 35. rep.point = "'3.2.2".      rep.name = "форвард".
create rep. rep.id = 36. rep.point = "'3.2.3".      rep.name = "опционные операции".
create rep. rep.id = 37. rep.point = "'3.2.4".      rep.name = "своп".
create rep. rep.id = 38. rep.point = "'3.2.5".      rep.name = "прочие производные".
create rep. rep.id = 39. rep.point = "'3.3".        rep.name = "переоценка, в т.ч.:".
create rep. rep.id = 40. rep.point = "'3.3.1".      rep.name = "    - нереализованная, в т.ч.".
create rep. rep.id = 41. rep.point = "'3.3.1.1".    rep.name = "фьючерс".
create rep. rep.id = 42. rep.point = "'3.3.1.2".    rep.name = "форвард".
create rep. rep.id = 43. rep.point = "'3.3.1.3".    rep.name = "опционные операции".
create rep. rep.id = 44. rep.point = "'3.3.1.4".    rep.name = "своп".
create rep. rep.id = 45. rep.point = "'3.3.1.5".    rep.name = "прочие производные".

create rep. rep.id = 46.  rep.point = "'4".         rep.name = "ВЫПУЩЕННЫЕ ЦЕННЫЕ БУМАГИ".
create rep. rep.id = 47. rep.point = "'4.1".        rep.name = "ПРОСТЫЕ ОБЛИГАЦИИ/ ПРОЧИЕ ЦЕННЫЕ БУМАГИ".
create rep. rep.id = 48. rep.point = "'4.1.1".      rep.name = "процентные расходы".
create rep. rep.id = 49. rep.point = "'4.1.2".      rep.name = "амортизация".
create rep. rep.id = 50. rep.point = "'4.2".        rep.name = "СУБОРДИНИРОВАННЫЕ ОБЛИГАЦИИ / ДОЛГИ".

create rep. rep.id = 51. rep.point = "'4.2.1".      rep.name = "процентные расходы".
create rep. rep.id = 52. rep.point = "'4.2.2".      rep.name = "амортизация".
create rep. rep.id = 53. rep.point = "'4.3".        rep.name = "БЕССРОЧНЫЕ ФИНАНСОВЫЕ ИНСТРУМЕНТЫ".
create rep. rep.id = 54. rep.point = "'4.3.1".      rep.name = "процентные расходы".

create rep. rep.id = 55. rep.point = "'5".          rep.name = "МЕЖБАНКОВСКИЕ КРЕДИТЫ И ДЕПОЗИТЫ".
create rep. rep.id = 56. rep.point = "'5.1".        rep.name = "КОРРЕСПОНДЕНТСКИЕ СЧЕТА".
create rep. rep.id = 57. rep.point = "'5.1.1".      rep.name = "процентные доходы/расходы в Национальном Банке РК".
create rep. rep.id = 58. rep.point = "'5.1.2".      rep.name = "процентные доходы/расходы в других банках".
create rep. rep.id = 59. rep.point = "'5.2".        rep.name = "КРЕДИТЫ БАНКАМ/ ОТ БАНКОВ".
create rep. rep.id = 60. rep.point = "'5.2.1".      rep.name = "процентные доходы/расходы".
create rep. rep.id = 61. rep.point = "'5.2.1.1".    rep.name = "займы, полученные от Национального Банка РК".
create rep. rep.id = 62. rep.point = "'5.2.1.2".    rep.name = "займы, полученные от иностраннных центральных банков".
create rep. rep.id = 63. rep.point = "'5.2.1.3".    rep.name = "займы овердрафт".
create rep. rep.id = 64. rep.point = "'5.2.1.4".    rep.name = "краткосрочные займы".
create rep. rep.id = 65. rep.point = "'5.2.1.5".    rep.name = "займы овернайт".
create rep. rep.id = 66. rep.point = "'5.2.1.6".    rep.name = "долгосрочные займы".
create rep. rep.id = 67. rep.point = "'5.2.1.7".    rep.name = "финансовый лизинг".
create rep. rep.id = 68. rep.point = "'5.2.1.8".    rep.name = "просроченная задолженность".
create rep. rep.id = 69. rep.point = "'5.2.1.9".    rep.name = "другие операции".
create rep. rep.id = 70. rep.point = "'5.2.2".      rep.name = "коммисионное вознаграждение".
create rep. rep.id = 71. rep.point = "'5.2.3".      rep.name = "корректировка стоимости займа".
create rep. rep.id = 72. rep.point = "'5.2.4".      rep.name = "амортизация".
create rep. rep.id = 73. rep.point = "'5.2.5".      rep.name = "резервы (провизии)".
create rep. rep.id = 74. rep.point = "'5.3".        rep.name = "ДЕПОЗИТЫ БАНКАМ/ ОТ БАНКОВ".
create rep. rep.id = 75. rep.point = "'5.3.1".      rep.name = "процентные доходы/расходы".
create rep. rep.id = 76. rep.point = "'5.3.1.1".    rep.name = "вклады в Национальном Банке РК".
create rep. rep.id = 77. rep.point = "'5.3.1.2".    rep.name = "вклады в иностранных центральных банках".
create rep. rep.id = 78. rep.point = "'5.3.1.3".    rep.name = "вклады в других банках, в т.ч.:".
create rep. rep.id = 79. rep.point = "'5.3.1.3.1".  rep.name = "вклады на одну ночь".
create rep. rep.id = 80. rep.point = "'5.3.1.3.2".  rep.name = "вклады до востребования".
create rep. rep.id = 81. rep.point = "'5.3.1.3.3".  rep.name = "краткосрочные вклады до 1 месяца".
create rep. rep.id = 82. rep.point = "'5.3.1.3.4".  rep.name = "краткосрочные вклады до 1 года".
create rep. rep.id = 83. rep.point = "'5.3.1.3.5".  rep.name = "долгосрочные вклады".
create rep. rep.id = 84. rep.point = "'5.3.1.3.6".  rep.name = "    - условные вклады".
create rep. rep.id = 85. rep.point = "'5.3.1.3.7".  rep.name = "    - просроченная задолженность".
create rep. rep.id = 86. rep.point = "'5.3.1.3.8".  rep.name = "    - вклад-обеспечение обязательств".
create rep. rep.id = 87. rep.point = "'5.3.2".      rep.name = "корректировка стоимости вклада".
create rep. rep.id = 88. rep.point = "'5.3.3".      rep.name = "амортизация".
create rep. rep.id = 89. rep.point = "'5.3.4".      rep.name = "резервы (провизии)".
create rep. rep.id = 90. rep.point = "'5.4".        rep.name = "ОПЕРАЦИИ ОБРАТНОЕ/ ПРЯМОЕ РЕПО".
create rep. rep.id = 91. rep.point = "'5.4.1".      rep.name = "процентные доходы по операциям ОБРАТНОЕ РЕПО".
create rep. rep.id = 92. rep.point = "'5.4.2".      rep.name = "процентные расходы по операциям ПРЯМОЕ РЕПО".
create rep. rep.id = 93. rep.point = "".            rep.name = "ИТОГО".

/*------------------------------------------------------------------*/

run WriteAll (dt1 - 7, 1).
run WriteAll (dt1, 2).

procedure WriteAll:
    def input parameter p-dt as date.
    def input parameter jj as int.
    dt = p-dt.
    i = jj.

    /* 1 */
    run WritePoint (3, i, "4481", "").
    run WritePoint (4, i, "4482", "5308").
    run WritePoint (5, i, "4510", "5510").
    run WritePoint (7, i, "4954", "5464").
    run WritePoint (9,  i, "4201", "").
    run WritePoint (10, i, "4202", "5305").
    run WritePoint (11, i, "4510", "5510").
    run WritePoint (13, i, "4709", "5709").
    run WritePoint (14, i, "4733", "5733").
    run WritePoint (17,  i, "4452", "").
    run WritePoint (18,  i, "4453", "5306").
    run WritePoint (19,  i, "4510", "5510").
    run WritePoint (21,  i, "3561", "").
    run WritePoint (22,  i, "4733", "5733").
    run WritePoint (23,  i, "3561", "").
    run WritePoint (24,  i, "4603", "5603").

    run WriteSumPoint (2, i, "3,4,5,7").
    run WriteSumPoint (12, i, "13,14").
    run WriteSumPoint (8, i, "9,10,11,12").
    run WriteSumPoint (20, i, "21,22").
    run WriteSumPoint (16, i, "17,18,19,20,23").
    run WriteSumPoint (1, i, "2,8,16,24").

    /* 2 */
    run WritePoint (26,  i, "4530", "5530").
    run WritePoint (27,  i, "4604", "5604").
    run WritePoint (29,  i, "4703", "5703").
    run WritePoint (30,  i, "4731", "5731").

    run WriteSumPoint (28, i, "29,30").
    run WriteSumPoint (25, i, "26,27,28").

    /*3*/
    run WritePoint (32,  i, "4897", "5897").
    run WritePoint (34,  i, "4891", "5891").
    run WritePoint (35,  i, "4892", "5892").
    run WritePoint (36,  i, "4893", "5893").
    run WritePoint (37,  i, "4895", "5895").
    run WritePoint (38,  i, "4896", "5896").
    run WritePoint (41,  i, "4590", "5590").
    run WritePoint (42,  i, "4560,4570,4580", "5560,5570,5580").
    run WritePoint (43,  i, "4591", "5591").
    run WritePoint (44,  i, "4593", "5593").
    run WritePoint (45,  i, "4594", "5594").

    run WriteSumPoint (33, i, "34,35,36,37,38").
    run WriteSumPoint (40, i, "41,42,43").
    run WriteSumPoint (39, i, "40").
    run WriteSumPoint (31, i, "32,33,39").

    /*4*/
    run WritePoint (48,  i, "", "5301,5303").
    run WritePoint (49,  i, "4454", "5307").
    run WritePoint (51,  i, "", "5401,5402,5406").
    run WritePoint (52,  i, "4455", "5404").
    run WritePoint (54,  i, "", "5407").

    run WriteSumPoint (53, i, "54").
    run WriteSumPoint (50, i, "51,52").
    run WriteSumPoint (47, i, "48,49").
    run WriteSumPoint (46, i, "47,50,53").

    /*5*/
    run WritePoint (57,  i, "4051", "5021").
    run WritePoint (58,  i, "4052", "5022,5023,5026").
    run WritePoint (61,  i, "", "5051").
    run WritePoint (62,  i, "", "5052").
    run WritePoint (63,  i, "4301", "").
    run WritePoint (64,  i, "4302", "5044,5054").
    run WritePoint (65,  i, "4303", "5111,5112,5113").
    run WritePoint (66,  i, "4304", "5046,5056").
    run WritePoint (67,  i, "4305", "5053").
    run WritePoint (68,  i, "4306", "5048,5058,5059").
    run WritePoint (69,  i, "", "5091").
    run WritePoint (70,  i, "4309", "5095").
    run WritePoint (71,  i, "4310,4311", "5047,5055,5057").
    run WritePoint (72,  i, "4312", "").
    run WritePoint (73,  i, "4952", "").
    run WritePoint (76,  i, "4101,4102,4103,4104", "5121,5122").
    run WritePoint (77,  i, "", "5123,5124").
    run WritePoint (79,  i, "4251", "").
    run WritePoint (80,  i, "4252", "5125").
    run WritePoint (81,  i, "4253", "5126").
    run WritePoint (82,  i, "4254", "5127").
    run WritePoint (83,  i, "4255", "5128").
    run WritePoint (84,  i, "4256", "5133").
    run WritePoint (85,  i, "4257", "5129").
    run WritePoint (86,  i, "4265", "5130").
    run WritePoint (87,  i, "4261,4262,4263,4264", "5134,5135,5136,5137").
    run WritePoint (88,  i, "4105,4266,4270", "5138,5140,5141").
    run WritePoint (89,  i, "4951", "5451").
    run WritePoint (91,  i, "4465", "").
    run WritePoint (92,  i, "", "5250").

    run WriteSumPoint (90, i, "91,92").
    run WriteSumPoint (78, i, "79,80,81,82,83,84,85,86").
    run WriteSumPoint (75, i, "76,77,78").
    run WriteSumPoint (74, i, "75,87,88,89").
    run WriteSumPoint (60, i, "61,62,63,64,65,66,67,68,69").
    run WriteSumPoint (59, i, "60,70,71,72,73").
    run WriteSumPoint (56, i, "57,58").
    run WriteSumPoint (55, i, "56,59,74,90").

    /*ИТОГО*/
    run WriteSumPoint (93, i, "1,25,31,46,55").

end procedure.

for each rep no-lock:
    rep.ch-sum = rep.sum[2] - rep.sum[1].
end.


procedure WritePoint:
    def input parameter p-id as int.
    def input parameter p-i as int.
    def input parameter gl-list1 as char.
    def input parameter gl-list2 as char.

    sum1 = 0. sum2 = 0.

    for each repPL where lookup(repPL.gl4, gl-list1 + "," + gl-list2) > 0 and repPL.dt = dt no-lock:
        if lookup(repPL.gl4, gl-list1) > 0 then sum1 = sum1 + repPL.bal.
        if lookup(repPL.gl4, gl-list2) > 0 then sum2 = sum2 + repPL.bal.
    end.

    find first rep where rep.id = p-id no-lock no-error.
    if avail rep then do:
        do transaction:
            rep.sum[p-i] = sum1 - sum2.
        end.
    end.
end procedure.

procedure WriteSumPoint:
    def input parameter p-id as int.
    def input parameter p-i as int.
    def input parameter p-list as char.

    sum1 = 0.
    for each rep where lookup(string(rep.id), p-list) > 0 no-lock:
        sum1 = sum1 + rep.sum[p-i].
    end.

    find first rep where rep.id = p-id no-lock no-error.
    if avail rep then do:
        do transaction:
            rep.sum[p-i] = sum1.
        end.
    end.
end procedure.

