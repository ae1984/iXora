/* r-salde1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Сальдовка развернутая с остатками по субсчетам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
        r-salde.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
        8-12-10
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM TXB
 * CHANGES
        02/01/01 edited by Podlipalina.E.
        02.11.2001 sasco
                + убраны нулевые счета
                + после "ИТОГО..." сделана разделительная черта
                + не выводятся имена для депозитов физ.лиц
                       05.01.2002:
                + запрос на дату сальдовки
                + все курсы валют берутся из истории в CRCHIS
        05.02.2002 sasco запрос на счет Г/К ил ENTER для всех счетов
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        12.07.2004 sasco баланс берется по glday вместо glbal
        12.07.2004 sasco балансы берутся по aab, hisdfb, lon, fun, arp
        28.12.2004 u00121 + изменена форма вывода документа пользователю - выводится в Excel
                    + Добавлены столбцы отчета:
                    - Сектор экономики = sub-cod.d-cod = "ecdivis"
                    - Дата открытия счета
                    - Дата закрытия счета/окончания срока действия счета
                    - Процентная ставка по счету
                    - Курс конвертации суммы счета
       29.12.2004 u00121 отчет сделан консолидированным
       09.09.05 nataly добавлен столбец "Гео код"
       25/07/2007 madiyar - убрал упоминание удаленной таблицы e002
       02/07/09 marinav - добавлен филиал
       07/08/2009 madiyar - добавлены стобцы по процентам
       31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel
                    + Изменены столбцы отчета:
                    - Сектор ОТРАСЛЕЙ экономики = sub-cod.d-cod = "ecdivis"
                    + Добавлены столбцы отчета:
                    - Сектор экономики = sub-cod.d-cod = "secek"
       05/08/2010 aigul - добавление информации о клиентах связанных с банком особыми отношениями
       01/09/2010 aigul - вывод информации о клиентах связанных с банком особыми отношениями по реестру
       09/12/2010 evseev - добавление столбца "Сумма по договору". В кредитах - сумма в договоре, в депозитах - сумма первого взноса.
       22/12/2010 evseev - добавление столбцов "основание" "условие обслуживания"
       21.07.2011 ruslan - добавил опцию по счетам с нулевыми остатаками и изменил rate
       01/08/2011 evseev - у клиентских счетов исправление условия "счет не закрыт?" на условие "счет был закрыт такого числа?"(таблица aadrt)
       02/08/2011 evseev - добавил столбцы для вывода даты при пролонгации депозита
       08/08/2011 evseev - удалил условие "счет был закрыт такого числа?"(таблица aadrt)
       10.08.2011 ruslan - убрал коммент txb.aaa.sta <> "C"
       11.08.2011 id00004 - вернул коммент txb.aaa.sta <> "C"
       04.01.2011 id00004 - добавил отображение ставок по текущим счетам
       24.04.2012 damir   - добавил if avail и glday = txb.glday.
       17.07.2012 damir   - добавил if avail crchis,выходила ошибка.
       24.09.2012 evseev - ТЗ-1368
       15/01/2013 Luiza  - добавила колонку код сегментации
       18.01.2013 evseev - ТЗ-1626
       01.02.2013 evseev - tz-1664
       02.07.2013 evseev - tz-1909
 */


def input parameter p-bank as char.
def shared var v-gllist  as char.
/******************************************************************************/
def buffer b-gl    for txb.gl.
def buffer b-lon   for txb.lon.
def buffer basecrc for txb.crchis.
def buffer crc2    for txb.crchis.
def buffer b-crc   for txb.crchis.
def buffer p-crc   for txb.crchis.

def shared var vasof  as date.
def shared var vasof2 like vasof.
def shared var v-crc  like txb.crc.crc.
def shared var vglacc as char format "x(6)".
def shared var v-withprc as logi.
def shared var v-withzero as logi.

def var v-in as logi.

def var glgl      like txb.gl.gl.
define var vbal as deci extent 4 format 'zzz,zzz,zzz,zz9.99-'.
def var vtitle-1  as   char format "x(110)".
def var v-bal     as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-balrate as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal2    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal2kzt as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal11   as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-opnamt    as   dec  format "zz,zzz,zzz,zzz.99-".
def var nullacc   as   log.

def var v-kurs like txb.crchis.rate[1]. /*переменная для курсов валют*/

def var nm as char.
def var ll as int.

{chbin_txb.i}
/******************************************************************************/
/*Временные таблицы*********************************************/
def shared temp-table t-gl /*временная таблица для сбора данных по счетам ГК*/
    field gl like txb.gl.gl /*счет ГК*/
    field des like txb.gl.des /*Название ГК*/
    index gl is primary unique gl.

def shared temp-table t-glcrc
    field gl like txb.gl.gl /*счет ГК*/
    field crc like txb.crc.crc /*Валюта*/
    field amt as dec format "zzz,zzz,zzz,zzz.99-" /*сумма в валюте счета, зависит от валюты*/
    field amtkzt as dec format "zzz,zzz,zzz,zzz.99-" /*Сумма в валюте счета конвертированная в тенге*/
    index gl is primary gl.

def shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
    field gl  like t-gl.gl  /*счет ГК*/
    field acc like txb.aaa.aaa  /*субсчет ГК*/
    field cif as char format "x(20)"  /*Название клиента*/
    field rnn as char format "x(12)"  /*Название клиента*/
    field geo as char format "x(3)"  /*ГЕО код*/
    field crc like t-glcrc.crc  /*валюта субсчета*/
    field ecdivis like txb.sub-cod.ccode /*сектор отраслей экономики клиента*/
    field secek like txb.sub-cod.ccode /*сектор экономики клиента*/
    field rdt like txb.aaa.regdt /*дата открытия счета*/
    field duedt like txb.arp.duedt /*дата закрытия счета*/

    field rdt1 as char /*пролонгация счета*/
    field duedt1 as char /*окончание действия счета*/

    field rate like txb.aaa.rate /*процентная ставка по счету, если есть*/

    field opnamt like t-glcrc.amt /*сумма по договору*/

    field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
    field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/
    field kurs like txb.crchis.rate[1] /*курс конвертации*/
    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field des as char /*остаток на 11-ом уровне*/
    field attrib as char /*признак bnkrel*/
    field uslov as char /*услоние обслуживания*/
    field osnov as char /*основание*/
    field clnsegm as char /* код сегментации */
    /*field krate like txb.accr.rate ставка по счету на день загрузки отчета*/
    index gl is primary gl.
/***************************************************************/

/*********************/
find last basecrc where basecrc.crc = v-crc and basecrc.rdt <= vasof no-lock no-error. /*находим курс выбранной валюты*/
if not avail basecrc then /*если курс не найден*/
    message v-crc vasof view-as alert-box.

find last txb.crchis where txb.crchis.crc = 1 and txb.crchis.rdt <= vasof no-lock no-error.
/*********************/
find first txb.cmp.

