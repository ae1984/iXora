/* s-loncon.p
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
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        02.12.2003 marinav - добавились шаблоны по движению залогов 67 и 68 , и добавился запрос валюты,
                             если проводка делается по этим шаблонам.
        13.01.2004 marinav - возможность возврата на тек счет клиента полученных штрафов lon0070
        11.02.2004 nadejda - при проведении списания по переоценке основной суммы кредита по LON0071 пишется история по 1 уровню
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        04/10/2004 madiyar - погашение ОД и %%, списанных в убыток (lon0094 и lon0095)
        14/10/2004 madiyar - изменился шаблон lon0077 (комиссия за неисп. кред. линию), внес соответствующие изменения
        08/12/2004 madiyar - изменил шаблон lon0084 - возврат комиссии за неисп кред линию
        14/12/2004 madiyar - списание штрафов с внебаланса (lon0100)
                             погашение штрафов, списанных в убыток (lon0101)
        30/12/2004 madiyar - возврат излишне полученных процентов (lon0102)
        06/01/2005 madiyar - при возврате ошибочно начисленных процентов (LON0034) пишется история по 2 уровню
        19/01/2005 madiyar - при переносе предоплаты на 1 уровень (LON0060) пишется история по 1 уровню
        10.06.2005 madiyar - шаблоны по возврату полученной индексации (lon0109,lon0110)
        01/08/2005 madiyar - при переносе предоплаты на 1 уровень (LON0060) некорректно определялась сумма, исправил
        13/01/2006 madiyar - разовые шаблоны lon00112, lon00113
        12.07.2006 Natalya D. - добавлена проверка юзера на наличие у него пакета прав, разрешающих проведение транзакций
        28/07/06  marinav  - обратока нового шаблона lon0120
        22/09/2006 madiyar - lon0034 изменился - передается и сумма в тенге
        08/09/2008 madiyar - lon0020,lon0022 и lon0031 - провизии в валюте кредита - передается код валюты
        08/07/2010 madiyar - расширил формат поля v-aaa в фрейме lon
        10/08/2010 aigul - добавила шаблоны списание гарантии и приход гарантии
        11/11/2010 madiyar - изменения в шаблонах по погашению спис. ОД и %% (lon0094, lon0095)
        03/12/2010 madiyar - проверка на непревышение одобр. суммы КЛ при создании лимитов
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        26/01/2011 madiyar - операции с доступными остатками КЛ возможны только по КЛ
        01/03/2011 madiyar - двойной контроль; выгрузка операций по залогам в AML
        03/03/2011 madiyar - поправил работу с операциями по залогам
        04/03/2011 madiyar - документы, созданные не сегодня, можно только просматривать
        28/03/2011 madiyar - доделал удаление/сторнирование
        29/03/2011 madiyar - перекомпиляция
        29/06/2011 madiyar - подправил проводки по шаблону lon0102
        05/10/2011 madiyar - новый шаблон lon0155 - списание комиссии (дисконт)
        27/11/2012 kapar - ASTANA-BONUS
        28/10/2013 Luiza   - ТЗ 1937 конвертация депозит
*/

def shared var g-lang as char.
def shared var g-ofc as char.
def shared var g-today as date.
def shared var s-lon like lon.lon.
def new shared var s-jh like jh.jh.

def var v-param as char.
def var rcode as int.
def var rdes as char.
def var vdel as char initial "^".
def var jparr as char.
def var vou-count as int.
def var i as int.
def var v-templ as char.
def var v-str as char.
def var v-balold as dec.
def var v-intold as dec.
def var v-rem as char.
def var v-f as log.

def var s-glrem2 as char.
def var s-glrem3 as char.
def var v-rem1 as char.
def var v-nxt as integer.
/*
def var s-aaa like aaa.aaa.
*/
def var glkomiss as integer.
def var sumkzt_now as deci.
def var sumkzt_before as deci.
def var sum as deci.

def var v-lim as deci no-undo.
def var v-rate as deci no-undo.

def var v-isgrant as logical no-undo.
def var v-grantacc as char no-undo.
def var v-grantsum as decimal no-undo.
def var v-jdt as date no-undo.
def var v-our as log no-undo.
def var v-lon as log no-undo.
def var v-finish as log no-undo.
def var v-cash as log no-undo.
def var v-lonour as log no-undo.
def var v-cashgl as int no-undo.
def var s-jhold as int no-undo.
def var v-sts as int no-undo.
def var v-fdt as date no-undo.
def var v-tdt as date no-undo.
def var v-dtmp as char no-undo.

/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
def var OK as logi initial false.

find first lon where lon.lon = s-lon no-error.
find first loncon where loncon.lon = lon.lon no-lock.
find first cif where cif.cif = lon.cif no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
if not avail crc then do:
    message "Не найдена валюта!" view-as alert-box error.
    return.
end.

v-rate = crc.rate[1].

v-rem1 = " " + s-lon + " " + loncon.lcnt + " " + trim(string(lon.opnamt,">>>,>>>,>>>,>>>,>>>,>>9.99-")) +
         " " + crc.code + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.


def var v-listitem as char.


DEFINE VARIABLE v-method AS char FORMAT "x(60)"
VIEW-AS COMBO-BOX.

def var v-cod as int.
def var v-system as char.
DEFINE VARIABLE l-templ AS CHARACTER.
find sysc where sysc.sysc eq "lontrx" no-lock no-error.

if available sysc then do:
l-templ = "".
v-str = sysc.chval.
do i = 1 to num-entries(v-str):
    v-templ = entry(i,v-str).
    v-cod = integer(v-templ) no-error.
    if error-status:error then do:
        v-cod = integer(substring(v-templ,4)) no-error.
        if error-status:error then v-cod = 0.
        v-system = substring(v-templ,1,3).
    end.
    else v-system = "LON".
    l-templ = l-templ + "," + v-system + string(v-cod,"9999").
end.
if l-templ ne "" then l-templ = substrin(l-templ,2).
end.
else l-templ = "LON0008,LON0009,LON0010,LON0023,LON0024,LON0025,LON0019,LON0020,LON0021,LON0022,LON0060".

v-listitem = "".
do i = 1 to num-entries(l-templ):
    v-templ = entry(i,l-templ).
    v-cod = integer(v-templ) no-error.
    if error-status:error then do:
        v-cod = integer(substring(v-templ,4)) no-error.
        if error-status:error then v-cod = 0.
        v-system = substring(v-templ,1,3).
    end.
    else v-system = "LON".
    find trxhead where trxhead.system = v-system and trxhead.code = v-cod no-lock no-error.
   if available trxhead then do:
        v-str = trxhead.des.
        do while index(v-str,",") <> 0:
            substring(v-str,index(v-str,","),1) = ";".
        end.
        v-listitem = v-listitem + "," + v-str.
    end.
end.

if v-listitem <> "" then v-listitem = substring(v-listitem,2).
def var v-amtprn as deci.
def var v-prnod  as deci.
def var v-prnbl  as deci.
def var v-bal    as deci.
def var v-bal12  as deci.

def var v-prnconv as deci.
def var v-prov as deci.
def var v-provs as deci.

def var v-int    as deci.
def var v-int11  as deci.
def var v-intod  as deci.
def var v-intoutbal as deci.
def var v-intcalc like lon.accrued.
def var v-intprepay as deci.
def var v-intall as deci.
def var dn1 as int.
def var dn2 like lon.accrued.

