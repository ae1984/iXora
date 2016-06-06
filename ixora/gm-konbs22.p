/* gm-konbs22.p
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
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM TXB
 * CHANGES
        01.06.2003 nadejda  - переделала балансы так, чтобы считать на любую дату
        20.07.2004 saltanat - Добавлено stream rpt для вывода данных в Excel.
        11/10/05 nataly     - был добавлен итоговый уровень по счетам ГК
        08/08/06 nataly     - Валюта была разбита на USD,RUB,EUR
        25/12/07 marinav    - ast -> txb
        13/11/08 marinav    - добавила валюту фунты
        10/09/2011 madiyar  - добавил шведские кроны, австралийские доллары и швейцарские франки
        06.04.2012 damir    - изменений не вносил, перекомпиляция.
        14/06/2012 madiyar  - добавил ранды
        15.06.2012 damir    - перекомпиляция.
        04.07.2012 damir    - добавил CAD.
        30.11.2012 Lyubov   - ТЗ 1374 от 23/05/2012 «Изменение счета ГК 1858»
*/

{gl-utils.i}

def shared var flag     as logical.
def shared var rate1    as decimal.
def shared var rate9    as decimal.
def shared var vbal     as decimal extent 10.
def shared var vbaltot  as decimal format 'zzz,zzz,zzz,zz9.99-'.
def shared var vsver    as decimal extent 8.
def shared var v-dat    as date.

def buffer p-crchis for txb.crchis.

def stream rpt.

define shared temp-table temp
    field gl        as integer format 'zzzzz9'
    field des       as char  format 'x(40)'
    field totgl     as integer format  'zzzzz9'
    field totlev    as integer format 'z9'
    field bal1      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* kzt */
    field bal2      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* usd */
    field bal3      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* eur */
    field bal4      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* rub */
    field bal5      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* gbp */
    field bal6      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* sek */
    field bal7      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* aud */
    field bal8      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* chf */
    field bal9      as deci format 'z,zzz,zzz,zzz,zz9.99-' /* ранды ЮАР */
    field bal10     as deci format 'z,zzz,zzz,zzz,zz9.99-' /* CAD */
    field baltot    as deci format 'z,zzz,zzz,zzz,zz9.99-'
    field usd       as integer init 0      .

def buffer b2-temp for temp.

output stream rpt to rpt1.img append.

