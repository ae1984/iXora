/* ispognt.p
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
*/

/* last change - 20.11.2001 by sasco : для больших сумм проставляется статус
                               cursts.sts = "BAC" - Big Amount Control
          последующее изменение на "RDY" - только в 2.4-1-1 (старшим менеджером)
          28.12.2001 - убран цикл 'do transaction' и добавлены release`ы

          07.01.2002 - для Астаны по ARP 150904507 > 50,000 KZT - запрет TRX
          15.01.2002 - для Астаны по ARP 150904507 запрет TRX если сумма всех
                       проводок за месяц больше суммы из sysc.sysc = "DBUDZH"
          16.01.2002 - переменная v-arp904 = true, если ARP 150904507
          17.05.2002 - для Уральска по АРП 000904406 контроль по 30000/TRX
                       и MAX = 200000 логин = sea
          22.07.2002 - проверка АРП счетов из arpcon - отмена изменений от 15/16.01.2002
          24.01.2003 - процедура find-rate1 первым параметром запрашивает вид курса - средневзвешенный или нацбанковский, передаем по умолчанию нацбанк
          29.12.2003 nadejda - запрет на платежи в пользу Казначейства 31 января
          30.12.2003 nadejda - проверка на просрочку на счетах Д/В потребкредитования - если да, то дебетовые операции запрещены
	      13.04.2004 valery - сделал проверку на vip - теперь тех кто в списке trxvip не проверяем на контроль
		  27.08.2004 dpuchkov  - добавил уведомление на контроль старшим менеджером.
          22.09.2004 dpuchkov  - добавил вторичный контроль если резидент 2
 		  03.03.2005 u00121    - Проврека на заполнение справочника "Вид документа" ТЗ ї 1380 от 24.02.2005
	      12.04.2005 saltanat  - Включила контроль КБК
	      05.08.2005 dpuchkov - добавил проверку на блокировку счетов.
          06/10/2008 galina - добавила валютный контроль платежей нерезидента;
                              валютный контроль платежей нерезидента в каждом филиале свой
          20.04.2009 galina - валютный конроль по субботам не включать
          30/03/2010 galina - обработка для фин.мониторинга согласно ТЗ 623 от 19/02/2010
          14/04/2010 galina - добавила ввод телефона для переводов без открытия счета
          19/04/2010 - добавила для фин.мониторинга согласно ТЗ 650 от 19/02/2010
          28/04/2010 galina - добавила подозрительные операции
          29/04/2010 galina - пропускаем подозрительные операции, если они удалены из фин.мониторинга
          28/05/2010 galina - поправила транзакционные блоки
          23/06/2010 galina - запрос дополнительной информации по клиенту для переводов без открытия счета
          24/06/2010 galina - добавила определение страны резиденства для нерезидента
          02/07/2010 galina - изменила количество параметров для kfmdopinf
          03/07/2010 galina - поправила declcparam
          15/07/2010 galina - online запрос по спискам террористов
          20/07/2010 galina - добавила переменную s-operType
          22/07/2010 galina - добавила парметр kfmprt_cre
          28/07/2010 galina - добавила переводы благотвор.организаций для фин.мониторинга
                              проверяем логическую переменную kfmOn в справочнике pksysc перед запросом в AML
          12.08.2010 marinav - в сообщения добавила view-as alert-box buttons ok title ""
          09/11/2010 madiyar - отключаем фин. мониторинг (пока только закомментил, на всякий случай)
          18/11/2010 madiyar - отключаем фин. мониторинг частично
          23/11/2010 madiyar - запрос заполнения мини-карточки только при переводе без открытия счета более USD1,000
          02/12/2010 madiyar - исправил расчет эквивалента в долларах
          01/02/2011 madiyar - поправки по фин. мониторингу
          09.02.2011 aigul - вывод контрактов при кнп 710,780,810-890 и запись платежа в п.м 9-1 ПлатДк
          29.09.2011 Luiza  - если вызов данной программы идет из A_KZ (g-fname  =  "A_KZ") контракт не предлагать
          23.11.2011 aigul - если кнп 311 или 322 и страна не КЗ то вывод сообщения
          06.02.2012 dmitriy - убрал контроль больших сумм (ТЗ 1076)
          14.02.2012 dmitriy - закомментировал 896 стр. - run chgsts (input "rmz", remtrz.remtrz, "con").
          28/03/2012 Luiza   - по СЗ закоментировала печать корешка после транзакции run v-rmtrz.
          25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
          27/04/2012 evseev  - повтор
          31.05.2012 aigul - сделала исключения для ГК 2206-2217
          01/06/2012 dmitriy - повтор от 31/05/2012 dmitriy - запрет отправки платежей со сбер.счетов в пользу третьих лиц
                              (откомпилировалась только версия, которую добавила Айгуль)
          26.07.2012 evseev - ТЗ-1464
          28.07.2012 evseev - ТЗ-1466
          11/10/2012 Luiza - ТЗ изменение пороговых сумм c 2000000 до 6000000 для кнп 119
          12/10/2012 madiyar - обработка статуса 2 kfmAMLOnline
          02/01/2013 madiyar - подправил вызов kfmdopinf
          14/05/2013 Luiza -  ТЗ № 1838 все проверки по финмон отключаем, будут проверяться в AML
*/

{global.i}

{lgps.i}
{comm-txb.i}
{findstr.i}
{kfm.i "new"}

def var vip as logical init false.
def var v-cash as log .
def shared var s-remtrz like remtrz.remtrz .
def var v-ctr as log.

