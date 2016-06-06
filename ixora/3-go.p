/* 3-go.p
 * MODULE
        Операции
 * DESCRIPTION
        Акцепт
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
 * BASES
        BANK COMM IB
 * CHANGES
        29.12.2003 nadejda - запрет на платежи в пользу Казначейства 31 января
        03/03/2004 nataly  - обработка платежей типа MDD
        06.05.2004 nadejda - проверка правильности КБК и реквизитов НК для налоговых платежей
        12.05.2004 isaev   - проверка КНП для налоговых платежей (должен начинатся с 9*)
        05.07.2004 tsoy    - проверка на существование платежа
        06.09.04 saltanat  - добавила отправку SWIFT сообщения на филиалах для валютных платежей,
                             акцептуется в п.5-2-11
        16/09/04 suchkov   - Перенес release в самый конец
        09/06/05 sasco     - исправил обработку реквизитов НК
        27.12.05 dpuchkov  - добавил проверку SCLEAR\SGROSS при акцепте инкассовых в зависимости от времени.
        21.02.05 dpuchkov  - если m_pid = "INK" в зависимости от времени акцепта ставим remtrz.rtim = time
        14.08.06 tsoy      - не оправляем на 2w если нет денег
        13.09.06 tsoy      - Добавил исключение для Астаны
        16.10.06 ten       - проставил в поле remtrz.info[4] ФИО офицера акцептовавшего платеж
        06/10/2008 galina - запретила акцепт платежей до прохождения валютного контроля
        12.11.2008 galina - убрала проверку на ЦО для валютного контроля
        20.04.2009 galina - валютный конроль по субботам не включать
        26.06.2009 galina - убрала транзакцию внутри транзакции
        30/03/2010 galina - обработка для фин.мониторинга согласно ТЗ 623 от 19/02/2010
        19/04/2010 galina - добавила для фин.мониторинга согласно ТЗ 650 от 19/02/2010
        28/04/2010 galina - добавила подозрительные операции
        29/04/2010 galina - пропускаем подозрительные операции, если они удалены из фин.мониторинга
        01/06/2010 galina - убрала транзакции внутри транзакции
        24/06/2010 galina - добавила определение страны резиденства для нерезидента
        03/07/2010 galina - поправила declcparam
        15/07/2010 galina - online запрос по спискам террористов
        20/07/2010 galina - добавила переменную s-operType
        22/07/2010 galina - добавила парметр kfmprt_cre
        28/07/2010 galina - добавила переводы благотвор.организаций для фин.мониторинга
                            проверяем логическую переменную kfmOn в справочнике pksysc перед запросом в AML
        09/11/2010 madiyar - отключаем фин. мониторинг (пока только закомментил, на всякий случай)
        01/02/2011 madiyar - поправки по фин. мониторингу
        25.03.2011 id00004 - запись в историю логина проводившего акцепт платежа
        06.10.2011 id00004 - добавил обработку ситуации для интернет банкинга если запустили программу на тестовой базе
        21.11.2011 id00004 - добавил обработку ситуации если есть невеный КНП для интернет банкинга
        10.12.2011 id00004 - добавил проверку на ИИН-БИН получателя для интернет банкинга
        10.12.2011 id00004 - добавил проверку на ИИН-БИН сотрудиков предприятия для MT-102 для интернет банкинга
        27.12.2011 id00004 - добавил проверку на ИИН-БИН отправителя для интернет банкинга
        04.01.2011 id00004 - добавил проверку на РНН отправителя для интернет банкинга
        04.01.2011 id00004 - убрал проверку на РНН отправителя для интернет банкинга т.к некоторые компании платят за свои представительства под другим РНН.
        28.03.2012 aigul - увеличила время для клиринга до 2.45
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        05/09/2012 dmitriy - если бенефициар клиент банка, то проверка реквизитов по Наименованию, РНН, счету, Кбе
        06/09/2012 dmitriy - убрал проверку бенефициара по наименованию
        11/10/2012 Luiza - ТЗ изменение пороговых сумм c 2000000 до 6000000 для кнп 119
        11.10.2012 Lyubov - ТЗ 1528, снимаем комиссию за зачисление на ПК
        12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
        23/10/2012 id00810 - ТЗ 1554, проверка данных зарплатных платежей
        05/11/2012 id00810 - ТЗ ,корректировка проверки данных (если платеж принят в формате OW, то не проверяется РНН/ИИН в виду отсутствия этих полей)
        06/11/2012 id00810 - ТЗ 1557, проверка данных платежа со списком на конкр.сч.KZ81470192870A023308, создание записи в таблице clsdp
        30/11/2012 id00810 - проверка ФИО в зарплатных платежах с учетом имеющегося в них символа ? вместо казахских символов
        04.01.2013 Lyubov - добавила команду trim при сравнении строк с ИИН/БИН, т.к. возникли ошибки
        04.01.2013 Lyubov - в соответствии с СЗ №166 убрала фразу "обратитесь в ОД по телефонам ..."
        11.01.2013 evseev - tz-1656
        14/02/2013 Luiza - ТЗ 1715 проверка даты валютирования.
        15/02/2013 Luiza - ТЗ 1715 проверка даты валютирования.
        21.02.2013 Anton - добавил ps-prmt.i, исправлен косяк с доступами
        04/03/2013 Luiza  - ТЗ 1736 проверка БИН налоговых органов
        02.05.2013 Lyubov - ТЗ №1807, перенесла проверку достаточности средств из snx1
        14/05/2013 Luiza -  ТЗ № 1838 все проверки по финмон отключаем, будут проверяться в AML
        28.05.2013 Lyubov - ТЗ №1853, зачисление на активные и заблокированные карты (pccards.sts <> 'Closed')
        31.05.2013 damir - Внедрено Т.З. № 1773. Добавлена запись pcupdarp.
        01.07.2013 Lyubov - ТЗ 1766, добавлен поиск ПК по ИИН
        05.07.2013 Lyubov - ТЗ 1953, округляем расчитанную сумму комиссии при поверке средств до сотых
        31.07.2013 Lyubov - ТЗ 1996, ФИО из платежа сверяется в таблицей pcstaff0
        06/09/2013 galina - ТЗ2079 убрала вопрос на формирование свифт по платежам в валюте для ресурса IBH
        20/09/2013 Luiza  - ТЗ 1916 проверка проставления вида документа
        24/09/2013 Luiza  - ТЗ 2047 при поступлении файла на зачисление проверка ФИО с таблицей соответствия символов
        24.09.2013 Lyubov - ТЗ 1986, возврат зачислений по ошибочным клиентам
        03.10.2013 damir - Внедрено Т.З. № 2124..
        10.10.2013 Lyubov - ТЗ 2135, дополнительно сохраняем в payreturn ИИН и ФИО
        16.10.2013 Lyubov - ТЗ 2149, сверка данных платежа производится с данными только основной карты
*/
{yes-no.i}
{global.i}
{lgps.i}
{chk-rbal.i}
{findstr.i}
{kfm.i "new"}
{srvcheck.i}
{chbin.i}
{chk-rekv.i}
{ps-prmt.i}
def shared var s-remtrz like remtrz.remtrz  .
def shared var reas as char label "Причина отвержения " format "x(40)" no-undo.
def var yn       as log initial false format "да/нет" no-undo.
def var ok       as log  no-undo.
def var ourbank  as cha no-undo.
def var clearing as cha no-undo.
def var vbal     as decimal no-undo.
def var valcntrl as logical no-undo.
def var brnch as log initial false  no-undo.
def var v-acc as char no-undo.
def var v-rnn as char no-undo.
def var v-kbk as integer no-undo.
def var v-swif as logi init true no-undo.
def var v-knp as char init '' no-undo.
def var v-pr as log init 'true' no-undo.

