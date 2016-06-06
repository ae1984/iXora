/* o-salde1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	    Оборотно-сальдовая ведомость, развернутая с остатками по субсчетам
		консолидированная
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	o-salde.p
 * MENU
        Перечень пунктов Меню Прагмы
	12-15
 * AUTHOR
       15/07/10 aigul - на основе r-salde.p
 * CHANGES
       15/07/10 aigul - создание отчета на основе r-salde.p
       04/08/2010 galina - выводим в отчет кредиты если есть остатки на 11 или 12 уровне
       07.10.2011 aigul - добавила вывод новых валют
       08.10.2013 dmitriy - ТЗ 1913
 * BASES
     TXB BANK
*/



def input parameter p-bank as char.
/******************************************************************************/
def buffer b-gl    for txb.gl.
def buffer b-lon   for txb.lon.
def buffer basecrc for txb.crchis.
def buffer crc2    for txb.crchis.
def buffer b-crc   for txb.crchis.
def buffer p-crc   for txb.crchis.
DEF VAR VBANK AS CHAR.
def shared var vasof  as date.
def shared var vasof2 like vasof.

def shared var vasof_f  as date.
def shared var vasof_f2 like vasof_f.


def shared var v-crc  like txb.crc.crc.
def shared var vglacc as char format "x(6)".
def shared var v-withprc as logi.

def var v-in as logi.
def var v-lev as integer.


def var glgl      like txb.gl.gl.
define var vbal as deci extent 4 format 'zzz,zzz,zzz,zz9.99-'.
def var vtitle-1  as   char format "x(110)".
def var v-bal     as   dec  format "zz,zzz,zzz,zzz.99-".

def var v-bal_f   as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-count     as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-sum     as   dec  format "zz,zzz,zzz,zzz.99-".


def var v-cbal     as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-dbal     as   dec  format "zz,zzz,zzz,zzz.99-".


def var v-cbalrate as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-dbalrate as   dec  format "zz,zzz,zzz,zzz.99-".

def var v-balrate as   dec  format "zz,zzz,zzz,zzz.99-".

def var v-balrate_f as   dec  format "zz,zzz,zzz,zzz.99-".

def var v-bal2    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal2kzt as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal11   as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal12   as   dec  format "zz,zzz,zzz,zzz.99-".

def var v-bal2_f    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal2kzt_f as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal11_f   as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal12_f   as   dec  format "zz,zzz,zzz,zzz.99-".
def var nullacc   as   log.

def var v-kurs like txb.crchis.rate[1]. /*переменная для курсов валют*/
def var v-kurs_f like txb.crchis.rate[1].


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

    field amt_f as dec format "zzz,zzz,zzz,zzz.99-"
	field amtkzt_f as dec format "zzz,zzz,zzz,zzz.99-"
    field dam as dec format "zzz,zzz,zzz,zzz.99-"
    field cam as dec format "zzz,zzz,zzz,zzz.99-"
	field damkzt as dec format "zzz,zzz,zzz,zzz.99-"
    field camkzt as dec format "zzz,zzz,zzz,zzz.99-"

    index gl is primary gl.

def shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
    field gl  like t-gl.gl  /*счет ГК*/
    field acc like txb.aaa.aaa  /*субсчет ГК*/
    field cif as char format "x(20)"  /*Название клиента*/
    field cifname as char /*Наименование клиента*/
    field geo as char format "x(3)"  /*ГЕО код*/
    field crc like t-glcrc.crc  /*валюта субсчета*/
    field ecdivis like txb.sub-cod.ccode /*сектор отраслей экономики клиента*/
    field secek like txb.sub-cod.ccode /*сектор экономики клиента*/
    field rdt like txb.aaa.regdt /*дата открытия счета*/
    field duedt like txb.arp.duedt /*дата закрытия счета*/
    field rate like txb.aaa.rate /*процентная ставка по счету, если есть*/
    field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
    field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/

    field amt_f like t-glcrc.amt_f
	field amtkzt_f like t-glcrc.amtkzt_f
    field dam like t-glcrc.dam
	field damkzt like t-glcrc.damkzt
    field cam like t-glcrc.cam
	field camkzt like t-glcrc.camkzt
    field banks as char
    field v-level as integer


    field kurs like txb.crchis.rate[1] /*курс конвертации*/
    field kurs_f like txb.crchis.rate[1] /*курс конвертации*/
    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field lev12 as deci
    field lev2_f as deci /*остаток на 2-ом уровне*/
    field lev2kzt_f as deci /*остаток на 2-ом уровне в kzt*/
    field lev11_f as deci /*остаток на 11-ом уровне*/
    field lev12_f as deci
    field des as char /*остаток на 11-ом уровне*/
    field kurs_d as deci
    index gl is primary gl.
