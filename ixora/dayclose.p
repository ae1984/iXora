/* dayclose.p
 * MODULE
        Закрытие операционного дня банка
 * DESCRIPTION
        Перевод операционного дня банка на следующий рабочий день
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
        31/12/99 pragma
 * CHANGES
        01.08.2003 nadejda   -  закомментировала неиспользуемые программы
        28.10.2003 marinav   -  по ссудным счетам - перенос просрочки на счета просрочки и начисление штрафов
        04.12.2003 nadejda   -  закомментарила все, что относится к профит-центрам
                                поставила снятие блокировки кассы
        23.01.2004 marinav   -  Перенос просрочки на счета просрочки если закрываемый день - рабочий
        02.02.2004 nataly    -  Начисление индексации по кредитам dclsind.p
        02.03.2004 marinav   -  dcls57 начисление комиссии за кред линию
        11.03.2004 nataly    -  добавлена программа по начислению %% по депоизиту "ЗВЕЗДА" dclsrez2.p
        04.05.2004 tsoy      -  заполнение поля cls.del если рабочий день то true иначе false.

        06.08.2004 sasco     -  добавил вызов процедуры trxvalps.p (by saltanat) - урегулирование карточных счетов
        (10.08.2004 sasco    -  trxvalps.p добавил окончательно :-) 06.08.04 только комментарий вставился, а RUN не было)
        23.09.2004 suchkov   -  добавил обработку временных прав
        06.10.2004 dpuchkov  -  поправил схему начисления % по 5 схеме.
        21.10.2004 saltanat  -  добавила работу со спец.инструкциями.(если в спец.инструкции есть пометка,
                                то по истечении 30 кал.дн. спец.инструкция удаляется)
        19.11.2004 dpuchkov  -  добавлено начисление % на текущие счета клиентов dcls22(только юр лица).
        23.11.2004 saltanat  -  удаление спец.инстр. переташила вверх.
        10.12.2004 madiyar   -  перенес dclsind ниже погашения и начисления по кредитам
        05.12.2004 dpuchkov  -  добавил автоматическое закрытие депозитных счетов без остатка на 1 уровне dcls25
        25.01.2005 kanat     -  добавил подсчет сумм исходящих платежей по 6 типу
        14.03.2005 u00121    -  Проверка длительности рабочей недели, если по каким либо причинам она изменялась, например, с 5-дневной на 6-дневную
        25.03.2005 u00121    -  Проверка длительности рабочей недели заключена в do transaction
        25.03.2005 dpuchkov  -  Добавил проверку на счета у которых не проставилась дата dclscheckacc.p.
        29.03.2005 saltanat  -  Включила вызов процедуры, предназначенной для закрытия льгот в тарификаторе для клиентов с недействующими счетами. - dcls62.p
        30/03/2005 madiyar   -  добавил процедуру dclsprov (начисление и списание провизий)
        01.04.2005 saltanat  -  Переименовала вызов процедуры run dcls_62.
        06.05.2005 dpuchkov  -  Добавил вызов процедур: dclsrez6 dclsrez7
        06/05/2005 madiyar   -  Добавил копирование прогнозных курсов в текущие
        19/05/2005 madiyar   -  Убрал копирование прогнозных курсов в текущие от греха подальше
        07/06/2005 madiyar   -  Включил индексацию
        09.06.2005 suchkov   -  Сделал проверку всех счетчиков системы
        22.06.2005 dpuchkov  -  Добавил процедуру списания комиссии с сейфовых ячеек равными долями.
        13.07.2005 dpuchkov  -  Добавил обнуление сиквенса CURRENT-VALUE(krnum) = 0.
        03.08.2005 marinav   -  run gcvpmove. - при закрытии месяца перенос файлов ГЦВП в архив.
        06.10.2005 suchkov   -  Разблокировка кассы после закрытия дня.
        10/10/2005 madiyar   -  Проверка, проставлены ли прогнозные курсы
        14.10.2005 u00121    -  Обнуление количества разрешенных проводок в операционный день, по клиентам котролирующихся биометрией
        06.12.2005 dpuchkov  -  Добавил новый алгоритм начисления по депозитам Ю.Л
        20.12.2005 dpuchkov  -  Добавил новый алгоритм начисления по депозитам Пенсионный dclsrez9
        04.01.2006 Natalya D.-  Добавила процедуру отправки сообщений-напоминаний на e-mail ежегодно 6,7,8-го декабря
        16.02.2006 dpuchkov  -  Добавил алгоритм по начислению процентов по депозиту Белая звезда
        23.02.06   marinav   -  Доп логи в  dayclose.prt
        01.03.06   dpuchkov  -  Сделал ежедневное списание задолжности за депозитарий
        20.03.06   Natalya D.-  Добавила процедуры обнуления и восстановления ставок и штрафов по просроченным кредитам.(dcls65 и dcls66).
        31.03.06   marinav   -  Доп логи в  dayclose.prt
        14.04.2006 Natalya D.-  Добавила процедуру(dcls67) корректировки внебалансовых остатков по кредитам КИК(26 уровень)
                                Перенесла процедуру dcls_vb до начисления коммисий(dcls57)
        03/05/2006 madiyar   -  добавил процедуру dclskpin (прогруз платежей из Казпочты)
        01.08.06 Isakov A.(u00671) - добавлен входной парамтр для запуска процедуры set_permissions
        01/09/06 marinav - перенос dcls27 после проводок по НДС
        15/11/2006 u00124 - Добавил переброску средств (гарантированные <-> негарантированные) dclstransf.
        27/02/2007 madiyar - закомментировал dclsind.p
        27/04/07 marinav - закомментировала dcls65, dcls66
        26/07/2007 madiyar - убрал ссылку на удаленную таблицу (rh)
        28/02/2008 id00004 - добавил алгоритмы по новым депозитам
        13/03/2008 madiyar - раскомментировал dcls65 и dcls66 (сброс и восстановление ставки по кредитам)
        10/06/08 marinav - закоментарены начисления НДС r-nds , s-pvn
        10/06/08 id00004 - добвил начисление по депозиту МЕТРОШКА
        04/07/2008 alex - добывил начисление НДС
        30/10/2008 id00024 - run compens сразу после  run getcom.
        03/11/2008 id00024 - раскомментил проги по казначейству (dcls14)
        01/07/09   marinav - перед разблокировкой проверим была ли блокировка?
        28/08/2009 id00024 - Добавил программу dclsscu. Автоматическое начисление % по SCU.
        15/04/2010 madiyar - dclspenot, отсроченная пеня
        09/09/2010 galina - добавила dclsLCcom амортизация комиссии для аккредитива
        07/12/2010 madiyar - изменения в работе с кредитными линиями, выключил dcls_vb и dcls57
        19/01/2011 madiyar - программа dcls_clclose.p - обнуление остатков КЛ при наступлении срока периода доступности
        02/03/2011 evseev - Добавил программу ARPPost. Возмещение почтовых расходов.
        29/03/2011 k.gitalov - программа cls-corp. Погашение отрицательного остатка cashpooling
        22.04.2011 aigul - запсиь в справочник значения yes о закрытии дня
        17.04.2011 damir - добавил программы cif-ost1, cif-ost2.
        25.05.2011 evseev - добавил программу dcls_luksnew
        30/09/2011 id00810 - переставила вызов dclsLCcom
        01/10/2011 madiyar - добавил вызов dclslncom - амортизация комиссии по кредитам
        06/12/2011 id00810 - добавила вызов dclsgarcom - амортизация комиссии по гарантиям
        21/12/2011 evseev - ТЗ-1223. Переоценка активов и обязательств в ин.валюте. dcls39a.
        30/12/2011 evseev - ТЗ-1223. Убрал программы dcls39a и dcls39, добавил dcls39b.
        04/01/2012 evseev - ТЗ-1223. Убрал все программы dcls39х, добавил dcls39с. Копирование курсов из crcpro в crc и crchis
        17.01.2012 aigul - отправка отчетов от ДВК
        20.01.2012 aigul - убрать рассылку от ДВК
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        16.07.2012 Lyubov - добавила вызов lcmonrep - ежемесячного отчета для МД и БО
        13.08.2012 Lyubov - ежемесячный отчет формируется в конце месяца при закрытии дня только на ЦО
        17.10.2012 evseev ТЗ-1556
        14.11.2012 id00477 - Убрал проверку блокировки кассы для ЦО и добавил в рассылку Anton.Marchenko@fortebank.com
        14.11.2012 id00477 - Убрал процерку блокировки кассы для ЦО и добавил в рассылку Anton.Marchenko@fortebank.com
        11/12/2012 madiyar - изменения в процедуре переоценки
        25/12/2012 id00810 - добавила вызов dclspccom.p - отнесение комиссии по ПК на доходы
        14.11.2012 id00477 - Убрал процерку блокировки кассы для ЦО и добавил в рассылку Anton.Marchenko@fortebank.com
        11/12/2012 madiyar - изменения в процедуре переоценки
        25/12/2012 id00810 - добавила вызов dclspccom.p - отнесение комиссии по ПК на доходы
        19/02/2013 Luiza - ТЗ № 1688 меняем признак передачи суммы комиссии ЭЦП в ЦО sysc.loval = no.
        05/04/2013 Luiza - ТЗ № 1764 блокирование валют
        14.05.2013 evseev - tz-1828
        23.05.2013 evseev - tz-1844
        10.06.2013 evseev - tz-1845
        01.07.2013 evseev - tz ОД от 01/07/2013
        02.07.2013 evseev - tz-1909
        16/07/2013 Luiza  - ТЗ № 1738 формирование списка для длительных платежных поручений(вызов a_filpplist)
        27/08/2013 Luiza  - ТЗ 2002
        17/10/2013 galina - ТЗ1918 добавила погашение комиссии
        05/11/2013 Sayat(id01143) - ТЗ 2174 от 30/10/2013 "Приведение в соответствие кода займа" добавил запуск программы lnsootvcods.
        18.11.2013 evseev - tz2126
*/



