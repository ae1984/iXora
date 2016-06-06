/* vccontrs.p
 * MODULE
        Валютный контроль
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
        23.02.2004 nadejda - запрашивать подтверждение на смену типа контракта
        01.07.2004 saltanat - в процедуру defcttype включила обработку контрактов типа = 5.
        21.09.2004 saltanat - для редактирования и удаления вставила проверку на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        11.01.2005 saltanat - Предусмотрела исключение для редактирования и т.д.
        23.05.2005 saltanat - Миним. остаток для рег/свид изменила на 0
        03.10.2006 u00600 - в процедуре updating добавила обязательное заполнение поля vccontrs.ctregnom (номер журнала регистрации)
                            при типе контракта = 1
        12/03/2008 galina - перекомпиляция в связи с изменением vccontrs.f
        17.03.2008 galina - количество дней до предупреждения изменено на 180 для контрактов по  услугам
   					   количестов дней  до предупреждения берется из сроков контракта для контрактов по товарам
        25.03.2008 galina - устранена ошибка Не могу понять после "format 999.99".
        07.04.2008 galuna - удалено обновление и вывод поля vccontrs.custom;
                            добавлено вывод поля vccontrs.info[8] = основание закрытия контракта
        17.04.2008 galina - удалено разграничение прав для пользователя по ID
        17.04.2008 galina - для редактирования и удаления удалена проверка на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        18.04.2008 galina - добавлено редактироване даты регистрации контракта
        21.04.2008 galina - автоматическое формирование ПС для окнтрактов типа 1
                            изменения на конракте копируются в ПС
        13.05.2008 galina - не проверять на наличие рег.свидетельств и лицензий
                            добавление полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        14.05.2008 galina - срок поступления валюты для контрактов на услуи брать с контракта
        29.05.2008 galina - для контрактов типа 9 копировать изменения в конракте в ПС
        02.06.2008 galina - перекомпеляция в связи с изменениями в vccontrs.f
        06.06.2008 galina - добавления поля остаток непереведенных средств
        25.07.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        10.10.2008 galina - перекомпиляция в связи с изменением vccontrs.f
        09.01.2008 galina - добавила редактирование поля Основание закрытия контракта
        27.04.2009 galina - перенесла на акцепт создание УНК
        18.05.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        14.08.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        26.08.2009 galina - в процедуру check_term не передаем дату
        30.12.2009 galina - перекомпиляция в связи с изменением vccontrs.f
        08.12.2010 aigul - для расчета курса USD подтягивать дату заключения контракта, а не дату регистрации контракта
        28.12.2010 aigul - вывод суммы залога
        28.02.2011 aigul - добавила if avail vcdocs then vp-dt = vcdocs.dndate.
        else vp-dt = g-today.
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        03.08.2011 damir - новые переменные v-valogov1, v-valogov2 (Валютная оговорка).
        05.08.2011 aigul - новые переменные для банка бен и корр
        09.08.2011 damir - смотреть на заполнение знака " | " в вал.огов. только если тип контракта "1".
        08.09.2011 damir - Добавил: 1) отображение vccontrs.opertyp,vccontrs.dtcorrect во frame vccontrs.
                           2) Если тип контракта "1" то при редактировании полей таблицы vccontrs, если данные были изменены, запись идет
                           в таблицу vccorrecthis, остальных типов не касается.
                           3) временную табл. t-vccontrs, перем. v-check, v-newupd
        09.09.2011 damir - перекомпиляция.
        15.09.2011 damir - пропускаем заполнение тип опер. если дата создания контракта совпадает с операционной датой.
        30.09.2011 damir - update vccontrs.ctoriginal только при создании нового контракта.
        07.10.2011 damir - добавил procedure copying.
        28.12.2011 damir - небольшие корректировки.
        28.03.2012 damir - чтобы пропускало только через клавишу F2 при наборе ТИП ОПЕР.
        03.04.2012 damir - поместил поля которые должны редактироваться всегда в процедуру updfield....
        06.04.2012 damir - перекомпиляция, убрал условие строка 2094.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        29.06.2012 damir - добавил funcvc.i, ТИП ОПЕР. 3, изменения в vccontrs.f form.
        02.07.2012 damir - перекомпиляция, ошибка при компиляции библиотеки.
        16.07.2012 damir - если тип контракта 2 - то регистрация только при сумме >= 10000. если тип контракта 1 > 50000.
        25.12.2012 damir - Внедрено Т.З. № 1306.
        03.05.2013 damir - Внедрено Т.З. № 1107.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
        */
{vc.i}
{mainhead.i}
{comm-txb.i}
{funcvc.i}
{vcmainshared.i}

def shared var s-cif            like cif.cif.
def new shared var s-avail03    as logi.
def new shared var v-chk        as logi initial no.
def new shared var s-change     as logi.

