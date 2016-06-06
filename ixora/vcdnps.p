/* vcdnps.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Редактирование паспортов сделок/доплистов
 * RUN

 * CALLER
        vccontrs.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        18.10.2002
 * BASES
        BANK COMM
 * CHANGES
        19.08.2003 nadejda  - перенесла сюда из триггера проверку на изменение валюты/суммы контракта, а то триггеры зацикливались
        17.02.2004 tsoy     - добавлен ввод vcps.info[1] vcps.info[2]
        19.02.2004 tsoy     - добавлен ввод изменены Имена меток для vcps.info[1] vcps.info[2],
                              по умолчанию vcps.info[1] = Имени клиента
        23.02.2004 nadejda  - запрашивать подтверждение на смену типа контракта
        01.07.2004 saltanat - внесено разрешение заполнения П.С. для контрактов типа = 5.
        21.09.2004 saltanat - для добавления,редактирования и удаления вставила проверку на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        11.01.2005 saltanat - Предусмотрела исключение для редактирования и т.д.
        21.03.2008 galina   - автоматическая генерация номера паспорта сделки и доп.листа
        27.03.2008 galina   - удален вывод окна запроса ФИО получателя уведомления
        07.04.2008 galina   - добавлен вывод и обновление поля vcps.info[4] = "ОСНОВ.ОФОРМ";
                              присвоение значения по умолчанию полю vcps.info[4] = "ОСНОВ.ОФОРМ;
                              проверка соотвествия значения поля "ОСНОВ.ОФОРМ" справочнику;
        17.04.2008 galina   - добавлены поля СРОКИ, ВАЛЮТ.ОГОВОРКА, ФОРМЫ РАСЧЕТОВ, ВАЛЮТЫ ПЛАТЕЖА
                              удалено разграничение прав пользователя по ID, удалено разграничаничение прав для акцептующего
        28.04.2008 galina   - удалена проверка обязятельного наличия ПС для контрактов типа 5
        13.05.2008 galina   - добавлен вывод полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
        29.05.2008 galina   - для контрактов типа 9, редактировать поле Номер
        03.06.2008 galina   - формирование допсоглашения для всех контрактов, кроме типа 1 и 9
        06.06.2008 galina   - добавления поля остаток непереведенных средств
        27.04.2009 galina   - генерация номера паспорта сделки
        18.05.2009 galina   - перекомпиляция в связи с изменением vcdnps.f
        13.08.2009 galina   - перекомпиляция в связи с изменением vc-summf.i
        26.08.2009 galina   - в процедуру check_term не передаем дату
        07/12/2009 galina   - убрала генерацию номера при редактировании паспорта сделки
        08.06.10            - переход на iban
        7/10/2010 aigul     - полe "ОСОБЫЕ ОТМ" увеличение на 6 строк и каждую по 50 символов
        09/11/2010 galina   - перекомпиляция
        17/11/2010 aigul    - vccontrs.ctdate поменяла на vccontrs.rdt (дата регистрации)
        25/11/2010 galina   - поправила редактирование поля "ОСОБЫЕ ОТМ"
        06.12.2010 aigul    - Поле "дата" подтягивает дату регистрации и становится нередактируемым
        28.12.2010 aigul    - вывод суммы Залога
        30.09.2011 damir    - если форма расчетов '22' просит ввести ОКПО пред.банка.
        05.10.2011 damir    - не производила синхронизацию  ПС с контрактом.
        26.10.2011 aigul    - recompile
        15.05.2012 aigul    - редактирование даты для типов ПС 04 контрактов - '2,3,6,11'
        29.06.2012 damir    - внедрено Т.З. № 1355, изменения в vcdnps.f.
        10.07.2012 damir    - перекомпиляция,корректировка.
        20.07.2012 damir    - отображение кода комиссии,транзакции для Доп.Согл (Тип документа 04).
        02.10.2012 damir    - корректировка в Т.З. № 1355. добавлено "vcps.dnnum like '%N%'". Не выявлено при тестировании.
        03.05.2013 damir - Внедрено Т.З. № 1107.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308..

*/
{vc.i}
{mainhead.i VCCONTRS}
{comm-txb.i}
{funcvc.i}

