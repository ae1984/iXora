/* printord2.p
 * MODULE
        Название модуля - Используется во всех модулях.
 * DESCRIPTION
        Описание - Формирование и вывод приходных и расходных кассовых ордеров
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        16.01.2012 damir    - в поле кассир(подпись) выводить номер ЭК (привязку ЭК к офицеру не использовать)
        18.01.2012 damir    - корректировка.
        23.01.2012 damir    - перекомпиляция.
        29.02.2012 damir    - внедрено Т.З. № 1281 по подписям.
        05.03.2012 damir    - перекомпиляция в связи с изменением printord2.f и printord2.i.
        07.03.2012 damir    - убрал shared parameter s-jh, выходила ошибка...
        11.03.2012 damir    - перекомпиляция в связи с изменением printord2.f.
        12.03.2012 damir    - добавил запись в массив drek [10][11][12].
        20.03.2012 damir    - перекомпиляция.
        26.03.2012 damir    - перекомпиляция в связи с изменением printord2.f.
        28.03.2012 damir    - перекомпиляция в связи с изменением printord2.f, printord2.i.
        28.03.2012 id00810  - добавила v-bankname для печати.
        30.03.2012 damir    - внедрено Т.З. № 1330, добавлены новые форматы для п.м. 4.1.3, 15.4, 4.1.8, 4.2.15, внесены изменения
        в printord2.f, printord2.i.
        10.04.2012 damir    - изменения в printord2.f,printord2.i.
        13.04.2012 damir    - изменил формат с "yes/no" на "да/нет".
        16.04.2012 damir    - добавил replace.
        18.04.2012 damir    - внедрено Т.З. № 1339.
        25.04.2012 damir    - перекомпиляция.
        05.05.2012 damir    - в sysc создал две записи fullnamerus,fullnamekz, а также внесены изменения в printord2.i,printord3.i,
        printord2.f.
        08.05.2012 damir    - перекомпиляция в связи с изменением printord2.f.
        10.05.2012 damir    - уменьшил размер вырезки substr назначения платежа.
        23.05.2012 damir    - добавил defprint.i, defprintbks.i, вывод данных в ордерах при коммунальных платежах.
        24.05.2012 damir    - добавил classes.i, variable Doc.
        07.05.2012 damir    - перекомпиляция.
        18.06.2012 damir    - перекомпиляция в связи с изменением printord2.f,printord2.i,printord3.i. Внедрены Т.З. № 1394,1393.
        21.06.2012 damir    - добавил проверку по символу / в паспорте.
        22.06.2012 damir    - добавил v-passpnum,v-passpdt,v-passpwho.
        25.06.2012 damir    - поставил символоразделитель "," joudoc.passp.
        28.06.2012 damir    - перекомпиляция, корректировка в шаблоне.
        05.07.2012 damir    - перекомпиляция в связи с изменением printord2.f,printord2.i,printord3.i.
        12.07.2012 damir    - убрал drek,input parameters,temp-table t-obm,v-bankname, добавил nbankBik.i.
        18.07.2012 damir    - мелкие корректировки.
        24.07.2012 id00810  - перекомпиляция в связи с изменением printord2.i
        09.08.2012 damir    - перекомпиляция в связи с изменением printord2.f.
        10.08.2012 damir    - перекомпиляция в связи с изменением printord2.f.
        11.09.2012 damir    - перекомпиляция в связи с изменением printord2.f,printord2.i,printord3.i. Переход на ИИН/БИН. Реализовано Т.З.
                              <Изменение цветовой гаммы в приходных/расходных ордерах>.
        13.09.2012 damir    - перекомпиляция в связи с изменением printord2.f,printord2.i.
        02.11.2012 damir    - Изменения, связанные с изменением шаблонов по конвертации. Добавил convgl.i,isConvGL,v-convGL.
        07.11.2012 damir    - Внедрено Т.З. № 1365,1481,1538. Добавил все типы обозначенные в iXora.
        26.12.2012 damir    - Внедрено Т.З. 1624.
        12.02.2013 damir    - Внедрено Т.З. 1676.
        26/03/2013 Luiza    - перекомпиляция в связи с ТЗ 1714 добавила g-fname  = a_obmen2
        30.07.2013 damir - Внедрено Т.З. № 1494.
        30.09.2013 damir - Внедрено Т.З. № 1648.
*/
{chbin.i}
{get-dep.i}
{nbankBik.i}
{classes.i}
{defprint.i}
{convgl.i "bank"}