def var vp-days     as integer.
def var vp-days-ch  as char format "999.99".
def var vp-daysost  as integer.
def var v-docsplat  as char init "".
def var v-vrsumakt  as deci.

def buffer b-vcdocs   for vcdocs.

def var v-valogov1 as char.
def var v-valogov2 as char.

def temp-table t-vccontrs   like vccontrs.

def var v-bb as char.
def var v-bb1 as char.
def var v-bb2 as char.
def var v-bb3 as char.
def var v-bc as char.
def var v-bc1 as char.
def var v-bc2 as char.
def var v-bc3 as char.
def var v-chang as logi format "да/нет" init no.
def var v-check as logi init no.
def var v-txbbank as char.
def var v-bnkbin as char.
def var v-sum as deci.
def var v-chg as logi format "да/нет" init no.
def var v-stsopen as logi.

def temp-table vcdoc
    field contr  as inte
    field dt     as date
    field sum    as deci
    field docsum as deci
    field sts    as inte.

def temp-table vcdocum
    field contr  as inte
    field dt     as date.

for each codfr where codfr.codfr = "vcdoc" and index("p", codfr.name[5]) > 0 no-lock:
    v-docsplat = v-docsplat + codfr.code + ",".
end.

find vcparams where vcparams.parcode = "daymessg" no-lock no-error.
if avail vcparams then vp-daysost = vcparams.valinte. else vp-daysost = 10.

def var v-ourbnk as char.
v-ourbnk = comm-txb().

function DelQues returns char(input str as char).
    if str = ? then return "".
    else return str.
end function.