def var v-crccode like crc.code.
def var v-crc like crc.crc.
def var ja as log.
def button btn1 label "Ok".
def button btn2 label "Cancel".
def var v-code as char.
def var v-aaa as char.

def var v-docid as char no-undo.
def var v-ja as logi no-undo.
def var v_codfr as char init "5". /*код операций  табл codfr для doch.codfr */
def var v-docsts as char no-undo.
def var v-select as integer no-undo.
def var v-z as char no-undo.
def var v-zname as char no-undo.
def var v-zcount as integer no-undo.

function is_authorised returns logical (input user_id as char, input auth_list as char).
    def var v-perm as logi init no.
    def var i as integer.

    if lookup(user_id,auth_list) > 0 then v-perm = yes.
    else do:
        find first ofc where ofc.ofc = user_id no-lock no-error.
        if avail ofc then do:
            do i = 1 to num-entries(ofc.expr[1]):
                if lookup(entry(i,ofc.expr[1]),auth_list) > 0 then do: v-perm = yes. leave. end.
            end.
        end. /* if avail ofc */
    end.
    return v-perm.
end function.

def temp-table wrk no-undo
  field ln as integer
  field clname as char
  field zalogDes as char
  field zalogAddr as char
  field zalogCrc as integer
  field zalogAmt as deci
  index idx is primary ln.

define button b1 label "НОВЫЙ".
define button b2 label "НА КОНТРОЛЬ".
define button b3 label "ТРАНЗАКЦИЯ".
define button b4 label "ОРДЕР".
define button b5 label "УДАЛИТЬ".
define button b6 label "ОТКРЫТЬ".
define button b7 label "ВЫХОД".

define frame a2
    b6 b1 b2 b3 b4 b5 b7
    with centered side-labels row 4 column 5.

def frame lon
    "Документ " v-docid format "x(9)" validate(can-find(doch where doch.docid = v-docid no-lock), "Нет такого документа!")
    "  Статус " v-docsts format "x(3)"
    "Транзакция " at 50 s-jh format ">>>,>>>,>>9" skip
    "Кредит " s-lon
    "Валюта " at 25 v-crccode
    "Счет " at 50 v-aaa format "x(20)" skip
    "Остаток кредита    " v-bal format "zzz,zzz,zzz,zz9.99"
    "Проценты           " v-intall format "zzz,zzz,zzz,zz9.99-"
    skip
    "в том числе " skip
    "Основная сумма     " v-amtprn format "zzz,zzz,zzz,zz9.99"
    "Начисл.% (баланс)  " v-int format "zzz,zzz,zzz,zz9.99"
    skip
    "Просроченная сумма " v-prnod  format "zzz,zzz,zzz,zz9.99"
    "Просрочен. проценты" v-intod format "zzz,zzz,zzz,zz9.99"
    skip
    "Блокированная сумма" v-prnbl  format "zzz,zzz,zzz,zz9.99"
    "Предоплата процент." v-intprepay format "zzz,zzz,zzz,zz9.99"
    skip
    "Общие накопл.(KZT) " v-prov format "zzz,zzz,zzz,zz9.99"
    "Списанные проценты " at 40 v-intoutbal format "zzz,zzz,zzz,zz9.99"
    skip
    "Спец. накопл.(KZT) " v-provs format "zzz,zzz,zzz,zz9.99"
    "Начисл.%(внебаланс)" at 40 v-intcalc format "zzz,zzz,zzz,zz9.99"
    skip
    "Перенести сумму    " v-prnconv format "zzz,zzz,zzz,zz9.99"
    "Валюта проводки    " v-crc skip
    "Прим.1" at 7 v-rem format "x(320)" view-as fill-in size 60 by 1 skip
    "Прим.2" at 7 s-glrem2 format "x(320)" view-as fill-in size 60 by 1 skip
    "Прим.3" at 7 s-glrem3 format "x(320)" view-as fill-in size 60 by 1 skip
    with centered row 7 no-label.

def frame ln1 v-method v-templ skip with centered no-label.

assign v-method:list-items in frame ln1 = v-listitem.
v-templ = entry(1,l-templ).

on value-changed of v-method do:

    v-templ = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), l-templ).
    DISPLAY v-templ WITH FRAME ln1.
    v-code = "".

    find first trxtmpl where trxtmpl.code = v-templ and (trxtmpl.drsub = "lon" or trxtmpl.crsub = "lon") no-lock no-error.
    if available trxtmpl then do:
        if trxtmpl.drsub = "lon" then v-cod = trxtmpl.dev.
        else v-cod = trxtmpl.cev.
        if (v-cod = 1) or (v-cod = 7) or (v-cod = 8) then v-code = "LON".
        else
        if (v-cod = 2) or (v-cod = 9) or (v-cod = 10) then v-code = "INT".
        else v-code = "OTHER".
    end.
    if v-code = "LON" then do:
        v-rem = v-rem1.
        s-glrem2 = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), v-listitem).
        s-glrem3 = "".
    end.
    if v-code = "INT" then do:
        v-rem = v-rem1.
        s-glrem2 = "".
        s-glrem3 = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), v-listitem).
    end.
    if v-code = "OTHER" then do:
        v-rem = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), v-listitem) + v-rem1.
        s-glrem2 = "".
        s-glrem3 = "".
    end.
    displ v-rem s-glrem2 s-glrem3 with frame lon.
end.

