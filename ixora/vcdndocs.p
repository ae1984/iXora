/* vcdndocs.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Редактирование документов контракта
 * RUN
        верхнее меню сведений о контракте
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-1
 * AUTHOR
        18.10.2002 nadejda
 * BASES
        BANK COMM
 * CHANGES
        22.08.2003 nadejda - добавлены поля сведений о партнере - только для платеж.документов по импорт.контрактам
        30.04.2004 nadejda - сведения о партнере допускаются и для экспортных контрактов
        01.07.2004 saltanat - для контрактов типа =5, обязательным является наличие паспорта сделки
        21.09.2004 saltanat - для добавления,редактирования и удаления вставила проверку на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        11.01.2005 saltanat - Предусмотрела исключение для редактирования и т.д.
        17.04.2008 galina - удалена проверка на доступ к пунктам редактирования, удаления и создания документов по ID пользователя
        17.04.2008 galina - для редактирования и удаления удалена проверка на то,что акцептующее лицо не может
                              выполнять эти процедуры.
        18.04.2008 galina - добавлено редактироване даты регистрации платежа
        25.04.2008 galina - удалена проверка наличия ПС для контрактов типа 5
        13.05.2008 galina - добавлен вывод полей "СУММА ЗАЙМ.%" и "СРОК ДВИЖ.КАП."
                            добавлено поле ОПЛАТА%
        27.05.2008 galina - если валюта плтежа, указаная в контракте не найдено, то присвоить пустое значение
        06.06.2008 galina - добавления поля остаток непереведенных средств
        18.08.2008 galina - перекомпеляция в связи с изменениями на форме vcdndocs.f
        10.11.2008 galina - перекомпеляция в связи с изменениями на форме vcdndocs.f
        25.11.2008 galina - перекомпеляция в связи с изменениями на форме vcdndocs.f
        09.04.2009 galina - перекомпеляция в связи с изменениями на форме vcdndocs.f
        18.05.2009 galina - не изменять признак возврата при редактировании платежа
        14.08.2009 galina - перекомпиляция в связи с изменением vc-summf.i
        26.08.2009 galina - в процедуру check_term не передаем дату
        21/06/2010 galina - новые типы документов зачет- (тип документа 23) и зачет+ (тип документа 24)
        25/11/2010 aigul - добавила корректировку поля Инопартнер для актов
        22.12.2010 aigul - Поле "дата" подтягивает дату регистрации
                           вывод суммы залога
        11.01.2011 aigul - если экспорт и тип 02 тогда возврат YES  и не редактируется,
                           если импорт и тип 03 тогда возврат YES  и не редактируется,
        03.08.2011 aigul - recompile
        30.09.2011 damir - добавлены
                           1) новые переменные v-numobyaz, v-trueupdate, v-docsmonth, v-docsyear, v-nextmonth, v-nextyear, v-date1, v-date2,
                           v-temp1, v-temp2, v-temp3, v-temp4, v-temp6, v-temp7, v-temp8, v-temp9, v-temp10, v-temp11, v-temp12.
                           temp-table t-vcdocs, t-vcpartners.
                           2) В procedure pro-upd были только update полей во фрейме vcdndocs, все остальное добавил.
        03.10.2011 damir - dobavil vcothdntype.i.
        04.10.2011 damir - перекомпиляция в связи с изменением vcothdntype.i...
        04.10.2011 damir - добавил vcdocscopy.p.
        30.11.2011 damir - Тип опер 2, только тип контракта "1".
        08.12.2011 aigul - recompile
        15.12.2011 aigul - recompile
        15.12.2011 damir - небольшие корректировки.
        12.01.2012 damir - небольшие корректировки..
        06.04.2012 damir - изменений не было, перекомпиляция.
        11.04.2012 damir - чтобы пропускало только через клавишу F2 при наборе ТИП ОПЕР.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        27.04.2012 aigul - проверка валюты в платДк с валютой платежа контракта
        15.05.2012 aigul - recompile vcdndocs.f проверка платежей, что они не превышают сумму контракта
        16.05.2012 aigul - recompile vcdndocs.f  проверка даты платежа с послдней датой РС/СУ
        13.06.2012 damir - перекомпиляция в связи с изменением vcdndocs.f.
        29.06.2012 damir - убрал зачет,уступка,пер.долга в form, изменения в vcdndocs.f.
        25.12.2012 damir - Внедрено Т.З. № 1306.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/
{vc.i}
{mainhead.i VCCONTRS}
{vcmainshared.i}
{comm-txb.i}
{funcvc.i}

def shared var s-vcdoctypes as char.
def shared var s-dnvid      as char.
def shared var s-contract   like vccontrs.contract.
def shared var v-prog       as char.

def var v-contrnum as char.
def var v-trueupdate as logi init no.
def var v-nextmonth as inte.
def var v-nextyear as inte.
def var v-chang      as logi format "да/нет" init no.

find vccontrs where vccontrs.contract = s-contract no-lock no-error.

if (vccontrs.cttype = "1") and not can-find(vcps where vcps.contract = s-contract and vcps.dntype = "01" no-lock) then do:
    bell.
    message skip " Контракт требует ввода паспорта сделки ! " skip(1) view-as alert-box buttons ok title " Предупреждение ".
    return.
end.

find cif where cif.cif = vccontrs.cif no-lock no-error.
if not avail cif then return.

if vccontrs.expimp = "i" then v-contrnum = "импорт, ".
else v-contrnum = "экспорт, ".
v-contrnum = v-contrnum + trim(vccontrs.ctnum) + " от " + string(vccontrs.ctdate, "99/99/9999").

def var v-ourbnk as char.
v-ourbnk = comm-txb().

if vccontrs.cttype = "6" and index('p', s-dnvid) > 0 then do:
    def var vv-term as inte.
    run check_term (s-contract, ?, ?, ?, ?, ?, output vv-term).
    if vccontrs.expimp = "I" then do:
        if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
            find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
            if not avail vcrslc then message "В контракте отсутствует РС!" skip
                                             "Нельзя проводить платеж без РС!" view-as alert-box buttons ok.
        end.
    end.
    else if vccontrs.expimp = "E" then do:
        if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,"999"),3,1) = "1" then do:
            find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = "21" no-lock no-error.
            if not avail vcrslc then message "В контракте отсутствует РС!" skip
                                             "Нельзя проводить платеж без РС!" view-as alert-box buttons ok.
        end.
    end.
end.

function DelQues returns char(input str as char).
    if str = ? then return "".
    else return str.
end function.

{vc-alldoc.i
    &option     = "vcdocs"
    &head       = "vcdocs"
    &headkey    = "docs"
    &frame      = "vcdndocs"
    &start      = " on help of vcdocs.knp in frame vcdndocs do: run uni_help1('spnpl', '*'). end. "
    &no-add     = " if (vccontrs.sts begins 'c') /*or (chkrights('vcdocsac'))*/ then do: run noupd. next outer. end. "
    &no-update  = " if (vccontrs.sts begins 'c') /*or (frame-value <> 'Акцепт' and chkrights('vcdocsac'))*/ then do: run noupd. next
                    outer. end. "
    &no-del     = " if (vccontrs.sts begins 'c') /*or chkrights('vcdocsac')*/ then do: run noupd. next outer. end. "
    &predisplay = " if avail vcdocs then do: run defcrckod. run deftypename. run defpartner. run defprocent. end.
                    else do: v-crckod = ''. v-dntypename = ''. v-partner = ''. end. "
    &display    = " vcdocs.dntype v-dntypename vcdocs.dnnum vcdocs.dndate vcdocs.sumpercent vcdocs.pcrc v-crckod vcdocs.sum
                    vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon vcdocs.payret when (index('p', s-dnvid) > 0 or
                    vcdocs.dntype = '17')  vcdocs.info[2] v-procent vcdocs.info[1] vcdocs.knp when index('g', s-dnvid) = 0
                    /*vcdocs.zachet vcdocs.ustupka vcdocs.perdolga*/ vcdocs.numobyaz vcdocs.opertype vcdocs.dtcorrect vcdocs.info[4]
                    when (index('p', s-dnvid) > 0 or index('o', s-dnvid) > 0) v-partner when (index('p', s-dnvid) > 0 or
                    index('o', s-dnvid) > 0) v-locatben when (index('p', s-dnvid) > 0 or index('o', s-dnvid) > 0) /*vcdocs.origin*/
                    vcdocs.kod14 when index('p', s-dnvid) > 0 vcdocs.rdt vcdocs.rwho vcdocs.cdt vcdocs.cwho"
    &preupdate  = " run defcrckod. run deftypename. run defpartner. run defprocent."
    &update     = " if s-newrec then do:
                        if vccontrs.cttype = '6' and index('p', s-dnvid) > 0 then do:
                            if vccontrs.expimp = 'I' then do:
                                if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 100000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,'999'),3,1) = '1' then do:
                                    find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                                    if not avail vcrslc then do:
                                        message 'В контракте отсутствует РС!' skip
                                                'Нельзя проводить платеж без РС!' view-as alert-box buttons ok.
                                        delete vcdocs.
                                        hide frame vcdndocs.
                                        hide frame vsele.
                                        s-newrec = false.
                                        leave outer.
                                    end.
                                end.
                            end.
                            else if vccontrs.expimp = 'E' then do:
                                if konv2usd(vccontrs.ctsum,vccontrs.ncrc,vccontrs.ctdate) > 500000 and (check_term(vccontrs.ctterm) > 180 or vv-term > 180) and substr(string(cif.geo,'999'),3,1) = '1' then do:
                                    find first vcrslc where vcrslc.contract = vccontrs.contract and vcrslc.dntype = '21' no-lock no-error.
                                    if not avail vcrslc then do:
                                        message 'В контракте отсутствует РС!' skip
                                                'Нельзя проводить платеж без РС!' view-as alert-box buttons ok.
                                        delete vcdocs.
                                        hide frame vcdndocs.
                                        hide frame vsele.
                                        s-newrec = false.
                                        leave outer.
                                    end.
                                end.
                            end.
                        end.
                    end.
                    /*----------------------------------------------------------------------------------------------*/
                    v-trueupdate = false. v-nextyear = 0. v-nextmonth = 0. v-sel = ''.
                    if vccontrs.cttype = '1' then do:
                        if not s-newrec then do:
                            if month(vcdocs.rdt) = 12 then do: v-nextmonth = 1. v-nextyear = year(vcdocs.rdt) + 1. end.
                            else do: v-nextmonth = month(vcdocs.rdt) + 1.  v-nextyear = year(vcdocs.rdt). end.
                            if g-today > date(v-nextmonth,10,v-nextyear) then v-trueupdate = true.
                            if g-today >= date(month(vcdocs.rdt),day(vcdocs.rdt),year(vcdocs.rdt)) and g-today <= date(v-nextmonth,10,v-nextyear) then v-trueupdate = false.

                            if v-trueupdate then do:
                                update vcdocs.cursdoc-con with frame vcdndocs.
                                if vcdocs.cursdoc-con entered then displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                                if vcdocs.opertype = '1' then do:
                                    message 'Документ не редактирован!' skip 'Редактировать с помощью F2 (ТИП ОПЕР)?' view-as alert-box information buttons yes-no update v-chang.
                                    if v-chang then do:
                                        m1: do while (keyfunction(lastkey) <> 'F2'):
                                            update vcdocs.opertype with frame vcdndocs.
                                            if v-sel <> '' then leave m1.
                                        end.
                                    end.
                                    else next.
                                end.
                                else if vcdocs.opertype = '2' then do:
                                    message 'Документ редактирован!' skip 'Редактировать с помощью F2 (ТИП ОПЕР)?' view-as alert-box information buttons yes-no update v-chang.
                                    if v-chang then do:
                                        m2: do while (keyfunction(lastkey) <> 'F2'):
                                            update vcdocs.opertype with frame vcdndocs.
                                            if v-sel <> '' then leave m2.
                                        end.
                                    end.
                                    else next.
                                end.
                            end.
                        end.
                    end.
                    /*----------------------------------------------------------------------------------------------*/
                    if (vccontrs.cttype <> '1') or (vccontrs.cttype = '1' and s-newrec) or (vccontrs.cttype = '1' and not s-newrec and not v-trueupdate) then do:
                        update vcdocs.dntype with frame vcdndocs.
                        run deftypename.
                        update vcdocs.dnnum with frame vcdndocs.
                        update vcdocs.dndate with frame vcdndocs.
                        if vcdocs.dndate entered then do:
                            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                            displ vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                        end.
                        update vcdocs.sumpercent when (index('p', s-dnvid) > 0 or vcdocs.dntype = '17') with frame vcdndocs.
                        if vccontrs.cttype <> '6' then do:
                            if vccontrs.expimp = 'i' and vcdocs.dntype = '02' then vcdocs.payret = yes.
                            if vccontrs.expimp = 'e' and vcdocs.dntype = '03' then vcdocs.payret = yes.
                        end.
                        else do:
                            update vcdocs.payret with frame vcdndocs.
                            display vcdocs.payret with frame vcdndocs.
                            update vcdocs.info[2] with frame vcdndocs.
                            if vcdocs.info[2] entered then run defprocent.
                            display v-procent with frame vcdndocs.
                        end.
                        update vcdocs.pcrc with frame vcdndocs.
                        if vcdocs.pcrc entered then do:
                            run defcrckod.
                            run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                            displ v-crckod vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                        end.
                        update vcdocs.sum with frame vcdndocs.
                        if vcdocs.sum entered then displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                        update vcdocs.cursdoc-con with frame vcdndocs.
                        if vcdocs.cursdoc-con entered then displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                        if index('p', s-dnvid) > 0 or (vccontrs.cttype = '1' and index('o', s-dnvid) > 0) then do:
                            update vcdocs.info[4] with frame vcdndocs.
                            run defpartner. displ v-partner v-locatben with frame vcdndocs.
                        end.
                        update vcdocs.knp with frame vcdndocs.
                        update vcdocs.kod14 with frame vcdndocs.
                        if index('p', s-dnvid) > 0 then do:
                            if vcdocs.kod14 = '22' then update vcdocs.info[1] = 'Уступка права требования к нерезиденту' with frame vcdndocs.
                            else if vcdocs.kod14 = '23' then do:
                                find first vcps where vcps.contract = s-contract and vcps.dntype = '01' no-lock no-error.
                                if avail vcps then update vcdocs.info[1] = 'Перевод долга по УНК ' + vcps.dnnum + string(vcps.num) + ' другому резиденту' with frame vcdndocs.
                            end.
                            else if vcdocs.kod14 = '21' then message 'Укажите условие для зачета!' view-as alert-box.
                        end.
                        update vcdocs.info[1] with frame vcdndocs.

                        run NextNum.
                    end.
                    run SelField.
                  "
    &postupdate = " run vcctsumm. if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1'
                    then run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                    displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with
                    frame vcctsumm. if vcdocs.info[1] entered then run defpaid.
                    for each vccorrecthis no-lock: end.
                    "
    &postcreate = " vcdocs.contract = s-contract. vcdocs.dndate = g-today.
                    if index('p', s-dnvid) > 0 then do:
                        vcdocs.info[4] = vccontrs.partner.
                        if vccontrs.cttype = '6' then vcdocs.info[2] = '1'.
                        if vccontrs.expimp = 'i' then vcdocs.dntype = '03'.
                        if vccontrs.expimp = 'e' then vcdocs.dntype = '02'.
                        if vccontrs.expimp = 'i' and  vcdocs.dntype = '02' then vcdocs.payret = yes.
                        if vccontrs.expimp = 'e' and  vcdocs.dntype = '03' then vcdocs.payret = yes.
                    end.
                    else do:
                        if index('o', s-dnvid) > 0 then do:
                            if lookup(vccontrs.cttype,'3,11') > 0 then vcdocs.dntype = '17'.
                            else if lookup(vccontrs.cttype,'1,2') > 0 then vcdocs.dntype = '07'.
                        end.
                        else vcdocs.dntype = entry(1, s-vcdoctypes).
                    end.
                    find ncrc where ncrc.code = entry(1, vccontrs.ctvalpl) no-lock no-error.
                    if avail ncrc then vcdocs.pcrc = ncrc.crc.
                    else message 'Валюта платежа ' + vccontrs.ctvalpl +  ', указанная в контракте, не найдена в справочнике!' view-as alert-box error.
                    run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con). "
    &delete     = " delete vcdocs. "
    &postdelete = " run vcctsumm. if vccontrs.cttype = '6' or vccontrs.cttype = '3' or vccontrs.cttype = '2' or vccontrs.cttype = '1'
                    then run check_term (s-contract, v-sumgtd, v-sumplat, v-sumakt, v-sumexc_6, ?, output v-term).
                    displ v-sumost1 v-suminv v-sumkon v-sumexc v-sumgtd v-sumplat v-sumakt v-sumost v-sumexc% v-term v-sumzalog with
                    frame vcctsumm."
}

