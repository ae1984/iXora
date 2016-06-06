/* vccontrs.f
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        23.02.2004 nadejda  - запрашивать подтверждение на смену типа контракта
        01.07.2004 saltanat - в функцию chk-cttype включила обработку контрактов типа = 5.
        14.03.2008 galina   -  удалена ссылка на справочник для поля vccontrs.ctterm
        17.03.2008 galina   - изменен формат ввода для поля vccontrs.ctterm
        07.04.2008 galuna   - удален вывод поля vccontrs.custom;
                            добавлен вывод поля vccontrs.info[8] = основание закрытия контракта
        17.04.2008 galina   - проверка типа контракта - если тип контракта 7, можно указать нулевую сумму контракта
                            если тип контракта не равен 7, то сумма не может быть нулевой
        24.04.2008 galina   - итоговые суммы выводятся на три сроки ниже
        13.05.2008 galina   - добавление полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        02.06.2008 galina   - не выводить сообщение о не соотвествии типа конракта сумме документа для конрактов с типом не равным 2 или 1
        06.06.2008 galina   - добавления поля остаток непереведенных средств
        25.07.2008 galina   - проверка значения в поле СРОКИ в зависимости от типа контракта
        10.11.2008 galina   - проверка типа контракта - если тип контракта 7 или 3, можно указать нулевую сумму контракта
                            если тип контракта не равен 7 или 3, то сумма не может быть нулевой
        09.01.2009 galina   - добавила ограничение для ввода значений в поле Основание закрытия конракта и добавила обработку on help для этого поля
        18.05.2009 galina   - возмоность ввода пустой даты завершения контракта
        14.08.2009 galina   - добавила поле ЛКБК
        30/12/2009 galina   - увеличила длину счета для комиссии до 20
        7/10/2010 aigul     - спустила на 4 строки ОСТ.НЕПЕР.СР
        22.12.2010 aigul    - спустила на 1 строку ОСТ.НЕПЕР.СР
        27.12.2010 aigul    - вывод суммы залогов
        03.08.2011 damir    - добавил новые поля v-valogov1, v-valogov2 во фрейме vccontrs.
        05.08.2011 aigul    - новые поля банк корр и банк бен
        08.09.2011 damir    - добавил алгритм "выбор полей для корректировки", добавил vccontrs.opertyp, vccontrs.dtcorrect в форму (frame vccontrs).
        30.09.2011 damir    - добавил vccontrs.ctoriginal во фрейм vccontrs.
        07.10.2011 damir    - добавил фрэйм country.
        29.06.2012 damir    - изменения в form.
        26.07.2012 damir    - поправил формат в переменной v-term,выходила ошибка.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/

/* vccontrs.f Валютный контроль
   Форма контракта

   18.10.2002 nadejda создан
*/
def var v-title as char.
def var v-partnername as char.
def var v-crcname as char.
def var v-ctsumusd as deci.
def var v-vcaaa as char.
def var v-reason as char no-undo.
def var v-selreas as inte no-undo.
def var v-ordben as char.
def var v-countryplat as char.
def var v-term as inte format "zzzzzzzzzzzzzzzzzzzzz9-".
def var msg-err as char.
def var v-sel as char.
def var v-string as char.
def var s as inte.
def var v-s as inte.
def var v-cod as char.

def new shared var v-sumgtd as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-suminv as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-suminv% as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumplat as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumkon as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumost as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumakt as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc% as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumzalog as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc_6 as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumost1 as deci format "zzz,zzz,zzz,zzz,zz9.99-".

def new shared temp-table t-chc no-undo
    field k as inte
    field nam as char
    field cod as char
index idx1 is primary k ascending.

def buffer b-vccontrs for vccontrs.

{vc-crosscurs.i}

function check-valpl returns char (p-valpl as char).
    def var i as integer.
    def var s as char.
    def var l as logical.
    p-valpl = trim(p-valpl).
    if p-valpl = "" then s = "".
    else do:
        if substring(p-valpl, length(p-valpl), 1) = "," then
        p-valpl = substring(p-valpl, length(p-valpl) - 1).
        l = true.
        do i = 1 to num-entries(p-valpl) :
            s = entry(i, p-valpl).
            if s = "" or not (can-find(ncrc where ncrc.code = s no-lock)) then do:
            l = false. leave. end.
        end.
        if l then s = "".
    end.
    return s.
