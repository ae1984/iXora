/* dil_iprt.p
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
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        09/06/04 kanat - https:\\ поменял на https:\\www. ...
        10/06/04 dpuchkov - поменял www.bankonline.kz на www.texakabank.kz
        12/05/05 u00121 - find first dealing_doc и find first ib.doc заменил на find last dealing_doc и find last ib.doc
        01/06/05 suchkov - добавил явное указание индекса
        23/09/05 suchkov - добавил trim
        23/08/06 suchkov - оптимизация
        25.04.2011 id00004 - переделал поиск таблицы netbank с учетом филиалов
        14.09.2011 id00004 - исправил ошибку при отображении валюты комиссии
        04/05/2012 evseev - изменил путь к логотипу
        14/05/2012 evseev - изменил путь к логотипу
        03.01.2013 evseev - ТЗ-625
        11.04.2013 damir - Внедрено Т.З. № 1793. Исправлена техническая ошибка.
        02.10.2013 damir - Внедрено Т.З. № 1550.
*/
{global.i}

def input parameter dnum as char.

def var v-docordacc as char.
def var v-docbenacc as char.
def var v-docsubtype as integer.
def var v-docamt as decimal.
def var v-docbamt as decimal.

find last sysc where sysc.sysc = 'ourbnk' no-lock no-error.
find last dealing_doc where dealing_doc.DocNo = dnum no-lock. /*12/05/05 u00121 */
find last netbank where netbank.rmz =  dealing_doc.docno and netbank.txb = sysc.chval exclusive-lock no-error.
if not avail netbank then do:
    find last ib.doc where ib.doc.type = 9 and ib.doc.remtrz = "EXC" + dealing_doc.DocNo and can-find (cif where cif.cif = doc.cif) no-lock no-error. /*12/05/05 u00121 */
end.

def buffer oaa for bank.aaa.
def buffer baa for bank.aaa.
def buffer ocrc for bank.crc.
def buffer bcrc for bank.crc.

find last netbank where netbank.rmz =  dealing_doc.docno and netbank.txb = sysc.chval exclusive-lock no-error.
if not avail netbank then do:
    find last ib.usr where usr.id = doc.id_usr no-lock no-error.
end.
else do:
    find last ib.usr where usr.cif = netbank.cif no-lock no-error.
    if (dealing_doc.DocType = 1 or dealing_doc.DocType = 2) then v-docsubtype = 1.
    else v-docsubtype = 2.
    if dealing_doc.DocType = 1 or dealing_doc.DocType = 2 then do:
        v-docordacc = dealing_doc.tclientaccno.
        v-docbenacc = dealing_doc.vclientaccno.
    end.
    else do:
        v-docbenacc = dealing_doc.tclientaccno.
        v-docordacc = dealing_doc.vclientaccno.
    end.
    v-docamt = decimal(entry(1, netbank.rem[3],  "#")).
    v-docbamt = decimal(entry(2, netbank.rem[3],  "#")).
end.

if avail netbank then find last oaa where oaa.aaa = trim(v-docordacc) no-lock no-error.
else find last oaa where oaa.aaa = trim(doc.ordacc) no-lock no-error.
find last ocrc where ocrc.crc = oaa.crc no-lock no-error.
if avail netbank then find last baa where baa.aaa = trim(v-docbenacc) no-lock no-error.
else find last baa where baa.aaa = trim(doc.benacc) no-lock no-error.
find last bcrc where bcrc.crc = baa.crc no-lock no-error.

output to 'rpt.html'.

{html-title.i &stream = " " &title = "Заявка" &size-add = " "}

