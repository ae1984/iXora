/* jou_main.p
 * MODULE
        Операционист
 * DESCRIPTION
        Журнал операций
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT
        куча всяких
 * MENU
        2-1, 3-1-6
 * BASES
	    BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        21.05.2001 добавлен ввод символа кассплана во время транзакции по кассе
        22.08.2001 KOVAL    - Изменена taxdelj на comm-dj
                              обменные операции добавляет статуc "del" при удалении 24.09.01
                              добавлено обновление таблицы CASHOFC для кассового модуля 15.10.01
        15.01.2002          - для Астаны по ARP 150904507 запрет TRX если сумма всех
                              проводок за месяц больше суммы из sysc.sysc = "DBUDZH"
                              исключение - офицеры из sysc.sysc = "DBUDZO"
        16.05.2002 KOVAL    - для MoneyGram добавлена проверка справочника стран
        04.06.2002          - проверка свода кассы при удалении проводки
        22.07.2002          - проверка АРП счетов из arpcon (checkarp.p) - отмена изменений от 15.01.2002
        09.08.2002          - для документов со статусом 'baJ' (для контроля) новый статус не проставится
                              при удалении проводки - удалятся все статусы 'baJ' из substs
        22.08.2002          - обработка платежей k-mobile
        01.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование
        01.10.2002 nataly   - status '5' for trx of type 'account-ARP', 'ARP - account', 'ARP - ARP'
        09.04.2003 sasco    - блокировка сумм по кредиту для клиентских проводок кроме тех, где
                              настройка групп (LGR) /для jou-aasnew.p/ - в sysc.'EXCLGR'
                              контроль и снятие спец. инструкции для контроля - в 2.13
        17.04.2003 sasco    - joudoc.sts = "SPC" для спец. курса обмена валюты
        01.08.2003 sasco    - отправка кассовых валютных проводок юр. лиц
                              перед штампом кассира в 3.1.1 на контроль в 2.7
        03.10.2003 nadejda  - накладывание специнструкции для контроля перенесено в блок, где ставится статус 5 - а то блокировка и при статусе 6 ставилась ;-)
        03.10.2003 nadejda  - делается специнструкция на счет по кредиту в случае проводки ARP -> СЧЕТ для для валютного контроля,
                              сами счета на принадлежность валкону проверяются в вызываемой программе по ГК, записанным в sysc ARPBGL

        13.10.2003 nadejda  - в случае, если удаляется транзакция - поискать эту транзакцию в списке блокированных сумм валютного контроля и убрать пометку о зачислении суммы на счет клиента
        12.11.2003 nadejda  - в случае проводки ARP-> СЧЕТ поискать сумму на счетах валютного контроля и проставить признак снятия суммы (вынесено из jou42-aasnew.p из-за того, что для офицеров без контролеров такие суммы вообще не искались - важно для филиалов)
        24.11.2003 nadejda  - поиск суммы на счетах вал.контроля и признак "разблокировано" сделан для вида ARP -> КАССА
        22.12.2003 nadejda  - запрет на дебетовые операции для тек.счетов, по кредиту которых есть просрочка
        12.01.2004 sasco    - после генерации проводок делается view frame для всех фреймов, а то после ввода дебиторов шапка mainhead`а исчезает
        27.01.2004 sasco    - убрал today для cashofc
        24.02.2004 nadejda  - исправлена сумма в вызове vcjoublk
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        13/05/2004 madiyar  - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25/05/2004 dpuchkov - добавил возможность контроля транзакций юр лиц в пользу юр лиц.
        26/05/2004 dpuchkov - перекомпиляция.
        27/05/2004 dpuchkov - изменение возможности контроля транзакций путём отображения Alert-box.
        14/06/2004 dpuchkov - добавил завершение обменной операции с проставлением льготного курса равного предыдущему
                              в случае если во время транзакции курсы валют были изменены ТЗ 874.
        16/06/2004 dpuchkov - добавил проверку срока действия доверенности.
        02/08/2004 recompile
        06.08.2004 saltanat - при статусе cursts: "bac" убрала необходимость вторичного контроля ст.менеджером
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        17.01.2005 dpuchkov - сделал возможным снятие комиссии если "Касса в пути"
        02.03.2005 dpuchkov - если код комиссии 444 и Счет->Касса то комиссия 0.1% (ТЗ 1385)
        25.03.2005 saltanat - поменяла местами расположение вызываемых процедур при удалении транзакции.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
        11.07.2005 dpuchkov- добавил формирование корешка
        02.08.2005 dpuchkov- добавил формирование корешка для РКО-шек
        10.08.2005 Ten - вернул необходимость вторичного контроля ст.менеджером
        12.08.2005 dpuchkov - добавил отображение корешков в субботу
        06.02.2006 marinav - при операции счет-счет добавлена возможность оплаты за филиалы
        08.02.2006 marinav - при печати ордера анализ оплаты за филиал.
        20/02/2006 nataly - автоматически проставляется код доходов-расходов по коду тарифа
        30.03.2006  nataly - создается спец интструкция по неснижаемому остатку для проводок СЧЕТ->СЧЕТ для ФЛ
        06.04.2006 nataly - добавила проверку, является ли клиент сотрудником банка. Если да, то сумму не блокировать (cif.mname = 'EMP')
        27/04/2006 nataly  - добавлена проверка на исключения по коду 193,180/181
        22.05.06 marinav - у юр лиц комиссию за обнал снимать всегда
        13.06.2006 dpuchkov - добавил проверку на случай если курсы валют равны нулю
        03.07.2006 dpuchkov - добавил savelog для курсов равных 0.
        07.07.2006 dpuchkov - добавил ещё savelog для поиска ошибки в случае если курсы равны 0.
        24.07.2006 tsoy     - не вызывается mob333jou.i в связи с закрытием счета
        10.01.2008 id00004  - перенес счета из sysc в код программы
        19/03/2009 galina - добавила валютный контроль платежей нерезидентов и платежей в валюте
        14/08/2009 madiyar - при наличии просрочки по кредиту расходная операция разрешается, если совершается перенос на другой счет этого же клиента
        03.09.09 marinav - льготный курс берется из таблички льготных курсов
        30/12/2009 madiyar - убрал проверку наличия просроченной задолженности по кредиту
        25.01.10   marinav - корешок печатать для всех филиалов
        25/01/2010 galina - запретила обмен ин.валюты на ин.валюту в обменных операциях
        30/03/2010 galina - обработка для фин.мониторинга согласно ТЗ 623 от 19/02/2010
        01/04/2010 galina - инкассация собственных средств банка
        05.04.10 marinav контроль расходных кассовых операций физ лиц более 5000 долл
        14.04.10 marinav контроль расходных кассовых операций физ лиц более 5000 долл после проводки
        21/04/2010 madiyar - финмон
        09.06.10 marinav - сумма контроля снижена до 1000 долл
        22.06.2010 marinav - убрана комиссия за обнал
        23/06/2010 galina - берем ФИО ИП из признака chif в sub-cod
        24/06/2010 galina - добавила определение страны разиденства для нерезидента
        03/07/2010 galina - поправила declcparam
        15/07/2010 galina - передаем ОКПО филиала
        18/11/2010 madiyar - частично отключаем фин. мониторинг (пока только закомментил, на всякий случай)
        23/11/2010 madiyar - запрос заполнения мини-карточки только при обмене более USD10,000 и переводе без открытия счета более USD1,000
        05.01.2011 marina  - в контроль по депозитам добавлены группы а28 а29 а30
        09.02.2011 Luiza  -  добавила режим поиска клиента в on help .....
        14.04.2011 ruslan - добавил печать платежного поручения.
        10.05.2011 aigul - добавила оповещение менеджеров при поступлении денег на заблокированные счета
        20.05.2011 evseev - в контроль по депозитам добавлены группы а22 а23 а24
        07.06.2011 aigul - проверка срока дейсвтия УЛ
        20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
        23/07/2011 madiyar - добавил по кассе счет 100500, обработка функции csobmen
        21.07.2011 Luiza  - если программа jou_main вызывается при g-fname = "a_cas1" или "a_cas2" или "a_cas3" значения полей db_com и cr_com
                        определются автоматически без возможности выбора из выпадающего списка(ТЗ 880).
        21.07.2011 Luiza - (ТЗ 901) если средств на счете клиента при пополнении недостаточно, тo проводка для снятия комиссии
                        должна создаться в момент акцепта кассира суммы пополнения счета клиента в программе x1-cash.p.
                        в поле joudoc.vo сохраняем все параметры для транзакции проводки на сумму комиссии.
        19/08/2011 madiyar - ЭК
        26/09/2011 Luiza (ТЗ 901)
        17/11/2011 evseev - переход на ИИН/БИН. Кр и Др вывод бин у счетов
        24/11/2011 evseev - ТЗ-1208 отправка уведомлений
        25/11/2011 evseev - ТЗ-1208 отправка уведомлений. дополнение условия
        28/11/2011 evseev - ТЗ-1208 отправка уведомлений менеджеру
        30/11/2011 evseev - удаление изменений за 24/11/2011 25/11/2011 28/11/2011. Из-за переноса кода в trxgen0.p
        30/11/2011 Luiza  - при удалении транзакции, удаляем запись из bxcif--если комиссия была записана в долг
        06.12.2011 aigul - убрала рассылку
        13.01.2012 damir - добавил keyord.i, printord.p
        19/01/2012 evseev - перекомпиляция
        23.01.2012 damir - поставил печать ордеров на лазерный после штампа проводки.
        25.01.2012 damir - перекомпиляция.
        05.03.2012 damir - убрал printord.p.
        06.03.2012 damir - вернул printord.p...
        07.03.2012 damir - добавил входной параметр передаваемый в printord.p.
        13.03.2012 damir - добавил возможность печати на матричный принтер пользователей которые есть в printofc.
        25/04/2012 dmitriy - заблокировал возможность выбора 1.Касса-2.Счет или 2.Счет-1.Касса
        18.05.2012 aigul - блокировка суммы - тз962
        25.09.2012 dmitriy - при удалении транзакции возврат чека в список неиспользованных
        27/09/2012 dmitriy - измененил сообщение по удалению/восстановлению чеков
        02/01/2013 madiyar - добавил v-iin
*/