procedure defcrckod.
    find ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
    if avail ncrc then v-crckod = ncrc.code. else v-crckod = ''.
end procedure.

procedure deftypename.
    find codfr where codfr.codfr = "vcdoc" and codfr.code = vcdocs.dntype no-lock no-error.
    if avail codfr then v-dntypename = codfr.name[2]. else v-dntypename = "".
end procedure.

procedure defpaid.
    def var i as integer.
    if vcdocs.info[1] <> '' then do:
        repeat i = 1 to num-entries(vcdocs.info[1], ';'):
            find b-vcdocs where (b-vcdocs.dntype = '12' or b-vcdocs.dntype = '15') and b-vcdocs.dnnum = entry(i, vcdocs.info[1], ';') exclusive-lock no-error.
            if avail b-vcdocs then b-vcdocs.info[5] = 'paid'.
        end.
    end.
end procedure.

procedure noupd.
    bell.
    message skip " Данное действие невозможно! Контракт закрыт либо у Вас нет прав на выполнение данной процедуры." skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
end procedure.

procedure defpartner.
    find vcpartners where vcpartners.partner = vcdocs.info[4] no-lock no-error.
    if avail vcpartners then v-partner = vcpartners.name.
    else v-partner = "".
    v-locatben = (avail vcpartners and vcpartners.country = "KZ").