end.


function check-formrs returns char (p-formrs as char).
    def var i as integer.
    def var s as char.
    def var l as logical.
    p-formrs = trim(p-formrs).
    if p-formrs = "" then s = "".
    else do:
        if substring(p-formrs, length(p-formrs), 1) = "," then p-formrs = substring(p-formrs, length(p-formrs) - 1).
        l = true.
        do i = 1 to num-entries(p-formrs) :
            s = entry(i, p-formrs).
            if s = "" or s = "msc" or not can-find(codfr where codfr.codfr = "vcfpay" and codfr.code = s no-lock) then do:
            l = false. leave. end.
        end.
        if l then s = "".
    end.
    return s.
end.

/*function check-term returns char (p-term as char).
    def var i as integer.
    def var s as char.
    def var l as logical.
    p-term = trim(p-term).
    if p-term = "" then s = "".
    else do:
    if substring(p-term, length(p-term), 1) = "," then
    p-term = substring(p-term, length(p-term) - 1).
    l = true.
    do i = 1 to num-entries(p-term) :
    s = entry(i, p-term).
    if s = "" or s = "msc" or
    not can-find(codfr where codfr.codfr = "vcterm" and codfr.code = s no-lock) then do:
    l = false. leave. end.
    end.
    if l then s = "".
    end.
    return s.
end.*/

function check-term returns char (p-term as char, p-cttype as char).
    def var v-days as integer.
    def var v-years as integer.
    def var s as char init ''.

    v-days = integer(substring(string(p-term,'999.99' ),1,3)).
    v-years = integer(substring(string(p-term, '999.99'),5,2)).

    if ((p-cttype = '1' or p-cttype = '9') and v-days < 180 and v-years = 0) then do:
        msg-err = "Для данного типа контракта ориентировочный срок не может быть меньше 180 дней!".
        s = '*'.
    end.
    if v-days > 359 then do:
        msg-err = "Количество дней не может быть больше 359!".
        s = '*'.
    end.
    if (lookup(p-cttype,'13,4,5,7,8') = 0 and v-days = 0 and v-years = 0) then do:
        msg-err = "Для данного типа контракта ориентировочный срок не может быть равен 0!!".
        s = '*'.
    end.
    return s.
end.

function chk-cttype returns logical (p-value as char).
    def var sp as deci.
    def var v-cttype as char.
    def var v-ans as logical.

    if p-value = "" then do:
        msg-err = " Введите тип контракта!".
        return false.
    end.
    if not can-find(codfr where codfr.codfr = "vccontr" and codfr.code = vccontrs.cttype and codfr.code <> "msc" no-lock) then do:
        msg-err = " Нет такого кода в справочнике типов контрактов!".
        return false.
    end.
    if /*((p-value <> "3") and (p-value <> "5"))*/ ((p-value = "1") and (p-value = "2")) and (vccontrs.ctsum > 0) then do:
        find vcparams where vcparams.parcode = "minpassp" no-lock no-error.
        if avail vcparams then sp = vcparams.valdeci. else sp = 5000.
        if vccontrs.ctsum / vccontrs.cursdoc-usd > sp then v-cttype = "1".
        else v-cttype = "2".

        if p-value <> v-cttype then do:
            v-ans = no.
            message skip
            " Указанный тип контракта не сответствует минимальной сумме оформления УНК !" skip
            " Вы уверены в правильности указания типа контракта ?" skip(1)
            view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-ans.
            if not v-ans then do:
                msg-err = " Неверный тип контракта - не соответствует сумме оформления УНК!".
                return false.
            end.
        end.
    end.
    return true.
end.