/*galina фин.мониторинг исходящих платежей*/
def var v-monamt as deci no-undo.
def var v-str as char no-undo.
def var v-kfm as logi no-undo init no.
def var v-kfm1 as logi no-undo init no.
def var v-kfm2 as logi no-undo init no.
def var v-kfm3 as logi no-undo init no.
def var v-kfm4 as logi no-undo init no.
def var v-kfm5 as logi no-undo init no.
def var v-kfm6 as logi no-undo init no.
def var v-kfm7 as logi no-undo init no.
def var v-kfm8 as logi no-undo init no.
def var v-kfm9 as logi no-undo init no.
def var v-kfm10 as logi no-undo init no.
def var v-kfm11 as logi no-undo init no.
def var v-kfmrem as char no-undo.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-clnameF as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-num as inte no-undo.
def var k as inte no-undo.
def var v-operId as integer no-undo.
def var v-bdt as char no-undo.
def var v-bplace as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-mess as integer no-undo.
def buffer b-remtrz for remtrz.
def buffer b-aaa for aaa.
def buffer b-cif for cif.
def buffer b-codfr for codfr.
def buffer b-sysc for sysc.
def var v-susp as integer no-undo.
def var v-country2 as char.
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
def var pf_file as char init "" no-undo.
def stream str41.
def var v-strs as char no-undo.
def var v-m2     as char . /* v-rnn    */
def var v-names      as char no-undo.
def var v-namef      as char no-undo.
def var v-namem      as char no-undo.


/*--- для проверки реквизитов бен-ра ---*/
def new shared var v-bnrnn as char.
def new shared var v-bncif as char.
def new shared var v-bnacc as char.
def new shared var v-bnkbe as char.
def new shared var v-find as logi.

def var v-bnrnn1 as char.
def var v-bncif1 as char.
def var v-bnacc1 as char.
def var v-bnkbe1 as char.

def var v-bn as char.
def var v-mes as char.
def var v-line1 as char.
def var v-line2 as char.
def var v-our_br as int.
def var v-aaa as char.

def new shared var s-jh like jh.jh.
def var v-amt as deci.
def var v-param as char no-undo.
def var v-trx   as char no-undo.
def var vdel    as char no-undo initial "^".
def var rcode   as int  no-undo.
def var rdes    as char no-undo.
def var v-kont  as inte no-undo.
def var v-psj   as logi no-undo.
def var v-sparp as char no-undo.
def var v-pc    as logi no-undo.
def var v-21    as char no-undo.
def var v-fm    as char no-undo.
def var v-nm    as char no-undo.
def var v-ft    as char no-undo.
def var v-la    as char no-undo.
def var v-32b   as char no-undo.
def var v-sumerr as deci no-undo.
def var v-spnom as char no-undo.
def var v-txt   as char no-undo.
def var v-txt1  as char no-undo.
def var v-arp   as char no-undo init 'KZ81470192870A023308'.
def var v-err   as logi no-undo.
define variable v_kbe as char.
define variable v_knp as char.
define variable check-bin as char.
define variable check-bn as char.
define variable v-ks     as char format 'x(6)'.
def var v-sumconv as deci no-undo.

def buffer b-crcpro for crcpro.

find b-sysc where b-sysc.sysc = "pcupdarp" no-lock no-error.
if avail b-sysc then v-sparp = trim(b-sysc.chval).
else do:
    message "Не найдены транзитные счета для пополнения з/п в sysc" view-as alert-box information buttons ok.
    return.
end.

def var v-bal     as decim.   /*Остаток*/
def var v-avl     as decim.   /*Доступный остаток*/
def var v-hbal    as decim.   /*Заморож. средства*/
def var v-fbal    as decim.   /*Задержанные средства*/
def var v-crline  as decim.   /*Откр.кредитная лин.*/
def var v-crlused as decim.   /*Использ.кред. линия*/
def var v-ooo     as char .  /*Номер овердрафтного счета*/
def var v-gaaa    as char format "x(20)".

function kzru returns char (vbank as char,vcif as char,str as char,str1 as char).
    define var outstr as char.
    def var kz as char .
    def var ru as char .
    def var i as integer.
    def var j as integer.
    def var ns as log init false.
    def var slen as int.
    /*str = caps(str).*/
    slen = length(str).
    find first pcsootv where pcsootv.bank = vbank and pcsootv.cif = vcif no-lock no-error.
    if not available pcsootv or trim(pcsootv.kz) = "" or trim(pcsootv.ru) = "" then outstr = str.
    else do:
        repeat i = 1 to slen:
            repeat j = 1 to num-entries(trim(pcsootv.kz),","):
                if substr(str,i,1) <> substr(str1,i,1) then do:
                    if substr(str,i,1) = entry(j,trim(pcsootv.ru)) then do:
                        outstr = outstr + entry(j,trim(pcsootv.kz)).
                        ns = true.
                    end.
                end.
            end.
            if not ns then outstr = outstr + substr(str,i,1).
            ns = false.
        end.
        outstr = Caps(substring(outstr,1,1)) + substring(outstr,2,length(outstr) - 1).
    end.
    return outstr.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " Записи OURBNK нет в sysc файле !!".
    pause.
    undo,return.
end.
ourbank = sysc.chval.

define frame fbn
    v-line1  format "x(50)" label "----" skip
    v-bnrnn format "x(50)" label "ИИН/БИН " skip
    /*v-bncif format "x(50)" label "cif " skip*/
    v-bnacc format "x(50)" label "acc " skip
    v-bnkbe format "x(50)" label "Кбе " skip
    v-line2  format "x(50)" label "----" skip
    v-bnrnn1 format "x(50)" label "ИИН/БИН 1" skip
    /*v-bncif1 format "x(50)" label "cif 1" skip*/
    v-bnacc1 format "x(50)" label "acc 1" skip
    v-bnkbe1 format "x(50)" label "Кбе 1"
with side-labels centered row 5.
/*--------------------------------------*/


Message " Вы уверены ? " update yn .
if not yn then return.

if yn then do:
  /* 05.07.2004 tsoy при отзыве платежа в ИО удаляется remtrz, здесь проверяется не удален ли он */
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if not avail remtrz then do:
        message skip "Платеж не найден. Возможно клиент уже отозвал этот платеж  " skip(1) view-as alert-box title " ОШИБКА ! ".
        return.
    end.
    if remtrz.source = "INK" then do:
        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz and sub-cod.d-cod = 'pdoctng' no-lock no-error.
        if not avail sub-cod or sub-cod.ccode  = "msc" then do:
            message "В меню <Справочник> не заполнен признак вида документа!" view-as alert-box.
            undo,return.
        end.
    end.
    /* Luiza проверка даты валютирования */
    if remtrz.valdt2 < g-today and remtrz.source = "IBH" then do:
        Message " Дата валютирования меньше даты текущего опер дня. Акцепт невозможен! " view-as alert-box.
        undo,return.
    end.
    if remtrz.valdt2 - remtrz.valdt1 > 10 and remtrz.source = "IBH" then do:
        Message " Дата валютирования превышает 10 календарных дней. Акцепт невозможен! " view-as alert-box.
        undo,return.
    end.

    /*---------------------------------------------------------------------------*/

