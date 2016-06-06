/* kfmdopinf.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Запрос доп. информации для переводов без открытия счета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/03/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        31.03.2010 galina - добавила {global.i}
        14/04/2010 galina - добавила ввод телефона
        23/06/2010 galina - запрос дополнительной информации по клиенту для переводов без открытия счета
        24/06/2010 galina - ИИН можно не заполнять
                            поправила определение признака резиденства
                            добавила заполнение полей rwho rwhn в cifmin
                            увеличила разрядность для ИД в cifmin
        29/06/2010 galina - не заполняем данные, если РНН единицы
        02/07/2010 galina - добавила параметры p-addrin,p-telin; удалила параметр p-bank
        03/12/2010 madiyar - работаем только с ИИН/БИН
*/
{global.i}

def input parameter p-namein as char. /* имя клиента */
def input parameter p-iinin as char.
def input parameter p-numregin as char.
def input parameter p-dtregin as date.
def input parameter p-orgregin as char.
def input parameter p-clname as char. /* имя получателя/отправителя */

def input parameter p-addrin as char. /* адрес */
def input parameter p-telin as char. /* телефон */

def input parameter p-ptype as integer. /* 1-входящий, 2-исходящий, 3-обменная операция */

def output parameter p-fam as char no-undo.
def output parameter p-name as char no-undo.
def output parameter p-mname as char no-undo.
def output parameter p-iin as char no-undo.
def output parameter p-numreg as char no-undo.
def output parameter p-dtreg as date no-undo.
def output parameter p-orgreg as char no-undo.
def output parameter p-dtbth as date no-undo.
def output parameter p-bplace as char no-undo.
def output parameter p-res as char no-undo.
def output parameter p-country as char no-undo.
def output parameter p-clfam2 as char no-undo.
def output parameter p-clname2 as char no-undo.
def output parameter p-clmname2 as char no-undo.
def output parameter p-addr as char no-undo.
def output parameter p-tel as char no-undo.
def output parameter p-public as char no-undo. /* признак ИПДЛ */
def output parameter p-doctyp as char no-undo. /* вид документа удостоверяющего личность */
def output parameter p-cif as char no-undo. /* ID клиента */

def shared var v-dopres as logi init no.
def var v-res as char no-undo.
def var v-resdes as char no-undo.
def var v-clfilial as char no-undo.

{chk12_innbin.i}
{adres.f}


def var v-mess1 as char no-undo.
def var v-mess2 as char no-undo.
def var v-public as char no-undo.
def var v-doctyp as char no-undo.
def var v-nocifmin as logi no-undo.

def new shared temp-table t-cif
    field fam as char
    field name as char
    field mname as char
    field iin as char
    field doctyp as char
    field publicf as char
    field rnn as char
    field numreg as char
    field dtreg as date
    field orgreg  as char
    field dtbth as date
    field bplace  as char
    field adres  as char
    field tel  as char
    field bank as char
    field cif as char.

