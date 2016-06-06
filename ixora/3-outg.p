/* 3-outg.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Создание и отправка платежей
 * BASES
        BANK comm
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
        05/02/2002, sasco - для валютных платежей РКО TXB00 : код возврата que.rcod = 1
        28/11/2003, sasco - вместо заполнения свифт МТ100 - будет МТ103
        01/12/2003, sasco - убрал вывод слова "режим" из лога "режим 3G"
        22.04.2004  tsoy  - контроль поля КодБK
        30/04/2004  kanat - добавил контроль РНН налогового комитета по БИК НК после update remtrz.rbank
        04.05.2004 nadejda - исправлена проверка счета налоговых комитетов с 000080000 на ...080...
        18.05.2004 dpuchkov - добавил проверку счетов и рнн на филиалах
        20.05.2004 dpuchkov - добавил проверку счетов и рнн на филиалах с использ внешнего .p модуля
        26/05/2004 valery - исключена возможность проведения платежей комбинации БИК и ИИК которых прописаны в sysc = GOSACC, в связи с введением новой казначейской системы ТЗ №937 от 20/05/04
        23.06.2004 dpuchkov - вынес формирование свифтов методом покрытия в независимые файлы(просмотр/прогрузка)
        16.07.2004 dpuchkov - перекомпиляция
        18.08.2004 valery - перекомпиляция
        09.09.2004 dpuchkov - добавил new shared переменную
        21.10.2004 sasco - в самом начале проверка на длину наименования получателя < 60 символов (v-longrnn)
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        12.04.2004 suchkov - теперь при попытке поставить МФО филиала, ругается и не дает
        09.06.2005 u00121 - раньше, когда создавался платеж на филиале, из-за того что банк-корреспондент банка-получателя в справочнике банков, всегда равен TXB00,
                                а TXB00 всегда работает по клирингу, программа позволяла отправлять платежи по клирингу в банки, которые по нему не работают. Теперь сделана
                                проверка, которая находит реального банка-корреспондент и проверяет его на клиринг.
        23.06.2005 u00121  - ТЗ № 47 от 08.06.2005 - введен статус банка 0 - открыт, 1 - открыт, закрыты активные операции, 2 - закрыт. Если статус не равен 0 , значит банк закрыт
                                и выдается соответсвующее сообщение с прекращением ввода данных.
        23.11.2005 suсhkov - Детали платежа 412 символов
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        18.09.2006 u00600 - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
        04.12.09   marinav - добавились поля debls.acc bic
        21/01/2010 galina - добавила справочник для КБК
        22/01/2010 galina - счет получателя в bnkx1 frame 20-тизначный
        09.06.10 marinav - контроль правильности счета в платежах на наши филиалы
        20/07/2010 galina - проверяем бенефициара по спискам террористов, только если есть наименование
        28/07/2010 galina - проверяем логическую переменную kfmOn в справочнике pksysc перед запросом в AML
        01.10.10  marinav - банк отправитель - АО Метрокомбанк
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        11/05/2011 madiyar - изменения по ТЗ № 856
        23/09/2011 lyubov - изменения по тз № 964. дата валютирования платежных поручений
        11/10/2011 Luiza  - добавила замену длинных наименований организаций на сокращения
        12/12/2011 Luiza  - не пропускаем пустое поле код для КодБК переменная v-sub
        22/02/2012 dmitriy - проверка заполнения поля "Получатель"
        24/02/2012 dmitriy - подправил алгоритм проверки заполнения поля "Получатель"
        15/03/2012 id00810 - название банка плательщика из sysc
        24/09/2012 Luiza  - по СЗ запрет редактирования поля remtrz.ord для платежей 2.2.1 и 15.1.1 и
                            если у rmz jh3 > 1 значит  получатель проверку уже прошел в  jou документе, ONline проверку не выполняем.

        01.10.2012 evseev - логирование
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        06/08/2013 galina - ТЗ1906  добавила ввод VIN
        13/08/2013 galina - ТЗ2028 вынесла перечень кнп для VIN кода в настройку pksysc
        19/08/2013 galina - ТЗ1871 добавила новый вид траспорта 6) СМЭП
        20/08/2013 galina - убрала лишний вывод сообщения о транспорте


*/


{global.i}
{comm-rnn.i}
{chkaaa20.i}

/* для использования BIN */
{chk12_innbin.i}
{chbin.i}

def shared var s-remtrz like remtrz.remtrz.
run savelog("3-outg","Начало............................................... " + s-remtrz).

def var v-9c as cha format "x(35)"  label "Фамилия, Имя    " .
def var v-9d as cha format "x(35)"  label "Персональный код".
def var v-9bin as char format "x(12)" label "Персональный код".
def var v-9e as cha format "x(35)"  label "Номер паспорта  ".
def var v-9f1 as cha format "x(35)" label "Кем выдан       ".
def var v-9f2 as cha format "x(35)" label "                ".
def var v-drg as cha format "99" label    "Срок действия   ".
def var prilist as cha.
def var sublist as cha .
def var lbnstr as cha .
def var de6 as int .
def var result as int format "9" .
def var v-det as cha .
def var addrbank as char format "x(80)".
def var cmdk as char format "x(70)".
def var v-bb as  cha  .
def var Lswtdfb as log format "Да/Нет".
def var Lswbank as log format "Да/Нет".

def new shared var f_title as char format "x(80)". /*title of frame mt100  */
def new shared buffer f57-bank for bankl.           /* nan */
def buffer smep-bank  for bankl.           /* nan */
def new shared buffer sw-bank  for bankl.           /* nan */
def new shared var s-sqn as cha .
def new shared var remrem202 as char format "x(16)". /* field 20 of mt202  */
def new shared var F52-L as char format "x(1)".  /* ordering institution*/
def new shared var F53-L as char format "x(1)".  /* sender's corr.      */
def new shared var F54-L as char format "x(1)".             /*rec-r's corr. */
def new shared var F56-L as char format "x(1)".    /*intermediary.  */
def new shared var F53-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F53-2val as char extent 4 format "x(35)".

/*intermediary 202 .  */
def new shared var F56-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F56-2val as char extent 4 format "x(35)".

/*intermediary 202 .  */
def new shared var F57-2L as char format "x(1)".    /*intermediary 202.*/
def new shared var F57-2val as char extent 5 format "x(35)".

/*intermediary 202 .*/
def new shared var F58-2L as char format "x(1)".
def new shared var F58-2aval as char extent 5 format "x(35)". /*58- 202.*/
def new shared var F58-2bval as char extent 5 format "x(35)".
def new shared var F72-2val as char extent 6 format "x(35)".
def new shared var F72-1val as char extent 6 format "x(35)". /* mt100.*/

/*intermediary 202 .*/
def new shared var F57-L as char format "x(1)".       /*account with inst.  */
def new shared var F57-str4 as char extent 2 format "x(35)".
def new shared var v-58 as char extent 4 format "x(35)".

def  var F71choice as char extent 3 format "x(3)" initial ["BEN", "OUR","NON"].
def var vdep as inte.
def var vpoint as inte.
def  var ootchoice as char extent 4 format "x(35)" initial [" MT 103 ", " MT 200 ", " MT 202 ", " MT 202, MT 103 "].

def new shared var dmt100 as char format "x(12)".
def new shared var v-bn1 like remtrz.ord.
def new shared var v-bn2 like remtrz.ord.
def new shared var v-bn3 like remtrz.ord.
def new shared var v-bn4 like remtrz.ord.
def new shared var v-bb1 like remtrz.ord.
def new shared var v-bb2 like remtrz.ord.
def new shared var v-bb3 like remtrz.ord.
def new shared var v-bb4 like remtrz.ord.

def new shared var v-refernumber as char.
def new shared var v-destnumber as char.
def new shared var v-dest202 as char.

def new shared var v-swinbankb like swbody.content[1].
def new shared var v-swinbankb2 like swbody.content[2].

def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def shared frame remtrz.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var clearing as cha.
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var receiver as cha.
def var s-bankl like remtrz.rbank .
def var v-weekbeg as int.
def var v-weekend as int.
def var intv as  int.
def new shared var sw as log format "Да/Нет" init yes.
def var brnch as log format "Да/Нет" initial false .
def new shared var scod as char init "ns" .
def var v-bn like remtrz.bn format "x(35)" label "Получатель" .
def var v-id as char format "x(12)" label "".

def var v-sub as cha format "x(6)" label "КодБК".

def var kindchoice as char extent 3 format "x(6)" label "Тип пл." initial ["Норм.", "Налог" , "Пенсия" ].
def var v-inc as cha format "x(10)" label "Код дохода" .
def var t-rcv as int .
def var v-rnn as log.
def var qq as char .
def var v-o as log.
def var bbcod as char.
def var valcntrl as logical init false.         /*** KOVAL Для валютного контроля ***/
def var logic as logical init false.            /*** KOVAL ***/

def var l-rekviz as logical .
def new shared var l-doubleswift as logical init False.

def var rnntrue as log init false.