{global.i "new global"}
{setglob.i}

g-batch = true.

define new shared variable nds as decimal init 0.
define new shared var doxnds as decimal init 0.
define new shared var s-target as date.
define new shared var s-bday as log.
define new shared var s-intday as int.
define new shared var s-rh as char.
define var vans as logi init true.
define new shared stream m-out .
define var vday as char format "x(132)".
vday = "Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday".
define var vnet as dec decimals 2.
define var vdate as date.

define var v-operdate as date.

def var v-weekbeg as int. /*первый день недели*/
def var v-weekend as int. /*последний день недели*/

define frame msg with size 64 by 22.

/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then
        v-weekend = sysc.inval.
else
        v-weekend = 6.
/*******************************************************************************************/

/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then
        v-weekbeg = sysc.inval.
else
        v-weekbeg = 2.
/*******************************************************************************************/

s-target = g-today + 1.
s-intday = 1.

/*****определение - рабочий закрываемый день или нет****************************************/
find hol where hol.hol = g-today no-lock no-error.
if not available hol and  weekday(g-today) ge v-weekbeg and  weekday(g-today) le v-weekend then
        s-bday = true.
else
        s-bday = false.
/*******************************************************************************************/



/**проверяем праздничный ли день************************************************************/
repeat while month(g-today) = month(s-target):
        find hol where hol.hol eq s-target no-lock no-error.
        if not available hol and weekday(s-target) ge v-weekbeg and weekday(s-target) le v-weekend then
                leave. /*если день рабочий, то продолжаем закрытие опер. дня*/
        else
                s-target = s-target + 1. /*если день праздничный то переключаемся на следующий день, пока не найдем первый рабочий*/