def new shared var v-chk        as logi initial no.
def shared var s-contract       like vccontrs.contract.
def new shared var s-dnvid      as char init "s".
def new shared var s-vcdoctypes as char.
def shared var s-change         as logi.
def new shared var s-check      as char.

def var v-cifname   as char.
def var v-contrnum  as char.
def var v-cursold   as deci.
def var v-comiss    as char init "com-01".
def var v-sp        as decimal.
def var v-ch        as logical.
def var v-bank      as inte.
def var v-exim      as char format '9'.
def var v-psnum     as integer init 1.
def var v-ps1       as char.
def var v-dnnum     as char.
def var v-note      as char format "x(50)".
def var v-note1     as char format "x(50)".
def var v-note2     as char format "x(50)".
def var v-note3     as char format "x(50)".
def var v-note4     as char format "x(50)".
def var v-note5     as char format "x(50)".
def var v-chang     as logi format "да/нет".
def var vp-num      as inte.
def var k           as inte.
def var v-reg as logi.

def temp-table t-vcps like vcps.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.
find vcparams where vcparams.parcode = "minpaspd" no-lock no-error.

v-cifname = "".
find cif where cif.cif = vccontrs.cif no-lock no-error.
if avail cif then
    v-cifname = trim(trim(substring(cif.name, 1, 40)) + " " + trim(cif.prefix)).

if vccontrs.expimp = "i" then v-contrnum = "импорт, ".
else v-contrnum = "экспорт, ".
v-contrnum = v-contrnum + trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99/99/9999").

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index(s-dnvid, codfr.name[5]) > 0 no-lock:
    s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