define new shared temp-table tmpswbody like swbody.

define buffer b-bankl for bankl .

def var v-ocover as integer no-undo.
def var v-covermsg as char no-undo.

def var v-bnlength as int.
def var v-que as char.
/*****************************valery****************************************************************************************************************************************/
def var accs as char.
def var accb1 as char format "x(3)".
def var i as int.
def var j as int.
def var accs2 as char.
def var f1 as logical init false.
def var f2 as logical init false.
def var f3 as logical init false.
def var msg as char init "Счет получателя не соответствует БИКу получателя, повторите, пожалуйста!".

def new shared var val_103_54con1 like swbody.content[1].
def new shared var val_103_54con2 like swbody.content[2].
def new shared var val_103_54con3 like swbody.content[3].
def new shared var val_103_54con4 like swbody.content[4].
def new shared var val_103_54con5 like swbody.content[5].
def new shared var val_103_54con6 like swbody.content[6].
def new shared var val_103_type like swbody.type.

define variable v-detpay as character .
define variable v-detpay1 as character extent 8.

DEFINE VARIABLE v-longrnn as logical.

def var v-knp as char no-undo. /* код назначения платежа */

def var rem_u as logi init false no-undo. /*u00600*/

def var temp_cr_amount like remtrz.amt.
def var l-clr as log init false. /*по умолчанию банк по клирингу не работает*/

def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".

def var v-senderNameList as char.
def var v-benNameList as char.
def var v-benCountry as char.
def var v-benName as char.
def var v-senderCountry as char.
def var v-senderName as char.
def var v-pttype as integer.
def var v-errorDes as char.
def var v-operIdOnline as char.
def var v-operStatus as char.
def var v-operComment as char.
def var v-bankname as char  no-undo.

/***************/
/* Luiza ----------------------------------------------------------------------------*/
def var full as char no-undo init "Товарищество с ограниченной ответственностью,Общественное объединение,Акционерное общество,
            Закрытое акционерное общество,Открытое акционерное общество,Потребительский кооператив,Общественный фонд,
            Религиозное объединение,Крестьянское хозяйство,Полное товарищество,Коммандитное товарищество,
            Государственное предприятие,Товарищество с дополнительной ответственностью,
            Производственный кооператив,Государственное учреждение,Индивидуальный предприниматель,
            Жилищные кооперативы,Жилищно-строительные кооперативы".
def var mini as char no-undo init "ТОО,ОО,АО,ЗАО,ОАО,ПК,ОФ,РО,КХ,ПТ,КТ,ГП,ТДО,ПК,ГУ,ИП,ЖК,ЖСК".
def var c as int.
/*--------------------------------------------------------------------------------*/

/*galina*/
def var v-smepamt like remtrz.payment.
def var v-smep as logi.


v-smepamt = 0.
find first pksysc where pksysc.sysc = 'SmepAmt' and pksysc.credtype = '0'  no-lock no-error.
if not avail pksysc or pksysc.deval = 0 then do:
    message "Не найдена запись SmepAmt в sysc!" view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.
v-smepamt = pksysc.deval.
/********/
v-covermsg = ''.


def var v-kbkforvin  as char.
v-kbkforvin = ''.
find first pksysc where pksysc.sysc = 'kbkforvin' and pksysc.credtype = '0' no-lock no-error.
if avail pksysc and trim(pksysc.chval) <> '' then v-kbkforvin = trim(pksysc.chval).

def var v-knpforvin  as char.
v-knpforvin = ''.
find first pksysc where pksysc.sysc = 'knpforvin' and pksysc.credtype = '0' no-lock no-error.
if avail pksysc and trim(pksysc.chval) <> '' then v-knpforvin = trim(pksysc.chval).