def var v-wass as integer.
def var v-bigamt as logical.
def var v-arp904 as logical.
def var v-arp904val as char.
def var v-sum904 like jl.dam.
def var v-bigcmp like jl.dam.
def var v-cmpamt like jl.dam.
def var v-rate1  like crc.rate[1].
def var v-rate2  like crc.rate[1].


def var v-coutry as char.

def var v-select as char.
def var v-knp1 as char.
def var v-chk as logical initial no.
def var v-sum-usd as decimal.

def var v-tempstr as char.

find first remtrz where remtrz.remtrz  = s-remtrz  no-lock .

find first aas where aas.aaa = remtrz.sacc and lookup (string(aas.sta),"1,2,3,11,16,17") > 0 no-lock no-error.
if not avail aas then find first aas where aas.aaa = remtrz.sacc and length(aas.mn) = 5 and (aas.mn begins "1" or aas.mn begins "2" or aas.mn begins "3" or aas.mn begins "5" or aas.mn begins "6" or aas.mn begins "9") no-lock no-error.
if avail aas then do:
    find first sub-cod where sub-cod.acc = s-remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
    if avail sub-cod and avail remtrz then do:
       v-tempstr = "". v-tempstr = entry(3,sub-cod.rcode) no-error.
       if (v-tempstr begins "9" and remtrz.rbank <> "KKMFKZ2A") or (not(v-tempstr begins "9") and remtrz.rbank = "KKMFKZ2A") then do:
          message "БИК не соответствует КНП!" view-as alert-box.
          return.
       end.
    end.
end.

if remtrz.jh1 ne ?  then do:
    message remtrz.remtrz +  " 1 проводка = " + string(remtrz.jh1)  +  " уже сделана . " .
    pause.
    return.
end.

/* 29.12.2003 nadejda - запрет на платежи в пользу Казначейства 31 декабря */
  /*
  if month(remtrz.valdt1) = 12 and day(remtrz.valdt1) = 31 and index(remtrz.rcvinfo[1], "/TAX/") <> 0  then do:
     message skip "Запрещены казначейские платежи в последний день года!" skip(1) view-as alert-box title " ОШИБКА ! ".
     return.
  end.
  */
/* 30.12.2003 nadejda - проверка на просрочку на счетах Д/В потребкредитования - если да, то дебетовые операции запрещены */
run chkdolg (remtrz.sacc, output v-cmpamt).

/* если есть просрочка - запретить транзакцию ! */
if v-cmpamt > 0 then do:
    message skip " Счет" remtrz.sacc "принадлежит Департаменту Потреб.кредитования," skip
                 " по связанному кредиту обнаружена просроченная задолженность !" skip(1)
                 " Дебетовые операции по счету запрещены, кроме погашения ссуды ! " skip(1)
                 view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
end.
v-cmpamt = 0.
/**************************************************/


/* Внимание! Не менять местами "run checkarp" и "run amt_ctrl" */

/* 17/07/2002, sasco - check ARP amounts for control */
run checkarp (remtrz.remtrz).
if return-value = 'no' then undo, return.
if return-value = 'con' then do:
    message "Документ должен пройти дополнительный контроль!" view-as alert-box.
    return.
end.


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
def var v-clrnn as char no-undo.
def var v-clbin as char no-undo.
def var v-claddr1 as char no-undo.
def var v-claddr2 as char no-undo.
def var v-rnn as char no-undo.
def var v-iin as char no-undo.
def var v-addr as char no-undo.
def buffer b-remtrz for remtrz.
def var v-bank as char no-undo.
def var v-susp as integer no-undo.
/**/
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
def var v-benbin as char no-undo.
def var v-bentype as char no-undo.
def var v-sacc as char no-undo.
def var v-name as char no-undo.
def var v-castom as char no-undo.
def var v-dtbth as date no-undo.
def var v-regdt as date no-undo.

def var v-clname2 as char no-undo.
def var v-clfam2 as char no-undo.
def var v-clmname2 as char no-undo.
def var v-resben1 as integer no-undo.
def var v-rbankbik as char no-undo.
def var v-sumkzt as char no-undo.

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
def var v-clid as char.
def var v-clbank as char.
def var v-country2 as char.

def var v-usdamt as deci no-undo.
def var v-askdopinfo as logi no-undo.

def var v-rmz as char.
def var v-rez as char.
def var v-fiz as char.
def var v-sts as logical initial no.
def var v-knp-chk as char.
def var v-prov as logic.
        /***********/
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
v-benFAM = ''.
v-benNAM = ''.
v-benM = ''.