def var Doc as class COMPAYDOCClass.

def var v-incas as char.
def var v-outcas as char.
def var v-passpnum as char.
def var v-passpdt as date.
def var v-passpwho as char.
def var v-iinbin as char.
def var KOd as char.
def var KBe as char.
def var KNP as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-naznplat as char.
def var v-city as char.
def var v-onacc as char.
def var v-accfrom as char.
def var v-bnkbin as char.
def var v-whorecei as char.
def var v-clien as char.
def var v-ofcnam as char.
def var v-depart as inte.
def var v-cokname as char.

def var vv-cif as char.
def var vv-type as char.
def var dtreg as date.
def var v-crc as char.
def var v-crc2 as char.
def var v-crccod as inte.
def var v-crccod2 as inte.
def var v-crcobmen as char.
def var v-crcobm as char.
def var v-curs as deci.
def var v-elcash as char.
def var p as inte.
def var v-doccontrol as logi.
def var v-idconfname as char.
def var v-dir as char.
def var v-pathdir as char.
def var v-exitcod as char.
def var v-res as char.
def var v-txb as char.
def var v-okpo as char.
def var v-convGL as logi.
def var v-Excep as logi.
def var v-storn as logi.

def buffer bb-ljl for ljl.
def buffer bb2-ljl for ljl.
def buffer bb3-ljl for ljl.
def buffer bb4-ljl for ljl.
def buffer bb5-ljl for ljl.

dtreg = ?. v-incas = "". v-outcas = "". v-passpnum = "". v-passpdt = ?. v-passpwho = "". v-iinbin = "". v-naznplat = "". v-doccontrol = false. v-Excep = false.

find jh where jh.jh eq jhnum no-lock no-error.
if not avail jh then return.

find first cmp no-lock no-error.
if avail cmp then do:
    v-okpo = trim(cmp.addr[3]).
    v-city = trim(cmp.name).
end.

Doc = NEW COMPAYDOCClass(Base).

dtreg = jh.jdt.

if v-bin then do:
    if dtreg ge v-bin_rnn_dt then do:
        find first sysc where sysc.sysc eq "bnkbin" no-lock no-error.
        if avail sysc then v-bnkbin = trim(sysc.chval).
    end.
    else v-bnkbin = trim(cmp.addr[2]).
end.
else v-bnkbin = trim(cmp.addr[2]).

if jh.sub eq "jou" then do:
    find joudoc where joudoc.docnum eq jh.ref no-lock no-error.
    dtreg = joudoc.whn.
    if joudoc.drcur ne 1 and joudoc.brate ne 1 then do:
        v-curs = joudoc.brate.
        find first crc where crc.crc eq joudoc.drcur no-lock no-error.
        if avail crc then v-crcobm = trim(crc.code).
    end.
    if joudoc.crcur ne 1 and joudoc.srate ne 1 then do:
        v-curs = joudoc.srate.
        find first crc where crc.crc eq joudoc.crcur no-lock no-error.
        if avail crc then v-crcobm = trim(crc.code).
    end.
end.
/*Документ отконтролирован в 2.4.1.1 ; 2.4.1.3 ; 2.4.1.7 ; 2.4.1.5 ; 2.4.1.7 ; 2.4.1.10 ; 2.4.1.11 ; 2.4.1.12*/
find first doccontord where doccontord.doc eq jh.ref no-lock no-error.
if avail doccontord then do:
    v-doccontrol = true.
    v-idconfname = doccontord.who.
end.
find ofc where ofc.ofc = jh.who no-lock no-error.
if avail ofc then v-ofcnam = ofc.name.
if avail ofc then do:
    v-depart = int(get-dep(ofc.ofc,g-today)).
    find first ppoint where ppoint.depart = v-depart no-lock no-error.
    if avail ppoint then do:
        v-cokname = trim(ppoint.name).
        if v-cokname begins "ЦОК" then v-cokname = trim(substr(trim(v-cokname),4,length(v-cokname))).
    end.
end.
def var s_nknmb as char.
def var i_temp_dep as inte.
if jh.sts = 6 then do:
    i_temp_dep = inte(get-dep(g-ofc,g-today)).
    find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
    if avail depaccnt and depaccnt.rem <> '' then s_nknmb = entry(1,depaccnt.rem,'$').
    else s_nknmb = '***'.
end.

{printord2.f}

if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.