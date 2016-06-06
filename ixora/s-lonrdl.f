/* s-lonrdl.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        02/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        25.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        02/06/2004 madiyar - добавил возможность ввода 4-ой схемы
        03/08/2004 tsoy   - добавил в сохранение истории новые параметры ( Коммисисия за кред.линию, Пролонгация 1,
                                                                           Пролонгация 2, Валюта индексации, Курс договора)
        30/01/2006 Natalya D. - добавлено поле Депозит
        04/05/06 marinav Увеличить размерность поля суммы
        21/02/2008 madiyar - переделал форму под новый размер терминала
        11.12.2008 galina - подвинула фрейм lon вправо; подвинула вправо фрейм cif
        15/12/2008 galina - явно указала ширину фрема cif
        25/03/2009 galina - добавила поле Поручител
        23.04.2009 galina - убираем поле поручитель
        15/10/2009 madiyar - добавил old-lonaaa
        19.02.10   marinav - формат счета 20
        27/05/2010 madiyar - расширил формат поля v-lcnt
        09/06/2010 galina - добавила ставку по штрафам до и после 7 дней просрочки
        17/07/2010 madiyar - 6-ая схема
        23/08/2010 madiyar - ставка по комиссии prem_s
        24/08/2010 madiyar - premsdt
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        11/02/2011 madiyar - подправил validate для lon.idtXX
        08/11/2011 madiyar - доп. поля в списке кредитов
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        18/06/2012 kapar - новое поле (Дата прекращения дополнительной % ставки)
        20/06/2012 kapar - новое поле (Дата начала дополнительной % ставки)
        11.01.2013 evseev - ТЗ-1530
        24/01/2013 zhassulan - ТЗ 1653 (изменение валидации для поля "Схема")
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
        29/05/2013 sayat(id01143) - изменена нижняя граница для параметра premsdt с g-today на lon.rdt ТЗ 1852 от 22/05/2013

*/

define variable old-lcnt like loncon.lcnt.
define variable old-lcntsub like loncon.lcntsub.

define variable old-dtsub like loncon.dtsub.
define variable old-lcntdop like loncon.lcntdop.
define variable old-dtdop like loncon.dtdop.
define variable old-obes-pier like loncon.obes-pier.

define variable paraksts as logical format "Подписан /Не подписан".
define variable v-deposit like aaa.aaa.
define variable ja-ne as logical.
define variable old-gua like lon.gua.
define variable old-cat like lon.loncat.
define variable old-noz as character.
define variable old-rdt like lon.rdt.
define variable old-duedt like lon.duedt.
define variable old-opnamt like lon.opnamt.
define variable old-prem like lon.prem.
define variable old-rdate like lon.rdate.
define variable old-ddate like lon.ddate.
define variable old-ddt like lon.ddt[5].
define variable old-cdt like lon.cdt[5].
define variable old-lonaaa like lon.aaa.
define variable old-lonaaad like lon.aaad.
define variable old-sods1 like loncon.sods1.
define variable old-sods2 like loncon.sods2.

define variable old-penprem like lon.penprem.
define variable old-penprem7 like lon.penprem7.
define variable prem_s as deci.
define variable premsdt as date.
define variable cl-voz as deci no-undo.
define variable cl-nevoz as deci no-undo.

define variable old-proc-no like loncon.proc-no.
define variable m1 as character init "Дата регис.".
define variable m2 as character init "Срок".
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
define variable pap as character.
define variable dam1-cam1 as decimal.
def var viss like lon.opnamt.
def var datt as date.
def var vf0 as inte.
define variable v-f1 as integer.

define variable iem as character.

/*galina 25/03/2009*/
/*def var v-guarantor as char format "x(50)".*/

form pap format "xx"    label "Дополнит.Nr..." help "Номер доп.соглашения"
     iem format "x(50)" label "Причина......." help "Причина изменения"
     ln%his.stdat       label "Дата изменения"
     ln%his.rdt         label "С............."
     ln%his.duedt       label "По............"
     ln%his.opnamt      label "Сумма........."
     ln%his.intrate     label "Процент......."
     ln%his.pnlt1       label "Штраф.%(выб.)."
     ln%his.pnlt2       label "Штраф.%(опл.).."
     ln%his.comln       label "Комиссия за кред.линию...."
     ln%his.long1       label "Пролонгация 1............."
     ln%his.long2       label "Пролонгация 2............."
     ln%his.kcrc        label "Валюта индексации........."
     ln%his.drate       label "Курс договора............."

with overlay 2 columns row 4 side-labels centered title "Изменение параметров кредита " + s-lon frame pap.

define buffer lon1 for lon.
define buffer loncon1 for loncon.
define var cif-kod as char.