{mainhead.i}
{yes-no.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{comm-txb.i}
{get-dep.i}
{findstr.i}
{kfm.i "new"}
{chbin.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

define var seltxb as int.
/*nataly*/
def var v-tarif as char no-undo.
def var v-dep as char no-undo.
def var v-code as char no-undo.
def var v-gl like jl.gl no-undo.
def buffer bjl for jl.
/*nataly*/

def var v-our as logical init false no-undo.
def var v-sotr as logical init false no-undo.

define new shared buffer bcrc for crc.
define new shared buffer ccrc for crc.


def new shared var v-crclgt as decimal.
def new shared var v-dateb as date.
def new shared var v-lgcurs as logical init False.

def var v-cif like cif.cif.

def var v-errmsg as char no-undo.
def var v-nomer as char no-undo.
if g-fname = "csobmen" then do:
    find first csofc where csofc.ofc = g-ofc no-lock no-error.
    if avail csofc then v-nomer = csofc.nomer.
    else do:
        message "Нет привязки к ЭК!" view-as alert-box error.
        return.
    end.
end.

 /* Luiza ----------------------------------------------------------------*/
def var v-ll as char init "".
def var v-ek as integer no-undo.
def new shared var v-arp_ek as char no-undo.
v-ek = 1.
if g-fname = 'a_cas1' or g-fname = 'a_cas2' or g-fname = 'a_cas3' then do:
    v-ll = g-fname.
    g-fname = "fofc".
    run sel2 ("Выберите :", " 1. Касса (100100) | 2. Электронный кассир (100500) | 3. Выход ", output v-ek).
    if (v-ek < 1) or (v-ek > 2) then return.
    if v-ek = 2 then do:
        find first csofc where csofc.ofc = g-ofc no-lock no-error.
        if avail csofc then v-nomer = csofc.nomer.
        else do:
            message "Нет привязки к ЭК!" view-as alert-box error.
            return.
        end.
    end.
 end.
/*-----------------------------------------------------------------------*/


define button b1 label "НОВЫЙ/ПОИСК".
define button b2 label "ТРАНЗАКЦИЯ".
define button b3 label "ОРДЕР (Б)".
define button b4 label "ОРДЕР (K)".
define button b5 label "УДАЛИТЬ".
define button b6 label "СТАТУС".
define button b7 label "СПРАВ.".
define button b8 label "ПЛАТЕЖ. ПОРУЧ.".

def var nalgl like gl.gl no-undo.
def var naldes as cha no-undo.
def var v-acc as log init false no-undo.
def var v-cifname like cif.name no-undo.

define frame a2
    b1 b2 b3 b4 b5 b6 b7 b8
    with side-labels row 3 centered no-box.


define new shared variable s-aaa   like aaa.aaa.
define new shared variable s-jh    like jh.jh label "TRX#".

define variable jou_prog as character NO-UNDO.
define variable jou_p   as character NO-UNDO.
define variable com_tmpl as character NO-UNDO.
define variable vou_tmp as character NO-UNDO.
define variable d_combo as character NO-UNDO.
define variable c_combo as character NO-UNDO.
define variable m_combo as character NO-UNDO.
define variable i       as integer format "9" no-undo.
define variable quest   as logical format "Да/Нет" no-undo.
define variable exist   as logical no-undo.

define new shared variable jou     as character .
define new shared variable v_doc   like joudoc.docnum.
define new shared variable loccrc1 as character format "x(3)".
define new shared variable loccrc2 as character format "x(3)".
define new shared variable f-code  like crc.code.
define new shared variable t-code  like crc.code.

define variable v-cash   as logical no-undo.
define variable vvalue as character NO-UNDO.
define variable fname as character NO-UNDO.
define variable lname as character NO-UNDO.
define variable crccode like crc.code NO-UNDO.
define variable cardsts as character NO-UNDO.
define variable cardexp as character NO-UNDO.
define variable card_dt as character NO-UNDO.

define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable vdel    as character initial "^" no-undo.
define variable vparam  as character no-undo.
define variable templ   as character no-undo.
define variable jparr   as character format "x(20)" no-undo.

define variable pbal     like jl.dam no-undo.   /*Full balance*/
define variable pavl     like jl.dam no-undo.   /*Available balnce*/
define variable phbal    like jl.dam no-undo.   /*Hold balance*/
define variable pfbal    like jl.dam no-undo.   /*Float balance*/
define variable pcrline  like jl.dam no-undo.   /*Credit line*/
define variable pcrlused like jl.dam no-undo.   /*Used credit line*/
define variable pooo     like aaa.aaa no-undo.

define variable j       as integer no-undo.
define variable contrl  as logical no-undo.
define variable yn      as logical no-undo.

define variable a   as decimal format "zzz,zzz,zzz,zzz.99" no-undo.
define variable s   as decimal format "zzz,zzz,zzz,zzz.99" no-undo.
define variable ds  as decimal no-undo.
define variable eps as decimal decimals 4 initial 0.001 no-undo.
define variable hh  as decimal decimals 4 format "-zzz,zzz.9999" no-undo.
define variable dsnal  as decimal no-undo.
define variable vgl     like gl.gl no-undo.
define variable vdes    as character NO-UNDO.

def var v-sum as decimal no-undo.
def var v-sumlim as decimal no-undo.
def var v-nal like trxbal.dam no-undo .
def var v9-nal like trxbal.dam  no-undo.
def var v-sumctrl as decimal no-undo.

def new shared var vrat as deci decimals 2 .
def var otv as log init 'false' no-undo.
def var d_rnn as char no-undo.

def var c1 as char extent 15 no-undo.
def var i1  as integer no-undo.
def buffer d-ofc for ofc .
def buffer b-aaa for aaa .

/*** KOVAL for MoneyGram ***/
define variable cr-MnG   as character init '088076115' no-undo.
define variable db-MnG   as character init '188076015' no-undo.
define variable tmp-MnG  as character init ? no-undo.
/*** KOVAL for MoneyGram ***/

/* sasco for KMobile */
define var v-phones as char format "x(75)" NO-UNDO.
define var i-phone as int init 0 NO-UNDO.
define var jou_sts as char NO-UNDO.

define variable v-sts like jh.sts  no-undo.
/*galina*/
def var v-monamt as deci no-undo.
def var v-monamt2 as deci no-undo.
def buffer b-jl for jl.
def buffer bb-jl for jl.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-num as inte no-undo.
def var v-operId as integer no-undo.
def var v-bdt as char no-undo.
def var v-bplace  as char no-undo.
def var v-kfm as logi no-undo init no.
def var v-numprt as char no-undo.
def var v-mess as integer no-undo.

def var v-dtbth as date no-undo.
def var v-regdt as date no-undo.
def var v-rnn as char no-undo.
def var v-iin as char no-undo.
def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-addr as char no-undo.
def var v-country2 as char.
def var v-mail as char no-undo.

/**/

/*ja on 16/05/2001 ****************************************************/
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.

def var templ-com as char no-undo.
def var templ-nal as char no-undo.
def var vdummy as char no-undo.
def var OK as logi no-undo.
def var v-blkacc as char no-undo.

def var v-knpval as char no-undo.
def var v-secval as char no-undo.
def var v-jss as char format "x(12)" no-undo.
def var v-njss as char no-undo.
def var v-nname as char no-undo.
def var v-nacc as char no-undo.
def var v-achk as logi no-undo.

define variable v-dbtval as decimal no-undo.
define variable v-crtval as decimal no-undo.
define new shared variable l-dovperson as logical init False.

define variable v-dovpersonname  as character no-undo.
define variable v-dovpersonpass  as character no-undo.
define buffer b-ofc for ofc.
define var vnm as logical no-undo.

define var v-chk as char no-undo.
define var v-ant as char no-undo.
def var del-page as logi  format "Да/Нет".

/* help for cif */
DEFINE VARIABLE phand AS handle.
DEFINE VARIABLE v-cif1 AS char.
DEFINE QUERY q-help FOR aaa, lgr.
DEFINE BROWSE b-help QUERY q-help
       DISPLAY aaa.aaa label "Счет клиента " format "x(20)" aaa.cr[1] - aaa.dr[1] label "доступный остаток" format "-z,zzz,zzz,zzz,zzz.99"
       aaa.sta label "Статус" format "x(1)" aaa.crc label "Вл " format "z9" lgr.des label "описание" format "x(20)"
       WITH  15 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 25 width 89 NO-BOX.
/*  help for cif */


find sysc where sysc.sysc= "ANT" no-lock no-error.
if avail sysc then v-ant = sysc.chval.

/*End of ja on 16/05/2001 **********************************************/

{mframe.i "new shared"}

on help of v_doc in frame f_main do:
    if v-ll = "" then run help-joudoc.
    else run help-joudoc3(v-ll).
end.
/*  help for cif */
on help of joudoc.dracc in frame f_main do:
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" /* and aaa.crc = 1*/ no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" /* and aaa.crc = 1*/ no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            joudoc.dracc = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            joudoc.dracc = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        end.
        displ  joudoc.dracc with frame f_main.
    end.
    DELETE PROCEDURE phand.
end.
/*  help for cif */
on help of joudoc.cracc in frame f_main do:
    hide frame f-help.
    v-cif1 = "".
    run h-cif PERSISTENT SET phand.
    v-cif1 = frame-value.
    if trim(v-cif1) <> "" then do:
        find first aaa where aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" /* and aaa.crc = 1*/ no-lock no-error.
        if available aaa then do:
            OPEN QUERY  q-help FOR EACH aaa where  aaa.cif = v-cif1 and length(aaa.aaa) >= 20 and aaa.sta <> "C" and aaa.sta <> "E" /* and aaa.crc = 1*/ no-lock,
                        each lgr where aaa.lgr = lgr.lgr and lgr.led <> "ODA" no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            joudoc.cracc = aaa.aaa.
            hide frame f-help.
        end.
        else do:
            joudoc.cracc = "".
            MESSAGE "СЧЕТ КЛИЕНТА НЕ НАЙДЕН.".
        end.
        displ  joudoc.cracc with frame f_main.
    end.
    DELETE PROCEDURE phand.
end.
/*  help for cif */

on help of joudoc.drcur in frame f_main do:
    run help-crc1.
end.
on help of joudoc.crcur in frame f_main do:
    run help-crc1.
end.
on return of db_com or return of cr_com or return of com_com in frame f_main do:
    apply "go" to frame f_main.
end.

on any-printable of db_com do:
    do j = 1 to db_com:num-items:
       if db_com:entry(j) begins last-event:function then do:
          db_com:screen-value = db_com:entry(j).
          leave.
       end.
    end.
    if j > db_com:num-items then bell.
end.

on any-printable of cr_com do:
    do j = 1 to cr_com:num-items:
       if cr_com:entry(j) begins last-event:function then do:
          cr_com:screen-value = cr_com:entry(j).
          leave.
       end.
    end.
    if j > cr_com:num-items then bell.
end.

on any-printable of com_com do:
    do j = 1 to com_com:num-items:
       if com_com:entry(j) begins last-event:function then do:
          com_com:screen-value = com_com:entry(j).
          leave.
       end.
    end.
    if j > com_com:num-items then bell.
end.


/** N…KO№AIS **/
on choose of b1 in frame a2 do:

    do transaction:
        v-kfm = no.
        s-jh  = ?.
        v_doc = "".
        clear frame f_main.
        update v_doc with frame f_main.
        if v_doc eq "" then do:
            v_doc = m_sub.
            find nmbr where nmbr.code eq "JOU" no-lock no-error.
            v_doc = v_doc + string (next-value (journal), "999999") + nmbr.prefix.

            exist = false.

            run chgsts(m_sub, v_doc, "new").

            display v_doc with frame f_main.
        end.
        else do:
            find joudoc where joudoc.docnum eq v_doc no-lock no-error.
            if not available joudoc then do:
                message "ДОКУМЕНТ НЕ НАЙДЕН.".
                pause 3.
                undo, return.
            end.

            exist = true.
            display joudoc.jh  with frame f_main.

            if joudoc.drcur ne 0 then do:
                find crc where crc.crc eq joudoc.drcur no-lock no-error.
                display crc.des with frame f_main.
            end.
            if joudoc.crcur ne 0 then do:
                find bcrc where bcrc.crc eq joudoc.crcur no-lock no-error.
                display bcrc.des with frame f_main.
            end.

            find jounum where jounum.num eq joudoc.dracctype no-lock no-error.
            if available jounum then db_com = jounum.num + "." + jounum.des.

            find jounum where jounum.num eq joudoc.cracctype no-lock no-error.
            if available jounum then cr_com = jounum.num + "." + jounum.des.

            d_cif = "". c_cif = "".
            dname_1 = "". dname_2 = "". dname_3 = "".
            cname_1 = "". cname_2 = "". cname_3 = "".
            if joudoc.dracc ne "" then do:
                find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
                if available aaa then do:
                    find cif where cif.cif eq aaa.cif no-lock no-error.
                    d_cif = cif.cif.
                    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                    dname_1 = substring(v-cifname,  1, 38).
                    dname_2 = substring(v-cifname, 39, 38).
                    if v-bin then  dname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
                    else dname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
                end.
                find arp where arp.arp eq joudoc.dracc no-lock no-error.
                if available arp then dname_1 = arp.des.
            end.

            if joudoc.cracc ne "" then do:
                find aaa where aaa.aaa eq joudoc.cracc no-lock no-error.
                if available aaa then do:
                    find cif where cif.cif eq aaa.cif no-lock.
                    c_cif = cif.cif.
                    v-cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
                    cname_1 = substring(v-cifname,  1, 38).
                    cname_2 = substring(v-cifname, 39, 38).
                    if v-bin then cname_3 = substring(v-cifname, 77, 17) + " (" + cif.bin + ")".
                    else cname_3 = substring(v-cifname, 77, 17) + " (" + cif.jss + ")".
                    v-njss = cif.jss .
                    v-nname = aaa.name.
                    v-nacc = aaa.aaa.
                end.
                find arp where arp.arp eq joudoc.cracc no-lock no-error.
                if available arp then cname_1 = arp.des.
            end.

            display joudoc.dramt joudoc.dracc joudoc.drcur joudoc.cramt
                joudoc.cracc joudoc.crcur loccrc1 loccrc2 joudoc.brate
                joudoc.bn joudoc.remark[1] joudoc.chk joudoc.srate joudoc.sn
                joudoc.remark[2] joudoc.rescha[3] db_com cr_com joudoc.num d_cif dname_1
                dname_2 dname_3 c_cif cname_1 cname_2 cname_3
                with frame f_main.
            color display input dname_1 dname_2 dname_3 cname_1 cname_2 cname_3 with frame f_main.

            if joudoc.comcode ne "" then do:
                find jounum where jounum.num eq joudoc.comacctype no-lock no-error.
                if available jounum then com_com = jounum.num + "." + jounum.des.

                if joudoc.comcur ne 0 then do:
                    find ccrc where ccrc.crc eq joudoc.comcur no-lock no-error.
                    display ccrc.des with frame f_main.
                end.

                find tarif2 where tarif2.num + tarif2.kod eq joudoc.comcode and tarif2.stat = 'r' no-lock no-error.
                display joudoc.comcode tarif2.pakalp com_com joudoc.comacc
                        joudoc.comcur joudoc.comamt
                        joudoc.nalamt
                        with frame f_main.
            end.
            else do:
                display joudoc.comcode "" @ tarif2.pakalp com_com
                    "" @ ccrc.des joudoc.comacc joudoc.comcur joudoc.comamt
                 joudoc.nalamt  with frame f_main.
            end.

            if g-ofc ne joudoc.who then do:
                message "Не ваш документ".
                v_doc = "".
                pause.
                clear frame f_main.
                return.
            end.
        end.

        /***  ADD,  EDIT  **/
        if exist then do:
            if joudoc.jh ne ? then return.

            find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error no-wait.
            if locked joudoc then do:
                message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ.".
                pause 3.
                undo, return.
            end.
        end.

        do on endkey undo, return:
            if not exist then do:
                create joudoc.
                joudoc.docnum = v_doc.
                joudoc.whn    = g-today.
                joudoc.who    = g-ofc.
                joudoc.tim    = time.
            end.
            update joudoc.num with frame f_main.
     /* Luiza ----------------------------------------------------------------*/
            if v-ll = 'a_cas1' or v-ll = 'a_cas2' or v-ll = 'a_cas3' then do:
                if v-ll = 'a_cas1' then do:
                    db_com = "1.Касса".
                    cr_com = "2.Счет".
                end.
                if v-ll = 'a_cas2' then do:
                    db_com = "2.Счет".
                    cr_com = "1.Касса".
                end.
                if v-ll = 'a_cas3' then do:
                    db_com = "2.Счет".
                    cr_com = "2.Счет".
                    joudoc.comcode = "302".
                    com_com = "2.Счет".
                    joudoc.comacc = joudoc.dracc.
                    joudoc.comcur = joudoc.drcur.
                    joudoc.comamt = 0.
                end.
                displ db_com with frame f_main.
                displ cr_com with frame f_main.
                assign db_com.
                assign cr_com.

            end.
            else do:
                update db_com with frame f_main.
                update cr_com with frame f_main.
                assign db_com.
                assign cr_com.
            end.
/*---------------------------------------------------------------------------------*/

            if cr_com:screen-value begins "5" then do:
                joudoc.dramt = 0 .
                joudoc.cramt = 0 .
                joudoc.cracc = "".
                c_cif = "      " .
                cname_1 = "".
                cname_2 = "".
                cname_3 = "".
                display cname_1 cname_2 cname_3 joudoc.dramt joudoc.cracc c_cif joudoc.cramt with frame f_main.
                pause 0.
            end.
            find jounum where jounum.num eq substring (db_com, 1, 1) no-lock no-error.
            joudoc.dracctype = jounum.num.
            find jounum where jounum.num eq substring (cr_com, 1, 1) no-lock no-error.
            joudoc.cracctype = jounum.num.
        end.

        find first jouset where jouset.drtype eq substring(db_com,3) and jouset.crtype eq substring(cr_com,3) and jouset.fname eq g-fname no-lock no-error.
        if not available jouset or jouset.proc eq "" then do:
            message "РЕЖИМ НЕ РАБОТАЕТ.".
            pause 3.
            undo, return.
        end.
                else if (jouset.drnum = "1" and jouset.crnum = "2") or (jouset.drnum = "2" and jouset.crnum = "1") then do:
            message skip "РЕЖИМ " + jouset.drnum + "-" + jouset.crnum + " ЗАБЛОКИРОВАН" view-as alert-box title " Внимание! ".
            undo, return.
        end.

        jou_prog = jouset.proc.
        hide frame a2.
        if v-ll = 'a_cas3' then run jdd_jou1. /* Luiza для платежей счет-> счет без комиссии   */
        else run value (jou_prog).

        if v-ek = 2 then do:
            v-arp_ek = ''.
            for each arp where arp.gl = 100500 and arp.crc = joudoc.drcur no-lock:
                find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
                if avail sub-cod then v-arp_ek = arp.arp.
            end.
            if v-arp_ek = '' then do:
                message "Не настроен счет ЭК " + v-nomer + " в валюте " + string(joudoc.drcur) + " !" view-as alert-box title " ОШИБКА ! ".
                return.
            end.
        end.

        view frame a2.

        if keyfunction (lastkey) eq "end-error" then do:
            if joudoc.dramt eq 0 and joudoc.cramt eq 0 then do:
                run Delete_status.
                delete joudoc.
            end.
        end.
        else do:
            /* sasco - for futher control of ARP from arpcon */
            find sysc where sysc.sysc = "ourbnk" no-lock no-error.
            if avail sysc and  sysc.chval  = 'TXB00' then v-our = true.
            /* найдем arpcon со счетом по дебету */
            find arpcon where arpcon.arp = joudoc.dracc and
                              arpcon.sub = 'jou' and
                              arpcon.txb = sysc.chval
                              no-lock no-error.

            if avail arpcon then do:
                find first substs where substs.sub = 'jou' and substs.acc = joudoc.docnum and substs.sts = arpcon.new-sts no-lock no-error.
                if not avail substs then run chgsts(m_sub, v_doc, "new").
            end.
            else run chgsts(m_sub, v_doc, "new").
        end.

        /*if comm-cod() = 0 then  do:*/
        if g-fname matches "*obmen*" and v-lgcurs then do:
            find current joudoc exclusive-lock no-error.
            joudoc.sts = "LGC".
        end.
        /*Проверка УЛ*/
        if (joudoc.dracctype = "2" and joudoc.cracctype = "1") then do:
            run check_ul(joudoc.dracc).
        end.
        if(joudoc.dracctype = "1" and joudoc.cracctype = "2") then do:
            run check_ul(joudoc.cracc).
        end.
        /**/
        release joudoc.
    end. /* transaction */
end. /* on choose of b1 in frame a2 */


/** TRANSAKCIJA **/
on choose of b2 do:
    if v_doc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v_doc no-lock no-error.
    if joudoc.jh ne ? then do:
        message "Транзакция уже проведена.".
        pause 3.
        undo, return.
    end.
    if joudoc.whn ne g-today then do:
        message substitute ("Документ создан &1 .", joudoc.whn).
        pause 3.
        undo, return.
    end.
    if joudoc.who ne g-ofc then do:
        message substitute ("Документ создан &1 .", joudoc.who).
        pause 3.
        undo, return.
    end.
    if joudoc.dramt lt 0 or joudoc.cramt lt 0 or joudoc.comamt lt 0 then undo, return.
    /*Проверка на неверные курсы валют*/
    if joudoc.remark[1] begins "Обмен валюты" then do:
       if joudoc.srate = 0 and joudoc.brate = 0 then do:
          message "Курсы валют равны 0. Продолжение невозможно!" view-as alert-box.
          return.
       end.
    end.
    /*Проверка на неверные курсы валют*/

    /* 17/07/2002, sasco - check ARP amounts for control */
    do transaction:
        run checkarp (joudoc.docnum).
    end. /* transaction */
    if return-value = 'no' then return.
    if return-value = 'con' then do:
        message "Документ должен пройти дополнительный контроль!" view-as alert-box.
        return.
    end.

    if g-fname matches '*obmen*' then do:
        /*galina запретить обмен ин.валюты на ин.валюту*/
        if joudoc.dracctype = "1" and joudoc.cracctype = "1" then do:
            if joudoc.crcur <> 1 and joudoc.drcur <> 1 then do:
                message "Данная операция невыполнима!~nНеверный код валюты" view-as alert-box title " ВНИМАНИЕ ! ".
                return.
            end.
        end.

        if joudoc.sts = "LGC" then do:
            v-lgcurs = True.
            find cursts where cursts.sub = m_sub and cursts.acc = v_doc use-index subacc no-lock no-error.
            if cursts.sts = "new" then do:
                message "Внимание! Платеж должен пройти контроль ст. менеджером в 2.4.1.1" view-as alert-box title ' '.
                return.
            end.
        end.
        else v-lgcurs = False.
    end.

    find first jouset where jouset.drnum = joudoc.dracctype and jouset.crnum = joudoc.cracctype no-lock no-error.
    if not available jouset or jouset.proc = "" then do:
        message "РЕЖИМ НЕ РАБОТАЕТ.".
        pause 3.
        undo, return.
    end.

    /*------------------------------09.09.03--------------------------*/
    jou_p = substring (jouset.proc, 1, 4) .
    if g-fname matches '*obmen*' and jouset.proc <> 'jaa_jou' then do:
        jou_p = "jab_".
        if g-fname = "csobmen" then jou_p = "jee_".
    end.
    /*------------------------------24.09.01--------------------------*/
    if joudoc.bas_amt = "D" then run amt_ctrl (input joudoc.dramt, input joudoc.drcur, output contrl).
    else
    if joudoc.bas_amt = "C" then run amt_ctrl (input joudoc.cramt, input joudoc.crcur, output contrl).

    find cursts where cursts.sub = m_sub and cursts.acc = v_doc use-index subacc no-lock no-error.
    if contrl and cursts.sts <> "con" and cursts.sts <> "bac" then do:
        message "Не пройден вторичный контроль (в 2.4.1.1). " + "Отправить на контроль ?" update yn.
        if yn then do:
            run chgsts(m_sub, v_doc, "apr").
            return.
        end.
        else return.
    end.

    /*555 код для РКЦ*/
    def buffer b-cifmko for cif.
    define frame f_mko
        v-cif      label "Введите CIF-код клиента"
        with row 8 col 25 overlay side-label.

    if joudoc.cracc = "000904100"  or joudoc.cracc = "000904401" then do:
        if (joudoc.dracctype = "1" and joudoc.cracctype = "4") then do:
            update v-cif with frame f_mko.
            find last b-cifmko where b-cifmko.cif = v-cif no-lock no-error.
            if not avail b-cifmko then do:
                message "CIF-код клиента не найден, продолжение невозможно!" view-as alert-box.
                hide frame f_mko.
            end.
        end.
    end.

    /*код для МКО*/
    if joudoc.cracc = "150904610"  or joudoc.cracc = "KZ14470192867A000216" or joudoc.cracc = "KZ47470192867A000204" or joudoc.cracc = "KZ04470192867A000202" then do:
        if (( joudoc.dracctype = "1" or joudoc.dracctype = "4") and joudoc.cracctype = "4") then do:
            update v-cif with frame f_mko.
            /*
            find last b-cifmko where b-cifmko.cif = v-cif no-lock no-error.
            if not avail b-cifmko then do:
                message "CIF-код клиента не найден, продолжение невозможно!" view-as alert-box.
                hide frame f_mko.
                return.
            end.
            */
        end.
    end.

    /*galina валютный контроль*/
    def var result as integer.
    def var v_dres as integer.
    def var v_cres as integer.

    if joudoc.dracctype = "2" and joudoc.cracctype = "2" then do:
        if joudoc.rescha[2] = '' then do:
            run chk_valcon(v_doc, output v_dres, output v_cres, output result).
            if result > 0 then do:
                message " Документ должен проконтролировать валютный контроль (в 9.11)" view-as alert-box title " ВНИМАНИЕ ! ".
                return.
            end.
        end.

    end.

    if joudoc.dramt > 0 then do:
        if g-fname matches '*obmen*' then do:
            v-dbtval = joudoc.brate.
            v-crtval = joudoc.srate.
            if v-lgcurs = True then do:
                otv = True.
                if vrat = 0 then do:
                    if joudoc.drcur = 1 then vrat = joudoc.srate.
                    else vrat = joudoc.brate.
                end.
                /* sasco - запрос на спец. курс */
                if vrat ne 0 then if yes-no ("", "Обмен по спец. курсу?") then do transaction:
                    find current joudoc exclusive-lock no-error.
                    joudoc.sts = "SPC".
                    find current joudoc no-lock no-error.
                end. /* transaction */
            end.
            jou_prog = jou_p + "tmpl".
            run value (jou_prog)(input joudoc.bas_amt, output vparam, output templ).
        end.
        else do.
            jou_prog = substring (jouset.proc, 1, 4) + "tmpl".
            run value (jou_prog)(input joudoc.bas_amt, output vparam, output templ).
        end.
    end.



    /***************************************************************************
        Added by ja on 16/05/2001 to evaluate templates for commissions
        for operation and "obnalichka" as applicable. It is done because
        code manual entry should be outside the transaction block.
    ****************************************************************************/
    empty temp-table w-cods.

    if joudoc.dramt > 0 then run Collect_Undefined_Codes(templ,"payment").

    if joudoc.comamt ne 0 then do:
        find first jouset where jouset.drnum eq joudoc.comacctype and jouset.crtype eq "" and jouset.fname eq g-fname no-lock no-error.
        com_tmpl = substring (jouset.proc, 1, 4) + "tcom".
        run value(com_tmpl)(output vdummy, output templ-com).
        run Collect_Undefined_Codes(templ-com,"tcom").
    end.

    if joudoc.nalamt ne 0 then do:
        find first jouset where jouset.drnum eq joudoc.comacctype and jouset.crtype eq "" and jouset.fname eq g-fname no-lock no-error.
        com_tmpl = substring (jouset.proc, 1, 4) + "ncom".
        run value(com_tmpl)(output vdummy, output templ-nal).
        run Collect_undefined_codes(templ-nal,"ncom").
    end.

    run Parametrize_Undefined_Codes(output OK).
    if not OK then do:
        bell.
        message "Не все коды введены! Транзакция не будет создана!" view-as alert-box.
        undo, return.
    end.

    {jm_finmon.i}

    /* Проверка срока действия доверенности */
    if joudoc.dracctype = "2" and joudoc.cracctype = "1" then do:
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if available aaa then find cif where cif.cif eq aaa.cif no-lock no-error.
    end.
    if joudoc.dracctype = "1" and joudoc.cracctype = "2" then do:
        find aaa where aaa.aaa eq joudoc.cracc no-lock no-error.
        if available aaa then find cif where cif.cif eq aaa.cif no-lock no-error.
        if avail cif and cif.mname = 'EMP' then v-sotr = true. else v-sotr = false. /*nataly*/
    end.

    if ((joudoc.dracctype = "1" and joudoc.cracctype = "2") or (joudoc.dracctype = "2" and joudoc.cracctype = "1") ) and cif.badd[1] <> "" and cif.badd[2] <> "" and cif.type = "p" then do:
        message " Операция по счету проводится владельцем счета? " view-as alert-box buttons yes-no title "" update btn1 as logical.
        if btn1 then l-dovperson = False.
        else do:
            l-dovperson = True.
            if g-today > cif.finday then do:
                message "Внимание: Истек срок доверенности." view-as alert-box.
                return.
            end.
        end.
    end.

    /* Запрет транзакций в пользу других юр лиц */
    if joudoc.dracctype eq "1" and joudoc.cracctype eq "2" then do:
        if v-secval <> "9" and v-secval <> ""  then do:
            message " Подтверждаете реквизиты отправителя? ~nНаименование: " + v-nname + "  ~nРНН: " + v-njss + " ~nСчёт: " + v-nacc + "  " view-as alert-box buttons yes-no title ""  update b as logical.
            if not b then do:
                find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = c_cif and sub-cod.d-cod = "secek" and (sub-cod.ccode = "1"  or sub-cod.ccode = "5") no-lock no-error.
                if available sub-cod then do:
                    find sysc where sysc.sysc = 'KNPLST' no-lock no-error.
                    if lookup (v-knpval, sysc.chval) = 0 then do:
                        message "Запрещены платежи наличными от юр. лиц в пользу ~n других юр. лиц." view-as alert-box.
                        return.
                    end.
                end.
            end.
            v-jss = "".
        end.
    end.
    /* Запрет транзакций в пользу других юр лиц */

    /*End of addition on 16/05/2001*********************************************/

    /*** KOVAL for MoneyGram 16/05/2002 ***/
    if joudoc.cracc eq cr-MnG or joudoc.dracc eq db-MnG then do:
        select ccode into tmp-MnG from sub-cod where sub="jou" and acc=v_doc and d-cod='iso3166'.
        if tmp-MnG eq ? or tmp-MnG eq 'msc' then do:
            bell. input clear.
            message "Не заполнен справочник стран! Транзакция не будет создана!" view-as alert-box.
            undo, return.
        end.
        else do:
            find first codfr where codfr.codfr='iso3166' and codfr.code = tmp-MnG no-lock no-error.
            if not avail codfr then do:
                bell. input clear.
                message "Не верно заполнен справочник стран! Транзакция не будет создана!" view-as alert-box.
                undo, return.
            end.
        end.
    end.
    /*** KOVAL for MoneyGram ***/

    quest = false.
    message "Провести транзакцию ? " update quest.
    if not quest then undo, return.

    /* Проверка на неверные курсы валют */
    if joudoc.remark[1] begins "Обмен валюты" then do:
        if joudoc.srate = 0 and joudoc.brate = 0 then run savelog ("zerokurs", joudoc.docnum + "-" + string(joudoc.srate) + " " + string(joudoc.brate)).
    end.
    /* Проверка на неверные курсы валют */

    /* Установка старого курса если курс был изменён */
    if g-fname matches '*obmen*' and vrat = 0 then do:
        find crc where crc.crc eq joudoc.drcur no-lock no-error.
        if v-dbtval <> crc.rate[2] then do:
            message " Внимание: Курс покупки был изменен, оставить предыдущий курс: " + string(v-dbtval) view-as alert-box buttons yes-no title ""  update bs1 as logical .
            if bs1 then do transaction:
                find current joudoc exclusive-lock.
                joudoc.brate = v-dbtval.
                find current joudoc no-lock.
            end. /* transaction */
        end.

        find crc where crc.crc eq joudoc.crcur no-lock no-error.
        if v-crtval <> crc.rate[3] then do:
            message " Внимание: Курс продажи был изменен, оставить предыдущий курс: " + string(v-crtval) view-as alert-box buttons yes-no title ""  update bs2 as logical.
            if bs2 then do transaction:
                find current joudoc exclusive-lock.
                joudoc.srate = v-crtval.
                find current joudoc no-lock.
            end. /* transaction */
        end.
    end.

    /* Проверка на неверные курсы валют */
    if joudoc.remark[1] begins "Обмен валюты" then do:
        if joudoc.srate = 0 and joudoc.brate = 0 then do:
            message "Курсы равны 0. Заново переформируйте jou документ!" view-as alert-box.
            run savelog ("zerokurs", joudoc.docnum + " " + string(joudoc.srate) + " " + string(joudoc.brate)).
            return.
        end.
    end.
    /* Проверка на неверные курсы валют */

    do transaction on error undo, retry :
        s-jh = 0.
        if joudoc.dramt > 0 then do:
            run Insert_Codes_Values("payment", vdel, input-output vparam).
            if otv then run trxgen-obm(templ, vdel, vparam, m_sub, v_doc, output rcode, output rdes, input-output s-jh).
            else run trxgen(templ, vdel, vparam, m_sub, v_doc, output rcode, output rdes, input-output s-jh).

            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            else do:
                def var i_temp_dep as integer.

                if joudoc.cracc = "000904100" or joudoc.cracc = "000904401" then do:
                    i_temp_dep = int (get-dep (g-ofc, g-today)).
                    find first ppoint where ppoint.depart = i_temp_dep no-lock no-error.
                    /*Только Касса -> ARP */
                    if (joudoc.dracctype = "1" and joudoc.cracctype = "4") then do:
                        if joudoc.cracc = "000904100" or joudoc.cracc = "000904401" then do:
                            create lnrkc.
                            if avail ppoint then lnrkc.bank = ppoint.info[3].
                            assign lnrkc.cif  = v-cif
                                   lnrkc.amt  = joudoc.dramt
                                   lnrkc.who  = g-ofc
                                   lnrkc.whn  = g-today
                                   lnrkc.tim  = time.
                            if joudoc.cracc = "000904401" then lnrkc.bn = 1. /*  счет МКО    */
                            if joudoc.cracc = "000904100" then lnrkc.bn = 2. /*  счет БАНКА  */
                            lnrkc.jh = s-jh.
                        end.
                    end.
                end.

                /* КОД ДЛЯ МКО*/
                if joudoc.cracc = "KZ14470192867A000216" or joudoc.cracc = "KZ47470192867A000204" or joudoc.cracc = "KZ04470192867A000202" then do:
                    i_temp_dep = int (get-dep (g-ofc, g-today)).
                    find sysc where sysc.sysc = "ourbnk" no-lock no-error.
                    /*Только Касса -> ARP */
                    if (( joudoc.dracctype = "1" or joudoc.dracctype = "4") and joudoc.cracctype = "4") then do:
                            create lnrkc.
                            assign lnrkc.bank = sysc.chval
                                   lnrkc.cif  = v-cif
                                   lnrkc.amt  = joudoc.dramt
                                   lnrkc.who  = g-ofc
                                   lnrkc.whn  = g-today
                                   lnrkc.tim  = time
                                   lnrkc.bn = 1 /*  счет МКО */
                                   lnrkc.jh = s-jh.
                    end.
                end.
            end.
        end.

        /** komisija **/
        if joudoc.comamt ne 0 then do:
            find first jouset where jouset.drnum eq joudoc.comacctype and jouset.crtype eq "" and jouset.fname eq g-fname no-lock no-error.

            com_tmpl = substring (jouset.proc, 1, 4) + "tcom".

            run value (com_tmpl)(output vparam, output templ).

            run Insert_Codes_Values("tcom", vdel, input-output vparam).

            /*nataly 20/02/2006*/
            v-tarif = joudoc.comcode.
            {j-cods1.i}

            /* Luiza 27.06.2011---если комиссия с счета-клиента---------------------------------------*/
            if joudoc.comacctype  = "2" then do:
                find first aaa where aaa.aaa = joudoc.comacc no-lock no-error.
                if not availabl aaa then do:
                    message "счет комиссии не найден" view-as alert-box error.
                    undo, return.
                end.

                if  aaa.cbal - aaa.hbal < joudoc.comamt and joudoc.dracctype = "1" and joudoc.cracctype = "2" then do:
                    /* если денег на счете недостаточно для оплаты комиссии,
                    проводка комиссии сформируется после акцепта кассира, когда сумма пополнения счета поступит счет клиента.
                    см. программу x1-cash.p */
                    repeat:
                        if index (vparam, "&") <= 0 then leave.
                        if index (vparam, "&") > 0 then do:
                            vparam = substring(vparam,1,index(vparam,"&") - 1) + substring(vparam,index(vparam,"&") + 1,(length(vparam) - index(vparam,"&"))).
                        end.
                    end.
                    find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
                    if available joudoc then joudoc.vo = templ + "&" + vparam + "&" + "jou" + "&" + v_doc. /* в данном поле сохраняем параметры для транзакции проводки комиссии*/
                    else do:
                        message "jou документ не найден".
                        pause.
                        undo, return.
                    end.
                    find current joudoc no-lock no-error.
                end.
                else run trxgen (templ, vdel, vparam, m_sub , v_doc, output rcode, output rdes, input-output s-jh).
            end.
            /*----------------------------------------------------------*/
            else run trxgen (templ, vdel, vparam, m_sub , v_doc, output rcode, output rdes, input-output s-jh).

            {j-cods2.i}
            /*nataly 20/02/2006*/

            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.

        if joudoc.nalamt ne 0 then do:
            find first jouset where jouset.drnum eq joudoc.comacctype and jouset.crtype eq "" and jouset.fname eq g-fname no-lock no-error.
            com_tmpl = substring (jouset.proc, 1, 4) + "ncom".
            run value (com_tmpl)(output vparam, output templ).
            run Insert_Codes_Values("ncom", vdel, input-output vparam).
            run trxgen (templ, vdel, vparam,m_sub, v_doc, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.

        /* sasco - показать все фреймы, которые могли "исчезнуть" */
        view frame mainhead.
        view frame a2.
        view frame f_main.

        if joudoc.dramt = 0 then do:
            for each jl where jl.jh = s-jh.
                jl.rem[1] = jl.rem[1] + " " + (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]).
            end.
        end.

        run chgsts(m_sub, v_doc, "trx").
        pause 1 no-message.
        find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error no-wait.
        joudoc.jh = s-jh.
        display joudoc.jh with frame f_main.
        /*find first aas where aas.aaa = joudoc.cracc no-lock no-error.
        if avail aas then do:
            find first crc where crc.crc = joudoc.crcur no-lock no-error.
            if avail crc then do:
                find first cif where cif.cif = aas.cif no-lock no-error.
                if avail cif then do:
                    for each sysc where sysc.sysc = "bnkadr" no-lock:
                        run mail(entry(5, sysc.chval, "|"), "BANK <abpk@metrocombank.kz>",
                        "Поступление средств на заблокированный счет",
                        "Поступила сумма  " + string(joudoc.cramt) + " " + crc.code + ", " + cif.name,
                        "", "", "").
                    end.
                end.
            end.
        end.*/


        /*galina - копируем заполненные данные по ФМ в реальные таблицы*/
        if v-kfm then run kfmcopy(v-operid,joudoc.docnum,'fm', s-jh).
        /**/

        /*ДОБАВЛЕНО*/
        find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
        if (joudoc.dracctype = "4" and joudoc.cracctype = "4" and (lookup(joudoc.dracc,v-ant) <> 0 or lookup(joudoc.cracc,v-ant) <> 0)) or   (joudoc.dracctype = "2" and joudoc.cracctype = "4" and lookup(joudoc.cracc,v-ant) <> 0) or (joudoc.dracctype = "4" and joudoc.cracctype = "2" and lookup(joudoc.dracc,v-ant) <> 0) or joudoc.dracctype = "1" or joudoc.cracctype = "1" then do:
            find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
            if not avail acheck then do:
                v-chk = "".
                v-chk = string(NEXT-VALUE(krnum)).
                create acheck.
                assign acheck.jh  = string(s-jh)
                       acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
                       acheck.dt = g-today
                       acheck.n1 = v-chk.
                release acheck.
            end.
        end.

        find last b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
        if joudoc.rescha[1] ne "" then do:
            find first aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if avail aaa then do:
                find cif of aaa exclusive-lock no-error.
                if avail cif then assign d_rnn = cif.jss cif.jss = joudoc.rescha[1].
            end.
        end.

        if g-fname = "csobmen" then run vou_100500(2).
        else do:
            find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
            if avail acheck and ((joudoc.dracctype = "4" and joudoc.cracctype = "4" and (lookup(joudoc.dracc,v-ant) <> 0 or lookup(joudoc.cracc,v-ant) <> 0)) or  (joudoc.dracctype = "2" and joudoc.cracctype = "4" and lookup(joudoc.cracc,v-ant) <> 0) or (joudoc.dracctype = "4" and joudoc.cracctype = "2" and lookup(joudoc.dracc,v-ant) <> 0) or (joudoc.dracctype = "1" and joudoc.cracctype <> "1") or (joudoc.cracctype = "1" and joudoc.dracctype <> "1")) then do:
                if joudoc.dracctype = "1" or (joudoc.dracctype = "4" and lookup(joudoc.dracc,v-ant) <> 0) then do:
                    if v-noord = no then run vou_bank2(2,1, joudoc.info).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank2(2,1, joudoc.info).
                    end.
                end.
                else
                if joudoc.cracctype = "1" or (joudoc.cracctype = "4" and lookup(joudoc.cracc,v-ant) <> 0) then do:
                    if v-noord = no then run vou_bank2(2,2, joudoc.info).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank2(2,2, joudoc.info).
                    end.
                end.
                else do:
                    if v-noord = no then run vou_bank(2).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank(2).
                    end.
                end.
            end.
            else do:
                if v-noord = no then run vou_bank(2).
                else do:
                    find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                    lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                    if avail printofc then run vou_bank(2).
                end.
            end.
        end.

        if joudoc.rescha[1] ne "" then do:
            find first aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if avail aaa then do:
                find cif of aaa exclusive-lock no-error.
                if avail cif then cif.jss = d_rnn.
            end.
        end.

        find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
        v-cash = false. v-acc = false.
        for each jl where jl.jh eq s-jh no-lock:
            if (jl.gl = sysc.inval) or (jl.gl = 100500) then v-cash = true.
        end.

        /*nataly 23.11.01  - status '5' for trx of type 'account-account'*/
        /*nataly  01.10.02 - status '5' for trx of type 'account-ARP', 'ARP - account', 'ARP - ARP'  */

        find ofc where ofc.ofc =  g-ofc no-lock no-error.
        if not v-acc then do:
            do i1 = 1 to NUM-ENTRIES(ofc.tit):
                c1[i1] = entry(i1,ofc.tit).
                find d-ofc where d-ofc.ofc = c1[i1] no-lock no-error.
                v-acc = available d-ofc and
                        ((joudoc.dracctype = '2' and joudoc.cracctype = '2' and (d_cif <> c_cif)) or
                        (joudoc.dracctype = '4' and joudoc.cracctype = '4') or
                        (joudoc.dracctype = '4' and joudoc.cracctype = '2') or
                        (joudoc.dracctype = '2' and joudoc.cracctype = '4')).
                if v-acc then leave.
            end.
        end. /*not v-acc*/

        if v-ll = "a_cas3" then v-acc = yes. /* Luiza */
        if v-cash or v-acc then do:
            run trxsts (input s-jh, input 5, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

            if v-cash then jou_sts = "cas".

            /* sasco - проверка на кассовую валютную проводку юр. лица */
            if v-cash then do: /* КАССА */
                find aaa where aaa.aaa = joudoc.cracc no-lock no-error. /* проверим кредит */
                if not available aaa then find aaa where aaa.aaa = joudoc.dracc no-lock no-error. /* проверим дебет */
                if available aaa then if aaa.crc <> 1 and substr (get-kod(aaa.aaa, ''), 1, 1) = '2' then do:
                    jou_sts = "baC".
                    message "Внимание! Платеж должен пройти контроль ст. менеджером в 2.4.1.1" view-as alert-box title ' '.
                end.
            end.
            /* конец обработки кассовых валютных проводок юр. лица */

            /* 06.08.2004 saltanat - проверка на прохождение арп - касса счета через 2.4.1.1 */
            if v-cash then do:
                if joudoc.dracctype = "4" then do:
                    /* 10.08.2005 Ten - добавим проверку счета арп-касса через ст.менеджера. */
                    /* find first arpcon where arpcon.arp = joudoc.dracc and arpcon.sub = "jou" and arpcon.txb = 'TXB00' no-lock no-error.
                       if avail arpcon then */
                    if (joudoc.cracctype = "1") and (m_sub = "jou") then jou_sts = "baC".
                end.
            end.

            /* 01.04.10 marinav контроль расходных кассовых операций физ лиц более 5000 долл*/
            if joudoc.dracctype = "2" and joudoc.cracctype = "1" then do:
                find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                if avail aaa and lookup(aaa.lgr, '202,204,208,222,246,A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A25,A26,A27,A28,A29,A30,A34,A35,A36,A31,A32,A33,A22,A23,A24') <> 0 then do:
                   find first cif where cif.cif = aaa.cif no-lock no-error.
                   if avail cif and cif.type = 'P' then do:
                      find first crc where crc.crc = joudoc.drcur no-lock no-error.
                      v-sumctrl = joudoc.dramt * crc.rate[1].
                      find first crc where crc.crc = 2 no-lock no-error.
                           if v-sumctrl / crc.rate[1] >= 1000 then do:
                             /* find cursts where cursts.sub eq m_sub and cursts.acc eq v_doc use-index subacc no-lock no-error.
                              if cursts.sts = "new" then run chgsts(m_sub, v_doc, "bad").
                              if cursts.sts = "new" or cursts.sts = "bad" then do:       */
                                 jou_sts = "bad".
                                 message "Сумма свыше 1000 долларов США. Платеж должен пройти вторичный контроль (в 2.4.1.10)! " view-as alert-box.
                             /* end.*/
                           end.
                   end.
                end.
            end.
            /* end 01.04.10 marinav контроль расходных операций физ лиц */


            /****** 03.10.2003 nadejda   перенесено сюда, чтобы накладывать специнструкцию только в случае статуса 5 */
            /* sasco - блокировка суммы для контроля ст. менеджером */
            /* (только для клиентских счетов)                       */
            /* nataly 20.05.03 вставлена проверка на b-aaa.cif <> aaa.cif */
            /* nadejda 03.10.2003  - делается специнструкция на счет по кредиту в случае проводки ARP -> СЧЕТ для для валютного контроля, сами счета на принадлежность валкону проверяются в вызываемой программе */
            /* nataly 30.03.2006  - создается спец интструкция по неснижаемому остатку для проводок СЧЕТ->СЧЕТ для ФЛЮ кроме сотрудников*/

            if (joudoc.dracctype = '1' and joudoc.cracctype = '2' ) and v-our then do:
                find tarif2 where tarif2.num + tarif2.kod eq '193'and tarif2.stat = 'r' no-lock no-error.
                if avail tarif2 then do:
                    find first tarifex2 where tarifex2.aaa = joudoc.cracc and tarifex2.cif = c_cif and tarifex2.str5 = '193' and tarifex2.stat = 'r' no-lock no-error.
                    if not avail tarifex2 then do:
                        find codfr where codfr.codfr = 'clnlim' and codfr.code = string(joudoc.drcur) no-lock no-error.
                        if avail codfr then v-sumlim = decimal(codfr.name[1]).
                        if v-sumlim > 0 then run jou-aasnew2 (joudoc.cracc, v-sumlim, joudoc.jh).
                    end.
                    else
                    if tarifex2.ost <> 0 then do:
                        v-sumlim = tarifex2.ost.
                        if v-sumlim > 0 then run jou-aasnew2 (joudoc.cracc, v-sumlim, joudoc.jh).
                    end.
                end.
            end.
            else
            if (joudoc.dracctype = '2' and joudoc.cracctype = '2' and d_cif <> c_cif) then do:
                run jou-aasnew (joudoc.cracc, joudoc.cramt, joudoc.jh).
            end.
            else do:
                if (joudoc.dracctype = '4' and joudoc.cracctype = '2') then run jou42-aasnew (joudoc.dracc, joudoc.cracc, joudoc.cramt, joudoc.jh).
            end.
            /**************************************/
        end.
        else do:
            run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

            /* --------------------> 11.10.2001, by sasco >------------------- */
            /* --------------------- generate CASHOFC record ----------------- */
            for each jl where jl.jh eq s-jh no-lock:
                if avail jl then do:
                    find sysc where sysc.sysc eq 'CASHGL' no-lock no-error.
                    if jl.gl eq sysc.inval then do:
                        find cashofc where cashofc.ofc eq g-ofc and
                                           cashofc.whn eq jl.jdt and
                                           cashofc.crc eq jl.crc and
                                           cashofc.sts eq 2 /* current sts */
                                           no-error.
                        if avail cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
                        else do:
                            create cashofc.
                            cashofc.whn = jl.jdt.
                            cashofc.ofc = g-ofc.
                            cashofc.who = g-ofc.
                            cashofc.crc = jl.crc.
                            cashofc.sts = 2.
                            cashofc.amt = jl.dam - jl.cam.
                        end.
                    end.
                end.
            end.
            /* --------------------< 11.10.2001, by sasco <------------------- */
            jou_sts = "rdy".
        end. /* конец проставления статуса проводки */

        /* 12.11.2003 nadejda - поискать сумму на счетах валютного контроля и проставить признак снятия суммы */
        /*if joudoc.dracctype = "4" and (lookup(joudoc.cracctype, "1,2,4") > 0) then do:
            if joudoc.cracctype = "1" then do:
                find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
                v-blkacc = string (sysc.inval).
            end.
            else v-blkacc = joudoc.cracc.
            run vcjoublk (joudoc.dracc, v-blkacc, joudoc.dramt, joudoc.jh).
        end.
        */
        /* 12.11.2003 aigul - контроль суммы*/
        def var v-block as logical.
        def var v-rmz as char.
        def var d-chk as logical initial no.
        def var c-chk1 as logical initial no.
        def var c-chk2 as logical initial no.
        def var v-chetp as char.
        if (joudoc.dracctype = "4") and (lookup(joudoc.cracctype, "2") > 0) then do:
            /*aigul - блокировка суммы*/
            find first arp where arp.arp = joudoc.dracc no-lock no-error.
            if avail arp and arp.gl = 223730 then d-chk = yes.
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            if avail aaa and (aaa.gl = 220310 or aaa.gl = 220420 or aaa.gl = 220520 or aaa.gl = 220620 or aaa.gl = 2207220 or
            aaa.gl = 221510 or aaa.gl = 221710) then c-chk1 = yes.
            find first arp where arp.arp = joudoc.cracc no-lock no-error.
            if avail arp and arp.gl = 287032 then c-chk2 = yes.
            if d-chk = yes and (c-chk1 = yes or c-chk2 = yes) then do:
                if joudoc.cracctype = "1" then do:
                    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
                    v-blkacc = string (sysc.inval).
                end.
                else v-blkacc = joudoc.cracc.
                run vcjoublk (joudoc.dracc, v-blkacc, joudoc.dramt, joudoc.jh, output v-block, output v-rmz).
                if v-block = yes and v-rmz = "" then do:
                undo, return.
                end.
                if v-block = no and v-rmz = "" then do:
                undo, return.
                end.
                if v-rmz <> "" then do:
                    joudoc.remark[1] = "Валютный контроль. Зачисление средств" + v-rmz + " " + joudoc.remark[1].
                    for each jl where jl.jh = s-jh exclusive-lock:
                       jl.sts = 5.
                    end.
                    for each jh where jh.jh = s-jh exclusive-lock:
                        jh.sts = 5.
                    end.
                    /*message "Необходим послед.контроль контроллирующего лица в пункте меню 2-4-1-3!" view-as alert-box.*/
                    /* заблокируем нужную сумму до контроля */
                    v-chetp = joudoc.cracc.
                     create aas.

                     find last aas_hist where aas_hist.aaa = v-chetp no-lock no-error.
                     if available aas_hist then aas.ln = aas_hist.ln + 1. else aas.ln = 1.

                     aas.sic = 'HB'.
                     aas.chkdt = g-today.
                     aas.chkno = 0.
                     aas.chkamt  = joudoc.dramt.
                     aas.payee = 'Внутренний платеж со счета клиента |' + TRIM(STRING(s-jh, "zzzzzzzzzz9")) .
                     aas.aaa = v-chetp .
                     aas.who = g-ofc.
                     aas.whn = g-today.
                     aas.regdt = g-today.
                     aas.tim = time.

                     if aas.sic = 'HB' then do:
                         find first aaa where aaa.aaa = v-chetp exclusive-lock.
                         if avail aaa then aaa.hbal = aaa.hbal + aas.chkamt.
                     end.

                     FIND FIRST ofc WHERE ofc.ofc = g-ofc NO-LOCK no-error.
                     if avail ofc then do:
                       aas.point = ofc.regno / 1000 - 0.5.
                       aas.depart = ofc.regno MODULO 1000.
                     end.

                     CREATE aas_hist.

                     find first aaa where aaa.aaa = v-chetp no-lock no-error.
                     IF AVAILABLE aaa THEN DO:
                        FIND FIRST cif WHERE cif.cif= aaa.aaa USE-INDEX cif NO-LOCK NO-ERROR.
                        IF AVAILABLE cif THEN DO:
                           aas_hist.cif= cif.cif.
                           aas_hist.name= trim(trim(cif.prefix) + " " + trim(cif.name)).
                         END.
                     END.

                     aas_hist.aaa= aas.aaa.
                     aas_hist.ln= aas.ln.
                     aas_hist.sic= aas.sic.
                     aas_hist.chkdt= aas.chkdt.
                     aas_hist.chkno= aas.chkno.
                     aas_hist.chkamt= aas.chkamt.
                     aas_hist.payee= aas.payee.
                     aas_hist.expdt= aas.expdt.
                     aas_hist.regdt= aas.regdt.
                     aas_hist.who= aas.who.
                     aas_hist.whn= aas.whn.
                     aas_hist.tim= aas.tim.
                     aas_hist.del= aas.del.
                     aas_hist.chgdat= g-today.
                     aas_hist.chgtime= time.
                     aas_hist.chgoper= 'A'.
                     release aas.
                     release aas_hist.
                    /*----------------------------------------------------------*/
                    MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: "
                    + string(s-jh) + "~nДанный документ подлежит контролю в п.м. 2.4.1.3" view-as alert-box.

                    run chgsts("jou", joudoc.docnum, "bac").
                    if v-noord = no then run vou_bankt(1, 1, joudoc.info).
                    else run printord(s-jh,"").
                end.
            end.
        end.

        pause 1 no-message.

        find first substs where substs.acc = joudoc.docnum and substs.sub = "jou" and substs.sts = "mb3" no-lock no-error.
        if avail substs then message "Внимание! Платеж уже был отправлен в KCell/KMobile~nПовторной отправки не произойдет" view-as alert-box title "".
        else do:
            /*--- sasco - for KMobile payments ---*/
            /* {mob333jou.i}*/
            /* the same for kcell - Kanat */
            {ibcomjou.i}
        end.

        run chgsts (m_sub, v_doc, jou_sts).

        find joudoc where joudoc.docnum eq v_doc exclusive-lock no-error no-wait.

        if d_avail ne "" or d_izm ne ""  or c_avail ne "" then do:
            find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if available aaa then do:
                run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal, output pfbal, output pcrline, output pcrlused, output pooo).
                d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
                d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
                display d_avail d_izm with frame f_main.
            end.
            find arp where arp.arp eq joudoc.dracc no-lock no-error.
            if available arp then do:
                find gl where gl.gl eq arp.gl no-lock no-error.
                if gl.type eq "A" or gl.type eq "E" then d_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
                else d_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").
                d_atl = "АРП-ОСТ".
                d_lab = "".
                display d_avail /*d_izm*/ d_atl d_lab with frame f_main.
            end.
            find arp where arp.arp eq joudoc.cracc no-lock no-error.
            if available arp then do:
                find gl where gl.gl eq arp.gl no-lock no-error.
                if gl.type eq "A" or gl.type eq "E" then c_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
                else c_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").
                c_atl = "АРП-ОСТ".
                display c_avail c_atl d_lab with frame f_main.
            end.
        end.
    end. /* transaction */

    release joudoc.
    if g-fname matches '*obmen*' then do:
        run sim-obm(s-jh).
        run trx-obm(s-jh).
    end.

    /*-----------------------------------------------------------------------*/
    if v-cash and not(g-fname matches '*obmen*') then do:
        pause 0.
        hide all no-pause.
        run x0-cont1.
        g-fname = 'FOFC'.
        hide all.
        view frame mainhead.
        view frame a2.
        view frame f_main.
        if v-ek = 2 then run csstampf(s-jh,v-nomer,output v-errmsg).
        if v-errmsg <> '' then do:
            message v-errmsg view-as alert-box error.
            return.
        end.
    end.
    /*-----------------------------------------------------------------------*/
    if v-ll = "a_cas3" then message "данный документ подлежит контролю в п.м. 2.4.1.3 " view-as alert-box.
end. /* on choose of b2 */

def var v-n as int.
def var v-prtorder as logical init "yes" format "да/нет".

/** VOUCHER (B) **/
on choose of b3 do:
    if v_doc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v_doc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует.".
        run x-vou (input v_doc, input m_sub).
        /*pause 3.*/
        undo, return.
    end.

    do transaction:
        s-jh = joudoc.jh.
        i = 1.
        find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
        if joudoc.rescha[1] ne "" then do:
            find first aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
            if avail aaa then do:
                find cif of aaa exclusive-lock no-error.
                if avail cif then assign d_rnn = cif.jss cif.jss = joudoc.rescha[1].
            end.
        end.

        if g-fname = "csobmen" then run vou_100500(2).
        else do:
            find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
            if avail acheck and ((joudoc.dracctype = "4" and joudoc.cracctype = "4" and (lookup(joudoc.dracc,v-ant) <> 0 or lookup(joudoc.cracc,v-ant) <> 0)) or (joudoc.dracctype = "2" and joudoc.cracctype = "4" and lookup(joudoc.cracc,v-ant) <> 0) or (joudoc.dracctype = "4" and joudoc.cracctype = "2" and lookup(joudoc.dracc,v-ant) <> 0) or (joudoc.dracctype = "1" and joudoc.cracctype <> "1") or (joudoc.cracctype = "1" and joudoc.dracctype <> "1")) then do:
                if joudoc.dracctype = "1" or (joudoc.dracctype = "4" and lookup(joudoc.dracc,v-ant) <> 0) then do:
                    if v-noord = no then run vou_bank2(2,1, joudoc.info).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank2(2,1, joudoc.info).
                        else run printord(s-jh,"").
                    end.
                end.
                else
                if joudoc.cracctype = "1" or (joudoc.cracctype = "4" and lookup(joudoc.cracc,v-ant) <> 0) then do:
                    if v-noord = no then run vou_bank2(2,2, joudoc.info).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank2(2,2, joudoc.info).
                        else run printord(s-jh,"").
                    end.
                end.
                else do:
                    if v-noord = no then run vou_bank(2).
                    else do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run vou_bank(2).
                        else run printord(s-jh,"").
                    end.
                end.
            end.
            else do:
                if v-noord = no then run vou_bank(2).
                else do:
                    find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                    lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                    if avail printofc then run vou_bank(2).
                    else run printord(s-jh,"").
                end.
            end.
        end.

        if joudoc.rescha[1] ne "" then do:
            find first aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
                if avail aaa then do:
                    find cif of aaa exclusive-lock no-error.
                    if avail cif then cif.jss = d_rnn.
                end.
        end.
    end. /* transaction */
end. /* on choose of b3 */

/** VOUCHER (K) **/
on choose of b4 do:
    if v_doc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v_doc no-lock no-error.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует.".
        pause 3.
        undo, return.
    end.

    find first jouset where jouset.drnum eq joudoc.dracctype and jouset.crnum eq joudoc.cracctype  no-lock no-error.
    vou_tmp = substring (jouset.proc, 1, 4) + "vou".

    i = 1.
    message "Укажите количество ваучеров:" update i.
    repeat while i ne 0:
        run value (vou_tmp).
        pause 0.
        i = i - 1.
    end.
end. /* on choose of b4 */

/** IZMEST **/
on choose of b5 do:
    if v_doc eq "" then undo, retry.
    find joudoc where joudoc.docnum eq v_doc no-lock no-error.
    if locked joudoc then do:
        message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ.".
        pause 3.
        undo, return.
    end.

    if joudoc.jh eq ? then do:
        message "Транзакция не существует.".
        pause 3.
        undo, return.
    end.

    if joudoc.who ne g-ofc then do:
        message "Этот документ не ваш.".
        pause 3.
        undo, return.
    end.

    s-jh = joudoc.jh.

    /* проверка свода кассы */
    quest = false.
    find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
    if avail sysc then do:
       if sysc.loval = yes and sysc.daval = g-today then quest = true. /* блок кассы */
    end.

    find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
    v-cash = false.  v-acc = false.

    find cursts where cursts.sub eq m_sub and cursts.acc eq v_doc use-index subacc no-lock no-error.

    find jh where jh.jh eq joudoc.jh no-lock no-error.

    for each jl where jl.jh eq s-jh no-lock:
        if jl.gl eq sysc.inval and (jl.sts eq 6 or cursts.sts eq "rdy") then do on endkey undo, return:
            message "Транзакция акцептована кассиром. Удалить нельзя.".
            pause 3.
            undo, return.
        end.
        if jl.gl eq sysc.inval and quest and jh.jdt = g-today then do:
            message "Свод кассы завершен, удалить нельзя" view-as alert-box.
            undo, return.
        end.
    end.

    do transaction on error undo, return:
        quest = false.
        if jh.jdt lt g-today then do:
            message substitute ("Дата проведения транзакции &1.  Сторно?", jh.jdt) update quest.
            if not quest then undo, return.
			 /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
    	                	           cashofc.ofc eq jl.teller and
        	                	       cashofc.crc eq jl.crc and
            	                	   cashofc.sts eq 2 /* current status */
                	                   exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        assign cashofc.whn = jl.jdt
                               cashofc.ofc = jl.teller
                               cashofc.crc = jl.crc
                               cashofc.who = g-ofc
                               cashofc.sts = 2
                               cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.
			/* ------------------------------------------------------------------*/
            /* sasco - снятие блокировки с суммы */
            /* (которая для контроля старшим менеджером в 2.13) */
            run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).

            /* 13.10.2003 nadejda - поискать эту транзакцию в списке блокированных сумм валютного контроля и убрать пометку о зачислении суммы на счет клиента */
            run jou42-blkdel (joudoc.jh).

            run trxstor(input joudoc.jh, input 6, output s-jh, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            run x-jlvo.
        end.
        else do:
            message "Вы уверены ?" update quest.
            if not quest then undo, return.

            v-sts = jh.sts.

            run trxsts (input s-jh, input 0, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.

            run trxdel (input s-jh, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                if rcode = 50 then do:
                    run trxstsdel (input s-jh, input v-sts, output rcode, output rdes).
                    return.
                end.
                else undo, return.
            end.

		   /* -------------------------for cashofc, by sasco, 18.10.01 -------- */
            for each jl where jl.jh eq joudoc.jh no-lock:
                if not avail jl then message "NOT FOUND JL WITH JOUDOC.JH -> CASHOFC".
                else
                if jl.gl eq sysc.inval and jl.sts = 6 then do:
                    find cashofc where cashofc.whn eq jl.jdt and
                                       cashofc.ofc eq jl.teller and
                                       cashofc.crc eq jl.crc and
                                       cashofc.sts eq 2 /* current status */
                                       exclusive-lock no-error.
                    if avail cashofc then cashofc.amt = cashofc.amt + jl.cam - jl.dam.
                    else do:
                        create cashofc.
                        cashofc.whn = jl.jdt.
                        cashofc.ofc = jl.teller.
                        cashofc.crc = jl.crc.
                        cashofc.sts = 2.
                        cashofc.amt = jl.cam - jl.dam.
                    end.
                    release cashofc.
                end.
            end.

            /*Код для РКЦ 555*/
            if joudoc.cracc = "000904100" or joudoc.cracc = "000904401"  then do:
                find last lnrkc where lnrkc.jh = jh.jh exclusive-lock no-error.
                if avail lnrkc then do:
                    if lnrkc.dtimp <> ? then do:
                        message "Данные уже прогружены: удаление невозможно." view-as alert-box.
                        undo, return.
                    end.
                    else delete lnrkc.
                end.
            end.

            /* ------------------------------------------------------------------*/
            if joudoc.cracc = "150904610"  or joudoc.cracc = "KZ14470192867A000216" or joudoc.cracc = "KZ47470192867A000204" or joudoc.cracc = "KZ04470192867A000202" then do:
                find last lnrkc where lnrkc.jh = jh.jh exclusive-lock no-error.
                if avail lnrkc then do:
                    if lnrkc.dtimp <> ? then do:
                        message "Данные уже прогружены: удаление невозможно." view-as alert-box.
                        undo, return.
                    end.
                    else delete lnrkc.
                end.
            end.

            /* sasco - снятие блокировки с суммы */
            /* (которая для контроля старшим менеджером в 2.13) */
            run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).

            /* 13.10.2003 nadejda - поискать эту транзакцию в списке блокированных сумм валютного контроля и убрать пометку о зачислении суммы на счет клиента */
            run jou42-blkdel (joudoc.jh).

        end.

        find  last joudoc where joudoc.docnum eq v_doc exclusive-lock no-error no-wait.
        if not avail joudoc then do:
		    message "Документ занят!!! Подождите..." view-as alert-box.
		    undo, return.
	    end.

        joudoc.jh   = ?.
        /*------------------------------------24.09.01----------------------*/
        if g-fname matches '*obmen*' then run chgsts(m_sub, v_doc, "del").
                                     else run chgsts(m_sub, v_doc, "new").
        /*------------------------------------24.09.01----------------------*/

        find last aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if available aaa then do:
            run aaa-bal777 (input aaa.aaa, output pbal, output pavl, output phbal, output pfbal, output pcrline, output pcrlused, output pooo).
            d_avail = string (pbal, "z,zzz,zzz,zzz,zzz.99").
            d_izm   = string (pavl, "z,zzz,zzz,zzz,zzz.99").
            d_atl = "СЧТ-ОСТ".
            d_lab = "ИСП-ОСТ".
            display d_avail d_izm d_atl d_lab with frame f_main.
        end.

        find first jouset where jouset.drnum eq joudoc.dracctype and jouset.crnum eq joudoc.cracctype and jouset.fname eq g-fname no-lock no-error.
        if jouset.proc eq "jgg_jou" then do:
            joudoc.nalamt = 0.
            a = pavl.
            s = a.

            find first trxbal where trxbal.sub = "cif" and trxbal.crc eq joudoc.drcur and trxbal.acc = joudoc.dracc and trxbal.lev = 9 no-lock no-error.
            if available trxbal then do:
                v-nal  = trxbal.cam - trxbal.dam.
                v9-nal = trxbal.cam - trxbal.dam.
            end.

            v-nal  = 0.
            v9-nal = 0.
            dramt = pavl.

            if joudoc.dramt > v-nal then do on error undo,retry:
                message "Обналичивается сумма:" + string(joudoc.dramt - v-nal,"z,zzz,zzz,zzz,zz9.99-").

                repeat:
                    run perev (input aaa.aaa,input joudoc.comcode, input s, input joudoc.drcur, input joudoc.comcur, aaa.cif, output ds, output vgl, output vdes).
                    /*run perev (input aaa.aaa,input "409", input v-nal, input joudoc.drcur, input joudoc.comcur, aaa.cif, output dsnal, output vgl, output vdes).*/
                    dsnal = 0.
                    hh = a - s - ds - dsnal.
                    if hh > (- eps) and hh < eps then leave.
                    s = s + hh.
                    v-nal = s - /*amt9 */ v9-nal .
                end.

                joudoc.comamt = ds.
                joudoc.nalamt = dsnal.
                joudoc.dramt = pavl - joudoc.comamt - joudoc.nalamt.

                display joudoc.dramt joudoc.comamt joudoc.nalamt with frame f_main.
            end.    /*** if joudoc.dramt > v-nal   ***/
        end.    /*** if jou_prog eq "jgg_jou"   ***/
        else do:
            joudoc.nalamt = 0.
            if joudoc.cracc = "" then do:
                find first aaa where aaa.aaa = joudoc.dracc and aaa.crc = joudoc.drcur no-lock no-error.
                if available aaa then do:
                    find first trxbal where trxbal.sub = "cif" and trxbal.crc eq joudoc.drcur and trxbal.acc = joudoc.dracc and trxbal.lev = 9 no-lock no-error.
                    v-nal = 0.
                    if avail trxbal then v-nal = trxbal.cam - trxbal.dam.
                    if joudoc.dramt > v-nal then do on error undo,retry:
                        run perev (input aaa.aaa,"409", input joudoc.dramt - v-nal, input joudoc.drcur, input joudoc.drcur,aaa.cif, output joudoc.nalamt, output nalgl, output naldes).
                        joudoc.nalamt = 0.
                        display joudoc.nalamt with frame f_main.
                    end.
                end.
            end.
        end.

        find arp where arp.arp eq joudoc.dracc no-lock no-error.
        if available arp then do:
            find gl where gl.gl eq arp.gl no-lock no-error.
            if gl.type eq "A" or gl.type eq "E" then d_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
            else d_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").
            d_atl = "АРП-ОСТ".
            d_lab = "".
            display d_avail /*d_izm*/ d_atl d_lab with frame f_main.
        end.

        find arp where arp.arp eq joudoc.cracc no-lock no-error.
        if available arp then do:
            find gl where gl.gl eq arp.gl no-lock no-error.
            if gl.type eq "A" or gl.type eq "E" then c_avail = string (arp.dam[1] - arp.cam[1], "z,zzz,zzz,zzz,zzz.99").
            else c_avail = string (arp.cam[1] - arp.dam[1], "z,zzz,zzz,zzz,zzz.99").
            c_atl = "АРП-ОСТ".
            display c_avail c_atl d_lab with frame f_main.
        end.

        /* Luiza удаляем запись из bxcif--если комиссия была записана в долг--------------------------*/
        find first bxcif where bxcif.aaa = joudoc.comacc and bxcif.whn = joudoc.whn and bxcif.type = joudoc.comcode and bxcif.amount = joudoc.comamt and bxcif.rem begins "#Комиссия за" no-error.
        if avail bxcif then delete bxcif.
        find first bxcif no-lock no-error.
        /* Luiza--------------------------------------------------------*/

        display joudoc.jh with frame f_main.
    end. /* transaction */

    do transaction:
        run comm-dj(joudoc.docnum).

        /* sasco - удалить записи о контроле для arpcon */
        find sysc where sysc.sysc = "ourbnk" no-lock no-error.
        /* найдем arpcon со счетом по дебету */
        find arpcon where arpcon.arp = joudoc.dracc and
                          arpcon.sub = 'jou' and
                          arpcon.txb = sysc.chval
                          no-lock no-error.
        if avail arpcon then do:
            /* удалим статус контроля из истории платежа */
            for each substs where substs.sub = 'jou' and
                                  substs.acc = joudoc.docnum and
                                  substs.sts = arpcon.new-sts:
                delete substs.
            end.

            find cursts where cursts.sub = 'jou' and cursts.acc = joudoc.docnum no-error.

            if avail cursts then do:
               find last substs where substs.sub = 'jou' and substs.acc = joudoc.docnum no-lock no-error.
               assign cursts.sts = substs.sts.
            end.
        end.
    end. /* transaction */

    /*------- возврат листа ЧК в список неиспользованных --------*/
    run back-chk.
    /*-----------------------------------------------------------*/

    release joudoc.
end. /* on choose of b5 */

/** STATUS **/
on choose of b6 do:
    if v_doc eq "" then undo, retry.
    run substs (m_sub, v_doc).
end.

/** SPRAVOCHNIK **/
on choose of b7 in frame a2 do:
    if v_doc eq "" then undo, retry.
    do transaction: run subcodj (v_doc, "jou"). end. /* transaction */
    view frame f_main.
    view frame a2.
end.

on choose of b8 in frame a2 do:
    find first joudoc where joudoc.docnum = v_doc no-lock no-error.
    if avail joudoc then run print_pl (joudoc.jh, joudoc.cracc).
end.


find first jouset where jouset.fname eq g-fname no-lock no-error.
if not available jouset then do:
    message "ФУНКЦИЯ НЕ ОПИСАНА В НАСТРОЙКАХ.".
    pause 5.
    undo, return.
end.

for each jouset where jouset.fname eq g-fname no-lock break by jouset.drnum.
    if first-of (jouset.drnum) then do:
        if jouset.drnum ne "" then do:
            find jounum where jounum.num eq jouset.drnum no-lock no-error.
            d_combo = d_combo + jounum.num + "." + jouset.drtype + ",".
        end.
    end.
end.

for each jouset where jouset.fname eq g-fname no-lock break by jouset.crnum.
    if first-of (jouset.crnum) then do:
        if jouset.crnum ne "" then do:
            find jounum where jounum.num eq jouset.crnum no-lock no-error.
            c_combo = c_combo + jounum.num + "." + jouset.crtype + ",".
        end.
    end.
end.

for each jouset where jouset.fname eq g-fname and jouset.crtype eq "" no-lock break by jouset.drnum.
    if first-of (jouset.drnum) then do:
        if jouset.drnum ne "" then do:
            find jounum where jounum.num eq jouset.drnum no-lock no-error.
            m_combo = m_combo + jounum.num + "." + jouset.drtype + ",".
        end.
    end.
end.

substring (d_combo, r-index (d_combo, ","), 1) = "".
substring (c_combo, r-index (c_combo, ","), 1) = "".
if g-fname = 'fofc' then substring (m_combo, r-index (m_combo, ","), 1) = "".

assign db_com:list-items in frame f_main = d_combo.
assign cr_com:list-items in frame f_main = c_combo.
assign com_com:list-items in frame f_main = m_combo.

find crc where crc.crc = 1 no-lock no-error.
loccrc1 = crc.code.
loccrc2 = crc.code.

view frame f_main.
enable all with frame a2.
wait-for window-close of current-window.


Procedure Delete_status.
    do transaction:
        for each substs where substs.sub eq m_sub and substs.acc eq joudoc.docnum exclusive-lock:
            delete substs.
        end.
        for each cursts where cursts.sub eq m_sub and cursts.acc eq joudoc.docnum exclusive-lock:
            delete cursts.
        end.
    end. /* transaction */
end procedure.

Procedure Collect_Undefined_Codes.

    def input parameter c-templ as char.
    def input parameter c-ident as char.
    def var vjj as inte.
    def var vkk as inte.
    def var ja-name as char.

    for each trxhead where trxhead.system = substring (c-templ, 1, 3) and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:
        if trxhead.sts-f eq "r" then vjj = vjj + 1.
        if trxhead.party-f eq "r" then vjj = vjj + 1.
        if trxhead.point-f eq "r" then vjj = vjj + 1.
        if trxhead.depart-f eq "r" then vjj = vjj + 1.
        if trxhead.mult-f eq "r" then vjj = vjj + 1.
        if trxhead.opt-f eq "r" then vjj = vjj + 1.

        for each trxtmpl where trxtmpl.code eq c-templ no-lock:
            if trxtmpl.amt-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crc-f eq "r" then vjj = vjj + 1.
            if trxtmpl.rate-f eq "r" then vjj = vjj + 1.
            if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.
            if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.
            if trxtmpl.dev-f eq "r" then vjj = vjj + 1.
            if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.
            if trxtmpl.cev-f eq "r" then vjj = vjj + 1.
            if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.

            repeat vkk = 1 to 5:
                if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
            end.

            for each trxcdf where trxcdf.trxcode = trxtmpl.code and trxcdf.trxln = trxtmpl.ln no-lock:
                if trxcdf.drcod-f eq "r" then do:
                    vjj = vjj + 1.
                    find first trxlabs where trxlabs.code = trxtmpl.code and trxlabs.ln = trxtmpl.ln and trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.
                    create w-cods.
                    w-cods.template = c-ident.
                    w-cods.parnum = vjj.
                    w-cods.codfr = trxcdf.codfr.
                    w-cods.name = ja-name.

                    case c-ident:
                        when "payment" then w-cods.what = "Dt Операции".
                        when "tcom" then w-cods.what = "Dt Комиссии за операцию".
                        when "ncom" then w-cods.what = "Dt Комиссии за обналичивание".
                    end case.
                end.

                if trxcdf.crcode-f eq "r" then do:
                    vjj = vjj + 1.
                    find first trxlabs where trxlabs.code = trxtmpl.code and trxlabs.ln = trxtmpl.ln and trxlabs.fld = trxcdf.codfr + "_Cr" no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.
                    create w-cods.
                    w-cods.template = c-ident.
                    w-cods.parnum = vjj.
                    w-cods.codfr = trxcdf.codfr.
                    w-cods.name = ja-name.

                    case c-ident:
                        when "payment" then w-cods.what = "Cr Операции".
                        when "tcom" then w-cods.what = "Cr Комиссии за операцию".
                        when "ncom" then w-cods.what = "Cr Комиссии за обналичивание".
                    end case.
                end.
            end.
        end. /*for each trxtmpl*/
    end. /*for each trxhead*/
end procedure.

Procedure Parametrize_Undefined_Codes.

    def var ja-nr as inte.
    def output parameter OK as logi initial false.
    def var jrcode as inte.
    def var saved-val as char.

    find first w-cods no-error.
    if not available w-cods then do:
        OK = true.
        return.
    end.
    def variable v-ind as integer.
    v-ind = 0.

    {jabrew.i
        &start = " on help of w-cods.val in frame jou_cods do:
                 run uni_help1(w-cods.codfr,'*').
                 end.
                 vkey = 'return'.
                 key-i = 0. "

        &head = "w-cods"
        &headkey = "parnum"
        &where = "true"
        &formname = "jou_cods"
        &framename = "jou_cods"
        &deletecon = "false"
        &addcon = "false"
        &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
        &predisplay = " ja-nr = ja-nr + 1. "
        &display = "ja-nr /*w-cods.codfr*/ w-cods.name w-cods.what w-cods.val"
        &highlight = "ja-nr"
        &postkey = "
            else if vkeyfunction = 'return' then do:
                valid:
                repeat:
                    saved-val = w-cods.val.
                    update w-cods.val with frame jou_cods.

                    find codfr where codfr.codfr = w-cods.codfr and codfr.code = w-cods.val no-lock no-error.
                    if not available codfr or codfr.code = 'msc' then do:
                        bell.
                        message 'Некорректное значение кода! Введите правильно!' view-as alert-box.
                        w-cods.val = saved-val.
                        display w-cods.val with frame jou_cods.
                        next valid.
                    end.
                    else do:
                        if w-cods.codfr = 'spnpl' then v-knpval = codfr.code.
                        if w-cods.codfr = 'secek' and w-cods.what begins 'dt'  then v-secval = codfr.code.
                        leave valid.
                    end.
               end.
               if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                    key-i = 0.
                    vkey = 'cursor-down^return'.
               end.
            end.
            else
            if keyfunction(lastkey) = 'GO' then do:
                jrcode = 0.
                for each w-cods:
                    find codfr where codfr.codfr = w-cods.codfr and codfr.code = w-cods.val no-lock no-error.
                    if not available codfr or codfr.code = 'msc' then jrcode = 1.
                end.
                if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                end.
                else do: OK = true. leave upper. end.
            end."
        &end = "hide frame jou_cods.
                hide message."
    }
end procedure.

Procedure Insert_Codes_Values.

    def input parameter t-template as char.
    def input parameter t-delimiter as char.
    def input-output parameter t-par-string as char.
    def var t-entry as char.

    for each w-cods where w-cods.template = t-template break by w-cods.parnum:
        t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
        if ERROR-STATUS:error then t-par-string = t-par-string + t-delimiter + w-cods.val.
        else do:
            entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
            entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
        end.
    end.

end procedure.

procedure deffilial.
     v-cltype = '01'.
     v-res = 'KZ'.
     v-res2 = '1'.

     find first codfr where codfr.codfr = 'DKPODP' and codfr.code = '1' no-lock no-error.
     if avail codfr then v-FIO1U = codfr.name[1].

     v-OKED = '65'.
     /*пока пустое, т.к. у филиала 12-значный ОКПО */
     v-prtOKPO = cmp.addr[3].

     find first cmp no-lock no-error.
     v-prtPhone = cmp.tel.
     v-rnn = cmp.addr[2].
     v-iin = ''.
     find sysc where sysc.sysc = "bnkbin" no-lock no-error.
     if avail sysc then v-iin = sysc.chval.
     v-addr = cmp.addr[1].

     find sysc where sysc.sysc = "bnkadr" no-lock no-error.
     if avail sysc then do:
        v-prtEmail = entry(5, sysc.chval, "|") no-error.
        v-addr = v-addr + ',' + entry(1, sysc.chval, "|") no-error.
     end.

     find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

end procedure.

procedure defclparam.

    v-cltype = ''.
    v-res = ''.
    v-res2 = ''.
    v-publicf = ''.
    v-FIO1U = ''.
    v-OKED = ''.
    v-prtOKPO = ''.
    v-prtEmail = ''.
    v-prtPhone = ''.
    v-prtFLNam = ''.
    v-prtFFNam = ''.
    v-prtFMNam = ''.
    v-clnameU = ''.
    v-prtUD = ''.
    v-prtUdN = ''.
    v-prtUdIs = ''.
    v-prtUdDt = ''.
    v-bdt = ''.
    v-bplace = ''.
    v-iin = ''.

    v-iin = cif.bin.

    if cif.type = 'B' then do:
        if cif.cgr <> 403 then v-cltype = '01'.
        if cif.cgr = 403 then v-cltype = '03'.
    end.
    else v-cltype = '02'.

    if cif.geo = '021' then do:
        v-res = 'KZ'.
        v-res2 = '1'.
    end.
    else do:
        v-res2 = '0'.
        if num-entries(cif.addr[1]) = 7 then do:
            v-country2 = entry(1,cif.addr[1]).
            if num-entries(v-country2,'(') = 2 then v-res = substr(entry(2,v-country2,'('),1,2).
        end.
    end.
    find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
    if avail cif-mail then v-prtEmail = cif-mail.mail.
    v-prtPhone = cif.tel.

    if v-cltype = '01' then do:
        v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name).
        v-prtOKPO = cif.ssn.
    end.
    else v-clnameU = ''.

    if v-cltype = '02' or v-cltype = '03'then do:
        if v-cltype = '02' then do:
            if num-entries(trim(cif.name),' ') > 0 then v-prtFLNam = entry(1,trim(cif.name),' ').
            if num-entries(trim(cif.name),' ') >= 2 then v-prtFFNam = entry(2,trim(cif.name),' ').

            if num-entries(trim(cif.name),' ') >= 3 then v-prtFMNam = entry(3,trim(cif.name),' ').
        end.
        else do:
            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
            if avail sub-cod and sub-cod.ccode <> 'msc' then do:
                if num-entries(trim(sub-cod.rcode),' ') > 0 then v-prtFLNam = entry(1,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 2 then v-prtFFNam = entry(2,trim(sub-cod.rcode),' ').
                if num-entries(trim(sub-cod.rcode),' ') >= 3 then v-prtFMNam = entry(3,trim(sub-cod.rcode),' ').
            end.
        end.

        if cif.geo = '021' then v-prtUD = '01'.
        else v-prtUD = '11'.

        if num-entries(cif.pss,' ') > 1 then v-prtUdN = entry(1,cif.pss,' ').
        else v-prtUdN = cif.pss.

        if num-entries(cif.pss,' ') >= 2 then v-prtUdDt = entry(2,cif.pss,' ').
        if num-entries(cif.pss,' ') >= 3 then v-prtUdIs = entry(3,cif.pss,' ').
        if num-entries(cif.pss,' ') > 3 then v-prtUdIs = entry(3,cif.pss,' ') + ' ' + entry(4,cif.pss,' ').

        find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.

        v-bdt = string(cif.expdt,'99/99/9999').
        v-bplace = cif.bplace.
    end.
    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.

    find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
    if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

procedure back-chk:
    def var v-bank as char.
    def var s1 as char.
    def var s2 as char.
    def var str-pages as char.

    if avail joudoc and joudoc.chk > 0 and joudoc.kfmcif = "" then do:


        /*------- возврат/удаление чека в список неиспользованных --------*/
        del-page = no.
        find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
        if avail checks then message "Чек испорчен ?" view-as alert-box question buttons yes-no title "" update del-page as logical.
        if del-page = yes then do:
                find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" no-lock no-error.
                if avail checks and index(checks.pages, string(joudoc.chk)) > 0 then do:
                    if index(checks.pages, string(joudoc.chk)) > 0 then do:
                        s1 = substr(checks.pages, 1, index(checks.pages, string(joudoc.chk)) - 1).
                        s2 = substr(checks.pages, index(checks.pages, string(joudoc.chk)) + length(string(joudoc.chk)) + 1).
                        str-pages = s1 + s2.
                    end.
                end.
                do transaction:
                    find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" exclusive-lock no-error.
                    if avail checks and index(checks.pages, string(joudoc.chk)) > 0 then do:
                        checks.pages = str-pages.
                        find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
                    end.
                end.
        end.
        if del-page = no then
        do transaction:
            find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk exclusive-lock no-error.
            if avail checks and index(checks.pages, string(joudoc.chk)) = 0 then
            checks.pages = checks.pages + string(joudoc.chk) + "|".
            find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
        end.
        /*-----------------------------------------------------------*/

    end.
    else
    if avail joudoc and joudoc.chk > 0 and joudoc.kfmcif <> "" then do:
        if substr(joudoc.kfmcif,1,1) = "a" then v-bank = "TXB00".
        if substr(joudoc.kfmcif,1,1) = "b" then v-bank = "TXB01".
        if substr(joudoc.kfmcif,1,1) = "c" then v-bank = "TXB02".
        if substr(joudoc.kfmcif,1,1) = "d" then v-bank = "TXB03".
        if substr(joudoc.kfmcif,1,1) = "e" then v-bank = "TXB04".
        if substr(joudoc.kfmcif,1,1) = "f" then v-bank = "TXB05".
        if substr(joudoc.kfmcif,1,1) = "h" then v-bank = "TXB06".
        if substr(joudoc.kfmcif,1,1) = "k" then v-bank = "TXB07".
        if substr(joudoc.kfmcif,1,1) = "l" then v-bank = "TXB08".
        if substr(joudoc.kfmcif,1,1) = "m" then v-bank = "TXB09".
        if substr(joudoc.kfmcif,1,1) = "n" then v-bank = "TXB10".
        if substr(joudoc.kfmcif,1,1) = "o" then v-bank = "TXB11".
        if substr(joudoc.kfmcif,1,1) = "p" then v-bank = "TXB12".
        if substr(joudoc.kfmcif,1,1) = "q" then v-bank = "TXB13".
        if substr(joudoc.kfmcif,1,1) = "r" then v-bank = "TXB14".
        if substr(joudoc.kfmcif,1,1) = "s" then v-bank = "TXB15".
        if substr(joudoc.kfmcif,1,1) = "t" then v-bank = "TXB16".

        find txb where txb.consolid and txb.bank = v-bank no-lock no-error.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run jou-backchk (joudoc.chk, joudoc.kfmcif).
        disconnect "txb".
    end.

end procedure.