if remtrz.outcode = 1 or (remtrz.outcode = 6 and remtrz.drgl = 287032) then do:
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

    if num-entries(remtrz.ord,'/') > 0 then v-name = entry(1,remtrz.ord,'/').
    else v-name = ''.
    if num-entries(remtrz.ord,'/') > 2 then v-clbin = entry(3,remtrz.ord,'/').
    v-bennameF = trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2])).

    if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
    else do:
       find first crc where crc.crc = remtrz.fcrc no-lock no-error.
       v-monamt = remtrz.amt * crc.rate[1].
    end.

    v-usdamt = 0. v-askdopinfo = no.
    find first crc where crc.crc = 2 no-lock no-error.
    if avail crc then v-usdamt = v-monamt / crc.rate[1].
    if v-usdamt >= 1000 then v-askdopinfo = yes.

    if v-askdopinfo then do:
        run kfmdopinf(v-name,
                     v-clbin,
                     '',
                     ?,
                     '',
                     v-bennameF, /*sender/resiver*/
                     '',
                     '',
                     2,
                     output v-prtFLNam,
                     output v-prtFFNam,
                     output v-prtFMNam,
                     output v-clbin,
                     output v-prtUdN,
                     output v-regdt,
                     output v-prtUdIs,
                     output v-dtbth,
                     output v-bplace,
                     output v-res2,
                     output v-res,
                     output v-benFAM,
                     output v-benNAM,
                     output v-benM,
                     output v-claddr1,
                     output v-prtPhone,
                     output v-publicf,
                     output v-prtUD,
                     output v-clid).
        if not v-dopres then return.
    end.


    v-senderCountry = v-res.
    v-senderName = trim(v-prtFLNam)+ ' ' + trim(v-prtFFNam) + ' ' + trim(v-prtFMNam).
    if trim(v-clid) <> '' then do transaction:
        find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .
        /*какое поле брать?*/
        remtrz.kfmcif = v-clid.
        find current remtrz no-lock.
    end.
end.

if remtrz.outcode = 3 then do:
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

end.

if v-senderName = '' then v-senderName = entry(1,remtrz.ord,'/').

if trim(v-senderCountry + v-senderName + v-senderNameList) <> '' then do:
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


if remtrz.fcrc  > 1 then do:
    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
    if not avail sub-cod or sub-cod.ccode = 'msc' then do:
       message 'Незаполнен справочник iso3166!' view-as alert-box title 'ВНИМАНИЕ'.
       return.
    end.
end.


if remtrz.outcode = 3 or remtrz.outcode = 1 or remtrz.outcode = 6 then do:
    find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
    if not avail sysc then do:
        message "" view-as alert-box.
        return.
    end.
    v-bank = sysc.chval.
    v-susp = 0.
    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "kfmsusp1" use-index dcod no-lock no-error .
    if avail sub-cod and sub-cod.ccode = '01' then do:
       find first kfmoper where kfmoper.bank = v-bank and kfmoper.operDoc = remtrz.remtrz no-lock no-error.
       if avail kfmoper then do:
           if kfmoper.sts <> 99  and kfmoper.sts <> 90 then do:
              message "Операция является подозрительной и находится на контроле у службы Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.
              return.
           end.
       end.
       else do:
           v-susp = 1.
           message "Операция является подозрительной и подлежит финансовому мониторингу.~nОбратитесь в службу Комплаенс." view-as alert-box title 'ВНИМАНИЕ'.

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
end.

/*----- запрет отправки платежей со сбер.счетов в пользу третьих лиц -------*/
find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
if avail aaa and aaa.crc = 1 and (aaa.gl = 220620 or aaa.gl = 220720 or aaa.gl = 221510 or aaa.gl = 221710 or aaa.gl = 221910) and g-fname = "OUTRMZ" then do:
    if num-entries(remtrz.ord,'/') > 0 then v-name = entry(1,remtrz.ord,'/').
    else v-name = ''.
    if num-entries(remtrz.ord,'/') > 2 then v-clbin = entry(3,remtrz.ord,'/').
    v-bennameF = trim(trim(remtrz.bn[1]) + ' ' + trim(remtrz.bn[2]) + ' ' + trim(remtrz.bn[3])).

    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = s-remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
    if avail sub-cod and sub-cod.rcode matches "*321*" then do:
        if v-name <> substr(v-bennameF,1,length(v-name)) or v-clbin <> trim(entry(3,remtrz.bn[3],"/")) then do:
            message "Переводные операции в пользу третьих лиц, ~nпредусмотрено только с текущих счетов" view-as alert-box title "Внимание".
            leave.
        end.
    end.
end.
/*--------------------------------------------------------------------------*/

