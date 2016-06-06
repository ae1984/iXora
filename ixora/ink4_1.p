/* ink4_1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Регистрация инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.6.2.1
 * BASES
        BANK COMM
 * AUTHOR
        07/10/2004 dpuchkov
 * CHANGES
        19.01.2005 dpuchkov перенес кнопку История в основной фрейм
        03.02.2005 dpuchkov при удалении ИР автоматически снимать суммы с внебаланса
        08.09.2005 dpuchkov изменил параметры печати отчета
        09.09.2005 dpuchkov добавил дату регистрации в отчет.
        23.08.2006 u00124   оптимизация
        08.11.2008 alex     оплата ИР вручную
        25.11.2008 galina - изменила on help для поля aas.bnf
                            изменила on help для поля aas.dpname
        10.06.2009 galina - добавила формирование платежа для ОПВ и СО
        29/06/2009 madiyar - добавил инкассовые адм.судов
        12/10/2009 galina - добавила оплату ПТП, выставленных нашим банком
        22/10/2009 galina - поправила оплату ПТП
        29/10/2009 galina - исправила определение суммы для частично оплаченных ИР
        27.01.10 marinav - расширение поля счета до 20 знаков
        25/03/2010 galina - поправила определение суммы оплаты для ОПВ и СО
        08/04/2010 galina - снимаем задержанный баланс по социальным РПРО
        23/09/2010 galina - поправила подсчет суммы ИР и спец.инструкций
        28/10/2010 madiyar - 780300 -> 830300
        06/01/2011 marinav - наименование НК берется из taxnk
        06/01/2011 evseev - повтор. предыд.изменения версии 1.23 потерлись.
                            изменил формат "->>>,>>>,>>9.99" на "->>>,>>>,>>>,>>9.99", расширил фреймы
        09/02/2011 madiyar - исправления по ИР адм. судов
        18/02/2011 evseev - устранил ошибку. добавил undo перед return (стр769,773).
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
        18.05.2011 ruslan - добавил функцию on help of
        14/06/2011 evseev - добавил 2 пустых параметра в вызов inktax
        20/06/2011 evseev - из-за перехода на ИИН/БИН, ink4 переименован в ink4_1
        20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
        10/08/2011 evseev - вывод уведомления. ТЗ-1030
        10/08/2011 evseev - ТЗ-1030. Если есть деньги не выводить уведомление
        10/08/2011 evseev - ТЗ-1030. Выводить уведомление, если есть спец. инструкции со статусом 0,1,3. Письмо от Кальяновой Т.
        15.08.2011 ruslan - добавил поиск по наименованию и убрал поиск по менеджеру, изменил основания, прочие разделил на 2 пункта.
        16.08.2011 ruslan - перекомпиляция
        20/09/2011 dmitriy - добавил наименование КБК в поле Примечание
        23/09/2011 dmitriy - обработчик on help для aas.kbk, испаравления по назначению платежа
        02/11/2011 evseev - СЗ от 01.11.2011 другая дата в назн. плат.
        04/11/2011 evseev - перекомпиляция
        16/11/2011 evseev - перекомпиляция
        16/11/2011 evseev - rnnben вместо dpname при оплате ОПВ и СО
        24/11/2011 evseev - ТЗ-1208 отправка уведомлений
        28/11/2011 evseev - ТЗ-1208 отправка уведомлений менеджеру
        21/12/2011 evseev - ТЗ-929. Оплата ИР с вал. счетов
        28.03.2012 aigul - увеличила время для клиринга до 2.45
        02/04/2012 id00810 - добавила v-bankname для печати уведомления
        28/04/2012 evseev - логирование значения aaa.hbal
        03/05/2012 evseev - rebranding. изменил наименование филиала для печати уведомления
        16/05/2012 evseev - rcity из v-banklocat
        15.06.2012 evseev - ТЗ-1397. Отправитель = префикс + наименование
        19.06.2012 evseev - отструктурировал код. вынес save_data в aas2his.i и переименовал в aas2his. добавил mn
        26.06.2012 evseev - ТЗ-1233
        14.11.2012 evseev - ТЗ-1524
        21.11.2012 evseev - ТЗ-1445
        28.11.2012 evseev - ТЗ-1374
*/


{yes-no.i}
{mainhead.i INK4}
{comm-txb.i}
{get-dep.i}
{nbankBik.i}
{convgl.i "bank"}

/* блок объявления переменных ->*/
    def temp-table t-aashist like aas_hist
        field ctc as char.
    def temp-table t-aashist1 like aas_hist
        field name1 as char.
    def temp-table t-aas
        field aaa    like aas.aaa
        field sta    like aas.sta
        field docdat like aas.docdat
        field fsum   like aas.fsum
        field kbk    like aas.kbk
        field knp    like aas.knp.
    def temp-table t-iaccs no-undo
        field icif   like aaa.cif
        field iaaa   like aaa.aaa
        field fsum   like aas.fsum
        field docdat like aas.docdat
        field knp    like aas.knp
        field kbk    like aas.kbk
        field fnum   like aas.fnum.
    def temp-table t-ln
        field rnn  as char
        field name as char
        index main is primary rnn ASC.
    def temp-table t-bud
        field cod  as integer
        field name as char
        index main is primary cod ASC.

    def buffer b-aas  for aas. /**/
    def buffer buf-aas for aas. /* в будущем убрать*/
    def buffer buf-t-aashist for t-aashist.  /**/
    def buffer buf-t-aashist1 for t-aashist1. /**/
    def buffer pl-ofc  for ofc.   /**/
    def buffer buf-ofc1   for ofc. /**/
    def buffer buf-aashist for aas_hist. /**/
    def buffer buf-aaa for aaa. /**/
    def buffer buf-aaar for aaar. /**/

    def stream v-out.
    def stream m-out.

    def new shared var s_l_inkopl       as logical   init false.  /* переменная оплаты ИР */ /*в inktax.p*/
    def new shared var s-rmzir          as char.  /*в inktax.p*/
    def new shared var s-jh like jh.jh.

    def var v-ofile          as char no-undo.
    def var v-ifile          as char no-undo.
    def var v-str            as char no-undo.
    def var v-ourbank        as char no-undo.
    def var vsele            as char form "x(42)" extent 1 initial [" Просмотр истории инкассовых распоряжений "] no-undo.
    def var vsele2           as char form "x(20)" extent 2 initial [" Отозвать ", " Удалить  " /*, " Отказано в акцепте"*/ ] no-undo.
    def var op_kod           AS CHAR format "x(1)" no-undo.
    def var p-ln             LIKE aas_hist.ln no-undo.
    def var p-aaa            LIKE aas_hist.aaa no-undo.
    def var s-aaa            LIKE aaa.aaa no-undo.
    def var v-dep            as integer no-undo.
    def var s_FindAcc        as char      format "x(20)" no-undo.
    def var s_FindCIF        as char      format "x(6)" no-undo.
    def var s_FindName       as char      format "x(10)" no-undo.
    def var dt_FindDateBegin as date no-undo.
    def var dt_FindDateEnd   as date no-undo.
    def var i_indx           as integer no-undo.
    def var v-specin         AS char      INIT '' no-undo.
    def var v-speckr         AS char      INIT '' no-undo.
    def var str_p            as char no-undo.
    def var i-ind            as inte no-undo.
    def var s-vcourbank      as char no-undo.
    def var v-usrglacc       as char no-undo.
    def var v-jh             like jh.jh no-undo.
    def var rcode            as inte no-undo.
    def var rdes             as char no-undo.
    def var v-ofc1           as char no-undo.
    def var vparam2          as char no-undo.
    def var vdel             as char      initial "^" no-undo.
    def var v-dp3            as integer   init 0 no-undo.
    def var b                as logi      no-undo.
    def var v-bnfiik         as char      no-undo.
    def var v-bnfrnn         as char      no-undo.
    def var v-bicbnf         as char      no-undo.
    def var vparam           as char no-undo.
    def var v-sum            as deci no-undo.
    def var v-jhink          like jh.jh no-undo.
    def var v-rem            as char no-undo.
    def var v-param          as char no-undo.
    def var t-sum            as decimal no-undo.
    def var v_doc            as char    no-undo.
    def var v-iikben         as char    no-undo.
    def var v-knp            as char    no-undo.
    def var v-fnum           as char    no-undo.
    def var v-sumh           as deci    no-undo.
    def var v-ln             like aas.ln no-undo.
    def var v-city           as char    no-undo.
    def var v-mailmessage    as char    no-undo.
    def var v-maillist       as char    no-undo extent 5.
    def var v-sp             as char    no-undo.
    def var i                as int     no-undo.
    def var k                as int     no-undo.
    def var l                as int     no-undo.
    def var v-pl             as char no-undo.
    def var v-cod            as char no-undo.
    def var ch_acc           as char no-undo.
    def var phand            AS handle no-undo.
    def var v-cif1           AS char no-undo.
    def var v-rmzsum         as dec     decimals 2 no-undo.
    def var v-inkaaa         like aaa.aaa no-undo.
    def var v-inknum         as char    no-undo.
    def var v-olds           as dec     decimals 2 no-undo.
    def var d_arsum          as dec     decimals 2 no-undo.
    def var d_arsummy        as dec     decimals 2 no-undo.
    def var d-SumOfPlat      as decimal init 0 no-undo.
    def var v-opl            as char    no-undo.
    def var d-tmpSum         as decimal init 0 no-undo.
    def var d_sum            as decimal no-undo.
    def var v_sec            as char    no-undo.
    def var r-cover          as integer no-undo.
    def var aasfsum          like aas.fsum no-undo.
    def var currrate         as decimal no-undo.
    def var v-rmzsumval      as dec     decimals 2 no-undo.
    def var v-arp            like arp.arp no-undo.
    def var v-acc            like aaa.aaa no-undo.
    def var v-sumval         as dec     decimals 2 no-undo.
    def var d_arsummykz      as dec     decimals 2 no-undo.
    def var d_arsumkz        as dec     decimals 2 no-undo.
    def var v-oldskz         as dec     decimals 2 no-undo.
    def var d-SumOfPlatval   as decimal init 0 no-undo.
    def var v-flv            as int init 0 no-undo.
    def var v-text           as char no-undo.
    def var v-olds1          as dec     decimals 2 no-undo.
    def var d_arsum1         as dec     decimals 2 no-undo.
    def var d_arsummy1       as dec     decimals 2 no-undo.
    def var v-countaas       as integer no-undo.
    def var v-dt             as date no-undo.
    def var v-yn             as logical init false no-undo.
    def var v-mn as char.


    def QUERY q-help FOR aaa, lgr.
    def QUERY q1     FOR aas.
    def QUERY q4     FOR t-aashist.
    def QUERY q5     FOR t-aashist1.
    def browse b-help query q-help displ
        aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
        aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)" WITH  15 DOWN.
    def browse b1 query q1 displ
        aas.cif format "x(6)" label "CIF-код"
        aas.aaa format "x(20)" label "Счет"
        aas.regdt label 'Дата рег'
        aas.fsum format "->>>,>>>,>>>,>>9.99"  label  "Перв. сумма"
        decimal(aas.docprim) format "->>>,>>>,>>>,>>9.99" label "Ост. сумма"
        aas.irsts format "x(11)" label "Статус"
        with 12 down title "K-2 Инкассовые распоряжения(действующие)" overlay.
    def browse b4 query q4 displ
        t-aashist.ln     format ">>99"  label 'N'
        t-aashist.cif  label 'CIF-код'
        t-aashist.aaa  format "x(20)" label 'Счет'
        t-aashist.regdt  label 'Дата рег'
        t-aashist.payee  format "x(29)" label 'Основание'
        t-aashist.ctc  format "x(14)" label 'Статус'
        with 20 down title "История ИР(действующие и удаленные) " overlay.
    def browse b5 query q5 displ
        t-aashist1.ln format ">>99"  label 'N'
        t-aashist1.name1 format "x(50)" label 'Статус '
        with 12 down title "История инкассовых распоряжений " overlay.

    def button bt_AddNew label "ДОБАВИТЬ НОВОЕ".
    def button bt_Find   label "ПОИСК".
    def button bprint LABEL "Печать"   .
    def button bexit LABEL "Выход"     .
    def button bdetail LABEL "Свойства".
    def button brem LABEL "Удалить"    .
    def button bhistory LABEL "История".
    def button bdethis  LABEL "История операций".
    def button bdtlst  LABEL "Детали".
    def button b-rmz label "Оплата".


    def frame f-rem
        v-rem label 'Назначение платежа' validate(trim(v-rem) <> '','Введите назначение платежа!') view-as editor size 50 by 4
        with side-labels centered row 8 width 80 title "Назначение платежа".
    def frame getlock
        t-aashist1.aaa format "x(20)" label     "Номер счета.           " skip
        t-aashist1.regdt label   "Дата регистрации       " skip
        t-aashist1.fsum format "->>>,>>>,>>>,>>9.99" label  "Сумма оплаты           " validate(aas.chkamt <> 0, "Введите сумму оплаты ") skip
        t-aashist1.fnum  format "x(21)"  label  "Номер инк. распоряжения" skip
        t-aashist1.docdat                label  "Дата инк. распоряжения." skip
        t-aashist1.bnf    format "x(50)" label  "Налоговое управление   " validate(aas.bnf <> "", "Введите название налогового управления (F2-поиск)") skip
        t-aashist1.dpname format "x(12)" label  "РНН налог. управления  " validate(aas.dpname <> "", "Введите РНН налогового управления ") skip
        t-aashist1.payee  /*aas.docprim*/ label "Примечание             " skip
        t-aashist1.kbk label     "КБК" validate(aas.kbk <> "", "Введите КБК ")
        t-aashist1.knp label     "      КНП" validate(aas.knp <> "", "Введите КНП ")
        with side-labels centered row 8.
    def frame getjust
        aas.aaa format "x(20)" label "Номер счета            " skip
        aas.regdt label "Дата регистрации       " skip
        aas.docprim format "x(15)" label "Сумма                  " validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
        aas.fnum format "x(30)" label "Номер ИР Адм.судов, с/о" skip
        aas.docdat label "Дата ИР Адм.судов, с/о " skip
        aas.bnf     format "x(70)" label "Наим. бенефициара      " skip
        aas.rnnben  format "x(12)" label "РНН бенефициара        " skip
        aas.iikben  format "x(20)" label "ИИК бенефициара        " skip
        aas.bicben  format "x(20)" label "БИК банка бенефициара  " skip
        aas.bankben format "x(42)" label "Наим. банка бенефициара" skip
        aas.knp                    label "КНП                    " validate(aas.knp <> "", "Введите КНП ") skip
        aas.kbk                    label "КБК                    " skip
        aas.payee  format "x(50)" label "Примечание             " skip
        with width 100 side-labels centered row 6.
    def frame getjust1
        aas.aaa format "x(20)" label "Номер счета            " skip
        aas.regdt label "Дата регистрации       " skip
        aas.docprim format "x(15)" label "Сумма                  " validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
        aas.fnum format "x(30)" label "Номер ИР Адм.судов, с/о" skip
        aas.docdat label "Дата ИР Адм.судов, с/о " skip
        aas.bnf     format "x(70)" label "Наим. бенефициара      " skip
        aas.rnnben  format "x(12)" label "РНН бенефициара        " skip
        aas.iikben  format "x(20)" label "ИИК бенефициара        " skip
        aas.bicben  format "x(20)" label "БИК банка бенефициара  " skip
        aas.bankben format "x(42)" label "Наим. банка бенефициара" skip
        aas.knp                    label "КНП                    " validate(aas.knp <> "", "Введите КНП ") skip
        aas.payee  format "x(50)" label "Примечание             " skip
        with width 100 side-labels centered row 6.
    def frame getother1
        aas.aaa format "x(20)" label     "Номер счета.           " skip
        aas.regdt label   "Дата регистрации       " skip
        aas.docprim format "x(15)" label  "Сумма                  "  validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
        aas.fnum format "x(30)"  label    "Номер инк. распоряжения" skip
        aas.docdat label  "Дата инк. распоряжения." skip
        aas.bnfname format "x(30)" label  "Бенефициар             "  skip
        aas.rnnben  format "x(12)" label  "РНН  бенефициара       "  skip
        aas.bicben   format "x(20)" label "БИК  бенефициара       "  skip
        aas.bankben  format "x(20)" label "Банк бенефициара       "  skip
        aas.iikben  format "x(20)" label  "ИИК  бенефициара       "  skip
        aas.docnum format "x(2)" label "Вид операции           " validate(lookup(aas.docnum, "07,09") > 0 , "Не верно указан вид операции! Вид операции должен быть 07 или 09") skip
        aas.knp label                     "КНП                    " validate(aas.knp <> "", "Введите КНП ")
        aas.payee label   "Примечание             "   skip
        with side-labels centered row 6.
    def frame getother2
        aas.aaa format "x(20)" label     "Номер счета.           " skip
        aas.regdt label   "Дата регистрации       " skip
        aas.docprim format "x(15)" label  "Сумма                  "  validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
        aas.fnum format "x(30)"  label    "Номер инк. распоряжения" skip
        aas.docdat label  "Дата инк. распоряжения." skip
        aas.bnfname format "x(30)" label  "Бенефициар             "  skip
        aas.rnnben  format "x(12)" label  "РНН  бенефициара       "  skip
        aas.bicben   format "x(20)" label "БИК  бенефициара       "  skip
        aas.bankben  format "x(20)" label "Банк бенефициара       "  skip
        aas.iikben  format "x(20)" label  "ИИК  бенефициара       "  skip
        aas.knp label                     "КНП                    " validate(aas.knp <> "", "Введите КНП ")
        aas.payee label   "Примечание             "   skip
        with side-labels centered row 6.

    def frame get_hist1
        t-aashist1.aaa format "x(20)" label     "Номер счета.           " skip
        t-aashist1.regdt label   "Дата регистрации       " skip
        t-aashist1.docprim format "x(15)" label  "Сумма                  "  validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
        t-aashist1.fnum format "x(30)"  label    "Номер инк. распоряжения" skip
        t-aashist1.docdat label  "Дата инк. распоряжения." skip
        t-aashist1.bnfname format "x(30)" label  "Бенефициар             "  skip
        t-aashist1.rnnben  format "x(12)" label  "РНН  бенефициара       "  skip
        t-aashist1.bicben   format "x(20)" label "БИК  бенефициара       "  skip
        t-aashist1.bankben  format "x(20)" label "Банк бенефициара       "  skip
        t-aashist1.iikben  format "x(20)" label  "ИИК  бенефициара       "  skip
        t-aashist1.knp label                     "КНП                    " validate(aas.knp <> "", "Введите КНП ")
        t-aashist1.payee label   "Примечание             "   skip
        with side-labels centered row 6.
    def frame getlist1
        aas.aaa format "x(20)" label "Номер счета.           " skip
        aas.regdt label "Дата регистрации       " skip
        aas.docprim format "x(20)" label "Сумма                  " validate(decimal(aas.docprim) <> 0, "Введите сумму оплаты ") skip
        aas.fnum  format "x(21)"  label "Номер инк. распоряжения" skip
        aas.docdat                label "Дата инк. распоряжения." skip
        aas.bnf    format "x(50)" label "Налог управл.(F2-поиск)" validate(aas.bnf <> "", "Введите название налогового управления (F2-поиск)") skip
        aas.dpname format "x(12)" label "РНН налог. управления  " validate(aas.dpname <> "", "Введите РНН налогового управления ") skip
        aas.docnum format "x(2)"  label "Вид операции           " skip
        aas.payee  format "x(50)" label "Примечание             " skip
        aas.kbk label     "КБК" validate(aas.kbk <> "", "Введите КБК ")
        aas.knp label     "      КНП" validate(aas.knp <> "", "Введите КНП ") skip
        aas.rgref  format "x(16)" label "Групповой референс     " validate(aas.rgref <> "", "Введите Групповой референс ")
        with side-labels centered row 6.
    def frame getlist2
        aas.docnum1 label  "Номер документа" help "Номер документа на основании которого снимается ограничение" skip
        aas.docdat1 label  "Дата документа " help "Дата документа на основании которого снимается ограничение" skip
        aas.docprim1 label "Примечание     "  skip
        with side-labels centered row 8.
    def frame listacsept
        aas.docprim1 label "Примечание " validate(aas.docprim1 <> "", "Необходимо заполнить поле 'Примечание' ")  skip
        with side-labels centered row 9.
    def frame getlist33
        t-aashist1.fnum        label                         "Номер инкассового распоряжения" skip
        t-aashist1.docdat      label                         "Дата  инкассового распоряжения" skip
        t-aashist1.who         label                         "Менеджер зарегистрировавший ИР"
        t-aashist1.bnf   format "x(35)"      label           "Налоговое управление          " skip
        t-aashist1.dpname format "x(16)"     label           "РНН налогового управления     " skip
        t-aashist1.kbk         label                         "КБК                           " skip
        t-aashist1.knp         label                         "КНП                           " skip
        t-aashist1.payee       label                         "Примечание                    " skip
        "ЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂ" skip
        t-aashist1.dtbefore    label                         "Дата приостановления ИР       " skip
        t-aashist1.docnum1     label                         "N док-та приостановления ИР   " skip
        t-aashist1.docdat1     label                         "Дата док-та приостановления ИР" skip
        t-aashist1.docprim1  format "x(35)"  label           "Примечание                    "  skip
        with side-labels centered row 5.
    def frame getlist34
        t-aashist1.fnum        label                         "Номер инкассового распоряжения" skip
        t-aashist1.docdat      label                         "Дата  инкассового распоряжения" skip
        t-aashist1.who         label                         "Менеджер зарегистрировавший ИР"
        t-aashist1.bnf   format "x(35)"      label           "Налоговое управление          " skip
        t-aashist1.dpname format "x(16)"     label           "РНН налогового управления     " skip
        t-aashist1.kbk         label                         "КБК                           " skip
        t-aashist1.knp         label                         "КНП                           " skip
        t-aashist1.payee       label                         "Примечание                    " skip
        "ЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂЂ" skip
        t-aashist1.dtbefore    label                         "Дата отзыва ИР                " skip
        t-aashist1.docnum1     label                         "N док-та для отзыва ИР        " skip
        t-aashist1.docdat1     label                         "Дата док-та для отзыва ИР     " skip
        t-aashist1.docprim1  format "x(35)"  label           "Примечание                    "  skip
        with side-labels centered row 5.
    def frame aacc
        ch_acc label "Счет" format "x(20)" validate(ch_acc <> "", "Введите номер счета ")
        with side-labels centered row 8.
    def frame a2
        bt_AddNew bt_Find with side-labels row 3 no-box.
    def frame f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
    def frame fr1 b1 skip bprint bdetail brem bhistory b-rmz bexit  with centered overlay row 3 width 97  top-only.
    def frame fr4 b4 skip bdethis bexit  with centered overlay row 3 width 100 top-only.
    def frame fr5 b5 skip bdtlst bexit with centered overlay row 3 top-only.
    def frame t_frame1
        s_FindAcc label "Поиск по номеру счета" format "x(21)"
        with side-labels centered row 7.
    def frame t_frame2
        s_FindCIF label "Поиск по CIF коду клиента" format "x(7)"
        with side-labels centered row 7.
    def frame t_frame3
        s_FindName label "Наименование клиента" format "x(20)"
        with side-labels centered row 7.
    def frame t_frame9
        s_FindCIF label "Поиск по номеру ИР" format "x(7)"
        with side-labels centered row 7.