end.
/*******************************************************************************************/


/**Lyubov - находим код филиала*************************************************************/
def var v-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if available sysc then
        v-ourbank = sysc.chval.
/*******************************************************************************************/


/**Списание комиссий за ЭЦП с 287082 на 460828 только на базе ЦО****************************/
find first cmp no-lock no-error.
if cmp.code = 000 then do:
    if s-bday eq true and month(g-today) ne month(s-target) then run month-comm.
end.
do transaction:
    if s-bday eq true and month(g-today) ne month(s-target) then do:
        find first sysc where sysc.sysc = "MC" exclusive-lock no-error.
        if avail sysc then sysc.loval = no.
        find first sysc where sysc.sysc = "MC" no-lock no-error.
    end.
end.
/*******************************************************************************************/
output stream m-out to dayclose.prt append.

s-intday = s-target - g-today.

display g-today label "Today"with row 2 centered side-label no-box.
display entry(weekday(g-today), vday) format "x(10)".
display s-target label "Next day" with row 2 centered side-label no-box.
display entry(weekday(s-target), vday) format "x(10)".

/* 10/10/2005 madiar - Проверка, проставлены ли прогнозные курсы */
/* 23/01/07 marinav
do transaction:
  for each crc where lookup(string(crc.crc),"2,4,11") > 0 no-lock:
    find first crcpro where crcpro.crc = crc.crc and crcpro.regdt = s-target no-lock no-error.
    if not avail crcpro or crcpro.rate[1] = 0 then do:
      message " Не проставлен прогнозный курс " crc.code "! ". pause 60.
      return.
    end.
  end.
end.
*/
/* 10/10/2005 madiar - end */