def var v-vin as char.
form s-bankl label "БанкП"
     remtrz.bb label "Банк получ"
     remtrz.ba label "Счет получ" format "x(21)"
     v-sub validate (  can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации")
     v-vin label "VIN код" format "x(20)" validate(trim(v-vin) <> '' and (can-find (first vincode where vincode.vin = trim(v-vin) use-index vinbinidx no-lock) or can-find (first vincode where vincode.f45 = trim(v-vin) use-index f45idx no-lock)) , " VIN код не найден!")
     with centered row 14 1 col overlay top-only frame bnkx1.

on help of v-sub in frame bnkx1 do:
  {itemlist.i
       &file = "budcodes"
       &where = " true "
       &frame = "row 2 centered scroll 1 15 down overlay "
       &flddisp = "budcodes.code column-label 'КБК' label 'КБК'
                   budcodes.name1 format 'x(60)' label 'Описание кода' column-label 'Описание кода' "
       &chkey = "code"
       &chtype = "integer"
       &index  = "code"
  }
  v-sub = string(budcodes.code,'999999').
  display v-sub with frame bnkx1.
end.

/**************/
v-longrnn = false.

function chk-gosacc returns logical (p-val1 as char, p-val2 as char).
    if p-val2 = ourbank then do:
        message "Внутренний платеж надо делать в 2.1.1".
        return false.
    end.
    if p-val1 ne "" then do:
        if p-val2 begins 'TXB' and substr(p-val2,4,2) <> substr(p-val1,19,2) then do:
            message "Неверный счет!".
            return false.
        end.
    end.
    return true.
end.
/*****************************valery****************************************************************************************************************************************/

/*Определим номера дней начала и окончания рабочей недели*******************************************************************************************************************/
find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval.
else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.
/***************************************************************************************************************************************************************************/

/*Найдем Транз.счет ГК для вход.плат. **************************************************************************************************************************************/
find  sysc 'psingl' no-lock no-error.
if avail sysc then intv = sysc.inval.
/***************************************************************************************************************************************************************************/

{lgps.i }
{ps-prmt.i}
{rmz.f}
/*Определим код текущего филиала нашего банка - принятый в Прагме **********************************************************************************************************/
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    message "Отсутствует запись OURBNK в таблице SYSC!".
    pause.
    undo,return.
end.
ourbank = sysc.chval.
/***************************************************************************************************************************************************************************/

/*Тип срочности платежа ****************************************************************************************************************************************************/
find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    message "Отсутствует запись PRI_PS в таблице SYSC!".
    pause.
    undo,return.
end.
prilist = sysc.chval.
/***************************************************************************************************************************************************************************/

/*Полочки для второй проводки **********************************************************************************************************************************************/
find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    message "Отсутствует запись PS_SUB в таблице SYSC!".
    pause.
    undo,return.
end.
sublist = sysc.chval.
/***************************************************************************************************************************************************************************/

find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    message "Отсутствует запись CLEARING в таблице SYSC!".
    pause.
    undo,return.
end.
clearing = sysc.chval.


if ourbank = clearing then brnch = false. else brnch = true.

/*Найдем Ностро-счет в Центр.Банке  ****************************************************************************************************************************************/
find sysc where sysc.sysc = 'LBNSTR' no-lock no-error.
if not avail sysc then do:
    message  "Отсутствует запись LBNSTR в таблице SYSC!".
    pause.
    return.
end.
lbnstr = sysc.chval .
/***************************************************************************************************************************************************************************/
find first sysc where sysc.sysc = "bankname" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

do transaction :

    find first que where que.remtrz = s-remtrz exclusive-lock no-error.
    if avail que then v-priory = entry(3 - int(que.pri / 10000 - 0.5 ), prilist).
    else v-priory = entry(1, prilist).

    display v-priory with frame remtrz. pause 0.

    find first sysc where sysc.sysc = "RMCASH" no-lock no-error.
    if not avail sysc then do:
        message "Отсутствует запись RMCASH в таблице SYSC!".
        return.
    end.
    v-cashgl = sysc.inval .

    find sysc where sysc.sysc = "CLECOD" no-lock no-error.
    if not avail sysc then do:
        v-text = " Записи CLECOD нет в файле sysc  ". run lgps.
        return.
    end.
    bbcod = substr(trim(sysc.chval),1,6).

    /*u00600*/
    find first remdeb where remdeb.remtrz = s-remtrz no-lock no-error.
    if avail remdeb then do:
        if remdeb.grp <> 0 and remdeb.ls <> 0 then rem_u = true.
    end.

    find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.

    v-knp = ''.
    find first sub-cod where sub-cod.acc = s-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' no-lock no-error.
    if avail sub-cod then v-knp = entry(3,sub-cod.rcode) no-error.
    if error-status:error then do:
        message "Ошибка определения кода назначения платежа!" view-as alert-box error.
        v-knp = ''.
    end.

    v-ocover = remtrz.cover.

    {koval-vlt.i}

    find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) and tarif2.stat = "r" no-lock no-error.
    if avail tarif2 then pakal = tarif2.pakalp.

    display pakal with frame remtrz.


    /* sasco */
    {rcomm-txb.i}

    /* если это валютный платеж на филиал - то поменяем источник и уберем RKO_VALOUT */
    if remtrz.source = "RKOTXB" and que.pid = "G" then do:
        remtrz.source = "O".
        v-text = remtrz.remtrz + " Источник remtrz изменен: RKOTXB -> O".
        run lgps.
        RKO_LOGI = no.
    end.

    if (not RKO_VALOUT()) or QUE_3G or QUE_TXB then do:

        /* mt100_0 :: для всех 3G, всех не-АлматыРКОВалютных                     */
        /*            5.3.1 - "O" - для всех не-АлматыРКОВалюта                  */
        /*            5.3.2 - "G" - для всех не-АлматыРКОВалюта                  */
        /*            5.3.3 - "P" - для всех абсолютно                           */
        /* === 3G or (not RKO_VALOUT)                                            */


        /* mt100_1 :: для ВСЕХ кроме "3G"                                        */
        /* === not QUE_3G                                                        */

        /* RECEIVER  */

        do on error undo , retry:
            display remtrz.tcrc with frame remtrz.
            do on error undo , retry:

                /*  06.09.2002 -- Kanat -- Проверка суммы по кредиту для тенговых платежей --------------------*/
                if remtrz.tcrc = 1 and m_pid = "P" and rnntrue = false then do:
                    update temp_cr_amount with centered overlay row 5 side-label
                    title "Проверка суммы по кредиту" frame credit_amount_check.

                    if remtrz.amt <> temp_cr_amount then do:
                        message "Ошибка! Сумма по кредиту не совпадает с суммой по дебету." view-as alert-box.
                        undo, retry.
                    end.
                end.
                /* -------------- End credit summ check ---------------------------------------------------------*/


                /* -------  Предварительная проверка РНН получателя для тенговых платежей ----- */

                if remtrz.tcrc = 1 and (m_pid = "P" or m_pid = "3g") and rnntrue = false then do:
                    qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
                    if qq <> "" then do:
                        v-9d = substr(qq,index(qq,"/RNN/") + 5).
                        qq = substr(qq,1,index(qq,"/RNN/") - 1).
                        v-9c = substr(qq,1,35).
                        v-9e = substr(qq,36,35).
                    end.

                    if (qq = "" or v-9d = "") and remtrz.info[3] <> "" then do:
                        v-9c  = substr(entry(3,remtrz.info[3],"^"),4,35).
                        v-9d  = substr(entry(4,remtrz.info[3],"^"),4,35).
                        v-9e  = substr(entry(5,remtrz.info[3],"^"),4,35).
                        v-9f1 = substr(entry(6,remtrz.info[3],"^"),4,35).
                        v-9f2 = substr(entry(6,remtrz.info[3],"^"),39,35).
                        v-drg = substr(entry(2,remtrz.info[3],"^"),4,2).
                    end.

                    /*u00600*/
                    if rem_u = true then do:
                        find first debls where debls.grp = remdeb.grp and debls.ls = remdeb.ls.
                        v-9d = debls.rnn. remtrz.ba = debls.acc.
                        if length(trim(remtrz.ba)) <> 20 or not chkaaa20 (trim(remtrz.ba)) then do:
                            message "Счет неверный! Проверьте счет дебитора!". pause 100. return.
                        end.
                    end.

			        /*BIN*/
				    if v-bin = no then do:
                        update v-9d validate( not comm-rnn (v-9d), "Не верный контрольный ключ РНН!") format "x(12)"
                                    with centered overlay row 5 side-label title " Проверка РНН получателя " frame rnncheck .

                        find first taxnk where taxnk.rnn = v-9d use-index rnn no-lock no-error.
                        if available taxnk then v-9c = taxnk.name.
                        else do:
                            find first rnnu where rnnu.trn = v-9d use-index rnn no-lock no-error.
                            if available rnnu then  v-9c = caps(rnnu.busname).
                        end.
                    end.
                    else do:
                        v-9bin = v-9d.
                        update v-9bin validate((chk12_innbin(v-9bin)),'Неправильно введён БИН/ИИН') format "x(12)"
                                    with centered overlay row 5 side-label  title " Проверка БИН/ИИН получателя " frame bincheck.
                        find first rnnu where rnnu.bin = v-9bin use-index bin no-lock no-error.
                        if available rnnu then  v-9c = caps(rnnu.busname).
                        v-9d = v-9bin.
                    end.
                    v-9c = TRIM(v-9c).
                    /* Luiza --- замена название формы собственности на сокращение */
                    do c = 1 to num-entries(full):
                        v-9c = replace(v-9c, entry(c,full), entry(c,mini)).
                    end.
                    /*замена название формы собственности на сокращение */

                    if length (v-9c) > 60 then v-longrnn = true.

                    v-id = v-9d.
                    remtrz.bn[1] = v-9c.
                    remtrz.bn[2] = v-9e.
                    remtrz.bn[3] = "/RNN/" + v-9d.
                    display remtrz.bn[1] remtrz.bn[2] remtrz.bn[3] with frame remtrz.
                    if remtrz.info[3] <> "" then remtrz.info[3] = "11B^3f:" + v-drg + "^9C:" + v-9c + "^9D:" + v-9D + "^9E:" + v-9E + "^9F:" + v-9f1 + v-9f2.
                    rnntrue = true.
                end.
                /* -------  END RNN CHECK  ----- */

                /*iban*/
                if remtrz.tcrc = 1 and rem_u = false then do:
                    if index(remtrz.ba,"/",2) <> 0 then  remtrz.ba = substr(remtrz.ba,1,index(remtrz.ba,"/",2) - 1).
                    pause 0.
                    update remtrz.ba  validate( length(trim(remtrz.ba)) = 20 and chkaaa20 (trim(remtrz.ba)), "Введите счет верно !") format "x(20)"  with centered overlay row 8 side-label title " Введите счет получателя " frame fr_ba .

                    if length(trim(remtrz.ba)) <> 20 then do:
                        message "Счет должен быть 20 цифр !". bell. bell. undo, retry.
                    end.

                    find bankl where bankl.mntrm = substr(remtrz.ba,5,3) no-lock no-error.
                    if avail bankl and  bankl.mntrm ne '470' then remtrz.rbank = bankl.bank.
                    if substr(remtrz.ba,5,3) = '470' then do:
                        find first bankl where bankl.bank = 'TXB' + substr(remtrz.ba,19,2) no-lock no-error.
                        if avail bankl then remtrz.rbank = bankl.bank.
                    end.
                end.

                if remtrz.rbank = "" and m_pid = "I" then remtrz.rbank = ourbank.

                if remtrz.jh2 eq ? and m_pid <> "S" then do:
                    if rem_u = true then remtrz.rbank = debls.bic.
                    update remtrz.rbank validate(chk-gosacc(remtrz.racc, remtrz.rbank), msg) with frame remtrz.   /** valery **/

                    if remtrz.outcode = 8 and not remtrz.rbank begins "RKB" then undo,retry .
                    if  remtrz.rbank = "" and ( not ( m_pid = 'P' or brnch ) or ( ( m_pid = 'P' or brnch ) and remtrz.tcrc = 1)) then undo,retry.
                    if ( m_pid = "3" or m_pid = "3g" ) and remtrz.rbank = ourbank then undo,retry.
                end.

                if remtrz.rbank = "" and brnch then remtrz.rcbank = clearing.
                display remtrz.rcbank with frame remtrz. pause 0.
                if remtrz.rbank <> "" then do:
                    run savelog("3-outg","571. " + remtrz.remtrz ).
                    find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

                    if rem_u = true and avail bankl then do:
                      run savelog("3-outg","575. " + remtrz.remtrz ).
                      remtrz.rcbank = bankl.cbank.
                      s-bankl = remtrz.rbank.
                      remtrz.bb[1] = bankl.name.
                      remtrz.bb[2] = bankl.addr[1].
                      remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
                    end.

                    if remtrz.source  = 'SVL' then do:
                        disp bankl.name label "Наим"  skip
                             bankl.addr[1] label "Адрес" skip bankl.addr[2] label "Адрес"
                             with centered row 6 1 col overlay top-only frame rr.
                    end.

                    if remtrz.rbank <> ""  or bankl.nu = "u" then remtrz.rcbank = caps(bankl.cbank).

                    if remtrz.rbank <> "" and not ( (( remtrz.source begins "P" or remtrz.source = "A" or brnch or
                                            remtrz.source = "IBH" or
                                            remtrz.source = "RKO") or
                                            remtrz.source begins "SVL") and
                                            remtrz.bb[1] + remtrz.bb[2] + remtrz.bb[3] <> "" ) then do:
                        run savelog("3-outg","596. " + remtrz.remtrz ).
                        s-bankl = remtrz.rbank.
                        remtrz.rbank = caps(bankl.bank) .
                        remtrz.bb[1] = bankl.name.
                        remtrz.bb[2] = bankl.addr[1].
                        remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
                    end.
                    else remtrz.rbank = caps(bankl.bank).

                    display remtrz.rbank remtrz.rcbank remtrz.bb with frame remtrz.
                end.
                else if not ourbank = clearing then remtrz.rcbank = clearing.
            end.

            /* RECEIVER - NOT OUR BANK  */
            if ( remtrz.rbank <> ourbank ) then do on error undo, retry:
                find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

                if not brnch and  ( ( avail bankl and bankl.nu <> "u" ) or remtrz.rbank = "" ) and remtrz.jh2 = ? and m_pid <> "S" then do on error undo,retry:
                    update remtrz.rcbank with frame remtrz.
                    if remtrz.rcbank <> "" then do:
                        find first bankl where bankl.bank  = remtrz.rcbank no-lock no-error.
                        if not avail bankl then find first bankl where substr(bankl.bank,7,3) = remtrz.rcbank no-lock no-error.
                    end.
                    if not avail bankl and not ( m_pid = 'P' or brnch ) then undo,retry.

                    if remtrz.source  = 'SVL' and remtrz.rbank <> remtrz.rcbank then do:
                        disp bankl.name label "Наим" skip
                             bankl.addr[1] label "Адрес"  skip bankl.addr[2] label "Адрес"
                             with centered row 6 1 col overlay top-only frame rr.
                    end.

                    if not (remtrz.rcbank =  '' and ( m_pid = 'P' or brnch )) then remtrz.rcbank = caps(bankl.bank).

                    display remtrz.rcbank with frame remtrz.
                end.
            end.

            if not (remtrz.rcbank = '' and (m_pid = 'P' or brnch ) ) then do:
                find first crc where crc.crc = remtrz.tcrc no-lock.
                bcode = crc.code.

                find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error.
                if not avail bankt then do:
                    message "Ошибка! Отсутствует запись в таблице BANKT!".
                    pause.
                    undo,retry.
                end.

                if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
                else remtrz.valdt2 = g-today + bankt.vdate.

                if remtrz.valdt2 = g-today and bankt.vtime < time then remtrz.valdt2 = remtrz.valdt2 + 1.

                repeat:
                    find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
                    if not available hol and weekday(remtrz.valdt2) >= v-weekbeg and weekday(remtrz.valdt2) <= v-weekend then leave.
                    else remtrz.valdt2 = remtrz.valdt2 + 1.
                end.

                if remtrz.jh2 eq ? and m_pid <> "S" then
                        update remtrz.valdt2 with frame remtrz. pause 0 .

                if remtrz.rbank <> 'KKMFKZ2A' and remtrz.valdt2 < remtrz.valdt1 then do:
                message " 2Дата < 1Дата ".
                undo, retry.
                end.

                if remtrz.rbank = 'KKMFKZ2A' and remtrz.valdt2 <> remtrz.valdt1 then do:
                message " Согласно Налоговому Кодексу РК оплата налогов и других обязательных платежей в бюджет должны перечисляться в день совершения операции по списанию денег с банковского счета налогоплательщика. ".
                undo, retry.
                end.

                find first t-bankl where t-bankl.bank = bankt.cbank no-lock.
                if t-bankl.nu = "u" then receiver = "u".
                else receiver = "n" .

                if receiver  ne 'u' and remtrz.info[10] = string(intv) then do:
                    message 'Банк неучастник, и номер счета Г/К = ' intv.
                    pause.
                    undo,retry.
                end.
                remtrz.raddr = t-bankl.crbank.
                remtrz.cracc = bankt.acc.
            end.
            if remtrz.jh2 = ? and not (remtrz.rcbank = '' and (m_pid = 'P' or brnch)) then do on error undo,retry:
                /*
                if remtrz.cracc <> '000885101' then update remtrz.cracc with frame remtrz.
                */
                displ remtrz.cracc with frame remtrz.
                find first bankt where bankt.acc = remtrz.cracc and bankt.crc = remtrz.tcrc and bankt.cbank = remtrz.rcbank no-lock no-error .
                if not avail bankt then do:
                    bell. undo ,retry.
                end.
            end.
            if not (remtrz.rcbank = '' and (m_pid = 'P' or brnch )) then do:
                if bankt.subl = "dfb" then do:
                    find first dfb where dfb.dfb = bankt.acc no-lock.
                    remtrz.crgl = dfb.gl.
                    find tgl where tgl.gl = remtrz.crgl no-lock.
                end.
                if bankt.subl = "cif" then do:
                    find first aaa where aaa.aaa = bankt.acc no-lock.
                    remtrz.crgl = aaa.gl.
                    find tgl where tgl.gl = remtrz.crgl no-lock.
                end.

                display remtrz.cracc remtrz.crgl tgl.sub remtrz.tcrc bcode with frame remtrz.
            end.

            find first bankl where bankl.bank = rbank no-lock no-error.
            if avail bankl and bankl.nu = "u" then do:
                if not (remtrz.rcbank  = '' and ( m_pid = 'P' or remtrz.source  = 'SVL')) then do:
                    if outcode = 8 then do:
                        run savelog("3-outg","711. " + remtrz.remtrz ).
                        remtrz.rsub = "snip".
                        remtrz.bb[1] = bankl.name.
                        remtrz.bb[2] = bankl.addr[1].
                        remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
                    end.
                    else do:
                        do on error undo,retry:
                            run savelog("3-outg","719. " + remtrz.remtrz ).
                            if remtrz.rsub = "" then remtrz.rsub = 'cif'.
                            update remtrz.rsub validate(remtrz.rsub <> "","")  with  frame remtrz.
                            if lookup(remtrz.rsub,sublist) = 0 then undo, retry.
                        end.
                        run savelog("3-outg","724. " + remtrz.remtrz + " rsub=" + remtrz.rsub ).
                        if remtrz.rsub <> "" then do:
                            run savelog("3-outg","726. " + remtrz.remtrz ).
                            if remtrz.rsub <> "snip" then do:
                                if remtrz.ba ne "" then remtrz.racc = remtrz.ba.
                                update remtrz.racc validate(remtrz.racc <> "" and chk-gosacc(remtrz.racc, remtrz.rbank), msg) with frame remtrz.
                                remtrz.ba = /*"/" + */ remtrz.racc .
                            end.
                            remtrz.bb[1] = bankl.name.
                            remtrz.bb[2] = bankl.addr[1].
                            remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
                        end.
                        else do:
                            run savelog("3-outg","737. " + remtrz.remtrz ).
                            remtrz.rsub = "". remtrz.ba = "".
                        end.
                    end.
                end.
            end.
            else remtrz.rsub = "".

            display remtrz.bb remtrz.rsub remtrz.ba remtrz.racc with frame remtrz.
            pause 0.

            find sw-bank where sw-bank.bank = remtrz.rcbank no-lock no-error. /*nan*/
            if available sw-bank then do:
                if sw-bank.bic = ? then Lswtdfb = false. else Lswtdfb = true.
            end.

            if Lswtdfb = false then do:
                find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
                if available aaa then do:
                    find cif of aaa.
                    if available cif and cif.mail <> '' and (cif.geo = '011' or cif.geo = '012' or cif.geo = '013' ) then do:
                        Lswtdfb = true. de6 = 1.
                    end.
                end.
            end.
        end. /* sasco - конец для mt100_0 */

        /*определим как отправлять платеж - клиринг, гросс, свифт******************************************************************************************************************/
        {mesg.i 4823}. /* запрос на клиринг, гросс, свифт и прочее */

        if (Lswtdfb ) and not brnch then remtrz.cover = 4.

        if remtrz.rcbank  = '' and m_pid =  'P' then do:
            remtrz.valdt2  = ?.
            remtrz.racc = ''.
            remtrz.rsub = '' .
            remtrz.cracc = ''.
            remtrz.crgl = 0.
            disp remtrz.valdt2 remtrz.racc remtrz.rsub remtrz.cracc remtrz.crgl with  frame remtrz.
        end.

        find sysc where sysc.sysc = "netgro" no-lock no-error.
        find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
        if avail bankl then do:
            /*09.06.2005 u00121 Проверим, работает ли банк-корреспондент банка получателя по клирингу*/
            find last comm.txb where comm.txb.consolid = true and comm.txb.path matches "*mkb*"  no-lock no-error. /*"конектимся" к Алмате*/
            if avail comm.txb then do:
                if connected ("txb") then disconnect "txb".
                connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                run findkorclr (input remtrz.rbank, output l-clr). /*запускаем программу проверки передав БИК банка получателя поле "БанкП", если банк-корреспондент работает по клирингу вернется значение true*/
                if connected ("txb") then disconnect "txb".
            end.
        end.

        v-smep = no.
        find first smep-bank where smep-bank.bank = remtrz.rbank no-lock no-error.
        if avail smep-bank and smep-bank.smepbank = 'smep' then v-smep = yes.
        if remtrz.tcrc = 1 then do:
            if remtrz.payment <= v-smepamt and v-smep then do:
                 remtrz.cover = 6.
                 v-covermsg = "Банк-получатель работает по СМЭП, платеж будет отправлен по системе СМЭП!".
            end.
            else do:

                if (remtrz.payment >= sysc.deval or bankl.crbank <> "clear") then do:
                    v-covermsg = "Банк-получатель не работает по клирингу, платеж может быть отправлен только по системе GROSS!".
                    remtrz.cover = 2.
                end.
                else do:
                    if l-clr then remtrz.cover = 1. /*если банк-корреспондент работает по клирингу - отправляем клирингом*/
                    else do:
                        v-covermsg = "Банк-корреспондент не работает по клирингу, платеж может быть отправлен только по системе GROSS!".
                        remtrz.cover = 2. /*если не работает то отправляем Гросом*/
                    end.
                end.
            end.
        end.
        else do:
            remtrz.cover = 4.
            v-ocover = 4.
            if v-covermsg <> '' then v-covermsg = ''.
        end.

        if (not brnch and bankl.nu = "u") or (brnch and remtrz.rbank begins "TXB") then do:
            remtrz.cover = 5.
            v-ocover = 5.
            if v-covermsg <> '' then v-covermsg = ''.
        end.
        if remtrz.rsub <> "snip" then do:
            if remtrz.tcrc = 1 then do:
                if remtrz.payment <= v-smepamt and v-smep and remtrz.cover <> 6 then do:
                    remtrz.cover = 6.
                    v-covermsg = "Банк-получатель работает по СМЭП, платеж будет отправлен по системе СМЭП!".

                end.
                else do:
                    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
                    if avail sub-cod and sub-cod.ccode = 's' and remtrz.cover <> 5 and remtrz.cover <> 6 then remtrz.cover = 2.

                    else do:
                        if v-covermsg <> '' then message v-covermsg VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".
                        update remtrz.cover validate(((remtrz.cover ge 1 and remtrz.cover le 2) or (remtrz.cover eq 4 and Lswtdfb ) or (remtrz.cover eq 5) or (remtrz.cover eq 6)),  "") with frame remtrz.
                        if v-ocover <> remtrz.cover then v-ocover = remtrz.cover.
                        if v-covermsg <> '' then v-covermsg = ''.

                   end.
                end.
            end.
            else  update remtrz.cover validate(((remtrz.cover ge 1 and remtrz.cover le 2) or (remtrz.cover eq 4 and Lswtdfb ) or (remtrz.cover eq 5)or (remtrz.cover eq 6)) ,  "") with frame remtrz.

            if remtrz.tcrc = 1 and remtrz.cover = 1 and ((remtrz.payment ge sysc.deval or bankl.crbank ne "clear"  ) or not l-clr) then do: /*если платеж в тенге и транспорт клиринг а сумма привышает допустимую по клирингу или банк корреспондент не работает по нему,
                 или в при любой валюте и сумме банк-корреспондент не работает по клирингу (l-clr = false), то не даем отправлять  */
                if remtrz.payment ge sysc.deval then do:
                    v-covermsg = "Сумма платежа (" + string(remtrz.payment) + ") превышает допустимую по клирингу (" + string(sysc.deval) + ") , можно отправить только по системе GROSS!".
                    remtrz.cover = 2.
                end.
                else if not l-clr or (bankl.crbank <> "clear") then do:
                    if bankl.smepbank = 'smep' and remtrz.payment <= v-smepamt then do:
                        v-covermsg = "Банк-получатель не работает по клирингу, платеж может быть отправлен по системе СМЭП!".
                        remtrz.cover = 6.
                    end.
                    else do:
                        v-covermsg = "Банк-получатель не работает по клирингу, платеж может быть отправлен только по системе GROSS!".
                        remtrz.cover = 2.
                    end.
            end.
        end.

        if remtrz.tcrc = 1 and remtrz.cover = 6 and (remtrz.payment > v-smepamt or not v-smep) then do:
                 if remtrz.payment > v-smepamt then do:
                     if ((remtrz.payment ge sysc.deval or bankl.crbank ne "clear"  ) or not l-clr) then do:
                           if remtrz.payment ge sysc.deval then v-covermsg = "Сумма платежа (" + string(remtrz.payment) + ") превышает допустимую по СМЭП (" + string(v-smepamt) + ") и допустимую по по клирингу (" + string(sysc.deval) + "), можно отправить по системе GROSS!".
                           if not l-clr or (bankl.crbank <> "clear") then v-covermsg = "Банк-получатель не работает СМЭП и по клирингу, платеж может быть отправлен только по системе GROSS!".
                           remtrz.cover = 2.
                     end.
                     else do:
                          find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
                          if avail sub-cod and sub-cod.ccode = 's' then do:
                              v-covermsg = "Сумма платежа (" + string(remtrz.payment) + ") превышает допустимую по СМЭП (" + string(v-smepamt) + ") , можно отправить по GROSS!".
                              remtrz.cover = 2.

                          end.
                          else do:
                              v-covermsg = "Сумма платежа (" + string(remtrz.payment) + ") превышает допустимую по СМЭП (" + string(v-smepamt) + ") , можно отправить по клирингу!".
                              remtrz.cover = 1.
                          end.
                     end.
                 end.
                 if not v-smep then do:
                      if bankl.crbank ne "clear" or not l-clr then do:
                          v-covermsg = "Банк-получатель не работает по СМЭП и по клирингу, платеж может быть отправлен только по системе GROSS!".
                          remtrz.cover = 2.
                      end.
                      else do:
                          find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = "urgency" no-lock no-error.
                          if avail sub-cod and sub-cod.ccode = 's' then do:
                              v-covermsg = "Банк-получатель не работает по СМЭП, платеж может быть отправлен по системе GROSS!".
                              remtrz.cover = 2.
                          end.
                          else do:
                              v-covermsg = "Банк-получатель не работает по СМЭП, платеж может быть отправлен по системе клиринг!".
                              remtrz.cover = 1.
                          end.
                      end.
                 end.
            end.
        end.


        if /*v-ocover = 1 and remtrz.cover = 2*/ v-ocover <> remtrz.cover and v-covermsg <> '' then message v-covermsg VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".
        display remtrz.cover with frame remtrz.

        /*определим как отправлять платеж - клиринг, гросс, свифт******************************************************************************************************************/

        if remtrz.cover = 4 then do:
            if remtrz.outcode = 4 then run swin("200").
            else do:
                if m_pid = 'P' or brnch then de6  = 1 .

                if de6 = 0 then do:
                    do on error undo,retry:
                        form ootchoice with overlay row 10 1 col centered no-labels frame ootfr.
                        display ootchoice with frame ootfr.
                        choose field ootchoice AUTO-RETURN with frame ootfr.
                    end. /* do on error */


                    if FRAME-INDEX = 1 then do:
                        dmt100 = "MT103". /* only one mt103 */
                        if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then run swin("103").
                        if return-value <> "ok" then undo.
                        /* realbic=destination. */
                    end.


                    if FRAME-INDEX = 2 then do:
                        dmt100 = "MT200".
                        run swin("200").
                        if return-value <> "ok" then undo.
                        /* realbic=destination. */
                    end.


                    if FRAME-INDEX = 3 then do:
                        dmt100 = "MT202".
                        run swin("202").
                        if return-value <> "ok" then undo.
                        /* realbic=destination. */
                    end.

                    if FRAME-INDEX = 4 then do:
                        dmt100 = "MT202MT103".
                        l-doubleswift = True.
                        run swin1("202").
                        if return-value <> "ok" then undo.
                        if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then run swin1("103").
                        if return-value <> "ok" then undo.
                    end.
                end.
                else do:
                    dmt100 = "ONE".
                    /* sasco */
                    if (not QUE_3G) or ((QUE_3G or QUE_TXB) and (not RKO_OUT)) then run swin("103").
                end.
            end.

            if lastkey eq keycode('pf4') then undo,retry.
            /*------------------SWIFT STOP  -----------------------*/
        end.
        else do: /* remtrz.cover ne 4 */
            if remtrz.cover ne 21 then do on error undo,retry:
                if remtrz.source = 'SVL' or (remtrz.rsub =  "" and not ( remtrz.cracc = lbnstr and remtrz.cover = 3 )) then do:
                    disp s-bankl remtrz.bb remtrz.ba v-sub  with frame bnkx1.
                end.
                if s-bankl <> "" then do:
                    find bankl where bankl.bank = trim(s-bankl) no-lock no-error.
                    if not avail bankl then
                        find bankl where bankl.bank = bbcod + trim(s-bankl) no-lock no-error.
                    if available bankl then do:
                        run savelog("3-outg","898. " + remtrz.remtrz ).
                        remtrz.bb[1] = bankl.name.
                        remtrz.bb[2] = bankl.addr[1].
                        remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
                    end.
                end.

                /* if not remtrz.ba begins "/" then remtrz.ba = "/" + remtrz.ba. */
                if index(remtrz.ba,"/",2) <> 0 then do:
                    v-sub = substr(remtrz.ba,index(remtrz.ba,"/",2) + 1).
                    remtrz.ba = substr(remtrz.ba,1,index(remtrz.ba,"/",2) - 1).
                end.
                if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then do:
                    v-kind = "Налог".
                    substr(remtrz.rcvinfo[1],index(remtrz.rcvinfo[1],"/TAX/"),5) = " ".
                end.
                else if index(remtrz.rcvinfo[1],"/PSJ/") > 0 then do:
                    v-kind = "Пенсия".
                end.
                else v-kind = "Норм.".

                if remtrz.rsub =  ""  and (remtrz.cracc = lbnstr or brnch) and remtrz.cover <> 4 then do:
                    /* ----------------------------------------- */
                    if (brnch and remtrz.tcrc <> 1 and remtrz.rbank <> clearing) then do:
                        if (remtrz.rbank = 'KKMFKZ2A') and (v-knp begins "9") then update v-sub validate ( /*v-sub = "" or*/ can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации") with frame bnkx1.
                    end.
                    else do:
                        do on error undo, retry:
                            if rem_u = true then if trim(remtrz.ba) begins "/" then remtrz.ba = trim(debls.acc, "/").
                            if trim(remtrz.ba) begins "/" then remtrz.ba = trim(remtrz.ba,"/").
                            if (remtrz.rbank = 'KKMFKZ2A') and (v-knp begins "9") then update v-sub validate ( /*v-sub = "" or*/ can-find (budcodes where code = inte(v-sub) no-lock), " Неверный код бюджетной классификации") with frame bnkx1.
                            if not (length(v-sub) = 6 /*or v-sub = ""*/) then do:
                                message "Введите 6 цифр!". bell. bell.
                                undo, retry.
                            end.
                            else if lookup(v-sub,v-kbkforvin) > 0 and lookup(v-knp,v-knpforvin) > 0 then do:

                                 if remtrz.detpay[1] begins 'VIN' then do:
                                     v-vin = substr(trim(remtrz.detpay[1]),4,index(trim(remtrz.detpay[1]),'/V') - 4).
                                     display  v-vin with frame frame2.
                                 end.

                                 update v-vin with frame bnkx1.
                                 find first vincode where vincode.vin = trim(v-vin) use-index vinbinidx no-lock no-error.
                                 if avail vincode then do:
                                     if remtrz.detpay[1] begins 'VIN' then remtrz.detpay[1] = 'VIN' + vincode.vin + '/V ' + trim(substr(trim(remtrz.detpay[1]),index(trim(remtrz.detpay[1]),'/V') + 2,length(trim(remtrz.detpay[1])))).
                                     else remtrz.detpay[1] = 'VIN' + vincode.vin + '/V ' + trim(remtrz.detpay[1]).
                                 end.
                                 if not avail vincode then do:
                                    find first vincode where vincode.F45 = trim(v-vin) use-index f45idx no-lock no-error.
                                    if avail vincode then do:
                                        if remtrz.detpay[1] begins 'VIN' then remtrz.detpay[1] = 'VIN' + vincode.F45 + '/V ' + trim(substr(trim(remtrz.detpay[1]),index(trim(remtrz.detpay[1]),'/V') + 2,length(trim(remtrz.detpay[1])))).
                                        else remtrz.detpay[1] = 'VIN' + vincode.F45 + '/V ' + trim(remtrz.detpay[1]).

                                    end.
                                 end.
                            end.
                        end.
                    end.
                            /* ----------------------------------------- */
                end.  /*  remtrz.rsub eq  ""  and  ....   */
                else
                if remtrz.rsub <> "snip" then do:
                    disp s-bankl remtrz.bb  remtrz.ba v-sub with frame bnkx1.
                    update remtrz.ba with frame bnkx1.
                    if (remtrz.rbank = 'KKMFKZ2A') and (v-knp begins "9") then update v-sub with frame bnkx1.
                end.

                if v-sub <> "" then remtrz.ba = remtrz.ba + "/" + v-sub .
                if remtrz.rsub = ""  and not ( remtrz.cracc = lbnstr and remtrz.cover = 3 ) or remtrz.rsub <> "snip" then do:
                    if remtrz.fcrc = 1 then do:
                        if (remtrz.rbank = 'KKMFKZ2A') and (v-knp begins "9") then v-kind = "Налог".
                        else v-kind = "Норм.".
                    end.
                    else do:
                        form kindchoice with overlay top-only row 17 1 col column 66 no-labels frame xxx.
                        do on error undo,retry :
                            display kindchoice with frame xxx.
                            choose field kindchoice keys v-kind no-error with frame xxx.
                            v-kind = frame-value.
                            if (index(remtrz.rcvinfo[1],"/PSJ/") > 0 or substr(trim(replace(remtrz.ba,"/"," ")),1,9) matches "...080..." ) and v-kind = "Норм." then do:
                                message "Неверный тип платежа. Счет получателя налоговый. Нажмите F4".
                                pause.
                                undo,retry.
                            end.
                            if (v-sub = "" or index(remtrz.rcvinfo[1],"/PSJ/") > 0 ) and v-kind = "Налог" then do:
                                message "Нет субсчета или платеж пенсионный. Нажмите F4".
                                pause.
                                undo,retry .
                            end.
                        end.
                    end.
                end.

                if v-kind = "Налог" then remtrz.rcvinfo[1] = "/TAX/ " + trim(remtrz.rcvinfo[1]).

                if v-kind = "Пенсия" and trim(remtrz.rcvinfo[1]) ne "/PSJ/ " then do:
                    message "Платеж не зарегистрирован как пенсионный.".
                    undo, retry.
                end.
            end.  /* do on error */

            disp remtrz.bb remtrz.ba v-kind  with frame remtrz.
            pause 0.

            qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
            if index(qq,"/RNN/") <> 0 then do :
                v-id = substr(qq,index(qq,"/RNN/") + 5,13 ).
                qq = substr(qq,1,index(qq,"/RNN/") - 1).
            end.

            if length(qq) > 60 then v-longrnn = true.

            /* sasco сообщение о длинном наименовании получателя 21/10/04 */
            if v-longrnn then message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".

            v-bn[1] = substr(qq,1,35).
            v-bn[2] = substr(qq,36,35).
            v-bn[3] = substr(qq,71,35).
            t-rcv = index(remtrz.rcvinfo[1],"/COD/").
            if t-rcv > 0 then do:
                if substr(remtrz.rcvinfo[1],length(remtrz.rcvinfo[1]),1) <> " " then remtrz.rcvinfo[1] = remtrz.rcvinfo[1] + " " .
                v-inc = substr(remtrz.rcvinfo[1], t-rcv + 5, index(remtrz.rcvinfo[1]," ",t-rcv) - t-rcv - 4) .
                substr(remtrz.rcvinfo[1], t-rcv , index(remtrz.rcvinfo[1]," ",t-rcv) - t-rcv + 1) = " " .
            end.
            if remtrz.rsub ne "snip" then do on error undo, retry:
                if remtrz.ba = "/" or remtrz.ba = "" then do:
                    qq = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] .
                    v-9d = substr(qq,index(qq,"/RNN/") + 5) .
                    qq = substr(qq,1,index(qq,"/RNN/") - 1).

                    /* sasco сообщение о длинном наименовании получателя 21/10/04 */
                    if length (qq) > 60 then v-longrnn = true.
                    if v-longrnn then message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".

                    v-9c = substr(qq,1,35).
                    v-9e = substr(qq,36,35).
                    v-9f1 = substr(qq,71,35).
                    v-9f2 = substr(qq,106,35).
                    update v-9c validate(v-9c <> '',"") v-9e validate(v-9e <> '',"") v-9f1 v-9f2 with centered 1 column overlay row 5 side-label frame frmsnip.
                    qq = "".
                    substr(qq,1,35) = v-9c.
                    substr(qq,36,35) = v-9e.
                    substr(qq,71,35) = v-9f1.
                    substr(qq,106,35) = v-9f2.
                    v-id = v-9d.
                    v-bn[1] = substr(qq,1,60).
                    v-bn[2] = substr(qq,61,60).
                    v-bn[3] = substr(qq,121,60).
                end.
                else do:
                    /*
                    message "1.... cif=" + v-9d + "~nv-bn[1]=" + v-bn[1] "~nv-bn[2]=" + v-bn[2] "~nv-bn[3]=" + v-bn[3] view-as alert-box.
                    if remtrz.rbank begins 'TXB' and length(remtrz.rbank) = 5 then do:
                        if connected ("txb") then disconnect "txb".
                        find first txb where txb.bank = remtrz.rbank and txb.consolid no-lock no-error.
                        if avail txb then do:
                            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                            run findcif_txb(v-9d, v-bin, output v-bn[1]).
                        end.
                        if connected ("txb") then disconnect "txb".
                    end.
                    message "2.... v-bn[1]=" + v-bn[1] "~nv-bn[2]=" + v-bn[2] "~nv-bn[3]=" + v-bn[3] view-as alert-box.
                    */
                    /* sasco сообщение о длинном наименовании получателя 21/10/04 */
                    displ v-bn v-id with centered row 15 1 col overlay top-only frame frminc. pause 0.

                    if v-longrnn then message "~n ~n Длина наименования получателя превышает 60 символов!!!~n ~n " VIEW-AS ALERT-BOX TITLE "В Н И М А Н И Е".

                    update v-bn with centered row 15 1 col overlay top-only frame frminc.

                  find first que where que.remtrz = remtrz.remtrz no-lock no-error.
                  if avail que then v-que = que.pid.

                  if v-que = "P" then do:
                        v-bnlength  = length(v-bn[1]) + length(v-bn[2]) + length(v-bn[3]).

                        if v-bnlength = 0 then
                        repeat:
                            message "Не заполнено поле Получатель" view-as alert-box title "Внимание!".
                            update v-bn with centered row 15 1 col overlay top-only frame frminc.
                            if (length(v-bn[1]) + length(v-bn[2]) + length(v-bn[3])) > 0 then leave.
                        end.

                        v-bnlength  = length(v-bn[1]) + length(v-bn[2]) + length(v-bn[3]).

                        if v-bnlength > 60 then
                        repeat:
                            message "Длина наименования получателя превышает 60 символов" view-as alert-box title "Внимание!".
                            update v-bn with centered row 15 1 col overlay top-only frame frminc.
                            if (length(v-bn[1]) + length(v-bn[2]) + length(v-bn[3])) <= 60 and (length(v-bn[1]) + length(v-bn[2]) + length(v-bn[3])) > 0 then leave.
                        end.
                  end.


                    if v-inc <> "" then remtrz.rcvinfo[1] = "/COD/" + v-inc + " " + trim(remtrz.rcvinfo[1]).
                end.
                if not (remtrz.cracc = lbnstr and remtrz.cover = 3) then if not ((g-fname = "A_KZ" or g-fname = "OUTRMZ") and remtrz.outcode = 3) then update remtrz.ord with frame remtrz.
                remtrz.bn[1] = v-bn[1].
                remtrz.bn[2] = v-bn[2].
                if trim(v-id) = "" then remtrz.bn[3] = v-bn[3].
                else remtrz.bn[3] = v-bn[3] + " " + "/RNN/" + trim(v-id).
            end.  /*   snip   */
            else do:
                if remtrz.info[3] ne "" then do:
                    v-9c  = substr(entry(3,remtrz.info[3],"^"),4,35).
                    v-9d  = substr(entry(4,remtrz.info[3],"^"),4,35).
                    v-9e  = substr(entry(5,remtrz.info[3],"^"),4,35).
                    v-9f1 = substr(entry(6,remtrz.info[3],"^"),4,35).
                    v-9f2 = substr(entry(6,remtrz.info[3],"^"),39,35).
                    v-drg = substr(entry(2,remtrz.info[3],"^"),4,2).
                end.
                if v-drg = "" then v-drg = "01" .
                update v-9c validate(v-9c <> '',"") v-9d validate( not comm-rnn (v-9d), "Не верный контрольный ключ РНН!") v-9f1 v-9f2 v-drg format "99"
                        with centered 1 column  overlay row 5 side-label title " Получатель " frame snip.
                remtrz.info[3] = "11B^3f:" + v-drg + "^9C:" + v-9c + "^9D:" +  v-9D + "^9E:" + v-9E + "^9F:" + v-9f1 + v-9f2.
                remtrz.bn[1] = v-9c.
                remtrz.bn[2] = v-9d.
                remtrz.bn[3] = v-9e.
                if entry(2,remtrz.rcvinfo[1]," ") = "days" then entry(1,remtrz.rcvinfo[1]," ") = v-drg.
                else remtrz.rcvinfo[1] = v-drg + " days " + rcvinfo[1] .
                remtrz.ref =  "single     SNIP payment       " + remtrz.remtrz.
                if remtrz.outcode <> 8 then update remtrz.ord  validate(remtrz.ord ne "","")  with frame remtrz.
            end.
            remtrz.ben[1] = trim(remtrz.bn[1]) + " " + trim(remtrz.bn[2]) + " " + trim(remtrz.bn[3]).
            remtrz.ordcst[1] = remtrz.ord.
            find bankl where bankl.bank = remtrz.sbank no-lock no-error.
            if available bankl and ( remtrz.ordins[1] = "" or ( remtrz.cracc eq lbnstr and remtrz.cover = 3 )) then do:
                if  m_pid <> 'P' or (m_pid = 'P' and remtrz.tcrc <> 1) then do:
                    remtrz.ordins[1] = bankl.name.
                    remtrz.ordins[2] = bankl.addr[1].
                    remtrz.ordins[3] = bankl.addr[2].
                    remtrz.ordins[4] = bankl.addr[3].
                end.
            end.

            if available bankl and remtrz.tcrc = 1 and m_pid  = 'P' then do:
                if ordins[1] = '' then do:
                    find ofc where ofc.ofc = g-ofc no-lock no-error.
                    vpoint = ofc.regno / 1000 - 0.5.
                    vdep   = ofc.regno - vpoint * 1000.
                    find point where point.point = vpoint no-lock no-error.
                    /*remtrz.ordins[1] = point.name.*/
                    find ppoint where  ppoint.depart = vdep and ppoint.point = vpoint no-lock no-error.
                    /*remtrz.ordins[2] = ppoint.name.
                    remtrz.ordins[3] = point.addr[1].  */
                    find sysc where sysc.sysc = "swadd4" no-lock.
                    /*remtrz.ordins[4] = sysc.chval.*/

                    remtrz.ordins[1]  = 'АО ' + v-bankname.
                    remtrz.ordins[2]  = "".  remtrz.ordins[3]  = "". remtrz.ordins[4]  = "".
                end.
                /*
                if remtrz.cover <> 5 then update remtrz.ordins label "Банк отпр." with overlay top-only row 8 1 col centered frame ads.
                */
                displ remtrz.ordins label "Банк отпр." with overlay top-only row 8 1 col centered frame ads.
            end.

            if not (remtrz.cracc = lbnstr and remtrz.cover = 3 ) and m_pid <> 'P' and remtrz.cover <> 5 then
                update remtrz.ordins label "Банк отпр." with overlay top-only row 8 1 col centered frame ads.

            v-detpay = remtrz.detpay[1] + remtrz.detpay[2] + remtrz.detpay[3] + remtrz.detpay[4].

            assign
            v-detpay1[1] = substring (v-detpay,1,50)
            v-detpay1[2] = substring (v-detpay,51,50)
            v-detpay1[3] = substring (v-detpay,101,50)
            v-detpay1[4] = substring (v-detpay,151,50)
            v-detpay1[5] = substring (v-detpay,201,50)
            v-detpay1[6] = substring (v-detpay,251,50)
            v-detpay1[7] = substring (v-detpay,301,50)
            v-detpay1[8] = substring (v-detpay,351) .

            update v-detpay1 help "Нажмите F1 по окончании ввода"  format "x(50)"
            with no-label overlay top-only centered title "Назначение платежа" frame adsd.
            v-detpay = v-detpay1[1] + v-detpay1[2] + v-detpay1[3] + v-detpay1[4] + v-detpay1[5] + v-detpay1[6] + v-detpay1[7] + v-detpay1[8].

            assign  remtrz.detpay[1] = substring (v-detpay,1,70)
                    remtrz.detpay[2] = substring (v-detpay,71,70)
                    remtrz.detpay[3] = substring (v-detpay,141,70)
                    remtrz.detpay[4] = substring (v-detpay,211) .

            if not (remtrz.cracc = lbnstr and remtrz.cover = 3 ) and remtrz.cover <> 5 then do on error undo,retry:
                if remtrz.rcvinfo[1] = "" then remtrz.rcvinfo[1] = remtrz.dracc .

                display      /* O72 - Sender to receivers information */
                        remtrz.rcvinfo[1] format "x(35)"
                        remtrz.rcvinfo[2] format "x(35)"
                        remtrz.rcvinfo[3] format "x(35)"
                        remtrz.rcvinfo[4] format "x(35)"
                        remtrz.rcvinfo[5] format "x(35)"
                        remtrz.rcvinfo[6] format "x(35)"
                        with overlay top-only row 13 column 41 no-labels 1 col title "Межбанковская информация" frame ff72.
                /* O72 - Sender to receivers information */
                /*
                update
                        remtrz.rcvinfo[2]
                        remtrz.rcvinfo[3]
                        remtrz.rcvinfo[4]
                        remtrz.rcvinfo[5]
                        remtrz.rcvinfo[6]
                        with frame ff72.
                */
            end. /* do on error */

            if not (remtrz.cracc = lbnstr and remtrz.cover = 3) and remtrz.cover <> 5 then do:
                /*
                form F71choice with overlay top-only row 17 1 col column 12 no-labels frame x.
                display F71choice with frame x.
                choose field F71choice AUTO-RETURN with frame x.
                remtrz.bi = FRAME-VALUE.
                */
                remtrz.bi = "OUR".
                display remtrz.bi with frame remtrz.
            end.
            else do:
                if remtrz.bi = "" then remtrz.bi = "NON".
            end.
        end. /* cover ne 4  */

        disp remtrz.bb remtrz.ba remtrz.bn remtrz.ord remtrz.bi with frame remtrz.
        if m_pid = "P" then pause.
    end.

    v-bb = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]).

    remtrz.actins[1] = "/" + substr(v-bb,1,35).
    remtrz.actins[2] = substr(v-bb,36,35).
    remtrz.actins[3] = substr(v-bb,71,35).
    remtrz.actins[4] = substr(v-bb,106,35).
    remtrz.actinsact = remtrz.rbank.

    if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank .
    if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .

    find first bankl where bankl.bank = remtrz.scbank no-lock no-error.
    if avail bankl then if bankl.nu = "u" then sender = "u". else sender  = "n".
    find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
    if avail bankl then if bankl.nu = "u" then receiver  = "u". else receiver  = "n".

    if remtrz.scbank = ourbank then sender = "o".
    if remtrz.rcbank = ourbank then receiver  = "o".

    find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver no-lock no-error.
    if avail ptyp then remtrz.ptype = ptyp.ptype.
    else remtrz.ptype = "N".

    /* ------------ SASCO ******************** */
    /* принудительно пишем тип = "6" так как это платеж
    типа "Наш Банк -- Не Участник"
    (в remtrz нет достаточно информации для автом. определения) */
    if RKO_VALOUT() and (not (QUE_3G or QUE_TXB)) then remtrz.ptype = "6".
    else do:
        if sender = "o" and receiver = "o" then remtrz.ptype = "M".
        find first ptyp where ptyp.ptype = remtrz.ptype no-lock.
        find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error.
        display  remtrz.ptype ptyp.des remtrz.cover with frame remtrz.
    end. /* --- sasco ***  */

    run rmzque.

    v-text = remtrz.remtrz + " тип=" + remtrz.ptype + " обработан "   + g-ofc  + ' ' + remtrz.rcbank.
    run lgps.
    release logfile.