/*****************************************************/
    /* проверка БИН налоговых органов */
    v_kbe = "".
    v_knp = "".
    check-bin = "".
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod then do:
        v_kbe = entry(2,sub-cod.rcode,',').
        v_knp = entry(3,sub-cod.rcode,',').
    end.
    else do:
        message "Не заполнены КБЕ и КНП, операция невозможна!" view-as alert-box.
        undo,return.
    end.
    if v_kbe = "11" and v_knp begins "9" then do:
        check-bin = "".
        check-bn = trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3]).
        if index(check-bn, "/RNN/") > 0 then check-bin = substring(check-bn,index(check-bn, "/RNN/") + 5,12).
        if check-bin = "" then do:
            message "БИН не найден, операция невозможна!" view-as alert-box.
            undo,return.
        end.
        find first taxnk where taxnk.bin = check-bin no-lock no-error.
        if not available taxnk then do:
            message "БИН отсутствует в справочнике налоговых органов, операция невозможна!" view-as alert-box.
            undo,return.
        end.
        if not index(trim(remtrz.ba), "KZ24070105KSN0000000") > 0 then do:
            message "Неверный счет получателя, операция невозможна!" view-as alert-box.
            undo,return.
        end.
         if trim(remtrz.rbank) <> "KKMFKZ2A" then do:
            message "Неверный БИК получателя, операция невозможна!" view-as alert-box.
            undo,return.
        end.
        if index(remtrz.ba, "KZ24070105KSN0000000/") <= 0 then v-ks = "" .
        else v-ks = substring(remtrz.ba,index(remtrz.ba, "KZ24070105KSN0000000/") + 21,6).
        find first budcodes where budcodes.code = inte(v-ks) no-lock no-error.
        if not available budcodes or v-ks = "" then do:
            message "Неверный код бюджетной классификации, операция невозможна!" view-as alert-box.
            undo,return.
        end.
    end.
/*****************************************************/
  /* 29.12.2003 nadejda - запрет на платежи в пользу Казначейства 31 января */
  /*if month(remtrz.valdt1) = 12 and day(remtrz.valdt1) = 31 and index(remtrz.rcvinfo[1], "/TAX/") <> 0  then do:
     message skip "Запрещены казначейские платежи в последний день года!" skip(1) view-as alert-box title " ОШИБКА ! ".
     return.
  end.
  */
  /* 30.12.2003 nadejda - проверка на просрочку на счетах Д/В потребкредитования - если да, то дебетовые операции запрещены */
    run chkdolg (remtrz.sacc, output vbal).

  /* если есть просрочка - запретить транзакцию ! */
    if vbal > 0 then do:
        message skip " Счет" remtrz.sacc "принадлежит Департаменту Потреб.кредитования," skip
            " по связанному кредиту обнаружена просроченная задолженность !" skip(1)
            " Дебетовые операции по счету запрещены, кроме погашения ссуды ! " skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
        return.
    end.
    vbal = 0.
  /**************************************************/

/* контроль на заполнение кода ЕКНП */
    find sub-cod where sub-cod.acc = s-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
    if not avail sub-cod then v-pr = false.
    else if (entry(1,sub-cod.rcode,',') eq ''  or entry(2,sub-cod.rcode,',') eq '' or entry(3,sub-cod.rcode,',') eq '') then v-pr = false.
    if not v-pr then do:
            message "Необходимо проставить коды ЕКНП (см.опцию 'Справочник')!".
            pause.
            return.
    end.

    v-knp = entry(3, sub-cod.rcode, ',').
 end.

/* Только инкассовые */
if m_pid = "INK" then do transact:
    find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
    if time < 53100 then do: remtrz.cover = 1. /* SCLEAR00 */ remtrz.rtim = time. end.
                    else do: remtrz.cover = 2. /* SGROSS00 */ remtrz.rtim = time. end.
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
end.
/* Только инкассовые */




/*** KOVAL Контроль на остаток дебитуемого счета RMZ ***/
if m_pid = "3A" then do:
    vbal = chk-rbal(s-remtrz).
    if vbal = ? or vbal < 0 then do:
        message "Ошибка контроля остатка (" + string(vbal) + ")" view-as alert-box.

        v-text = s-remtrz + " 3-go: Ошибка контроля остатка (" + string(vbal) + ") с помощью chk-rbal.i".
        run lgps.
        return.
    end.

    /*проверка достаточности средств на счете*/
    if can-do(v-sparp,remtrz.racc) then do:
        find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
        if avail aaa and aaa.sta = "A" then do:
            find first tarifex where tarifex.cif = aaa.cif and tarifex.crc = remtrz.fcrc and tarifex.str5 = '058' no-lock no-error.
            if not avail tarifex then do:
                find first tarif2 where tarif2.crc = remtrz.fcrc and tarif2.str5 = '058' no-lock no-error.
                if avail tarif2 then do:
                    if tarif2.proc > 0 then do:
                        v-amt = remtrz.amt * (tarif2.proc / 100).
                        if tarif2.min1 > 0 and v-amt < tarif2.min1 then v-amt = tarif2.min1.
                        if tarif2.max1 > 0 and v-amt > tarif2.max1 then v-amt = tarif2.max1.
                    end.
                    else v-amt = tarif2.ost.
                    v-kont = tarif2.kont.
                end.
                else message "Не найден тариф для снятия комиссии!" view-as alert-box.
            end.
            else do:
                if tarifex.proc > 0 then do:
                    v-amt = remtrz.amt * (tarifex.proc / 100).
                    if tarifex.min1 > 0 and v-amt < tarifex.min1 then v-amt = tarifex.min1.
                    if tarifex.max1 > 0 and v-amt > tarifex.max1 then v-amt = tarifex.max1.
                end.
                else v-amt = tarifex.ost.
                v-kont = tarifex.kont.
            end.
            v-amt = round(v-amt,2).
            find first pcsootv where pcsootv.bank = ourbank and pcsootv.cif = aaa.cif no-lock no-error.
            if available pcsootv and trim(pcsootv.aaa) <> "" then do: /* достаточность средств для комиссии проверяем на счете головной компании */
                find first b-aaa where b-aaa.aaa = trim(pcsootv.aaa) no-lock no-error.
                if available b-aaa and (b-aaa.cbal - b-aaa.hbal) < v-amt then do:
                    message ' Недостаток средств на счете ' + trim(pcsootv.aaa) + ' головной организ.для списания комиссии по зарп.проекту ' view-as alert-box.
                    return.
                end.
            end.
            else do: /* иначе проверяем на текущем счете */
                if  (aaa.cbal - aaa.hbal) < (v-amt + remtrz.amt) /*vbal - v-amt < 0*/ then do:
                    message ' Недостаток средств на счете! Необходимая сумма ' v-amt + remtrz.amt view-as alert-box.
                    return.
                end.
            end.
        end.
    end.
end.
/*** KOVAL Контроль на остаток дебитуемого счета RMZ ***/

 def buffer b-crcc for crc.

 DEFINE VARIABLE ptpsession AS HANDLE.
 DEFINE VARIABLE messageH AS HANDLE.
 def var v-s2     as char .
 def var v-val    as logical init false.
 def var i  as integer .
 def var v-bbbb   as char.