{mesg.i 0881} update vans.
if vans = false then quit.

CURRENT-VALUE(krnum) = 0.

display " Операционный день закрывается......................" string(time,"HH:MM:SS") skip with centered frame msg.

        run set_permissions(0). /* suchkov   - 21.09.04 - Установка и удаление временных прав
                                   Isakov A. - 01.08.06 - добавлен входной парамтр для выбора видов прав: выдача или удаление, либо и то и другое  */

        run test_counters. /* suchkov - 09.06.05 - Проверка всех счетчиков системы */

        run dcls25. /* Автоматическое закрытие депозитных счетов без остатка на 1 уровне*/

        run dcls8. /* 21.10.2004 saltanat - работа со спец.инструкциями // ~Для платежных карт удаление по признаку, по истечении 30дн.~ \\
                                                                       // ~Для Кредитного Департамента удаление по признаку без проверки на дату~ \\ */

        put stream m-out skip(1) g-today skip .

        run put(1).

        run put(2).

        run dcls7. /*закрытие тех овердрафтов и что-то там еще, кто знает опишите...*/

        run compltrx. /*Отражение сумм комиссии в долл ...*/

        run ARPPost. /*возмещение почтовых расходов*/

        run cif-ost1. /*Дамир*/ /*Автоматический перевод остатков с одного счета на другой*/
        run cif-ost2. /*Дамир*/ /*Автоматический перевод остатков с одного счета на другой, по счетам по которым уже был был перевод*/
display " Calculate Accrued Interest........................." string(time,"HH:MM:SS") skip with frame msg.

/*      if s-bday eq true and month(g-today) ne month(s-target) then  do: */
        run savelog("dayclose", "260. ").
           run dcls23. /* списание комисии по сейфовым ячейкам теперь ежедневно */
/*      end. */

        run savelog("dayclose", "264. ").
        run dclscheckacc. /* проверка на кривой счет если не проставилась одна из дат */
        run savelog("dayclose", "266. ").
        run dcl-tk. /* заполнение таблицы транзакций */
        run put(3).
/*      run dclstransf.*/  /*урегулирование депозитов гарантированные <-> негарантированные*/
/*      run dclsstar. */   /* Начисление процентов по Звезда белая синяя красная*/