if not avail netbank then do:

    put unformatted
        '<table border="0" width="100%">'  skip
        '<tr><td width="100"><img src="http://portal/_layouts/images/top_logo_bw.jpg"></td><td>'  skip
        '<p align="center"><font size="5"><b>'  skip
        'Заявка на '
        (if avail doc then (if doc.subtype = 1 then 'покупку' else 'продажу') else "") '<br>иностранной валюты' space "No " (if avail doc then substr(doc.remtrz,4) else "") '</b></font></p>'  skip
        '</td></tr><table><table border="0"><tr><td><img src="http://www.texakabank.kz/images/f1.gif" width="60"></td><td vAlign="top">'  skip
        '<font size="4">' skip.
    put unformatted
        '<p align="right">Дата:  ' (if avail doc then string(doc.valdate,"99/99/9999") else "") '</p>' skip
        '<p>Клиент:  ' (if avail usr then usr.contact[1] else "") '</p>'
        '<p>ИИН/БИН:  ' (if avail usr then usr.contact[2] else "") '</p>'
        '<p>Телефон:  ' (if avail usr then usr.contact[3] else "") '</p>'
        '<p>Схема ' (if avail doc then (if doc.subtype = 1 then 'конвертации' else 'реконвертации') else "") ':   ' ocrc.code '  -  ' bcrc.code
        '<p>'
        '<p>Просим ' (if avail doc then (if doc.subtype = 1 then 'списать' else 'произвести продажу иностранной валюты') else "") ' с нашего текущего счета No  '
        (if avail doc then doc.ordacc else "").

    if avail doc then do:
        if doc.subtype = 1 then do:
            put unformatted ' сумму'.
            if amt <> 0 then put unformatted ' в размере  ' doc.amt ' тенге'.
            else put unformatted ', необходимую для покупки ' doc.bamt ' ' bcrc.code ' по курсу сделки ' if avail dealing_doc then string(dealing_doc.rate,">>>>>>9.99") else "".
        end.

        if doc.subtype = 2 then do:
            put unformatted ' в размере'.
            if amt <> 0 then put unformatted '  ' doc.amt ' ' ocrc.code.
            else put unformatted ', необходимом для покупки ' doc.bamt ' ' bcrc.code ' по курсу сделки ' if avail dealing_doc then string(dealing_doc.rate,">>>>>>9.99") else "".
        end.
    end.
    put unformatted '</p>' skip.
    put unformatted '<p>'.

    put unformatted
        'Комиссию за ' (if avail doc then (if doc.subtype = 1 then 'конвертацию' else 'реконвертацию') else "") ' удержите в '.
    if avail doc then do:
        if doc.subtype = 1 then put unformatted ' иностранной валюте.'.
        if doc.subtype = 2 then do:
            find first aaa where aaa.aaa = comacc no-lock no-error.
            put unformatted
                (if avail aaa then (if aaa.crc = 1 then ' тенге' else ' иностранной валюте со счета   ') else "") doc.comacc '.'.
        end.
    end.
    put unformatted '</p><p>'.

    if avail doc then put unformatted
        'Срочность заявки:   ' (if doc.urgency = 'U' then 'срочная' else 'обычная') '.'.

    put unformatted '</p>'.
    put unformatted '<p>'.
    put unformatted
        'Просим перечислить сумму в ' (if avail doc then (if doc.subtype = 1 then 'валюте' else 'тенге') else "") ' на наш текущий счет '
        (if avail doc then (if doc.subtype = 1 then 'в иностранной валюте ' else '') else "") 'No   ' (if avail doc then doc.benacc else "") '.'.
    put unformatted '</p>'.
    put unformatted '<p>'.
    if avail doc and doc.subtype = 1 then put unformatted
        'Цель покупки:  ' doc.letr[1].
    put unformatted '</p>'.
    put unformatted
        '<p align="center">Банк производит ' (if avail doc then (if doc.subtype = 1 then 'конвертацию' else 'реконвертацию') else "") ' в соответствии с действующим валютным законодательством Республики Казахстан.
        С тарифами на услуги ознакомлены.</p>' skip
        '<p>Кодовая фраза:  ' (if avail doc then doc.ibinfo[4] else "") '</p>' skip
        '<p>Кодовая фраза проверена, сальдо счета позволяет:_________________________</p>' skip.
    put unformatted
        '</font></td></tr></table>'.