form
    v-clfilial no-label format "x(60)" colon 25 skip
    v-res label 'Резидентство'  colon 18 format "9" validate(can-find (codfr where codfr.codfr = 'kfmPrtRs' and codfr.code = v-res no-lock),'Введите признак!') help 'F2 - справочник'
    v-resdes no-label colon 20 format "x(20)" skip
    p-fam label 'Фамилия'  colon 18 format "x(20)" validate(trim(p-fam) <> '','Введите фамилию!')
    p-name label 'Имя' colon 45 format "x(20)" validate(trim(p-name) <> '','Введите имя!')
    p-mname label 'Отчество' colon 75 format "x(20)" skip
    p-dtbth label 'Дата рождения' colon 18 format "99/99/9999" validate(p-dtbth <> ?,'Введите дату!')
    p-bplace label 'Место рождения'  colon 45 format "x(40)" validate(trim(p-bplace) <> '','Введите место рождения!') skip
    p-public label 'Принад/ть к ИПДЛ'  colon 18 format "9"  help 'F2 - справочник' validate(can-find (codfr where codfr.codfr = 'publicf' and codfr.code = p-public no-lock),'Введите признак!')
    v-public no-label colon 20 format "x(60)" skip
    '------------------------------------Документ удостоверяющий личность---------------------' at 5  skip
    p-doctyp label 'Вид документа'  colon 18 format "99"  help 'F2 - справочник' validate(can-find (codfr where codfr.codfr = 'kfmFUd' and codfr.code = p-doctyp no-lock),'Введите признак!')
    v-doctyp no-label colon 21 format "x(60)" skip
    p-numreg label 'Номер' colon 18 format "x(40)" validate(trim(p-numreg) <> '','Введите номер документа!') skip
    p-orgreg label 'Кем выдан'  colon 18 format "x(40)" validate(trim(p-orgreg) <> '','Введите наименование!') skip
    p-dtreg label 'Дата выдачи' colon 18 format "99/99/9999" validate(p-dtreg <> ?,'Введите дату!') skip
    '-----------------------------------------------------------------------------------------' at 5 skip
    p-iin label 'ИИН' colon 18 format "x(12)" validate(chk12_innbin(p-iin) or v-res = '0','Не введен или некорректный ИИН!') skip
    v-adres label 'Юридический адрес' colon 18 format "x(50)" skip
    p-tel label 'Телефон' colon 18 format "x(20)" validate(trim(p-tel) <> '','Введите тефон клиента!') skip
    '-----------------------------------Отправитель/Получатель--------------------------------' at 5 skip
    p-clfam2 format "x(20)" validate(trim(p-clfam2) <> '',v-mess1) label 'Фамилия' colon 18
    p-clname2 format "x(20)" validate(trim(p-clname2) <> '',v-mess2) label 'Имя' colon 45
    p-clmname2 format "x(20)" label 'Отчество' colon 75
with centered side-label row 7 width 100 overlay  title 'Дополнительная информация для фин.мониторинга' frame fdopinfo.


