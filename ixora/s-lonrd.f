/* s-lonrd.f
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
*/

/*----------------------------------------------------------------------------
  #3.KredЁtu noformёЅana
----------------------------------------------------------------------------*/
define  shared variable s-lon    like lon.lon.
define  shared variable s-longrp like longrp.longrp.
define  shared variable grp-name as character.
define  shared variable crc-code as character.
define  shared variable cat-des  as character.
define  shared variable v-cif    like cif.cif.
define  shared variable v-lcnt   like loncon.lcnt.
define  shared variable v-vards  like cif.name format "x(36)".
define  shared variable s-cat as character.
define  shared variable s-apr as character.
define variable old-lcnt like loncon.lcnt.
define variable i-dt  as date.
define variable paraksts as logical format "ParakstЁts/Nav parakstЁts".
define variable ja-ne as logical.
define variable old-gua like lon.gua.
define variable old-cat like lon.loncat.
define variable old-noz as character.
define variable old-rdt like lon.rdt.
define variable old-duedt like lon.duedt.
define variable old-opnamt like lon.opnamt.
define variable old-prem like lon.prem.
define variable old-lcr like lon.lcr.
define variable old-sods1 like loncon.sods1.
define variable old-sods2 like loncon.sods2.
define variable old-proc-no like loncon.proc-no.
define variable m3 as character init "Заменить ".
define variable m4 as character init " на ".
define variable pap as character.
define variable dam1-cam1 as decimal.
def var viss like lon.opnamt.
def var datt as date.
def var vf0 as inte.
define variable v-f1 as integer.

define variable iem as character.
form pap format "xx"    label "Дополнит.Nr..." help "Номер доп.соглашения"
     iem format "x(50)" label "Причина......." help "Причина изменения"
     ln%his.stdat       label "Дата изменения"
     ln%his.rdt         label "С............."
     ln%his.duedt       label "По............"
     ln%his.opnamt      label "Сумма........."
     ln%his.intrate     label "Процент......."
     ln%his.pnlt1       label "Штраф.%(выб.)."
     ln%his.pnlt2       label "Штраф.%(опл.).."
with overlay 2 columns row 4 side-labels centered title
"Изменение параметров кредита " + s-lon
frame pap.

define buffer lon1 for lon.
define buffer loncon1 for loncon.

define shared frame lon.

form 
    v-cif                    label "ѓКлиент......"
    help "Код клиента; F2-код; F4-выход; F1-далее"
    loncon.lon               label "Кредит......"
    help "Номер кредитного счета(KKFs); F4-выход; F1-далее" skip
    v-lcnt validate(trim(v-lcnt) = "" or v-lcnt = old-lcnt or
    not can-find(first loncon where loncon.lcnt = v-lcnt),
    "Повторный номер договора")
                             label "ѓДоговор....."
    help "Договор Nr; F2-ввод дополнения к договору; F4-выход; F1-далее"
    lon.gua                  label "Вид........."
    help "LO - Кредит; CL - Кредитная линия; OD - Овердрафт; LK - Лизинг"
    validate(lon.gua = "LO" or lon.gua = "CL" or lon.gua = "OD"
    or lon.gua = "LK" or lon.gua = "FK","Варианты - LO,CL,LK,FK или OD") 
    skip
    s-longrp validate(can-find(longrp where longrp.longrp = s-longrp),
    "Код не найден в справочнике")
                             label "ѓГруппа......"
    help "Код группы; F2-справочник; F4-выход; F1-далее"
    v-uno                    label "Тип.........."  
    help "Тип кредита; F2-справочник; F4-выход; F1-далее" skip
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
    help "Срок погашения договора; F4-выход; F1-далее" skip
    lon.opnamt format ">>>,>>>,>>9.99" validate(lon.opnamt >= viss,
    "Сумма кредита меньше долгового остатка") 
                             label "ѓСумма......."
    help "Сумма кредита; F4-выход; F1-далее"
    dam1-cam1 format ">>>,>>>,>>9.99" label "Остаток...."
    s-prem format "x xxxxxxxx" label "ѓ% ставка...." 
    help "Годовая процентная ставка (база F или V); F4-выход; F1-далее"
/*    lon.lcr validate(lon.lcr <> "","Невыполняемое поле")
                             label "Отрасль....." 
    help "Счет овердрафта; F4-выход; F1-далее" */
    loncon.proc-no           label "ѓвыплата % с "
    help "Начало погашения процентов; F4-выход; F1-далее"
    loncon.sods1 validate(loncon.sods1 >= 0,"Штрафн.% негативный")
                             label "ѓШтраф%(выб)"
    help "Штрафной % за просроченную оплату; F4-выход; F1-далее"
    loncon.sods2 validate(loncon.sods2 >= 0,"Штрафн.% негативный")
                             label " Штраф%(опл)"
    help "Штрафной % за просроченную оплату; F4-выход; F1-далее"
    i-dt format "99/99/9999" label "ѓВыбрать до..."
    validate(i-dt >= lon.rdt and i-dt < lon.duedt,"")
    help "Срок выборки кредита; F4-выход; F1-далее"
    paraksts                 label "Договор....."
    help "N/P-Не подписано/Подписано; F4-выход; F1-далее"
    loncon.vad-amats         label "ѓРуководитель...."
    help "Должность руководителя; F4-выход; F1-далее"
    loncon.vad-vards         label "ѓИмя........."
    help "Имя,фамилия руководителя; F2-ввод паспортн.данных; F4-выход;F1-далее"
    loncon.galv-gram         label "ѓГл.бухгалтер"
    help "Имя,фамилия гл.бухгалтера; F4-выход; F1-далее"
    loncon.rez-char[9]       label " Номер плат." format "x(14)"
    help "Регистрационный номер "  skip
    loncon.kods              label "ѓБанк........"
    help "Код банка клиента; F4-выход; F1-далее"
    loncon.deposit  /*validate(can-find(aaa where aaa.aaa = v-deposit),"")*/
                             label "Депозит......"
    help "Под залог депозит; F4-выход; F1-далее"
    loncon.konts             label "Счет........"
    help "Расчетный счет клиента; F4-выход; F1-далее"
    loncon.talr              label "ѓТелефон....."
    help "Телефонный номер клиента; F4-выход; F1-далее"
    lon.basedy  validate(lon.basedy = 365 or lon.basedy = 360," ")
                             label "Дней в году.."
    help "Кол-во дней в году-360 или 365; F4-выход; F1-далее"
   "ђ”””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””"
with side-label no-hide 4 columns column 15 
     no-box row 4 frame lon.

form v-vards format "x(60)" with no-label no-hide no-box 
     overlay row 3 column 15 frame cif.