/* новый */
on choose of b1 in frame a2 do:
    v-docid = "".
    run dochgen (output v-docid).
    if v-docid = "" then do:
        message "Ошибка генерации номера документа. Обратитесь к администратору." view-as alert-box error.
        return.
    end.

    v-docsts = 'new'.
    displ v-docid v-docsts with frame lon.

    v-templ = entry(1,l-templ).
    DISPLAY v-templ WITH FRAME ln1.
    APPLY "VALUE-CHANGED" TO v-method IN FRAME ln1.

    update v-method WITH FRAME ln1.

    /* приход или списание залога */
    if (v-templ = "lon0067") or (v-templ = "lon0068") then do:
        v-z = ''.
        v-zcount = 0.
        empty temp-table wrk.
        for each lonsec1 where lonsec1.lon = lon.lon no-lock:
            if (lonsec1.lonsec = 5) or (lonsec1.lonsec = 6) then next.
            create wrk.
            assign wrk.ln = lonsec1.ln
                   wrk.clname = lonsec1.pielikums[1]
                   wrk.zalogDes = trim(lonsec1.prm)
                   wrk.zalogAddr = trim(lonsec1.vieta)
                   wrk.zalogCrc = lonsec1.crc
                   wrk.zalogAmt = lonsec1.secamt.
        end.
        find first wrk no-lock no-error.
        {itemlist.i
            &file = "wrk "
            &frame = "width 110 row 6 centered scroll 1 24 down overlay title ' Выбор предмета залога '"
            &where = " yes "
            &flddisp = " wrk.ln label 'nn' format '>>9'
                         wrk.zalogDes label 'Обеспечение' format 'x(50)'
                         wrk.zalogCrc label 'Вал' format '>>9'
                         wrk.zalogAmt label 'Сумма' format '>>>,>>>,>>9.99'
                         wrk.clname label 'Залогодатель' format 'x(33)'
                       "
             &chkey = "ln"
             &chtype = "integer"
             &index  = "idx"
        }

        if avail wrk then do:
            v-z = string(wrk.ln).
            v-zname = trim(wrk.zalogDes) + ', ' + trim(wrk.zalogAddr).
            for each lonsec1zal where lonsec1zal.lon = lon.lon and lonsec1zal.ln = wrk.ln no-lock:
                v-zcount = v-zcount + 1.
            end.
            if v-zcount > 1 then v-zname = v-zname + ' (' + string(v-zcount) + " залогодат.)".
            v-prnconv = wrk.zalogAmt.
            v-crc = wrk.zalogCrc.
            displ v-prnconv v-crc with frame lon.
        end.
        if v-z = '' then do:
            message "Не выбрано обеспечение для прихода или списания!" view-as alert-box.
            return "exit".
        end.
        else
    end.

    if lookup(v-templ,"lon0137,lon0138,lon0139,lon0140,lon0141,lon0142") > 0 and lon.gua <> 'CL' then do:
        message "Операция только для кредитных линий!" view-as alert-box error.
        return.
    end.

    if lookup(v-templ,"lon0067,lon0068,lon0133,lon0134") > 0 then do:
        update v-prnconv view-as fill-in  v-crc
        v-rem    view-as fill-in
        s-glrem2 view-as fill-in
        s-glrem3 view-as fill-in with frame lon.
        v-param = string(v-prnconv) + vdel + string(v-crc) + vdel + lon.lon.
    end.
    else do:
        if lookup(v-templ,"lon0070,lon0102") > 0 then do:
            update v-aaa v-prnconv view-as fill-in
                v-rem    view-as fill-in
                s-glrem2 view-as fill-in
                s-glrem3 view-as fill-in with frame lon.
            v-param = string(v-prnconv) + vdel + lon.lon + vdel + string(v-aaa).
            if v-templ = "lon0102" then do:
                run lonbalcrc('lon',lon.lon,g-today,"12",yes,1,output v-bal12).
                v-bal12 = - v-bal12.
                if lon.crc <> 1 then do:
                    if v-prnconv * v-rate > v-bal12 then v-param = v-param + vdel + string(v-bal12).
                    else v-param = v-param + vdel + string(v-prnconv * v-rate).
                end.
                else do:
                    if v-prnconv > v-bal12 then v-param = v-param + vdel + string(v-bal12).
                    else v-param = v-param + vdel + string(v-prnconv).
                end.
            end.
        end.
        else do:
            /* 04/10/2004 madiyar - погашение ОД, %% и штрафов списанных в убыток */
            if lookup(v-templ,"lon0094,lon0095,lon0101,lon0109,lon0110,lon0112,lon0155") > 0 then do:
                /* запросить текущий счет клиента */
                /*
                s-aaa = v-aaa.
                update s-aaa label "Тек. счет" validate(can-find(aaa where aaa.aaa = s-aaa),"Некорректный счет клиента!") with centered row 7 overlay frame fr.
                */
                update v-aaa with frame lon.
            end.
            /* 04/10/2004 madiyar - end */

            if v-templ <> "lon0134" then
                update v-prnconv view-as fill-in
                    v-rem view-as fill-in
                    s-glrem2 view-as fill-in
                    s-glrem3
                    view-as fill-in with frame lon.

            if lookup(v-templ,"lon0137,lon0138") > 0 then do:
                run lonbalcrc('lon',lon.lon,g-today,"15,35",yes,lon.crc,output v-lim).
                v-lim = - v-lim + v-prnconv.
                if v-lim > lon.opnamt then do:
                    message lon.lon + " - Превышена одобренная сумма кредитной линии!" view-as alert-box error.
                    return.
                end.
            end.

            if lookup(v-templ,"lon0077,lon0084") > 0 then do:
                find first longrp where longrp.longrp = lon.grp no-lock no-error.
                glkomiss = 0.
                if avail longrp then do:
                    if substr(string(longrp.stn),1,1) = '1' then glkomiss = 442920.
                    if substr(string(longrp.stn),1,1) = '2' then glkomiss = 442910.
                end.
                if glkomiss = 0 then do:
                    message lon.lon + " - Проверьте настройку группы кредита!" view-as alert-box error.
                    return.
                end.
            end.

            v-param = string(v-prnconv) + vdel + lon.lon.

            if lookup(v-templ,"lon0020,lon0022,lon0031") > 0 then v-param = string(v-prnconv) + vdel + string(lon.crc) + vdel + lon.lon.

            if v-templ = "lon0155" then v-param = string(v-prnconv) + vdel + v-aaa + vdel + lon.lon.

            /* 22/09/2006 madiyar - возврат излишне начисленных процентов */
            if lookup(v-templ,"lon0034") > 0 then do:
                /* первые два пар-ра (сумма и сс. счет) уже добавлены, осталось добавить сумму в тенге */
                if lon.crc = 1 then v-param = v-param + vdel + string(v-prnconv).
                else do:
                    /* с 11-го уровня забираем сумму такую, чтобы остаток по текущему курсу соотв. остатку на 2-ом */
                    if v-prnconv > v-int then do:
                        message " Некорректная сумма! " view-as alert-box error.
                        return.
                    end.
                    v-param = v-param + vdel + string(v-int11 - (v-int - v-prnconv) * v-rate).
                end.
            end.
            /* 22/09/2006 madiyar - end */

            /* 10/06/2005 madiyar - возврат полученной индексации */
            if lookup(v-templ,"lon0109,lon0110") > 0 then do:
                /* первые два пар-ра (сумма и сс. счет) уже добавлены, осталось добавить тек. счет */
                v-param = v-param + vdel + v-aaa.
            end.
            /* 10/06/2005 madiyar - end */

            /* 12/01/2006 madiyar - разовый возврат */
            if lookup(v-templ,"lon0112") > 0 then do:
                /* первые два пар-ра (сумма и сс. счет) уже добавлены, осталось добавить тек. счет и сумму второй линии */
                v-param = v-param + vdel + v-aaa + vdel + string(v-prnconv).
            end.
            /* 12/01/2006 madiyar - end */

            /* погашение ОД и %% списанных в убыток */
            if lookup(v-templ,"lon0094,lon0095") > 0 then do:
                /* первые два пар-ра (сумма и сс. счет) уже добавлены */
                if lon.crc = 1 then v-param = v-param + vdel + string(v-prnconv) + vdel + v-aaa + vdel + '0' + vdel + '0'.
                else do:
                    v-param = v-param + vdel +
                              '0' + vdel +
                              v-aaa + vdel +
                              string(v-prnconv) + vdel +
                              string(round(v-prnconv * v-rate,2)).
                end.
            end.

            /* погашение штрафов, списанных в убыток */
            if v-templ = "lon0101" then do:
                /* первые два пар-ра (сумма и сс. счет) уже добавлены */
                v-param = v-param + vdel + string(v-prnconv) + vdel + v-aaa.
            end.


            /*Перенос % ASTANA в просроченные*/
            if v-templ = "lon0168" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.
            /*Списание излишне начисл.%% ASTANA (текущего года без конв)*/
            if v-templ = "lon0169" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.
            /*Списание (сторно) излишне начисл.%% ASTANA прошлых лет*/
            if v-templ = "lon0170" then do:
                v-param = string(v-prnconv) + vdel + '592100' + vdel + lon.lon.
            end.
            /*Доначисление процентов ASTANA*/
            if v-templ = "lon0171" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.
            /*Перенос просроченных процентов ASTANA в начисленные (49-50ур)*/
            if v-templ = "lon0172" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.
            /*Списание начисл. вознаграждения вне баланса ASTANA*/
            if v-templ = "lon0173" then do:
                v-param = string(v-prnconv) + vdel + '817000' + vdel + lon.lon.
            end.
            /*Перенос начисленного вознаграждения (ур. 2) в вознаграждение «ASTANA»*/
            if v-templ = "lon0174" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon + vdel +
                          string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.
            /*Перенос начисленного вознаграждения «ASTANA» в вознаграждение (ур. 2)*/
            if v-templ = "lon0175" then do:
                v-param = string(v-prnconv) + vdel + lon.lon + vdel + lon.lon + vdel +
                          string(v-prnconv) + vdel + lon.lon + vdel + lon.lon.
            end.


            /* 14/10/2004 madiyar - доначисление комиссии за неиспользованную кредитную линию */
            if v-templ = "lon0077" then do:
                if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel + string(glkomiss) + vdel + string(v-prnconv).
                else v-param = string(v-prnconv) + vdel + lon.lon + vdel + string(glkomiss) + vdel + "0".
            end.
            /* 09/08/2010 aigul - приход гарантии */
            if v-templ = "lon0133" then do:
                if lon.crc = 1 then v-param = string(v-prnconv) + vdel + string(lon.crc) + vdel + lon.lon + vdel +
                                              v-rem + vdel + s-glrem2 + vdel + s-glrem3 + vdel + '' + vdel + ''.
                else v-param = string(v-prnconv) + vdel + string(v-crc) + vdel + lon.lon + vdel +
                               v-rem + vdel + s-glrem2 + vdel + s-glrem3 + vdel + '' + vdel + ''.
            end.
            /* 09/08/2010 aigul - списание гарантии */

            if v-templ = "lon0134" then do:
                if lon.crc = 1 then v-param = string(v-prnconv) + vdel + string(lon.crc) + vdel + lon.lon + vdel +
                                              v-rem + vdel + s-glrem2 + vdel + s-glrem3 + vdel + '' + vdel + ''.
                else v-param = string(v-prnconv) + vdel + string(v-crc) + vdel + lon.lon + vdel +
                               v-rem + vdel + s-glrem2 + vdel + s-glrem3 + vdel + '' + vdel + ''.
            end.

            if v-templ = "lon0084" then do:
                if lon.crc = 1 then v-param = string(v-prnconv) + vdel + string(glkomiss) + vdel + lon.lon + vdel + "0" + vdel + "0" + vdel + "0" + vdel + "0".
                else do:
                    v-param = "0" + vdel + string(glkomiss) + vdel + lon.lon.
                    sumkzt_now = v-prnconv * v-rate.
                    sumkzt_before = 0. sum = 0.
                    for each lonres where lonres.lon = lon.lon and lonres.lev = 25 and lonres.dc = "D" no-lock break by lonres.jdt desc:
                        if sum + lonres.amt < v-prnconv then do:
                            sum = sum + lonres.amt.
                            find last crchis where crchis.crc = lon.crc and crchis.regdt <= lonres.jdt no-lock no-error.
                            sumkzt_before = sumkzt_before + lonres.amt * crchis.rate[1].
                        end.
                        else do:
                            find last crchis where crchis.crc = lon.crc and crchis.regdt <= lonres.jdt no-lock no-error.
                            sumkzt_before = sumkzt_before + (v-prnconv - sum) * crchis.rate[1].
                            sum = v-prnconv.
                            leave.
                        end.
                    end.

                    if sum < v-prnconv then do:
                        message " Ошибка! Возвращаемая сумма больше начисленных комиссий " view-as alert-box buttons ok.
                        return.
                    end.
                    else do:
                        run lonbalcrc('lon',lon.lon,g-today,"25",yes,lon.crc,output sum).
                        if sum < v-prnconv then do:
                            message " Ошибка! Возвращаемая сумма больше начисленных комиссий " view-as alert-box buttons ok.
                            return.
                        end.
                    end.

                    if sumkzt_now > sumkzt_before then v-param = v-param + vdel +
                                                                 string(sumkzt_before) + vdel +
                                                                 string(sumkzt_now - sumkzt_before) + vdel +
                                                                 string(v-prnconv) + vdel +
                                                                 "0".
                    else v-param = v-param + vdel +
                                   string(sumkzt_now) + vdel +
                                   "0" + vdel +
                                   string(v-prnconv) + vdel +
                                   string(sumkzt_before - sumkzt_now).
                end.
            end.
            if v-templ = "lon0120" then do:
                v-param = string(round(v-amtprn / v-prnconv,2)) + vdel +
                          string(v-amtprn) + vdel +
                          lon.lon + vdel +
                          string(round(v-int / v-prnconv,2)) + vdel +
                          string(v-int) + vdel +
                          string(v-int11) + vdel +
                          string(v-provs) .
            end.
            /* доначисление процентов */
            if v-templ = "lon0061" then do:
                if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel +
                      string(v-prnconv) + vdel + lon.lon.
                else v-param = string(v-prnconv) + vdel + lon.lon + vdel +
                      "0" + vdel + lon.lon .
            end.
        end.
    end.

    v-f = no.
    for each trxtmpl where trxtmpl.code = v-templ no-lock:
        if trxtmpl.rem-f[1] = "r" or
           trxtmpl.rem-f[2] = "r" or
           trxtmpl.rem-f[3] = "r" or
           trxtmpl.rem-f[4] = "r" or
           trxtmpl.rem-f[5] = "r" then v-f = yes.
    end.
    if v-f then do:
        do while index(v-rem,vdel) <> 0 :
            substring(v-rem,index(v-rem,vdel),1) = " ".
        end.
        v-param = v-param + vdel + v-rem + vdel + s-glrem2 + vdel + s-glrem3 + vdel + "" + vdel  + "".
    end.

    /*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
    run usrrights.
    if return-value <> '1' then do:
        message "У Вас нет прав для создания транзакции!" view-as alert-box.
        return "exit".
    end.

    v-ja = yes.
    message "Отправить на контроль?" view-as alert-box buttons yes-no update v-ja.

    do transaction:
        create doch.
        doch.docid = v-docid.
        doch.rdt = g-today.
        doch.rtim = time.
        doch.rwho = g-ofc.
        if v-ja then doch.sts = "sen".
        else doch.sts = "new".
        doch.templ = v-templ.
        doch.delim = vdel.
        doch.param1 = v-param.
        doch.sub = "lon".
        doch.acc = lon.lon.
        doch.codfr =  v_codfr.
        doch.info[1] = v-aaa + "|" + string(v-prnconv) + "|" + string(v-crc) + "|" + replace(v-rem,"|",'') + "|" + replace(s-glrem2,"|",'') + "|" + replace(s-glrem3,"|",'').
        if (v-templ = "lon0067") or (v-templ = "lon0068") then do:
            doch.info[2] = v-z.
            doch.info[3] = v-zname.
        end.
        /*
        v-rdt =  doch.rdt.
        v-rtim = doch.rtim.
        */
        find current doch no-lock.
        run trxsim (v-docid, v-templ, vdel, v-param, 4, output rcode, output rdes, output jparr).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            undo.
            next.
        end.
        run doch_hist(v-docid).
     end. /*end trans-n*/
     v-docsts = doch.sts.
     displ v-docsts with frame lon.
     if v-ja then run pr_doch_order(v-docid,doch.rdt,doch.rtim,doch.rwho).