function chk-sts returns logical (p-value as char).

    if p-value = "" then do:
        msg-err = " Введите статус контракта!".
        return false.
    end.

    find codfr where codfr.codfr = "vcctsts" and codfr.code = p-value no-lock no-error.
    if not avail codfr or p-value = "msc" then do:
        msg-err = " Недопустимое значение статуса контракта!".
        return false.
    end.

    if p-value = "N" then do:
        find first vcps where vcps.contract = s-contract no-lock no-error.
        find first vcrslc where vcrslc.contract = s-contract no-lock no-error.
        find first vcdocs where vcdocs.contract = s-contract no-lock no-error.
        if avail vcps or avail vcrslc or avail vcdocs then do:
            msg-err = " Есть документы по контракту - нельзя присвоить статус 'Новый' (N) !".
            return false.
        end.
    end.
    return true.
end.

function chk-crc returns logical (p-value as integer).
    if p-value = 0 then do:
        msg-err = " Выберите валюту контракта!".
        return false.
    end.
    if not can-find(ncrc where ncrc.crc = p-value no-lock) then do:
        msg-err = " Нет такой валюты в справочнике курсов валют НБ РК!".
        return false.
    end.
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = p-value no-lock no-error.
    if avail ncrc and ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= vccontrs.ctregdt then do:
        msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
        " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.
    return true.
end.

function chk-dt returns logical (p-value as date).
    if p-value = ? then do:
    msg-err = " Введите дату контракта!". return false. end.
    if p-value > vccontrs.ctregdt then do:
    msg-err = " Дата контракта не может быть больше даты регистраци по журналу!". return false. end.
    if p-value > vccontrs.lastdate and (vccontrs.cttype <> '1' or  vccontrs.lastdate <> ?) then do:
    msg-err = " Дата контракта не может быть больше последней даты!". return false. end.
    if can-find(b-vccontrs where b-vccontrs.cif = vccontrs.cif and b-vccontrs.ctnum = vccontrs.ctnum and
    b-vccontrs.ctdate = p-value and b-vccontrs.contract <> vccontrs.contract no-lock) then do:
    msg-err = " Уже есть контракт с таким номером и датой у данного клиента!". return false. end.
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    if avail ncrc and ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-value then do:
        msg-err = " Нельзя пользоваться валютой " + ncrc.code + " после " + entry(2, ncrc.prefix) +
        " - заменена " + entry(1, ncrc.prefix) + " !".
        return false.
    end.
    return true.
end.

function check-acc returns logical (p-value as char).
    if p-value = "" then do:
        msg-err = " Укажите текущий счет для снятия комиссий по контракту !".
        return false.
    end.
    find aaa where aaa.aaa = p-value no-lock no-error.
    if not avail aaa then do:
        msg-err = " Счет не найден !".
        return false.
    end.
    if aaa.cif <> vccontrs.cif then do:
        msg-err = " Счет принадлежит другому клиенту !".
        return false.
    end.
    return true.
end.

function check-summ return logical(p-summ as decimal, p-type as char).
    if p-type = '7' or p-type = '3' then return true.
    else if p-summ = 0 then do:
        msg-err = "Сумма не может быть нулевой!".
        return false.
    end.
    return true.
end.

function chk-inn returns logical (p-value as char).
    /*if can-find(vcpartner where vcpartner.partner = vccontrs.partner and vcpartner.country = "RU" no-lock) and p-value = "" then do:*/
    if vccontrs.ctvalpl matches "*RUB*" and p-value = "" then do:
        msg-err = " Введите ИНН получателя!".
        return false.
    end.
    return true.
end.