/* <-блок объявления переменных*/

/* функции и процедуры ->*/
    function exchange returns decimal (input sum as decimal, input rate as decimal).
        if (sum / rate) > truncate(sum / rate, 2) then
            RETURN(truncate(sum / rate, 2) + 0.01).
        else RETURN(truncate(sum / rate, 2)).
    end function.
    /* Функция возвращает FALSE если пользователь имеет право на удаление и редактирование */
    FUNCTION plcarddel return logical (s as logical).
        if aas.payee begins 'Кр лимит по п/к' then do:
            find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
            if avail pl-ofc then do:
                if pl-ofc.titcd = '104' and ofc.regno = 1001 then return false.
                else return true.
            end. else return true.
        end. else return true.
    end FUNCTION.
    PROCEDURE specindo.
        def var pack  as char init ''.
        def var i     as inte init 0.
        def var boole as logi init false.
        def var cha   as char init ''.

        find sysc where sysc.sysc = 'pkcon' no-lock no-error.
        if avail sysc then do:
            /* 11.11.2004 saltanat - Проставление признака Платежных карт с учетом прав доступа !!! на пакеты !!! */
            boole = false.
            find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
            if avail pl-ofc then do:
                if pl-ofc.expr[1] <> '' then do:
                    do i = 1 to num-entries(pl-ofc.expr[1]):
                        cha = entry(i,pl-ofc.expr[1]).
                        if lookup(cha,sysc.chval) > 0 then do:
                            boole = true.
                            leave.
                        end.
                    end.
                end.
            end.
            if lookup(g-ofc,sysc.chval) > 0 or boole then do:
                find current aas exclusive-lock.
                if aas.delaas = '' then do:
                    aas.delaas = 'd'.
                    v-specin   = '*'.
                    aas.specin = '*'.
                end. else do:
                    if aas.delaas = 'd' then do:
                        aas.delaas = ''.
                        v-specin   = ''.
                        aas.specin = ''.
                    end. else message 'Стоит признак удаления Департамента Кредитного Администрирования!' view-as alert-box warning buttons ok.
                end.
            end.
            else message 'У Вас нет прав работы с признаком удаления спец.инструкции Платежных карт! ' view-as alert-box warning buttons ok.
        end.
        else message 'Нет возможности работы с признаком удаления спец.инструкции Платежных карт! 'view-as alert-box warning buttons ok.
        find current aas no-lock.
    end PROCEDURE.
    PROCEDURE speckrdo.
        def var pack  as char init ''.
        def var i     as inte init 0.
        def var boole as logi init false.
        def var cha   as char init ''.

        find sysc where sysc.sysc = 'dkpriz' no-lock no-error.
        if avail sysc then do:
            boole = false.
            find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
            if avail pl-ofc then do:
                if pl-ofc.expr[1] <> '' then do:
                    do i = 1 to num-entries(pl-ofc.expr[1]):
                        cha = entry(i,pl-ofc.expr[1]).
                        if lookup(cha,sysc.chval) > 0 then do:
                            boole = true.
                            leave.
                        end.
                    end.
                end.
            end.
            if lookup(g-ofc,sysc.chval) > 0 or boole then do:
                find current aas exclusive-lock.
                if aas.delaas = '' then do:
                    aas.delaas = 'k'.
                    v-speckr   = '*'.
                    aas.speckr = '*'.
                end. else do:
                    if aas.delaas = 'k' then do:
                        aas.delaas = ''.
                        v-speckr   = ''.
                        aas.speckr = ''.
                    end.
                    else message 'Стоит признак удаления Департамента Платежных карт!' view-as alert-box warning buttons ok.
                end.
            end.
            else message 'У Вас нет прав работы с признаком удаления спец.инструкции Кредитного Администрирования! ' view-as alert-box warning buttons ok.
        end.
        else message 'Нет возможности работы с признаком удаления спец.инструкции Кредитного Администрирования! 'view-as alert-box warning buttons ok.
        find current aas no-lock.
    end PROCEDURE.
/* <-функции и процедуры*/

v-ourbank = comm-txb().
{aas2his.i &db = "bank"}

output stream m-out to inkpay.txt.

on "return" of v-rem in frame f-rem do:
   apply "go" to v-rem in frame f-rem.
end.

on "end-error" of v-rem in frame f-rem do:
   hide frame f-rem no-pause.
end.

s-vcourbank = comm-txb().

find ofc where ofc.ofc = g-ofc no-lock no-error.

on help of aas.bnf in frame getlist1 do:
   empty temp-table t-ln.
   for each taxnk no-lock use-index rnn1:
       create t-ln.
       assign
           t-ln.rnn  = taxnk.rnn
           t-ln.name = taxnk.name.
   end.
   find first t-ln no-error.
   if not avail t-ln then do:
       message skip " Справочника нет !" skip(1) view-as alert-box button ok title "".
       return.
   end.
   {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay title 'Выберите налоговое управление ' "
       &where = " true "
       &flddisp = " t-ln.rnn label 'РНН' format 'x(12)'
                    t-ln.name label 'Наименование' format 'x(50)'"
       &chkey = "rnn"
       &chtype = "string"
       &index  = "main"
   }
   v-cod = frame-value.
   find first taxnk where taxnk.rnn = v-cod use-index rnn1 no-lock no-error.
   if avail taxnk then assign aas.dpname = taxnk.rnn  aas.bnf = taxnk.name.
   display aas.dpname aas.bnf with frame getlist1.