/*
  if remtrz.outcode = 3 then do:
     k = 0.
     v-mess = 0.
     --найти признак оффшора--
     find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
     if avail sub-cod and sub-cod.ccode <> 'msc' then do:

        find first codfr where codfr.codfr = 'iso3166' and codfr.code = sub-cod.ccode no-lock no-error.
        if codfr.name[3] = 'offshor' then do:
           if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
           else do:
              find first crc where crc.crc = remtrz.fcrc no-lock no-error.
              v-monamt = remtrz.amt * crc.rate[1].
           end.
           if v-monamt < 2000000 then do:
              for each jl where jl.acc = remtrz.sacc and jl.dc = 'D' and jl.jdt > (g-today - 7) and jl.jdt <= g-today no-lock:
                 find first jh where jh.jh = jl.jh no-lock no-error.
                 if not avail jh then next.

                 if not (jh.ref matches 'RMZ*') then next.
                 find first b-remtrz where b-remtrz.remtrz = jh.ref no-lock no-error.

                 if not avail b-remtrz then next.
                 find first sub-cod where sub-cod.acc = b-remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
                 if not avail sub-cod or sub-cod.ccode = 'msc' then next.

                 find first codfr where codfr.codfr = 'iso3166' and codfr.code = sub-cod.ccode no-lock no-error.
                 if not avail codfr then next.
                 if codfr.name[3] <> 'offshor' then next.

                 if jl.crc = 1 then v-monamt = v-monamt + jl.dam.
                 else do:
                    find last crchis where crchis.crc = jl.crc and crchis.rdt < jl.jdt no-lock no-error.
                    v-monamt = v-monamt + jl.dam * crchis.rate[1].
                 end.
                 v-mess = 1.
              end.
           end.
           if v-monamt >= 2000000 then do:
              if v-mess = 1 then message 'Общая сумма переводов в оффшорную зону за последние 7 дней >= 2000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
              else message 'Перевод в оффшорную зону суммы >= 2000000 тенге подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.

              v-kfm1 = yes.
              k = k + 1.
          end.
        end.
     end.

     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
     if avail aaa then do:
        find first cif where cif.cif = aaa.cif no-lock no-error.

        if avail cif and cif.type = 'B' and cif.cgr <> 403 and (g-today - cif.expdt) < 90 then do:
           if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
           else do:
              find first crc where crc.crc = remtrz.fcrc no-lock no-error.
              v-monamt = remtrz.amt * crc.rate[1].
           end.

           if v-monamt >= 7000000 then do:
             if not v-kfm1 then message 'Прошло менее 3 месяцев с момента регистрации ~nЮЛ ' + cif.cif + ' ' + trim(cif.prefix) + ' ' + trim(cif.name) + '.~nПеревод на сумму >= 7000000 тенге подлежит финансовому мониторнигу!' view-as alert-box title 'ВНИМАНИЕ'.

             v-kfm2 = yes.
             k = k + 1.
           end.
        end.
     end.

  end.
*/

  /*if*/ /*remtrz.outcode = 3 or*/ /*remtrz.outcode = 1 or remtrz.outcode = 6 then do:*/
      /*find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
      if avail sub-cod then do:
          if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
          else do:
               find first crc where crc.crc = remtrz.fcrc no-lock no-error.
               v-monamt = remtrz.amt * crc.rate[1].
          end.
          v-str = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4].

          if entry(3,sub-cod.rcode) = '119' then do:
             if v-monamt >= 6000000 and not remtrz.own then do:
                 if checkkey2 (v-str,'kfmkey') then do:
                     v-kfm3 = yes.
                     k = k + 1.
                     if not v-kfm1 and not v-kfm2 then message "Переводы в пользу другого лица на безвозмездной основе ~nсуммой >= 6000000 тенге подлежат финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                 end.
             end.
          end.*/
   /*оплата услуг*/
          /*
          if lookup(entry(3,sub-cod.rcode),'740,819,820,830,840,851,852,859,869,890,810,811,812,813,814,815,816,817,818,819,820,840,850,851,852,854,855,856,859,860,861,862,869,870,880') > 0  or (lookup(entry(3,sub-cod.rcode),'120,290') > 0 and checkkey2(v-str,'kfmk1')) then do:
              if v-monamt >= 7000000 then do:
                  k = k + 1.
                  v-kfm4 = yes.
                  if not v-kfm1 and not v-kfm2 then message 'Платеж/перевод за оказание услуг на сумму >= 7000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
              end.
          end.

          if lookup(entry(3,sub-cod.rcode),'831,832,833,834,835,836,837,839,027,046,048') > 0 then do:
               if v-monamt >= 7000000 then do:
                   if not v-kfm2 then message "Осуществление страховой выплаты на сумму >= 7000000~nОперация подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                   k = k + 1.
                   v-kfm5 = true.
               end.
          end.

          if (lookup(entry(3,sub-cod.rcode),'219,229,222') > 0  or (lookup(entry(3,sub-cod.rcode),'290') > 0 and checkkey2(v-str,'kfmk4'))) then do:
               if v-monamt >= 7000000 then do:
                   if not v-kfm1 and not v-kfm2 then message " Купля-продажа драг. металлов, камней и изделий из них на сумму >= 7000000~nОперация подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                   v-kfm6 = true.
                   k = k + 1.
               end.
          end.

          if v-monamt >= 45000000 then do:
               if lookup(entry(3,sub-cod.rcode),'720,721,722') > 0 then do:
                   if not v-kfm1 and not v-kfm2 then message " Сделка с недвиж.имуществом, подлежащим обязательной гос.регистрации на сумму >= 45000000~nОперация подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                   v-kfm7  = true.
                   k = k + 1.
               end.
          end.

          if lookup(entry(3,sub-cod.rcode),'510,521, 522,529,531,532,539,541,542,543,544,545,548,549,550,551,552,553,554,555,558,559,560,561,562,563,570,580,590,610,621,623,629,631,633,639, 641,642,645,647,648,649,651,652,655,657,658,661, 662,663, 671,672,681,682,690') > 0 then do:
               if v-monamt >= 45000000 then do:
                   if not v-kfm1 and not v-kfm2 then message " Сделка с ценными бумагами на сумму >= 45000000~nОперация подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                   v-kfm8 = true.
                   k = k + 1.
               end.
          end.

          if v-monamt >= 2000000 then do:
              if entry(2,sub-cod.rcode) = '18' then do:
                  if not v-kfm1 and not v-kfm2 and not v-kfm3 and not v-kfm4 then message 'Перевод в пользу благотворительной организации ~nна сумму >= 2000000 тенге подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                  v-kfm10 = yes.
                  k = k + 1.
              end.
          end.
          */

      /*end.*/

      /*
      if v-monamt >= 7000000 then do:
           v-str = ''.
           v-str = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4].
           if checkkey2(v-str,'kfmk3') = yes then do:
                if not v-kfm1 and not v-kfm2 then message " Приобретение/продажа культур.ценностей на сумму >= 7000000~nОперация подлежит финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
                v-kfm9 = true.
                k = k + 1.
            end.
      end.
      */

      find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
      /*if avail aaa then do:
          find first cif where cif.cif = aaa.cif no-lock no-error.
          if avail cif then do:
              find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" use-index dcod no-lock no-error.
              if avail sub-cod and sub-cod.ccode = '8' then do:
                  if remtrz.fcrc = 1 then v-monamt = remtrz.amt.
                  else do:
                      for each jl where jl.acc = remtrz.sacc and jl.dc = 'D' and jl.jdt > (g-today - 7) and jl.jdt <= g-today no-lock:
                          find first jh where jh.jh = jl.jh no-lock no-error.
                          if not avail jh then next.
                          if not (jh.ref matches 'RMZ*') then next.
                          find first b-remtrz where b-remtrz.remtrz = jh.ref no-lock no-error.
                          if not avail b-remtrz then next.

                          if jl.crc = 1 then v-monamt = v-monamt + jl.dam.
                          else do:
                             find last crchis where crchis.crc = jl.crc and crchis.rdt < jl.jdt no-lock no-error.
                             v-monamt = v-monamt + jl.dam * crchis.rate[1].
                          end.

                      end.
                      v-mess = 1.
                  end.
                  if v-monamt >= 6000000 then do:
                      if not v-kfm1 and not v-kfm2 and not v-kfm3 and not v-kfm4 and not v-kfm10 then do:
                         if v-mess = 1 then message 'Общая сумма переводов благотворительной организации за последние 7 дней >= 6000000 тенге.~nОперация подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                         else message 'Перевод благотворительной организации на сумму >= 6000000 тенге подлежит финансовому мониторингу! ' view-as alert-box title 'ВНИМАНИЕ'.
                      end.
                      v-kfm10 = yes.
                      k = k + 1.
                   end.
              end.
          end.
      end.

  end.
  if v-kfm1 or v-kfm2 or v-kfm3 or v-kfm4 or v-kfm5 or v-kfm6 or v-kfm7 or v-kfm8 or v-kfm9 or v-kfm10 then do:
     if v-kfm1 then v-oper = '06'.
     if not v-kfm1 and v-kfm2 then v-oper = '11'.
     if not v-kfm1 and not v-kfm2 and v-kfm3 then  v-oper = '09'.
     if not v-kfm1 and not v-kfm2 and v-kfm4 then  v-oper = '16'.
     if not v-kfm1 and not v-kfm2 and v-kfm5 then v-oper = '13'.
     if not v-kfm1 and not v-kfm2 and v-kfm6 then v-oper = '17'.
     if not v-kfm1 and not v-kfm2 and v-kfm7 then v-oper = '18'.
     if not v-kfm1 and not v-kfm2 and v-kfm8 then v-oper = '19'.
     if not v-kfm1 and not v-kfm2 and v-kfm9 then v-oper = '10'.
     if not v-kfm1 and not v-kfm2 and not v-kfm3 and not v-kfm4 and v-kfm10 then v-oper = '09'.

     v-kfmrem = ''.
     if k >= 2 then v-kfmrem = 'Имеется дополнительный признак для фин. мониторинга!'.
     run fm1.
     if not kfmres then return.
     if v-kfm then run kfmcopy(v-operId,remtrz.remtrz,'fm',0).
  end.*/




  /*----------- amount control -------------------- */