form
    vccontrs.opertyp colon 17 label "ТИП ОПЕР."  format "9"  validate(vccontrs.opertyp <> 0, 'Выберите поле(я) для редактирования контракта, нажав F2 !') help "Нажмите F2, выберите поле(я) для редактирования!"
    /*  vccontrs.contract colon 10 */
    vccontrs.dtcorrect colon 54 label "ДАТА ПОСЛ.КОРР." format "99/99/9999" skip
    vccontrs.ctnum colon 17 validate(vccontrs.ctnum <> "" and not can-find(b-vccontrs where b-vccontrs.cif = vccontrs.cif and
    b-vccontrs.ctnum = vccontrs.ctnum and b-vccontrs.ctdate = vccontrs.ctdate and b-vccontrs.contract <> vccontrs.contract no-lock)," Уже есть контракт с таким номером и датой у данного клиента!")
    vccontrs.expimp colon 54 label "Экспорт/Импорт"
    vccontrs.sts colon 64 format "xx" label "СТС" validate(chk-sts(vccontrs.sts), msg-err) help " Код статуса контракта (F2 - помощь)"
    vccontrs.stsdt format "99/99/9999" no-label colon 67 skip
    /*vccontrs.ctoriginal label "ОРИГ. КОНТР." colon 17 help "Выберите yes/no" skip*/
    vccontrs.ctdate colon 17 label "ДАТА КОНТРАКТА" validate(chk-dt(vccontrs.ctdate), msg-err) skip
    vccontrs.ctregnom format ">>>>9" label "РЕГ.ЖУРНАЛ" colon 17 help " Номер по журналу регистрации"
    vccontrs.ctregdt format "99/99/9999" no-label colon 25
    /*vccontrs.custom format "x(5)" label "ТАМОЖ.ОРГАН" colon 54 help " Код таможенного органа по классификатору (F2 - помощь)" validate(vccontrs.custom <> "", " Укажите код таможенного органа!")*/
    vccontrs.info[8]  format "x(2)" label "ОСНОВ.ЗАКРЫТИЯ" colon 54
    validate(can-find(codfr where codfr.codfr = 'vcreason' and codfr.code = vccontrs.info[8] no-lock),'Неверное основание закрытия контракта!')
    help " Код основания закрытия контракта (F2 - помощь)"
    vccontrs.cttype label "ТИП" colon 67 validate(chk-cttype(vccontrs.cttype), msg-err) skip
    vccontrs.lastdate colon 54 validate(vccontrs.cttype = "1" or vccontrs.lastdate >= vccontrs.ctdate,"Последняя дата не может быть меньше даты контракта!") skip
    vccontrs.partner colon 17 validate(vccontrs.partner = "" or can-find(vcpartner where vcpartner.partner = vccontrs.partner no-lock)," Нет такого партнера в списке инопартнеров!")
    v-partnername colon 28 no-label format "x(40)" skip
    vccontrs.ncrc colon 17 label "ВАЛЮТА КОНТР" validate(chk-crc(vccontrs.ncrc), msg-err)
    v-crcname no-label colon 20 format "xxx"
    /*vccontrs.ctsum colon 54 validate(vccontrs.ctsum > 0,"Сумма не может быть нулевой!") skip*/
    vccontrs.ctsum colon 54 validate(check-summ(vccontrs.ctsum,vccontrs.cttype), msg-err) skip
    vccontrs.ctvalpl colon 17 format "x(20)" validate(check-valpl(vccontrs.ctvalpl) = "","Введен неверный код валюты " + check-valpl(vccontrs.ctvalpl) + " !")
    vccontrs.cursdoc-usd colon 54 format ">>>>>>>>>9.999999" validate(vccontrs.cursdoc-usd > 0,"Курс не может быть нулевым!") label "КУРС К USD" skip
    v-vcaaa colon 17 format "x(20)" label "Т/СЧЕТ ДЛЯ КОМ." help " F2 - текущие счета клиента" validate (check-acc(v-vcaaa), msg-err)
    v-ctsumusd format ">>>,>>>,>>>,>>>,>>9.99" colon 54 label "СУММА В USD" skip
    vccontrs.info[2] colon 17 label "ТОВАР" skip
    vccontrs.info[3] colon 17 label "ДОПОЛНИТ. СВЕД-Я" skip
    /*vccontrs.info[1] colon 17 label "ВАЛЮТ.ОГОВОРКА" skip*/
    /*v-valogov1 colon 17 format "x(60)" label "ВАЛ.ОГОВ.(вал. )" skip
    v-valogov2 colon 17 format "x(60)" label "ВАЛ.ОГОВ.(прим.)" skip*/
    vccontrs.cardnum format "x(30)" colon 17 label "№ ЛКБК" skip
    vccontrs.ctformrs colon 17 format "x(24)" validate(check-formrs(vccontrs.ctformrs) = "","Введен неверный код формы расчетов " + check-formrs(vccontrs.ctformrs) + " !")
    vccontrs.rdt label "РЕГ." colon 54
    vccontrs.rwho no-label colon 69 skip
    /*vccontrs.ctterm colon 17 format "x(24)"*/
    vccontrs.ctterm label "СРОКИ РЕПАТР" colon 17 format "999.99" validate(check-term(vccontrs.ctterm,vccontrs.cttype) = "", msg-err)
    vccontrs.cdt label "АКЦ." colon 54
    vccontrs.cwho no-label colon 69 skip
    "БАНКОВСКИЕ РЕКВИЗИТЫ ИНОПАРТНЕРА:" colon 17 skip
    vccontrs.bankcsw label "SWIFT банк-корр" colon 17 format "x(35)" skip
    v-bc colon 17 format "x(35)" label "Банк-корреспон" skip
    v-bc1 colon 17 format "x(35)" label "" skip
    v-bc2 colon 17 format "x(35)" label "" skip
    /*v-bc3 colon 17 format "x(35)" label "" skip*/
    /*vccontrs.bankc label "банк-корреспонд" colon 17 skip*/
    vccontrs.bankbsw label "SWIFT банк-бен" colon 17  format "x(35)" skip
    v-bb colon 17 format "x(35)" label "Банк бенефициар" skip
    v-bb1 colon 17 format "x(35)" label "" skip
    v-bb2 colon 17 format "x(35)" label "" skip
    /*v-bb3 colon 17 format "x(35)" label "" skip*/
    /*vccontrs.bankb label "банк-бенефициар" colon 17 skip*/
    vccontrs.bankbacc label "счет получ" colon 17 format "x(31)" skip
    vccontrs.inn label "ИНН" colon 17 format "x(12)" /*validate(chk-inn(vccontrs.inn), msg-err)*/ skip
    "------------------------------------------------------------------------------" skip
    v-sumost1 label "ОСТ.НЕПЕР.СР." colon 14       v-sumgtd label "СУММА ГТД" colon 54 skip
    v-suminv label "ИНВ,СПЕЦ,УСЛ" colon 14   v-sumkon label "КОНТРОЛ" colon 54 skip
    v-sumexc label "ЗАЕМНЫЕ СР-ВА" colon 14       v-sumplat label "ОПЛАТЫ" colon 54 skip
    v-sumakt label "СУММА АКТОВ" colon 14       v-sumost label "ОСТАТОК" colon 54 skip
    v-sumexc% label "СУММА ЗАЙМ.%" colon 14   v-term label "СРОК ДВИЖ.КАП." colon 54 skip
    v-sumzalog label "Залоги" colon 14