end.

on help of aas.kbk in frame getlist1 do:
   empty temp-table t-bud.
   for each budcodes no-lock:
       create t-bud.
       assign
           t-bud.cod = budcodes.code.
       t-bud.name = budcodes.name.
   end.
   find first t-bud no-error.
   if not avail t-bud then do:
       message skip " Справочника нет !" skip(1) view-as alert-box button ok title "".
       return.
   end.
   {itemlist.i
       &file = "t-bud"
       &frame = "row 6 centered scroll 1 12 down overlay title 'Выберите код КБК ' "
       &where = " true "
       &flddisp = " t-bud.cod label 'Код' format '999999'
                    t-bud.name label 'Наименование' format 'x(50)'"
       &chkey = "cod"
       &chtype = "integer"
       &index  = "main"
   }
   v-cod = frame-value.
   find first budcodes where budcodes.code = integer(v-cod) no-lock no-error.
   if avail budcodes then assign aas.kbk = string(budcodes.code) aas.payee = budcodes.name.
   display aas.kbk aas.payee with frame getlist1.
end.

on help of aas.dpname in frame getlist1 do:
   str_p = "".
   find first taxnk use-index rnn1 no-lock no-error.
   if avail taxnk then do:
       for each taxnk no-lock use-index rnn1:
           str_p = str_p + string (taxnk.rnn) + "|".
       end.
       str_p = SUBSTR (str_p, 1, LENGTH(str_p) - 1).
       run sel ("Выберите РНН налогового управления", str_p).
       i-ind = 0.
       for each taxnk use-index rnn1 no-lock :
           i-ind = i-ind + 1.
           if i-ind = int(return-value) then do:
               aas.dpname = taxnk.rnn .
               leave.
           end.
       end.
       display aas.dpname with frame getlist1.
   end. else do:
       message "Внимание: Не заполнен справочник налоговых комитов.".
       pause.
   end.
end.

on help of ch_acc in frame aacc  do:
   v-cif1 = "".
   run h-cif PERSISTENT SET phand.
   v-cif1 = frame-value.
   if trim(v-cif1) <> "" then do:
       find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock no-error.
       if available aaa then do:
           OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock,
                each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
           ENABLE ALL WITH FRAME f-help.
           wait-for return of frame f-help
               FOCUS b-help IN FRAME f-help.
           ch_acc = aaa.aaa.
           hide frame f-help.
       end. else do:
           ch_acc = "".
           MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
       end.
       displ  ch_acc with frame aacc.
   end.
   DELETE PROCEDURE phand.
end.