find sysc where sysc.sysc = "trxcon" no-lock no-error.
if avail sysc then do :
    find first cursts where cursts.sub = "rmz" and cursts.acc = remtrz.remtrz use-index subacc no-lock no-error .
    if not avail cursts or (avail cursts and cursts.sts ne "con") then do :

        /*****************************valery*********************************************/
	    find sysc where sysc.sysc = "trxvip" no-lock no-error. /*если есть список vip юзверей*/
 	    if avail sysc and lookup(g-ofc, sysc.chval) > 0 then   /*то проверяем есть ли текущий юзверь в этом списке*/

 	         vip = true. /*если есть то флаг vip ставим в true*/



        if not vip then do: /*если флаг vip true, то значит юзверь в списке vip, а значит не делаем ни каких проверок на контроль*/

        /*****************************valery*********************************************/



	        run amt_ctrl(input remtrz.amt, remtrz.fcrc, output v-ctr).
	        if v-ctr then do :
	            run chgsts(input "rmz", remtrz.remtrz, "apr").
	            message " 1 TRX необходим контроль ". pause.
	            return.
	        end.

	    end. /*** этот end вставил я :) ******************valery*********************************/
    end.
end.
  /* контроль на заполнение ЕКНП */
def var v-pr as char.
run k-eknp(output v-pr).
if v-pr ne '0' then return.



run k-pdoctng(output v-pr, input remtrz.fcrc). /*03.03.2005 u00121 Проврека на заполнение справочника "Вид документа" ТЗ ї 1380 от 24.02.2005*/
if v-pr ne '0' then return.

/* 12/04/05 saltanat  -  Включила контроль КБК */
run k-kbk(output v-pr).
if v-pr ne '0' then return.