on help of p-public in frame fdopinfo do:
    {itemlist.i
    &file = "codfr"
    &frame = "row 6 centered scroll 1 20 down overlay width 91 "
    &where = " codfr.codfr = 'publicf' "
    &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
    &chkey = "code"
    &index  = "cdco_idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    p-public = codfr.code.
    v-public = codfr.name[1].
    display p-public v-public with frame fdopinfo.
end.

on help of v-res in frame fdopinfo do:
    {itemlist.i
    &file = "codfr"
    &frame = "row 6 centered scroll 1 20 down overlay width 91 "
    &where = " codfr.codfr = 'kfmPrtRs' "
    &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
    &chkey = "code"
    &index  = "cdco_idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    v-res = codfr.code.
    v-resdes = codfr.name[1].
    display v-res v-resdes with frame fdopinfo.
end.

on help of p-doctyp in frame fdopinfo do:
    {itemlist.i
    &file = "codfr"
    &frame = "row 6 centered scroll 1 20 down overlay width 91 "
    &where = " codfr.codfr = 'kfmFUd' "
    &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
    &chkey = "code"
    &index  = "cdco_idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
    }
    p-doctyp = codfr.code.
    v-doctyp = codfr.name[1].
    display p-doctyp v-doctyp with frame fdopinfo.
end.

/*do transaction: */

    v-dopres = no.
    v-public = ''.
    v-clfilial = ''.

    if p-ptype = 1 then do:
      v-mess1 = 'Введите фамилию отправителя'.
      v-mess2 = 'Введите имя отправителя'.
    end.
    else do:
      v-mess1 = 'Введите фамилию получателя'.
      v-mess2 = 'Введите имя получателя'.
    end.

    if num-entries(p-namein,' ') > 0 then p-fam = entry(1,p-namein,' ').
    if num-entries(p-namein,' ') > 1 then p-name = entry(2,p-namein,' ').
    if num-entries(p-namein,' ') > 2 then p-mname = entry(3,p-namein,' ').
    if p-ptype < 3 then do:
        if num-entries(p-clname,' ') > 0 then p-clfam2 = entry(1,p-clname,' ').
        if num-entries(p-clname,' ') > 1 then p-clname2 = entry(2,p-clname,' ').
        if num-entries(p-clname,' ') > 2 then p-clmname2 = entry(3,p-clname,' ').
    end.
    p-iin = p-iinin.
    p-numreg = p-numregin.
    p-dtreg = p-dtregin.
    p-orgreg = p-orgregin.
    v-adres = p-addrin.
    p-tel = p-telin.

    display p-fam p-name p-mname v-adres p-tel p-numreg p-orgreg p-dtreg p-iin p-clfam2 p-clname2 p-clmname2 with frame fdopinfo.

    update v-res with frame fdopinfo.
    find first codfr where codfr.codfr = 'kfmPrtRs' and codfr.code = v-res no-lock no-error.
    if avail codfr then do:
        v-resdes = codfr.name[1].
        display v-resdes with frame fdopinfo.
    end.

    v-nocifmin = no.

    if v-res  = '1' then update p-iin with frame fdopinfo.
    else update p-numreg  with frame fdopinfo.
    empty temp-table t-cif.
    /* ищем в своем филиале */
    if v-res = '1' then find first cif where cif.bin = p-iin and cif.type = 'P'and cif.geo = '021' no-lock no-error.
    else find first cif where cif.geo <> '021' and cif.type = 'P' and cif.pss matches '*' + p-numreg + '*' no-lock no-error.
    if avail cif then do:
        create t-cif.
        t-cif.rnn = cif.jss.
        t-cif.iin = cif.bin.
        t-cif.cif = cif.cif.
        if cif.pss <> '' then do:
            case num-entries(trim(cif.pss),' '):
                when 1 then t-cif.numreg = cif.pss.
                when 2 then do: t-cif.numreg = entry(1,cif.pss, ' '). t-cif.dtreg = date(entry(2,cif.pss,' ')) no-error. end.
                when 3 then do: t-cif.numreg = entry(1,cif.pss, ' '). t-cif.dtreg = date(entry(2,cif.pss, ' ')) no-error. t-cif.orgreg  = entry(3,cif.pss, ' '). end.
                when 4 then do: t-cif.numreg = entry(1,cif.pss, ' '). t-cif.dtreg = date(entry(2,cif.pss, ' ')) no-error. t-cif.orgreg  = entry(3,cif.pss, ' ') + ' ' +  entry(4,cif.pss, ' '). end.
            end.
        end.

        if cif.name <> '' then do:
            case num-entries(trim(cif.name),' '):
                when 1 then t-cif.fam = cif.name.
                when 2 then do: t-cif.fam = entry(1,cif.name,' '). t-cif.name = entry(2,cif.name,' '). end.
                when 3 then do: t-cif.fam = entry(1,cif.name,' '). t-cif.name = entry(2,cif.name,' '). t-cif.mname = entry(3,cif.name,' '). end.
            end.
        end.

        t-cif.dtbth = cif.expdt.
        t-cif.bplace = cif.bplace.
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'publicf' no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> 'msc' then t-cif.public = sub-cod.ccode.

        find first codfr where codfr.codfr = 'publicf' and codfr.code = t-cif.public no-lock no-error.
        if avail codfr then do:
            v-public = codfr.name[1].
             display v-public with frame fdopinfo.
        end.

        t-cif.adres = cif.addr[1].
        t-cif.tel = cif.tel.
        find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
        if avail sysc and sysc.chval <> '' then t-cif.bank = sysc.chval.
    end.

    /* ищем в другом филиале */
    find first t-cif no-lock no-error.
    if not avail t-cif then do:
        if v-res = '1' then run kfmdopcif(v-res,p-iin).
        else run kfmdopcif(v-res,p-numreg).
    end.

    find first t-cif no-lock no-error.
    if avail t-cif then do:
        p-fam = t-cif.fam.
        p-name = t-cif.name.
        p-mname = t-cif.mname.
        p-iin = t-cif.iin.
        p-doctyp = t-cif.doctyp.
        p-public = t-cif.publicf.
        p-numreg = t-cif.numreg.
        p-dtreg = t-cif.dtreg.
        p-orgreg = t-cif.orgreg.
        p-dtbth = t-cif.dtbth.
        p-bplace = t-cif.bplace.
        v-adres = t-cif.adres.
        p-addr = t-cif.adres.
        p-tel = t-cif.tel.
        p-cif = t-cif.cif.

        if t-cif.bank = 'txb00' then v-clfilial = 'КЛИЕНТ ЦО'.
        else do:
            find first txb where txb.bank = t-cif.bank no-lock.
            v-clfilial = 'КЛИЕНТ ФИЛИАЛА ' +  caps(txb.info).
        end.
    end.
    if not avail t-cif then do:
        if v-res = '1' then find first cifmin where cifmin.iin = p-iin and cifmin.res = '1' no-lock no-error.
        else find first cifmin where cifmin.docnum matches '*' + p-numreg + '*' and cifmin.res = '0' no-lock no-error.
        if avail cifmin then do:
            p-fam = cifmin.fam.
            p-name = cifmin.name.
            p-mname = cifmin.mname.
            p-iin = cifmin.iin.
            p-doctyp = cifmin.doctype.
            p-public = cifmin.publicf.
            p-numreg = cifmin.docnum.
            p-dtreg = cifmin.docdt.
            p-orgreg = cifmin.docwho.
            p-dtbth = cifmin.bdt.
            p-bplace = cifmin.bplace.
            v-adres = cifmin.addr.
            p-tel = cifmin.tel.
        end.
        else v-nocifmin = yes.
    end.
    find first codfr where codfr.codfr = 'publicf' and codfr.code = p-public no-lock no-error.
    if avail codfr then do:
        v-public = codfr.name[1].
        display v-public with frame fdopinfo.
    end.

    find first codfr where codfr.codfr = 'kfmFUd' and codfr.code = p-doctyp no-lock no-error.
    if avail codfr then do:
        v-doctyp = codfr.name[1].
         display v-doctyp with frame fdopinfo.
    end.

    display v-clfilial p-fam p-name p-mname p-dtbth p-bplace p-public p-doctyp p-iin v-doctyp v-public v-adres p-tel p-clfam2 p-clname2 p-clmname2  p-numreg p-orgreg p-dtreg with frame fdopinfo.
    if not avail t-cif then do:
        update p-fam with frame fdopinfo.
        update p-name with frame fdopinfo.
        update p-mname with frame fdopinfo.
        update p-dtbth with frame fdopinfo.
        update p-bplace with frame fdopinfo.
        update p-public  with frame fdopinfo.
        find first codfr where codfr.codfr = 'publicf' and codfr.code = p-public no-lock no-error.
        if avail codfr then do:
            v-public = codfr.name[1].
             display v-public with frame fdopinfo.
        end.
        update p-doctyp with frame fdopinfo.
        find first codfr where codfr.codfr = 'kfmFUd' and codfr.code = p-doctyp no-lock no-error.
        if avail codfr then do:
            v-doctyp = codfr.name[1].
             display v-doctyp with frame fdopinfo.
        end.

        update p-numreg with frame fdopinfo.
        update p-orgreg with frame fdopinfo.
        update p-dtreg  with frame fdopinfo.
        update p-iin with frame fdopinfo.

    /*v-adres = ''.*/
        v-title = "Юридический адрес".
        {adres.i
        &hide = "hide frame fur no-pause."}
        display v-adres with frame fdopinfo.
        p-country = v-country_cod.
        /*if v-country_cod = 'KZ' then p-res = '1'.
        else p-res = '0'.*/
        p-addr = v-adres.

        update p-tel with frame fdopinfo.
    end.
    else do:
        v-country2 = entry(1,v-adres).
        if num-entries(v-country2,'(') = 2 then p-country = substr(entry(2,entry(1,v-adres),'('),1,2).
    end.


    if p-ptype < 3 then do:
        update p-clfam2  with frame fdopinfo.
        update p-clname2 p-clmname2 with frame fdopinfo.
    end.

/*end.*/
if not avail t-cif then do transaction:
    if v-nocifmin then do:
        create cifmin.
        cifmin.cifmin = 'cm' + string(next-value(cmnum),'99999999').
    end.
    else find current cifmin exclusive-lock.
    cifmin.fam = p-fam.
    cifmin.name = p-name.
    cifmin.mname = p-mname.
    cifmin.iin = p-iin.
    cifmin.doctype = p-doctyp.
    cifmin.publicf = p-public.
    /*
    cifmin.rnn = p-rnn.
    */
    cifmin.docnum = p-numreg.
    cifmin.docdt = p-dtreg.
    cifmin.docwho = p-orgreg.
    cifmin.bdt = p-dtbth.
    cifmin.bplace = p-bplace.
    cifmin.publicf = p-public.
    cifmin.addr = v-adres.
    cifmin.tel = p-tel.
    cifmin.res = v-res.
    cifmin.rwhn = g-today.
    cifmin.rwho = g-ofc.

    p-cif = cifmin.cifmin.

end.
if p-res = '' then p-res = v-res.
v-dopres = yes.
pause 10.
hide frame fdopinfo.