with side-label row 3 width 80 title "КЛИЕНТ : " + v-cifname frame vccontrs.

form
    v-ordben label "Наименование/ФИО" format "x(80)" skip
    v-countryplat label "Страна" format "x(2)" skip
with row 18 column 1 width 100 overlay side-label title "НЕРЕЗИДЕНТ" frame country.

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*
Значение в comm.vccontrs.info[4]

ОКПО банка-11
Признак Экспорт/Импорт-12
Номер контракта-13
Дата контракта-14
Сумма контракта-15
Наименование нерезидента-16
Страна нерезидента-17
Сроки репатриации-18
Примечание-19
Валюта контракта-20
Последняя дата-21
Дата закрытия УНК-22
Основание закрытия УНК-23
Валюта платежа-24
Код способа расчетов-25
Валютная оговорка-26
Детали валютной оговорки-27
*/
do s = 1 to 11:
    find t-chc where t-chc.k = s no-lock no-error.
    if not avail t-chc then do:
        create t-chc.
        t-chc.k = s.
        if s = 1 then do: t-chc.nam = "Признак Экспорт/Импорт". t-chc.cod = "12". end.
        if s = 2 then do: t-chc.nam = "Номер контракта". t-chc.cod = "13". end.
        if s = 3 then do: t-chc.nam = "Дата контракта". t-chc.cod = "14". end.
        if s = 4 then do: t-chc.nam = "Сумма контракта". t-chc.cod = "15". end.
        if s = 5 then do: t-chc.nam = "Наименование нерезидента". t-chc.cod = "16". end.
        if s = 6 then do: t-chc.nam = "Страна нерезидента". t-chc.cod = "17". end.
        if s = 7 then do: t-chc.nam = "Сроки репатриации". t-chc.cod = "18". end.
        if s = 8 then do: t-chc.nam = "Валюта контракта". t-chc.cod = "20". end.
        if s = 9 then do: t-chc.nam = "Последняя дата". t-chc.cod = "21". end.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*on help of vccontrs.custom in frame vccontrs do:
  run uni_help1 ("customs", "*").