/*Вывод контрактов/ПС*/
if trim(g-fname) <> "A_KZ" then do:
    def buffer b-ncrchis for ncrchis.
    find first vcdocs where vcdocs.dnnum = s-remtrz no-lock no-error.
    if not avail vcdocs then do:
        find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
        if avail remtrz then do:
            find last ncrchis where ncrchis.rdt <= remtrz.rdt and ncrchis.crc = 2 no-lock no-error.
            if avail ncrchis then do:
                find last b-ncrchis where b-ncrchis.rdt <= remtrz.rdt and b-ncrchis.crc = remtrz.tcrc no-lock
                no-error.
                if avail b-ncrchis then v-sum-usd = remtrz.amt * b-ncrchis.rate[1] / ncrchis.rate[1].
            end.
            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz
            and sub-cod.d-cod = 'eknp' no-lock no-error.
            if avail sub-cod then do:
                v-knp1 = substr(sub-cod.rcode,7,3).
                if v-knp1 = '710' or v-knp1 = '780'  then do:
                    find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif and cif.type = 'b' no-lock no-error.
                        if avail cif then do:
                            if remtrz.fcrc <> 1 then do:
                             run sel ('Сделайте выбор:', ' 1. Выбор контракта/паспорта сделки | 2. Без контракта ').
                             v-select = return-value.
                             v-chk = yes.
                             if v-select = '1' and remtrz.fcrc <> 1 then do:
                                run vcshowct(cif.cif, remtrz.remtrz, remtrz.rdt,remtrz.tcrc, remtrz.amt, v-knp1, output v-prov).
                                if v-prov = no then return.
                             end.
                             if v-select = '' then return.
                            end.
                        end.
                    end.
                end.
                if (int(v-knp1) >= 810 and int(v-knp1) <= 890) /*and v-sum-usd > 50000*/ then do:
                    find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
                    if avail aaa then do:
                        find first cif where cif.cif = aaa.cif and cif.type = 'b' no-lock no-error.
                        if avail cif then do:
                             if remtrz.fcrc <> 1 then do:
                                 run sel ('Сделайте выбор:', ' 1. Выбор контракта/паспорта сделки | 2. Без контракта ').
                                 v-select = return-value.
                                 v-chk = yes.
                                 if v-select = '1'  then do:
                                    run vcshowct(cif.cif, remtrz.remtrz, remtrz.rdt,remtrz.tcrc, remtrz.amt, v-knp1, output v-prov).
                                    if v-prov = no then return.
                                 end.
                                 if v-select = '' then return.
                             end.
                        end.
                    end.
                end.
            end.
            if remtrz.tcrc <> 1 then do:
                v-sum-usd = 0.
                find last ncrchis where ncrchis.rdt <= remtrz.rdt and ncrchis.crc = 2 no-lock no-error.
                if avail ncrchis then do:
                    find last b-ncrchis where b-ncrchis.rdt <= remtrz.rdt and b-ncrchis.crc = remtrz.tcrc no-lock
                    no-error.
                    if avail b-ncrchis then v-sum-usd = remtrz.amt * b-ncrchis.rate[1] / ncrchis.rate[1].
                end.
                v-knp-chk = "".
                find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz
                and sub-cod.d-cod = 'iso3166' no-lock no-error.
                if avail sub-cod then v-coutry = sub-cod.ccode.
                find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = s-remtrz
                and sub-cod.d-cod = 'eknp' no-lock no-error.
                if avail sub-cod then do:
                    v-rez = substr(sub-cod.rcode,1,1).
                    v-fiz = substr(sub-cod.rcode,2,1).
                    v-knp-chk = substr(sub-cod.rcode,7,3).
                    v-sts = no.
                    if v-rez = "1" and v-fiz = "9" then do:
                        if (v-sum-usd >= 100000) and (v-knp-chk = '510' or v-knp-chk = '520'  or v-knp-chk = '540' or  v-knp-chk matches '8*')
                        then v-sts = yes.
                        if v-sum-usd >= 100000 and (v-knp-chk = '722')
                        then v-sts = yes.
                        if v-sum-usd >= 500000 and (v-knp-chk = '560')
                        then v-sts = yes.
                        if (v-knp-chk = '311' or v-knp-chk = '321') and v-coutry <> "KZ" then v-sts = yes.
                        if (v-sts and (remtrz.drgl <> 220520 and remtrz.drgl <> 220420
                        and substr(string(remtrz.drgl),1,4) <> '2203'
                        and substr(string(remtrz.drgl),1,4) <> '2206' and substr(string(remtrz.drgl),1,4) <> '2207'
                        and substr(string(remtrz.drgl),1,4) <> '2215' and substr(string(remtrz.drgl),1,4) <> '2217'
                        and substr(string(remtrz.drgl),1,4) <> '2219')) then do:
                            message "Данный перевод подлежит уведомлению НБРК," skip
                            "необходимо открытие счета клиенту!" view-as alert-box title "Внимание!".
                            return.
                        end.
                    end.
                end.
            end.
        end.
    end.
 end.  /* end for if trim(g-fname) <> "A_KZ" then do:*/

run isrmgnt.
pause 0.


/*run v-rmtrz.*/



pause 0.

 find sysc where sysc.sysc eq "CASHGL" no-lock.
 v-cash = no.
 for each jl where jl.jh eq remtrz.jh1 no-lock.
     if jl.gl eq sysc.inval then v-cash = true.
 end.

 v-wass = 0.

 do transaction :
 find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .
 for each jl where jl.jh eq remtrz.jh1 exclusive-lock :
     if v-cash then do :
         jl.sts = 5.
         run chgsts(input "rmz", remtrz.remtrz, "cas").