/*      run dcls48. */   /* Начисление процентов по депозитам */
        run savelog("dayclose", "273. ").

        run dclsUR.   /* Начисление процентов по новым депозитам юр. лиц */


        run savelog("dayclose", "278. ").
        run dcls_standart.  /*Начисление процентов по депозиту МЕТРО-СТАНДАРТ*/
        run savelog("dayclose", "280. ").
        run dcls_classic .  /*Начисление процентов по депозиту МЕТРО-КЛАССИК*/
        run savelog("dayclose", "282. ").
        run dcls_luks.      /*Начисление процентов по депозиту МЕТРО-ЛЮКС*/
        run savelog("dayclose", "284. ").
        run dcls_luksnew.   /*Начисление процентов по депозиту МЕТРО-ЛЮКС с 1.06.2011*/
        run savelog("dayclose", "286. ").
        run dcls_vip.       /*Начисление процентов по депозиту МЕТРО-VIP*/
        run savelog("dayclose", "288. ").
        run dcls_super_luks. /*Начисление процентов по депозиту СУПЕРЛЮКС*/
        run savelog("dayclose", "290. ").
        run dcls_kids. /*Начисление процентов по депозиту МЕТРОШКА*/
        run savelog("dayclose", "292. ").
        run dcls_fortelux.
        run savelog("dayclose", "295. ").
        run dcls_ForteProfitable.
        run savelog("dayclose", "297. ").
        run dcls_ForteUniversal.
        run savelog("dayclose", "300. ").
        run dcls_ForteMaximum.
        run savelog("dayclose", "303. ").
        run dcls_ForteSpecial.
        run savelog("dayclose", "306. ").
        /*run dcls22.*/     /* начисление %% по текущим счетам юридических лиц */

display " Calculate LON Interest............................." string(time,"HH:MM:SS") skip with frame msg.

	run dcls_pkclose. /* 2010-02-05 TZ638 id00024 Автоматическое закрытие неработающих текущих счетов */
        run lnsootvcods.
       /* run dclskpin.*/ /* прогруз платежей из Казпочты */
        run put(4).
        if s-bday = true then run dcls55.  /* Погашение, перенос просрочки на счета просрочки если закрываемый день - рабочий */
        run dcls66. /* восстановление ставки по кредитам, для начисления процентов и штрафов в балансе */
        run dcls65. /* сброс ставки по кредитам на 0, для начисления процентов и штрафов вне баланса */
        run put(36).
        run dcls56.  /* Начисление штрафов */
        run put(37).
        run dcls54. /* LON ACCRUED INTEREST TRANSACTION - Начисление процентов по кредитам */
        run put(38).
        /* run dclsind. */ /* индексация */
        run put(39).
        /*
        run dcls_vb. -- Перенос на внебаланс остатков по кредитам 26.03.03 --
        run dcls57. -- комиссия за неисп кред линию --
        */
        run put(40).
        if day(s-target) = 1 then run dclsprov. /* начисление и списание провизий */
        run dcls67.  /*корректировка внебалансовых остатков по кредитам КИК (26 уровень)*/

        run dclspenot. /* Возврат и списание отсроченной пени */

        run dcls_clclose. /* обнуление остатков КЛ при наступлении срока периода доступности */

display " Calculate FUN & SCU Interest......................." string(time,"HH:MM:SS") skip with frame msg.

        /* run put(5). */
        run dcls14. /* Начисление процентов по РЕПО */
        run dclsscu. /* Начисление процентов по Ценным Бумагам */
        /* run put(6). */

       /* run dcls41. что это? напишите кто знает...*/

display " Comission calculate................................" string(time,"HH:MM:SS") skip with frame msg.

        run put(41).
        run dclstarif.
        run put(42).
        if s-bday eq true and month(g-today) ne month(s-target) then
        do:
                run put(7).
		display " Start Pay Accrued Interest........................." string(time,"HH:MM:SS") skip with frame msg.
                /*run dcls21.*/ /*Выплата процентов по счетам клиентов и Удержание налога на нерeзидентов*/

                run put(9).
                run dcls2. /*Удержание процентов за овердрафт*/

                run put(11).
                run dcls32.  /* сбор комиссии за обслуж. счета(кроме врем.) */

        end.


display " Comission GET......................................" string(time,"HH:MM:SS") skip with frame msg.

        run put(44).
        run getcom. /* Удержание комиссии */
        run compens.    /* Начисление вознаграждения для АО компания по страхованию жизни */
        run dclsLCcom.  /* Амортизация комиссии по аккредитивам */
        run dclslncom.  /* Амортизация комиссии по кредитам */
        run dclsgarcom.  /* Амортизация комиссии по гарантиям */
        if s-bday = true then run dclsgarpog. /*погашение комиссии по графику для гарантий*/
        run dclspccom. /* Отнесение комиссии по ПК на доходы */
display " Cash Pooling......................................." string(time,"HH:MM:SS") skip with frame msg.
        run put(43).
        run cls-corp. /*Погашение отрицательного остатка в закрытии дня (корпоративные клиенты)*/