/***************************************************************/

/*********************/
find last basecrc where basecrc.crc = v-crc and basecrc.rdt <= vasof no-lock no-error. /*находим курс выбранной валюты*/

if not avail basecrc then /*если курс не найден*/
    message v-crc vasof view-as alert-box.

/* first date */
find last basecrc where basecrc.crc = v-crc and basecrc.rdt <= vasof_f no-lock no-error. /*находим курс выбранной валюты*/

if not avail basecrc then /*если курс не найден*/
    message v-crc vasof_f view-as alert-box.
/**************/

find last txb.crchis where txb.crchis.crc = 1 and txb.crchis.rdt <= vasof no-lock no-error.

find last txb.crchis where txb.crchis.crc = 1 and txb.crchis.rdt <= vasof_f no-lock no-error.
/*********************/
find first txb.cmp.

FIND FIRST TXB.SYSC WHERE TXB.SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
    IF AVAIL TXB.SYSC AND TXB.SYSC.CHVAL <> '' THEN VBANK =  TXB.SYSC.CHVAL.


/*Сбор данных***********************************************************************************************************************************************************/
for each txb.gl where txb.gl.ibfact eq false and (vglacc = "" or string(txb.gl.gl) = vglacc) no-lock break by txb.gl.gl :


/***************************************************************************************************************************************************************/
/***************************************************************************************************************************************************************/
nullacc = yes.
    find last txb.crchis where txb.crchis.crc = 1  and txb.crchis.rdt <= vasof no-lock no-error.
    find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = 1 and txb.glday.gdt <= vasof no-lock no-error.
        vbal[1] = txb.glday.bal * basecrc.rate[9] / basecrc.rate[1].
        /* other currencies */
        vbal[3] = 0.
        vbal[2] = 0.
        vbal[4] = 0.
        /* ПРОВЕРИМ, НУЛЕВОЙ СЧЕТ ИЛИ НЕТ */
        if vbal[1] <> 0.0 then
            nullacc = no.
    for each txb.crc where txb.crc.crc >= 2 no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= vasof no-lock no-error.
        find last b-crc where b-crc.crc = glday.crc  and b-crc.rdt <= vasof no-lock no-error.
            if avail txb.glday then do:
                vbal[2] = vbal[2] + txb.glday.bal.
                vbal[3] = vbal[3] + txb.glday.bal * (b-crc.rate[1] * basecrc.rate[9] / (basecrc.rate[1] * b-crc.rate[9])).
            if vbal[2] <> 0 or vbal[3] <> 0 then nullacc = no.
                vbal[2] = 0.
                vbal[3] = 0.
            end. /* avail glday */
            end. /* each crc */
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
    end.
    vbal[4] = vbal[1].
    for each txb.crc where txb.crc.crc >= 2 no-lock:
        find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= vasof no-lock no-error.
            if avail txb.glday then do:
                find last b-crc where b-crc.crc = glday.crc and b-crc.rdt le vasof no-lock no-error.
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
    if txb.gl.subled = 'cif' then do:
        for each txb.aaa where txb.aaa.gl = txb.gl.gl no-lock:

            find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif then do:
                    /* first date */
                    v-bal_f = 0.
                    find last txb.histrxbal where txb.histrxbal.subled = 'cif' and txb.histrxbal.acc = txb.aaa.aaa
                    and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.aaa.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.

                            if txb.gl.type eq "A" then do:
                                if avail txb.histrxbal then
                                v-bal_f = txb.histrxbal.dam - txb.histrxbal.cam.
                            end.
                            else do:
                                if avail txb.histrxbal then
                                v-bal_f = txb.histrxbal.cam - txb.histrxbal.dam.
                            end.
                            /*
                            run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"2",yes,txb.aaa.crc,output v-bal2).
                            v-bal2 = - v-bal2.
                            run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"11",yes,1,output v-bal11).
                            v-bal11 = v-bal11.
                            */
                            find last txb.crchis where txb.crchis.crc eq txb.aaa.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                            if avail txb.crchis then do:
                                v-balrate_f = v-bal_f * txb.crchis.rate[1] / txb.crchis.rate[9].
                                v-bal2kzt = v-bal2 * txb.crchis.rate[1] / txb.crchis.rate[9].
                            end.


                    /* second date */
                    v-bal = 0.
                    find last txb.histrxbal where txb.histrxbal.subled = 'cif' and txb.histrxbal.acc = txb.aaa.aaa
                    and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.aaa.crc and txb.histrxbal.dt <= vasof  no-lock no-error.

                            if txb.gl.type eq "A" then do:
                                if avail txb.histrxbal then
                                    v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                            end.
                            else do:
                                if avail txb.histrxbal then
                                    v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                            end.
                            /*
                            run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"2",yes,txb.aaa.crc,output v-bal2).
                            v-bal2 = - v-bal2.
                            run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"11",yes,1,output v-bal11).
                            v-bal11 = v-bal11.
                            */
                            find last txb.crchis where txb.crchis.crc eq txb.aaa.crc and txb.crchis.rdt <= vasof no-lock no-error.
                            if avail txb.crchis then do:
                                v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
                                v-bal2kzt = v-bal2 * txb.crchis.rate[1] / txb.crchis.rate[9].
                            end.

                    /*Обороты */
                    v-dbal = 0.
                    v-cbal = 0.
                    v-dbalrate = 0.
                    v-cbalrate = 0.
                    for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.lev = 1 and txb.jl.jdt >= vasof_f And txb.jl.jdt <= vasof no-lock:
                        v-dbal = v-dbal + txb.jl.dam.
                        v-cbal = v-cbal + txb.jl.cam.
                            if txb.aaa.crc ne 1 then do:
                                find last txb.crchis where txb.crchis.crc eq txb.aaa.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
                                if avail txb.crchis then do:
                                    v-cbalrate = v-cbalrate + txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
                                    v-dbalrate = v-dbalrate + txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
                                end.
                            end.
                            else do:
                                v-cbalrate = v-cbalrate + txb.jl.cam.
                                v-dbalrate = v-dbalrate + txb.jl.dam.
                            end.
                    end.
                    v-in = no.
                        if  v-bal <> 0 or v-bal_f <> 0 or v-cbalrate <> 0 or v-dbalrate <> 0 then v-in = yes.
                        else do:
                            if v-withprc then
                                if (v-bal2 > 0) or (v-bal11 > 0) then v-in = yes.
                        end.
                    /* Counting per cents' levels */

                    v-bal2_f = 0.
                    v-bal11_f = 0.

                    v-bal2 = 0.
                    v-bal11 = 0.

                    v-bal2kzt_f = 0.
                    v-bal2kzt = 0.


                        /* first date*/

                        run lonbalcrc_txb('cif',txb.aaa.aaa,vasof_f,"2",no,txb.aaa.crc,output v-bal2_f).
                        v-bal2_f = - v-bal2_f.
                        run lonbalcrc_txb('cif',txb.aaa.aaa,vasof_f,"11",no,1,output v-bal11_f).


                        if txb.aaa.crc <> 1 then do: /*если валюта счета не тенге*/
                            find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                            if avail txb.crchis then
                            v-bal2kzt_f = v-bal2_f * txb.crchis.rate[1] / txb.crchis.rate[9].
                        end.
                        else do:
                            v-bal2kzt_f = v-bal2_f.
                        end.
                        /* second date*/

                        run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"2",yes,txb.aaa.crc,output v-bal2).
                        v-bal2 = - v-bal2.
                        run lonbalcrc_txb('cif',txb.aaa.aaa,vasof,"11",yes,1,output v-bal11).

                        if txb.aaa.crc <> 1 then do: /*если валюта счета не тенге*/
                            find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= vasof no-lock no-error.
                            if avail txb.crchis then
                            v-bal2kzt = v-bal2 * txb.crchis.rate[1] / txb.crchis.rate[9].
                        end.
                        else do:
                            v-bal2kzt = v-bal2.
                        end.

                        if v-in then do:
                            find first t-acc where t-acc.gl = txb.gl.gl and t-acc.acc = txb.aaa.aaa and t-acc.cif = txb.cif.cif no-error.
                                if not avail t-acc then do:
                                    create t-acc.
                                    t-acc.gl = txb.gl.gl.
                                    t-acc.acc = txb.aaa.aaa.
                                    t-acc.cif = txb.aaa.cif.
                                    t-acc.cifname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                                    t-acc.crc = txb.aaa.crc.
                                    t-acc.geo = txb.cif.geo.
                                    t-acc.amt_f = v-bal_f.
                                    t-acc.amtkzt_f = v-balrate_f.
                                    t-acc.kurs_f = v-kurs_f.
                                    t-acc.fil = txb.cmp.name.
                                    t-acc.banks = vbank.
                                    t-acc.dam = v-dbal.
                                    t-acc.cam = v-cbal.
                                    t-acc.damkzt = v-dbalrate.
                                    t-acc.camkzt = v-cbalrate.
                                    t-acc.amt = v-bal.
                                    t-acc.amtkzt = v-balrate.
                                    t-acc.banks = vbank.
                                    t-acc.lev2_f = v-bal2_f.
                                    t-acc.lev2kzt_f = v-bal2kzt_f.
                                    t-acc.lev11_f = v-bal11_f.

                                    t-acc.lev2 = v-bal2.
                                    t-acc.lev2kzt = v-bal2kzt.
                                    t-acc.lev11 = v-bal11.

                                    t-acc.rdt = txb.aaa.regdt.
                                    t-acc.duedt = txb.aaa.expdt.


                                    if txb.gl.type eq "A" then do:
                                        t-acc.kurs_d = v-balrate_f + v-dbalrate - v-cbalrate - v-balrate.
                                    end.
                                    else do:
                                        t-acc.kurs_d = v-balrate_f - v-dbalrate + v-cbalrate - v-balrate.
                                    end.
                                    find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
                                    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis"
                                    and txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
                                        if avail txb.sub-cod then
                                            t-acc.ecdivis = txb.sub-cod.ccode.
                                        else
                                            t-acc.ecdivis = "".
                                    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek"
                                    and txb.sub-cod.acc = txb.aaa.cif no-lock no-error. /*сектор экономики*/
                                        if avail txb.sub-cod then
                                            t-acc.secek = txb.sub-cod.ccode.
                                    /*message p-bank t-acc.acc txb.gl.gl. pause 0.*/
                                end.
                        end.

                end.
        end. /* for each */
    end. /* if txb.gl.subled */


    /*****************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли счет Указанного ГК Внутренним транзитным счетом*/

    if txb.gl.subled = 'ARP' then do:
        for each txb.arp where txb.arp.gl = txb.gl.gl no-lock:

            /* first date */
            v-bal_f = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'arp' and txb.histrxbal.acc = txb.arp.arp
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.arp.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
                if txb.gl.type eq "A" then do:
                    if avail txb.histrxbal then
                    v-bal_f = txb.histrxbal.dam - txb.histrxbal.cam.
                end.
                else do:
                    if avail txb.histrxbal then
                    v-bal_f = txb.histrxbal.cam - txb.histrxbal.dam.
                end.
                find last txb.crchis where txb.crchis.crc eq txb.arp.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                if avail txb.crchis then
                v-balrate_f = v-bal_f * txb.crchis.rate[1] / txb.crchis.rate[9].

            /* second date */
            v-bal = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'arp' and txb.histrxbal.acc = txb.arp.arp
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.arp.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                if txb.gl.type eq "A" then do:
                    if avail txb.histrxbal then
                        v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                end.
                else do:
                    if avail txb.histrxbal then
                        v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                end.
             find last txb.crchis where txb.crchis.crc eq txb.arp.crc and txb.crchis.rdt <= vasof no-lock no-error.
             if avail txb.crchis then
             v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].
             /*Обороты */
             v-dbal = 0.
             v-cbal = 0.
             v-dbalrate = 0.
             v-cbalrate = 0.
             for each txb.jl where txb.jl.acc = txb.arp.arp and txb.jl.lev = 1 and txb.jl.jdt >= vasof_f And txb.jl.jdt <= vasof no-lock:
                v-dbal = v-dbal + txb.jl.dam.
                v-cbal = v-cbal + txb.jl.cam.
                if txb.arp.crc ne 1 then do:
                    find last txb.crchis where txb.crchis.crc eq txb.arp.crc and txb.crchis.rdt le txb.jl.jdt no-lock no-error.
                    if avail txb.crchis then do:
                        v-cbalrate = v-cbalrate + txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
                        v-dbalrate = v-dbalrate + txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
                    end.
                end.
                else do:
                    v-cbalrate = v-cbalrate + txb.jl.cam.
                    v-dbalrate = v-dbalrate + txb.jl.dam.
                end.
             end.
             if  v-bal <> 0 or v-bal_f <> 0 or v-cbalrate <> 0 or v-dbalrate <> 0 then do:
                        create t-acc.
                        t-acc.gl = txb.gl.gl.
                        t-acc.acc = txb.arp.arp.
                        t-acc.cif = txb.arp.des.
                        t-acc.crc = txb.arp.crc.

                        t-acc.amt_f = v-bal_f.
                        t-acc.amtkzt_f = v-balrate_f.
                        t-acc.kurs_f = v-kurs_f.
                        t-acc.fil = txb.cmp.name.
                        t-acc.banks = vbank.

                        t-acc.dam = v-dbal.
                        t-acc.cam = v-cbal.
                        t-acc.damkzt = v-dbalrate.
                        t-acc.camkzt = v-cbalrate.

                        t-acc.amt = v-bal.
                        t-acc.amtkzt = v-balrate.
                        t-acc.banks = vbank.

                        t-acc.rdt = txb.arp.rdt.
                        t-acc.duedt = txb.arp.duedt.

                        if txb.gl.type eq "A" then do:
                            t-acc.kurs_d = v-balrate_f + v-dbalrate - v-cbalrate - v-balrate.
                        end.
                        else do:
                            t-acc.kurs_d = v-balrate_f - v-dbalrate + v-cbalrate - v-balrate.
                        end.
                        find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.d-cod = "ecdivis"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error.
                            if avail txb.sub-cod then
                                t-acc.ecdivis = txb.sub-cod.ccode.
                            else
                                t-acc.ecdivis = "".
                        find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.d-cod = "secek"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                            if avail txb.sub-cod then
                                t-acc.secek = txb.sub-cod.ccode.
                            else
                                t-acc.secek = "".
			            /*message p-bank t-acc.acc txb.gl.gl. pause 0.*/
             end.
        end.
    end.

    /***************************************************************************************************************************************************************/
    /***************************************************************************************************************************************************************/
    /*Является ли указанный ГК Казначейским счетом*/

    if txb.gl.subled = 'fun' then do:
        for each txb.fun where txb.fun.gl = txb.gl.gl no-lock:

            /* first date */
            v-bal_f = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'fun' and txb.histrxbal.acc = txb.fun.fun
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.fun.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
            find txb.bankl where txb.bankl.bank = txb.fun.bank no-lock no-error.
                if avail txb.bankl then do:
                    if txb.gl.type eq "A" then do:
                        if avail txb.histrxbal then
                        v-bal_f = txb.histrxbal.dam - txb.histrxbal.cam.
                    end.
                    else do:
                        if avail txb.histrxbal then
                        v-bal_f = txb.histrxbal.cam - txb.histrxbal.dam.
                    end.
                end.
                find last txb.crchis where txb.crchis.crc eq txb.fun.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                if avail txb.crchis then
                    v-balrate_f = v-bal_f * txb.crchis.rate[1] / txb.crchis.rate[9].

            /* second date */
            v-bal = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'fun' and txb.histrxbal.acc = txb.fun.fun
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.fun.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
            find txb.bankl where txb.bankl.bank = txb.fun.bank no-lock no-error.
                if avail txb.bankl then do:
                    if txb.gl.type eq "A" then do:
                        if avail txb.histrxbal then
                            v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                        end.
                        else do:
                            if avail txb.histrxbal then
                                v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                        end.
                end.
                find last txb.crchis where txb.crchis.crc eq txb.fun.crc and txb.crchis.rdt <= vasof no-lock no-error.
                if avail txb.crchis then
                    v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].

            /*Обороты */
            v-dbal = 0.
            v-cbal = 0.
            v-dbalrate = 0.
            v-cbalrate = 0.
            for each txb.jl where txb.jl.acc = txb.fun.fun and txb.jl.lev = 1 and txb.jl.jdt >= vasof_f and txb.jl.jdt <= vasof no-lock:
                v-dbal = v-dbal + txb.jl.dam.
                v-cbal = v-cbal + txb.jl.cam.
                    if txb.fun.crc ne 1 then do:
                        find last txb.crchis where txb.crchis.crc eq txb.fun.crc and txb.crchis.rdt le txb.jl.jdt no-lock no-error.
                        if avail txb.crchis then do:
                            v-cbalrate = v-cbalrate + txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
                            v-dbalrate = v-dbalrate + txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
                        end.
                    end.
                    else do:
                        v-cbalrate = v-cbalrate + txb.jl.cam.
                        v-dbalrate = v-dbalrate + txb.jl.dam.
                    end.
            end.
            if  v-bal <> 0 or v-bal_f <> 0 or v-cbalrate <> 0 or v-dbalrate <> 0 then do:
                            create t-acc.
                            t-acc.gl = txb.gl.gl.
                            t-acc.acc = txb.fun.fun.
                            t-acc.cif = txb.bankl.name.
                            t-acc.crc = txb.fun.crc.


                            t-acc.amt_f = v-bal_f.
                            t-acc.amtkzt_f = v-balrate_f.
                            t-acc.kurs_f = v-kurs_f.
                            t-acc.fil = txb.cmp.name.
                            t-acc.banks = vbank.

                            t-acc.dam = v-dbal.
                            t-acc.cam = v-cbal.
                            t-acc.damkzt = v-dbalrate.
                            t-acc.camkzt = v-cbalrate.

                            t-acc.amt = v-bal.
                            t-acc.amtkzt = v-balrate.
                            t-acc.banks = vbank.

                            t-acc.rdt = txb.fun.rdt.
                            t-acc.duedt = txb.fun.duedt.

                            find txb.sub-cod where txb.sub-cod.sub = "fun" and txb.sub-cod.d-cod = "ecdivis"
                            and txb.sub-cod.acc = t-acc.acc no-lock no-error.
                                if avail txb.sub-cod then
                                    t-acc.ecdivis = txb.sub-cod.ccode.
                                else
                                    t-acc.ecdivis = "".
                            find txb.sub-cod where txb.sub-cod.sub = "fun" and txb.sub-cod.d-cod = "secek"
                            and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                                if avail txb.sub-cod then
                                    t-acc.secek = txb.sub-cod.ccode.
                                else
                                    t-acc.secek = "".
                            if txb.gl.type eq "A" then do:
                                t-acc.kurs_d = v-balrate_f + v-dbalrate - v-cbalrate - v-balrate.
                            end.
                            else do:
                                t-acc.kurs_d = v-balrate_f - v-dbalrate + v-cbalrate - v-balrate.
                            end.
                            /*message p-bank t-acc.acc txb.gl.gl. pause 0.*/
            end.

        end.
    end.
    /***************************************************************************************************************************************************************/

    /***************************************************************************************************************************************************************/
    /*Является ли указанный счет Корреспондентским?*/
    if txb.gl.subled = 'dfb' then do:
        for each txb.dfb where txb.dfb.gl = txb.gl.gl no-lock:

            /* first date */
            v-bal_f = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'dfb' and txb.histrxbal.acc = txb.dfb.dfb
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.dfb.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
                if txb.gl.type eq "A" then do:
                    if avail txb.histrxbal then
                    v-bal_f = txb.histrxbal.dam - txb.histrxbal.cam.
                end.
                else do:
                    if avail txb.histrxbal then
                    v-bal_f = txb.histrxbal.cam - txb.histrxbal.dam.
                end.
                find last txb.crchis where txb.crchis.crc eq txb.dfb.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                if avail txb.crchis then
                v-balrate_f = v-bal_f * txb.crchis.rate[1] / txb.crchis.rate[9].

            /* second date */
            v-bal = 0.
            find last txb.histrxbal where txb.histrxbal.subled = 'dfb' and txb.histrxbal.acc = txb.dfb.dfb
            and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.dfb.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                if txb.gl.type eq "A" then do:
                    if avail txb.histrxbal then
                        v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                end.
                else do:
                    if avail txb.histrxbal then
                        v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                end.
             find last txb.crchis where txb.crchis.crc eq txb.dfb.crc and txb.crchis.rdt <= vasof no-lock no-error.
             if avail txb.crchis then
             v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].

             /*Обороты */
             v-dbal = 0.
             v-cbal = 0.
             v-dbalrate = 0.
             v-cbalrate = 0.
             for each txb.jl where txb.jl.acc = txb.dfb.dfb and txb.jl.lev = 1 and txb.jl.jdt >= vasof_f And txb.jl.jdt <= vasof no-lock:
                v-dbal = v-dbal + txb.jl.dam.
                v-cbal = v-cbal + txb.jl.cam.
                if txb.dfb.crc ne 1 then do:
                    find last txb.crchis where txb.crchis.crc eq txb.dfb.crc and txb.crchis.rdt le txb.jl.jdt no-lock no-error.
                    if avail txb.crchis then do:
                        v-cbalrate = v-cbalrate + txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
                        v-dbalrate = v-dbalrate + txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
                    end.
                end.
                else do:
                    v-cbalrate = v-cbalrate + txb.jl.cam.
                    v-dbalrate = v-dbalrate + txb.jl.dam.
                end.
             end.
             if  v-bal <> 0 or v-bal_f <> 0 or v-cbalrate <> 0 or v-dbalrate <> 0 then do:
                        create t-acc.
                        t-acc.gl = txb.gl.gl.
                        t-acc.acc = txb.dfb.dfb.
                        t-acc.cif = txb.dfb.name.
                        t-acc.crc = txb.dfb.crc.
                        t-acc.ecdivis = "".

                        t-acc.amt_f = v-bal_f.
                        t-acc.amtkzt_f = v-balrate_f.
                        t-acc.kurs_f = v-kurs_f.
                        t-acc.fil = txb.cmp.name.
                        t-acc.banks = vbank.

                        t-acc.dam = v-dbal.
                        t-acc.cam = v-cbal.
                        t-acc.damkzt = v-dbalrate.
                        t-acc.camkzt = v-cbalrate.

                        t-acc.amt = v-bal.
                        t-acc.amtkzt = v-balrate.
                        t-acc.banks = vbank.

                        t-acc.rdt = txb.dfb.rdt.
                        t-acc.duedt = txb.dfb.duedt.

                        find txb.sub-cod where txb.sub-cod.sub = "dfb" and txb.sub-cod.d-cod = "ecdivis"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error.
                            if avail txb.sub-cod then
                                t-acc.ecdivis = txb.sub-cod.ccode.
                            else
                                t-acc.ecdivis = "".
                        find txb.sub-cod where txb.sub-cod.sub = "dfb" and txb.sub-cod.d-cod = "secek"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                            if avail txb.sub-cod then
                                t-acc.secek = txb.sub-cod.ccode.
                            else
                                t-acc.secek = "".
                        if txb.gl.type eq "A" then do:
                            t-acc.kurs_d = v-balrate_f + v-dbalrate - v-cbalrate - v-balrate.
                        end.
                        else do:
                            t-acc.kurs_d = v-balrate_f - v-dbalrate + v-cbalrate - v-balrate.
                        end.
                        /*message p-bank t-acc.acc txb.gl.gl. pause 0.*/
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

                    /* first date */
                    v-bal_f = 0.

                    if txb.gl.gl <> 142410 and txb.gl.gl <> 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
                            if not avail histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 1 no-lock no-error.
                            end.

                    if txb.gl.gl = 142410 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 7 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
                            if not avail txb.histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 7 no-lock no-error.
                            end.

                    if txb.gl.gl = 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 8 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt < vasof_f  no-lock no-error.
                            if not avail histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 8 no-lock no-error.
                            end.

                    if txb.gl.type eq "A" then do:
                        if avail txb.histrxbal then
                            v-bal_f = txb.histrxbal.dam - txb.histrxbal.cam.
                    end.
                    else do:
                        if avail txb.histrxbal then
                            v-bal_f = txb.histrxbal.cam - txb.histrxbal.dam.
                    end.

                    find last txb.crchis where txb.crchis.crc eq txb.lon.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                    if avail txb.crchis then
                    v-balrate_f = v-bal_f * txb.crchis.rate[1] / txb.crchis.rate[9].

                    /* second date */
                    v-bal = 0.
                    if txb.gl.gl <> 142410 and txb.gl.gl <> 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 1 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                            if not avail histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 1 no-lock no-error.
                            end.

                    if txb.gl.gl = 142410 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 7 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                            if not avail txb.histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 7 no-lock no-error.
                            end.

                    if txb.gl.gl = 142710 then
                        find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon
                        and txb.histrxbal.level = 8 and txb.histrxbal.crc = txb.lon.crc and txb.histrxbal.dt <= vasof  no-lock no-error.
                            if not avail histrxbal then do:
                                find txb.trxbal where txb.trxbal.subled = 'lon' and txb.trxbal.acc = txb.lon.lon
                                and txb.trxbal.level = 8 no-lock no-error.
                            end.
                    if txb.gl.type eq "A" then do:
                        if avail txb.histrxbal then
                            v-bal = txb.histrxbal.dam - txb.histrxbal.cam.
                    end.
                    else do:
                        if avail txb.histrxbal then
                            v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                    end.
                    find last txb.crchis where txb.crchis.crc eq txb.lon.crc and txb.crchis.rdt <= vasof no-lock no-error.
                    if avail txb.crchis then
                    v-balrate = v-bal * txb.crchis.rate[1] / txb.crchis.rate[9].

                    /*Обороты */
                    v-dbal = 0.
                    v-cbal = 0.
                    v-dbalrate = 0.
                    v-cbalrate = 0.
                    for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.lev = txb.histrxbal.level
                    and txb.jl.jdt >= vasof_f and txb.jl.jdt <= vasof no-lock:
                        v-dbal = v-dbal + txb.jl.dam.
                        v-cbal = v-cbal + txb.jl.cam.
                        if txb.lon.crc ne 1 then do:
                            find last txb.crchis where txb.crchis.crc eq txb.lon.crc and txb.crchis.rdt le txb.jl.jdt no-lock no-error.
                            if avail txb.crchis then do:
                                v-cbalrate = v-cbalrate + txb.jl.cam * txb.crchis.rate[1] / txb.crchis.rate[9].
                                v-dbalrate = v-dbalrate + txb.jl.dam * txb.crchis.rate[1] / txb.crchis.rate[9].
                            end.
                        end.

                        else do:
                            v-cbalrate = v-cbalrate + txb.jl.cam.
                            v-dbalrate = v-dbalrate + txb.jl.dam.
                        end.
                    end.
                    /* Counting per cents' levels */

                    v-bal2_f = 0.
                    v-bal11_f = 0.
                    v-bal12_f = 0.
                    v-bal2 = 0.
                    v-bal11 = 0.
                    v-bal12 = 0.
                    v-bal2kzt_f = 0.
                    v-bal2kzt = 0.

                    if (string(txb.gl.gl) begins "1411") or (string(txb.gl.gl) begins "1417") then do:
                        /* first date*/

                        run lonbalcrc_txb('lon',txb.lon.lon,vasof_f,"2",no,txb.lon.crc,output v-bal2_f).

                        run lonbalcrc_txb('lon',txb.lon.lon,vasof_f,"11",no,1,output v-bal11_f).
                        v-bal11_f = - v-bal11_f.

                        run lonbalcrc_txb('lon',txb.lon.lon,vasof_f,"12",no,1,output v-bal12_f).
                        v-bal12_f = - v-bal12_f.

                        if txb.lon.crc <> 1 then do: /*если валюта счета не тенге*/
                            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt < vasof_f no-lock no-error.
                            if avail txb.crchis then
                            v-bal2kzt_f = v-bal2_f * txb.crchis.rate[1] / txb.crchis.rate[9].
                        end.
                        else do:
                            v-bal2kzt_f = v-bal2_f.
                        end.
                        /* second date*/

                        run lonbalcrc_txb('lon',txb.lon.lon,vasof,"2",yes,txb.lon.crc,output v-bal2).
                        run lonbalcrc_txb('lon',txb.lon.lon,vasof,"11",yes,1,output v-bal11).
                        v-bal11 = - v-bal11.
                        run lonbalcrc_txb('lon',txb.lon.lon,vasof,"12",yes,1,output v-bal12).
                        v-bal12 = - v-bal12.
                        if txb.lon.crc <> 1 then do: /*если валюта счета не тенге*/
                            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= vasof no-lock no-error.
                            if avail txb.crchis then
                            v-bal2kzt = v-bal2 * txb.crchis.rate[1] / txb.crchis.rate[9].
                        end.
                        else do:
                            v-bal2kzt = v-bal2.
                        end.
                    end.

                    if  v-bal <> 0 or v-bal_f <> 0 or v-cbalrate <> 0 or v-dbalrate <> 0 or v-bal11 <> 0 or v-bal11_f <> 0 or v-bal12 <> 0 or v-bal12_f <> 0 then do:
                        create t-acc.
                        t-acc.acc = txb.lon.lon.
                        t-acc.gl = txb.gl.gl.
                        t-acc.cif = txb.cif.cif.
                        t-acc.cifname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
                        t-acc.crc = txb.lon.crc.
                        t-acc.amt_f = v-bal_f.
                        t-acc.amtkzt_f = v-balrate_f.
                        t-acc.kurs_f = v-kurs_f.
                        t-acc.fil = txb.cmp.name.
                        t-acc.dam = v-dbal.
                        t-acc.cam = v-cbal.
                        t-acc.damkzt = v-dbalrate.
                        t-acc.camkzt = v-cbalrate.
                        t-acc.amt = v-bal.
                        t-acc.amtkzt = v-balrate.
                        t-acc.banks = vbank.
                        t-acc.lev2_f = v-bal2_f.
                        t-acc.lev2kzt_f = v-bal2kzt_f.
                        t-acc.lev11_f = v-bal11_f.
                        t-acc.lev12_f = v-bal12_f.
                        t-acc.lev2 = v-bal2.
                        t-acc.lev2kzt = v-bal2kzt.
                        t-acc.lev11 = v-bal11.
                        t-acc.lev12 = v-bal12.

                        t-acc.rdt = txb.lon.opndt.
                        t-acc.duedt = txb.lon.duedt.

                        find txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "ecdivis"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error.
                            if avail txb.sub-cod then
                                t-acc.ecdivis = txb.sub-cod.ccode.
                            else
                                t-acc.ecdivis = "".
                        find txb.sub-cod where txb.sub-cod.sub = "lon" and txb.sub-cod.d-cod = "secek"
                        and txb.sub-cod.acc = t-acc.acc no-lock no-error. /*сектор экономики*/
                            if avail txb.sub-cod then
                                t-acc.secek = txb.sub-cod.ccode.
                            else
                                t-acc.secek = "".
                        if txb.gl.type eq "A" then do:
                            t-acc.kurs_d = v-balrate_f + v-dbalrate - v-cbalrate - v-balrate.
                        end.
                        else do:
                            t-acc.kurs_d = v-balrate_f - v-dbalrate + v-cbalrate - v-balrate.
                        end.

                        /*message p-bank t-acc.acc txb.gl.gl. pause 0.*/
            end.
        end.
    end.
    /***************************************************************************************************************************************************************/
    end. /*for each gl*/
/*Окончание сбора данных************************************************************************************************************************************************/
hide all.