/*------ 20.11.2001, by sasco --- for big amounts - change status to "BAC" -*/
         v-bigamt = false.
         if jl.dam > 0.0 then v-bigcmp = jl.dam.
                            else v-bigcmp = jl.cam.
         if jl.crc = 1 then   do:
              find sysc where sysc.sysc = "trxco2" no-lock no-error.
              if avail sysc then v-cmpamt = decimal(entry(1, sysc.chval, " ")).
              else v-cmpamt = 3000000.00.
          end.
          else do:
              find sysc where sysc.sysc = "trxco2" no-lock no-error.
              if avail sysc then v-cmpamt = decimal(entry(2, sysc.chval, " ")).
              else v-cmpamt = 50000.00.
              run find-rate1(2, input jl.crc, input jl.whn, output v-rate1).
              run find-rate1(2, input 2, input jl.whn, output v-rate2).
              v-bigcmp = v-bigcmp * v-rate1 / v-rate2.
          end.

          /*if v-bigcmp >= v-cmpamt then
          if v-wass = 0 then v-wass = 1.*/

     end. /* vcash */
     else do:
         jl.sts = 6. jl.teller = g-ofc.
         run chgsts (input "rmz", input remtrz.remtrz, input "rdy").

         v-bigamt = false.
         if jl.dam > 0.0 then v-bigcmp = jl.dam.
                         else v-bigcmp = jl.cam.
         if jl.crc = 1 then do:
              find sysc where sysc.sysc = "trxco2" no-lock no-error.
              if avail sysc then v-cmpamt = decimal(entry(1, sysc.chval, " ")).
              else v-cmpamt = 3000000.00.
         end.
         else do:
             find sysc where sysc.sysc = "trxco2" no-lock no-error.
             if avail sysc then v-cmpamt = decimal(entry(2, sysc.chval, " ")).
             else v-cmpamt = 50000.00.
             run find-rate1(2, input jl.crc, input jl.whn, output v-rate1).
             run find-rate1(2, input 2, input jl.whn, output v-rate2).
             v-bigcmp = v-bigcmp * v-rate1 / v-rate2.
         end.

         /*if v-bigcmp >= v-cmpamt then
         if v-wass = 0 then v-wass = 2.*/

/* ---------------------------------  20.11.2001 ------------------------- */
     end. /* else */
end.  /* for each */
end.
def var v-onlval as logical init False.

do transaction:
   find jh where jh.jh eq remtrz.jh1 exclusive-lock.
   if v-cash then jh.sts = 5. else jh.sts = 6.
end.


/*29.10.2008 galina надо убрать проверку на ЦО при окончание тестирования*/
if g-today = today then do:
    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
    if avail sub-cod then do:
        if (remtrz.fcrc <> 1 and not substr(remtrz.sqn,19) matches "ДПС*")  or (remtrz.fcrc = 1 and (substr(sub-cod.rcode, 4, 1) = "2" or substr(sub-cod.rcode, 1, 1) = "2"))  then  do:
            if remtrz.vcact = "" then do:
                message "Внимание! Необходим валютный контроль в пункте 9.11!" view-as alert-box buttons ok title "" .
             end.
        end.
        if v-bigcmp < v-cmpamt then v-onlval = True.
        else v-onlval = False.
    end.
end.

/*run chgsts (input "rmz", remtrz.remtrz, "con").*/

if v-wass = 1 /* and not v-onlval */    /* cash */  then do:
    run chgsts (input "rmz", remtrz.remtrz, "bac").
    message "Внимание! Отошлите на контроль к старшему менеджеру (в 2.4.1.1)!" view-as alert-box buttons ok title "" .
end.

if v-wass = 2 /* account */ then do:
    run chgsts (input "rmz", remtrz.remtrz, "bap").
    message "Внимание! Отошлите на контроль к старшему менеджеру (в 2.4.1.1)!" view-as alert-box buttons ok title "" .
end.


/*  end. */  /* do transaction */

   /* если это суббота и платеж по погашению потреб кредита на счет группы 236, то отправляем без акцепта */
if g-today ne today then do:

       def new shared var v-fl as logi init false.
       def var v-path as char no-undo.
       find first cmp no-lock no-error.
       if cmp.name matches "*МКО*" then v-path = '/data/'.
                                            else v-path = '/data/b'.

       find txb where  txb.bank = remtrz.rbank no-lock no-error.
       if avail txb then do:

           connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
           run ispogntcheck(remtrz.racc).
           if connected ("txb") then disconnect "txb".


           if v-fl = true then do:
           v-text  = remtrz.remtrz + ' автоматическая отсылка по маршруту (платеж потреб. кредита)' .
           run lgps.
           do transaction:
                find current remtrz exclusive-lock.
                remtrz.cwho = 'auto'.
                remtrz.info[5] = 'auto'.
                find current remtrz no-lock.

                find first que where  que.remtrz  = remtrz.remtrz exclusive-lock no-error.
                if avail que then do:
                   find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
                   if remtrz.cracc = sysc.chval  then que.rcod = '0'.
                   else que.rcod = '1'.
                   que.pid  = 'P'.
                   que.dp = today.
                   que.tp = time.
                   que.con = 'F'.
                   release que.
                end.

           end.
           end.
       end.
end.
  /******************************************************************************************/

  release remtrz.
  release jh.
  release jl.


  pause 0.


procedure defclparam.
  v-cltype = ''.
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
  v-clbin = ''.
  v-claddr1 = ''.
  v-claddr2 = ''.

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

  v-prtOKPO = cif.ssn.
  find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
  if avail cif-mail then v-prtEmail = cif-mail.mail.
  v-prtPhone = cif.tel.
  v-clrnn = cif.jss.
  v-clbin = cif.bin.
  v-claddr1 = cif.addr[1].
  v-claddr2 = cif.addr[2].

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
  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.


  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