/*Новый интернет банкинг*/
if m_pid = "3A" then do transaction:
    find last netbank where netbank.rmz = remtrz.remtrz exclusive-lock no-error.
    if avail netbank then do:
        /* проверка на ИИН/БИН  */
        /* ------------- dmitriy ------------- */
        if remtrz.rbank begins "TXB" then do:
            v-line1 = "-----Данные из карточки клиента------".
            v-line2 = "-----Данные из документа rmz---------".

            find first cmp no-lock no-error.
            if avail cmp then v-our_br = cmp.code.

            v-find = no.
            v-aaa = remtrz.ba.

            find txb where txb.consolid and txb.bank = remtrz.rbank no-lock no-error.
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run bn-check(v-aaa).
            disconnect "txb".

            if v-find = yes then do:
                v-bnacc1 = remtrz.ba.

                v-bn = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
                i = r-index( v-bn, '/RNN/' ).
                if i <> 0 then do:
                    v-bnrnn1 = trim( substring(v-bn, i + 5, 12 )).
                    v-bncif1 = trim( substring(v-bn, 1, i - 1)).
                end.

                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then v-bnkbe1 = substr(sub-cod.rcode,4,2).

                v-mes = "".
                if v-bnrnn <> v-bnrnn1 then v-mes = "ИИН/БИН".
                /*if v-bncif <> v-bncif1 then v-mes = v-mes + " Наименование".*/
                if v-bnacc <> v-bnacc1 then v-mes = v-mes + " Счет".
                if v-bnkbe <> v-bnkbe1 then v-mes = v-mes + " Кбе".

                if v-mes = "" then do:
                    v-mes = "Все данные введены правильно.".
                    message v-mes view-as alert-box  buttons ok title "" .
                end.
                else do:
                    display v-line1 v-bnrnn /*v-bncif*/ v-bnacc v-bnkbe v-line2 v-bnrnn1 /*v-bncif1*/ v-bnacc1 v-bnkbe1 with frame fbn.
                    v-mes = v-mes + " указаны неверно. Документ не может быть отправлен!".
                    message v-mes view-as alert-box  buttons ok title "" .
                    return.
                end.
            end.
            /*else
                message "Получатель не является клиентом банка" view-as alert-box  buttons ok title "" .*/
        end.
        /*else message "Проверку не делаем, клиент не нашего банка" view-as alert-box  buttons ok title "" .*/
        /* ----------------------------------- */
        /*проверка РНН плательщика*/
        if remtrz.tcrc <> 1 then v-val = true. else v-val = false.
        v-m2 = "".
        if v-val then do:
            i = r-index(remtrz.ord, '/RNN/').
            if i <> 0 then
            v-m2 = trim( substring( remtrz.ord, i + 5, 12 )). /* РНН плательщика */
        end.
        else do:  /* теньговые платежики */
           i = r-index( remtrz.ord, '/RNN/' ).
           if i <> 0 then v-m2 = trim( substring( remtrz.ord, i + 5, 12 )). /* РНН плательщика */
        end.
        if v-m2 <> "" then do:
            find first b-aaa where b-aaa.aaa = remtrz.sacc no-lock no-error.
            find first b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
            if v-m2 <> b-cif.bin then do:
            /* message "ОШИБКА: РНН Плательщика " +  v-m2 + " не совпадает с карточкой клиента " view-as alert-box  buttons ok title "" .
            return. */
            end.
        end.
        /*проверка РНН плательщика*/
        if index(remtrz.rcvinfo[1],"/PSJ/") > 0 then do:
            find first b-sysc where b-sysc.sysc = "PSJIN" no-lock no-error.
            if avail b-sysc then pf_file = trim(b-sysc.chval) + trim(remtrz.remtrz).
            v-psj = yes.
        end.
        if v-bin then do:
            if remtrz.tcrc <> 1 then v-val = true. else v-val = false.
            if v-val then do:
                v-s2 = trim(substring( trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3]), 081, 80 )).
            end.
            else do:
                do i = 1 to 3:
                   v-bbbb = trim( remtrz.bn[i] ).
                   v-bbbb   = v-bbbb + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + " ".
                end.
                i = r-index( v-bbbb, "/RNN/" ).
                if i <> 0 then do:
                   v-s2 = trim( substring( v-bbbb, i + 5, 12 )).
                end.
                else do:
                    /* признак /RNN/ мог разбиться на 2 части в разных строках
                    21.02.2003 nadejda - добавлен поиск РНН в простом слиянии строк */
                    v-bbbb = "".
                    do i = 1 to 3:
                        v-bbbb = v-bbbb + trim(remtrz.bn[i]).
                    end.
                    i = r-index(v-bbbb, "/RNN/").
                    if i <> 0 then do:
                        v-s2 = trim(substring(v-bbbb, i + 5, 12)).
                    end.
                end.
            end.

            /*проверка ИИН-БИН плательщика*/
            v-m2 = "".
            if v-val then do:
                i = r-index(remtrz.ord, '/RNN/').
                if i <> 0 then
                v-m2 = trim( substring( remtrz.ord, i + 5, 12 )). /* РНН плательщика */
            end.
            else do:  /* теньговые платежики */
                i = r-index( remtrz.ord, '/RNN/' ).
                if i <> 0 then v-m2 = trim( substring( remtrz.ord, i + 5, 12 )). /* РНН плательщика */
            end.
            if v-m2 <> "" then do:
             find first b-aaa where b-aaa.aaa = remtrz.sacc no-lock no-error.
             find first b-cif where b-cif.cif = b-aaa.cif no-lock no-error.
             if v-m2 <> b-cif.bin then do:
                message "ОШИБКА: ИИН/БИН Отправителя " +  v-m2 + " не совпадает с карточкой клиента " view-as alert-box  buttons ok title "" .
                return.
             end.
            end.
        end. /* v-bin */
        /* проверка на ИИН/БИН  */

        find last b-codfr where b-codfr.codfr = 'spnpl' and b-codfr.child = false and b-codfr.code <> 'msc'and b-codfr.code = v-knp no-lock no-error.
        if not avail b-codfr then do:
           message "ОШИБКА: КНП " +  v-knp + " не найден в справочнике Иксоры" view-as alert-box  buttons ok title "" .
           return.
        end.
        /* проверка данных зарплатных платежей на карточные счета */
        if v-psj and can-do(v-sparp,remtrz.racc) then do:
            v-pc = yes.
            /*find first b-sysc where b-sysc.sysc = "PSJIN" no-lock.
            if avail b-sysc then pf_file = trim(b-sysc.chval) + trim(remtrz.remtrz).*/
            message 'Ждите, идет проверка данных зарплатных платежей на счета по ПК'. pause 0.
  		    i = 0.
            v-sumerr = 0.
            input stream str41 from value(pf_file). /*читаем содержимое файла*/
            repeat:
			    import stream str41 unformatted v-strs.
			    i = i + 1.
                v-strs = trim(v-strs).
        		if v-strs begins ':21:' then do:
                    assign v-21  = trim(substr(v-strs,5))
                           v-fm  = ''
                           v-nm  = ''
                           v-ft  = ''
                           v-rnn = ''
                           v-la  = ''
                           v-32b = ''
                           v-err = no.
                    next.
                end.
                else if v-strs begins ':32B:' then do: v-32b = trim(replace(substr(v-strs,9),',','.')). next. end.
                else if v-strs begins '/FM/'  then do: v-fm  = trim(substr(v-strs,5)). next. end.
                else if v-strs begins '/NM/'  then do: v-nm  = trim(substr(v-strs,5)). next. end.
                else if v-strs begins '/FT/'  then do: v-ft  = trim(substr(v-strs,5)). next. end.
                else if v-strs begins '/RNN/' then do: v-rnn = trim(substr(v-strs,6)). next. end.
                else if v-strs begins '/IDN/' then do: v-rnn = trim(substr(v-strs,6)). next. end.
                else if v-strs begins '/LA/'  then do:

                    v-la = trim(substr(v-strs,5)).
                    find first pccards where pccards.iin = v-rnn no-lock no-error.
                    if not avail pccards then do:
                        v-spnom = v-spnom + v-21 + ','.
                        v-txt = v-txt + '\n' + v-21 + '- ИИН не найден'.
                        find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                        if not avail payreturn then do:
                            create payreturn.
                            assign payreturn.rmz = remtrz.remtrz
                                   payreturn.aaa = v-la
                                   payreturn.iin = v-rnn
                                   payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                   payreturn.amt = deci(v-32b)
                                   payreturn.who = g-ofc
                                   payreturn.whn = g-today
                                   payreturn.reason = v-21 + '- ИИН не найден'
                                   payreturn.tim = time.
                        end.
                        v-sumerr = v-sumerr + deci(v-32b).
                        next.
                    end.
                    find first pccards where pccards.aaa = v-la and pccards.sts <> 'Closed' and not sup no-lock no-error.
                    if not avail pccards then do:
                        v-spnom = v-spnom + v-21 + ','.
                        v-txt = v-txt + '\n' + v-21 + '-' + '/LA/' + v-la + ' нет ПК с таким счетом'.
                        find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                        if not avail payreturn then do:
                            create payreturn.
                            assign payreturn.rmz = remtrz.remtrz
                                   payreturn.aaa = v-la
                                   payreturn.iin = v-rnn
                                   payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                   payreturn.amt = deci(v-32b)
                                   payreturn.who = g-ofc
                                   payreturn.whn = g-today
                                   payreturn.reason = v-21 + '-' + '/LA/' + v-la + ' нет ПК с таким счетом'
                                   payreturn.tim = time.
                        end.
                        v-sumerr = v-sumerr + deci(v-32b).
                        next.
                    end.
                    else if pccards.iin <> v-rnn then do:
                        v-spnom = v-spnom + v-21 + ','.
                        v-txt = v-txt + '\n' + v-21 + '-' + '/IDN/' + v-rnn + ' ИИН не соотвествует счету'.
                        find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                        if not avail payreturn then do:
                            create payreturn.
                            assign payreturn.rmz = remtrz.remtrz
                                   payreturn.aaa = v-la
                                   payreturn.iin = v-rnn
                                   payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                   payreturn.amt = deci(v-32b)
                                   payreturn.who = g-ofc
                                   payreturn.whn = g-today
                                   payreturn.reason = v-21 + '-' + '/IDN/' + v-rnn + ' ИИН не соотвествует счету'
                                   payreturn.tim = time.
                        end.
                        v-sumerr = v-sumerr + deci(v-32b).
                        next.
                    end.
                    find first pcstaff0 where pcstaff0.iin = v-rnn and not pcstaff0.sts matches '*Closed*' no-lock no-error.
                    if not avail pcstaff0 then do:
                        if not v-err then v-spnom = v-spnom + v-21 + ','.
                        v-txt = v-txt + '\n' + v-21 + '- Счет закрыт'.
                        v-err = yes.
                        find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                        if not avail payreturn then do:
                            create payreturn.
                            assign payreturn.rmz = remtrz.remtrz
                                   payreturn.aaa = v-la
                                   payreturn.iin = v-rnn
                                   payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                   payreturn.amt = deci(v-32b)
                                   payreturn.who = g-ofc
                                   payreturn.whn = g-today
                                   payreturn.reason = v-21 + '- Счет закрыт'.
                                   payreturn.tim = time.
                        end.
                        v-sumerr = v-sumerr + deci(v-32b).
                        next.
                    end.
                    if (index(v-fm,'?') = 0 and v-fm ne pcstaff0.sname) or (index(v-fm,'?') > 0 and not chk-rekv(v-fm,pcstaff0.sname))
                    then do:
                        v-names = kzru(ourbank,b-cif.cif,v-fm,pcstaff0.sname).
                        if v-names <> pcstaff0.sname then do:
                            v-spnom = v-spnom + v-21 + ','.
                            v-txt = v-txt + '\n' + v-21 + '-' + '/FM/' + v-fm + ' <> ' +  pcstaff0.sname + '(ПК).'.
                            v-err = yes.
                            find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                            if not avail payreturn then do:
                                create payreturn.
                                assign payreturn.rmz = remtrz.remtrz
                                       payreturn.aaa = v-la
                                       payreturn.iin = v-rnn
                                       payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                       payreturn.amt = deci(v-32b)
                                       payreturn.who = g-ofc
                                       payreturn.whn = g-today
                                       payreturn.reason = v-21 + '-' + '/FM/' + v-fm + ' <> ' +  pcstaff0.sname + '(ПК).'
                                       payreturn.tim = time.
                            end.
                            v-sumerr = v-sumerr + deci(v-32b).
                        end.
                    end.
                    if (index(v-nm,'?') = 0 and v-nm ne pcstaff0.fname) or (index(v-nm,'?') > 0 and not chk-rekv (v-nm,pcstaff0.fname))
                    then do:
                        v-namef = kzru(ourbank,b-cif.cif,v-nm,pcstaff0.fname).
                        if v-namef <> pcstaff0.fname then do:
                            if not v-err then v-spnom = v-spnom + v-21 + ','.
                            v-txt = v-txt + '\n' + v-21 + '-' + '/NM/' + v-nm + ' <> ' +  pcstaff0.fname + '(ПК).'.
                            v-err = yes.
                            find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                            if not avail payreturn then do:
                                create payreturn.
                                assign payreturn.rmz = remtrz.remtrz
                                       payreturn.aaa = v-la
                                       payreturn.iin = v-rnn
                                       payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                       payreturn.amt = deci(v-32b)
                                       payreturn.who = g-ofc
                                       payreturn.whn = g-today
                                       payreturn.reason = v-21 + '-' + '/NM/' + v-nm + ' <> ' +  pcstaff0.fname + '(ПК).'
                                       payreturn.tim = time.
                            end.
                            v-sumerr = v-sumerr + deci(v-32b).
                        end.
                    end.
                    /*if num-entries(pccards.sname,' ') = 3 then*/
                   if (index(v-ft,'?') = 0 and v-ft ne pcstaff0.mname) or (index(v-ft,'?') > 0 and not chk-rekv(v-ft,pcstaff0.mname))
                    then do:
                        v-namem = kzru(ourbank,b-cif.cif,v-ft,pcstaff0.mname).
                        if v-namem <> pcstaff0.mname then do:
                            if not v-err then v-spnom = v-spnom + v-21 + ','.
                            v-txt = v-txt + '\n' + v-21 + '-' + '/FT/' + v-ft + ' <> ' +  pcstaff0.mname + '(ПК).'.
                            v-err = yes.
                            find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                            if not avail payreturn then do:
                                create payreturn.
                                assign payreturn.rmz = remtrz.remtrz
                                       payreturn.aaa = v-la
                                       payreturn.iin = v-rnn
                                       payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                       payreturn.amt = deci(v-32b)
                                       payreturn.who = g-ofc
                                       payreturn.whn = g-today
                                       payreturn.reason = v-txt
                                       payreturn.tim = time.
                            end.
                            v-sumerr = v-sumerr + deci(v-32b).
                        end.
                    end.
                    if v-rnn ne '' then do:
                        if (v-bin and trim(v-rnn) ne trim(pccards.iin)) or (not v-bin and trim(v-rnn) ne trim(pccards.rnn)) then do:
                            if not v-err then v-spnom = v-spnom + v-21 + ','.
                            v-txt = v-txt + '\n' + v-21 + '-' + (if v-bin then '/IDN/' else '/RNN/') + v-rnn + ' <> ' +  (if v-bin then pccards.iin else pccards.rnn) + '(ПК).'.
                            find first payreturn where payreturn.rmz = remtrz.remtrz and payreturn.aaa = v-la no-lock no-error.
                            if not avail payreturn then do:
                                create payreturn.
                                assign payreturn.rmz = remtrz.remtrz
                                       payreturn.aaa = v-la
                                       payreturn.iin = v-rnn
                                       payreturn.name = v-fm + ' ' + v-nm + ' ' + v-ft
                                       payreturn.amt = deci(v-32b)
                                       payreturn.who = g-ofc
                                       payreturn.whn = g-today
                                       payreturn.reason = v-21 + '-' + (if v-bin then '/IDN/' else '/RNN/') + v-rnn + ' <> ' +  (if v-bin then pccards.iin else pccards.rnn) + '(ПК).'
                                       payreturn.tim = time.
                            end.
                            v-sumerr = v-sumerr + deci(v-32b).
                        end.
                    end.
                end.
            end.
            input stream str41 close.
            if v-spnom ne '' then do:
                reas = 'Ошибки в данных по сотрудникам: ' .
                reas = reas + right-trim(v-spnom,',').
                message v-txt view-as alert-box  buttons ok title "" .
                /*return.*/
            end.
        end.
        /* проверка данных зарплатных платежей на карточки */

        /*проверка данных платежа со списком на конкр.сч.KZ81470192870A023308 */
        if v-psj and remtrz.racc = v-arp then do:
            find first txb where txb.bank =  'txb' + substr(v-arp,19,2) no-lock no-error.
            if not avail txb then return.
            if connected ("txb") then disconnect "txb".
            connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password) no-error.
            run bn-check-rmz(pf_file,output v-spnom,output v-txt).
            if connected ("txb") then disconnect "txb".
            if v-spnom ne '' then do:
                reas = 'Ошибки в данных по сотрудникам: ' .
                reas = reas + right-trim(v-spnom,',').
                message v-txt view-as alert-box  buttons ok title "" .
                return.
            end.
        end.
        /*проверка данных платежа со списком на конкр.сч.KZ81470192870A023308 */

        message "ВНИМАНИЕ: ПЛАТЕЖ Сделан в сервисе Интернет-Банкинг!" skip  "Вы уверены что все реквизиты верные?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
        if not v-ans then return.

        run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").
        if isProductionServer() then run setBrokerURL in ptpsession ("tcp://172.16.3.5:2507").
        else run setBrokerURL in ptpsession ("tcp://172.16.2.77:2507").

        run setUser in ptpsession ("SonicClient").
        run setPassword in ptpsession ("SonicClient").
        RUN beginSession IN ptpsession.

        run createXMLMessage in ptpsession (output messageH).
        run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
        run appendText in messageH ("<DOC>").

        if remtrz.fcrc = 1 then run appendText in messageH ("<PAYMENT>").
        else run appendText in messageH ("<CURRENCY_PAYMENT>").

        run appendText in messageH ("<ID>" + netbank.id + "</ID>").
        run appendText in messageH ("<STATUS>5</STATUS>").
        run appendText in messageH ("<DESCRIPTION>Исполнен</DESCRIPTION>").
        run appendText in messageH ("<TIMESTAMP>" + string(g-today) + " " + string(time, "hh:mm:ss") +  "</TIMESTAMP>").

        if remtrz.fcrc = 1 then run appendText in messageH ("</PAYMENT>").
        else run appendText in messageH ("</CURRENCY_PAYMENT>").

        run appendText in messageH ("</DOC>").
        RUN sendToQueue IN ptpsession ("SYNC2NETBANK", messageH, ?, ?, ?).
        RUN deleteMessage IN messageH.
        RUN deleteSession IN ptpsession.
        netbank.sts = "5".
        netbank.rem[1] = "Исполнен" .
        find current netbank no-lock no-error.
        find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
        if avail remtrz then do:
           remtrz.cwho = g-ofc.
        end.
        find current remtrz no-lock no-error.
    end. /*avail netbank */