end.*/

on help of vccontrs.sts in frame vccontrs do:
    run uni_help1 ("vcctsts", "*").
end.

on help of vccontrs.info[8] in frame vccontrs do:
    if v-reason = "" then do:
        for each codfr where codfr.codfr = 'vcreason' and codfr.code <> 'msc' no-lock:
            if v-reason <> "" then v-reason = v-reason + " |".
            v-reason = v-reason + string(codfr.code) + " " + codfr.name[1].
        end.
    end.
    run sel2 (" ВЫБЕРИТЕ ОСНОВАНИЕ ЗАКРЫТИЯ КОНТРАКТА", v-reason, output v-selreas).
    if v-selreas <> 0 then vccontrs.info[8] = trim(entry(1,(entry(v-selreas,v-reason, '|')),' ')).
    display vccontrs.info[8] with frame vccontrs.
end.

on help of vccontrs.expimp in frame vccontrs do:
    def var v-sl as char.
    v-sl = "".
    run sel("ПРИЗНАК","1.Экспорт|2.Импорт").
    v-sl = trim(return-value).
    if v-sl = "1" then vccontrs.expimp = "E".
    if v-sl = "2" then vccontrs.expimp = "I".
    displ vccontrs.expimp with frame vccontrs.
end.

on help of vccontrs.opertyp in frame vccontrs do:
    v-s = 0.
    for each t-chc no-lock:
        if v-string <> "" then v-string = v-string + " |".
        v-string = v-string + t-chc.nam.
        v-s = v-s + 1.
    end.
    v-sel = "".
    run sel_mt1("insert - выбор изменненной графы, delete - отменить выбор",v-string,vccontrs.contract,v-s,output v-sel).
    vccontrs.opertyp = 2.
    displ vccontrs.opertyp with frame vccontrs.
    if v-sel <> "" then do:
        v-check = yes.
        if lookup('1',v-sel) > 0 then do: v-cod = "". run Fchg("1",output v-cod). run Cdoc(v-cod). end.
        if lookup('2',v-sel) > 0 then do: v-cod = "". run Fchg("2",output v-cod). run Cdoc(v-cod). end.
        if lookup('3',v-sel) > 0 then do: v-cod = "". run Fchg("3",output v-cod). run Cdoc(v-cod). end.
        if lookup('4',v-sel) > 0 then do: v-cod = "". run Fchg("4",output v-cod). run Cdoc(v-cod). end.
        if lookup('5',v-sel) > 0 then do: v-cod = "". run Fchg("5",output v-cod). run Cdoc(v-cod). end.
        if lookup('6',v-sel) > 0 then do: v-cod = "". run Fchg("6",output v-cod). run Cdoc(v-cod). end.
        if lookup('7',v-sel) > 0 then do: v-cod = "". run Fchg("7",output v-cod). run Cdoc(v-cod). end.
        if lookup('8',v-sel) > 0 then do: v-cod = "". run Fchg("8",output v-cod). run Cdoc(v-cod). end.
        if lookup('9',v-sel) > 0 then do: v-cod = "". run Fchg("9",output v-cod). run Cdoc(v-cod). end.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
procedure Cdoc:
    def input parameter cod as char.

    if not lookup(cod,vccontrs.info[4]) > 0 then do:
        if vccontrs.info[4] <> "" then vccontrs.info[4] = vccontrs.info[4] + ',' + cod.
        else vccontrs.info[4] = cod.
    end.
end procedure.

procedure Fchg:
    def input parameter sel as char.
    def output parameter cod as char.

    find t-chc where t-chc.k = inte(sel) no-lock no-error.
    if avail t-chc then cod = t-chc.cod.
end procedure.
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/