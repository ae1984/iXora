/* vcctac.p
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
        27.04.2009 galina - перенесла на акцепт создание паспорта сделки
        28.04.2009 galina - ПС только для контрактов типа 1
        08.06.10 - переход на iban
        11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
        14.03.2011 aigul - дате ПС присвоить дату регистрации контракта
        08.09.2011 damir - то что добавил закоментил вдруг попросят обратно вернуть.
        30.09.2011 damir - если при регистрации контракта есть форма расчетов '22' то выводит message.
        07.10.2011 damir - добавил сохранение нового ПС в vcpshismt.
        19.10.2011 damir - добавил do transaction
        29.06.2012 damir - паспорт сделки на УНК в message.

*/

/* vccontrs.p Валютный контроль
   Акцепт данных о контракте

   18.10.2002 nadejda создан
*/

{vc.i}

{global.i}
{nlvar.i}
{vc-crosscurs.i}
def shared var s-contract like vccontrs.contract.
def shared var s-cif like cif.cif.
def shared var v-cifname as char.
def var v-ans as logical init no.

def buffer b-vcps for vcps.
def var v-bank as inte.
def var v-exim as char format '9'.
def var v-psnum as integer init 1.
def var v-ps1 as char.
{comm-txb.i}

find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
    if avail vccontrs then do:
        if vccontrs.cdt = ? then do:
            message " Утвердить данные контракта? " update v-ans.
            if v-ans eq false then do:
            bell.
            leave.
        end.
        else do transaction on error undo, retry:
            find current vccontrs exclusive-lock.
            vccontrs.cdt = g-today.
            vccontrs.cwho = g-ofc.
            find current vccontrs no-lock.
            if vccontrs.cttype = '1' then do:
                find first vcps where vcps.contract = s-contract and vcps.dntype = '01' no-lock no-error.
                if not avail vcps then do:
                    create vcps.
                    if vccontrs.expimp = 'i' then v-exim = '2'.
                    else v-exim = '1'.
                    v-bank = comm-cod().
                    find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
                    find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.
                    /*v-ps1 = v-exim + '/' + substr(sysc.chval,7,3) + '/' +  string(v-bank,'99') +  string(ofchis.dep,'99') + '/'.*/
                    v-ps1 = v-exim + '/' + string(sysc.inval,'999') + '/' +  string(v-bank,'99') +  string(ofchis.dep,'99') + '/'.
                    find last b-vcps where b-vcps.dnnum = v-ps1 and b-vcps.dntype = '01' use-index dnnum no-lock no-error.
                    if avail b-vcps then do:
                        v-psnum = b-vcps.num + 1.
                    end.
                    assign
                    vcps.ps = next-value(vc-ps)
                    vcps.contract = vccontrs.contract
                    vcps.rwho = g-ofc
                    vcps.rdt = g-today
                    vcps.dntype = '01'
                    vcps.dnnum = v-ps1
                    vcps.num = v-psnum
                    vcps.dndate = /*vccontrs.rdt*/ vccontrs.ctregdt
                    vcps.lastdate = vccontrs.lastdate
                    vcps.ncrc = vccontrs.ncrc
                    vcps.sum = vccontrs.ctsum
                    vcps.ctvalpl = vccontrs.ctvalpl
                    vcps.ctvalogr = vccontrs.info[1]
                    vcps.ctterm = vccontrs.ctterm
                    vcps.ctformrs = vccontrs.ctformrs
                    vcps.info[1] = v-cifname.
                    run crosscurs(vcps.ncrc, vccontrs.ncrc, vcps.dndate, output vcps.cursdoc-con).

                    message "Зарегистрирован УНК " + vcps.dnnum + string(vcps.num) view-as alert-box.
                    if lookup("22",trim(vccontrs.ctformrs),",") > 0 then message "Введите код ОКПО предыдущего банка паспорта сделки в закладке (ПсДлДс) ! " view-as alert-box buttons ok.

                end.
            end.

            /* записать в историю */
            run vc2hisct(s-contract, "Контракт акцептован").

            s-noedt = true.
            s-nodel = true.
            s-page = 1.
            run nlmenu.
        end.
    end.
    else do:
        message " Снять отметку об утверждении данных? " update v-ans.
        if v-ans eq false then do:
            bell.
            leave.
        end.
        else do transaction on error undo, retry:
            find current vccontrs exclusive-lock.
            vccontrs.cdt = ?.
            vccontrs.cwho = ''.
            find current vccontrs no-lock.
            /* записать в историю */
            run vc2hisct(s-contract, "Снят акцепт контракта").

            s-noedt = false.
            s-nodel = false.
            s-page = 1.
            run nlmenu.
        end.
    end.
end.

do transaction:
    find first vccontrs where vccontrs.contract = s-contract no-lock no-error.
    if avail vccontrs then do:
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
        if avail vcps then do:
            find first vcpshismt where vcpshismt.contract = vcps.contract and vcpshismt.ps = vcps.ps and vcpshismt.stsnew = "old" no-lock no-error.
            if not avail vcpshismt then do:
                create vcpshismt.
                assign
                vcpshismt.ps = vcps.ps
                vcpshismt.contract = vcps.contract
                vcpshismt.rdt = vcps.rdt
                vcpshismt.rwho = vcps.rwho
                vcpshismt.dntype = vcps.dntype
                vcpshismt.dnnum = vcps.dnnum
                vcpshismt.num = vcps.num
                vcpshismt.dndate = vcps.dndate
                vcpshismt.lastdate = vcps.lastdate
                vcpshismt.ncrc = vcps.ncrc          /*Валюта контракта*/
                vcpshismt.sum = vcps.sum            /*Сумма контракта*/
                vcpshismt.ctvalpl = vcps.ctvalpl    /*валюта платежа*/
                vcpshismt.ctvalogr = vcps.ctvalogr  /*валютная оговорка*/
                vcpshismt.ctterm = vcps.ctterm      /*сроки репатриации*/
                vcpshismt.ctformrs = vcps.ctformrs  /*Код способа расчетов*/
                vcpshismt.info[1] = vcps.info[1]
                vcpshismt.createdt = g-today
                vcpshismt.createwho = g-ofc
                vcpshismt.stsnew = "old"
                vcpshismt.rslc = vcps.rslc
                vcpshismt.cursdoc-con = vcps.cursdoc-con
                vcpshismt.origin = vcps.origin
                vcpshismt.ctexpimp = vccontrs.expimp /*Признак экспорт-импорт*/
                vcpshismt.ctpartner = vccontrs.partner /*Инопартнер*/
                vcpshismt.ctnum = vccontrs.ctnum     /*Номер контракта*/
                vcpshismt.ctdate = vccontrs.ctdate   /*Дата контракта*/
                vcpshismt.ctclose = vccontrs.info[8] /*Основание закрытия*/
                vcpshismt.ctclosedt = vccontrs.stsdt. /*Дата закрытия*/
            end.
        end.
    end.
end.