display " Create fakturis...................................." string(time,"HH:MM:SS") skip with frame msg.
        run put(45).
        run s-fakturis0. /*создание счетов-фактур*/

        if s-bday eq true and month(g-today) ne month(s-target) then
        do:
                if v-ourbank = 'TXB00' then run lcmonrep.  /* формирование ежемесячного отчета для международного департамента и бэк-офиса*/
               /* run s-pvn.*/ /*формирование отчетов по счетам-фактурам для Департамента Налоговой политике, формируется только при переходе на следующий месяц*/
        end.
/*
display " ODA payment......................" string(time,"HH:MM:SS") skip with frame msg.
        run put(12).
        */
       /* run trxoda. Начисление/оплата овердрафта k.gitalov убрал т.к. ломает работу кэш пулинга*/

display " Start CIF subled treatment........................." string(time,"HH:MM:SS") skip with frame msg.


        if s-bday then
        do:
                run put(14).

		display " Posting Trx........................................" string(time,"HH:MM:SS") skip with frame msg.

                run put(15).
               /* run dcls60.*/ /*??????????????????Кто знает опишите....*/

                run put(17).
                run dcls37. /*Конвертация по закрытию дня (Переоценка вал. позиции)*/

                run dclsnds. /*начисление НДС*/

                /*
                run dcls39d.
                */
                run dcls_raznoska.
                run dcls39c1. /*Закрытие счетов конвертации*/
                run dcls39c2. /*Закрытие счетов конвертации*/
                run dcls39c. /*Закрытие счетов конвертации*/
                run dcls_after.


        end.

        if s-bday eq true and month(g-today) ne month(s-target) then do:
              /*  run r-nds.*/ /*Расчет НДС с заключительными проводками при закрытии месяца*/
                run gcvpmove.     /*при закрытии месяца перенос файлов ГЦВП в архив.*/
        end.

        run put(13).
        run dcls27. /*Здесь пишутся истории за каждый день по всем таблицам счетов! - aab, hisarp, hisfun, hisock, hisast и история справочника sub-cod - hissc*/

display " Start Balance Update..............................." string(time,"HH:MM:SS") skip with centered frame msg.
        run put(19).
        run dcls51. /*Изменение/обновление баланса */

display " Start Points Dayclose.............................." string(time,"HH:MM:SS") skip with centered frame msg.
        run put(21).
        run dcls26.          /*Баланс кассы (100100) по РКО*/

        do transaction :
                find sysc where sysc.sysc eq "GLDATE" exclusive-lock .
                sysc.daval = g-today.
        end.

display " Posting Expense...................................." string(time,"HH:MM:SS") skip with centered frame msg.
        run put(23).
        run dcls58. /*корректировка счетов доходов/расходов*/

display " Balance Sheet......................................" string(time,"HH:MM:SS") skip with frame msg.
        run put(25).
        run dcls3. /*Формирование истории баланса glbal -> glday*/

display " Totaling G/L for Average Balance..................." string(time,"HH:MM:SS") skip with frame msg.
        run put(29).
        run dcls40. /*формирование суммы балансов по месяцам*/

display " Creating a list of payment orders for DPP..........." string(time,"HH:MM:SS") skip with frame msg.
        run a_filpplist. /* формирование списка для длительных платежных поручений  */

/*galina - амортизация коммисии по аккредитивам*/
/*display " Letter of credit comission amortization......." string(time,"HH:MM:SS") skip with frame msg.
run dclsLCcom.*/
/*********/

        v-operdate = g-today.
        /*формирование истории закрытых опер.дней******************/
        do transaction :
                create cls.
                        cls.cls = s-target - 1.
                        cls.whn = g-today.
                        cls.who = g-ofc.
                        cls.del = s-bday.
        end.
        /*********************************************************/

display " Calculate payments amounts........................." string(time,"HH:MM:SS") skip with frame msg.

        run dcls61. /* 25/01/2005 kanat - Подсчет сумм исходящих платежей по 6 типу за день */