procedure deffilial.
     v-cltype = '01'.
     v-res = 'KZ'.
     v-res2 = '1'.

     find first codfr where codfr.codfr = 'DKPODP' and codfr.code = '1' no-lock no-error.
     if avail codfr then v-FIO1U = codfr.name[1].

     v-OKED = '65'.
     /*пока пустое, т.к. у филиала 12-значный ОКПО cmp.addr[3]*/
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


procedure fm1.
  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = string(remtrz.fcrc) no-lock no-error.
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
    if remtrz.outcode = 3 then do:
        if num-entries(v-bennameF) > 0 then v-benFAM = entry(1,v-bennameF).
        if num-entries(v-bennameF) > 1 then v-benNAM = entry(2,v-bennameF).
        if num-entries(v-bennameF) > 2 then v-benM = entry(3,v-bennameF).
    end.
  end.
  if avail sub-cod then v-knp = entry(3,sub-cod.rcode).
  if avail sub-cod then do:
    if substr(entry(2,sub-cod.rcode),1,1) <> '1' then v-resben2 = '0'.
    if substr(entry(2,sub-cod.rcode),1,1) = '1' then v-resben2 = '1'.
  end.
  if v-resben2 = '1' then v-resbenC = 'KZ'.

  if remtrz.fcrc <> 1 then do:
    find first crc where crc.crc = remtrz.fcr no-lock no-error.
    v-sumkzt = trim(string(remtrz.amt * crc.rate[1],'>>>>>>>>>>>>9.99')).
  end.

  if v-susp = 0 then run kfmoperh_cre('01','01',remtrz.remtrz,v-oper,v-knp,'2',codfr.code,trim(string(remtrz.amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).
  else run kfmoperh_cre('03','03',remtrz.remtrz,v-oper,v-knp,'2',codfr.code,trim(string(remtrz.amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).


  find first cmp no-lock no-error.
  find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.

  v-num = 0.
  v-num = v-num + 1.

  if remtrz.outcode = 6 then do:
      if remtrz.drgl <> 287032  then v-sacc = remtrz.sacc.
      else v-sacc = ''.
      v-castom = '01'.
  end.
  if remtrz.outcode = 1 then do:
      v-sacc = remtrz.sacc.
      v-castom = '01'.
  end.


  if remtrz.outcode = 3 then do:
      find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
      find first cif where cif.cif = aaa.cif no-lock no-error.
      run defclparam.
      v-sacc = remtrz.sacc.
      v-castom = '02'.
      run kfmprt_cre(v-operId,v-num,'01',v-castom,'57',v-res2,v-res,v-cltype,v-publicf,'',v-sacc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,v-clrnn,v-prtOKPO,v-OKED,v-clbin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,v-claddr1,v-claddr2,'','01').
  end.

  if remtrz.outcode = 1 or (remtrz.outcode = 6 and remtrz.drgl = 287032) then do:
     v-cltype = ''.
     find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error .
     if avail sub-cod then do:
       if substr(entry(1,sub-cod.rcode),2,1) = '9' then v-cltype = '02'.
       else v-cltype = '01'.
     end.

    run kfmprt_cre(v-operId,v-num,'01',v-castom,'57',v-res2,v-res,v-cltype,v-publicf,'',v-sacc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,v-clrnn,v-prtOKPO,v-OKED,v-clbin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,v-claddr1,v-claddr2,'','01').
  end.
  if remtrz.outcode = 6 and remtrz.drgl <> 287032 then do:
     run deffilial.
     v-num = v-num + 1.
     run kfmprt_cre(v-operId,v-num,'01','01','57',v-res2,v-res,'01','','',v-sacc,cmp.name,trim(sysc.chval),'KZ','','','','',cmp.name,v-FIO1U,v-rnn,v-prtOKPO,v-OKED,v-iin,'','','',v-prtPhone,v-prtEmail,'','','','','','','',v-addr,'','','01').
  end.

  v-num = v-num + 1.

  find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "iso3166" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then  v-resben = sub-cod.ccode.

  if remtrz.fcrc = 1 then do:

      v-rcbank = ''.
      find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
      if avail bankl then v-rcbank = trim(bankl.name).
      v-rcbankbik = ''.
      if remtrz.rcbank matches "TXB*" then do:
         find first txb where txb.consolid and txb.bank = remtrz.rcbank no-lock no-error.
         if avail txb then v-rcbankbik = txb.mfo.
      end.
      else v-rcbankbik = remtrz.rcbank.

      v-rbankbik = ''.
      if remtrz.rbank matches "TXB*" then do:
         find first txb where txb.consolid and txb.bank = remtrz.rbank no-lock no-error.
         if avail txb then v-rbankbik = txb.mfo.
      end.
      else v-rbankbik = remtrz.rbank.

      if num-entries(remtrz.bn[3],'/') >=3 then v-benbin = entry(3,remtrz.bn[3],'/').
 end.

 run kfmprt_cre(v-operId,v-num,'01','01','57',v-resben2,v-resbenC,v-bentype,'','',remtrz.ba,trim(remtrz.bb[1]) + trim(remtrz.bb[2]),v-rbankbik,v-resben,remtrz.cracc,v-rcbank,v-rcbankbik,'',v-bennameU,'','','','',v-benbin,v-benFAM,v-benNAM,v-benM,'','','','','','','','','','','','','02').
 if v-susp = 0 then s-operType = 'fm'.
 else s-operType = 'su'.
 run kfmoper_cre(v-operId).
 v-kfm = yes.
end procedure.