/* Новое */
on choose of bt_AddNew in frame a2 do:
   repeat:
       hide frame getother1.
       hide frame getother2.
       hide frame getlist1.
       run sel2 (" Параметры ", " 1. Обязательные платежи в бюджет | 2. И/Р Администраторов судов, суд.орг. | 3. Прочие | ВЫХОД", output v-dep).
       if (v-dep < 1) or (v-dep > 3) then return.
       repeat:
           update ch_acc with frame aacc.
           hide frame aacc.
           find last aaa where aaa.aaa = ch_acc no-lock no-error.
           if not available aaa then do:
               message "Счет не найден".
               pause 3.
           end. else do:
               if aaa.sta = 'C' then do:
                   message skip "Счет " + aaa.aaa + " закрыт !" skip "Добавление спец. инструкций невозможно !" skip(1) view-as alert-box button Ok title "Внимание!".
                   return.
               end.
               leave.
           end.
       end.
       hide frame aacc.
       if avail aaa then do:
           if v-dep = 1 then do:
               find last cif where cif.cif = aaa.cif no-lock no-error.
               if avail cif then message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".
               message "Внимание: платежи в бюджет формируются к оплате автоматически при закрытии дня".
               pause.
               message "".
               pause 0.
               find last aas where aas.aaa = aaa.aaa and (aas.sta = 4 or aas.sta = 5) no-lock no-error.
               do transaction on error undo, return:
                   for each t-aas:
                       delete t-aas.
                   end.
                   for each buf-aaa where buf-aaa.cif = aaa.cif:
                       for each aas where aas.aaa = buf-aaa.aaa no-lock:
                           create t-aas.
                           assign
                               t-aas.aaa    = aas.aaa
                               t-aas.sta    = aas.sta
                               t-aas.docdat = aas.docdat
                               t-aas.fsum   = aas.fsum
                               t-aas.kbk    = aas.kbk
                               t-aas.knp    = aas.knp.
                       end.
                   end.
                   create aas.
                   find last buf-aashist where buf-aashist.aaa = aaa.aaa and buf-aashist.ln <> 7777777  use-index aaaln no-lock no-error.
                   if available buf-aashist then aas.ln = buf-aashist.ln + 1. else aas.ln = 1.
                   aas.aaa = aaa.aaa.
                   aas.payee = "ИР налог.органов".
                   displ aas.aaa aas.payee with frame getlist1.
                   update  aas.regdt aas.docprim aas.fnum aas.docdat aas.bnf aas.dpname aas.docnum with frame getlist1.
                   update aas.kbk with frame getlist1.
                   find first budcodes where budcodes.code = integer(aas.kbk) no-lock no-error.
                   if avail budcodes then aas.payee = budcodes.name.
                   displ aas.regdt aas.docprim aas.fnum aas.docdat aas.bnf aas.dpname aas.docnum  aas.payee aas.kbk with frame getlist1.
                   update aas.payee aas.knp with frame getlist1.
                   aas.chkamt = 100000000000.00 . /* блокируем счет */
                   aas.sta   = 4.
                   aas.mn = "41000".
                   aas.who   = g-ofc.
                   aas.fsum  = decimal(aas.docprim). /* aas.chkamt */
                   aas.irsts = "не оплачено".
                   aas.activ = True.
                   aas.contr = False.
                   aas.tim   = time.
                   aas.whn   = g-today.
                   aas.who   = g-ofc.
                   aas.sic   = 'HB'.
                   s-aaa     = aaa.aaa.
                   if aas.fsum >= 100000000000 then do:
                       message "Неверная сумма оплаты!".
                       undo, return.
                   end.

                    find first aaa where aaa.aaa = s-aaa exclusive-lock.
                    run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                    aaa.hbal = aaa.hbal + aas.chkamt.

                   find last cif where cif.cif = aaa.cif no-lock no-error.
                   if avail cif then aas.cif = cif.cif.
                   hide frame getlist1.
                   v-usrglacc = "".
                   if s-vcourbank = "txb00" then do:
                       find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
                       if avail vnebal then v-usrglacc = vnebal.gl.
                       else do:
                           v-ofc1 = string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
                           find last vnebal where vnebal.usr = v-ofc1 no-lock no-error.
                           if avail vnebal then v-usrglacc = vnebal.gl.
                       end.
                   end. else do:
                       find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                       if avail vnebal then v-usrglacc = vnebal.gl.
                   end.
                   /* Блокируем сумму и производим транзакцию на внебаланс */
                   if aas.chkamt <> 0 and v-usrglacc <> "" then do:
                       b = no.
                       message "Внимание. Сумма будет зачислена на счет внебаланса" v-usrglacc vnebal.k2 view-as alert-box question buttons yes-no update b.
                       if not b then do:
                           undo, return.
                       end.
                       v-jh = 0.
                       vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + /* "учет суммы И.Р. " + */ aaa.aaa + vdel + aaa.aaa + vdel.
                       run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                       if rcode ne 0 then do:
                           message rdes view-as alert-box title "".
                           return.
                       end. else do:
                           message "Произведена транзакция #" v-jh " по  учету суммы ИР на внебаланс ".
                           pause.
                       end.
                   end. else do:
                       if aas.chkamt = 0 then do:
                           message "Невозможно зачислить сумму 0.0 на внебаланс" .
                           pause.
                           undo, return.
                       end.
                       if v-usrglacc = "" then do:
                           message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                           pause.
                           undo, return.
                       end.
                   end.
                   find first buf-ofc1 where buf-ofc1.ofc = g-ofc no-lock.
                   aas.point = buf-ofc1.regno / 1000 - 0.5.
                   aas.depart = buf-ofc1.regno MODULO 1000.
                   op_kod = 'A'.
                   RUN aas2his.
                   hide frame getlist1.
               end. /* transaction */
           end.
           /* ИР Администраторов судов, судебные органы */
           if v-dep = 2 then do:
               /*v-mn = "42000".*/
               run sel2 (" ИР адм. судов и суд. орг.", "1.ИР по оплате треб.о возмещ.вреда жизни и здоровью и треб.по взыск.алиментов |2.ИР по опл.треб.по опл.выход.пособий и опл/труда с лицами, вознагр.по авторскому договору  |3.ИР по испол.док.о взыскании в доход гос-ва |4.ИР по прочим испол.документам", output v-dp3).
               case v-dp3:
                   when 1 then v-mn = "42100".
                   when 2 then v-mn = "42200" .
                   when 3 then v-mn = "42300" .
                   when 4 then v-mn = "42400" .
                   otherwise return.
               end.

               find last cif where cif.cif = aaa.cif no-lock no-error.
               if avail cif then message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".
               message "Внимание: платежи по И/Р Адм. судов, судебных органов, формируются к оплате автоматически при закрытии дня".
               pause.
               message "".
               pause 0.
               find last aas where aas.aaa = aaa.aaa and (aas.sta = 4 or aas.sta = 5) no-lock no-error.
               do transaction on error undo, return:
                   create aas.
                   find last buf-aashist where buf-aashist.aaa = aaa.aaa and buf-aashist.ln <> 7777777 use-index aaaln no-lock no-error.
                   if available buf-aashist then aas.ln = buf-aashist.ln + 1. else aas.ln = 1.
                   aas.aaa = aaa.aaa.
                   aas.payee = "ИР судов,суд.орг".
                   aas.regdt = g-today.
                   if v-mn begins "423" then displ aas.aaa aas.payee with frame getjust. else displ aas.aaa aas.payee with frame getjust1.
                   if v-mn begins "423" then update aas.regdt aas.docprim aas.fnum aas.docdat aas.bnf aas.rnnben aas.iikben aas.bicben with frame getjust.
                   else update aas.regdt aas.docprim aas.fnum aas.docdat aas.bnf aas.rnnben aas.iikben aas.bicben with frame getjust1.
                   find first bankl where bankl.bank = aas.bicben no-lock no-error.
                   if avail bankl then do:
                       aas.bankben = bankl.name.
                       if v-mn begins "423" then displ aas.bankben with frame getjust. else displ aas.bankben with frame getjust1.
                   end.
                   if v-mn begins "423" then update aas.bankben aas.knp aas.kbk with frame getjust. else update aas.bankben aas.knp  with frame getjust1.
                   find first budcodes where budcodes.code = integer(aas.kbk) no-lock no-error.
                   if avail budcodes then aas.payee = budcodes.name.
                   if v-mn begins "423" then update aas.payee with frame getjust. else update aas.payee with frame getjust1.

                   aas.chkamt = 100000000000.00 . /* блокируем счет */
                   aas.sta   = 4.
                   aas.mn = v-mn.
                   aas.dpname = "адм. судов".
                   aas.who   = g-ofc.
                   aas.fsum  = decimal(aas.docprim). /* aas.chkamt */
                   aas.irsts = "не оплачено".
                   aas.activ = True.
                   aas.contr = False.
                   aas.tim   = time.
                   aas.whn   = g-today.
                   aas.who   = g-ofc.
                   aas.sic   = 'HB'.
                   s-aaa     = aaa.aaa.
                   if aas.fsum >= 100000000000 then do:
                       message "Неверная сумма оплаты!".
                       undo, return.
                   end.

                   find first aaa where aaa.aaa = s-aaa exclusive-lock.
                   run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                   aaa.hbal = aaa.hbal + aas.chkamt.

                   find last cif where cif.cif = aaa.cif no-lock no-error.
                   if avail cif then aas.cif = cif.cif.
                   if v-mn begins "423" then hide frame getjust. else hide frame getjust1.
                   v-usrglacc = "".
                   if s-vcourbank = "txb00" then do:
                       find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
                       if avail vnebal then v-usrglacc = vnebal.gl.
                       else do:
                           v-ofc1 = string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
                           find last vnebal where vnebal.usr = v-ofc1 no-lock no-error.
                           if avail vnebal then v-usrglacc = vnebal.gl.
                       end.
                   end. else do:
                       find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                       if avail vnebal then v-usrglacc = vnebal.gl.
                   end.
                   /* Блокируем сумму и производим транзакцию на внебаланс */
                   if aas.chkamt <> 0 and v-usrglacc <> "" then do:
                       b = no.
                       message "Внимание. Сумма будет зачислена на счет внебаланса" v-usrglacc vnebal.k2 view-as alert-box question buttons yes-no update b.
                       if not b then do:
                           undo, return.
                       end.
                       v-jh = 0.
                       vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + /* "учет суммы И.Р. " + */ aaa.aaa + vdel + aaa.aaa + vdel.
                       run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                       if rcode ne 0 then do:
                           message rdes view-as alert-box title "".
                           return.
                       end. else do:
                           message "Произведена транзакция #" v-jh " по  учету суммы ИР на внебаланс ".
                           pause.
                       end.
                   end. else do:
                       if aas.chkamt = 0 then do:
                           message "Невозможно зачислить сумму 0.0 на внебаланс" .
                           pause.
                           undo, return.
                       end.
                       if v-usrglacc = "" then do:
                           message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                           pause.
                           undo, return.
                       end.
                   end.
                   find first buf-ofc1 where buf-ofc1.ofc = g-ofc no-lock.
                   aas.point = buf-ofc1.regno / 1000 - 0.5.
                   aas.depart = buf-ofc1.regno MODULO 1000.
                   op_kod = 'A'.
                   RUN aas2his.
                   if v-mn begins "423" then hide frame getjust. else hide frame getjust1.
               end. /* transaction */
           end.
           if v-dep = 3 then do:
               run sel2 (" Прочие", " 1. Пенс и соц. отчисления | 2. Платежное требование-поручение  ", output v-dp3).
               if v-dp3 = 0  then return.
               if v-dp3 = 1 then do:
                  find last cif where cif.cif = aaa.cif no-lock no-error.
                  if avail cif then message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".
                  message "Внимание: Прочие инкассовые расп. оплачиваются в обычных пунктах меню".
                  pause 3.
                  message "".
                  pause 0.
                  do transaction on error undo, return :
                     create aas.
                     find last buf-aashist where buf-aashist.aaa = aaa.aaa and buf-aashist.ln <> 7777777 use-index aaaln no-lock no-error.
                     if available buf-aashist then aas.ln = buf-aashist.ln + 1. else aas.ln = 1.
                     aas.aaa = aaa.aaa.
                     aas.payee = "ИР по пенс и соц отч.".
                     displ aas.aaa aas.payee with frame getother1.
                     update aas.regdt aas.docprim aas.fnum aas.docdat aas.bnfname aas.rnnben aas.bicben aas.bankben aas.docnum aas.iikben aas.knp aas.payee with frame getother1.
                     if lookup(aas.docnum, "07,09") = 0 then  do:
                        message "Не верно указан вид операции! Вид операции должен быть 07 или 09" view-as alert-box.
                        undo,  return.
                     end.
                     find last bankl where bankl.bic = aas.bicben no-lock no-error.
                     if avail bankl and aas.bicben <> "" then aas.bankben = bankl.name.
                     aas.chkamt = 100000000000.00.
                     aas.sta = 9.
                     if aas.docnum = "07" then aas.mn = "43300". else if aas.docnum = "09" then aas.mn = "43400". else aas.mn = "43100".
                     aas.who = g-ofc.
                     aas.fsum  =  decimal(aas.docprim).
                     aas.irsts = "не оплачено".
                     aas.activ = True.
                     aas.contr = False.
                     aas.tim = time.
                     aas.whn = g-today.
                     aas.who = g-ofc.
                     aas.sic = 'HB'.
                     s-aaa = aaa.aaa.

                     find first aaa where aaa.aaa = s-aaa exclusive-lock.
                     run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                     aaa.hbal = aaa.hbal + aas.chkamt.

                     find last cif where cif.cif = aaa.cif no-lock no-error.
                     if avail cif then aas.cif = cif.cif.
                     if s-vcourbank = "txb00" then do:
                        find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
                        if avail vnebal then v-usrglacc = vnebal.gl.
                        else do:
                           v-ofc1 =  string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
                           find last vnebal where vnebal.usr = v-ofc1 no-lock no-error.
                           if avail vnebal then v-usrglacc = vnebal.gl.
                        end.
                     end. else do:
                        find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                        if avail vnebal then v-usrglacc = vnebal.gl.
                     end.
                     if s-vcourbank = "" then  do:
                        message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") " .
                        pause.
                        undo,  return.
                     end.
                     /* Блокируем сумму и производим транзакцию на внебаланс */
                     if aas.chkamt <> 0 and v-usrglacc <> "" then do:
                        message "Внимание. Сумма будет зачислена на счет внебаланса" v-usrglacc vnebal.k2  view-as alert-box question buttons yes-no update b.
                        if not b then do:
                            undo, return.
                        end.
                        v-jh = 0.
                        vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + aaa.aaa + vdel + aaa.aaa + vdel.
                        run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                        if rcode ne 0 then do:
                            message rdes view-as alert-box title "".
                            undo, return.
                        end. else do:
                            message "Произведена транзакция #" v-jh " по  учету суммы ИР на внебаланс ".
                            pause.
                        end.
                     end. else do:
                        if aas.chkamt = 0 then do:
                            message "Невозможно зачислить сумму 0.0 на внебаланс".
                            pause.
                            undo,  return.
                        end.
                        if v-usrglacc = "" then do:
                            message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                            pause.
                            undo,  return.
                        end.
                     end.
                     FIND FIRST buf-ofc1 WHERE buf-ofc1.ofc = g-ofc NO-LOCK.
                     aas.point = buf-ofc1.regno / 1000 - 0.5.
                     aas.depart = buf-ofc1.regno MODULO 1000.
                     op_kod = 'A'.
                     RUN aas2his.
                  end. /*transaction*/
               end.
               if v-dp3 = 2 then do:
                   find last cif where cif.cif = aaa.cif no-lock no-error.
                   if avail cif then message "Наименование клиента:" cif.name  skip "РНН клиента:" cif.jss view-as alert-box question buttons ok title "Визуальный контроль".

                   message "Внимание: Прочие инкассовые расп. оплачиваются в обычных пунктах меню".
                   pause 3.
                   message "".
                   pause 0.

                   do transaction on error undo, return :
                       create aas.
                       find last buf-aashist where buf-aashist.aaa = aaa.aaa and buf-aashist.ln <> 7777777 use-index aaaln no-lock no-error.
                       if available buf-aashist then aas.ln = buf-aashist.ln + 1.
                       else aas.ln = 1.
                       aas.aaa = aaa.aaa.
                       aas.payee = "ПТП".
                       displ aas.aaa aas.payee with frame getother2.
                       update aas.regdt aas.docprim aas.fnum aas.docdat aas.bnfname aas.rnnben aas.bicben aas.bankben aas.iikben aas.knp aas.payee with frame getother2.
                       find last bankl where bankl.bic = aas.bicben no-lock no-error.
                       if avail bankl and aas.bicben <> "" then aas.bankben = bankl.name.
                       aas.chkamt = 100000000000.00.
                       aas.sta = 9.
                       aas.mn = "43200".
                       aas.who = g-ofc.
                       aas.fsum  =  decimal(aas.docprim).
                       aas.irsts = "не оплачено".
                       aas.activ = True.
                       aas.contr = False.
                       aas.tim = time.
                       aas.whn = g-today.
                       aas.who = g-ofc.
                       aas.sic = 'HB'.
                       s-aaa = aaa.aaa.

                       find first aaa where aaa.aaa = s-aaa exclusive-lock.
                       run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + aas.chkamt) + " ; " + string(aas.chkamt)).
                       aaa.hbal = aaa.hbal + aas.chkamt.

                       find last cif where cif.cif = aaa.cif no-lock no-error.
                       if avail cif then aas.cif = cif.cif.
                       if s-vcourbank = "txb00" then do:
                           find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
                           if avail vnebal then v-usrglacc = vnebal.gl.
                           else do:
                               v-ofc1 =  string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
                               find last vnebal where vnebal.usr = v-ofc1 no-lock no-error.
                               if avail vnebal then v-usrglacc = vnebal.gl.
                           end.
                       end. else do:
                           find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                           if avail vnebal then v-usrglacc = vnebal.gl.
                       end.
                       if s-vcourbank = "" then do:
                           message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") " .
                           pause.
                           undo,  return.
                       end.
                       /* Блокируем сумму и производим транзакцию на внебаланс */
                       if aas.chkamt <> 0 and v-usrglacc <> "" then do:
                           message "Внимание. Сумма будет зачислена на счет внебаланса" v-usrglacc vnebal.k2  view-as alert-box question buttons yes-no update b.
                           if not b then do:
                               undo, return.
                           end.
                           v-jh = 0.
                           vparam2 = aas.docprim + vdel + string(1) + vdel + v-usrglacc + vdel + "830300" + vdel + /*"учет суммы И.Р. " +*/ aaa.aaa + vdel + aaa.aaa + vdel.
                           run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                           if rcode ne 0 then do:
                               message rdes view-as alert-box title "".
                               undo, return.
                           end. else do:
                               message "Произведена транзакция #" v-jh " по  учету суммы ИР на внебаланс ".
                               pause.
                           end.
                       end. else do:
                           if aas.chkamt = 0 then  do:
                               message "Невозможно зачислить сумму 0.0 на внебаланс".
                               pause.
                               undo,  return.
                           end.
                           if v-usrglacc = "" then do:
                               message "Не удалось найти счет Г/К для зачисления на внебаланс! (обсл менеджер-"substr(cif.fname,1,8) ") ".
                               pause.
                               undo,  return.
                           end.
                       end.
                       FIND FIRST buf-ofc1 WHERE buf-ofc1.ofc = g-ofc NO-LOCK.
                       aas.point = buf-ofc1.regno / 1000 - 0.5.
                       aas.depart = buf-ofc1.regno MODULO 1000.
                       op_kod = 'A'.
                       RUN aas2his.
                   end. /*transaction*/
               end.
           end.

           v-countaas = 0.
           for each b-aas where b-aas.aaa = aaa.aaa and lookup(string(b-aas.sta), "0,1,3") <> 0 no-lock:
               v-countaas = v-countaas + 1.
           end.
           v-olds1 = 0.
           /*контроль денежных средств*/
           d_arsum1 = 0.
           for each buf-aaar where buf-aaar.a5 = aas.aaa and buf-aaar.a4 <> "1" no-lock:
               d_arsum1 = d_arsum1 + decimal(buf-aaar.a3).
           end.
           /*зависла частичная оплата с данного счета*/
           d_arsummy1 = 0.
           for each buf-aaar where buf-aaar.a5 = aas.aaa and buf-aaar.a4 <> "1" and buf-aaar.a2 = aas.fnum no-lock:
               d_arsummy1 = d_arsummy1 + decimal(buf-aaar.a3).
           end.
           if (v-dep = 1 or v-dep = 2 or v-dep = 3) and avail cif and (aaa.cr[1] - aaa.dr[1] > 0)then do:
               v-mailmessage = " ИР/ПТП=" + string(aas.fnum) +
                   " РНН=" + cif.jss +
                   " счет=" + aas.aaa +
                   " sum=" + string(aas.docprim) +
                   " КНП=" + string(aas.knp) +
                   " КБК=" + string(aas.kbk).
               find first cmp no-lock no-error.
               v-city = "".
               if avail cmp then do:
                   if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                   else if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               end.
               v-mailmessage = v-city + "\n\n" + v-mailmessage.
               find first pksysc where pksysc.sysc = "inksm" no-lock no-error.
               if avail pksysc and trim(pksysc.chval) <> '' then do:
                   do k = 1 to num-entries(pksysc.chval,';'):
                       v-sp = entry(k,pksysc.chval,';').
                       do i = 1 to num-entries(v-sp):
                           if trim(entry(i,v-sp)) <> '' then do:
                               if v-maillist[k] <> '' then v-maillist[k] = v-maillist[k] + ','.
                               v-maillist[k] = v-maillist[k] + trim(entry(i,v-sp)) + "@metrocombank.kz".
                           end.
                       end.
                   end.
               end.
               do l = 1 to k - 1.
                   if v-maillist[k] <> '' then
                   run mail(v-maillist[k], "METROCOMBANK <abpk@metrocombank.kz>", "Прием инкассовых распоряжений/платежных требований-поручений на счета клиентов с остатком более 0",
                       v-mailmessage, "1", "", "").
               end.
           end.

           if ((v-countaas <> 0) or ((aaa.cr[1] - aaa.dr[1]) - v-olds1 - decimal(d_arsum1) - decimal(d_arsummy1) < aas.fsum)) and
               (v-dep = 1 or v-dep = 2 or v-dep = 3) then do:
               v-ofile = "ofile.htm" .
               v-ifile = "/data/export/tz1030_1.htm".
               output stream v-out to value(v-ofile).
               input from value(v-ifile).
               repeat:
                   import unformatted v-str.
                   v-str = trim(v-str).
                   repeat:
                       if v-str matches "*aaa*" then do:
                           v-str = replace (v-str, "aaa", aas.aaa ).
                           next.
                       end.
                       if v-str matches "*clnname*" then do:
                           v-str = replace (v-str, "clnname", cif.prefix + " " + cif.name ).
                           next.
                       end.
                       if v-str matches "*jss*" then do:
                           v-str = replace (v-str, "jss", cif.jss ).
                           next.
                       end.
                       find first cmp no-lock no-error.
                       if v-str matches "*rcity*" then do:
                           v-str = replace (v-str, "rcity", v-banklocat ).
                           next.
                       end.
                       if v-str matches "*fnum*" then do:
                           v-str = replace (v-str, "fnum", aas.fnum ).
                           next.
                       end.
                       if v-str matches "*docdat*" then do:
                           v-str = replace (v-str, "docdat", string(date(aas.docdat),"99.99.9999") + " г." ).
                           next.
                       end.
                       find first ofc where ofc.ofc = g-ofc no-lock no-error.
                       if avail ofc then do:
                           if v-str matches "*ofcname*" then do:
                               v-str = replace (v-str, "ofcname", ofc.name).
                               next.
                           end.
                       end. else do:
                           if v-str matches "ofcname" then do:
                               v-str = replace (v-str, "ofcname", "&nbsp;&nbsp;" ).
                               next.
                           end.
                       end.
                       find first codfr where codfr.codfr = "DKKOGO" and codfr.code = "1" no-lock no-error.
                       if avail codfr then do:
                           if v-str matches "*rfilchifr*" then do:
                               v-str = replace (v-str, "rfilchifr", ENTRY(2,codfr.name[1],",")).
                               next.
                           end.
                       end. else do:
                           if v-str matches "*rfilchifr*" then do:
                               v-str = replace (v-str, "rfilchifr", "&nbsp;&nbsp;" ).
                               next.
                           end.
                       end.
                       find first codfr where codfr.codfr = "DKPODP" and codfr.code = "1" no-lock no-error.
                       if avail codfr then do:
                           if v-str matches "*rfiochif*" then do:
                               v-str = replace (v-str, "rfiochif",codfr.name[1]).
                               next.
                           end.
                       end. else do:
                           if v-str matches "*rfiochif*" then do:
                               v-str = replace (v-str, "rfiochif", "&nbsp;&nbsp;" ).
                               next.
                           end.
                       end.
                       find first codfr where codfr.codfr = "DKOSN" and codfr.code = "1" no-lock no-error.
                       if avail codfr then do:
                           if v-str matches "*rdover*" then do:
                               v-str = replace (v-str, "rdover",  codfr.name[1] ).
                               next.
                           end.
                       end. else do:
                           if v-str matches "*rdover*" then do:
                               v-str = replace (v-str, "rdover", "&nbsp;&nbsp;" ).
                               next.
                           end.
                       end.
                       if v-str matches "*banknameDgv*" then do:
                          v-str = replace (v-str, "banknameDgv", v-nbankDgv ).
                          next.
                       end.
                       if v-str matches "*banknamefil*" then do:
                          v-str = replace (v-str, "banknamefil", v-nbankfil ).
                          next.
                       end.
                       leave.
                   end.
                   put stream v-out unformatted v-str skip.
               end.
               input close.
               output stream v-out close.
               unix silent cptunkoi value(v-ofile) winword.
           end.
       end. /* if avail aaa then do: */
   end. /* repeat */
end. /* on choose of bt_AddNew in frame a2 */