end.

procedure defprocent.
    case vcdocs.info[2]:
        when '1' then v-procent = 'no'.
        when '2' then v-procent = 'yes'.
    end.
end.

procedure Scode:
    def input parameter typ as char.
    def output parameter cod as char.
    cod = "".
    for each codfr where codfr.codfr = "vcdoc" and index(typ,codfr.name[5]) > 0 no-lock:
        cod = cod + codfr.code + ",".
    end.
end procedure.

procedure Ndoc:
    def input parameter typ as char.
    def output parameter num as inte.
    def buffer b-vcdocs for comm.vcdocs.
    num = 0.
    for each b-vcdocs where b-vcdocs.contract = s-contract no-lock:
        if lookup(b-vcdocs.dntype,typ) = 0 then next.
        num = num + 1.
    end.
end procedure.

procedure NextNum:
    def buffer b-nmbrs for comm.nmbrs.
    def var dntype as char.
    def var num as inte.
    dntype = "". num = 0.
    run Scode("p,o",output dntype).
    run Ndoc(dntype,output num).
    if s-newrec then do:
        if lookup(vcdocs.dntype,dntype) > 0 then do:
            find b-nmbrs where b-nmbrs.ccode = string(s-contract) exclusive-lock no-error.
            if not avail b-nmbrs then do:
                create b-nmbrs.
                b-nmbrs.ccode = string(vccontrs.contract).
                b-nmbrs.descode = "Контракт ВалКон".
                b-nmbrs.nmbr = num.
            end.
            b-nmbrs.nmbr = b-nmbrs.nmbr + 1.
            vcdocs.numobyaz = b-nmbrs.nmbr.
            displ vcdocs.numobyaz with frame vcdndocs.
            release b-nmbrs.
        end.
    end.