/*Сбор данных***********************************************************************************************************************************************************/
for each txb.gl where txb.gl.ibfact eq false and (vglacc = "" or string(txb.gl.gl) = vglacc) no-lock break by txb.gl.gl :
    if v-gllist <> "" and lookup(substr(string(txb.gl.gl),1,4),v-gllist) = 0 then next.
    /***************************************************************************************************************************************************************/
    /***************************************************************************************************************************************************************/
    nullacc = yes.
    find last txb.crchis where txb.crchis.crc = 1  and txb.crchis.rdt <= vasof no-lock no-error.
    find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = 1 and txb.glday.gdt <= vasof no-lock no-error.
    if avail txb.glday then vbal[1] = txb.glday.bal * basecrc.rate[9] / basecrc.rate[1].
    /* other currencies */
    vbal[3] = 0.
    vbal[2] = 0.
    vbal[4] = 0.
    /* ПРОВЕРИМ, НУЛЕВОЙ СЧЕТ ИЛИ НЕТ */
    if vbal[1] <> 0.0 then nullacc = no.
    for each txb.crc where txb.crc.crc >= 2 no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= vasof no-lock no-error.
        find last b-crc where b-crc.crc = txb.glday.crc  and b-crc.rdt <= vasof no-lock no-error.
        if avail txb.glday then do:
            vbal[2] = vbal[2] + txb.glday.bal.
            vbal[3] = vbal[3] + txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            if vbal[2] <> 0 or vbal[3] <> 0 then nullacc = no.
            vbal[2] = 0.
            vbal[3] = 0.
        end. /* avail glday */
    end. /* each crc */
    /*  if nullacc then next.*/
    /* КОНЕЦ ПОВЕРКИ - ЕСЛИ НУЛЕВОЙ, ТО ПЕРЕХОДИМ НА СЛЕД. СЧЕТ ГЛ.КНИГИ */
    if txb.gl.vadisp and txb.gl.gldisp then do:
        find first t-gl where t-gl.gl = txb.gl.gl no-error.
        if not avail t-gl then do:
            create t-gl.
            t-gl.gl = txb.gl.gl.
            t-gl.des = txb.gl.des.
        end.
        if vbal[1] <> 0.0 then do:
            find first t-glcrc where t-glcrc.gl = txb.gl.gl and t-glcrc.crc = 1 no-error.
            if not avail t-glcrc then do:
                create t-glcrc.
                t-glcrc.gl = txb.gl.gl.
                t-glcrc.crc = 1.
                t-glcrc.amt = vbal[1].
                t-glcrc.amtkzt = vbal[1].
            end.
            else do:
                t-glcrc.amt = t-glcrc.amt + vbal[1].
                t-glcrc.amtkzt = t-glcrc.amtkzt + vbal[1].
            end.
        end.
    end.
    vbal[4] = vbal[1].
    for each txb.crc where txb.crc.crc >= 2 no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= vasof no-lock no-error.
        if avail txb.glday then do:
            find last b-crc where b-crc.crc = txb.glday.crc and b-crc.rdt le vasof no-lock no-error.
            vbal[2] = vbal[2] + txb.glday.bal.
            vbal[3] = vbal[3] + txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            if vbal[2] <> 0 or vbal[3] <> 0 then do:
                    find first t-glcrc where t-glcrc.gl = txb.gl.gl and t-glcrc.crc = txb.glday.crc no-error.
                    if not avail t-glcrc then do:
                        create t-glcrc.
                        t-glcrc.gl = txb.gl.gl.
                        t-glcrc.crc = txb.glday.crc.
                        t-glcrc.amt = vbal[2].
                        t-glcrc.amtkzt = vbal[3].
                    end.
                    else do:
                        t-glcrc.amt = t-glcrc.amt + vbal[2].
                        t-glcrc.amtkzt = t-glcrc.amtkzt + vbal[3].
                    end.
            end.

            vbal[4] = vbal[4] + vbal[3].
            vbal[2] = 0.
            vbal[3] = 0.
        end. /* each glday */
    end. /* each crc */
    /***************************************************************************************************************************************************************/
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
        /*Является ли счет указанного ГК клиентским?*/
    if txb.gl.subled = 'cif' then do: /*да*/
        for each txb.aaa where txb.aaa.gl = txb.gl.gl /*and txb.aaa.sta <> "C"*/ no-lock break by txb.aaa.gl. /*найдем все не закрытые счета по этому ГК*/
            /*
            find last txb.aadrt where txb.aadrt.idclr = txb.aaa.aaa and txb.aadrt.who = "C" and txb.aadrt.whn < vasof no-lock no-error. /*находим когда закрыт счет*/
            if avail txb.aadrt then next.
            */
            find last txb.aab where txb.aab.fdt <= vasof and txb.aab.aaa = txb.aaa.aaa no-lock no-error. /*находим по ним остаток*/
            find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error. /*находим карточку клиента*/
            if avail txb.cif then do: /*если карточка есть...*/
                if not avail txb.aab then  /*... и не найден остаток*/
                    v-bal = 0. /*txb.aaa.cbal. то остаток берем из самого счета*/
                else  /*если остаток есть, то сохраняем его*/
                    v-bal = txb.aab.bal.
                run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"2",yes,txb.aaa.crc,output v-bal2).
                v-bal2 = - v-bal2.
                run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"11",yes,1,output v-bal11).
                v-bal11 = v-bal11.
                if txb.aaa.crc <> 1 then do: /*если валюта счета не тенге*/
                    find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= vasof no-lock no-error. /*ищем курс на заданную дату*/
                    if avail txb.crchis then do:
                        v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9]. /*получаем остаток в тенге*/
                        v-bal2kzt = v-bal2 * txb.crchis.rate[1] / txb.crchis.rate[9].
                        v-kurs    = txb.crchis.rate[1].
                    end.
                end.
                else do:
                    v-balrate = v-bal.  /*иначе если тенге, то остаток в тенге = равен остаток по балансу */
                    v-bal2kzt = v-bal2.
                    v-kurs = 1.
                end.

                v-opnamt = txb.aaa.opnamt.
                find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr and (txb.lgr.led = 'sav') no-lock no-error.
                if avail txb.lgr then do:
                   find first txb.jl where txb.jl.whn >= txb.aaa.regdt and  txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl and txb.jl.dc = 'c' no-lock no-error.
                   if avail txb.jl then v-opnamt = txb.jl.cam.
                end.

                /*если выбрано с нулевыми остатками*/
                if v-withzero then do:
                    find first t-acc where t-acc.gl = txb.gl.gl and t-acc.acc = txb.aaa.aaa and t-acc.cif = txb.cif.cif no-error.
                    if not avail t-acc then do:
                        create t-acc.
                        t-acc.gl = txb.gl.gl.
                        t-acc.acc = txb.aaa.aaa.
                        t-acc.geo = cif.geo.
                    end.
                    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                    if available txb.sub-cod then do:
                        if txb.sub-cod.ccode <> "msc" then do:
                            find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                            if avail txb.codfr then do:
                                ll = index(txb.codfr.name[1],"(").
                                if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                else t-acc.clnsegm = trim(txb.codfr.name[1]).
                            end.
                        end.
                    end.
                   /*  find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsts" and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
                    if avail txb.sub-cod then do:
                        if txb.sub-cod.ccode <> "1" then t-acc.cif = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                        else t-acc.cif = "".
                    end.
                    else */
                    t-acc.cif = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                    t-acc.rnn = txb.cif.bin.
                    /* t-acc.cif = txb.cif.cif.*/
                    t-acc.crc = txb.aaa.crc.
                    find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                    /*      31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel
                    + Изменены столбцы отчета:
                    - Сектор ОТРАСЛЕЙ экономики = sub-cod.d-cod = "ecdivis"
                    + Добавлены столбцы отчета:
                    - Сектор экономики = sub-cod.d-cod = "secek" */
                    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*сектор отраслей экономики*/
                    if avail txb.sub-cod then t-acc.ecdivis = txb.sub-cod.ccode.
                    else t-acc.ecdivis = "".
                    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*сектор экономики*/
                    if avail txb.sub-cod then t-acc.secek = txb.sub-cod.ccode.
                    /*      31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel */

                    /*15.12.2010*/
                    t-acc.uslov = ''.
                    t-acc.osnov = ''.
                    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnuoo" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*условия обслуживания и основание*/
                    if avail txb.sub-cod then do:
                       if txb.sub-cod.ccode = 'msc' then do:
                         t-acc.uslov = ''.
                         t-acc.osnov = ''.
                       end.
                       else do:
                         /*t-acc.osnov =  entry(1, txb.sub-cod.rcode ,'^') + ' ' + entry(2, txb.sub-cod.rcode ,'^') + ' ' + string(entry(3, txb.sub-cod.rcode ,'^'), '99/99/9999').*/
                         t-acc.osnov = replace(txb.sub-cod.rcode,'^',' ').
                         find txb.codfr where txb.codfr.codfr = "clnuoo" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                         if avail txb.codfr then do:
                           t-acc.uslov = txb.codfr.name[1].
                         end.
                       end.
                    end.
                    /*      15.12.2010*/

                    t-acc.des  = txb.lgr.des.
                    assign t-acc.rdt = txb.aaa.regdt
                    t-acc.duedt = txb.aaa.expdt
                    /*t-acc.rate = txb.aaa.rate*/
                    t-acc.opnamt = v-opnamt
                    t-acc.amt = v-bal
                    t-acc.amtkzt = v-balrate
                    t-acc.kurs = v-kurs
                    t-acc.lev2 = v-bal2
                    t-acc.lev2kzt = v-bal2kzt
                    t-acc.lev11 = v-bal11
                    t-acc.fil = txb.cmp.name.

                    t-acc.rdt1 = "".
                    t-acc.duedt1 = "".
                    find first txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                    if avail txb.acvolt then do:
                       if date(txb.acvolt.x1) <> txb.aaa.regdt then do:
                          t-acc.rdt1 = string(date(txb.acvolt.x1),"99/99/9999").
                          t-acc.duedt1 = string(date(txb.acvolt.x3),"99/99/9999").
                       end.
                    end.

                    if txb.cif.bin <> '' then do:
                        find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                        if avail prisv then do:
                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                        end.

                        /*else t-acc.attrib = "Не связанное лицо".*/
                        else do:
                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                        if avail prisv then do:
                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                        end.
                        else t-acc.attrib = "Не связанное лицо".
                        end.
                    end.
                    if txb.cif.bin = '' then do:
                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                        if avail prisv then do:
                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                        end.
                        else t-acc.attrib = "Не связанное лицо".
                    end.
                    find last txb.accr where txb.accr.aaa = txb.aaa.aaa and txb.accr.fdt <= vasof no-lock no-error.
                    if avail txb.accr then t-acc.rate = txb.accr.rate.
                    find last txb.compens where txb.compens.acc = txb.aaa.aaa no-lock no-error.
                    if avail txb.compens then do:
                       t-acc.rate = txb.aaa.rate.
                    end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
                end.
                else do: /*без 0 остатков*/
                    v-in = no.
                    if v-bal <> 0.0 then v-in = yes.
                    else do:
                        if v-withprc then
                            if (v-bal2 > 0) or (v-bal11 > 0) then v-in = yes.
                    end.
                    if v-in then do: /*если остаток(-ки) не ноль*/ /*идем дальше*/
                        find first t-acc where t-acc.gl = txb.gl.gl and t-acc.acc = txb.aaa.aaa and t-acc.cif = txb.cif.cif no-error.
                        if not avail t-acc then do:
                            create t-acc.
                            t-acc.gl = txb.gl.gl.
                            t-acc.acc = txb.aaa.aaa.
                            t-acc.geo = cif.geo.
                        end.
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end.
                       /*  find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsts" and txb.sub-cod.acc = txb.cif.cif no-lock no-error.
                        if avail txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "1" then t-acc.cif = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                            else t-acc.cif = "".
                        end.
                        else */
                        t-acc.cif = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                        t-acc.rnn = txb.cif.bin.
                        /* t-acc.cif = txb.cif.cif.*/
                        t-acc.crc = txb.aaa.crc.
                        find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                        /*      31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel
                        + Изменены столбцы отчета:
                        - Сектор ОТРАСЛЕЙ экономики = sub-cod.d-cod = "ecdivis"
                        + Добавлены столбцы отчета:
                        - Сектор экономики = sub-cod.d-cod = "secek" */
                        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*сектор отраслей экономики*/
                        if avail txb.sub-cod then t-acc.ecdivis = txb.sub-cod.ccode.
                        else t-acc.ecdivis = "".
                        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*сектор экономики*/
                        if avail txb.sub-cod then t-acc.secek = txb.sub-cod.ccode.
                        /*      31.05.2010 id00024 + изменена форма вывода документа пользователю - выводится в Excel */

                        /*15.12.2010*/
                        t-acc.uslov = ''.
                        t-acc.osnov = ''.
                        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnuoo" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*условия обслуживания и основание*/
                        if avail txb.sub-cod then do:
                           if txb.sub-cod.ccode = 'msc' then do:
                             t-acc.uslov = ''.
                             t-acc.osnov = ''.
                           end.
                           else do:
                             /*t-acc.osnov =  entry(1, txb.sub-cod.rcode ,'^') + ' ' + entry(2, txb.sub-cod.rcode ,'^') + ' ' + string(entry(3, txb.sub-cod.rcode ,'^'), '99/99/9999').*/
                             t-acc.osnov = replace(txb.sub-cod.rcode,'^',' ').
                             find txb.codfr where txb.codfr.codfr = "clnuoo" and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                             if avail txb.codfr then do:
                               t-acc.uslov = txb.codfr.name[1].
                             end.
                           end.
                        end.
                        /*      15.12.2010*/

                        t-acc.des  = txb.lgr.des.
                        assign t-acc.rdt = txb.aaa.regdt
                        t-acc.duedt = txb.aaa.expdt
                        /*t-acc.rate = txb.aaa.rate*/
                        t-acc.opnamt = v-opnamt
                        t-acc.amt = v-bal
                        t-acc.amtkzt = v-balrate
                        t-acc.kurs = v-kurs
                        t-acc.lev2 = v-bal2
                        t-acc.lev2kzt = v-bal2kzt
                        t-acc.lev11 = v-bal11
                        t-acc.fil = txb.cmp.name.

                        t-acc.rdt1 = "".
                        t-acc.duedt1 = "".
                        find first txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                        if avail txb.acvolt then do:
                           if date(txb.acvolt.x1) <> txb.aaa.regdt then do:
                              t-acc.rdt1 = string(date(txb.acvolt.x1),"99/99/9999").
                              t-acc.duedt1 = string(date(txb.acvolt.x3),"99/99/9999").
                           end.
                        end.

                        if txb.cif.bin <> '' then do:
                            find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.

                            /*else t-acc.attrib = "Не связанное лицо".*/
                            else do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        if txb.cif.bin = '' then do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                        end.
                        find last txb.accr where txb.accr.aaa = txb.aaa.aaa and txb.accr.fdt <= vasof no-lock no-error.
                        if avail txb.accr then t-acc.rate = txb.accr.rate.
                        find last txb.compens where txb.compens.acc = txb.aaa.aaa no-lock no-error.
                        if avail txb.compens then do:
                           t-acc.rate = txb.aaa.rate.
                        end.
                        find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa and txb.acvolt.x7 <> 100 no-lock no-error.
                        if avail txb.acvolt then do:
                           t-acc.rate = txb.aaa.rate.
                        end.

                        message p-bank t-acc.acc txb.gl.gl. pause 0.
                    end.
                end.
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли счет Указанного ГК Внутренним транзитным счетом*/
    if txb.gl.subled = 'ARP' then do:
        for each txb.arp where txb.arp.gl eq txb.gl.gl no-lock break  by txb.arp.gl by txb.arp.crc:
            find last txb.hisarp where txb.hisarp.arp = txb.arp.arp and txb.hisarp.fdt <= vasof no-lock no-error.
            if txb.gl.type eq "A" then do:
                if not avail txb.hisarp then
                    v-bal = txb.arp.dam[1] - txb.arp.cam[1].
                else
                    v-bal = txb.hisarp.dam[1] - txb.hisarp.cam[1].
            end.
            else do:
                if not avail txb.hisarp then v-bal = txb.arp.cam[1] - txb.arp.dam[1].
                else v-bal = txb.hisarp.cam[1] - txb.hisarp.dam[1].
            end.
            if txb.arp.crc ne 1 then do:
                find last txb.crchis where txb.crchis.crc eq txb.arp.crc and txb.crchis.rdt le vasof no-lock no-error.
                if avail txb.crchis then do:
                    v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                    v-kurs = txb.crchis.rate[1].
                end.
            end.
            else do:
                v-balrate = v-bal.
                v-kurs = 1.
            end.
            if v-withzero then do:
                create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.arp.arp.
                    t-acc.cif = txb.arp.des.
                    t-acc.crc = txb.arp.crc.
                    t-acc.ecdivis = "".
                    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                    if avail txb.sub-cod then t-acc.secek = txb.sub-cod.ccode.
                    else t-acc.secek = "".
                    t-acc.secek = txb.sub-cod.ccode.
                    t-acc.rdt = txb.arp.rdt.
                    t-acc.duedt = txb.arp.duedt.
                    t-acc.rate = 0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.

                    find first txb.cif where txb.cif.cif = txb.arp.des no-lock no-error.
                    if avail txb.cif then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end. /* if available txb.sub-cod */
                        if txb.cif.bin <> '' then do:
                            find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.

                            /*else t-acc.attrib = "Не связанное лицо".*/
                            else do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        if txb.cif.bin = '' then do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and  txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                        end.
                    end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
            end.
            else do:
                if  v-bal <> 0 then do:
                    create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.arp.arp.
                    t-acc.cif = txb.arp.des.
                    t-acc.crc = txb.arp.crc.
                    t-acc.ecdivis = "".
                    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                    if avail txb.sub-cod then t-acc.secek = txb.sub-cod.ccode.
                    else t-acc.secek = "".
                    t-acc.secek = txb.sub-cod.ccode.
                    t-acc.rdt = txb.arp.rdt.
                    t-acc.duedt = txb.arp.duedt.
                    t-acc.rate = 0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.

                    find first txb.cif where txb.cif.cif = txb.arp.des no-lock no-error.
                    if avail txb.cif then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end. /* if available txb.sub-cod */
                        if txb.cif.bin <> '' then do:
                            find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.

                            /*else t-acc.attrib = "Не связанное лицо".*/
                            else do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        if txb.cif.bin = '' then do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and  txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                        end.
                    end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
                end.
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли указанный ГК Счетом доходов/расходов*/
    if txb.gl.subled = 'eps' then do:
        for each txb.eps where txb.eps.gl = txb.gl.gl no-lock break by txb.eps.gl.
            if txb.gl.type eq "A" then v-bal = txb.eps.dam[1] - txb.eps.cam[1].
            else v-bal = txb.eps.cam[1] - txb.eps.dam[1].
            if txb.eps.crc ne 1 then do:
                find last txb.crchis where txb.crchis.crc eq txb.eps.crc and txb.crchis.rdt le vasof no-lock no-error.
                if avail txb.crchis then do:
                    v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                    v-kurs = txb.crchis.rate[1].
                end.
            end.
            else do:
                v-balrate = v-bal.
                v-kurs = 1.
            end.
            if v-withzero then do:
                create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.eps.eps.
                    t-acc.cif = txb.eps.des.
                    t-acc.crc = txb.eps.crc.
                    t-acc.ecdivis = "".
                    t-acc.rdt = txb.eps.rdt.
                    t-acc.duedt = ?.
                    t-acc.rate = 0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.
                    /*
                    find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.eps.des no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                    */
                    find first txb.cif where txb.cif.cif = txb.eps.des no-lock no-error.
                    if avail txb.cif then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end. /* if available txb.sub-cod */
                        if txb.cif.bin <> '' then do:
                            find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.

                            /*else t-acc.attrib = "Не связанное лицо".*/
                            else do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        if txb.cif.bin = '' then do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                        end.
                    end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
            end.
            else do:
                if v-bal ne 0 then do:
                    create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.eps.eps.
                    t-acc.cif = txb.eps.des.
                    t-acc.crc = txb.eps.crc.
                    t-acc.ecdivis = "".
                    t-acc.rdt = txb.eps.rdt.
                    t-acc.duedt = ?.
                    t-acc.rate = 0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.
                    /*
                    find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.eps.des no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                    */
                    find first txb.cif where txb.cif.cif = txb.eps.des no-lock no-error.
                    if avail txb.cif then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end. /* if available txb.sub-cod */
                        if txb.cif.bin <> '' then do:
                            find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.

                            /*else t-acc.attrib = "Не связанное лицо".*/
                            else do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        if txb.cif.bin = '' then do:
                            if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                            if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                            find first prisv where trim(prisv.name) = nm no-lock no-error.
                            if avail prisv then do:
                                 find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                 if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                 if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                            end.
                            else t-acc.attrib = "Не связанное лицо".
                        end.
                    end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
                end.
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли указанный ГК Казначейским счетом*/
    if txb.gl.subled = 'fun' then do:
        for each txb.fun where txb.fun.gl = txb.gl.gl no-lock break by txb.fun.gl.
            find last txb.hisfun where txb.hisfun.fun = txb.fun.fun and txb.hisfun.fdt <= vasof no-lock no-error.
            find txb.bankl where txb.bankl.bank = txb.fun.bank no-lock no-error.
            if avail txb.bankl then do:
                if txb.gl.type eq "A" then do:
                    if avail txb.hisfun then v-bal = txb.hisfun.dam[1] - txb.hisfun.cam[1].
                    else v-bal = txb.fun.dam[1] - txb.fun.cam[1].
                end.
                else do:
                    if avail txb.hisfun then v-bal = txb.hisfun.cam[1] - txb.hisfun.dam[1].
                    else v-bal = txb.fun.cam[1] - txb.fun.dam[1].
                end.
                if txb.fun.crc ne 1 then do:
                    find last txb.crchis where txb.crchis.crc = txb.fun.crc and txb.crchis.rdt <= vasof no-lock no-error.
                    if avail txb.crchis then do:
                        v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                        v-kurs = txb.crchis.rate[1].
                    end.
                end.
                else do:
                    v-balrate = v-bal.
                    v-kurs = 1.
                end.
                if v-withzero then do:
                    create t-acc.
                        t-acc.gl = txb.gl.gl.
                        t-acc.acc = txb.fun.fun.
                        t-acc.cif = txb.bankl.name.
                        t-acc.crc = txb.fun.crc.
                        t-acc.ecdivis = "".
                        t-acc.rdt = txb.fun.rdt.
                        t-acc.duedt = txb.fun.duedt.
                        t-acc.rate =0.
                        t-acc.opnamt = 0.
                        t-acc.amt = v-bal.
                        t-acc.amtkzt = v-balrate.
                        t-acc.kurs = v-kurs.
                        t-acc.fil = txb.cmp.name.
                        /*
                        find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.bankl.name no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                        */
                        find first txb.cif where txb.cif.cif = txb.bankl.name no-lock no-error.
                        if avail txb.cif then do:
                        find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                        if available txb.sub-cod then do:
                            if txb.sub-cod.ccode <> "msc" then do:
                                find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                if avail txb.codfr then do:
                                    ll = index(txb.codfr.name[1],"(").
                                    if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                    else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                end.
                            end.
                        end. /* if available txb.sub-cod */
                            if txb.cif.bin <> '' then do:
                                find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.

                                /*else t-acc.attrib = "Не связанное лицо".*/
                                else do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                                end.
                            end.
                            if txb.cif.bin = '' then do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        message p-bank t-acc.acc txb.gl.gl. pause 0.
                end.
                else do:
                    if v-bal <> 0 then do:
                        create t-acc.
                        t-acc.gl = txb.gl.gl.
                        t-acc.acc = txb.fun.fun.
                        t-acc.cif = txb.bankl.name.
                        t-acc.crc = txb.fun.crc.
                        t-acc.ecdivis = "".
                        t-acc.rdt = txb.fun.rdt.
                        t-acc.duedt = txb.fun.duedt.
                        t-acc.rate =0.
                        t-acc.opnamt = 0.
                        t-acc.amt = v-bal.
                        t-acc.amtkzt = v-balrate.
                        t-acc.kurs = v-kurs.
                        t-acc.fil = txb.cmp.name.
                        /*
                        find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.bankl.name no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                        */
                        find first txb.cif where txb.cif.cif = txb.bankl.name no-lock no-error.
                        if avail txb.cif then do:
                            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                            if available txb.sub-cod then do:
                                if txb.sub-cod.ccode <> "msc" then do:
                                    find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                    if avail txb.codfr then do:
                                        ll = index(txb.codfr.name[1],"(").
                                        if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                        else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                    end.
                                end.
                            end. /* if available txb.sub-cod */
                            if txb.cif.bin <> '' then do:
                                find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.

                                /*else t-acc.attrib = "Не связанное лицо".*/
                                else do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                                end.
                            end.
                            if txb.cif.bin = '' then do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                        message p-bank t-acc.acc txb.gl.gl. pause 0.
                    end.
                end.
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли указанный счет Корреспондентским?*/
    if txb.gl.subled = 'dfb' then do:
        for each txb.dfb where txb.dfb.gl = txb.gl.gl no-lock break by txb.dfb.gl.
            find last txb.hisdfb where txb.hisdfb.dfb = txb.dfb.dfb and txb.hisdfb.fdt <= vasof no-lock no-error.
            if txb.gl.type eq "A" then do:
                if avail txb.hisdfb then v-bal = txb.hisdfb.dam[1] - txb.hisdfb.cam[1].
                else v-bal = txb.dfb.dam[1] - txb.dfb.cam[1].
            end.
            else do:
                if avail txb.hisdfb then v-bal = txb.hisdfb.cam[1] - txb.hisdfb.dam[1].
                else v-bal = txb.dfb.cam[1] - txb.dfb.dam[1].
            end.
            if txb.dfb.crc <> 1 then do:
                find last txb.crchis where txb.crchis.crc eq txb.dfb.crc and txb.crchis.rdt le vasof no-lock no-error.
                if avail txb.crchis then do:
                    v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                    v-kurs = txb.crchis.rate[1].
                end.
            end.
            else do:
                v-balrate = v-bal.
                v-kurs = 1.
            end.
            if v-withzero then do:
                create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.dfb.dfb.
                    t-acc.cif = txb.dfb.name.
                    t-acc.crc = txb.dfb.crc.
                    t-acc.ecdivis = "".
                    t-acc.rdt = txb.dfb.rdt.
                    t-acc.duedt = txb.dfb.duedt.
                    t-acc.rate =0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.
                    /*
                    find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.dfb.name no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                    */
                    find first txb.cif where txb.cif.cif = txb.dfb.name no-lock no-error.
                        if avail txb.cif then do:
                            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                            if available txb.sub-cod then do:
                                if txb.sub-cod.ccode <> "msc" then do:
                                    find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                    if avail txb.codfr then do:
                                        ll = index(txb.codfr.name[1],"(").
                                        if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                        else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                    end.
                                end.
                            end. /* if available txb.sub-cod */
                            if txb.cif.bin <> '' then do:
                                find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.

                                /*else t-acc.attrib = "Не связанное лицо".*/
                                else do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                                end.
                            end.
                            if txb.cif.bin = '' then do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
            end.
            else do:
                if v-bal ne 0 then do:
                    create t-acc.
                    t-acc.gl = txb.gl.gl.
                    t-acc.acc = txb.dfb.dfb.
                    t-acc.cif = txb.dfb.name.
                    t-acc.crc = txb.dfb.crc.
                    t-acc.ecdivis = "".
                    t-acc.rdt = txb.dfb.rdt.
                    t-acc.duedt = txb.dfb.duedt.
                    t-acc.rate =0.
                    t-acc.opnamt = 0.
                    t-acc.amt = v-bal.
                    t-acc.amtkzt = v-balrate.
                    t-acc.kurs = v-kurs.
                    t-acc.fil = txb.cmp.name.
                    /*
                    find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.dfb.name no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode  no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                    */
                    find first txb.cif where txb.cif.cif = txb.dfb.name no-lock no-error.
                        if avail txb.cif then do:
                            find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                            if available txb.sub-cod then do:
                                if txb.sub-cod.ccode <> "msc" then do:
                                    find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                    if avail txb.codfr then do:
                                        ll = index(txb.codfr.name[1],"(").
                                        if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                        else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                    end.
                                end.
                            end. /* if available txb.sub-cod */
                            if txb.cif.bin <> '' then do:
                                find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.

                                /*else t-acc.attrib = "Не связанное лицо".*/
                                else do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                                end.
                            end.
                            if txb.cif.bin = '' then do:
                                if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                find first prisv where trim(prisv.name) = nm no-lock no-error.
                                if avail prisv then do:
                                     find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                     if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                     if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                end.
                                else t-acc.attrib = "Не связанное лицо".
                            end.
                        end.
                    message p-bank t-acc.acc txb.gl.gl. pause 0.
                end.
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли указанный счет КГ Кредитным счетом?*/
    if txb.gl.subled = 'lon' then do:
        glgl = txb.gl.gl.
        if txb.gl.gl = 142410 or txb.gl.gl = 142710 then glgl = 141110.
        for each txb.lon where txb.lon.gl = glgl no-lock break by txb.lon.gl.
            find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                if avail txb.cif then do:

                    if txb.gl.gl <> 142410 and txb.gl.gl <> 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                        if not avail histrxbal then do:
                            find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon and txb.trxbal.level = 1 no-lock no-error.
                        end.
                    if txb.gl.gl = 142410 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 7 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                        if not avail histrxbal then do:
                            find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon and txb.trxbal.level = 7 no-lock no-error.
                        end.

                    if txb.gl.gl = 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 8 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                        if not avail histrxbal then do:
                            find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon and txb.trxbal.level = 8 no-lock no-error.
                        end.

                    if avail txb.histrxbal or avail txb.trxbal then do:
                        if txb.gl.type eq "A" then
                            if avail txb.histrxbal then v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                            else
                                if avail txb.trxbal then v-bal = txb.trxbal.dam - txb.trxbal.cam.
                                else
                                    if avail txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                                    else
                                        if avail txb.trxbal then v-bal = txb.trxbal.cam - txb.trxbal.dam.
                        if txb.lon.crc ne 1 then do:
                            find last txb.crchis where txb.crchis.crc eq txb.lon.crc and txb.crchis.rdt le vasof no-lock no-error.
                            if avail txb.crchis then do:
                                v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                                v-kurs = txb.crchis.rate[1].
                            end.
                        end.
                        else do:
                            v-balrate = v-bal.
                            v-kurs = 1.
                        end.

                        if v-withzero then do:
                            create t-acc.
                                t-acc.gl = txb.gl.gl.
                                t-acc.acc = txb.lon.lon.
                                t-acc.cif = trim(trim(cif.prefix) + " " + trim(cif.name)).
                                t-acc.rnn = txb.cif.bin.
                                t-acc.crc = txb.lon.crc.
                                find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.lon.cif no-lock no-error. /*сектор экономики*/
                                if avail txb.sub-cod then t-acc.ecdivis = txb.sub-cod.ccod.
                                else t-acc.ecdivis = "".
                                t-acc.rdt = txb.lon.rdt.
                                t-acc.duedt = txb.lon.duedt.
                                t-acc.rate =lon.prem.
                                t-acc.opnamt = txb.lon.opnamt.
                                t-acc.amt = v-bal.
                                t-acc.amtkzt = v-balrate.
                                t-acc.kurs = v-kurs.
                                t-acc.fil = txb.cmp.name.
                                /*
                                find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.lon.cif no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                                */
                                find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                                if avail txb.cif then do:
                                    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                                    if available txb.sub-cod then do:
                                        if txb.sub-cod.ccode <> "msc" then do:
                                            find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                            if avail txb.codfr then do:
                                                ll = index(txb.codfr.name[1],"(").
                                                if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                                else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                            end.
                                        end.
                                    end. /* if available txb.sub-cod */
                                    if txb.cif.bin <> '' then do:
                                        find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.

                                        /*else t-acc.attrib = "Не связанное лицо".*/
                                        else do:
                                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.
                                        else t-acc.attrib = "Не связанное лицо".
                                        end.
                                    end.
                                    if txb.cif.bin = '' then do:
                                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.
                                        else t-acc.attrib = "Не связанное лицо".
                                    end.
                                end.
                                message p-bank t-acc.acc txb.gl.gl. pause 0.
                        end.
                        else do:
                            if v-bal ne 0 then do:
                                create t-acc.
                                t-acc.gl = txb.gl.gl.
                                t-acc.acc = txb.lon.lon.
                                t-acc.cif = trim(trim(cif.prefix) + " " + trim(cif.name)).
                                t-acc.rnn = txb.cif.bin.
                                t-acc.crc = txb.lon.crc.
                                find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.lon.cif no-lock no-error. /*сектор экономики*/
                                if avail txb.sub-cod then t-acc.ecdivis = txb.sub-cod.ccod.
                                else t-acc.ecdivis = "".
                                t-acc.rdt = txb.lon.rdt.
                                t-acc.duedt = txb.lon.duedt.
                                t-acc.rate =lon.prem.
                                t-acc.opnamt = txb.lon.opnamt.
                                t-acc.amt = v-bal.
                                t-acc.amtkzt = v-balrate.
                                t-acc.kurs = v-kurs.
                                t-acc.fil = txb.cmp.name.
                                /*
                                find first txb.sub-cod where txb.sub-cod.d-cod = "bnkrel" and txb.sub-cod.acc = txb.lon.cif no-lock no-error.
                                if avail txb.sub-cod then do:
                                    find first txb.codfr where txb.codfr.codfr = "bnkrel" and txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                    if avail codfr then t-acc.attrib = txb.codfr.name[1].
                                end.
                                */
                                find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
                                if avail txb.cif then do:
                                    find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clnsegm" no-lock no-error.
                                    if available txb.sub-cod then do:
                                        if txb.sub-cod.ccode <> "msc" then do:
                                            find first txb.codfr where txb.codfr.codfr = 'clnsegm' and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
                                            if avail txb.codfr then do:
                                                ll = index(txb.codfr.name[1],"(").
                                                if ll > 0 then t-acc.clnsegm = substring(txb.codfr.name[1],1,ll - 1).
                                                else t-acc.clnsegm = trim(txb.codfr.name[1]).
                                            end.
                                        end.
                                    end. /* if available txb.sub-cod */
                                    if txb.cif.bin <> '' then do:
                                        find first prisv where prisv.rnn = txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.

                                        /*else t-acc.attrib = "Не связанное лицо".*/
                                        else do:
                                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.
                                        else t-acc.attrib = "Не связанное лицо".
                                        end.
                                    end.
                                    if txb.cif.bin = '' then do:
                                        if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                                        if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                                        find first prisv where trim(prisv.name) = nm no-lock no-error.
                                        if avail prisv then do:
                                             find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                                             if avail txb.codfr then t-acc.attrib = txb.codfr.name[1].
                                             if not avail txb.codfr then t-acc.attrib = 'Нет такого справочника'.
                                        end.
                                        else t-acc.attrib = "Не связанное лицо".
                                    end.
                                end.
                                message p-bank t-acc.acc txb.gl.gl. pause 0.
                            end.
                        end.
                    end.
                end.
        end.
    end.
    /***************************************************************************************************************************************************************/
end. /*for each gl*/
/*Окончание сбора данных************************************************************************************************************************************************/
hide all.