end. /* m_pid = "3A"*/

find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
if avail netbank then do:
   if netbank.sts <> "5" then do:
       message "ОШИБКА: Необходимо перезапустить брокер SonicMQ, обратитесь в Службу тех.поддержки, затем снова акцептуйте платеж." view-as alert-box  buttons ok title "" .
       return.
   end.
end.


/* Не проверяем одного Астаниснкого Клиента */

if lookup(remtrz.dracc,"154467273") = 0 then do:

      /* 06.05.2004 nadejda - проверка реквизитов НК для налоговых платежей */
    v-acc = entry(1, trim(remtrz.ba, "/"), "/").
    if (v-acc matches "...080..." or v-acc matches "...144...") and (v-knp begins '9') then do:
        if num-entries(trim(remtrz.ba, "/"), "/") < 2 then do:
            message skip " Неверный код бюджетной классификации !" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
            return.
        end.

        v-kbk = integer (entry(2, trim(remtrz.ba, "/"), "/")) no-error.
        if error-status:error then do:
            message skip " Неверный код бюджетной классификации !" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
            return.
        end.

        find budcodes where budcodes.code = v-kbk no-lock no-error.
        if not avail budcodes then do:
            message skip " Неверный код бюджетной классификации !" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
            return.
        end.

        if index(remtrz.rcvinfo[1], "/TAX/") = 0 then do:
            message skip " Неверный вид платежа - должен быть налоговый платеж !" skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
            return.
        end.

        if v-acc matches "...080..." then do:
            v-rnn = trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]).
            v-rnn = trim(substr(v-rnn, index(v-rnn, "/RNN/") + 5)).
            v-rnn = substr(v-rnn, 1, 12).

            find first taxnk where taxnk.rnn = v-rnn no-lock no-error.
            if avail taxnk and (string(taxnk.bik, "999999999") <> remtrz.rbank or string(taxnk.iik, "999999999") <> v-acc) then do:
                message skip " Неверные реквизиты налогового комитета !~nПлатеж: " remtrz.rbank " / " v-acc "~nНал. к.: " taxnk.bik " / " taxnk.iik skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
                return.
            end.
        end.
    end.