end.

/* на контроль */
on choose of b2 in frame a2 do:
    if not avail doch then return.

    if doch.rdt <> g-today then do:
        message "Документ создан не сегодня, отправка на контроль запрещена!" view-as alert-box.
        return.
    end.

    if doch.sts <> 'new' then do:
        if doch.sts = "trx" then message "Документ уже проведен, номер проводки: " + string(doch.jh) view-as alert-box.
        else
        if doch.sts = "acc" then message "Документ уже акцептован" view-as alert-box.
        else
        if doch.sts = "sen" then message "Документ уже отправлен на контроль" view-as alert-box.
        else
        if doch.sts = "rej" then message "Отказано в проводке" view-as alert-box.
        else
        if doch.sts = "del" then message "Проводка удалена" view-as alert-box.
        else
        if doch.sts = "str" then message "Проводка сторнирована" view-as alert-box.
        else message "Некорректный статус документа для отправки на контроль" view-as alert-box.
        return.
    end.

    do transaction:
        find current doch exclusive-lock.
        doch.sts = "sen".
        find current doch no-lock.
        run doch_hist(doch.docid).
    end. /*end transac*/
    v-docsts = doch.sts.
    displ v-docsts with frame lon.
    /*
    find dochhelp where dochhelp.docid = c-docid no-lock no-error.
    if available dochhelp then delete dochhelp.
    */
    run pr_doch_order(doch.docid, doch.rdt, doch.rtim, doch.rwho).