for each bank.gl where bank.gl.ibfact = false no-lock break by bank.gl.type by bank.gl.gl   :
    assign vbal[1] = 0  vbal[2] = 0 vbal[3] = 0 vbal[4] = 0 vbal[5] = 0 vbal[6] = 0 vbal[7] = 0 vbal[8] = 0 vbal[9] = 0 vbal[10] = 0.

    if first(bank.gl.type) and  not flag then do:
        flag = true.
        for each bank.crc where bank.crc.sts ne 9 no-lock:
            find last bank.crchis where bank.crchis.crc = bank.crc.crc and bank.crchis.rdt <= v-dat no-lock no-error.

            displ bank.crc.crc label "ВАЛ." bank.crc.des label "НАЗВАНИЕ" bank.crchis.rate[1] format "zzz9.99" label "КУРС "
            bank.crchis.rate[9] format "zzzzzz9" label "РАЗМЕРНОСТЬ".

            put stream rpt unformatted bank.crc.crc " ; " bank.crc.des " ; " XLS-NUMBER(bank.crchis.rate[1]) " ; " XLS-NUMBER(bank.crchis.rate[9]) " ; "
            " " skip.
        end.
        find last bank.crchis where bank.crchis.crc = 1 and bank.crchis.rdt <= v-dat no-lock no-error.
    end.

    if lookup(bank.gl.type, "A,L,O,R,E") = 0 then next.

    find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.crc = 1 and txb.glday.gdt <= v-dat no-lock no-error.
    if available txb.glday then vbal[1] = vbal[1] + txb.glday.bal * rate9 / rate1.

    /* other currencies */
    for each bank.crc where bank.crc.crc > 1 and bank.crc.sts <> 9 no-lock:
        find last txb.glday where txb.glday.gl = bank.gl.gl and txb.glday.crc = bank.crc.crc and txb.glday.gdt <= v-dat no-lock no-error.
        if avail txb.glday then do:
            find last p-crchis where p-crchis.crc = txb.glday.crc and p-crchis.rdt <= v-dat no-lock no-error.
            if      txb.glday.crc = 2  then  vbal[2]  = vbal[2]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 4  then  vbal[3]  = vbal[3]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 3  then  vbal[4]  = vbal[4]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 6  then  vbal[5]  = vbal[5]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 7  then  vbal[6]  = vbal[6]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 8  then  vbal[7]  = vbal[7]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 9  then  vbal[8]  = vbal[8]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 10 then  vbal[9]  = vbal[9]  + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
            else if txb.glday.crc = 11 then  vbal[10] = vbal[10] + txb.glday.bal * (p-crchis.rate[1] * rate9 / rate1 * p-crchis.rate[9]).
        end.
    end.

    vbaltot = vbal[1]  + vbal[2] + vbal[3] + vbal[4] + vbal[5] + vbal[6] + vbal[7] + vbal[8] + vbal[9] + vbal[10].

    if bank.gl.vadisp  and (vbaltot <> 0 or can-do('185800,185900,285800,285900',string(bank.gl.gl))) then  do:
        find b2-temp where b2-temp.gl = bank.gl.gl no-lock no-error.
        if not available b2-temp then do:
            create temp.
            temp.gl     = bank.gl.gl.
            temp.des    = bank.gl.des.
            temp.totlev = bank.gl.totlev.
            temp.bal1   = vbal[1].
            temp.bal2   = vbal[2].
            temp.bal3   = vbal[3].
            temp.bal4   = vbal[4].
            temp.bal5   = vbal[5].
            temp.bal6   = vbal[6].
            temp.bal7   = vbal[7].
            temp.bal8   = vbal[8].
            temp.bal9   = vbal[9].
            temp.bal10  = vbal[10].
            temp.baltot = vbaltot.
        end.
        else do:
            b2-temp.bal1   = b2-temp.bal1 + vbal[1].
            b2-temp.bal2   = b2-temp.bal2 + vbal[2].
            b2-temp.bal3   = b2-temp.bal3 + vbal[3].
            b2-temp.bal4   = b2-temp.bal4 + vbal[4].
            b2-temp.bal5   = b2-temp.bal5 + vbal[5].
            b2-temp.bal6   = b2-temp.bal6 + vbal[6].
            b2-temp.bal7   = b2-temp.bal7 + vbal[7].
            b2-temp.bal8   = b2-temp.bal8 + vbal[8].
            b2-temp.bal9   = b2-temp.bal9 + vbal[9].
            b2-temp.bal10  = b2-temp.bal10 + vbal[10].
            b2-temp.baltot = b2-temp.baltot + vbaltot.
        end.
    end.
    /*сравнение лоро-ностро счетов*/
    if bank.gl.gl = 135100 then vsver[1] = vsver[1] + vbaltot /* vbal[4]*/.
    if bank.gl.gl = 215200 then vsver[2] = vsver[2] + vbaltot /*vbal[4]*/.
    if bank.gl.gl = 135200 then vsver[3] = vsver[3] + vbaltot /*vbal[4]*/.
    if bank.gl.gl = 215100 then vsver[4] = vsver[4] + vbaltot /*vbal[4]*/.
    /*--Валютная позиция, id00700, 14-05-2013*/
    if bank.gl.gl = 185800 then vsver[5] = vsver[5] + vbaltot.
    if bank.gl.gl = 285900 then vsver[6] = vsver[6] + vbaltot.
    if bank.gl.gl = 185900 then vsver[7] = vsver[7] + vbaltot.
    if bank.gl.gl = 285800 then vsver[8] = vsver[8] + vbaltot.
    /*Валютная позиция, id00700, 14-05-2013--*/

end. /*for each bank.gl.*/

output stream rpt close.