end.

do transaction:
    if remtrz.ptype = "" then do:
        message " Не определен тип платежа! Отправка невозможна.". pause.
        return .
    end.

    yn = false .

    /* sasco */
    /* если не 3G или АлматыРКОВалюта */
    if not QUE_3G and RKO_VALOUT() then run out-mt100. /* BY SASCO */
    if (QUE_3G or QUE_TXB) and remtrz.source = "RKO" then do:
        remtrz.source = "O".
        v-text = remtrz.remtrz + " Источник remtrz изменен: RKO -> O".
        run lgps.
    end.


    if ( m_pid = "3g" or m_pid = "G" or (m_pid = "3" and remtrz.source = "SW")) and sw then message "Обработать?" update yn.

    if yn then do:
        find first que where que.remtrz = s-remtrz exclusive-lock no-error.
        if avail que and ( que.pid ne m_pid or que.con eq "F" ) then do:
            message "Не владелец! Отправка невозможна.". pause.
            release que.
            undo,return.
        end.

        if avail que then do:
            find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
            /* by sasco :  проверка OUTGOING для всех платежей кроме RKO && TXB00
            так как у них не вводится банк корр и другие данные :-) */
            if (remtrz.valdt2 eq ? or remtrz.cracc eq "" or remtrz.crgl eq 0 or remtrz.rcbank eq "") and (not RKO_VALOUT() or QUE_3G ) then do:
                message "Вы должны сначала выполнить OUTGOING!".  pause.
                release que.
                release remtrz.
                undo,return.
            end.

            /*проверка бенефициара на терроризм*/

            if remtrz.jh3 = ? or remtrz.jh3 <= 1 then do: /* Luiza, если у rmz jh3 > 1 значит  получатель проверку уже прошел в  jou документе  */
                if remtrz.sbank = ourbank then do:
                    v-benCountry  = ''.
                    v-benName = ''.
                    v-senderCountry = ''.
                    v-senderName = ''.
                    v-benNameList = ''.
                    v-senderNameList = ''.
                    v-errorDes = ''.
                    v-operIdOnline = ''.
                    v-operStatus = ''.
                    v-operComment = ''.
                    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
                    if avail sub-cod and sub-cod.ccode <> 'msc' then v-benCountry = sub-cod.ccode.

                    v-benName = trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2])).
                    if trim(v-benName) <> '' then do:
                        if trim(v-benCountry) <> '' then do:
                            find first code-st where code-st.code = v-benCountry no-lock no-error.
                            if avail code-st then v-benCountry = code-st.cod-ch.
                        end.
                        find first pksysc where pksysc.sysc = 'kfmOn' no-lock no-error.
                        if avail pksysc and pksysc.loval then do:

                            display "" skip(2) "          ПОДОЖДИТЕ" skip "    ИДЕТ ПРОВЕРКА КЛИЕНТА     " skip(2) "" with frame f1 centered overlay row 10 title 'ВНИМАНИЕ'.

                            run kfmAMLOnline(remtrz.remtrz,
                                              v-benCountry,
                                              v-benName,
                                              v-benNameList,
                                              '1',
                                              '1',
                                              v-senderCountry,
                                              v-senderName,
                                              v-senderNameList,
                                              output v-errorDes,
                                              output v-operIdOnline,
                                              output v-operStatus,
                                              output v-operComment).
                            hide frame f1 no-pause.
                            if trim(v-errorDes) <> '' then do:
                                message "Ошибка!~n" + v-errorDes + "~nПри необходимости обратитесь в ДИТ" view-as alert-box title 'ВНИМАНИЕ'.
                                return.
                            end.
                            if v-operStatus = '0' then do:
                                run kfmOnlineMail(remtrz.remtrz).
                                message "Операция приостановлена для анализа! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                                return.
                            end.
                            if v-operStatus = '2' then do:
                                run kfmOnlineMail(remtrz.remtrz).
                                message "Проведение операции запрещено! Обратитесь в службу Комплаенс" view-as alert-box title 'ВНИМАНИЕ'.
                                return.
                            end.
                        end.
                    end.
                end.
            end. /* Luiza */
            scod = "ok".

            if (not brnch) and (not RKO_VALOUT () ) then do:
                if remtrz.cover lt 4 then do:
                    v-text = remtrz.remtrz + " TELEX сообщение сформированно " + g-ofc.
                end.
                else do:
                    if remtrz.cover = 4 /*ja*/ and not brnch /*ja*/ then do:
                        if remtrz.outcode = 4 or dmt100 = "MT200" then do:
                            RUN swmt-cre(s-remtrz,g-today,"send","200",s-sqn,scod).
                            if scod = "ok" then do:
                                v-text = remtrz.remtrz + " MT200 SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                run lgps.
                            end.
                        end.
                        else
                        case dmt100:
                            when "MT100" then do:
                                s-sqn = "".
                                RUN swmt-cre(s-remtrz,g-today,"send","100",s-sqn,scod).
                                if scod = "ok" then do:
                                    v-text = remtrz.remtrz + " SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                    run lgps.
                                end.
                                pause 0.
                            end.
                            when "MT202" then do:
                                RUN swmt-cre(s-remtrz,g-today,"send","202",s-sqn,scod).
                                if scod = "ok" then do:
                                    v-text = remtrz.remtrz + " MT202 SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                    run lgps.
                                end.
                            end.
                            when "MT103" then do:
                                s-sqn = "".
                                RUN swmt-cre(s-remtrz,g-today,"send","103",s-sqn,scod).
                                if scod = "ok" then do:
                                    v-text = remtrz.remtrz + " SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                    run lgps.
                                end.
                                pause 0.
                            end.
                            when "MT202MT103" then do:
                                RUN swmt-cre1(s-remtrz,g-today,"send","202",s-sqn,scod).
                                if scod = "ok" then do:
                                    v-text = remtrz.remtrz + " MT202 SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                    run lgps.
                                end.
                                s-sqn = "" .
                                RUN swmt-cre1(s-remtrz,g-today,"send","103",s-sqn,scod).
                                if scod = "ok" then do:
                                    v-text = remtrz.remtrz + " SWIFT " + s-sqn + " сообщение сформированно " + g-ofc.
                                    run lgps.
                                end.
                                pause 0.
                            end.
                        end case.
                    end.
                end.
            end.

            if (scod ne "ok") and (remtrz.cover = 4) and not brnch then do:
                v-text = "Ошибка SWSEND! SWIFT сообщение не было отправлено для " + remtrz.remtrz + ".".
                run lgps.
                message v-text. pause.
            end.
            else do:
                que.pid = m_pid.
                /* sasco -  проверка на РКО и TXB00 */
                if RKO_VALOUT() = true then do:
                    if remtrz.tcrc = 1 then que.rcod = "0".
                    else que.rcod = "1".
                end.
                else que.rcod = "0".

                v-text = " Отсылка " + remtrz.remtrz + " по маршруту , код возврата = " + que.rcod.
                run lgps.
                que.con = "F".
                que.dp = today.
                que.tp = time.

                release que.
                remtrz.cwho = g-ofc.

                {koval-vsd.i}
            end.
        end.

        pause 0.
    end.
end.