{vc-alldoc.i
    &option         = "vcps"
    &head           = "vcps"
    &headkey        = "ps "
    &frame          = "vcdnps"
    &no-add         = " if (vccontrs.sts begins 'c') /*or chkrights('vcpsac')*/ then do: run noupd. next outer. end. "
    &no-update      = " if (vccontrs.sts begins 'c') /*or (frame-value <> 'Акцепт' and chkrights('vcpsac'))*/ then do: run noupd. next outer. end. "
    &no-del         = " if (vccontrs.sts begins 'c') /*or chkrights('vcpsac')*/ then do: run noupd. next outer. end. "
    &predisplay     = " if avail vcps then do:
                            v-note = substr(string(vcps.dnnote[5]), 1, 50).
                            v-note1 = substr(string(vcps.dnnote[5]), 51, 50).
                            v-note2 = substr(string(vcps.dnnote[5]), 101, 50).
                            v-note3 = substr(string(vcps.dnnote[5]), 151, 50).
                            v-note4 = substr(string(vcps.dnnote[5]), 201, 50).
                            v-note5 = substr(string(vcps.dnnote[5]), 251, 50).

                            /*28.05.2008*/
                            if vcps.dntype = '01' and vccontr.cttype = '1' then v-dnnum = vcps.dnnum + string(vcps.num).
                            else v-dnnum = vcps.dnnum.
                            run defvars.
                        end.
                        else do:
                            v-nbcrckod = ''. v-dntypename = ''. v-rslctype = ''. v-dnnum = ''.
                        end. "
    &display        = " vcps.dntype v-dntypename v-dnnum /*vcps.info[4]*/ vcps.dndate vcps.lastdate vcps.ncrc v-nbcrckod
                        vcps.sum vcps.ctvalpl /*vcps.ctvalogr*/ vcps.cursdoc-con vcps.sum / vcps.cursdoc-con @ v-sumdoccon vcps.ctterm /*vcps.ctformrs*/
                        vcps.dnnote[1] vcps.dnnote[2] /*vcps.dnnote[3] vcps.dnnote[4] vcps.dnnote[5]*/ v-note v-note1 v-note2 v-note3 v-note4 v-note5
                        /*vcps.rslc when vcps.rslc > 0 vcps.okpoprev*/ v-rslctype v-rslcdate v-rslcnum
                        vcps.rdt vcps.rwho vcps.cdt vcps.cwho v-comcod v-comsum v-comcrc v-comjh v-comdate "
    &postdisplay    = " "
    &preupdate      = " run defvars. v-cursold = vcps.cursdoc-con. "
    &update         = " if s-newrec then do:
                            if vcps.dntype = '04' then do:
                                case vccontrs.cttype:
                                    when '6' then do:
                                        run RegNBRK(output v-reg).
                                        if v-reg then do:
                                            delete vcps.
                                            hide frame vcdnps.
                                            hide frame vsele.
                                            s-newrec = false.
                                            leave outer.
                                        end.
                                    end.
                                end case.
                            end.
                        end.

                        empty temp-table t-vcps.
                        BUFFER-COPY vcps to t-vcps.

                        if (vccontrs.cttype = '1' or vccontrs.cttype = '9') then update vcps.dntype with frame vcdnps. run deftype.
                        displ v-dntypename with frame vcdnps.

                        if vcps.dntype = '01' then do:
                            if vcps.dnnum = '' and vcps.num = 0 then do:
                                if vccontrs.expimp = 'i' then v-exim = '2'.
                                else v-exim = '1'.
                                v-bank = comm-cod().
                                find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
                                find sysc where sysc.sysc = 'CLECOD' no-lock no-error.
                                v-ps1 = v-exim + '/' + string(sysc.inval,'999') + '/' +  string(v-bank,'99') +  string(ofchis.dep,'99') + '/'.
                                find last b-vcps where b-vcps.dnnum = v-ps1 and b-vcps.dntype = '01' use-index dnnum no-lock no-error.
                                if avail b-vcps then v-psnum = b-vcps.num + 1.
                                v-dnnum = v-ps1 + string(v-psnum).
                                vcps.dnnum = v-ps1.
                                vcps.num = v-psnum.
                            end.
                            else v-dnnum = vcps.dnnum + string(vcps.num).
                            displ v-dnnum with frame vcdnps.
                        end.
                        if vcps.dntype = '04' and (vccontrs.cttype = '2' or vccontrs.cttype = '3' or vccontrs.cttype = '6' or vccontrs.cttype = '11')
                        then update vcps.dndate with frame vcdnps.

                        if vcps.dndate entered then do:
                            run crosscurs(vcps.ncrc, vccontrs.ncrc, vcps.dndate, output vcps.cursdoc-con).
                            displ vcps.cursdoc-con vcps.sum / vcps.cursdoc-con @ v-sumdoccon with frame vcdnps.
                        end.
                        if vcps.dntype = '04' then update vcps.lastdate with frame vcdnps.

                        if vcps.dntype <> '01' then do:
                            if vccontrs.cttype = '1' then do:
                                v-chang = false.
                                message '< Валюта > контракта может быть отредактирована только с помощью <F2>! Редактировать с помощью <F2> ?' view-as alert-box buttons yes-no update v-chang.
                                if v-chang then do:
                                    s-check = 'changeF2'.
                                    metka1:
                                    do while (keyfunction(lastkey) <> 'F2'):
                                        update vcps.ncrc with frame vcdnps.
                                        if v-sel1 <> '' and lookup('13',v-sel1) > 0 then do:
                                            update vcps.ncrc with frame vcdnps.
                                            if vcps.ncrc entered then do:
                                                run defcrcall.
                                                displ v-nbcrckod vcps.cursdoc-con vcps.sum / vcps.cursdoc-con @ v-sumdoccon with frame vcdnps.
                                            end.
                                            vcps.info2[1] = 'F2'.
                                            find t-vcps where t-vcps.ps = vcps.ps no-lock no-error.
                                            if avail t-vcps and t-vcps.ncrc <> vcps.ncrc then leave metka1.
                                            else do:
                                                message 'Вы не поменяли <Валюту>, повторите ! ' view-as alert-box.
                                                next metka1.
                                            end.
                                        end.
                                    end.
                                end.
                            end.
                            else do:
                                update vcps.ncrc with frame vcdnps.
                                if vcps.ncrc entered then do:
                                    run defcrcall.
                                    displ v-nbcrckod vcps.cursdoc-con vcps.sum / vcps.cursdoc-con @ v-sumdoccon with frame vcdnps.
                                end.
                            end.
                        end.

                        if vcps.dntype <> '01' then do:
                            if vccontrs.cttype = '1' then do:
                                v-chang = false.
                                message '< Сумма > контракта может быть отредактирована только с помощью <F2>! Редактировать с помощью <F2> ?' view-as alert-box buttons yes-no update v-chang.
                                if v-chang then do:
                                    s-check = 'changeF2'.
                                    metka2:
                                    do while (keyfunction(lastkey) <> 'F2'):
                                        update vcps.sum with frame vcdnps.
                                        if v-sel1 <> '' and lookup('8',v-sel1) > 0 then do:
                                            update vcps.sum with frame vcdnps.
                                            vcps.info2[1] = 'F2'.
                                            find t-vcps where t-vcps.ps = vcps.ps no-lock no-error.
                                            if avail t-vcps and t-vcps.sum <> vcps.sum then leave metka2.
                                            else do:
                                                message 'Вы не поменяли <Сумму>, повторите ! ' view-as alert-box.
                                                next metka2.
                                            end.
                                        end.
                                    end.
                                end.
                            end.
                            else update vcps.sum with frame vcdnps.
                        end.

                        if vcps.sum entered then displ vcps.sum / vcps.cursdoc-con @ v-sumdoccon with frame vcdnps.

                        update vcps.ctvalpl with frame vcdnps.
                        update vcps.cursdoc-con with frame vcdnps.
                        if vcps.cursdoc-con entered then displ vcps.sum / vcps.cursdoc-con @ v-sumdoccon with frame vcdnps.

                        if vcps.dntype <> '01' then do:
                            if vccontrs.cttype = '1' then do:
                                v-chang = false.
                                message '< Сроки > контракта может быть отредактирована только с помощью <F2>! Редактировать с помощью <F2> ?' view-as alert-box buttons yes-no update v-chang.
                                if v-chang then do:
                                    s-check = 'changeF2'.
                                    metka3:
                                    do while (keyfunction(lastkey) <> 'F2'):
                                        update vcps.ctterm with frame vcdnps.
                                        if v-sel1 <> '' and lookup('11',v-sel1) > 0 then do:
                                            update vcps.ctterm with frame vcdnps.
                                            vcps.info2[1] = 'F2'.
                                            find t-vcps where t-vcps.ps = vcps.ps no-lock no-error.
                                            if avail t-vcps and t-vcps.ctterm <> vcps.ctterm then leave metka3.
                                            else do:
                                                message 'Вы не поменяли <Сроки>, повторите ! ' view-as alert-box.
                                                next metka3.
                                            end.
                                        end.
                                    end.
                                end.
                            end.
                            else update vcps.ctterm with frame vcdnps.
                        end.
                        update vcps.dnnote[1] vcps.dnnote[2] v-note format 'x(50)' v-note1 v-note2 v-note3 v-note4
                        v-note5 with frame vcdnps.

                        vcps.dnnote[5] = v-note + v-note1 + v-note2 + v-note3 + v-note4 + v-note5.
                        vcps.info[1] = v-cifname.
                        "
    &postupdate     =   " if vcps.dntype <> '01' then do:
                            s-change = false. run checkcontr. run vcctsumm.
                            if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1' then
                            run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                            displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog
                            with frame vcctsumm. end.
                            if vcps.dntype = '01' then do: run checkcontr.
                        end. "
    &prefind        =   " "
    &postfind       =   " "
    &precreate      =   " "
    &postcreate     =   " run postcr. "
    &postcreatetwo  =   " run postcrtwo. "
    &predelete      =   " "
    &delete         =   " delete vcps. "
    &postdelete     =   " run vcctsumm.
                        if (vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1') then
                        run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                        displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog
                        with frame vcctsumm. "

}

procedure RegNBRK:
    def output parameter p-reg as logi.
    p-reg = false.
    if vccontrs.cttype = "6" then do:
        def var vv-term as inte.
        run check_term (vccontrs.contract, ?, ?, ?, ?, ?, output vv-term).
        find cif where cif.cif = vccontrs.cif no-lock no-error.
        if vccontrs.expimp = "I" then do:
            if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                if not avail vcrslc then do:
                    message "Контракт подлежит регистрации в НБРК!" skip
                    "Введите данные РС в опцию РС/СУ!" view-as alert-box buttons ok.
                    p-reg = true.
                end.
            end.
        end.
        else if vccontrs.expimp = "E" then do:
            if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
                find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                if not avail vcrslc then do:
                    message "Контракт подлежит регистрации в НБРК!" skip
                    "Введите данные РС в опцию РС/СУ!" view-as alert-box buttons ok.
                    p-reg = true.
                end.
            end.
        end.
    end.
end procedure.

procedure defv-rslc.
    find vcrslc where vcrslc.rslc = vcps.rslc no-lock no-error.
    if avail vcrslc then do:
        find codfr where codfr.codfr = 'vcdoc' and codfr.code = vcrslc.dntype no-lock no-error.
        v-rslctype = codfr.name[1].
        v-rslcdate = vcrslc.dndate. v-rslcnum = vcrslc.dnnum.
    end.
    else do:
        v-rslctype = ''. v-rslcdate = ?. v-rslcnum = ''.
    end.
end.

procedure defvars.
    find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
    if avail ncrc then v-nbcrckod = ncrc.code.
    else v-nbcrckod = ''.
    run deftype.
    run defv-rslc.

    if vcps.dntype <> '' then do:
        v-comiss = "com-" + vcps.dntype.
        find vcctcoms where vcctcoms.contract = s-contract and vcctcoms.codcomiss = v-comiss and vcctcoms.info[1] matches "*" + vcps.dnnum + "*" no-lock no-error.
        if avail vcctcoms then do:
            find first jl where jl.jh = vcctcoms.jh no-lock no-error.
            if not avail jl then do:
                find current vcctcoms exclusive-lock.
                vcctcoms.jh = 0.
                find current vcctcoms no-lock.
            end.
        end.
        find vcctcoms where vcctcoms.contract = s-contract and vcctcoms.codcomiss = v-comiss and vcctcoms.info[1] matches "*" + vcps.dnnum + "*" no-lock no-error.
        find vcparams where vcparams.parcode = v-comiss no-lock no-error.
        v-comcod = entry(1, vcparams.valchar).
        if avail vcctcoms then do:
            v-comsum = vcctcoms.sum.
            v-comdate = vcctcoms.datecomiss.
            find crc where crc.crc = vcctcoms.crc no-lock no-error.
            v-comcrc = crc.code.
            if vcctcoms.jh > 0 then v-comjh = string(vcctcoms.jh).
            else v-comjh = "долг".
        end.
        else do:
            v-comsum = 0.
            v-comdate = ?.
            v-comcrc = ''.
            v-comjh = ''.
        end.
    end.
end.

procedure deftype.
  find codfr where codfr.codfr = "vcdoc" and codfr.code = vcps.dntype no-lock no-error.
  if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = ''.
end.

procedure postcr.
    if (vccontrs.cttype <> '1' and vccontrs.cttype <> '9') then vcps.dntype = '04'.

    select count(*) into vp-num from vcps where vcps.contract = s-contract and (vcps.dntype = '19' or vcps.dntype = '04') and vcps.dnnum like '%N%'.
    vcps.contract = s-contract.
    vcps.ncrc = vccontrs.ncrc.
    vcps.sum = vccontrs.ctsum.
    vcps.dndate = vccontrs.rdt.
    vcps.lastdate = vccontrs.lastdate.
    vcps.ctterm = vccontrs.ctterm.
    vcps.ctvalpl = vccontrs.ctvalpl.
    vcps.dntype = '04'.
    vcps.info[4] = '2'.
    vcps.dndate = g-today.

    run vcctsumm.
    if (vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1') then
    run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
end.

procedure postcrtwo:
    find first b-vcps where b-vcps.contract = s-contract and b-vcps.dntype = "01" and b-vcps.ps <> vcps.ps no-lock no-error.
    if avail b-vcps then do:
        find first b2-vcps where b2-vcps.ps = s-ps exclusive-lock no-error.
        if avail b2-vcps then do:
            if b2-vcps.info2[1] = 'F2' then b2-vcps.dnnum = b-vcps.dnnum + string(b-vcps.num) + ', N ' + string(vp-num + 1).
            else vcps.dnnum = b-vcps.dnnum + string(b-vcps.num).
        end.
    end.
end procedure.

procedure defncrc.
    find ncrc where ncrc.crc = vcps.ncrc no-lock no-error.
    if avail ncrc then v-nbcrckod = ncrc.code.
    else v-nbcrckod = ''.
end.

procedure defcrcall.
    def var vp-crc  like ncrc.crc.
    def var v-msg   as char.
    def var v-s     as char.
    def var vp-curs as deci.

    run defncrc.
    run crosscurs(vcps.ncrc, vccontrs.ncrc, vcps.dndate, output vcps.cursdoc-con).
end.

procedure noupd.
    bell.
    message skip " Данное действие невозможно! Контракт закрыт либо у Вас нет прав на выполнение данной процедуры. " skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.


procedure checkcontr.
    def var v-cttype as char.

    if vcps.ncrc <> vccontrs.ncrc then do:
        do transaction on error undo, retry:
            find current vcps exclusive-lock.
            if vcps.info[3] <> '' then vcps.info[3] = vcps.info[3] + ','.
            vcps.info[3] = vcps.info[3] + '1'.
            vcps.cursdoc-con = 1.
            find current vcps no-lock.
            find current vccontrs exclusive-lock.
            vccontrs.ncrc = vcps.ncrc.
            run crosscurs(vccontrs.ncrc, 2, vccontrs.ctdate, output vccontrs.cursdoc-usd).
            find current vccontrs no-lock.
        end.
    end.
    if vccontrs.ctsum <> vcps.sum / vcps.cursdoc-con then do:
        do transaction on error undo, retry:
            find current vcps exclusive-lock.
            if vcps.info[3] <> '' then vcps.info[3] = vcps.info[3] + ','.
            vcps.info[3] = vcps.info[3] + '3'.
            find current vcps no-lock.
            find current vccontrs exclusive-lock.
            vccontrs.ctsum = vcps.sum / vcps.cursdoc-con.

            if vccontrs.cttype = "2" or vccontrs.cttype = "1" then do:
                find vcparams where vcparams.parcode = "minpassp" no-lock no-error.
                if avail vcparams then v-sp = vcparams.valdeci. else v-sp = 5000.
                if vccontrs.ctsum / vccontrs.cursdoc-usd > v-sp then v-cttype = "1".
                else v-cttype = "2".
                if vccontrs.cttype <> v-cttype then do:
                    v-ch = no.
                    message skip " Тип контракта не сответствует минимальной сумме паспорта сделки !" skip
                    " Изменить тип контракта ?" skip(1) view-as alert-box error buttons yes-no title " ВНИМАНИЕ ! " update v-ch.
                    if v-ch then vccontrs.cttype = v-cttype.
                end.
            end.
            find current vccontrs no-lock.
        end.
    end.
    if vccontrs.lastdate <> vcps.lastdate then do:
        do transaction on error undo, retry:
            find current vcps exclusive-lock.
            if vcps.info[3] <> '' then vcps.info[3] = vcps.info[3] + ','.
            vcps.info[3] = vcps.info[3] + '2'.
            find current vcps no-lock.
            find current vccontrs exclusive-lock.
            vccontrs.lastdate = vcps.lastdate.
            find current vccontrs no-lock.
        end.
    end.
    if vccontrs.ctvalpl <> vcps.ctvalpl then do:
        do transaction on error undo, retry:
            find current vcps exclusive-lock.
            if vcps.info[3] <> '' then vcps.info[3] = vcps.info[3] + ','.
            vcps.info[3] = vcps.info[3] + '4'.
            find current vcps no-lock.
            find current vccontrs exclusive-lock.
            vccontrs.ctvalpl = vcps.ctvalpl.
            find current vccontrs no-lock.
        end.
    end.
    if vccontrs.ctterm <> vcps.ctterm then do:
        do transaction on error undo, retry:
            find current vcps exclusive-lock.
            if vcps.info[3] <> '' then vcps.info[3] = vcps.info[3] + ','.
            vcps.info[3] = vcps.info[3] + '5'.
            find current vcps no-lock.
            find current vccontrs exclusive-lock.
            vccontrs.ctterm = vcps.ctterm.
            find current vccontrs no-lock.
        end.
    end.
end procedure.