end.
else do:
    put unformatted
        '<table border="0" width="100%">'  skip
        '<tr><td width="100"><img src="http://portal/_layouts/images/top_logo_bw.jpg"></td><td>'  skip
        '<p align="center"><font size="5"><b>'  skip
        'Заявка на '
        (if v-docsubtype = 1 then 'покупку' else 'продажу') '<br>'  skip
        'иностранной валюты' space "No " dealing_doc.docno
        '</b></font></p>'  skip
        '</td></tr><table><table border="0"><tr><td><img src="http://www.texakabank.kz/images/f1.gif" width="60"></td><td vAlign="top">'  skip
        '<font size="4">' skip
        '<p align="right">'
        'Дата:  ' g-today
        '</p>'  skip
        '<p>Клиент:  ' (if avail usr then usr.contact[1] else "") '</p>'
        '<p>ИИН/БИН:  ' (if avail usr then usr.contact[2] else "") '</p>'
        '<p>Телефон:  ' (if avail usr then usr.contact[3] else "") '</p>'
        '<p>Схема ' (if v-docsubtype = 1 then 'конвертации' else 'реконвертации') ':   ' ocrc.code '  -  ' bcrc.code '<p>'
        '<p>Просим ' (if v-docsubtype = 1 then 'списать' else 'произвести продажу иностранной валюты') ' с нашего текущего счета No  ' v-docordacc.

    if v-docsubtype = 1 then do:
        put unformatted ' сумму'.
        if v-docamt <> 0 then
            put unformatted ' в размере  ' v-docamt ' тенге'.
        else
            put unformatted ', необходимую для покупки ' v-docbamt ' ' bcrc.code
            ' по курсу сделки ' if avail dealing_doc then string(dealing_doc.rate,">>>>>>9.99") else "".
    end.
    if v-docsubtype = 2 then do:
        put unformatted ' в размере'.
        if v-docamt <> 0 then
            put unformatted '  ' v-docamt ' ' ocrc.code.
        else
            put unformatted ', необходимом для покупки ' v-docbamt ' ' bcrc.code
            ' по курсу сделки ' if avail dealing_doc then string(dealing_doc.rate,">>>>>>9.99") else "".
    end.
    put unformatted '</p>' skip.
    put unformatted '<p>'.
    put unformatted
        'Комиссию за ' (if v-docsubtype = 1 then 'конвертацию' else 'реконвертацию') ' удержите в '.
    if v-docsubtype = 1 then do:
        find first aaa where aaa.aaa = dealing_doc.com_accno  no-lock no-error.
        put unformatted (if avail aaa then (if aaa.crc = 1 then ' тенге' else ' иностранной валюте') else "").
    end.
    if v-docsubtype = 2 then do:
        find first aaa where aaa.aaa = dealing_doc.com_accno /*comacc*/ no-lock no-error.
        put unformatted (if avail aaa then (if aaa.crc = 1 then ' тенге' else ' иностранной валюте со счета ') else "") dealing_doc.com_accno /*doc.comacc*/ '.'.
    end.
    put unformatted '</p>' skip.
    put unformatted '<p>'.
    put unformatted
        'Срочность заявки:   ' (if (dealing_doc.DocType = 1 or dealing_doc.DocType = 3) then 'срочная' else 'обычная.').
    /* if doc.urgency = 'U' then 'срочная' else 'обычная' '.'. */
    /* 'срочная' .  */
    put unformatted '</p>' skip.
    put unformatted '<p>'.
    put unformatted
        'Просим перечислить сумму в ' (if v-docsubtype = 1 then 'валюте' else 'тенге') ' на наш текущий счет ' (if v-docsubtype = 1 then 'в иностранной валюте ' else '') 'No   ' v-docbenacc '.'.
    put unformatted '</p>' skip.

    put unformatted '<p>'.
    if v-docsubtype = 1 then do:
        find last trgt where trgt.jh = int(dealing_doc.DocNo).
        put unformatted 'Цель покупки:  ' (if avail trgt then trgt.rem2 else "").
    end.
    put unformatted '</p>'.

    put unformatted
        '<p align="center">Банк производит ' (if v-docsubtype = 1 then 'конвертацию' else 'реконвертацию') ' в соответствии с действующим валютным законодательством Республики Казахстан.
        С тарифами на услуги ознакомлены.</p>'
        '<p>Кодовая фраза:  ' /*doc.ibinfo[4] */ '</p>'
        '<p>Кодовая фраза проверена, сальдо счета позволяет:_________________________' '</p>' .
    put unformatted
        '</font></td></tr></table>'.
end.
{html-end.i}

output close.

unix silent value("cptwin rpt.html iexplore").

unix silent value("rm rpt.html").