end procedure.

procedure SelField:
    def var v-oldval as char.
    def var v-info4 as char.

    def buffer b-vcpartners for vcpartners.

    v-info4 = trim(vcdocs.info[4]).
    if lookup("1",v-sel) > 0 or lookup("3",v-sel) > 0 then do:
        find first vcpartners where vcpartners.partner = v-info4 no-lock no-error.
        if avail vcpartners then do:
            pause 0.
            v-ordben = trim(vcpartners.name).
            displ v-ordben with frame country.
            v-oldval = v-ordben.
            update vcdocs.info[4] with frame country.
            displ vcdocs.info[4] with frame country.
            find first b-vcpartners where b-vcpartners.partner = trim(vcdocs.info[4]) no-lock no-error.
            if avail b-vcpartners then v-ordben = trim(b-vcpartners.name).
            displ v-ordben with frame country.
            update v-ordben with frame country.
            hide frame country.
            pause 0.
            if v-oldval <> v-ordben then do:
                find current b-vcpartners exclusive-lock no-error.
                b-vcpartners.name = trim(v-ordben).
                find current b-vcpartners no-lock no-error.
                if lookup("1",v-sel) > 0 then do:
                    run CorrAdd("NAME",DelQues(v-oldval) + "|" + DelQues(trim(v-ordben)),"Наименование/ФИО отправителя денег/товаров").
                    run CorrAddCt("NRNAME",DelQues(v-oldval) + "|" + DelQues(trim(v-ordben)),"Наименование нерезидента").
                    run vc2hisct(vccontrs.contract, "Изменен контракт : Наименование/ФИО отправителя денег/товаров с " + DelQues(v-oldval) + " на " + DelQues(trim(v-ordben))).
                end.
                else if lookup("3",v-sel) > 0 then do:
                    run CorrAdd("BNAME",DelQues(v-oldval) + "|" + DelQues(trim(v-ordben)),"Наименование/ФИО получателя денег/товаров").
                    run CorrAddCt("NRNAME",DelQues(v-oldval) + "|" + DelQues(trim(v-ordben)),"Наименование нерезидента").
                    run vc2hisct(vccontrs.contract, "Изменен контракт : Наименование/ФИО получателя денег/товаров с " + DelQues(v-oldval) + " на " + DelQues(trim(v-ordben))).
                end.

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("2",v-sel) > 0 or lookup("4",v-sel) > 0 then do:
        find first vcpartners where vcpartners.partner = v-info4 no-lock no-error.
        if avail vcpartners then do:
            pause 0.
            v-country = vcpartners.country.
            displ v-country with frame country.
            v-oldval = v-country.
            update vcdocs.info[4] with frame country.
            displ vcdocs.info[4] with frame country.
            find first b-vcpartners where b-vcpartners.partner = trim(vcdocs.info[4]) no-lock no-error.
            if avail b-vcpartners then v-country = trim(b-vcpartners.country).
            displ v-country with frame country.
            update v-country with frame country.
            hide frame country.
            pause 0.
            if v-oldval <> v-country then do:
                find current b-vcpartners exclusive-lock no-error.
                b-vcpartners.country = v-country.
                find current b-vcpartners no-lock no-error.
                if lookup("2",v-sel) > 0 then do:
                    run CorrAdd("COUNTRY",DelQues(v-oldval) + "|" + DelQues(trim(v-country)),"Страна отправителя денег/товара").
                    run CorrAddCt("NRCOUNTRY",DelQues(v-oldval) + "|" + DelQues(trim(v-country)),"Страна нерезидента").
                    run vc2hisct(vccontrs.contract, "Изменен контракт : Страна отправителя денег/товара с " + DelQues(v-oldval) + " на " + DelQues(trim(v-country))).
                end.
                else if lookup("4",v-sel) > 0 then do:
                    run CorrAdd("BCOUNTRY",DelQues(v-oldval) + "|" + DelQues(trim(v-country)),"Страна бенефициара").
                    run CorrAddCt("NRCOUNTRY",DelQues(v-oldval) + "|" + DelQues(trim(v-country)),"Страна нерезидента").
                    run vc2hisct(vccontrs.contract, "Изменен контракт : Страна бенефициара с " + DelQues(v-oldval) + " на " + DelQues(trim(v-country))).
                end.

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("5",v-sel) > 0 then do:
        v-oldval = string(vcdocs.dndate,"99/99/9999").
        update vcdocs.dndate with frame vcdndocs.
        if vcdocs.dndate entered then do:
            if v-oldval <> string(vcdocs.dndate,"99/99/9999") then do:
                run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                displ vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                run CorrAdd("PAYDATE",DelQues(v-oldval) + "|" + DelQues(string(vcdocs.dndate,"99/99/9999")),"Дата платежа/исполнения обязательств").

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("6",v-sel) > 0 then do:
        v-oldval = string(vcdocs.sum,"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99").
        update vcdocs.sum with frame vcdndocs.
        if vcdocs.sum entered then do:
            if v-oldval <> string(vcdocs.sum,"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99") then do:
                displ vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                run CorrAdd("SUMM",DelQues(v-oldval) + "|" + DelQues(string(vcdocs.sum,"-zzzzzzzzzzzzzzzzzzzzzzzzz9.99")),"Сумма платежа/обязательств").

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("7",v-sel) > 0 then do:
        v-oldval = string(vcdocs.pcrc).
        update vcdocs.pcrc with frame vcdndocs.
        if vcdocs.pcrc entered then do:
            if v-oldval <> string(vcdocs.pcrc) then do:
                run defcrckod.
                run crosscurs(vcdocs.pcrc, vccontrs.ncrc, vcdocs.dndate, output vcdocs.cursdoc-con).
                displ v-crckod vcdocs.cursdoc-con vcdocs.sum / vcdocs.cursdoc-con @ v-sumdoccon with frame vcdndocs.
                run CorrAdd("CURR",DelQues(v-oldval) + "|" + DelQues(string(vcdocs.pcrc)),"Валюта платежа").

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("8",v-sel) > 0 then do:
        v-oldval = trim(vcdocs.kod14).
        update vcdocs.kod14 with frame vcdndocs.
        if vcdocs.kod14 entered then do:
            if v-oldval <> trim(vcdocs.kod14) then do:
                if vcdocs.kod14 = "22" then update vcdocs.info[1] = "Уступка права требования к нерезиденту" with frame vcdndocs.
                else if vcdocs.kod14 = "23" then do:
                    find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
                    if avail vcps then update vcdocs.info[1] = "Перевод долга по ПС " + vcps.dnnum + string(vcps.num) + " другому резиденту" with frame vcdndocs.
                end.
                else if vcdocs.kod14 = "21" then do:
                    message "Укажите условие для зачета!" view-as alert-box.
                    update vcdocs.info[1] with frame vcdndocs.
                end.
                run CorrAdd("CODECALC",DelQues(v-oldval) + "|" + DelQues(trim(vcdocs.kod14)),"Способ расчетов").

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
    if lookup("9",v-sel) > 0 then do:
        if index('p', s-dnvid) > 0 then do:
            v-oldval = vcdocs.dntype.
            update vcdocs.dntype with frame vcdndocs.
            if vcdocs.dntype entered then do:
                if v-oldval <> vcdocs.dntype then do:
                    def var v-io1 as char.
                    def var v-io2 as char.
                    run Rval(v-oldval,output v-io1).
                    run Rval(vcdocs.dntype,output v-io2).
                    run CorrAdd("INOUT",DelQues(v-io1) + "|" + DelQues(v-io2),"Признак платежа").

                    update vcdocs.opertype = "2" with frame vcdndocs.
                    displ vcdocs.opertype with frame vcdndocs.
                end.
            end.
        end.
    end.
    if lookup("10",v-sel) > 0 then do:
        v-oldval = trim(vcdocs.info[1]).
        update vcdocs.info[1] with frame vcdndocs.
        if vcdocs.info[1] entered then do:
            if v-oldval <> trim(vcdocs.info[1]) then do:
                run CorrAdd("NOTE",DelQues(v-oldval) + "|" + DelQues(trim(vcdocs.info[1])),"Примечание").

                update vcdocs.opertype = "2" with frame vcdndocs.
                displ vcdocs.opertype with frame vcdndocs.
            end.
        end.
    end.
end procedure.

procedure Rval:
    def input parameter dntype as char.
    def output parameter inout as char.
    inout = "".
    if dntype = "02" then inout = "2".
    if dntype = "03" then inout = "1".
end procedure.

procedure CorrAdd:
    def input parameter nm as char.
    def input parameter cr as char.
    def input parameter ds as char.

    do:
        create vccorrecthis.
        vccorrecthis.num = next-value(correct).
        vccorrecthis.docs = s-docs.
        vccorrecthis.correctdt = g-today.
        vccorrecthis.who = g-ofc.
        vccorrecthis.bank = v-ourbnk.
        vccorrecthis.sub = nm.
        vccorrecthis.corrfield = cr.
        vccorrecthis.des = ds.
        release vccorrecthis.
    end.
    vcdocs.dtcorrect = g-today.
    displ vcdocs.dtcorrect with frame vcdndocs.
end procedure.

procedure CorrAddCt:
    def input parameter nm as char.
    def input parameter cr as char.
    def input parameter ds as char.

    do:
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
    end.
    find current vccontrs exclusive-lock no-error.
    vccontrs.dtcorrect = g-today.
    find current vccontrs no-lock no-error.
end procedure.