{vc-sisn.i

&head       =   "vccontrs"
&headkey    =   "contract"
&option     =   "VCCONTRS"
&noedt      =   false
&nodel      =   false
&variable   =   " if vccontrs.cdt <> ? then do: s-noedt = true. s-nodel = true. end. "
&no-delete  =   " /* if chkrights('vcctac') then do: message skip ' У вас нет прав для выполнения процедуры ! '
                view-as alert-box buttons ok title ' Внимание '. next main. end.*/
                find first vcps where vcps.contract = s-contract no-lock no-error.
                find first vcrslc where vcrslc.contract = s-contract no-lock no-error.
                find first vcdocs where vcdocs.contract = s-contract no-lock no-error.
                if (avail vcps) or (avail vcrslc) or (avail vcdocs) then do:
                    message skip 'По данному контракту есть документы ! ' skip(1)
                    'Удалить контракт вместе с документами ?' skip(1) view-as alert-box warning buttons yes-no title 'ВНИМАНИЕ!'
                    update v-choice as logical.
                    if v-choice = no then next.
                end. "
&delete     =   " if avail vccontrs then delete vccontrs. "
&predisplay =   " run predispl. run RegNBRK. "
&display    =   "
                display
                    vccontrs.opertyp vccontrs.dtcorrect vccontrs.ctnum vccontrs.sts vccontrs.stsdt vccontrs.ctregnom
                    vccontrs.ctregdt vccontrs.expimp vccontrs.info[8] /*vccontrs.custom vccontrs.ctoriginal*/ vccontrs.ctdate
                    vccontrs.cttype vccontrs.partner v-partnername vccontrs.ncrc v-crcname vccontrs.ctsum /*vccontrs.info[1]*/
                    /*v-valogov1 v-valogov2*/ v-vcaaa vccontrs.lastdate vccontrs.cursdoc-usd vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd
                    vccontrs.info[2] vccontrs.info[3] vccontrs.rdt vccontrs.rwho vccontrs.cdt vccontrs.cwho vccontrs.bankcsw v-bc
                    v-bc1 v-bc2 /*v-bc3*/ vccontrs.bankbsw v-bb v-bb1 v-bb2 /*v-bb3*/ vccontrs.bankbacc vccontrs.inn
                    vccontrs.ctvalpl vccontrs.ctformrs vccontrs.ctterm v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat
                    v-sumakt v-sumost v-sumexc% v-term v-sumzalog vccontrs.cardnum
                with frame vccontrs.
                "
&postdisplay =  " if not vccontrs.sts begins 'c' then run check-dolg.
                  run checkcontract. "
&no-update  =   " /*if chkrights('vcctac') then do: message skip ' У вас нет прав для выполнения процедуры ! '
                view-as alert-box buttons ok title ' Внимание '. next main. end.*/
                if vccontrs.sts begins 'C' then do:
                    bell.
                    if vccontrs.cttype = '1' then message ' Вы хотите возобновить действие контракта ? ' view-as alert-box buttons yes-no title 'Внимание' update v-chg.
                    if not v-chg then next main.
                end. "
&preupdate  =   " "
&update     =   "   if vccontrs.cttype = '1' then do:
                        if not s-newrec then do:
                            if vccontrs.ctregdt <> g-today and not (vccontrs.sts begins 'C') then do:
                                update vccontrs.ctvalpl vccontrs.info[2] vccontrs.info[3] vccontrs.ctformrs with frame vccontrs.
                                run defupd.
                                update vccontrs.bankcsw with frame vccontrs.
                                if vccontrs.bankcsw <> '' then do:
                                    find first swibic where swibic.bic matches vccontrs.bankcsw  + '*' no-lock no-error.
                                    if avail swibic then do:
                                      vccontrs.bankcsw = swibic.bic.
                                      v-bc = substr(string(swibic.name), 1, 35).
                                      v-bc1 = substr(string(swibic.name), 36, 35).
                                      v-bc2 = substr(string(swibic.name), 72, 35).
                                    end.
                                end.
                                update v-bc v-bc1 v-bc2 vccontrs.bankbsw with frame vccontrs.
                                if vccontrs.bankbsw <> '' then do:
                                    find first swibic where swibic.bic matches vccontrs.bankbsw + '*' no-lock no-error.
                                    if avail swibic then do:
                                      vccontrs.bankbsw = swibic.bic.
                                      v-bb = substr(string(swibic.name), 1, 35).
                                      v-bb1 = substr(string(swibic.name), 36, 35).
                                      v-bb2 = substr(string(swibic.name), 72, 35).
                                    end.
                                end.
                                update v-bb v-bb1 v-bb2 vccontrs.bankbacc vccontrs.inn with frame vccontrs.
                                vccontrs.bankb = v-bb + v-bb1 + v-bb2.
                                vccontrs.bankc = v-bc + v-bc1 + v-bc2.
                                if vccontrs.opertyp = 1 or (vccontrs.opertyp = 3 and g-today - vccontrs.stsdt >= 5) then do:
                                    message 'Документ не редактирован!' skip 'Редактировать с помощью F2(ТИП ОПЕР.)?' view-as alert-box information buttons yes-no update v-chang.
                                    if v-chang then do:
                                        metka1:
                                        do while (keyfunction(lastkey) <> 'F2'):
                                            update vccontrs.opertyp with frame vccontrs.
                                            if v-sel <> '' then leave metka1.
                                        end.
                                    end.
                                    else next.
                                end.
                                else if vccontrs.opertyp = 2 then do:
                                    message 'Документ редактирован!' skip 'Редактировать с помощью F2 (ТИП ОПЕР.)?' view-as alert-box information buttons yes-no update v-chang.
                                    if v-chang then do:
                                        metka2:
                                        do while (keyfunction(lastkey) <> 'F2'):
                                            update vccontrs.opertyp with frame vccontrs.
                                            if v-sel <> '' then leave metka2.
                                        end.
                                    end.
                                    else next.
                                end.
                            end.
                            if vccontrs.sts begins 'C' then do:
                                update vccontrs.opertyp = 3 with frame vccontrs.
                                if vccontrs.opertyp = 3 then do:
                                    message 'ВНИМАНИЕ! Закрытие УНК будет отменено!' view-as alert-box buttons ok title 'СООБЩЕНИЕ'.
                                    update vccontrs.sts = 'A' with frame vccontrs.
                                    message 'Действие контракта возобновлено!' view-as alert-box buttons ok title 'ВНИМАНИЕ'.
                                end.
                            end.
                        end.
                    end.

                    if (s-newrec) or (vccontrs.cttype <> '1') or (vccontrs.cttype = '1' and s-newrec) or (vccontrs.cttype = '1' and not s-newrec and vccontrs.ctregdt = g-today) then do:
                        update vccontrs.ctnum vccontrs.expimp vccontrs.sts with frame vccontrs.
                        if vccontrs.sts = 'C' then update vccontrs.stsdt with frame vccontrs.
                        update vccontrs.ctdate vccontrs.ctregnom with frame vccontrs.
                        if vccontrs.ctregdt entered then do:
                            run crosscurs(vccontrs.ncrc, 2, vccontrs.ctdate, output vccontrs.cursdoc-usd).
                            run defcttype.
                            displ vccontrs.cttype vccontrs.cursdoc-usd vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd with frame vccontrs.
                        end.
                        if vccontrs.sts = 'C' then update vccontrs.info[8] with frame vccontrs.
                        update vccontrs.cttype with frame vccontrs.
                        update vccontrs.lastdate vccontrs.partner with frame vccontrs.
                        if vccontrs.partner entered then do:
                            run defpartner.
                            displ v-partnername with frame vccontrs.
                        end.
                        update vccontrs.ncrc with frame vccontrs.
                        if vccontrs.ncrc entered then do:
                            run defncrc.
                            run crosscurs(vccontrs.ncrc, 2, vccontrs.ctdate, output vccontrs.cursdoc-usd).
                            run defcttype.
                            displ vccontrs.cttype v-crcname vccontrs.cursdoc-usd
                            vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd
                            with frame vccontrs.
                        end.
                        update vccontrs.ctsum with frame vccontrs.
                        if vccontrs.ctsum entered then do:
                            run defcttype.
                            displ vccontrs.cttype vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd
                            with frame vccontrs.
                        end.
                        update vccontrs.ctvalpl vccontrs.cursdoc-usd with frame vccontrs.
                        if vccontrs.cursdoc-usd entered then do:
                            run defcttype.
                            displ vccontrs.cttype
                            vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd with frame vccontrs.
                        end.
                        update v-vcaaa vccontrs.info[2] vccontrs.info[3] vccontrs.ctformrs vccontrs.ctterm with frame vccontrs.
                        run defupd.
                        update vccontrs.bankcsw with frame vccontrs.
                        if vccontrs.bankcsw <> '' then do:
                            find first swibic where swibic.bic matches vccontrs.bankcsw  + '*' no-lock no-error.
                            if avail swibic then do:
                              vccontrs.bankcsw = swibic.bic.
                              v-bc = substr(string(swibic.name), 1, 35).
                              v-bc1 = substr(string(swibic.name), 36, 35).
                              v-bc2 = substr(string(swibic.name), 72, 35).
                            end.
                        end.
                        update v-bc v-bc1 v-bc2 vccontrs.bankbsw with frame vccontrs.
                        if vccontrs.bankbsw <> '' then do:
                            find first swibic where swibic.bic matches vccontrs.bankbsw + '*' no-lock no-error.
                            if avail swibic then do:
                              vccontrs.bankbsw = swibic.bic.
                              v-bb = substr(string(swibic.name), 1, 35).
                              v-bb1 = substr(string(swibic.name), 36, 35).
                              v-bb2 = substr(string(swibic.name), 72, 35).
                            end.
                        end.
                        update v-bb v-bb1 v-bb2 vccontrs.bankbacc vccontrs.inn with frame vccontrs.
                        vccontrs.bankb = v-bb + v-bb1 + v-bb2.
                        vccontrs.bankc = v-bc + v-bc1 + v-bc2.
                    end.

                    run SelField.

                    do transaction:
                        if vccontrs.cttype = '1' and vccontrs.ctregnom = 0 then do:
                            message 'Введите номер по журналу регистрации!' view-as alert-box.
                            update vccontrs.ctregnom with frame vccontrs .
                        end.
                        if vccontrs.ctregnom = 0 then undo, retry.
                    end.
                    /*---------------------------------------------------------------------------*/
                    if s-newrec then do:
                        case vccontrs.cttype:
                            when '2' then do:
                                if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) < 10000 then do:
                                    message 'Такой контракт регистрации в модуле не подлежит !!!' view-as alert-box buttons ok.
                                    gotnext:
                                    repeat:
                                        update vccontrs.ctsum with frame vccontrs.
                                        if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) >= 10000 then leave gotnext.
                                    end.
                                end.
                            end.
                            when '11' then do:
                                if vccontrs.expimp = 'I' then do:
                                    if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and inte(vccontrs.ctterm) > 18000 then do:
                                        message 'Контракт подлежит получению РС в НБРК! ' skip 'Введите данные РС в опцию РС/СУ!' view-as alert-box buttons ok.
                                    end.
                                end.
                                else if vccontrs.expimp = 'E' then do:
                                    if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and inte(vccontrs.ctterm) > 18000 then do:
                                        message 'Контракт подлежит получению РС в НБРК! ' skip
                                        'Введите данные РС в опцию РС/СУ!' view-as alert-box buttons ok.
                                    end.
                                end.
                            end.
                            when '6' then do:
                                run RegNBRK.
                            end.
                        end case.
                    end.
                    s-change = true.
                    if s-change = true and (vccontrs.cttype = '1' or vccontrs.cttype = '9') and vccontrs.sts = 'A' then run checkps."