/*Поиск*/
on choose of bt_Find in frame a2 do:
   on "GO" of b1 IN FRAME fr1 do:
      RUN specindo.
      browse b1:refresh().
   end.
   on "GET" of b1 IN FRAME fr1 do:
      RUN speckrdo.
      browse b1:refresh().
   end.
   on choose of b-rmz in frame fr1 do:
      v-olds   = 0.            v-oldskz = 0.         v-inknum = aas.fnum.   v-inkaaa = aas.aaa.
      v-iikben = aas.iikben.   v-knp    = aas.knp.   v-fnum   = aas.fnum.   v-ln     = aas.ln.

      find first aaa where aaa.aaa eq aas.aaa no-lock no-error.
      if not avail aaa then return.
      find first cif where cif.cif eq aaa.cif no-lock no-error.
      if not avail cif then return.
      if aaa.crc <> 1 then do:
          find last arp where arp.gl = 287045 and arp.des = "Оплата инкассовых распоряжений" no-lock no-error.
          if avail arp then v-arp = arp.arp.
          else do:
              message "Не найден ARP счет для оплаты инкассовых!" view-as alert-box.
              leave.
          end.
          find last crchis where crchis.rdt <= g-today and crchis.crc = aaa.crc no-lock no-error.
          if not avail crchis then do:
              message "Курс валюты не найден!" view-as alert-box.
              leave.
          end. else currrate = crchis.rate[1].
      end.
      for each aas where aas.aaa = v-inkaaa and lookup(string(aas.sta), "0,3") <> 0 and aas.mn <> "30037" no-lock:
          v-oldskz = v-oldskz + aas.chkamt.
          if aaa.crc = 1 then
              v-olds = v-olds + aas.chkamt.
          else do:
              v-olds = v-olds + exchange(aas.chkamt, currrate).
          end.
      end.
      find first aas where aas.aaa eq v-inkaaa and aas.ln = v-ln and aas.fnum eq v-inknum no-lock no-error.
      v-sumh = 0.
      for each b-aas where b-aas.aaa = v-inkaaa and b-aas.sta = 0 no-lock:
          v-sumh = v-sumh + b-aas.chkamt.
      end.
      if v-sumh > 0 then do:
         message "Оплата не возможна, на счете имеются спец.инструкции зарегистрированные в 1.3.1.7" view-as alert-box.
         leave.
      end.
      /* ТЗ-1524
      if aas.mn matches "424.." then do:
          v-sumh = 0.
          for each b-aas where b-aas.aaa = v-inkaaa and lookup(string(b-aas.sta), "11,2,16,17") <> 0 no-lock:
              v-sumh = v-sumh + b-aas.chkamt.
          end.
          if v-sumh > 0 then do:
             message "Оплата не возможна на счете имеются РПРО" view-as alert-box.
             leave.
          end.
          v-sumh = 0.
          for each b-aas where b-aas.aaa = v-inkaaa and b-aas.sta = 3 no-lock:
              v-sumh = v-sumh + b-aas.chkamt.
          end.
          if v-sumh > 0 then do:
             message "Оплата не возможна на счете имеются спец.инструкции зарегистрированные в 1.3.1.3" view-as alert-box.
             leave.
          end.
      end.*/

      /*контроль денежных средств*/
      d_arsum = 0.
      d_arsumkz = 0.
      for each aaar where aaar.a5 = aas.aaa and aaar.a4 <> "1" no-lock:
          d_arsumkz = d_arsumkz + decimal(aaar.a3).
          if aaa.crc = 1 then
              d_arsum = d_arsum + decimal(aaar.a3).
          else do:
              find last crchis where crchis.rdt <= date(aaar.a6) and crchis.crc = aaa.crc no-lock no-error.
              if not avail crchis then do:
                  message "Курс валюты не найден!" view-as alert-box.
                  leave.
              end.
              d_arsum = d_arsum + exchange(decimal(aaar.a3), crchis.rate[1]).
          end.
      end.
      /*зависла частичная оплата с данного счета*/
      d_arsummy = 0.
      for each aaar where aaar.a5 = aas.aaa and aaar.a4 <> "1" and aaar.a2 = aas.fnum no-lock:
          d_arsummykz = d_arsummykz + decimal(aaar.a3).
          if aaa.crc = 1 then
              d_arsummy = d_arsummy + decimal(aaar.a3).
          else do:
              find last crchis where crchis.rdt <= date(aaar.a6) and crchis.crc = aaa.crc no-lock no-error.
              if not avail crchis then do:
                  message "Курс валюты не найден!" view-as alert-box.
                  leave.
              end.
              d_arsummy = d_arsummy + exchange(decimal(aaar.a3), crchis.rate[1]).
          end.
      end.
      if aas.sta = 4 or aas.sta = 5  then do:
          if aaa.crc = 1 then aasfsum = aas.fsum.
          else aasfsum = exchange(aas.fsum, currrate).
          if (aaa.cr[1] - aaa.dr[1]) - (v-olds + decimal(d_arsum) + decimal(d_arsummy)) < aasfsum then do:
              if aaa.crc = 1 then
                  v-rmzsum = (aaa.cr[1] - aaa.dr[1]) - (v-olds + decimal(d_arsum) + decimal(d_arsummy)).
              else do:
                  v-rmzsumval = (aaa.cr[1] - aaa.dr[1]) - (v-olds + decimal(d_arsum) + decimal(d_arsummy)).
                  v-rmzsum = trunc((v-rmzsumval * currrate),2).
              end.
              if v-rmzsum <= 0 then do:
                  message "Суммы на счете недостаточно для оплаты ИР. " + string(aaa.cr[1] - aaa.dr[1]) + " " + string(v-olds) + " " + string(d_arsum) + " " + string(d_arsummy) view-as alert-box.
                  leave.
              end.
          end. else do:
              v-rmzsum = decimal(aas.docprim).
              if aaa.crc <> 1 then v-rmzsumval = exchange(decimal(aas.docprim), currrate).
          end.
      end.
      if aas.sta = 9 and (aas.knp = '010' or aas.knp = '019' or aas.knp = '017' or aas.knp = '012') then do:
          if aaa.crc = 1 then aasfsum = aas.fsum. else aasfsum = exchange(aas.fsum, currrate).
          if (aaa.cr[1] - aaa.dr[1]) - (v-olds + decimal(d_arsum) + decimal(d_arsummy)) < aasfsum then do:
              message "Суммы на счете недостаточно для оплаты ИР. ~nИР по пенсионным и социальным рапоряжениям оплачиваются полностью" view-as alert-box.
              leave.
          end. else do:
              v-rmzsum = decimal(aas.docprim).
              if aaa.crc <> 1 then v-rmzsumval = exchange(decimal(aas.docprim), currrate).
          end.
      end.
      /*для ПТП galina*/
      if aas.sta = 9 and (aas.knp = '421' or aas.knp = '423' or aas.knp = '429') then do:
          for each b-aas where b-aas.aaa = aas.aaa and b-aas.ln = aas.ln no-lock:
              if b-aas.sta <> 9 or (b-aas.knp = '421' and b-aas.knp = '423' and b-aas.knp = '429') then do:
                  message "На счете имеются другие ограничения кроме ПТП!" view-as alert-box title "ВНИМАНИЕ".
                  leave.
              end.
          end.
          find first txb where txb.bank = v-ourbank no-lock no-error.
          if txb.mfo <> aas.bicben then do:
              message "Оплата внешних ПТП не возможна!" view-as alert-box title "ВНИМАНИЕ".
              leave.
          end.
          if aaa.crc = 1 then aasfsum = aas.fsum.
          else aasfsum = exchange(aas.fsum, currrate).
          if (aaa.cr[1] - aaa.dr[1]) - (v-olds + decimal(d_arsum) + decimal(d_arsummy)) < aasfsum then do:
              message "Суммы на счете недостаточно для оплаты.~nПТП оплачиваются полностью" view-as alert-box.
              leave.
          end. else do:
              v-rmzsum = decimal(aas.fsum).
              if aaa.crc <> 1 then v-rmzsumval = exchange(decimal(aas.fsum), currrate).
          end.
          find first buf-aaa where buf-aaa.aaa = v-iikben no-lock no-error.
          if not avail buf-aaa then do:
              message "Не найден счет для зачисления денег " + v-iikben view-as alert-box title "ВНИМАНИЕ".
              leave.
          end.
      end.

      if v-rmzsum <= 0 then do:
          message "Ошибка определения суммы оплаты!" view-as alert-box title "ВНИМАНИЕ".
          leave.
      end.
      v-sumh = 0.
      for each b-aas where b-aas.aaa = v-inkaaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16,17,0,3") <> 0 no-lock:
          v-sumh = v-sumh + b-aas.chkamt.
      end.
      if v-sumh <> aaa.hbal then do:
          message string(v-sumh) ' ' string(aaa.hbal) view-as alert-box.
          message "Сумма задержанного баланса не равна сумме ИР и спец.инструкций!" view-as alert-box title "ВНИМАНИЕ".
          leave.
      end.
      b = no.

      message "Внимание. Будет сформирован платёж на сумму " + string(v-rmzsum) + " счет " + v-inkaaa + " номер ИР " + v-inknum view-as alert-box question buttons yes-no update b.
      if not b then leave.
      if aas.sta = 9 and (aas.knp = '421' or aas.knp = '423' or aas.knp = '429') then do:
          run savelog("ink4", "1364 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) + " " + string(aas.docprim) ).
          v-sum = 0.
          find current aas exclusive-lock no-error.
          find current aas exclusive-lock no-error.
          find current aaa exclusive-lock no-error.
          t-sum = 0.
          for each b-aas where b-aas.aaa = v-inkaaa and lookup(string(b-aas.sta), "11,2,4,5,15,6,7,9,16,17") <> 0 no-lock:
              t-sum = t-sum + b-aas.chkamt.
          end.
          find current aaa exclusive-lock no-error.
          run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
          aaa.hbal = aaa.hbal - t-sum.
          v-sum = decimal(aas.docprim).
          v-sumval = exchange(decimal(aas.docprim), currrate).
          v-rem = 'Оплата ПТП № ' + v-fnum.
          update v-rem with frame f-rem.
          if aaa.crc = 1 then do:
              v-param = ''.
              v-param = '' + vdel +
                  string(v-sum) + vdel +
                  string(aaa.crc) + vdel +
                  aaa.aaa + vdel + v-iikben + vdel + v-rem + vdel + v-knp.
              s-jh = 0.
              rcode = 0.
              rdes = ''.
              run trxgen ("jou0022", vdel, v-param, "cif", v-iikben, output rcode, output rdes, input-output s-jh).
          end. else do:
              vparam = "".
              vparam = string(v-sumval)
                  + vdel + aaa.aaa
                  + vdel + string(getConvGL(aaa.crc,"C"))
                  + vdel + "Конв.для опл. " + v-rem + " поступившего на счет " + aas.aaa
                  + vdel + substr(cif.geo, 3, 1)
                  + vdel + "1"
                  + vdel + v_sec
                  + vdel + "4"
                  + vdel + "223"
                  + vdel + string(v-sum)
                  + vdel + v-arp
                  + vdel + v-rem + " поступившего на счет " + aas.aaa.
              s-jh = 0.
              run trxgen("vnb0085", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output s-jh).
              if rcode ne 0 then do:
                  message rdes view-as alert-box title "".
                  return.
              end.
              if s-jh > 0 then do:
                 run vou_bank(2).
              end.
              v-param = "".
              v-param = "" + vdel +
                  string(v-sum) + vdel +
                  string(1) + vdel + /* валюта */
                  v-arp + vdel +
                  v-iikben + vdel +
                  v-rem + " поступившего на счет " + aaa.aaa + vdel +
                  "1" + vdel +
                  v-knp. /* код назначения платежа */
              s-jh = 0.
              run trxgen ('jou0033', vdel, v-param, "cif", v-arp, output rcode, output rdes, input-output s-jh).
          end.
          if rcode > 0 then do:
              message rdes.
              pause 20.
          end.
          if s-jh > 0 then do:
              find current aaa exclusive-lock no-error.
              d-SumOfPlat = 0.
              aas.sta = 6.
              aas.irsts = "полностью".
              run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
              aaa.hbal = aaa.hbal - aas.chkamt.
              aas.chkamt = 0.
              aas.tim = time.
              op_kod = 'P'.
              aas.whn = g-today.
              aas.who = g-ofc.
              s-aaa = aaa.aaa.
              aas.mn = substr(aas.mn,1,3) + "43".
              RUN aas2his.
              op_kod= 'D'.
              aas.sta = 9.
              aas.tim = time + 1.
              aas.who = g-ofc.
              aas.whn = g-today.
              aas.mn = substr(aas.mn,1,3) + "44".
              RUN aas2his.
              delete aas.
              /*с внебаланса*/
              d-SumOfPlat = v-sum.
              {vnebal.i}
              run jou.
              v_doc = return-value.
              find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
              if avail joudoc then joudoc.num = v-fnum.
              find current joudoc no-lock no-error.
              find first jh where jh.jh = s-jh exclusive-lock.
              jh.party = v_doc.
              if jh.sts < 6 then jh.sts = 6.
              for each jl of jh:
                  if jl.sts < 6 then jl.sts = 6.
              end.
              find current jh no-lock.
              message 'Сумма ' + trim(string(v-sum,'>>>>>>>>>9.99')) + ' зачислена на счет ' + v-iikben + '. Номер проводки ' + trim(string(s-jh)).
              pause 5.
              run vou_bank(2).
              hide frame f-rem no-pause.
          end. /*f s-jh > 0 then*/

          find current aaa exclusive-lock no-error.
          run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
          aaa.hbal = aaa.hbal + t-sum.
          find current aaa no-lock no-error.
      end. else do:
          d-SumOfPlat = 0.
          d-SumOfPlatval = 0.
          if (aaa.cr[1] - aaa.dr[1]) - d_arsum  > 0 then do: /* деньги на счете есть производим оплату инкассовых распоряжений */
              if aas.docdat = ? then v-dt = aas.regdt. else v-dt = aas.docdat.
              v-opl = "".
              if aas.sta = 4 or aas.sta = 5 or (aas.sta = 9 and (aas.knp = '010' or aas.knp = '019' or aas.knp = '017' or aas.knp = '012')) then do:
                  if aaa.crc = 1 then do:
                      if decimal(aas.docprim) - d_arsummy <= ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds) then do:
                          run savelog("ink4", "1481 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat = decimal(aas.docprim) - decimal(d_arsummy).
                          v-opl = "Оплата И.Р номер " +  string(aas.fnum) + " от " + string(v-dt) + " КБК " +
                                  string(aas.kbk) + " " + string(aas.docnum) + ' ' + aas.payee.
                      end.
                      if decimal(aas.docprim) - d_arsummy >  ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds) then do:
                          run savelog("ink4", "1487 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat = (aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds - decimal(d_arsummy).
                          v-opl = "Оплата И.Р номер " + string(aas.fnum) + " от " + string(v-dt) + " КБК " +
                                  string(aas.kbk) + " " + string(aas.docnum) + " (Ч/О) " + aas.payee.
                      end.
                      if aas.sta = 9 and (aas.knp = '010' or aas.knp = '019' or aas.knp = '017' or aas.knp = '012') then do:
                          run savelog("ink4", "1494 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat = v-rmzsum.
                          v-opl = "Оплата И.Р номер " +  string(aas.fnum) + " от " + string(v-dt) + " КНП " +
                                  fill('0', 3 - length(aas.knp)) + string(aas.knp,'999') + " " + string(aas.docnum) + ' ' + aas.payee.
                      end.
                  end. else do:
                      if exchange(decimal(aas.docprim), currrate) - d_arsummy <= ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds) then do:
                          run savelog("ink4", "1503 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat = decimal(aas.docprim) - decimal(d_arsummykz).
                          d-SumOfPlatval =  exchange(d-SumOfPlat, currrate).
                          v-opl = "опл. И.Р ном." +  string(aas.fnum) + " от " + string(v-dt) + " КБК " +
                                  string(aas.kbk) + " " + string(aas.docnum) + ' ' + aas.payee.
                      end.
                      if exchange(decimal(aas.docprim), currrate) - d_arsummy >  ((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds) then do:
                          run savelog("ink4", "1510 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat =  trunc((((aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds - decimal(d_arsummy)) * currrate),2).
                          d-SumOfPlatval = (aaa.cr[1] - aaa.dr[1]) - decimal(d_arsum) - v-olds - decimal(d_arsummy).
                          v-opl = "опл. И.Р ном." + string(aas.fnum) + " от " + string(v-dt) + " КБК " +
                                   string(aas.kbk) + " " + string(aas.docnum) + " (Ч/О) " + aas.payee.
                      end.
                      if aas.sta = 9 and (aas.knp = '010' or aas.knp = '019' or aas.knp = '017' or aas.knp = '012') then do:
                          run savelog("ink4", "1517 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                          d-SumOfPlat = v-rmzsum.
                          d-SumOfPlatval = v-rmzsumval.
                          v-opl = "опл. И.Р ном." +  string(aas.fnum) + " от " + string(v-dt) + " КНП " +
                                   fill('0', 3 - length(aas.knp)) + string(aas.knp,'999') + " " + string(aas.docnum) + ' ' + aas.payee.
                      end.
                  end.
              end.
              v-bnfiik = ''.
              v-bnfrnn = ''.
              v-bicbnf = ''.
              run savelog("ink4", "1507 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) + " " + string(d-SumOfPlat)).
              if d-SumOfPlat <= 0 then leave.
              if aas.sta = 4 or aas.sta = 5  then do:
                  v-bnfiik = 'KZ24070105KSN0000000'.
                  v-bnfrnn = aas.dpname.
                  v-bicbnf = 'KKMFKZ2A'.
                  /* распоряжения администраторов судов */
                  if aas.dpname = "адм. судов" then do:
                      v-bnfiik = aas.iikben.
                      v-bnfrnn = aas.rnnben.
                      v-bicbnf = aas.bicben.
                  end.
              end.
              if aas.sta = 9 and (aas.knp = '010' or aas.knp = '019' or aas.knp = '017' or aas.knp = '012') then do:
                  find first p_f_list where p_f_list.rnn = aas.rnnben  and p_f_list.acnt = aas.iikben and p_f_list.bic = aas.bicben no-lock no-error.
                  if not avail p_f_list then do:
                      message "Не найден пенсионный фонд" view-as alert-box.
                      leave.
                  end.
                  v-bnfiik = aas.iikben.
                  v-bnfrnn = aas.rnnben.
                  v-bicbnf = aas.bicben.
              end.
              d-tmpSum = 0.
              d_sum = 0.
              d_sum = aaa.hbal.
              t-sum = 0.
              for each b-aas where b-aas.aaa = v-inkaaa and lookup(string(b-aas.sta), "2,4,5,6,7,9") <> 0 no-lock:
                  t-sum = t-sum + b-aas.chkamt.
              end.
              find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = aaa.cif and sub-cod.d-cod = "secek" no-lock no-error.
              if avail sub-cod and sub-cod.ccode <> "msc" then v_sec = string(sub-cod.ccode). else v_sec = "".
              if time < 50400 then r-cover = 1. /* SCLEAR00 */
              else r-cover = 2. /* SGROSS00 */
              if aaa.crc = 1 then do:
                  run savelog("ink4", "1542 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) + " " + string(d-SumOfPlat)).
                  run inktax(aas.fnum, /*Номер документа*/
                      d-SumOfPlat, /*Сумма платежа*/
                      aas.aaa, /*Счет отправителя*/
                      v-bicbnf, /*Банк получателя*/
                      v-bnfiik, /*Счет получателя*/
                      aas.kbk, /*КБК*/
                      true, /*Тип бюджета - проверяется если есть КБК*/
                      aas.bnf, /*Бенефициар*/
                      v-bnfrnn, /*РНН Бенефициара*/
                      fill('0', 3 - length(aas.knp)) + string(aas.knp,'999'), /*KNP*/
                      integer(substr(cif.geo, 3, 1) + v_sec), /*Kod*/
                      11 /*integer(comm.taxnk.kbe)*/, /* Kbe */
                      v-opl, /*Назначение платежа*/
                      "INK", /*Код очереди*/
                      "0", /*Кол-во экз.*/
                      r-cover, /*remtrz.cover (для проверки даты валютирования, т.е. 1-CLEAR00 или 2-SGROSS00) */
                      cif.jss, /*РНН отправителя*/
                      trim(trim(cif.prefix) + " " + trim(cif.name)), /*s-fiozer*/
                      "",  /* БИН Бенефициара */
                      ""). /* БИН отправителя */
              end. else do:
                  find current aaa exclusive-lock no-error.
                  run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - t-sum) + " ; " + string(t-sum)).
                  aaa.hbal = aaa.hbal - t-sum.
                  find current aaa no-lock no-error.
                  v-param = ''.
                  vparam = string(d-SumOfPlatval)
                      + vdel + aaa.aaa
                      + vdel + string(getConvGL(aaa.crc,"C"))
                      + vdel + "Конв.для " + v-opl + " поступившего на счет " + aas.aaa
                      + vdel + substr(cif.geo, 3, 1)
                      + vdel + "1"
                      + vdel + v_sec
                      + vdel + "4"
                      + vdel + "223"
                      + vdel + string(d-SumOfPlat)
                      + vdel + v-arp
                      + vdel + v-opl + " поступившего на счет " + aas.aaa.
                  s-jh = 0.
                  run savelog("ink4", "1578 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) + " " + string(d-SumOfPlatval) + " " + string(d-SumOfPlat)).
                  run trxgen("vnb0085", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output s-jh).
                  find current aaa exclusive-lock no-error.
                  run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + t-sum) + " ; " + string(t-sum)).
                  aaa.hbal = aaa.hbal + t-sum.
                  find current aaa no-lock no-error.
                  if rcode ne 0 then do:
                      message rdes view-as alert-box title "".
                      return.
                  end.
                  if s-jh > 0 then do:
                      run vou_bank(2).
                      run savelog("ink4", "1589 ; " + aas.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) + " " + string(d-SumOfPlat)).
                      run inktax(aas.fnum, /*Номер документа*/
                          d-SumOfPlat, /*Сумма платежа*/
                          v-arp, /*Счет отправителя*/
                          v-bicbnf, /*Банк получателя*/
                          v-bnfiik, /*Счет получателя*/
                          aas.kbk, /*КБК*/
                          true, /*Тип бюджета - проверяется если есть КБК*/
                          aas.bnf, /*Бенефициар*/
                          v-bnfrnn, /*РНН Бенефициара*/
                          fill('0', 3 - length(aas.knp)) + string(aas.knp,'999'), /*KNP*/
                          integer(substr(cif.geo, 3, 1) + v_sec), /*Kod*/
                          11 /*integer(comm.taxnk.kbe)*/, /* Kbe */
                          v-opl, /*Назначение платежа*/
                          "INK", /*Код очереди*/
                          "0", /*Кол-во экз.*/
                          r-cover, /*remtrz.cover (для проверки даты валютирования, т.е. 1-CLEAR00 или 2-SGROSS00) */
                          cif.jss, /*РНН отправителя*/
                          trim(trim(cif.prefix) + " " + trim(cif.name)), /*s-fiozer*/
                          "",  /* БИН Бенефициара */
                          ""). /* БИН отправителя */
                  end.
              end.
              if return-value <> "" then do:
                  create t-iaccs.
                  assign
                      t-iaccs.iaaa   = aas.aaa
                      t-iaccs.icif   = aaa.cif
                      t-iaccs.fsum   = aas.fsum
                      t-iaccs.docdat = aas.docdat
                      t-iaccs.knp    = aas.knp
                      t-iaccs.kbk    = aas.kbk
                      t-iaccs.fnum   = aas.fnum.
                  /* таблица неоплаченных RMZ */
                  create aaar.
                  assign
                      aaar.a1 = return-value /*rmz*/
                      aaar.a2 = aas.fnum /*номер ИР*/
                      aaar.a3 = string(d-SumOfPlat) /*сумм*/
                      aaar.a5 = aas.aaa
                      aaar.a6 = string(g-today).
                  if aaa.crc <> 1 then aaar.a7 = v-arp.
                  /*признак ИР была служебка от бугалтерии*/
                  find last sub-cod where sub-cod.acc = return-value and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
                  if avail sub-cod then do:
                      sub-cod.d-cod = 'pdoctng'.
                      sub-cod.ccode = '03'.
                  end. else do:
                      create sub-cod.
                      assign
                          sub-cod.acc   = return-value
                          sub-cod.sub   = 'rmz'
                          sub-cod.d-cod = 'pdoctng'
                          sub-cod.ccode = '03'.
                  end.
                  put stream m-out unformatted aaa.aaa + "+УСПЕШНО формирование rmz " + return-value skip.
                  message "Перевод успешно создан, необходим акцепт!" view-as alert-box information.
              end. else do:
                run savelog("ink4", "1664 ; Не создалась RMZ  " + aaa.aaa + " " + string(aas.fnum) + " " + string(aas.docnum) ).
                put stream m-out unformatted aaa.aaa + "-ОШИБКА формирование rmz " + rdes  skip.
              end.
          end.
      end.
      browse b1:refresh().
   end.
   on choose OF bhistory IN FRAME fr1 do:
           message "Ждите идет поиск...".
           ON CHOOSE OF bexit IN FRAME fr4 do:
              hide frame fr4.
              APPLY "WINDOW-CLOSE" TO BROWSE b4.
           end.
           ON CHOOSE OF bdethis IN FRAME fr4 do:
              find last aaa where aaa.aaa = t-aashist.aaa no-lock no-error.
              find buf-t-aashist where rowid (buf-t-aashist) = rowid (t-aashist) exclusive-lock no-error.
              if avail buf-t-aashist and avail aaa then do:
                  ON CHOOSE OF bexit IN FRAME fr5 do:
                     hide frame fr5.
                     message "".
                     pause 0.
                     APPLY "WINDOW-CLOSE" TO BROWSE b5.
                  end.
                  ON CHOOSE OF bdtlst IN FRAME fr5 do:
                     find buf-t-aashist1 where rowid (t-aashist1) = rowid (buf-t-aashist1) no-lock no-error.
                     if avail buf-t-aashist1 then do:
                         if t-aashist1.sta = 9 or t-aashist1.sta = 15 then message "ПРОЧИЕ ИНКАССОВЫЕ РАСПОРЯЖЕНИЯ ".
                         else message "ОБЯЗАТЕЛЬНЫЕ ПЛАТЕЖИ В БЮДЖЕТ".
                         if t-aashist1.chgoper = "T" then do: /*приостановлено*/
                            display t-aashist1.fnum t-aashist1.docdat t-aashist1.who t-aashist1.bnf t-aashist1.dpname t-aashist1.kbk t-aashist1.knp t-aashist1.payee t-aashist1.dtbefore t-aashist1.docnum1 t-aashist1.docdat1 t-aashist1.docprim1 with frame getlist33.
                         end. else if t-aashist1.chgoper = "O" or t-aashist1.chgoper = "X" then do: /*отозвано*/
                            display t-aashist1.fnum t-aashist1.docdat t-aashist1.who t-aashist1.bnf t-aashist1.dpname t-aashist1.kbk t-aashist1.knp t-aashist1.payee t-aashist1.dtbefore t-aashist1.docnum1 t-aashist1.docdat1 t-aashist1.docprim1 with frame getlist34.
                         end. else do:
                            if t-aashist1.sta <> 9 and t-aashist1.sta <> 15 then
                               display t-aashist1.aaa  t-aashist1.regdt t-aashist1.dpname t-aashist1.kbk t-aashist1.bnf t-aashist1.fsum t-aashist1.fnum t-aashist1.docdat t-aashist1.knp t-aashist1.payee with frame getlock.
                            else display t-aashist1.aaa t-aashist1.regdt t-aashist1.docprim t-aashist1.fnum t-aashist1.docdat t-aashist1.bnfname t-aashist1.rnnben t-aashist1.bicben t-aashist1.bankben t-aashist1.iikben t-aashist1.knp t-aashist1.payee with frame get_hist1.
                         end.
                     end.
                  end.
                  for each t-aashist1.
                      delete t-aashist1.
                  end.
                  for each aas_hist where aas_hist.aaa = t-aashist.aaa  and aas_hist.ln = t-aashist.ln and lookup(string(aas_hist.sta), "4,5,6,9,15") <> 0  exclusive-lock USE-INDEX aasprep break by aas_hist.tim DESCENDING:
                      create t-aashist1.
                      find last ofc where ofc.ofc = aas_hist.who no-lock no-error.
                      if      aas_hist.chgoper = 'A' then t-aashist1.name1 = "Введено   [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'E' then t-aashist1.name1 = "Изменено  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'D' then t-aashist1.name1 = "Удалено   [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'P' then t-aashist1.name1 = "Опл полн  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'L' then t-aashist1.name1 = "Опл част  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'T' then t-aashist1.name1 = "Приост-но [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'O' then t-aashist1.name1 = "Отозвано  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'X' then t-aashist1.name1 = "Отк Акцепт[" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      else if aas_hist.chgoper = 'Q' then t-aashist1.name1 = "Действует [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                      t-aashist1.docdat   = aas_hist.docdat  .
                      t-aashist1.dpname   = aas_hist.dpname  .
                      find first taxnk where taxnk.rnn = aas_hist.dpname no-lock no-error.
                      if  avail taxnk then aas_hist.bnf = taxnk.name.
                      t-aashist1.bnf      = aas_hist.bnf     .
                      t-aashist1.docnum1  = aas_hist.docnum1 .
                      t-aashist1.docdat1  = aas_hist.docdat1 .
                      t-aashist1.docprim1 = aas_hist.docprim1.
                      t-aashist1.fnum     = aas_hist.fnum    .
                      t-aashist1.kbk      = aas_hist.kbk     .
                      t-aashist1.knp      = aas_hist.knp     .
                      t-aashist1.aaa      = aas_hist.aaa     .
                      t-aashist1.ln       = aas_hist.ln      .
                      t-aashist1.sic      = aas_hist.sic     .
                      t-aashist1.chkdt    = aas_hist.chkdt   .
                      t-aashist1.chkno    = aas_hist.chkno   .
                      t-aashist1.chkamt   = aas_hist.chkamt  .
                      t-aashist1.payee    = aas_hist.payee   .
                      t-aashist1.chgoper  = aas_hist.chgoper .
                      t-aashist1.chgdat   = aas_hist.chgdat  .
                      t-aashist1.chgtime  = aas_hist.chgtime .
                      t-aashist1.who      = aas_hist.who     .
                      t-aashist1.tim      = aas_hist.tim     .
                      t-aashist1.dtbefore = aas_hist.dtbefore.
                      t-aashist1.docprim  = aas_hist.docprim .
                      t-aashist1.fsum     = aas_hist.fsum    .
                      t-aashist1.bnfname  = aas_hist.bnfname .
                      t-aashist1.rnnben   = aas_hist.rnnben  .
                      t-aashist1.bicben   = aas_hist.bicben  .
                      t-aashist1.bankben  = aas_hist.bankben .
                      t-aashist1.iikben   = aas_hist.iikben  .
                      t-aashist1.sta      = aas_hist.sta     .
                      t-aashist1.regdt    = aas_hist.regdt   .
                  end.
                  open query q5 for each t-aashist1 no-lock.
                  b5:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                  ENABLE all with frame fr5 centered overlay top-only.
                  apply "value-changed" to b5 in frame fr5.
                  WAIT-FOR WINDOW-CLOSE of frame fr5.
              end.
           end.
           for each t-aashist.
               delete t-aashist.
           end.
           p-aaa = ''.
           p-ln = 0.
           for each aas_hist where aas_hist.aaa = aaa.aaa and lookup(string(aas_hist.sta), "4,5,6,9,15") <> 0  NO-LOCK USE-INDEX aasprep break by  aas_hist.ln  by aas_hist.chgdat DESCENDING  by aas_hist.tim DESCENDING:
               if aas_hist.ln <> p-ln then do transaction:
                   p-aaa = aas_hist.aaa.
                   p-ln = aas_hist.ln.
                   create t-aashist.
                   t-aashist.fnum = aas_hist.fnum.
                   t-aashist.aaa = aas_hist.aaa.
                   t-aashist.ln  = aas_hist.ln.
                   t-aashist.sic = aas_hist.sic.
                   t-aashist.chkdt = aas_hist.chkdt.
                   t-aashist.chkno = aas_hist.chkno.
                   t-aashist.chkamt = aas_hist.chkamt.
                   t-aashist.docprim = aas_hist.docprim.
                   t-aashist.payee = aas_hist.payee.
                   t-aashist.chgoper = aas_hist.chgoper.
                   t-aashist.who = aas_hist.who.
                   t-aashist.tim = aas_hist.tim.
                   t-aashist.cif = aas_hist.cif.
                   t-aashist.fsum    = aas_hist.fsum.
                   t-aashist.bnfname = aas_hist.bnfname.
                   t-aashist.rnnben  = aas_hist.rnnben.
                   t-aashist.bicben  = aas_hist.bicben.
                   t-aashist.bankben = aas_hist.bankben.
                   t-aashist.iikben  = aas_hist.iikben.
                   if aas_hist.chgoper = 'D' or aas_hist.chgoper = 'O' or aas_hist.chgoper = 'X' then t-aashist.ctc = '[Удалено  ]'.
                   else t-aashist.ctc = '[Действует]'.
               end.
           end.
           open query q4 for each t-aashist where t-aashist.aaa = aas.aaa no-lock.
           message "".
           pause 0.
           b4:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
           ENABLE all with frame fr4 centered overlay top-only.
           apply "value-changed" to b4 in frame fr4.
           WAIT-FOR WINDOW-CLOSE of frame fr4.
   end.
   ON CHOOSE OF bprint IN FRAME fr1 do:
      output to value("file.txt").
      put unformatted " " skip.
      put unformatted "------------------------------------------------------------------------------------------" skip.
      put unformatted "                  ПРИОСТАНОВЛЕНИЕ ОПЕРАЦИЙ ПО СЧЕТАМ                            " skip.
      put unformatted "------------------------------------------------------------------------------------------" skip.
      put unformatted "  CIF          СЧЕТ         N ДОК   ДАТА ДОК. ДАТА РЕГ  ОРГАН_ОГР          ПРИМЕЧАНИЕ     " skip.
      put unformatted "------------------------------------------------------------------------------------------" skip.
      if v-dep = 1 then
          for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and aas.cif = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/ exclusive-lock:
              put unformatted aas.cif " " aas.aaa format 'x(20)' " " aas.fnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "  " string(aas.regdt,"99/99/99") "  " aas.dpname format 'x(15)'   "     " aas.payee skip.
          end.
      if v-dep = 2 then
          for each aas where lookup(string(aas.sta), "4,15,5,6,7,9") <> 0 and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln:
              put unformatted aas.cif " " aas.aaa format 'x(20)' " " aas.fnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "  " string(aas.regdt,"99/99/99") "  " aas.dpname format 'x(15)' "     " aas.payee skip.
          end.
      if v-dep = 3 then
          for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and aas.fnum = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/ exclusive-lock:
              put unformatted aas.cif " " aas.aaa format 'x(20)' " " aas.fnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "  " string(aas.regdt,"99/99/99") "  " aas.dpname format 'x(15)'   "     " aas.payee skip.
          end.
      if v-dep = 4 then
          for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and aas.cif = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/ exclusive-lock:
              put unformatted aas.cif " " aas.aaa format 'x(20)' " " aas.fnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "  " string(aas.regdt,"99/99/99") "  " aas.dpname format 'x(15)'   "     " aas.payee skip.
          end.
      if v-dep = 5 then
          for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and aas.whn >= dt_FindDateBegin and aas.whn <= dt_FindDateEnd and aas.ln <> 7777777 /*use-index aaaln*/ exclusive-lock:
              put unformatted aas.cif " " aas.aaa format 'x(20)' " " aas.fnum format 'x(7)' "  " string(aas.docdat,"99/99/99") "  " string(aas.regdt,"99/99/99") "  " aas.dpname format 'x(15)'   "     " aas.payee  skip.
          end.
      output close.
      run menu-prt('file.txt').
   end.
   /*Выход*/
   ON CHOOSE OF bexit IN FRAME fr1 do:
      message "".
      pause 0.
      hide frame fr1.
      APPLY "WINDOW-CLOSE" TO BROWSE b1.
      view frame a2.
   end.
   /*Свойства*/
   ON CHOOSE OF bdetail IN FRAME fr1 do:
      /* Из основного фрейма кнопка СВОЙСТВА */
      find buf-aas where rowid (aas) = rowid (buf-aas) exclusive-lock.
      if aas.sta = 9 or aas.sta = 15 then message "ПРОЧИЕ ИНКАССОВЫЕ РАСПОРЯЖЕНИЯ ".
      else message "ОБЯЗАТЕЛЬНЫЕ ПЛАТЕЖИ В БЮДЖЕТ".
      find first taxnk where taxnk.rnn = aas.dpname no-lock no-error.
      if  avail taxnk then aas.bnf = taxnk.name.
      find last ofc where ofc.ofc = aas.who no-lock no-error.
      if avail ofc then  do:
         if aas.sta <> 9 and aas.sta <> 15 then display aas.aaa  aas.regdt aas.docprim aas.fnum aas.docdat aas.bnf  aas.dpname aas.docnum aas.payee aas.kbk aas.knp aas.rgref with frame getlist1.
         else display aas.aaa  aas.regdt aas.docprim aas.fnum aas.docdat aas.bnfname aas.rnnben aas.bicben aas.bankben aas.iikben aas.knp aas.payee with frame getother1.
      end.
      hide frame getother1.
   end.
   /*Снять ограничение*/
   ON CHOOSE OF brem IN FRAME fr1 do:
      v-flv = 0.
      if aas.contr then do:
          /*
          if aas.irsts = "приостан." then do: v-flv = 2. message '2'. pause. end.
          else do:*/
             if aas.docnum1 = "" then v-flv = 2 /*3*/.
             if aas.docnum1 <> "" then v-flv = 1.
          /*end.*/
      end. else do:
          form vsele2 with 1 column centered row 10 no-label frame nnn.
          view frame nnn.
          display vsele2 with frame nnn.
          choose field vsele2 auto-return with frame nnn.
          hide frame nnn.
          v-flv = 0.
      end.
      if frame-index = 1 or /*frame-index = 3 or*/ frame-index = 2 or v-flv = 1 or v-flv = 2 /*or v-flv = 3*/ then do:
          find buf-aas where rowid (buf-aas) = rowid (aas) exclusive-lock.
          find first buf-ofc1 where buf-ofc1.ofc = g-ofc NO-LOCK.

          /*if frame-index = 3 then v-text = "Вы подтверждаете отказ в акцепте?".*/
          if frame-index = 1 or v-flv = 1 then v-text = "Вы действительно хотите отозвать ИР?".
          if frame-index = 2 or v-flv = 2 then v-text = "Вы действительно хотите удалить ИР?".
          v-yn =  false.
          if v-flv = 0 then v-yn = yes-no ("Внимание!", v-text).
          if v-yn = True or (v-yn = False and v-flv <> 0) then do:
              find buf-aas where rowid (buf-aas) = rowid (aas) no-lock no-error.
              if not aas.contr then do:
                  if frame-index = 1 then update aas.docnum1 aas.docdat1 aas.docprim1 with frame getlist2.
                  else update aas.docprim1 with frame listacsept.
                  aas.activ = False.
                  aas.whn1 = g-today.
                  aas.who1 = g-ofc.
                  find last aas_hist where aas_hist.ln= aas.ln exclusive-lock no-error.
                  hide frame getlist2.
                  hide frame listacsept.
                  release buf-aas.
                  message "Необходим контроль Директором/ЗамОД в 1.3.1.6" view-as alert-box question buttons ok.
              end. else do:
                  find buf-aas where rowid (buf-aas) = rowid (aas) exclusive-lock.
                  find first aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
                  /*if frame-index = 3 or v-flv = 3 then op_kod= 'X'.*/
                  if frame-index = 1 or v-flv = 1 then do: op_kod= 'O'. aas.mn = substr(aas.mn,1,3) + "41". end.
                  if frame-index = 2 or v-flv = 2 then do: op_kod= 'D'. aas.mn = substr(aas.mn,1,3) + "49". end.
                  aas.who = g-ofc.
                  aas.whn = g-today.
                  aas.tim = time.
                  s-aaa = aaa.aaa.
                  RUN aas2his.
                  /* Снятие сумм с внебаланса при удалении */
                  v-usrglacc = "".
                  if s-vcourbank = "txb00" then do:
                      find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
                      if avail vnebal then v-usrglacc = vnebal.gl.
                      else do:
                          v-ofc1 =  string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
                          find last vnebal where vnebal.usr = v-ofc1 no-lock no-error.
                          if avail vnebal then v-usrglacc = vnebal.gl.
                      end.
                  end. else do:
                     find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
                     if avail vnebal then v-usrglacc = vnebal.gl.
                  end.
                  if v-usrglacc <> "" then do:
                      v-jh = 0.
                      vparam2 = aas.docprim + vdel + string(1) + vdel + "830300" + vdel + v-usrglacc + vdel + aaa.aaa + vdel + aaa.aaa + vdel.
                      run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                      if rcode ne 0 then do:
                          message aaa.aaa + "Ошибка снятия суммы с внебаланса: " + rdes view-as alert-box buttons ok.
                          return.
                      end. else do:
                          message "Произведена транзакция #" v-jh " по снятию суммы ИР с внебаланса" v-usrglacc view-as alert-box buttons ok.
                          pause.
                      end.
                  end. else do:
                      message aaa.aaa + "Не найден счет Г/К для снятия с внебаланса " view-as alert-box buttons ok.
                      return.
                  end.
                  find first aaa where aaa.aaa = aas.aaa exclusive-lock no-error.
                  if avail aaa then do:
                     run savelog("aaahbal", "ink4_1 ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
                     aaa.hbal = aaa.hbal - aas.chkamt.
                  end.
                  delete buf-aas.
                  browse b1:refresh().
              end.
          end.
      end.
   end.

   repeat:
       message "".
       pause 0.
       run sel2 (" Параметры поиска", " 1. По наименованию | 2. По номеру счета | 3. По номеру ИР | 4. По CIF коду | 5. За период | ВЫХОД", output v-dep).
       if v-dep = 0 then return.
       on help of s_FindAcc in frame t_frame1 do:
          v-cif1 = "".
          run h-cif PERSISTENT SET phand.
          v-cif1 = frame-value.
          if trim(v-cif1) <> "" then do:
              find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock no-error.
              if available aaa then do:
                  OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" no-lock,
                                         each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
                  ENABLE ALL WITH FRAME f-help.
                  wait-for return of frame f-help
                  FOCUS b-help IN FRAME f-help.
                  s_FindAcc = aaa.aaa.
                  hide frame f-help.
              end. else  do:
                 s_FindAcc = "".
                 MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
              end.
              displ  s_FindAcc with frame t_frame1.
          end.
          DELETE PROCEDURE phand.
       end.
       on help of s_FindCIF in frame t_frame2 do:
          v-cif1 = "".
          run h-cif PERSISTENT SET phand.
          v-cif1 = frame-value.
          if trim(v-cif1) <> "" then do:
              find first cif where cif.cif = v-cif1 no-lock no-error.
              if available cif then do:
                 s_FindCIF = cif.cif.
              end. else do:
                 s_FindCIF = "".
                 MESSAGE "CIF код КЛИЕНТА НЕ НАЙДЕН.".
              end.
              displ  s_FindCIF with frame t_frame2.
          end.
          DELETE PROCEDURE phand.
       end.
       on help of s_FindCIF in frame t_frame9 do:
          v-cif1 = "".
          run h-cif PERSISTENT SET phand.
          v-cif1 = frame-value.
          if trim(v-cif1) <> "" then do:
             find first cif where cif.cif = v-cif1 no-lock no-error.
             if available cif then do:
                s_FindCIF = cif.cif.
             end. else do:
                s_FindCIF = "".
                MESSAGE "CIF код КЛИЕНТА НЕ НАЙДЕН.".
             end.
             displ  s_FindCIF with frame t_frame9.
          end.
          DELETE PROCEDURE phand.
       end.
       case v-dep:
           when 1 then do: /*по наименованию*/
                hide frame a2.
                {itemlist.i
                  &updvar  = "def var vname like cif.sname. {imesg.i 2808} update vname. vname = '*' + vname + '*' . "
                  &where = "(caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vname or caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vname)"
                  &form = "cif.cif cif.sname form ""x(40)"" cif.jss cif.tel "
                  &frame = "row 5 centered scroll 1 down overlay "
                  &index = "sname"
                  &chkey = "cif"
                  &chtype = "string"
                  &file = "cif"
                  &flddisp = "cif.cif trim(trim(cif.prefix) + ' ' + trim(cif.sname)) @ cif.sname  cif.jss  cif.tel "
                  &funadd = "if frame-value = "" "" then do: bell. {imesg.i 9205}. pause 1. next. end."
                  &set = "N"
                }
                v-cif1 = frame-value.
                if trim(v-cif1) <> "" then do:
                       find first cif where cif.cif = v-cif1 no-lock no-error.
                       if available cif then do:
                           s_FindCIF = cif.cif.
                           s_FindName = trim(cif.prefix) + " " + trim(cif.name).
                       end. else do:
                           s_FindCIF = "".
                           s_FindName = "".
                           MESSAGE "КЛИЕНТ НЕ НАЙДЕН.".
                       end.
                       displ s_FindName with frame t_frame3.
                end.
                open query q1 for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and  aas.cif = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/.
                hide frame t_frame3.
                b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                ENABLE all with frame fr1 centered overlay top-only.
                apply "value-changed" to b1 in frame fr1.
                WAIT-FOR WINDOW-CLOSE of frame fr1.
           end.
           when 2 then do: /*По номеру счета*/
                hide frame a2.
                repeat:
                   update s_FindAcc with frame t_frame1.
                   find aaa where aaa.aaa = s_FindAcc no-error.
                   if not available aaa then do:
                      message "Счет не найден".
                      pause 3.
                   end. else do:
                      if aaa.sta = 'C' then do:
                         message skip "Счет " + aaa.aaa + " закрыт !" skip "Добавление спец.инструкций невозможно !" skip(1)
                              view-as alert-box button Ok title "Внимание!".
                         return.
                      end.
                      leave.
                   end.
                end.
                hide frame t_frame1.
                i_indx = 0.
                for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0  and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln.
                    i_indx = i_indx + 1.
                end.
                if i_indx <> 0 then do:
                   open query q1 for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0  and aas.aaa = s_FindAcc and aas.ln <> 7777777 use-index aaaln.
                   b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                   ENABLE all with frame fr1 centered overlay top-only.
                   apply "value-changed" to b1 in frame fr1.
                   WAIT-FOR WINDOW-CLOSE of frame fr1.
                end. else do:
                   display "По счету " + s_FindAcc + " нет инкассовых распоряжений !" format "x(47)" with center row 7 frame bridin.
                   form vsele with 1 column centered row 10 no-label frame nnn.
                   view frame nnn.
                   display vsele with frame nnn.
                   choose
                   field vsele auto-return with frame nnn.
                   hide frame bridin.
                   hide frame nnn.
                   if frame-index = 1 then do:
                      message "Ждите идет поиск...".
                      ON CHOOSE OF bexit IN FRAME fr4 do:
                         hide frame fr4.
                         APPLY "WINDOW-CLOSE" TO BROWSE b4.
                      end.
                      ON CHOOSE OF bdethis IN FRAME fr4 do:
                         find last aaa where aaa.aaa = t-aashist.aaa no-lock no-error.
                         find buf-t-aashist where rowid (buf-t-aashist) = rowid (t-aashist) exclusive-lock no-error.
                         if avail buf-t-aashist and avail aaa then do:
                             ON CHOOSE OF bexit IN FRAME fr5 do:
                                hide frame fr5.
                                message "".
                                pause 0.
                                APPLY "WINDOW-CLOSE" TO BROWSE b5.
                             end.
                             ON CHOOSE OF bdtlst IN FRAME fr5 do:
                                find buf-t-aashist1 where rowid (t-aashist1) = rowid (buf-t-aashist1) no-lock no-error.
                                if avail buf-t-aashist1 then do:
                                    if t-aashist1.chgoper = "T" then do: /*приостановлено*/
                                        display t-aashist1.fnum t-aashist1.docdat t-aashist1.who t-aashist1.bnf t-aashist1.dpname t-aashist1.kbk t-aashist1.knp t-aashist1.payee t-aashist1.dtbefore t-aashist1.docnum1 t-aashist1.docdat1 t-aashist1.docprim1  with frame getlist33.
                                        hide frame getlist33.
                                    end. else if t-aashist1.chgoper = "O" or t-aashist1.chgoper = "X" then do: /*отозвано*/
                                            display t-aashist1.fnum t-aashist1.docdat t-aashist1.who t-aashist1.bnf t-aashist1.dpname t-aashist1.kbk t-aashist1.knp t-aashist1.payee t-aashist1.dtbefore t-aashist1.docnum1 t-aashist1.docdat1 t-aashist1.docprim1  with frame getlist34.
                                            hide frame getlist34.
                                    end. else if t-aashist1.sta = 9 or t-aashist1.sta = 15 then
                                       message "ПРОЧИЕ ИНКАССОВЫЕ РАСПОРЯЖЕНИЯ ".
                                    else message "ОБЯЗАТЕЛЬНЫЕ ПЛАТЕЖИ В БЮДЖЕТ".
                                    displ t-aashist1.aaa t-aashist1.regdt t-aashist1.fnum t-aashist1.fsum t-aashist1.docdat t-aashist1.bnf
                                          t-aashist1.dpname t-aashist1.payee t-aashist1.kbk t-aashist1.knp with frame getlock.
                                    hide frame getlock.
                                end.
                             end.
                             for each t-aashist1 .
                                 delete t-aashist1.
                             end.
                             for each aas_hist where aas_hist.aaa = t-aashist.aaa  and aas_hist.ln = t-aashist.ln and lookup(string(aas_hist.sta), "4,5,15,6,7,9") <> 0 NO-LOCK USE-INDEX aasprep break by aas_hist.tim DESCENDING :
                                 find last ofc where ofc.ofc = aas_hist.who no-lock no-error.
                                 create t-aashist1.
                                 if      aas_hist.chgoper = 'A' then t-aashist1.name1 = "Введено   [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'E' then t-aashist1.name1 = "Изменено  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'D' then t-aashist1.name1 = "Удалено   [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'P' then t-aashist1.name1 = "Опл полн  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'L' then t-aashist1.name1 = "Опл част  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'T' then t-aashist1.name1 = "Приост-но [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'O' then t-aashist1.name1 = "Отозвано  [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'X' then t-aashist1.name1 = "Отк Акцепт[" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 else if aas_hist.chgoper = 'Q' then t-aashist1.name1 = "Действует [" + ofc.name + "," + string(aas_hist.chgdat) + "," + STRING(aas_hist.chgtime, "hh:mm:ss") + "]" .
                                 t-aashist1.fnum     = aas_hist.fnum    .
                                 t-aashist1.docdat   = aas_hist.docdat  .
                                 t-aashist1.bnf      = aas_hist.bnf     .
                                 t-aashist1.dpname   = aas_hist.dpname  .
                                 t-aashist1.docprim1 = aas_hist.docprim1.
                                 t-aashist1.docnum1  = aas_hist.docnum1 .
                                 t-aashist1.docdat1  = aas_hist.docdat1 .
                                 t-aashist1.aaa      = aas_hist.aaa     .
                                 t-aashist1.ln       = aas_hist.ln      .
                                 t-aashist1.sic      = aas_hist.sic     .
                                 t-aashist1.chkdt    = aas_hist.chkdt   .
                                 t-aashist1.chkno    = aas_hist.chkno   .
                                 t-aashist1.chkamt   = aas_hist.chkamt  .
                                 t-aashist1.payee    = aas_hist.payee   .
                                 t-aashist1.chgoper  = aas_hist.chgoper .
                                 t-aashist1.chgdat   = aas_hist.chgdat  .
                                 t-aashist1.chgtime  = aas_hist.chgtime .
                                 t-aashist1.who      = aas_hist.who     .
                                 t-aashist1.tim      = aas_hist.tim     .
                                 t-aashist1.dtbefore = aas_hist.dtbefore.
                                 t-aashist1.docprim  = aas_hist.docprim .
                                 t-aashist1.fsum     = aas_hist.fsum    .
                                 t-aashist1.bnfname  = aas_hist.bnfname .
                                 t-aashist1.rnnben   = aas_hist.rnnben  .
                                 t-aashist1.bicben   = aas_hist.bicben  .
                                 t-aashist1.bankben  = aas_hist.bankben .
                                 t-aashist1.iikben   = aas_hist.iikben  .
                                 t-aashist1.kbk      = aas_hist.kbk     .
                                 t-aashist1.knp      = aas_hist.knp     .
                                 t-aashist1.regdt    = aas_hist.regdt   .
                             end.
                             open query q5 for each t-aashist1 no-lock by t-aashist1.chgtime DESCENDING.
                             b5:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                             ENABLE all with frame fr5 centered overlay top-only.
                             apply "value-changed" to b5 in frame fr5.
                             WAIT-FOR WINDOW-CLOSE of frame fr5.
                         end.
                      end.
                      for each t-aashist.
                          delete t-aashist.
                      end.
                      p-aaa = ''.
                      p-ln = 0.
                      for each aas_hist where aas_hist.aaa = aaa.aaa and lookup(string(aas_hist.sta), "4,5,15,6,9,15") <> 0 NO-LOCK USE-INDEX aasprep break by aas_hist.ln by aas_hist.chgdat DESCENDING by aas_hist.tim DESCENDING:
                          if aas_hist.ln <> p-ln then do transaction:
                             p-aaa = aas_hist.aaa.
                             p-ln = aas_hist.ln.
                             create t-aashist.
                             t-aashist.aaa      = aas_hist.aaa    .
                             t-aashist.ln       = aas_hist.ln     .
                             t-aashist.sic      = aas_hist.sic    .
                             t-aashist.chkdt    = aas_hist.chkdt  .
                             t-aashist.chkno    = aas_hist.chkno  .
                             t-aashist.chkamt   = aas_hist.chkamt .
                             t-aashist.docprim  = aas_hist.docprim.
                             t-aashist.payee    = aas_hist.payee  .
                             t-aashist.chgoper  = aas_hist.chgoper.
                             t-aashist.who      = aas_hist.who    .
                             t-aashist.tim      = aas_hist.tim    .
                             t-aashist.cif      = aas_hist.cif    .
                             t-aashist.bnfname  = aas_hist.bnfname.
                             t-aashist.rnnben   = aas_hist.rnnben .
                             t-aashist.bicben   = aas_hist.bicben .
                             t-aashist.bankben  = aas_hist.bankben.
                             t-aashist.iikben   = aas_hist.iikben .
                             if aas_hist.chgoper = 'D' or aas_hist.chgoper = 'O' or aas_hist.chgoper = 'X' then t-aashist.ctc = '[Удалено  ]'.
                             else t-aashist.ctc = '[Действует]'.
                          end.
                      end.
                      open query q4 for each t-aashist where t-aashist.aaa = aaa.aaa no-lock.
                      message "".
                      pause 0.
                      b4:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                      ENABLE all with frame fr4 centered overlay top-only.
                      apply "value-changed" to b4 in frame fr4.
                      WAIT-FOR WINDOW-CLOSE of frame fr4.
                   end.
                end.
           end.
           when 3 then do: /* По номеру ИР */
                hide frame a2.
                update s_FindCIF with frame t_frame9.
                open query q1 for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and  aas.fnum = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/.
                b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                ENABLE all with frame fr1 centered overlay top-only.
                apply "value-changed" to b1 in frame fr1.
                WAIT-FOR WINDOW-CLOSE of frame fr1.
           end.
           when 4 then  do: /* По CIF коду */
                hide frame a2.
                update s_FindCIF with frame t_frame2.
                open query q1 for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and  aas.cif = s_FindCIF and aas.ln <> 7777777 /*use-index aaaln*/.
                b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                ENABLE all with frame fr1 centered overlay top-only.
                apply "value-changed" to b1 in frame fr1.
                WAIT-FOR WINDOW-CLOSE of frame fr1.
           end.
           when 5 then do: /* За период */
                hide frame a2.
                update dt_FindDateBegin label  "Дата начала" with centered row 7 side-label frame t_frame4.
                update dt_FindDateEnd label "Дата окончания" with centered row 7 side-label frame t_frame4.
                open query q1 for each aas where lookup(string(aas.sta), "4,5,15,6,7,9") <> 0 and aas.whn >= dt_FindDateBegin and aas.whn <= dt_FindDateEnd and aas.ln <> 7777777 /*use-index aaaln*/.
                b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
                ENABLE all with frame fr1 centered overlay top-only.
                apply "value-changed" to b1 in frame fr1.
                WAIT-FOR WINDOW-CLOSE of frame fr1.
           end.
           when 6 then do:
                view frame a2.
                return.
           end.
       end.
   end.
end.

enable all with frame a2.
view frame a2.
wait-for window-close of current-window.