end.
/**/

if remtrz.ptype eq ""  then do:
    Message " Тип платежа еще не определен !! Невозможно отправить " .
    pause .
    return .
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " Записи OURBNK нет в sysc файле !!".
    pause.
    undo,return.
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " Записи CLEARING нет в sysc файле !!".
    pause.
    undo,return.
end.
clearing = sysc.chval.

if ourbank = clearing  then brnch = false . else brnch = true .


if brnch and remtrz.source = "H" and remtrz.crgl eq ? then  do:
    message "Проведите операцию OUTGOING !!!".
    pause.
    return.
end.

{get-fio.i}
{get-dep.i}
{comm-txb.i}
def var ourcode as integer.
ourcode = comm-cod().

if not yn then return.
if yn then do /*transaction*/:

    find first que where que.remtrz = s-remtrz no-lock no-error .
    if avail que and ( que.pid ne m_pid or que.con eq "F" ) then do:
        Message " Вы не владелец !! Отправить невозможно ".
        pause.
        undo,return.
    end.

    /*26.06.2008 galina проверка на акцепт Вал.котроля платежей, подлежащих проверке*/
  if g-today = today then do:
        find first sub-cod where sub-cod.sub   = 'rmz' and sub-cod.acc   = remtrz.remtrz and sub-cod.d-cod = 'eknp' no-lock  no-error.

        if substr(sub-cod.rcode,1,1) = "2" or substr(sub-cod.rcode,4,1)= "2" then do:
            if remtrz.vcact = "" then do:
                message " Документ должен проконтролировать валютный контроль (в 9.11)" view-as alert-box title " ВНИМАНИЕ ! ".
                return.
            end.
        end.
        if substr(sub-cod.rcode,1,1) = "1" and substr(sub-cod.rcode,4,1)= "1" then do:
            if remtrz.fcrc <> 1 then do:
                if remtrz.vcact = "" then do:
                    message " Документ должен проконтролировать валютный контроль (в 9.11)" view-as alert-box title " ВНИМАНИЕ ! ".
                    return.
                end.
            end.
        end.
    end.



   if remtrz.outcode = 3 then do:
       v-benCountry  = ''.
       if remtrz.fcrc  > 1 then do:
          find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
          if not avail sub-cod or sub-cod.ccode = 'msc' then do:
             message 'Незаполнен справочник iso3166!' view-as alert-box title 'ВНИМАНИЕ'.
             return.
          end.
          v-benCountry = sub-cod.ccode.
       end.

       /*****проверка на терроризм******/

       v-benName = ''.
       v-senderCountry = ''.
       v-senderName = ''.
       v-benNameList = ''.
       v-senderNameList = ''.
       v-errorDes = ''.
       v-operIdOnline = ''.
       v-operStatus = ''.
       v-operComment = ''.

       find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
       find first cif where cif.cif = aaa.cif no-lock no-error.
       run defclparam.
       v-senderCountry = v-res.

       if cif.type = 'B' then do:
           v-senderNameList = ''.

           if cif.cgr <> 403 then do:
               for each founder where founder.cif = cif.cif no-lock:
                   if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                   if founder.ftype = 'B' then v-senderNameList = v-senderNameList + founder.name.
                   if founder.ftype = 'P' then v-senderNameList = v-senderNameList + trim(founder.sname) + ' ' + trim(founder.fname) + ' ' + trim(founder.mname).
               end.
           end.
           if cif.cgr = 403 then do:
               if v-prtFLNam <> '' then do:
                   if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
                   v-senderNameList = v-senderNameList + v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
               end.
           end.

           if v-senderNameList <> '' then v-senderNameList = v-senderNameList + '|'.
       end.
       if v-cltype = '01' then v-senderName = v-clnameU.
       if v-cltype = '02' then v-senderName = v-prtFLNam + '  ' + v-prtFFNam + ' ' + v-prtFMNam.
       if v-cltype = '03' then v-senderName = trim(cif.prefix) + ' ' + trim(cif.name).
       v-benName = entry(1,(trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2]))),'/').

       if trim(v-senderCountry + v-senderName + v-senderNameList + v-benName + v-benCountry) <> '' then do:
            if trim(v-benCountry) <> '' then do:
                find first code-st where code-st.code = v-benCountry no-lock no-error.
                if avail code-st then v-benCountry = code-st.cod-ch.
            end.
            if trim(v-senderCountry) <> '' then do:
                find first code-st where code-st.code = v-senderCountry no-lock no-error.
                if avail code-st then v-senderCountry = code-st.cod-ch.
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
       /*****конец - проверка на терроризм******/
       v-susp = 0.
       find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "kfmsusp1" use-index dcod no-lock no-error .
       if avail sub-cod and sub-cod.ccode = '01' then do:
           find first kfmoper where kfmoper.bank = ourbank and kfmoper.oper\Doc = remtrz.remtrz no-lock no-error.
           if avail kfmoper then do:
               if kfmoper.sts <> 99  and kfmoper.sts <> 90 then do:
                  message "Операция является подозрительной и находится на контроле у службы Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.
                  return.
               end.
           end.
           else do:
               v-susp = 1.
               message "Операция является подозрительной и подлежит финансовому мониторингу.~nОбратитесь в службу Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.
               /**/
               v-oper = ''.
               run fm1.
               if not kfmres then return.
               if v-kfm then run kfmcopy(v-operId,remtrz.remtrz,'su',0).

               hide all no-pause.

               display g-fname format "x(16)" g-mdes format "x(65)" "iXora  " g-ofc g-today format "99/99/9999"
               with color messages overlay no-box no-label row 2 width 110 frame mainhead.

               return.
           end.
       end.

       k = 0.
       v-mess = 0.

   end.


   find first doc where doc.remtrz eq remtrz.remtrz no-lock no-error.
   if avail doc then do:
        find ofc where ofc.ofc eq g-ofc no-lock no-error.
        if avail ofc then do transaction:
           find current remtrz exclusive-lock.
           remtrz.info[4] = ofc.name.
           find current remtrz no-lock.
        end.
   end.

