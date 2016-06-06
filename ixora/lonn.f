/* lonn.f
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
         30/01/2006 Natalya D. - добавлено поле Депозит
         11.01.2013 evseev - ТЗ-1530
*/

define variable dam1-cam1 as decimal.
define variable i-dt      as date.
define variable paraksts as logical format "ParakstЁts/Nav parakstЁts".

form /* "ѓ"
    v-vards                  no-label skip */
    v-cif                    label "ѓКлиент......"
    help "Код клиента; F2-код; F4-выход; F1-далее"
    loncon.lon               label "Кредит......"
    help "Номер кредитного счета; F4-выход; F1-далее" skip
    v-lcnt format "x(16)" validate(trim(v-lcnt) = "" or v-lcnt = old-lcnt or
    not can-find(first loncon where loncon.lcnt = v-lcnt),
    "Повторный номер договора")
                             label "ѓДоговор....."
    help "Nr договора; F2-ввод дополнения к договору; F4-выход; F1-далее"

    lon.gua                  label "Вид........."
    /*
    help "LO - Кредит; CL - Кредитная линия; OD - Овердрафт; LK - Лизинг"
    */
    validate(lon.gua = "LO" or lon.gua = "CL" or lon.gua = "OD" or lon.gua =
             "LK","Варианты - LO,CL,LK или OD")
    skip
    loncon.lcntsub           label "Договор Суб." format "x(29)"
    help "Номер договора субсидирования; F4-выход; F1-далее" skip

    s-longrp validate(can-find(longrp where longrp.longrp = s-longrp),
    "Код не найден в справочнике")
                             label "ѓГруппа......"
    help "Код группы; F2-справочник; F4-выход; F1-далее"
    v-uno               label       "Тип.........." skip
    lon.crc validate(can-find(crc where crc.crc = lon.crc),
    "Код не найден в справочнике")
                             label "ѓВалюта......"
    help "Код валюты; F2-справочник; F4-выход; F1-далее"
    crc-code format "x(36)"  no-label skip
    s-cat format "999.99"    label "ѓЦель........"
    help "Цель кредита; F2-справочник; F4-выход; F1-далее"
    cat-des format "x(20)"   no-label
    loncon.objekts format "x(48)"
                             label "ѓОбъект......"
    help "Объект кредита; F4-выход; F1-далее"
    lon.rdt                  label "ѓС..........."
    help "Дата заключения договора; F4-выход; F1-далее"
    lon.duedt                label "По.........."
    help "Срок погашения договора; F4-выход; F1-далее"  skip
    lon.opnamt format ">>>,>>>,>>9.99" validate(lon.opnamt >= viss,
    "Сумма кредита меньше долгового остатка")
                             label "ѓСумма......."
    help "Сумма кредита; F4-выход; F1-далее"
    dam1-cam1 format ">>>,>>>,>>9.99" label "Остаток....."
    s-prem format "x xxxxxxxx"        label "ѓ% ставка...."
    help "Годовая процентная ставка (база F или V); F4-выход; F1-далее"
 /*   lon.lcr validate(lon.lcr <> "","Невыполняемое поле")
                             label "Отрасль....."
    help "Счет овердрафта; F4-выход; F1-далее" */
    lon.ddt[5] format "99/99/9999"   label "Пролонгация1..."
    help "Дата первой пролонгации; F4-выход; F1-далее"
    loncon.proc-no  format 'x(15)'  label "ѓвыплата % с "
    help "Начало погашения процентов; F4-выход; F1-далее"
    lon.cdt[5] format "99/99/9999"   label "Пролонгация2..."
    help "Дата второй пролонгации; F4-выход; F1-далее"
    loncon.sods1 validate(loncon.sods1 >= 0,"Штрафн.% негативный")
                             label "ѓШтраф%(выб)"
    help "Штрафной % за выбор просроченного кредита; F4-выход; F1-далее"
    loncon.sods2 validate(loncon.sods2 >= 0,"Штрафн.% негативный")
                             label "Штраф%(опл)"
    help "Штрафной % за просроченную оплату; F4-выход; F1-далее"
    i-dt format "99/99/9999" label "ѓВыбрать до..."
    validate(i-dt >= lon.rdt and i-dt < lon.duedt,"")
    help "Срок выборки кредита; F4-выход; F1-далее"
    paraksts                 label "Договор...."
    help "N/P-Не подписано/Подписано; F4-выход; F1-далее"
    loncon.vad-amats         label "ѓРуководитель...."
    help "Должность руководителя; F4-выход; F1-далее"
    loncon.vad-vards         label "ѓИмя........."
    help "Имя,фамилия руководителя; F2-ввод паспортн.данных; F4-выход;F1-далее"
    loncon.galv-gram         label "ѓГл.бухгалтер"
    help "Имя,фамилия гл.бухгалтера; F4-выход; F1-далее"
    loncon.rez-char[9]       label " Nr налог.пл" format "x(14)"
    help "Nr налог.регистра " skip
    loncon.kods              label "ѓБанк........"
    help "Код банка клиента; F4-выход; F1-далее"
    loncon.konts             label "Счет........"
    help "Расчетный счет клиента; F4-выход; F1-далее"
    loncon.talr              label "ѓТелефон....."
    help "Телефонный номер клиента; F4-выход; F1-далее"
    loncon.deposit           label "ѓДепозит........"
    help "Под залог депозита; F4-выход; F1-далее"

    lon.basedy  validate(lon.basedy = 365 or lon.basedy = 360," ")
                             label "Дней в году.."
    help "Кол-во дней в году-360 или 365; F4-выход; F1-далее"
   "ђ”””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””"
with side-label no-hide 4 columns column 15
     no-box row 4 frame lon.
form v-vards format "x(60)" with no-label no-hide no-box
     overlay row 3 column 15 frame cif.

define variable m1 as character init "Дата регис.".
define variable m2 as character init "Срок".
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
/*------------------------------------------------------------- ---------------
  #3.
     1.izmai‡a - formi‡ai pielikts kl–t kredЁta atlikuma lauks
-----------------------------------------------------------------------------*/