display " Close tarif for clients with closed accounts......." string(time,"HH:MM:SS") skip with frame msg.

    run dcls_62. /* 29.03.05 saltanat - Процедура предназначена для закрытия льгот в тарификаторе для клиентов с недействующими счетами.*/

        do transaction:
		/*14.10.2005 u00121 Обнуление количества разрешенных проводок в операционный день, по клиентам котролирующихся биометрией*/
		for each biojhcnt where biojhcnt.dt = g-today. /*найдем всех клиентов с разрешенными биопроводками за закрываемый день*/
			if biojhcnt.cnt <> 0 then /*если у них к закрытию дня остались разрешенные транзакции, то */
				biojhcnt.cnt = 0. /*обнуляем их количество*/
		end.
		/*************************************************************************************************************************/

                /*14.03.2005 u00121 Проверка длительности рабочей недели, если по каким либо причинам она изменялась, например, с 5-дневной на 6-дневную*/
                find sysc where sysc.sysc = 'WKSTRT' no-error.  /*Проверка начала недели*/
                if avail sysc and sysc.daval = s-target then /*если дата, указаная в sysc совпадает с датой опердня  на который перешла Прагма*/
                do: /*то, значит с этой даты начинается нормальная рабочая неделя - по умолчанию 5-дневная*/
                        sysc.chval = "2". /*начало недели с понедельника*/
                        sysc.inval = 2.
                end.

                find sysc where sysc.sysc = 'WKEND'  no-error. /*проверка окончания недели*/
                if avail sysc and sysc.daval = s-target then /*если дата, указаная в sysc совпадает с датой опердня  на который перешла Прагма*/
                do: /*то, значит с этой даты начинается нормальная рабочая неделя - по умолчанию 5-дневная*/
                        sysc.chval = "6". /*конец недели с пятницы*/
                        sysc.inval = 6.
                end.
                /****************************************************************************************************************************************/
                /* 06.10.2005 г. - suchkov - Автоматическая разблокировка кассы при закрытии опердня. */
                find first sysc where sysc.sysc = "CASVOD" no-error .
               /*перед разблокировкой проверим была ли блокировка?*/
               /*14.11.2012 г. - id00477 - Убрал процерку блокировки кассы для ЦО и добавил в рассылку Anton.Marchenko@fortebank.com*/
                find first cmp.
                if available sysc and sysc.loval = false and not cmp.name matches "*МКО*" and cmp.name matches "*Филиал*" then
                     run mail ("Ivan.Karasev@fortebank.com;Alexandr.Korzhov@fortebank.com;Anton.Marchenko@fortebank.com",
                     "METROKOMBANK <mkb@metrokombank.kz>",
                     "Касса не заблокирована ",
                     "~nКасса не заблокирована : ~n"  + cmp.name + "~n~n Дата - " + string(g-today),
                     "1", "", "" ).


                if available sysc then sysc.loval = false .
                /****************************************************************************************************************************************/
        end.
display " Dayclose finished.................................." string(time,"HH:MM:SS") skip with frame msg.

        run put(31).
        run put(32).

output stream m-out close.

/* копирование прогнозных курсов валют в текущие*/
do transaction:
  for each crc exclusive-lock:
    find first crcpro where crcpro.crc = crc.crc and crcpro.regdt = s-target no-lock no-error.
    if avail crcpro and crcpro.rate[1] <> crc.rate[1] then do:
        assign crc.rate[1] = crcpro.rate[1] crc.regdt = v-operdate.
        create crchis.
        buffer-copy crc to crchis.
        crchis.rdt = crc.regdt.
        crchis.who = g-ofc.
        crchis.whn = v-operdate.
        crchis.tim = 99999.
    end.
  end.
end.

/*aigul*/
run sysc-day.
/*run P_vccomp.*/
/**/
/* блокировка валют при закрытии дня------------------*/
/* В закрытии дня блокируем валюты, что бы на следующий день
        не было возможности провести наличный обмен валюты
        до выставления курса покупки и продажи валют . */
   run crcclose.
/*-------------------------------------------------------*/

run daycloserlogwrite("День закрыт на базе " + dbname).

message " Finish " . pause .
quit. /*Опер день закрыли, выход*/