/* 06.09.04 saltanat - SWIFT message */

   if ( m_pid = "3A" ) and ( ourbank <> 'TXB00' ) and (remtrz.tcrc <> 1 or remtrz.fcrc <> 1) and remtrz.source <> "IBH" then do:
        if yes-no ('', 'По платежу нужно набрать SWIFT сообщение МТ103. Разрешить набор?') then do:
            run swin("103").

            if return-value = "ok" then do:
                if avail que then do transaction:
                    find current que exclusive-lock.
                    v-swif = false.
                    que.pid = m_pid.
                    que.rcod = "3" .
                    v-text = " Отправлен " + remtrz.remtrz + " по маршруту 3A - 3M, rcod = " +
                    que.rcod + " " + remtrz.sbank + " -> " + remtrz.rbank .
                    run lgps.
                    que.con = "F".
                    que.dp = today.
                    que.tp = time.
                    release que .
                    find first bankt where bankt.cbank = 'TXB00' and bankt.crc = remtrz.tcrc no-lock no-error.
                    if avail bankt then do:
                        find current remtrz exclusive-lock.
                        remtrz.cracc = bankt.acc.
                        remtrz.rbank = 'valout'.
                        find current remtrz no-lock.

                    end.
                    Message "Платеж нужно акцептовать в п.5.2.11 ! " view-as alert-box buttons ok.
                end. /* que */
            end. /* if return "ok" */
            else Message "Сообщение МТ103 не отправлено ! " view-as alert-box.
       end. /* if yes */
   end. /* if */


    if avail que and v-swif then do transaction:
      find current que exclusive-lock.
      find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .
      {canbal.i}
      {nbal+r.i}
      que.pid = m_pid.
      if remtrz.jh1 ne ? then
       find first jl where jl.jh = remtrz.jh1 no-lock no-error  .
      if remtrz.jh1 ne ? and avail jl and not remtrz.source begins 'MD' then
        que.rcod = "2".
      else if remtrz.jh1 ne ? and avail jl and remtrz.source begins 'MD' then
        que.rcod = "1".
      else
      que.rcod = "0" .
      v-text = " Отправлен " + remtrz.remtrz + " по маршруту , rcod = " +
      que.rcod +
      " " + remtrz.sbank + " -> " + remtrz.rbank .
      run lgps.
      que.con = "F".
      que.dp = today.
      que.tp = time.
    end.

    /* для платежа со списком на конкр.сч.KZ81470192870A023308 создание записи в таблице clsdp, обработка записи - платежи на отдельные счета в ELX_ps.p */
    if v-psj and remtrz.racc = v-arp then do:
        find first clsdp where clsdp.aaa    = remtrz.racc
                           and clsdp.txb    = 'txb' + substr(remtrz.racc,19,2)
                           and clsdp.rem    = remtrz.remtrz
        no-lock no-error.
        if not avail clsdp then do:
            create clsdp.
            assign clsdp.aaa    = remtrz.racc
                   clsdp.txb    = 'txb' + substr(remtrz.racc,19,2)
                   clsdp.sts    = '19'
                   clsdp.rem    = remtrz.remtrz
                   clsdp.level1 = remtrz.amt
                   clsdp.level2 = remtrz.fcrc
                   clsdp.prm    = pf_file.
        end.
    end.

    {koval-vsd.i}

    release que .
    release remtrz.