end.

/* транзакция */
on choose of b3 in frame a2 do:
    if not avail doch then return.

    if doch.rdt <> g-today then do:
        message "Документ создан не сегодня, создание проводки запрещено!" view-as alert-box.
        return.
    end.

    if doch.sts <> 'acc' then do:
        if doch.sts = "trx" then message "Документ уже проведен, номер проводки: " + string(doch.jh) view-as alert-box.
        else
        if doch.sts = "new" then message "Документ не отправлен на контроль" view-as alert-box.
        else
        if doch.sts = "sen" then message "Документ еще не акцептован" view-as alert-box.
        else
        if doch.sts = "rej" then message "Отказано в проводке" view-as alert-box.
        else
        if doch.sts = "del" then message "Проводка удалена" view-as alert-box.
        else
        if doch.sts = "str" then message "Проводка сторнирована" view-as alert-box.
        else message "Некорректный статус документа для проводки" view-as alert-box.
        return.
    end.

    v-ja = no.
    message "Создать проводку?" view-as alert-box update v-ja.
    if not v-ja then return.

    v-param = doch.param1.
    v-templ = doch.templ.
    vdel = doch.delim.

    /* ja - EKNP - 26/03/2002 --------------------------------------------*/
    run Collect_Undefined_Codes(v-templ).
    run Parametrize_Undefined_Codes(output OK).
    if not OK then do:
        bell.
        message "Не все коды введены! Транзакция не будет создана!" view-as alert-box.
        return "exit".
    end.

    run Insert_Codes_Values(v-templ, vdel, input-output v-param).
    /* ja - EKNP - 26/03/2002 --------------------------------------------*/

    /* собственно транзакция */
    do transaction on error undo, return:
        s-jh = 0.
        /*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
        run usrrights.
        if return-value = '1' then do:
            run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            run lonresadd(s-jh).
        end.
        else do:
            message "У Вас нет прав для создания транзакции!" view-as alert-box.
            return "exit".
        end.

        if v-templ = "lon0071" or v-templ = "lon0060" or v-templ = "lon0120" then do:
            /* сделать запись в истории 1 уровня */
            v-nxt = 0.
            for each lnsch where lnsch.lnn = lon.lon no-lock:
                if lnsch.f0 = 0 and lnsch.flp > 0 then do:
                    if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                end.
            end.
            v-nxt = v-nxt + 1.

            find first jl where jl.jh = s-jh and jl.acc = lon.lon and jl.lev = 1 and jl.dc = 'C' no-lock no-error.

            create lnsch.
            assign lnsch.lnn = lon.lon
                   lnsch.f0 = 0
                   lnsch.flp = v-nxt
                   lnsch.schn = "   . ." + string(v-nxt, "zzzz")
                   lnsch.paid = jl.cam
                   lnsch.stdat = jl.jdt
                   lnsch.jh = jl.jh
                   lnsch.whn = jl.whn
                   lnsch.who = jl.who.
        end.

        if v-templ = "lon0034" or v-templ = "lon0120" then do:
            /* сделать запись в истории 2 уровня */
            v-nxt = 0.
            for each lnsci where lnsci.lni = lon.lon no-lock:
                if lnsci.f0 = 0 and lnsci.flp > 0 then do:
                    if v-nxt < lnsci.flp then v-nxt = lnsci.flp.
                end.
            end.
            v-nxt = v-nxt + 1.

            find first jl where jl.jh = s-jh and jl.acc = lon.lon and jl.lev = 2 and jl.dc = 'C' no-lock no-error.

            create lnsci.
            assign lnsci.lni = lon.lon
                   lnsci.f0 = 0
                   lnsci.flp = v-nxt
                   lnsci.schn = "   . ." + string(v-nxt, "zzzz")
                   lnsci.paid = jl.cam
                   lnsci.idat = jl.jdt
                   lnsci.jh = jl.jh
                   lnsci.whn = jl.whn
                   lnsci.who = jl.who.
        end.

        find current doch exclusive-lock.
        doch.jh = s-jh.
        doch.sts = "trx".
        find current doch no-lock.

        run doch_hist(doch.docid).

    end.

    v-docsts = doch.sts.
    displ v-docsts s-jh with frame lon.
    find first jh where jh.jh = s-jh no-lock no-error.

    /* pechat vauchera */
    ja = no.
    vou-count = 1. /* kolichestvo vaucherov */

    do on endkey undo:
        message "Печатать ваучер ?" update ja.
        if ja then do:
            message "Сколько ?" update vou-count.
            if vou-count > 0 and vou-count < 10 then do:
                find first jl where jl.jh = s-jh no-lock no-error.
                if available jl then do:
                    s-jh = jh.jh.
                    do i = 1 to vou-count:
                        run vou_lon(s-jh,'').
                    end.

                    do transaction:
                        find current jh exclusive-lock.
                        if jh.sts < 5 then jh.sts = 5.
                        find current jh no-lock.

                        for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                        release jl.
                    end.

                end.  /* if available jl */
                else do:
                    message "Can't find transaction " s-jh view-as alert-box.
                    return.
                end.
            end.  /* if vou-count > 0 */
        end. /* if ja */
        pause 0.
    end.

    pause 0.
    view frame lon.
    view frame ln1.
end.