form
    v-cif               label "Клиент......" validate (can-find(cif where cif.cif = v-cif), "Нет такого клиента!")
                        help "Код клиента; F2-код; F4-вых; F1-далее"
    loncon.lon          at 46 label "Кредит......"
                        help "Номер кредитного счета; F4-вых; F1-далее" skip
    v-lcnt              label "Договор....." format "x(29)"
                        help "Договор Nr; F2-ввод дополнения к договору; F4-вых; F1-далее"
    lon.gua             at 46 label "Вид........." validate(lon.gua = "LO"  or lon.gua = "CL" ,"Вариант - LO,CL" ) skip
    loncon.lcntdop      label "Доп. Согл..." format "x(29)" help "Номер дополнительного соглашения; F4-выход; F1-далее"
    loncon.dtdop        at 46 label "Дата доп.сог" format "99/99/9999"
                        help "Дата дополнительного соглашения; F4-вых; F1-далее" skip
    loncon.lcntsub      label "Договор Суб." format "x(29)" help "Номер договора субсидирования; F4-выход; F1-далее"
    loncon.dtsub        at 46 label "Дата дог.суб" format "99/99/9999"
                        help "Дата договора субсидирования; F4-вых; F1-далее" skip
    s-longrp            label "Группа......" validate(can-find(longrp where longrp.longrp = s-longrp), "Код не найден в справочнике")
                        help "Код группы; F2-справ.; F4-вых; F1-далее"
    v-uno               at 46 label "Тип........." /*format ">,>>>,>>9"*/
                        help "Тип кредита; F2-справ.; F4-вых; F1-далее" skip
    lon.plan            label "Схема......." validate(((s-longrp = 90 or s-longrp = 92) and (lon.plan > 0 and lon.plan < 6 and lon.plan <> 3))
                                                        or ((s-longrp <> 90 or s-longrp <> 92) and (lon.plan > 0 and lon.plan < 3)),
                                                      "Введите схему кредита: 1-обычная, 2-аннуитет")
                        help "1-обычная, 2-аннуитет, 3-равном., 4-равном.ежеднев.; F4-вых; F1-далее"
    lon.day             at 46 label "День расчета" validate(lon.day > 0 and lon.day < 32, "Введите день расчет кредита, от 1 до 31")
                        help "Расчетный день клиента (0 - для старых крелитов); F4-выход; F1-далее" skip
    lon.crc             label "Валюта......" validate(can-find(crc where crc.crc = lon.crc), "Код не найден в справочнике")
                        help "Код валюты; F2-справ.; F4-вых; F1-далее"
    crc-code            at 18 no-label format "x(10)"
    lon.trtype          at 46 label "Тип транша.." skip

    lon.clmain          label "Ссуд.счет КЛ" validate(if lon.clmain <> '' then can-find(lon1 where lon1.lon = lon.clmain) else true, "Cсудный счет не найден")
                        help "Ссудный счет кредитной линий; F4-вых; F1-далее"
    clcif               at 46 label "Cif код КЛ.." validate(if lon.clmain <> '' then can-find(lon1 where lon1.lon = lon.clmain) else true, "Cсудный счет не найден")
                        help "Код клиента кредитной линий; F4-вых; F1-далее" skip
    clname              label "Наимено-е КЛ" validate(if lon.clmain <> '' then can-find(lon1 where lon1.lon = lon.clmain) else true, "Cсудный счет не найден")
                        help "Наименование клиента кредитной линий; F4-вых; F1-далее" skip

    loncon.objekts      label "Объект......" format "x(70)" validate(trim(loncon.objekts) <> "", "Введите объект кредита")
                        help "Объект кредита; F4-вых; F1-далее" skip
    lon.rdt             label "С..........."
                        help "Дата заключения договора; F4-вых; F1-далее"
    lon.duedt           at 46 label "По.........."
                        help "Срок погашения договора; F4-вых; F1-далее" skip
    lon.duedt15         label "Погаш(возоб)" validate((lon.duedt15 >= lon.rdt and lon.duedt15 <= lon.duedt) or (lon.duedt15 = ?),"")
                        help "Срок погашения возобн. КЛ; F4-вых; F1-далее"
    lon.duedt35         at 46 label "Погаш(невоз)" validate((lon.duedt35 >= lon.rdt and lon.duedt35 <= lon.duedt) or (lon.duedt35 = ?),"")
                        help "Срок погашения невозобн. КЛ; F4-вых; F1-далее" skip
    lon.opnamt          label "Сумма......." format ">,>>>,>>>,>>9.99" validate(lon.opnamt >= viss and lon.opnamt > 0,"Сумма кредита меньше долгового остатка")
                        help "Сумма кредита; F4-вых; F1-далее"
    dam1-cam1           at 46 label "Остаток....." format ">,>>>,>>>,>>9.99" skip

    cl-voz              label "Ост.ВозКЛ..." format ">,>>>,>>>,>>9.99" help "Остаток возобновляемой кредитной линии; F4-вых; F1-далее"
    cl-nevoz            at 46 label "Ост.НевозКЛ." format ">,>>>,>>>,>>9.99" help "Остаток невозобновляемой кредитной линии; F4-вых; F1-далее" skip

    s-prem              label "Осн.% ставка" format "x xxxxxxxx" validate(trim(s-prem) <> "", "Введите вознаграждение")
                        help "Годовая %% ставка (база F или V); F4-вых; F1-далее"
    d-prem              at 46 label "Доп.% ставка" format "x xxxxxxxx" validate(trim(d-prem) <> "", "Введите вознаграждение")
                        help "Годовая дополнительная %% ставка (база F или V); F4-вых; F1-далее" skip
    lon.rdate           label "Доп.% с....." format "99/99/9999"
                        help "Дата начала дополнительной % ставки; F4-вых; F1-далее"
    lon.ddate           at 46 label "Доп.% по...." format "99/99/9999"
                        help "Дата прекращения дополнительной % ставки; F4-вых; F1-далее"  skip
    lon.ddt[5]          label "Пролонгация1" format "99/99/9999"
                        help "Дата 1-й пролонгации; F4-вых; F1-далее"
    lon.cdt[5]          at 46 label "Пролонгация2" format "99/99/9999"
                        help "Дата 2-й пролонгации; F4-вых; F1-далее" skip
    loncon.proc-no      label "Выплата % с " format 'x(15)'
                        help "Начало погашения %%; F4-вых; F1-далее" skip
    lon.penprem         label "Штраф%(до 7 дней)" format ">>9.99" help "Штраф за просроченную оплату до семи дней просрочки; F4-вых; F1-далее"
    lon.penprem7        at 46 label "Штраф%(после 7 дней)" format ">>9.99" help "Штраф за просроченную оплату после семи дней просрочки; F4-вых; F1-далее" skip
    loncon.sods1        label "Штраф%(выб)." validate(loncon.sods1 >= 0,"")
                        help "Штраф за просроченную оплату; F4-вых; F1-далее"
    v-komcl             at 46 label "Комис. за CL" validate(v-komcl >= 0,"")
                        help "Штраф за неисп кред линию; F4-вых; F1-далее" skip
    prem_s              label "Ком.ставка.." format ">>9.99" help "Ставка комиссии по кредитам бывших сотрудников" validate(prem_s >= 0,"")
    premsdt             at 46 label "Начислять с." format "99/99/9999" validate(premsdt >= lon.rdt and premsdt < lon.duedt,"") skip
    lon.idt15           label "ВыбратьДоВоз" format "99/99/9999" validate((lon.idt15 >= lon.rdt and ((lon.idt15 < lon.duedt15) or (lon.duedt15 = ?))) or (lon.idt15 = ?),"")
                        help "Срок выборки возобн. КЛ; F4-вых; F1-далее"
    lon.idt35           at 46 label "ВыбратьДоНев" format "99/99/9999" validate((lon.idt35 >= lon.rdt and ((lon.idt35 < lon.duedt35) or (lon.duedt35 = ?))) or (lon.idt35 = ?),"")
                        help "Срок выборки невозобн. КЛ; F4-вых; F1-далее" skip
    paraksts            label "Договор....."
                        help "N/P-Не подписано/Подписано; F4-вых; F1-далее" skip
    loncon.vad-amats    label "Руков(должн)" format "x(25)"
                        help "Должность рук-ля; F4-вых; F1-далее"
    loncon.vad-vards    at 46 label "Руков.(ФИО)." format "x(25)"
                        help "Имя,фамилия рук-ля; F2-ввод паспортн.данных; F4-вых;F1-далее" skip
    loncon.galv-gram    label "Гл.бухгалтер"
                        help "Имя,фамилия гл.бух; F4-вых; F1-далее" skip
    loncon.rez-char[9]  label "РНН........." format "x(12)" help ""
    v-deposit           at 46 label "Депозит....."
                        help "Nr депоз-го счёта; F2-справ.; F4-вых; F1-далее" skip
    lon.aaa             label "Счет........"  format "x(20)"
                        help "Расчетный счет клиента; F4-вых; F1-далее"
    lon.aaad            at 46 label "ARP счет...."  format "x(20)"
                        help "Расчетный счет клиента; F4-вых; F1-далее" skip
    lon.basedy          label "Дней в году." validate(lon.basedy = 365 or lon.basedy = 360," ")
                        help "Кол-во дней в году-360 или 365; F4-вых; F1-далее" skip
    v-crc               label "Вал.индекс.." format 'z9' help ""
    v-rate              at 46 label "Курс по дог." format 'zz9.99'  help "" skip
    loncon.who          label "Оформ/редакт"
    loncon.pase-pier    at 46 label "Ответств...." format "x(10)" skip
    loncon.obes-pier    label "Отв.по обесп" format "x(10)" skip
    /*v-guarantor label "Поручитель"*/
    with side-label no-hide /*6 columns*/ column 25 no-box row 4 width 110 frame lon.

form v-vards format "x(60)" with width 65 no-label no-hide no-box overlay row 3 column 25 frame cif.

form loncon.lon format "x(9)" lon.gua lon.rdt format "99/99/99" help
     "F4-выход; вверх/вниз-поиск; F1,Enter-выбор; F3-замена списка"
     with 33 down no-label title "Кредит" row 3 scroll 1 frame ln.