/*********************комиссия за зачисление на ПК****************************/
    find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if v-pc then do:
        v-kont = 0.
        find first tarifex where tarifex.cif = cif.cif and tarifex.str5 = '058' no-lock no-error.
        if not avail tarifex then do:
            find first tarif2 where tarif2.str5 = '058' no-lock no-error.
            if avail tarif2 then do:
                if tarif2.proc > 0 then do:
                    v-amt = (remtrz.amt - v-sumerr) * (tarif2.proc / 100).
                    if tarif2.min1 > 0 and v-amt < tarif2.min1 then v-amt = tarif2.min1.
                    if tarif2.max1 > 0 and v-amt > tarif2.max1 then v-amt = tarif2.max1.
                end.
                else v-amt = tarif2.ost.
                v-kont = tarif2.kont.
            end.
            else message "Не найден тариф для снятия комиссии!!!" view-as alert-box.
        end.
        else do:
            if tarifex.proc > 0 then do:
                v-amt = (remtrz.amt - v-sumerr) * (tarifex.proc / 100).
                if tarifex.min1 > 0 and v-amt < tarifex.min1 then v-amt = tarifex.min1.
                if tarifex.max1 > 0 and v-amt > tarifex.max1 then v-amt = tarifex.max1.
            end.
            else v-amt = tarifex.ost.
            v-kont = tarifex.kont.
        end.
        if v-kont <> 0 then do:
            find first pcsootv where pcsootv.bank = ourbank and pcsootv.cif = cif.cif no-lock no-error.
            if available pcsootv and trim(pcsootv.aaa) <> "" then v-gaaa = trim(pcsootv.aaa).
            else v-gaaa = aaa.aaa.

            if remtrz.fcrc = 1 then do:
                v-param = string(v-amt) + vdel + v-gaaa + vdel + string(v-kont) + vdel + 'Комиссия за зачисление по Salary' + vdel + '' + vdel + '840'.
                v-trx   = 'uni0023'.
            end.
            else do:
                v-sumconv = 0.
                find last b-crcpro where b-crcpro.crc = remtrz.fcrc and b-crcpro.regdt <= g-today no-lock no-error.
                if avail b-crcpro then v-sumconv = v-amt * b-crcpro.rate[1].
                else do: message "This isn't record crcpro!!!" view-as alert-box buttons ok. return. end.

                v-param = string(v-amt) + vdel + v-gaaa + vdel + "Комиссия за зачисление по Salary" + vdel + "1" + vdel + "4" + vdel + "840" + vdel + string(v-sumconv) + vdel +
                string(v-kont) + vdel + "Комиссия за зачисление по Salary".
                v-trx   = 'uni0013'.
            end.
            find first joudoc where joudoc.rescha[1] = remtrz.remtrz no-lock no-error.
            if not avail joudoc then do:
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , remtrz.remtrz , output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    message "Проводка по комиссии не была сделана!" view-as alert-box error.
                    return.
                end.
                else do:
                    message "Проводка по комиссии сделана!" s-jh view-as alert-box error.
                    run jou.
                end.
                find first joudoc where joudoc.jh = s-jh exclusive-lock no-error.
                if avail joudoc then joudoc.rescha[1] = remtrz.remtrz.
            end.
        end.
    end.
/*********************комиссия за зачисление на ПК****************************/

end .

/*данные по клиенту*/
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

  if cif.type = 'B' then do:
     if cif.cgr <> 403 then v-cltype = '01'.
     if cif.cgr = 403 then v-cltype = '03'.
  end.
  else v-cltype = '02'.

  if cif.geo = '021' then do:
   v-res2 = '1'.
   v-res = 'KZ'.
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

  if v-cltype = '01' then v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name).
  else v-clnameU = ''.

  if v-cltype = '02' or v-cltype = '03' then do:
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

      find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error .
      if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.

      v-bdt = string(cif.expdt,'99/99/9999').
      v-bplace = cif.bplace.
  end.
  v-prtOKPO = cif.ssn.
  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.


  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

/*заполняем форму для фин.мониторинга*/
procedure fm1.

  def var v-knp as char.
  def var v-resben as char.
  def var v-resbenC as char.
  def var v-resben2 as char.
  def var v-rcbank as char.
  def var v-rcbankbik as char.
  def var v-bennameU  as char no-undo.
  def var v-bennameF  as char no-undo.
  def var v-benFAM as char no-undo.
  def var v-benNAM as char no-undo.
  def var v-benM as char no-undo.
  def var v-benrnn as char no-undo.
  def var v-bentype as char no-undo.
  def var v-sumkzt as char no-undo.
  def var v-rbankbik as char no-undo.


  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(remtrz.fcrc) no-lock no-error.
  v-benFAM = ''.
  v-benNAM = ''.
  v-benM = ''.
  v-bennameU = ''.
  v-bennameF = ''.
  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
  if avail sub-cod and substr(entry(2,sub-cod.rcode),2,1) <> '9' then do:
    v-bennameU = trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2]).
    v-bentype = '01'.
  end.
  if avail sub-cod and substr(entry(2,sub-cod.rcode),2,1) = '9' then do:
    v-bentype = '02'.
    v-bennameF = trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2])).
    if num-entries(v-bennameF) > 0 then v-benFAM = entry(1,v-bennameF).
    if num-entries(v-bennameF) >= 2 then v-benNAM = entry(2,v-bennameF).
    if num-entries(v-bennameF) >= 3 then v-benM = entry(3,v-bennameF).
  end.
  if avail sub-cod then v-knp = entry(3,sub-cod.rcode).
  if avail sub-cod then do:
    if substr(entry(2,sub-cod.rcode),1,1) <> '1' then v-resben2 = '0'.
    if substr(entry(2,sub-cod.rcode),1,1) = '1' then v-resben2 = '1'.
  end.
  if v-resben2 = '1' then v-resbenC = 'KZ'.
  v-sumkzt = ''.
  if remtrz.fcrc <> 1 then do:
    find first crc where crc.crc = remtrz.fcr no-lock no-error.
    v-sumkzt = trim(string(remtrz.amt * crc.rate[1],'>>>>>>>>>>>>9.99')).
  end.
  if v-susp = 0 then run kfmoperh_cre('01','01',remtrz.remtrz,v-oper,v-knp,'2',codfr.code,trim(string(remtrz.amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).
  else run kfmoperh_cre('03','03',remtrz.remtrz,v-oper,v-knp,'2',codfr.code,trim(string(remtrz.amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).
  find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
  find first cif where cif.cif = aaa.cif no-lock no-error.
  run defclparam.

  find first cmp no-lock no-error.
  find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

  v-num = 0.
  v-num = v-num + 1.

  run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',remtrz.sacc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
/*  run kfmprt_cre(v-operId,v-num,'01','02','34',v-res,v-cltype,v-publicf,remtrz.sacc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-OKED,cif.bin,v-clnameF,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'').*/
  v-num = v-num + 1.

  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then  v-resben = sub-cod.ccode.

  v-rcbank = ''.
  find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
  if avail bankl then v-rcbank = trim(bankl.name).
  v-rcbankbik = ''.
  if remtrz.rcbank matches "TXB*" then do:
     find first txb where txb.consolid and txb.bank = remtrz.rcbank no-lock no-error.
     if avail txb then v-rcbankbik = txb.mfo.
  end.
  else v-rcbankbik = remtrz.rcbank.
  if num-entries(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],'/') >=3 then v-benrnn = entry(3,remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],'/').

  v-rbankbik = ''.
  if remtrz.rbank matches "TXB*" then do:
     find first txb where txb.consolid and txb.bank = remtrz.rbank no-lock no-error.
     if avail txb then v-rbankbik = txb.mfo.
  end.
  else v-rbankbik = remtrz.rbank.


  /*run kfmprt_cre(v-operId,v-num,'01','02','34',v-res2,v-res,v-cltype,v-publicf,'',remtrz.sacc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'').*/
  run kfmprt_cre(v-operId,v-num,'01','01','57',v-resben2,v-resbenC,v-bentype,'','',remtrz.ba,trim(remtrz.bb[1]) + trim(remtrz.bb[2]),v-rbankbik,v-resben,remtrz.cracc,v-rcbank,v-rcbankbik,'',v-bennameU,'',v-benrnn,'','','',v-benFAM,v-benNAM,v-benM,'','','','','','','','','','','','','02').

  if v-susp = 0 then s-operType = 'fm'.
  else s-operType = 'su'.
  run kfmoper_cre(v-operId).

  v-kfm = yes.

end procedure.