/* повторная печать ордера для контролера */
on choose of b4 in frame a2 do:
    if not avail doch then return.

    if doch.rdt <> g-today then do:
        message "Документ создан не сегодня!" view-as alert-box.
        return.
    end.

    if doch.sts <> 'sen' then do:
        if doch.sts = "trx" then message "Документ уже проведен, номер проводки: " + string(doch.jh) view-as alert-box.
        else
        if doch.sts = "acc" then message "Документ уже акцептован" view-as alert-box.
        else
        if doch.sts = "new" then message "Документ не отправлен на контроль" view-as alert-box.
        else
        if doch.sts = "rej" then message "Отказано в проводке" view-as alert-box.
        else
        if doch.sts = "del" then message "Проводка удалена" view-as alert-box.
        else
        if doch.sts = "str" then message "Проводка сторнирована" view-as alert-box.
        else message "Некорректный статус документа для повторной печати ордера на контроль" view-as alert-box.
        return.
    end.

    run pr_doch_order(doch.docid, doch.rdt, doch.rtim, doch.rwho).
end.

/* удаление */
on choose of b5 in frame a2 do:
    if not avail doch then return.

    if doch.sts <> 'trx' then do:
        message "Проводки для удаления нет" view-as alert-box.
        return.
    end.

    find first jl where jl.jh = doch.jh no-lock no-error.
    if not avail jl then do:
        message "Не найдены линии проводки!" view-as alert-box.
        return.
    end.

    /*
    message "Удаление проводки пока не работает!" view-as alert-box.
    */

    s-jhold = doch.jh.
    find sysc where sysc.sysc = "cashgl" no-lock no-error.
    v-cashgl = sysc.inval.

    def var lntrxstor_enabled as logi no-undo init no.
    def var lntrxstor_list as char no-undo init ''.
    find first sysc where sysc.sysc = "lntrxstor" no-lock no-error.
    if avail sysc then assign lntrxstor_enabled = sysc.loval lntrxstor_list = sysc.chval.

    do transaction on error undo, return:
        v-jdt = g-today.
        v-our = yes.
        v-lonour = no.

        find first jh where jh.jh = s-jhold no-lock no-error.

        for each jl where jl.jh = s-jhold no-lock:
            if jl.sts = 6 then v-finish = yes.
            if jl.gl = v-cashgl then v-cash = yes.
            if jl.jdt <> g-today then v-jdt = jl.jdt.
            if jl.who <> g-ofc then v-our = no.
            if jl.acc = s-lon then v-lonour = yes.
        end.

        /* если включена возможность сторнирования проводок банкадма у юзеров из справочника - редактируем v-our */
        if lntrxstor_enabled then
            if not v-our then v-our = (jh.who = "bankadm" and jh.jdt <> g-today and is_authorised(g-ofc,lntrxstor_list)).

        if not v-our then do:
            message "Вы не можете удалить чужую транзакцию" view-as alert-box information buttons ok.
            return.
        end.

        if v-finish and v-cash then do:
            message "Вы не можете удалить выполненную кассовую транзакцию" view-as alert-box information buttons ok.
            return.
        end.

        if not v-lonour then do:
            message "Транзакция не связана с кредитом. Удаление невозможно" view-as alert-box information buttons ok.
            return.
        end.

        ja = no.
        if v-jdt <> g-today then do :
            message "Транзакция не текущего дня. Выполнить сторно?" view-as alert-box question buttons yes-no update ja.
            if not ja then return.
        end.

        /* это проводка на выдачу? */
        find first jl where jl.jh = s-jhold and jl.acc = s-lon and jl.sub = "lon" and jl.dc = "d" and jl.lev = 1 no-lock no-error.
        v-isgrant = (jh.party begins "GRANT OF LOAN") and (avail jl).

        find first jl where jl.jh = s-jhold and jl.sub = "cif" and jl.dc = "c" and jl.lev = 1 no-lock no-error.
        v-isgrant = v-isgrant and (avail jl).

        if v-isgrant then do:
            v-grantacc = jl.acc.
            v-grantsum = jl.cam.
        end.

        if v-jdt = g-today then do:
            v-sts = 0.
            run trxsts(input s-jhold, input v-sts, output rcode, output rdes).
            if rcode <> 0 then do:
                message rdes view-as alert-box.
                return.
            end.
            run trxdel(input s-jhold, input true, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes view-as alert-box.
                return.
            end.

            for each lnsch where lnsch.lnn = s-lon and lnsch.jh = s-jhold exclusive-lock:
                delete lnsch.
            end.
            for each lnsci where lnsci.lni = s-lon and lnsci.jh = s-jhold exclusive-lock:
                delete lnsci.
            end.
            for each lnscg where lnscg.lng = s-lon and lnscg.jh = s-jhold exclusive-lock:
                delete lnscg.
            end.
            for each lonres where lonres.lon = s-lon and lonres.jh = s-jhold exclusive-lock:
                if lonres.dc = "D" and lonres.lev = 2 then do:
                    do i = 2 to num-entries(lonres.rem) by 2:
                        v-dtmp = entry(i,lonres.rem).
                        v-fdt = ?.
                        v-tdt = ?.
                        if length(v-dtmp) = 8 then do:
                            v-tdt = date(integer(substring(v-dtmp,5,2)),integer(substring(v-dtmp,7,2)),integer(substring(v-dtmp,1,4))) no-error.
                        end.
                        find acr where acr.lon = s-lon and acr.tdt = v-tdt exclusive-lock no-error.
                        if available acr then do:
                            acr.sts = 0.
                            release acr.
                        end.
                    end.
                end.
                delete lonres.
            end.
            find current doch exclusive-lock.
            doch.sts = "del".
            doch.jh = 0.
            find current doch no-lock.
            run doch_hist(doch.docid).
            v-docsts = doch.sts.
            s-jh = doch.jh.
            displ v-docsts s-jh with frame lon.
        end.
        else do:
            v-sts = 0.
            run trxstor(input s-jhold, input v-sts, output s-jh, output rcode, output rdes).
            if rcode <> 0 then do:
                message rdes view-as alert-box.
                return.
            end.

            for each lnsch where lnsch.lnn = s-lon and lnsch.jh = s-jhold exclusive-lock:
                delete lnsch.
            end.
            for each lnsci where lnsci.lni = s-lon and lnsci.jh = s-jhold exclusive-lock:
                delete lnsci.
            end.
            for each lnscg where lnscg.lng = s-lon and lnscg.jh = s-jhold exclusive-lock:
                delete lnscg.
            end.
            for each lonres where lonres.lon = s-lon and lonres.jh = s-jhold exclusive-lock:
                if lonres.dc = "D" and lonres.lev = 2 then do:
                    do i = 2 to num-entries(lonres.rem) by 2:
                        v-dtmp = entry(i,lonres.rem).
                        v-fdt = ?.
                        v-tdt = ?.
                        if length(v-dtmp) = 8 then do:
                            v-tdt = date(integer(substring(v-dtmp,5,2)),integer(substring(v-dtmp,7,2)),integer(substring(v-dtmp,1,4))) no-error.
                        end.
                        find acr where acr.lon = s-lon and acr.tdt = v-tdt exclusive-lock no-error.
                        if available acr then do:
                            acr.sts = 0.
                            release acr.
                        end.
                    end.
                end.
                delete lonres.
            end.

            /* pechat vauchera */
            ja = no.
            vou-count = 1. /* kolichestvo vaucherov */
            find jh where jh.jh = s-jh no-lock no-error.
            do on endkey undo:
                message "Печатать ваучер? " + string(s-jh) view-as alert-box buttons yes-no update ja.
                if ja then do:
                    message "Сколько ?" update /* view-as alert-box set */ vou-count.
                    if vou-count > 0 and vou-count < 10 then do:
                        find first jl where jl.jh = s-jh no-lock no-error.
                        if available jl then do:
                            {mesg.i 0933} s-jh.
                            do i = 1 to vou-count:
                                run x-jlvou.
                            end.

                            if jh.sts < 5 then jh.sts = 5.
                            for each jl of jh exclusive-lock:
                                if jl.sts < 5 then jl.sts = 5.
                            end.
                        end.  /* if available jl */
                        else do:
                            message "Can't find transaction " s-jh view-as alert-box.
                            return.
                        end.
                    end.  /* if vou-count > 0 */
                end. /* if ja */
                pause 0.
            end.
            pause 0.
            ja = no.
            message "Штамповать ?" update ja.
            if ja then run jl-stmp.
            find current doch exclusive-lock.
            doch.sts = "str".
            find current doch no-lock.
            run doch_hist(doch.docid).
            v-docsts = doch.sts.
            displ v-docsts with frame lon.
        end.

        /* если это проводка на выдачу - снять специнструкцию */
        if v-isgrant then run jou-aasdel (v-grantacc, v-grantsum, s-jhold).
    end.

    message "Проводка удалена/сторнирована!" view-as alert-box information.

end.

/* открыть */
on choose of b6 in frame a2 do:
    update v-docid with frame lon.
    find first doch where doch.docid = v-docid no-lock no-error.
    if not avail doch then do: v-docid = ''. return. end.
    if (doch.sub <> 'lon') or (doch.codfr <> v_codfr) then do:
        message "Не кредитная операция!" view-as alert-box error.
        v-docid = ''.
        return.
    end.
    if (doch.acc <> lon.lon) then do:
        message "Операция не по этому займу!" view-as alert-box error.
        v-docid = ''.
        return.
    end.
    if (doch.rwho <> g-ofc) then do:
        message "Не ваша операция!" view-as alert-box error.
        v-docid = ''.
        return.
    end.
    v-templ = doch.templ.
    v-method = entry(lookup(v-templ,l-templ),v-listitem).
    displ v-method with frame ln1.
    apply "value-changed" to v-method in frame ln1.
    /*


    v-method = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), l-templ).
    ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE), v-listitem).
    */

    v-docsts = doch.sts.
    s-jh = doch.jh.
    v-aaa = entry(1,doch.info[1],'|').
    if num-entries(doch.info[1],'|') > 1 then v-prnconv = deci(entry(2,doch.info[1],'|')) no-error.
    if num-entries(doch.info[1],'|') > 2 then v-crc = integer(entry(3,doch.info[1],'|')) no-error.
    if num-entries(doch.info[1],'|') > 3 then v-rem = entry(4,doch.info[1],'|').
    if num-entries(doch.info[1],'|') > 4 then s-glrem2 = entry(5,doch.info[1],'|').
    if num-entries(doch.info[1],'|') > 5 then s-glrem3 = entry(6,doch.info[1],'|').
    displ v-docsts s-jh v-aaa v-prnconv v-crc v-rem s-glrem2 s-glrem3 with frame lon.

end.

view frame a2.

find first lon where lon.lon = s-lon no-lock no-error.
find first crc where crc.crc = lon.crc no-lock no-error.
v-crccode = crc.code.
v-crc = lon.crc.

v-prov = 0.
v-provs = 0.
for each trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon no-lock:
  if trxbal.lev = 1 then v-amtprn = trxbal.dam - trxbal.cam.
  if trxbal.lev = 7 then v-prnod = trxbal.dam - trxbal.cam.
  if trxbal.lev = 8 then v-prnbl = trxbal.dam - trxbal.cam.
  if trxbal.lev = 3 then do:
      if trxbal.crc <> 1 then do:
          find crc where crc.crc = trxbal.crc no-lock no-error.
          if available crc then v-prov = v-prov + (trxbal.cam - trxbal.dam) * crc.rate[1] / crc.rate[9].
      end.
      else v-prov = v-prov + (trxbal.cam - trxbal.dam).
  end.
  if trxbal.lev = 6 then do:
      if trxbal.crc <> 1 then do:
          find crc where crc.crc = trxbal.crc no-lock no-error.
          if available crc then v-provs = v-provs + (trxbal.cam - trxbal.dam) * crc.rate[1] / crc.rate[9].
      end.
      else v-provs = v-provs + (trxbal.cam - trxbal.dam).
  end.
  if trxbal.lev = 2 then v-int = trxbal.dam - trxbal.cam.
  if trxbal.lev = 9 then v-intod = trxbal.dam - trxbal.cam.
  if trxbal.lev = 10 then v-intprepay = trxbal.cam - trxbal.dam.
  if trxbal.lev = 13 then v-intoutbal = trxbal.dam - trxbal.cam.
  if trxbal.lev = 11 then v-int11 = trxbal.cam - trxbal.dam.
end.

v-bal = v-amtprn + v-prnod + v-prnbl.
v-balold = v-bal.
v-intold = v-int + v-intod - v-intprepay.
v-intcalc = 0.

for each acr of lon where acr.sts = 0 no-lock:
    run day-360(acr.fdt,acr.tdt,lon.basedy,output dn1,output dn2).
    v-intcalc = v-intcalc + round((dn1 * acr.prn * acr.rate / 100 / lon.basedy) , 2).
end.

v-intall = v-int + v-intod + v-intoutbal + v-intcalc - v-intprepay.

/* поиск текущего счета клиента с той же валютой что и кредит */
find first aaa where aaa.cif = lon.cif and aaa.crc = lon.crc and aaa.lgr begins '1' no-lock no-error.
if avail aaa then v-aaa = aaa.aaa.
             else v-aaa = "".

displ v-docid v-docsts s-jh s-lon v-crccode v-aaa v-bal v-amtprn v-prnbl v-prnod v-prov
      v-provs v-intall v-int v-intod v-intoutbal v-intcalc v-intprepay
with frame lon.





enable all with frame a2.
wait-for window-close of frame a2 or choose of b7 in frame a2.





/*ja - EKNP - 26/03/2002 -------------------------------------------*/
Procedure Collect_Undefined_Codes.

    def input parameter c-templ as char.
    def var vjj as inte.
    def var vkk as inte.
    def var ja-name as char.

    for each w-cods:
        delete w-cods.
    end.
    for each trxhead where trxhead.system = substring (c-templ, 1, 3) and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:

        if trxhead.sts-f eq "r" then vjj = vjj + 1.
        if trxhead.party-f eq "r" then vjj = vjj + 1.
        if trxhead.point-f eq "r" then vjj = vjj + 1.
        if trxhead.depart-f eq "r" then vjj = vjj + 1.
        if trxhead.mult-f eq "r" then vjj = vjj + 1.
        if trxhead.opt-f eq "r" then vjj = vjj + 1.

        for each trxtmpl where trxtmpl.code eq c-templ no-lock:
            if trxtmpl.amt-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crc-f eq "r" then vjj = vjj + 1.
            if trxtmpl.rate-f eq "r" then vjj = vjj + 1.
            if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.
            if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.
            if trxtmpl.dev-f eq "r" then vjj = vjj + 1.
            if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.
            if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.
            if trxtmpl.cev-f eq "r" then vjj = vjj + 1.
            if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.

            repeat vkk = 1 to 5:
                if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
            end.

            for each trxcdf where trxcdf.trxcode = trxtmpl.code and trxcdf.trxln = trxtmpl.ln:
                if trxcdf.drcod-f eq "r" then do:
                    vjj = vjj + 1.

                    find first trxlabs where trxlabs.code = trxtmpl.code
                                             and trxlabs.ln = trxtmpl.ln
                                             and trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.

                    create w-cods.
                           w-cods.template = c-templ.
                           w-cods.parnum = vjj.
                           w-cods.codfr = trxcdf.codfr.
                           w-cods.name = ja-name.
                end.

                if trxcdf.crcode-f eq "r" then do:
                    vjj = vjj + 1.

                    find first trxlabs where trxlabs.code = trxtmpl.code
                                             and trxlabs.ln = trxtmpl.ln
                                             and trxlabs.fld = trxcdf.codfr + "_Cr" no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.
                    create w-cods.
                    w-cods.template = c-templ.
                    w-cods.parnum = vjj.
                    w-cods.codfr = trxcdf.codfr.
                    w-cods.name = ja-name.
                end.
            end.
        end. /*for each trxtmpl*/
    end. /*for each trxhead*/

end procedure.



Procedure Parametrize_Undefined_Codes.

  def var ja-nr as inte.
  def output parameter OK as logi initial false.
  def var jrcode as inte.
  def var saved-val as char.

  find first w-cods no-error.
  if not available w-cods then do:
    OK = true.
    return.
  end.

  {jabrew.i
   &start = " on help of w-cods.val in frame lon_cods do:
               if w-cods.codfr = 'spnpl' then run uni_help1(w-cods.codfr,'4*').
                                         else run uni_help1(w-cods.codfr,'*').
              end.
              vkey = 'return'.
              key-i = 0. "

   &head = "w-cods"
   &headkey = "parnum"
   &where = "true"
   &formname = "lon_cods"
   &framename = "lon_cods"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
   &predisplay = " ja-nr = ja-nr + 1. "
   &display = "ja-nr /*w-cods.codfr*/ w-cods.name /*w-cods.what*/ w-cods.val"
   &highlight = "ja-nr"
   &postkey = "else if vkeyfunction = 'return' then do:
               valid:
               repeat:
                saved-val = w-cods.val.
                update w-cods.val with frame lon_cods.
                find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                if not available codfr or codfr.code = 'msc' then do:
                   bell.
                   message 'Некорректное значение кода! Введите правильно!'
                           view-as alert-box.
                   w-cods.val = saved-val.
                   display w-cods.val with frame lon_cods.
                   next valid.
                end.
                else leave valid.
               end.
                if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                  key-i = 0.
                  vkey = 'cursor-down^return'.
                end.
               end.
               else if keyfunction(lastkey) = 'GO' then do:
                   jrcode = 0.
                 for each w-cods:
                  find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                  if not available codfr or codfr.code = 'msc' then jrcode = 1.
                 end.
                 if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                 end.
                 else do: OK = true. leave upper. end.
               end."
   &end = "hide frame lon_cods.
           hide message."
   }

end procedure.

Procedure Insert_Codes_Values.

    def input parameter t-template as char.
    def input parameter t-delimiter as char.
    def input-output parameter t-par-string as char.
    def var t-entry as char.

    for each w-cods where w-cods.template = t-template break by w-cods.parnum:
        t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
        if ERROR-STATUS:error then t-par-string = t-par-string + t-delimiter + w-cods.val.
        else do:
            entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
            entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
        end.
    end.

end procedure.

procedure dochgen. /*генерация номера след документа */
    def output parameter v-docid as char format "x(9)".
    def var num1 as int.
    find first nmbr where nmbr.code = "JOU" no-lock no-error.
    do transaction:
        num1 = NEXT-VALUE(dochnum).
        v-docid = "D" + string(num1, "9999999") + caps(nmbr.prefix).
    end.
end procedure.

/*
procedure prn_order.
    def input parameter prn_docid as char format "x(9)".
    def input parameter dtreg as date format "99/99/9999".
    def input parameter dtime as int.

    def var numln as int no-undo.
    def var prn_des as char format "x(25)" no-undo.
    def var prn_gl as int format "999999" no-undo.
    def var prn_crc as int no-undo.
    def var prn_kzt as char no-undo.
    def var prn_amt as decimal no-undo.
    def var total-dam as decimal no-undo.
    def var total-cam as decimal no-undo.
    def var p_name as char no-undo.
    def var p_addr as char no-undo.
    def var ofc_name as char no-undo.
    def var prn_code as char format "x(20)" no-undo.
    def var prn_rem1 as char format "x(60)" no-undo.

    for each point no-lock.
        p_name = point.name.
        p_addr =  point.addr[1].
    end.
    for each ofc where ofc.ofc = g-ofc no-lock.
        ofc_name = ofc.name.
    end.

    output to value("uni.img") page-size 0.

    for each cmp no-lock:
        put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР (для контроля)" skip.
        put "=========================================================================================="
            skip
            cmp.name space(23)
            dtreg format "99/99/9999" " " string(dtime,"HH:MM") skip
            "БИН" + cmp.addr[2] + "," + cmp.addr[3] format "x(60)" skip.
        put p_name format "x(50)" skip.
        put p_addr format "x(50)" skip.
        put "Ном.докум. " + prn_docid + "   /" + ofc_name  format "x(78)" skip.
        put "=========================================================================================="
            skip.
    end.

    numln = 0.
    total-dam = 0.
    total-cam = 0.
    for each docl where  docl.docid = prn_docid no-lock.
        numln = numln + 1.
        prn_amt = 0.
        if docl.dc="D" then do:
            prn_amt = docl.dam.
            total-dam = total-dam + docl.dam.
        end.
        else do:
            prn_amt = docl.cam.
            total-cam = total-cam + docl.cam.
        end.
        prn_crc = docl.crc.
        find crc where crc.crc = prn_crc no-lock.
        if available crc then prn_kzt = crc.code.
        else do:
            message "Ошибка!!! Не найден код валюты".
            hide message.
        end.

        prn_gl = docl.gl.
        find gl where gl.gl = prn_gl no-lock.
        if available gl then prn_des = gl.sname.
        else do:
            message "Ошибка!!! Не найден счет главной книги".
            hide message.
        end.

        put string(numln,"99") + " " + string(docl.gl) + " " + prn_des format "x(35)" " " docl.acc format "x(20)" " " prn_kzt " ".
        put prn_amt format "zzz,zzz,zzz,zzz,zz9.99" + " " docl.dc skip.
        if numln = 1 then prn_rem1 =  docl.rem[1].
    end.

    put  prn_code skip.

    put space (39) "ВСЕГО ДЕБЕТ  " total-dam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
    put space (39) "ВСЕГО КРЕДИТ " total-cam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
    put "------------------------------------------------------------------------------------------" skip.
    put "Примечан.: " prn_rem1 format "x(60)"  skip.
    put "==========================================================================================" skip(1).
    put "Менеджер:                  Контролер:"
    skip(2).

    output close.
    unix silent prit -t value("uni.img").
end procedure.
*/