&postupdate =   "  "
}

procedure RegNBRK:
    if vccontrs.cttype = "6" then do:
        find cif where cif.cif = s-cif no-lock no-error.
        if vccontrs.expimp = "I" then do:
            if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and (check_term(vccontrs.ctterm) > 180 or v-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                if not avail vcrslc then do:
                    message "Контракт подлежит регистрации в НБРК!" skip
                    "Введите данные РС в опцию РС/СУ!" view-as alert-box buttons ok.
                end.
            end.
        end.
        else if vccontrs.expimp = "E" then do:
            if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and (check_term(vccontrs.ctterm) > 180 or v-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                if not avail vcrslc then do:
                    message "Контракт подлежит регистрации в НБРК!" skip
                    "Введите данные РС в опцию РС/СУ!" view-as alert-box buttons ok.
                end.
            end.
        end.
    end.
end procedure.

procedure checkps.
    if vccontrs.opertyp <> 3 then do:
        find vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then do:
            if vcps.ncrc <> vccontrs.ncrc then do:
                find current vcps exclusive-lock.
                do transaction on error undo, retry:
                    vcps.ncrc = vccontrs.ncrc.
                    vcps.cursdoc-con = 1.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.ctsum <> vcps.sum / vcps.cursdoc-con then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.sum = vccontrs.ctsum * vcps.cursdoc-con.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.lastdate <> vcps.lastdate then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.lastdate = vccontrs.lastdate.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.ctvalpl <> vcps.ctvalpl then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.ctvalpl = vccontrs.ctvalpl.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.ctterm <> vcps.ctterm then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.ctterm = vccontrs.ctterm.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.ctformrs <> vcps.ctformrs then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.ctformrs = vccontrs.ctformrs.
                    find current vcps no-lock.
                end.
            end.
            if vccontrs.info[1] <> vcps.ctvalogr then do:
                do transaction on error undo, retry:
                    find current vcps exclusive-lock.
                    vcps.ctvalogr = vccontrs.info[1].
                    find current vcps no-lock.
                end.
            end.
        end.
    end.
end procedure.

procedure defupd.
  vccontrs.aaa = v-vcaaa.
end.

procedure defpartner.
    find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
    if avail vcpartners then v-partnername = trim(trim(vcpartners.name) + ' ' + trim(vcpartners.formasob)).
    else v-partnername = ''.
end procedure.

procedure defncrc.
    find ncrc where ncrc.crc = vccontrs.ncrc no-lock no-error.
    if avail ncrc then v-crcname = ncrc.code.
end procedure.

procedure defcttype.
    def var sp as deci.
    def var v-type as char.
    def var v-ans as logical.

    if (vccontrs.cttype = "2" or vccontrs.cttype = "1") then do:
        find vcparams where vcparams.parcode = "minpassp" no-lock no-error.
        if avail vcparams then sp = vcparams.valdeci. else sp = 5000.
        if vccontrs.ctsum / vccontrs.cursdoc-usd > sp then v-type = "1".
        else v-type = "2".
        if vccontrs.cttype <> v-type then do:
            v-ans = no.
            message skip
            " Тип контракта не сответствует минимальной сумме УНК !" skip
            " Изменить тип контракта ?" skip(1) view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-ans.
            if v-ans then vccontrs.cttype = v-type.
            else do:
                if s-newrec then do:
                    gotnext1:
                    repeat:
                        update vccontrs.ctsum with frame vccontrs.
                        if vccontrs.cttype = "1" then do:
                            if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > sp then leave gotnext1.
                        end.
                        else leave gotnext1.
                    end.
                end.
            end.
        end.
    end.
end.

procedure check-dolg.
    def var vp-sum as deci.
    def var vp-dt as date.
    def var vp-i as integer.
    def var vp-l as logical.

    s-avail03 = true.
    vp-days-ch = vccontrs.ctterm.
    vp-days = (integer(substring(vp-days-ch,5,2)) * 360) + integer(substring(vp-days-ch,1,3)).

    if vccontrs.cttype = "3" then do:
        /* контракты по услугам - сверка суммы актов, 120 дней */
        if  v-sumakt > v-sumplat then do:
            /* есть акты, не покрытые извещениями */
            if v-sumplat = 0 then do:
                /* нет извещений - берем просто первый акт */
                find first vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "17"
                use-index main no-lock no-error.
                /*vp-dt = vcdocs.dndate.*/
                if avail vcdocs then vp-dt = vcdocs.dndate.
                else vp-dt = g-today.
            end.
            else do:
                /* идем по актам, пока их сумма меньше суммы платежей */
                vp-sum = 0.
                for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "17"
                no-lock use-index main.
                    vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
                    if vp-sum > v-sumplat then do:
                        vp-dt = vcdocs.dndate.
                        leave.
                    end.
                end.
            end.
            if g-today > vp-dt + vp-days then do:
                message skip
                "Есть акты, не покрытые поступлениями валюты," skip
                " прошло больше " + string(vp-days) + " дней !" skip(1)
                view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
            end.
            else do:
                if g-today >= vp-dt + vp-days - vp-daysost then do:
                    message skip
                    "Есть акты, не покрытые поступлениями валюты !" skip(1)
                    string(vp-days) + " дней наступит через " + string(vp-dt + vp-days - g-today) " дней, " +
                    string(vp-dt + vp-days, "99/99/9999") + "." skip(1)
                    view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
                end.
            end.
        end.
        if v-sumakt < v-sumplat then do:
            /* есть платежи, не покрытые актами */
            if v-sumakt = 0 then do:
                find first vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 use-index main no-lock no-error.
                if avail vcdocs then vp-dt = vcdocs.dndate.
                else vp-dt = g-today.
            end.
            else do:
                /* идем по платежам минус возвраты, пока их сумма меньше суммы актов */
                for each vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 no-lock use-index main.
                    if vcdocs.payret then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                    else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
                    if vp-sum > v-sumakt then do:
                        vp-dt = vcdocs.dndate.
                        leave.
                    end.
                end.
            end.
            if g-today > vp-dt + vp-days then do:
                message skip "Есть платежи, не покрытые актами," skip
                "прошло больше " + string(vp-days) + " дней !" skip(1)
                "Нельзя создавать ПОРУЧЕНИЕ НА ПЕРЕВОД !" skip(1)
                view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
            end.
            else do:
                if g-today >= vp-dt + vp-days - vp-daysost then do:
                    message skip
                    "Есть платежи, не покрытые актами !" skip(1)
                    string(vp-days) + " дней наступит через " +
                    string(vp-dt + vp-days - g-today) " дней, " +
                    string(vp-dt + vp-days, "99/99/9999") + "." skip(1)
                    view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
                end.
            end.
        end.
    end.
    /*займы*/
    if vccontrs.cttype = "6"  then do:
        if  v-sumexc_6 < v-sumplat then do:
            /* платежи превышают сумму поступления/отправки займа */
            if v-sumplat = 0 then do:
                /* нет поступлений/отправки займа - берем просто первый платеж */
                find first vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 and (if vccontrs.expimp = 'i' then vcdocs.dntype = '03' else vcdocs.dntype = '02')
                and vcdocs.info[2] = '1' use-index main no-lock no-error.
                if avail vcdocs then vp-dt = vcdocs.dndate.
                else vp-dt = g-today.
            end.
            else do:
                /* идем по платежам, пока их сумма меньше суммы поступления/отправки*/
                vp-sum = 0.
                for each vcdocs where vcdocs.contract = s-contract and lookup(vcdocs.dntype, v-docsplat) > 0 and (if vccontrs.expimp = 'i' then vcdocs.dntype = '03' else vcdocs.dntype = '02')
                and vcdocs.info[2] = '1' use-index main no-lock.
                    if vcdocs.payret  then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                    else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
                    vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
                    if vp-sum > v-sumplat then do:
                        vp-dt = vcdocs.dndate.
                        leave.
                    end.
                end.
            end.
            if g-today > vp-dt + vp-days then do:
                message skip
                "Есть займы, не покрытые платежами," skip
                "прошло больше " + string(vp-days) + " дней !" skip(1)
                "Нельзя создавать ПОРУЧЕНИЕ НА ПЕРЕВОД !" skip(1)
                view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
            end.
            else do:
                if g-today >= vp-dt + vp-days - vp-daysost then do:
                    message skip
                    "Есть займы, не покрытые платежами !" skip(1)
                    string(vp-days) + " дней наступит через " +
                    string(vp-dt + vp-days - g-today) " дней, " +
                    string(vp-dt + vp-days, "99/99/9999") + "." skip(1)
                    view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
                end.
            end.
        end.
    end.
    /* контракты по товарам */
    if (vccontrs.cttype = '2' or vccontrs.cttype = '1') then do:
        if v-sumgtd /*- v-sumakt*/ > v-sumplat then do:
            /* есть ГТД, не покрытые извещениями */
            if v-sumplat = 0 then do:
                /* нет извещений - берем просто первую ГТД */
                find first vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "14" use-index main no-lock no-error.
                if avail vcdocs then vp-dt = vcdocs.dndate.
                else vp-dt = g-today.
            end.
            else do:
                /* идем по ГТД, пока их сумма меньше суммы платежей */
                vp-sum = 0.
                for each vcdocs where vcdocs.contract = s-contract and vcdocs.dntype = "14" no-lock use-index main.
                    if vcdocs.payret then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                    else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.
                    if vp-sum /*- v-sumakt*/ > v-sumplat then do:
                        vp-dt = vcdocs.dndate.
                        leave.
                    end.
                end.
            end.
            if g-today > vp-dt + vp-days then do:
                message skip "Есть ГТД, не покрытые поступлениями валюты," skip
                "сумма ГТД превышает сумму платежей на " + string((v-sumgtd /*- v-sumakt*/ - v-sumplat) / vccontrs.cursdoc-usd, ">>>,>>>,>>>,>>9.99") +
                " USD," skip " прошло больше " + string(vp-days) + " дней !" skip(1)
                "Нельзя создавать извещение о поступлении валюты" skip(1) view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
            end.
            else do:
                if g-today >= vp-dt + vp-days - vp-daysost then do:
                    message skip "Есть ГТД, не покрытые поступлениями валюты!" skip "Сумма ГТД превышает сумму платежей на " +
                    string((v-sumgtd /*- v-sumakt*/ - v-sumplat) / vccontrs.cursdoc-usd, ">>>,>>>,>>>,>>9.99") + " USD," skip (1)
                    string(vp-days) + " дней наступит через " + string(vp-dt + vp-days - g-today) " дней, " + string(vp-dt + vp-days, "99/99/9999") + "." skip(1)
                    view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
                end.
            end.
        end.
        if v-sumgtd /*+ v-sumakt*/ < v-sumplat then do:
            /* есть платежи, не покрытые ГТД */
            if v-sumgtd = 0 then do:
                /* нет ГТД - берем просто первый платеж */
                find first vcdocs where vcdocs.contract = s-contract and
                lookup(vcdocs.dntype, v-docsplat) > 0 use-index main no-lock no-error.
                /*vp-dt = vcdocs.dndate.*/
                if avail vcdocs then vp-dt = vcdocs.dndate.
                else vp-dt = g-today.
            end.
            else do:
                /* идем по платежам минус возвраты, пока их сумма меньше суммы ГТД */
                for each vcdocs where vcdocs.contract = s-contract and
                lookup(vcdocs.dntype, v-docsplat) > 0 no-lock use-index main.
                    if vcdocs.payret then vp-sum = vp-sum - vcdocs.sum / vcdocs.cursdoc-con.
                    else vp-sum = vp-sum + vcdocs.sum / vcdocs.cursdoc-con.

                    if vp-sum > v-sumgtd /*+ v-sumakt*/ then do:
                        find first b-vcdocs where b-vcdocs.contract = s-contract and lookup(b-vcdocs.dntype, v-docsplat) > 0 and b-vcdocs.payret = yes and b-vcdocs.dndate > vcdocs.dndate no-lock use-index main no-error.
                        if avail b-vcdocs then do:
                            if (vp-sum - b-vcdocs.sum / b-vcdocs.cursdoc-con) > v-sumgtd + v-sumakt then do:
                                vp-dt = vcdocs.dndate.
                                leave.
                            end.
                        end.
                        else do:
                            vp-dt = vcdocs.dndate.
                            leave.
                        end.
                    end.
                end.
            end.
            if g-today > vp-dt + vp-days then do:
                message skip "Есть платежи, не покрытые ГТД," skip "прошло больше " + string(vp-days) + " дней !" skip(1) "Нельзя создавать ПОРУЧЕНИЕ НА ПЕРЕВОД !" skip(1)
                view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
            end.
            else do:
                if g-today >= vp-dt + vp-days - vp-daysost then do:
                    message skip "Есть платежи, не покрытые ГТД !" skip(1) string(vp-days) + " дней наступит через " + string(vp-dt + vp-days - g-today) " дней, " +
                    string(vp-dt + vp-days, "99/99/9999") + "." skip(1) view-as alert-box error buttons ok title " ВНИМАНИЕ ! ".
                end.
            end.
        end.
    end.
end.

procedure predispl.
    run defpartner.
    run defncrc.
    run vcctsumm.
    if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
    run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
    v-vcaaa = vccontrs.aaa.

    v-bb = substr(string(vccontrs.bankb), 1, 35).
    v-bb1 = substr(string(vccontrs.bankb), 36, 35).
    v-bb2 = substr(string(vccontrs.bankb), 71, 35).

    v-bc = substr(string(vccontrs.bankc), 1, 35).
    v-bc1 = substr(string(vccontrs.bankc), 36, 35).
    v-bc2 = substr(string(vccontrs.bankc), 72, 35).
end.

procedure CorrAdd:
    def input parameter nm as char.
    def input parameter cr as char.
    def input parameter ds as char.

    create vccorrecthis.
    vccorrecthis.num = next-value(correct).
    vccorrecthis.contract = s-contract.
    vccorrecthis.correctdt = g-today.
    vccorrecthis.who = g-ofc.
    vccorrecthis.bank = v-ourbnk.
    vccorrecthis.sub = nm.
    vccorrecthis.corrfield = cr.
    vccorrecthis.des = ds.
    release vccorrecthis.

    vccontrs.dtcorrect = g-today.
    displ vccontrs.dtcorrect with frame vccontrs.
end procedure.

procedure SelField:
    def var v-oldval as char.
    def var s as inte.
    def var s2 as inte.
    def var p as inte init 0.
    def var str as char init "".
    def var value0 as char init "".
    def var change as char init "".
    def var ss as inte init 1.
    def var pp as inte init 0.
    def var str4 as char init "".
    def var change2 as char init "".

    if lookup('1',v-sel) > 0  then do:
        v-oldval = vccontrs.expimp.
        update vccontrs.expimp with frame vccontrs.
        if vccontrs.expimp entered then do:
            if v-oldval <> vccontrs.expimp then run CorrAdd("EISIGN",DelQues(v-oldval) + "|" + DelQues(vccontrs.expimp),"Признак Экспорт/Импорт").
        end.
    end.
    if lookup('2',v-sel) > 0  then do:
        v-oldval = vccontrs.ctnum.
        update vccontrs.ctnum  with frame vccontrs.
        if vccontrs.ctnum entered then do:
            if v-oldval <> vccontrs.ctnum then run CorrAdd("CONTRACT",DelQues(v-oldval) + "|" + DelQues(vccontrs.ctnum),"Номер контракта").
        end.
    end.
    if lookup('3',v-sel) > 0  then do:
        v-oldval = string(vccontrs.ctdate,"99/99/9999").
        update vccontrs.ctdate with frame vccontrs.
        if vccontrs.ctdate entered then do:
            if v-oldval <> string(vccontrs.ctdate,"99/99/9999") then run CorrAdd("CDATE",DelQues(v-oldval) + "|" + DelQues(string(vccontrs.ctdate,"99/99/9999")),"Дата контракта").
        end.
    end.
    if lookup('4',v-sel) > 0  then do:
        v-oldval = string(vccontrs.ctsum,"-zzzzzzzzzzzzzzzzzz9.99").
        update vccontrs.ctsum with frame vccontrs.
        if vccontrs.ctsum entered then do:
            if v-oldval <> string(vccontrs.ctsum,"-zzzzzzzzzzzzzzzzzz9.99") then do:
                run defcttype.
                displ vccontrs.cttype vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd with frame vccontrs.
                run CorrAdd("CSUMM",DelQues(v-oldval) + "|" + DelQues(string(vccontrs.ctsum,"-zzzzzzzzzzzzzzzzzz9.99")),"Сумма контракта").
            end.
        end.
    end.
    if lookup('5',v-sel) > 0 then do:
        find first vcpartners where vcpartners.partner = trim(vccontrs.partner) no-lock no-error.
        if avail vcpartners then do:
            pause 0.
            v-ordben = trim(vcpartners.name).
            displ v-ordben with frame country.
            v-oldval = v-ordben.
            update v-ordben with frame country.
            hide frame country.
            pause 0.
            if v-ordben entered then do:
                if v-oldval <> v-ordben then do:
                    find current vcpartners exclusive-lock no-error.
                    vcpartners.name = trim(v-ordben).
                    find current vcpartners no-lock no-error.
                    run CorrAdd("NRNAME",DelQues(v-oldval) + "|" + DelQues(trim(v-ordben)),"Наименование нерезидента").
                end.
            end.
        end.
    end.
    if lookup('6',v-sel) > 0 then do:
        find first vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
        if avail vcpartners then do:
            pause 0.
            v-countryplat = vcpartners.country.
            displ v-countryplat with frame country.
            v-oldval = v-countryplat.
            update v-countryplat with frame country.
            hide frame country.
            pause 0.
            if v-countryplat entered then do:
                if v-oldval <> v-countryplat then do:
                    find current vcpartners exclusive-lock no-error.
                    vcpartners.country = trim(v-countryplat).
                    find current vcpartners no-lock no-error.
                    run CorrAdd("NRCOUNTRY",DelQues(v-oldval) + "|" + DelQues(v-countryplat),"Страна нерезидента").
                end.
            end.
        end.
    end.
    if lookup('7',v-sel) > 0  then do:
        v-oldval = vccontrs.ctterm.
        update vccontrs.ctterm with frame vccontrs.
        if vccontrs.ctterm entered then do:
            if v-oldval <> vccontrs.ctterm then run CorrAdd("TERM",DelQues(v-oldval) + "|" + vccontrs.ctterm,"Сроки репатриации").
        end.
    end.
    if lookup('8',v-sel) > 0  then do:
        v-oldval = string(vccontrs.ncrc).
        update vccontrs.ncrc with frame vccontrs.
        if vccontrs.ncrc entered then do:
            if v-oldval <> string(vccontrs.ncrc) then do:
                run defncrc.
                run crosscurs(vccontrs.ncrc, 2, vccontrs.ctdate, output vccontrs.cursdoc-usd).
                run defcttype.
                displ vccontrs.cttype v-crcname vccontrs.cursdoc-usd vccontrs.ctsum / vccontrs.cursdoc-usd @ v-ctsumusd with frame vccontrs.
                run CorrAdd("CCURR",DelQues(v-oldval) + "|" + DelQues(string(vccontrs.ncrc)),"Валюта контракта").
            end.
        end.
    end.
    if lookup('9',v-sel) > 0  then do:
        v-oldval = string(vccontrs.lastdate,"99/99/9999").
        update vccontrs.lastdate with frame vccontrs.
        if vccontrs.lastdate entered then do:
            if v-oldval <> string(vccontrs.lastdate,"99/99/9999") then run CorrAdd("CLASTDATE",DelQues(v-oldval) + "|" + DelQues(string(vccontrs.lastdate,"99/99/9999")),"Последняя дата").
        end.
    end.
end procedure.

procedure checkcontract.
    {vccheckcont.i}
end.