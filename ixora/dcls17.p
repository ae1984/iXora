/* dcls17.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Запись в таблицу долгов всех комиссий за закрываемый день, потом все будет сниматься
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        20.01.2000 svl
 * CHANGES
        26.12.2001            Разделены тарифы и расчет комиссии по тенговым (валютным), внутренним (внешним), дебетовым (кредитовым) платежам
        18.01.2002            Автоматическое закрытие технических овердрафтов
        28.06.2002            Обработка платежей V2 для Уральска
        01.08.2003 nadejda  - небольшая оптимизация циклов
        10.11.2003 nadejda  - обработка Интернет-платежей с типом M как внутренних
        16.02.2004 marinav  - закрыитие тех овердрафта перенесено в dcls7
        15.04.2004 valery   - Изменен(полность) принцип нахождения сумм для снятия коммиссий,
                              теперь если сумма коммиссии не установлена явно, проверяется, установлена процентная ставка для коммиссии
        22.04.2004 valery   - добавлена проверка на ГРОС, если платеж по ГРОСу и если он внешний и тенговый, то снимается минимальная коммиссия по КЛИРИНГУ
        28.04.2004 suchkov  - поправлена ошибка поиска в sysc (теперь ищет через lookup)
        11.10.2004 saltanat - в Атырау внесла снятие комиссии для ЧП.
        17.11.2004 saltanat - Добавлено снятие комиссии для платежей со штрих-кодами по своим тарифам.
        18.11.2004 saltanat - Убрала проверку на тип отправки при расчете комиссий для платежей со штрих кодами.
        18.11.2004 saltanat - для опер. по плат. карточкам невзимать комиссии для кредитовых(было) и дебетовых
                              поступлений по АРП счетам (arpdt, aaact).
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        11.02.2005 tsoy     - новые тарифы для интернет офиса.
        08.04.2005 saltanat - Сделала предоставление люгот на филиалах операциям Платежных карточек проведенным по льготным транзитным счетам( справ.- "arplg").
        21.06.2005 tsoy     - тариф 021 для сканированных внутренних убираем.
        08.08.2005 saltanat - Внесена автоматизация тарифов для физ.лиц по кодам - 141,163,165
        09.08.2005 saltanat - Убрала снятие комиссий у физ лиц за кредитовые операции.
        10.08.2005 suchkov  - Исправил ошибку в логике при определении назначения комиссии.
        11.08.2005 tsoy     - Исправил наименование комиссии берется из tarif2.
        15.08.2005 saltanat - Для физ. лиц заведены другие комиссии. А также для депозитных счетов физ. лиц комиссия не должна сниматься.
        16.08.2005 saltanat - Убрала проверку на депозитные счета. Включила проверку на кассовую операцию.
        23.08.2005 saltanat - Добавила проверку на осуществление платежей м/у счетами одного клиента. В этом случае комиссия не снимается.
        25.08.2005 saltanat - Выборка льгот по счетам.
        22.11.2005 marinav  - Добавлена проверка на ptype = "4" - тоже внутренний платеж
        23.11.2005 marinav  - В обработку включены физ лица филиалов; поменялась комиссия за вал операции физ лиц - 254,
                              за переводы внутри сети ЮЛ берется 141 код
        25.01.2006 marinav -  проверка на банк-получатель - если TXB то берем комиссию как за внутренний платеж
        14.08.2006 tsoy    -  исправил счетчик вместо сканированных на гросс
        17/08/2006 marinav - возврат версии
        21/08/2006 tsoy - возврат версии
        13/09/2006 tsoy - Интернет платежи филиалов тоже не обрабатываются
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
        20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2
*/


 {global.i}

{comm-txb.i}
{curs_conv.i}

def var v-cbank as char no-undo.
v-cbank = comm-txb ().

def var logfile   as char init "dcls17log.log"  no-undo.

def var v-dict    as char initial "flg90" no-undo.
def var v-dict2   as char initial "stmt" no-undo.
def var v-amt90   like jl.dam no-undo.
def var v-amt90n  like jl.dam no-undo.
def var v-crc     like crc.crc initial 2 no-undo.
def var v-f       as log no-undo.
def var v-amt     like jl.dam no-undo.
def var v-des     as char no-undo.
def var v-gl      like gl.gl no-undo.
def var v-branch  as char no-undo.

def new shared var s-jh like jh.jh .

def var jparr     as char no-undo.
def var vou-count as int no-undo.
def var i         as int no-undo.
def var v-templ   as char initial "cif0006" no-undo.
def var v-str     as char no-undo.
def var v-balold  as dec no-undo.
def var v-intold  as dec no-undo.
def var v-rem     as char no-undo.
def var vbal      like jl.dam no-undo.
def var vavl      like jl.dam no-undo.
def var vhbal     like jl.dam no-undo.
def var vfbal     like jl.dam no-undo.
def var vcrline   like jl.dam no-undo.
def var vcrlused  like jl.dam no-undo.
def var vooo      like aaa.aaa no-undo.
def var v-payout  as logical no-undo.

def var kod11     like rem.crc1 no-undo.
def var tproc     like tarif2.proc  no-undo.
def var tmin1     as dec decimals 10  no-undo.
def var tmax1     as dec decimals 10  no-undo.
def var tost      as dec decimals 10  no-undo.
def var pakal     as char no-undo.
def var pakala    as char no-undo.
def var pakaldti  as char no-undo.
def var pakaldti_fiz as char no-undo.
def var pakalcti  as char no-undo.
def var pakaldto  as char no-undo.
def var pakaldto_fiz as char no-undo.
def var pakalcto  as char no-undo.
def var pakaldvi  as char no-undo.
def var pakaldvi_fiz as char no-undo.
def var pakalcvi  as char no-undo.
def var pakaldvo  as char no-undo.
def var pakalcvo  as char no-undo.
def var pakalv2   as char no-undo.
def var pakalshc  as char no-undo.
def var pakalshc1  as char no-undo.
def var pakalshc2  as char no-undo.
def var pakalv2all  as char no-undo.

def var v-err     as log no-undo.

def var v-crca    like crc.crc no-undo.
def var v-crcdti  like crc.crc no-undo.
def var v-crcdti_fiz like crc.crc no-undo.
def var v-crccti  like crc.crc no-undo.
def var v-crcdto  like crc.crc no-undo.
def var v-crcdto_fiz like crc.crc no-undo.
def var v-crccto  like crc.crc no-undo.
def var v-crcdvi  like crc.crc no-undo.
def var v-crcdvi_fiz like crc.crc no-undo.
def var v-crccvi  like crc.crc no-undo.
def var v-crcdvo  like crc.crc no-undo.
def var v-crccvo  like crc.crc no-undo.
def var v-crcv2   like crc.crc no-undo.
def var v-crcshc  like crc.crc no-undo.
def var v-crcshc1  like crc.crc no-undo.
def var v-crcshc2  like crc.crc no-undo.
def var v-crcv2all  like crc.crc no-undo.

def var v-amta    as dec no-undo.
def var v-amtdti  as dec no-undo.
def var v-amtdti_fiz as dec no-undo.
def var v-amtcti  as dec no-undo.
def var v-amtdto  as dec no-undo.
def var v-amtdto_fiz as dec no-undo.
def var v-amtcto  as dec no-undo.
def var v-amtdvi  as dec no-undo.
def var v-amtdvi_fiz as dec no-undo.
def var v-amtcvi  as dec no-undo.
def var v-amtdvo  as dec no-undo.
def var v-amtcvo  as dec no-undo.
def var v-amtv2   as dec no-undo.
def var v-amtshc  as dec no-undo.
def var v-amtshc1  as dec no-undo.
def var v-amtshc2  as dec no-undo.
def var v-amtv2all  as dec no-undo.

def var v-comma   as char no-undo.
def var v-commdti as char no-undo.
def var v-commdti_fiz as char no-undo.
def var v-commcti as char no-undo.
def var v-commdto as char no-undo.
def var v-commdto_fiz as char no-undo.
def var v-commcto as char no-undo.
def var v-commdvi as char no-undo.
def var v-commdvi_fiz as char no-undo.
def var v-commcvi as char no-undo.
def var v-commdvo as char no-undo.
def var v-commcvo as char no-undo.
def var v-commv2  as char no-undo.
def var v-commshc as char no-undo.
def var v-commshc1 as char no-undo.
def var v-commshc2 as char no-undo.
def var v-commv2all as char no-undo.

def var v-jurfiz as char no-undo.

def temp-table wt  no-undo
    field cif like cif.cif
    field cntdti   as int
    field cntdti_fiz as int
    field cntcti   as int
    field cntdto   as int
    field cntdto_fiz as int
    field cntcto   as int
    field cntdvi   as int
    field cntdvi_fiz as int
    field cntcvi   as int
    field cntdvo   as int
    field cntcvo   as int
    field cntv2    as int
    field cntshc   as int
    field cntshc1  as int
    field cntshc2  as int
    field cntv2all as int
    field amtdti   as int
    field amtdti_fiz as int
    field amtcti   as int
    field amtdto   as int
    field amtdto_fiz as int
    field amtcto   as int
    field amtdvi   as int
    field amtdvi_fiz as int
    field amtcvi   as int
    field amtdvo   as int
    field amtcvo   as int
    field amtv2    as int
    field amtshc   as int
    field amtshc1  as int
    field amtshc2  as int
    field amtv2all as int
index wt is unique cif.


find sysc where sysc.sysc = "chg90" no-lock no-error.
if available sysc then do:
    v-templ = entry(1,sysc.chval).
    v-comma = entry(2,sysc.chval).
    v-commdti = entry(3,sysc.chval). /* 141 */
    v-commcti = entry(4,sysc.chval).
    v-commdto = entry(5,sysc.chval). /* 163 */
    v-commcto = entry(6,sysc.chval).
    v-commdvi = entry(7,sysc.chval). /* 165 */
    v-commcvi = entry(8,sysc.chval).
    v-commdvo = entry(9,sysc.chval).
    v-commcvo = entry(10,sysc.chval).
    v-commv2  = entry(11,sysc.chval).
    v-commshc = entry(15,sysc.chval).
    v-commshc1 = entry(16,sysc.chval).
    v-commshc2 = entry(17,sysc.chval).
    v-commv2all = entry(18,sysc.chval).
    v-commdti_fiz = entry(19,sysc.chval). /* 230 */
    v-commdto_fiz = entry(20,sysc.chval). /* 212 */
    v-commdvi_fiz = entry(28,sysc.chval). /* 254 */
end.
else do:
    v-templ     = "cif0006".
    v-comma     = "106". /*За переводн.операцию без НДС*/
    v-commdti   = "141". /*За деб.опер (тенге,внут) б/НДС*/
    v-commcti   = "142". /*За кред.опер(тенге,внут) б/НДС*/
    v-commdto   = "163". /*За деб.опер (тенге,внеш) б/НДС*/
    v-commcto   = "164". /*За кред.опер(тенге,внеш) б/НДС*/
    v-commdvi   = "165". /*За деб.опер (вал, внут) б/НДС*/
    v-commcvi   = "166". /*За кред.опер (вал,внут) б/НДС */
    v-commdvo   = "167". /*За деб.опер (вал, внеш) б/НДС*/
    v-commcvo   = "168". /*За кред.опер (вал,внеш) б/НДС*/
    v-commv2    = "170". /*За деб.опер.с датой след.дня*/
    v-commshc   = "012". /*За деб.опер платежей со штрих-кодами (тенге, внешн) - Клиринг*/
    v-commshc1  = "021". /*За деб.опер платежей со штрих-кодами (тенге, внут) - Клиринг*/
    v-commshc2  = "022". /*За деб.опер платежей со штрих-кодами (тенге, внешн) с буд датой валютир.- Клиринг*/
    v-commv2all = "170". /*За деб.опер (тенге, внешн) с буд датой валютир.- Клиринг*/
    v-commdti_fiz   = "230". /*За деб.опер физ.лиц (тенге,внут) б/НДС*/
    v-commdto_fiz   = "212". /*За деб.опер физ.лиц (тенге,внеш) б/НДС*/
    v-commdvi_fiz   = "254". /*За деб.опер физ.лиц (вал, внут) б/НДС поменялся с 23.11.05 */
end.

def var v-arp as char no-undo.
def var v-aaa as char no-undo.
def var v-arplg as char no-undo.

def var v-self as logical no-undo.
def var v-rnn  as char no-undo.
def var v-i    as int no-undo.

def buffer bjl for jl.
def buffer cjl for jl.
def buffer caaa for aaa.

def var v-chgx   as char initial "009"  no-undo.  /* за ведение счета ЧП в тенге внутренние дебетовые проводки -1тг      */

/*find tarif2 where tarif2.num = trim(substring(v-comma,1,1)) and tarif2.kod = trim(substring(v-comma,2,2))
              and tarif2.stat = 'r' no-lock no-error.*/
find first tarif2 where  tarif2.str5 = trim(v-comma) and tarif2.stat = 'r' no-lock no-error.
if available tarif2 then v-crc = tarif2.crc.
else do:
    message "Не найден тариф " v-comma.
    pause.
    pause 1000.
end.

find crc where crc.crc = v-crc no-lock no-error.

find sysc where sysc = "ourbnk" no-error. /* Код банка,принятый в Прагме */
 if avail sysc then v-branch = sysc.chval. /*TXB00, TXB01 и т.д.*/

find sysc where sysc  = "arpdt" no-error .  /* Счет-искл (ARP) для плат карт */
 if available sysc then v-arp = sysc.chval.

find sysc where sysc = "aaact" no-error.   /* Счет-искл (CIF) для плат карт  */
if available sysc then v-aaa = sysc.chval.

find sysc where sysc  = "arplg" no-error .  /* Счет-искл (ARP) для плат карт на филиалах */
 if available sysc then v-arplg = sysc.chval.
 else v-arplg = ''.

    output to value("17dcls" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".log").


/******************проверяем, а заведены ли указанные комиссии******************************/
put " dcls17 проверяет коды коммиссий" g-today  skip.
    find first tarif2 where tarif2.str5 = v-comma
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-comma.
        put unformatted "Не найдена комиссия с кодом " v-comma  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdti
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commdti.
        put unformatted "Не найдена комиссия с кодом " v-commdti  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdto
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commdto.
        put unformatted "Не найдена комиссия с кодом " v-commdto  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdvi
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commdvi.
        put unformatted "Не найдена комиссия с кодом " v-commdvi  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdvo
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commdvo.
        put unformatted "Не найдена комиссия с кодом " v-commdvo  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commcti
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commcti.
        put unformatted "Не найдена комиссия с кодом " v-commcti  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commcto
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commcto.
        put unformatted "Не найдена комиссия с кодом " v-commcto  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commcvi
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commcvi.
        put unformatted "Не найдена комиссия с кодом " v-commcvi  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commcvo
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commcvo.
        put unformatted "Не найдена комиссия с кодом " v-commcvo  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commv2
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
            message "Не найдена комиссия с кодом " v-commv2.
        put unformatted "Не найдена комиссия с кодом " v-commv2  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commshc
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commshc.
        put unformatted "Не найдена комиссия с кодом " v-commshc  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commshc1
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commshc1.
        put unformatted "Не найдена комиссия с кодом " v-commshc1  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commshc2
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commshc2.
        put unformatted "Не найдена комиссия с кодом " v-commshc2  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commv2all
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commv2all.
        put unformatted "Не найдена комиссия с кодом " v-commv2all  skip.
            pause 1000.
        end.

   find first tarif2 where tarif2.str5 = v-commdti_fiz
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commdti_fiz.
        put unformatted "Не найдена комиссия с кодом " v-commdti_fiz  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdto_fiz
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commdto_fiz.
        put unformatted "Не найдена комиссия с кодом " v-commdto_fiz  skip.
            pause 1000.
        end.

    find first tarif2 where tarif2.str5 = v-commdvi_fiz
                        and tarif2.stat = 'r' no-lock no-error.
        if not avail tarif2 then do:
                message "Не найдена комиссия с кодом " v-commdvi_fiz.
        put unformatted "Не найдена комиссия с кодом " v-commdvi_fiz  skip.
            pause 1000.
        end.


/*******************************************************************************************/



for each jl where jl.jdt eq g-today and jl.sub eq "CIF" and jl.lev eq 1 no-lock use-index jdtlevsub:
    v-f = yes.
    /*****************************************************************************************************************************************/
    if lookup(string(jl.gl),v-aaa) > 0 then
    do: /*если счет принадлежит к счету исключения для клиентов и снятия идут с льготного АРП-счета - например, карточники переводы делают коммерсантам */
        find bjl where bjl.jh = jl.jh and bjl.sub = "ARP" and bjl.lev = 1  and lookup(string(bjl.gl),v-arp) > 0 and bjl.dc = (if jl.dc = "c" then "d" else "c")  no-lock no-error.
        if available bjl then v-f = no.
        else if v-cbank ne 'TXB00' then do: /* если счет принадлежит к счету искл. кл. и перевод клиенту осущ-ся на филиале с льгот. транз. счета платежных карт Ц.О. */
                find remtrz where remtrz.rdt <= jl.jdt and remtrz.sbank = 'TXB00' and lookup(remtrz.sacc,v-arplg) > 0 and remtrz.jh2 = jl.jh  no-lock no-error.
            if avail remtrz then v-f = no.
        end.

    end.
    /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    if jl.rem[1] begins "Storno" then v-f = no.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    find trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.trxt = 0 and trxcods.codfr = v-dict no-lock no-error.
        if available trxcods then
    do:
            if trxcods.code eq "no" then v-f = no.
    end.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    find trxcods where trxcods.trxh eq jl.jh and trxcods.trxln eq jl.ln and trxcods.trxt eq 0 and trxcods.codfr eq v-dict2 no-lock no-error.
        if available trxcods then
    do:
            if trxcods.code begins "chg" then v-f = no.
    end.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    if jl.rem[1] begins "Storno" or jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then v-f = no.
        /*****************************************************************************************************************************************/
        /*****************************************************************************************************************************************/
    if not v-f then next.

    /* Интернет платежи будем обрабатывать отдельно в dcls18.p */
    find jh where jh.jh = jl.jh no-lock no-error.
    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
    if avail remtrz and remtrz.source = "IBH" and remtrz.ptype <> "M"  then next.

/*если все проверки прошли, то идем дальше*/
        find aaa where aaa.aaa = jl.acc no-lock no-error. /*а есть ли вообще такой счет?*/
        if not available aaa then next. /*если не найден то переходим на следующую проводку */

            find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
            if not available sub-cod then next. /* Убрала проверку на юр лиц в Алмате, т.к. берем комиссии для физ лиц тоже. */
/*            if v-branch <> 'TXB00' and sub-cod.ccode <> "0" then next.   23.11.05 marinav теперь должно работать на филиалах*/
            v-jurfiz = sub-cod.ccode. /* Запоминаем статус клиента */
          /*  if not available sub-cod or sub-cod.ccode <> "0" then next.*/ /*если это не юр лицо то выходим*/

                /* 15.08.2005 saltanat - если физ лицо и счет депозитный, то комиссии не снимаем */
           /*     if v-jurfiz = '1' then do:
                   find lgr where lgr.lgr = aaa.lgr no-lock no-error.
                   if avail lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') then next.
                end. */

                find sub-cod where sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" and sub-cod.acc = aaa.aaa no-lock no-error. /*льготный счет ?*/
                if available sub-cod and sub-cod.ccode = "no" then next. /*счет льготный, выходим*/


                    find jh where jh.jh = jl.jh no-lock no-error.

                    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
                    v-payout = (avail remtrz and remtrz.ptype <> "M").  /* YES = платеж внешний */
                    v-err = no.

                    /* В Атырау нов. условия для ЧП-в */
                    /*
                    if v-branch = "TXB03" then do:
                       find first sub-cod where sub-cod.sub eq "cln"
                                            and sub-cod.d-cod eq "ecdivis"
                                            and sub-cod.acc eq aaa.cif no-lock no-error.
                       if avail sub-cod and sub-cod.ccode = "98" then do:

                        if jl.dc = "D" then
                        do:
                                if not v-payout then do:
                                     run perev0(aaa.aaa, v-chgx, aaa.cif, output kod11,
                                     output tproc, output tmin1, output tmax1,
                                     output tost, output pakal, output v-err).
                                    if  tost gt 0 then do:
                                        CREATE bxcif.
                                               bxcif.cif  = aaa.cif.
                                               bxcif.aaa  = aaa.aaa.
                                               bxcif.crc  = kod11.
                                               bxcif.tim  = time.
                                               bxcif.type = v-chgx.
                                               bxcif.whn  = g-today.
                                               bxcif.amount = tost.
                                               bxcif.period =
                                                       substring(string(g-today,"99/99/9999"),7,4) + "/" +
                                                       substring(string(g-today,"99/99/9999"),4,2).
                                                bxcif.rem = pakal + ". За " + string(g-today,"99/99/9999") +
                                                ". Счет " + aaa.aaa.
                                     end.
                                     next.
                                end.
                        end.
                       end.
                    end.
                    */

                    find wt where wt.cif = aaa.cif no-error.
                    if not available wt then do: create wt. wt.cif = aaa.cif. end.

                    /* у Уральска единый тариф на внешние платежи тенге/вал с датой валютирования после сегодняшней */

                    /*
                    if v-payout and v-branch = "TXB02" and remtrz.valdt2 > jl.jdt then
                    do:
                        wt.cntv2 = wt.cntv2 + 1.
                        run perev0(aaa.aaa, v-commv2 , wt.cif, output v-crcv2, output tproc,output tmin1, output tmax1, output v-amtv2, output pakalv2, output v-err).
                        if not v-err then /*если код найден, то дальше*/
                        do:
                            if v-amtv2 = 0 and tproc <> 0 then /*если сумма комиссии не ноль*/
                            do: /*если ноль то смотрим проценты*/
                                if remtrz.cover <> 2 then /*если платеж не по ГРОСу*/
                                do: /*ищем сумму коммиссии дальше*/
                                    v-amtv2 = ((jl.dam + jl.cam) * tproc) / 100. /*ищем сумму коммиссии по установленному проценту*/
                                    if v-amtv2 < tmin1 then /*то смотрим меньше ли она минимального значения*/
                                                v-amtv2 = tmin1. /* если меньше, то устанавливаем коммиссию равную суммме минимальной комиссии*/
                                    else
                                        if v-amtv2 > tmax1 and tmax1 > 0 then /*если комиссия больше минимальной и больше максимальной  и при этом максимальная комиссия больше нуля*/
                                                v-amtv2 = tmax1.
                                end.
                                else
                                do: /*Иначе, если это ГРОС, то в любом случае снимаем минимальную*/
                                    v-amtv2 = tmin1.
                                end.
                            end.
                            if v-amtv2 <> 0 then
                                put unformatted wt.cif "  "  jl.acc " коммисия по коду " v-commv2 " = " v-amtv2 skip.
                            wt.amtv2 = wt.amtv2 + v-amtv2.
                        end.
                    end. /***Уральск********/
                    else
                    do: /*если это не внешний Уральский платеж*/
                    */
                      /* 15.08.2005 saltanat - Разделяю расчет по статусам клиента */
                      if v-jurfiz = "0" then do:
                        /* ---------- ЮРИДИЧЕСКИЕ ЛИЦА ----------- */
                        if jl.dc = "D" then
                        do:
                            if jl.crc = 1 then
                            do: /*****************************************************************************************************************************************/
                                if v-payout then
                                do:  /* дебет тенге внешний */

                                /* 17.11.2004 saltanat - Для платежей со штрих кодами другая комиссия  *  * */

                                  if remtrz.source = 'SCN' then do: /* дебет тенге внешний с штрих-кодом */

                                      if remtrz.valdt2 > g-today then do:

                                          wt.cntshc2 = wt.cntshc2 + 1.  /*количество платежей*/
                                          run perev0(aaa.aaa, v-commshc2 , wt.cif, output v-crcshc2, output tproc,
                                          output tmin1, output tmax1, output v-amtshc2, output pakalshc2, output v-err).
                                          if not v-err then /*если код найден, то дальше*/
                                          do:
                                            if v-amtshc2 = 0 and tproc <> 0 then
                                            do: /*если ноль то смотрим проценты*/
                                                    v-amtshc2 = (jl.dam * tproc) / 100.
                                                    if v-amtshc2 < tmin1 then
                                                       v-amtshc2 = tmin1.
                                                    else
                                                        if v-amtshc2 > tmax1 and tmax1 > 0 then
                                                           v-amtshc2 = tmax1.
                                            end.
                                            if v-amtshc2 <> 0 then
                                                    put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commshc2) " = " string(v-amtshc2) " " remtrz.remtrz skip.
                                            wt.amtshc2 = wt.amtshc2 + v-amtshc2.

                                          end.


                                      end.

                                      if remtrz.valdt2 = g-today then do:

                                          wt.cntshc = wt.cntshc + 1.  /*количество платежей*/
                                          run perev0(aaa.aaa, v-commshc , wt.cif, output v-crcshc, output tproc,
                                          output tmin1, output tmax1, output v-amtshc, output pakalshc, output v-err).
                                          if not v-err then /*если код найден, то дальше*/
                                          do:
                                            if v-amtshc = 0 and tproc <> 0 then
                                            do: /*если ноль то смотрим проценты*/
                                                    v-amtshc = (jl.dam * tproc) / 100.
                                                    if v-amtshc < tmin1 then
                                                       v-amtshc = tmin1.
                                                    else
                                                        if v-amtshc > tmax1 and tmax1 > 0 then
                                                           v-amtshc = tmax1.
                                            end.
                                            if v-amtshc <> 0 then
                                                    put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commshc) " = " string(v-amtshc)  if avail remtrz then remtrz.remtrz  else " "  skip.
                                            wt.amtshc = wt.amtshc + v-amtshc.

                                          end.

                                      end.

                                  end. /* дебет тенге внешний с штрих-кодом */
                                  else do: /* дебет тенге внешний без штрих-кода */

                                    if remtrz.valdt2 = g-today then do:

                                       if remtrz.rbank begins 'TXB' then do: /* расматриваются платежи по сети Банка - как внутренний платеж*/
                                             wt.cntdti = wt.cntdti + 1. /*количество платежей*/
                                             run perev0(aaa.aaa, v-commdti , wt.cif, output v-crcdti, output tproc,
                                             output tmin1, output tmax1, output v-amtdti, output pakaldti, output v-err).
                                             if not v-err then
                                             do:
                                                 if v-amtdti = 0 and tproc <> 0 then
                                                 do:
                                                         v-amtdti = (jl.dam * tproc) / 100.
                                                         if v-amtdti < tmin1 then
                                                             v-amtdti = tmin1.
                                                         else
                                                             if v-amtdti > tmax1 and tmax1 > 0 then
                                                                 v-amtdti = tmax1.
                                                 end.
                                                 if v-amtdti <> 0 then
                                                         put unformatted  wt.cif  "  "  jl.acc " коммисия по коду " string(v-commdti) " = " string(v-amtdti) if avail remtrz then remtrz.remtrz  else " "   skip.
                                                 wt.amtdti = wt.amtdti + v-amtdti.
                                             end.

                                       end.
                                       else do:
                                             wt.cntdto = wt.cntdto + 1.  /*количество платежей*/
                                             run perev0(aaa.aaa, v-commdto , wt.cif, output v-crcdto, output tproc,
                                             output tmin1, output tmax1, output v-amtdto, output pakaldto, output v-err).
                                             if not v-err then /*если код найден, то дальше*/
                                             do:
                                                 if v-amtdto = 0 and tproc <> 0 then
                                                 do: /*если ноль то смотрим проценты*/
                                                     if remtrz.cover <> 2 then /*если платеж не по ГРОСу*/
                                                     do: /*ищем сумму коммиссии дальше*/
                                                         v-amtdto = (jl.dam * tproc) / 100.
                                                         if v-amtdto < tmin1 then
                                                             v-amtdto = tmin1.
                                                         else
                                                             if v-amtdto > tmax1 and tmax1 > 0 then
                                                                 v-amtdto = tmax1.
                                                     end.
                                                     else /*Иначе, если это ГРОС, то в любом случае снимаем минимальную*/
                                                         v-amtdto = tmin1.
                                                 end.
                                                 if v-amtdto <> 0 then
                                                         put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commdto) " = " string(v-amtdto) " " if avail remtrz then remtrz.remtrz  else " " skip.
                                                 wt.amtdto = wt.amtdto + v-amtdto.
                                             end.
                                        end.
                                     end.


                                    if remtrz.valdt2 > g-today then do:

                                          wt.cntv2all = wt.cntv2all + 1.  /*количество платежей*/
                                          run perev0(aaa.aaa, v-commv2all , wt.cif, output v-crcv2all, output tproc,
                                          output tmin1, output tmax1, output v-amtv2all, output pakalv2all, output v-err).
                                          if not v-err then /*если код найден, то дальше*/
                                          do:
                                            if v-amtv2all = 0 and tproc <> 0 then
                                            do: /*если ноль то смотрим проценты*/
                                                    v-amtv2all = (jl.dam * tproc) / 100.
                                                    if v-amtv2all < tmin1 then
                                                       v-amtv2all = tmin1.
                                                    else
                                                        if v-amtv2all > tmax1 and tmax1 > 0 then
                                                           v-amtv2all = tmax1.
                                            end.
                                            if v-amtshc <> 0 then
                                                    put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commv2all) " = " string(v-amtv2all) if avail remtrz then remtrz.remtrz  else " "  skip.
                                            wt.amtv2all = wt.amtv2all + v-amtv2all.

                                          end.

                                     end.


                                  end. /* дебет тенге внешний без штрих-кода */
                                end.
                                else
                                do: /* дебет тенге внутренний */
                                         wt.cntdti = wt.cntdti + 1. /*количество платежей*/
                                         run perev0(aaa.aaa, v-commdti , wt.cif, output v-crcdti, output tproc,
                                         output tmin1, output tmax1, output v-amtdti, output pakaldti, output v-err).
                                         if not v-err then
                                         do:
                                             if v-amtdti = 0 and tproc <> 0 then
                                             do:
                                                     v-amtdti = (jl.dam * tproc) / 100.
                                                     if v-amtdti < tmin1 then
                                                         v-amtdti = tmin1.
                                                     else
                                                         if v-amtdti > tmax1 and tmax1 > 0 then
                                                             v-amtdti = tmax1.
                                             end.
                                             if v-amtdti <> 0 then
                                                     put unformatted  wt.cif  "  "  jl.acc " коммисия по коду " string(v-commdti) " = " string(v-amtdti) if avail remtrz then remtrz.remtrz  else " "   skip.
                                             wt.amtdti = wt.amtdti + v-amtdti.
                                         end.
                                end.
                            end. /*jl.crc =1 *****************************************************************************************************************************************/
                            else /*это валюта*/
                            do:
                                if v-payout then
                                do: /* дебет валюта внешний */
                                    wt.cntdvo = wt.cntdvo + 1.  /*количество платежей*/
                                    run perev0(aaa.aaa, v-commdvo , wt.cif, output v-crcdvo, output tproc,
                                    output tmin1, output tmax1, output v-amtdvo, output pakaldvo, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtdvo = 0 and tproc <> 0 then
                                        do:
                                                v-amtdvo = (jl.dam * tproc) / 100.
                                                if v-amtdvo < tmin1 then
                                                    v-amtdvo = tmin1.
                                                else
                                                    if v-amtdvo > tmax1 and tmax1 > 0 then
                                                        v-amtdvo = tmax1.
                                        end.
                                        if v-amtdvo <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commdvo) " = " string(v-amtdvo) " " if avail remtrz then remtrz.remtrz  else " "   skip.
                                        wt.amtdvo = wt.amtdvo + v-amtdvo.
                                    end.
                                end.
                                else
                                do:
                                    wt.cntdvi = wt.cntdvi + 1.  /* дебет валюта внутренний */
                                    run perev0(aaa.aaa, v-commdvi , wt.cif, output v-crcdvi, output tproc,
                                    output tmin1, output tmax1, output v-amtdvi, output pakaldvi, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtdvi = 0 and tproc <> 0  then
                                        do:
                                                v-amtdvi = (jl.dam * tproc) / 100.
                                                if v-amtdvi < tmin1 then
                                                    v-amtdvi = tmin1.
                                                else
                                                    if v-amtdvi > tmax1 and tmax1 > 0 then
                                                        v-amtdvi = tmax1.
                                        end.
                                        if v-amtdvi <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commdvi) " = " string(v-amtdvi) " " if avail remtrz then remtrz.remtrz  else " "  skip.
                                        wt.amtdvi = wt.amtdvi + v-amtdvi.
                                    end.
                                end.
                            end.
                        end. /* "D" */
                        if jl.dc = "C" then
                        do:
                            if jl.crc = 1 then
                            do:
                                if v-payout then
                                do: /* кредит тенге внешний */
                                    wt.cntcto = wt.cntcto + 1.
                                    run perev0(aaa.aaa, v-commcto , wt.cif, output v-crccto, output tproc,
                                    output tmin1, output tmax1, output v-amtcto, output pakalcto, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtcto = 0 and tproc <> 0 then
                                        do:
                                                v-amtcto = (jl.cam * tproc) / 100.
                                                if v-amtcto < tmin1 then
                                                        v-amtcto = tmin1.
                                                else
                                                    if v-amtcto > tmax1 and tmax1 > 0 then
                                                                    v-amtcto = tmax1.
                                        end.
                                        if v-amtcto <> 0 then
                                          put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commcto) " = " string(v-amtcto) " "  if avail remtrz then remtrz.remtrz  else " "  skip.
                                        wt.amtcto = wt.amtcto + v-amtcto.
                                    end.
                                end.
                                else
                                do: /* кредит тенге внутренний */
                                    wt.cntcti = wt.cntcti + 1.
                                    run perev0(aaa.aaa, v-commcti , wt.cif, output v-crccti, output tproc,
                                    output tmin1, output tmax1, output v-amtcti, output pakalcti, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtcti = 0 and tproc <> 0 then
                                        do:
                                                v-amtcti = (jl.cam * tproc) / 100.
                                                if v-amtcti < tmin1 then
                                                        v-amtcti = tmin1.
                                                else
                                                    if v-amtcti > tmax1 and tmax1 > 0 then
                                                                v-amtcti = tmax1.
                                        end.
                                        if v-amtcti <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commcti) " = " string(v-amtcti) " "  if avail remtrz then remtrz.remtrz  else " "   skip.

                                        wt.amtcti = wt.amtcti + v-amtcti.
                                    end.
                                end.
                            end. /*jl.crc = 1*/
                            else /*это валюта*/
                            do:
                                if v-payout then
                                do: /* кредит валюта внешний */
                                    wt.cntcvo = wt.cntcvo + 1.
                                    run perev0(aaa.aaa, v-commcvo , wt.cif, output v-crccvo, output tproc,
                                    output tmin1, output tmax1, output v-amtcvo, output pakalcvo, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtcvo = 0 and tproc <> 0 then
                                        do:
                                                v-amtcvo = (jl.cam * tproc) / 100.
                                                if v-amtcvo < tmin1 then
                                                        v-amtcvo = tmin1.
                                                else
                                                    if v-amtcvo > tmax1 and tmax1 > 0 then
                                                                v-amtcvo = tmax1.
                                        end.
                                        if v-amtcvo <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commcvo) " = " string(v-amtcvo) " " if avail remtrz then remtrz.remtrz  else " "   skip.
                                        wt.amtcvo = wt.amtcvo + v-amtcvo.
                                    end.
                                end.
                                else
                                do: /* кредит валюта внутренний */
                                    wt.cntcvi = wt.cntcvi + 1.
                                    run perev0(aaa.aaa, v-commcvi , wt.cif, output v-crccvi, output tproc,
                                    output tmin1, output tmax1, output v-amtcvi, output pakalcvi, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtcvi = 0 and tproc <> 0 then
                                        do:
                                                v-amtcvi = (jl.cam * tproc) / 100.
                                                if v-amtcvi < tmin1 then
                                                        v-amtcvi = tmin1.
                                                else
                                                    if v-amtcvi > tmax1 and tmax1 > 0 then
                                                                    v-amtcvi = tmax1.
                                        end.
                                        if v-amtcvi <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commcvi) " = " string(v-amtcvi) " " if avail remtrz then remtrz.remtrz  else " "   skip.
                                        wt.amtcvi = wt.amtcvi + v-amtcvi.
                                   end.
                                end.
                            end. /*это валюта*/
                        end. /* "C" */
                      end. /* юр. лицо */
                      else if v-jurfiz = "1" then do:
                        /* ---------- ФИЗИЧЕСКИЕ ЛИЦА ----------- */
                        if jl.dc = "D" then
                        do:
                            /* 22.08.2005 saltanat - Если это внутренний перевод и осущ-ся одним клиентом, то комиссия не взимается */
                            v-self = no.
                            if not v-payout then do: /* внутренний платеж */
                               for each cjl where cjl.jh = jl.jh and cjl.dc = 'c' no-lock.
                                   if cjl.acc ne '' then do:
                                      find caaa where caaa.aaa = cjl.acc no-lock no-error.
                                      if avail caaa then do:
                                         if aaa.cif = caaa.cif then do: v-self = yes. leave. end.
                                      end.
                                   end.
                               end.
                            end.
                            else do: /* внешний платеж */
                               if remtrz.rbank begins 'TXB' then do: /* расматриваются платежи по сети Банка */
        						  v-rnn = remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3].
								  v-i = index(v-rnn,'RNN').
								  if v-i > 0 then do:
                                     find cif where cif.cif = aaa.cif no-lock no-error.
                                     if avail cif then do:
                                        if substring(v-rnn,v-i + 4,12) = cif.jss then v-self = yes.
                                     end.
								  end.
                               end. /* TXB */
                            end.

                            if v-self then next. /* Если платеж одного клиента */

                            if jl.crc = 1 then
                            do: /*****************************************************************************************************************************************/
                                  /* 25/01/06 marinav   -  and not(remtrz.rbank begins 'TXB') */
                                if v-payout and not(remtrz.rbank begins 'TXB') then
                                do:  /* дебет тенге внешний */

                                  if remtrz.source ne 'SCN' then do: /* дебет тенге внешний без штрих-кода */
                                    if remtrz.valdt2 = g-today then do:
                                        wt.cntdto_fiz = wt.cntdto_fiz + 1.  /*количество платежей*/
                                        run perev0(aaa.aaa, v-commdto_fiz , wt.cif, output v-crcdto_fiz, output tproc,
                                        output tmin1, output tmax1, output v-amtdto_fiz, output pakaldto_fiz, output v-err).
                                        if not v-err then /*если код найден, то дальше*/
                                        do:
                                            if v-amtdto_fiz = 0 and tproc <> 0 then
                                            do: /*если ноль то смотрим проценты*/
                                                if remtrz.cover <> 2 then /*если платеж не по ГРОСу*/
                                                do: /*ищем сумму коммиссии дальше*/
                                                    v-amtdto_fiz = (jl.dam * tproc) / 100.
                                                    if v-amtdto_fiz < tmin1 then
                                                        v-amtdto_fiz = tmin1.
                                                    else
                                                        if v-amtdto_fiz > tmax1 and tmax1 > 0 then
                                                            v-amtdto_fiz = tmax1.
                                                end.
                                                else /*Иначе, если это ГРОС, то в любом случае снимаем минимальную*/
                                                    v-amtdto_fiz = tmin1.
                                            end.
                                            if v-amtdto_fiz <> 0 then
                                                    put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commdto_fiz) " = " string(v-amtdto_fiz) " " if avail remtrz then remtrz.remtrz  else " " skip.
                                            wt.amtdto_fiz = wt.amtdto_fiz + v-amtdto_fiz.
                                        end.
                                     end.
                                  end. /* дебет тенге внешний без штрих-кода */
                                end.
                                else
                                do: /* дебет тенге внутренний */
									/* 16.08.2005 saltanat - Включила проверку : 1. операция д.б. м/у клиентами банка
                                    		                                     2. не брать комиссий с кассовых операций */
				                	     if (avail remtrz) and (not (remtrz.rbank begins 'TXB')) then next.

                                         find first cjl where cjl.jh = jl.jh and cjl.dc = 'c' and (cjl.gl = 100100 or cjl.gl = 100200) no-lock no-error.
                                         if avail cjl then next.

                                         wt.cntdti_fiz = wt.cntdti_fiz + 1. /*количество платежей*/
                                         run perev0(aaa.aaa, v-commdti_fiz , wt.cif, output v-crcdti_fiz, output tproc,
                                         output tmin1, output tmax1, output v-amtdti_fiz, output pakaldti_fiz, output v-err).
                                         if not v-err then
                                         do:
                                             if v-amtdti_fiz = 0 and tproc <> 0 then
                                             do:
                                                     v-amtdti_fiz = (jl.dam * tproc) / 100.
                                                     if v-amtdti_fiz < tmin1 then
                                                         v-amtdti_fiz = tmin1.
                                                     else
                                                         if v-amtdti_fiz > tmax1 and tmax1 > 0 then
                                                             v-amtdti_fiz = tmax1.
                                             end.
                                             if v-amtdti_fiz <> 0 then
                                                     put unformatted  wt.cif  "  "  jl.acc " коммисия по коду " string(v-commdti_fiz) " = " string(v-amtdti_fiz) if avail remtrz then remtrz.remtrz  else " "   skip.
                                             wt.amtdti_fiz = wt.amtdti_fiz + v-amtdti_fiz.
                                         end.
                                end.
                            end. /*jl.crc =1 *****************************************************************************************************************************************/
                            else /*это валюта*/

/* 25.01.2006 marinav */
                            do:
                                if not v-payout or (v-payout and remtrz.rbank begins 'TXB') then do: /* дебет валюта внутренний */
									/* 16.08.2005 saltanat - Включила проверку : 1. операция д.б. м/у клиентами банка
                                    		                                     2. не брать комиссий с кассовых операций */
				      	     if (avail remtrz) and (not (remtrz.rbank begins 'TXB')) then next.

                                         find first cjl where cjl.jh = jl.jh and cjl.dc = 'c' and (cjl.gl = 100100 or cjl.gl = 100200) no-lock no-error.
                                         if avail cjl then next.

                                    wt.cntdvi_fiz = wt.cntdvi_fiz + 1.
                                    run perev0(aaa.aaa, v-commdvi_fiz , wt.cif, output v-crcdvi_fiz, output tproc,
                                    output tmin1, output tmax1, output v-amtdvi_fiz, output pakaldvi_fiz, output v-err).
                                    if not v-err then /*если код найден, то дальше*/
                                    do:
                                        if v-amtdvi_fiz = 0 and tproc <> 0  then
                                        do:
                                                v-amtdvi_fiz = (jl.dam * tproc) / 100.
                                                if v-amtdvi_fiz < tmin1 then
                                                    v-amtdvi_fiz = tmin1.
                                                else
                                                    if v-amtdvi_fiz > tmax1 and tmax1 > 0 then
                                                        v-amtdvi_fiz = tmax1.
                                        end.
                                        if v-amtdvi_fiz <> 0 then
                                                put unformatted  wt.cif  "  " jl.acc " коммисия по коду " string(v-commdvi_fiz) " = " string(v-amtdvi_fiz) " " if avail remtrz then remtrz.remtrz  else " "  skip.
                                        wt.amtdvi_fiz = wt.amtdvi_fiz + v-amtdvi_fiz.
                                    end.
                                end.
                            end. /* валюта */
                        end. /* "D" */
                      end. /* физ. лицо */

                    /*
                    end. /*если это не внешний Уральский платеж*/
                    */
end. /*for each jl*/



for each wt :
            if wt.amtdti <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdti
                    bxcif.crc = v-crcdti
                    bxcif.rem = pakaldti + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdti ,">>>>>"))
                    bxcif.type  = v-commdti.
        end.
            if wt.amtdti_fiz <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdti_fiz
                    bxcif.crc = v-crcdti_fiz
                    bxcif.rem = pakaldti_fiz + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdti_fiz ,">>>>>"))
                    bxcif.type  = v-commdti_fiz.
        end.
            if wt.amtdto <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdto
                    bxcif.crc = v-crcdto
                    bxcif.rem = pakaldto + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdto,">>>>>"))
                    bxcif.type  = v-commdto.
        end.
            if wt.amtdto_fiz <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdto_fiz
                    bxcif.crc = v-crcdto_fiz
                    bxcif.rem = pakaldto_fiz + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdto_fiz,">>>>>"))
                    bxcif.type  = v-commdto_fiz.
        end.
            if wt.amtdvi <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdvi
                    bxcif.crc = v-crcdvi
                    bxcif.rem = pakaldvi + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdvi,">>>>>"))
                    bxcif.type  = v-commdvi.
        end.
            if wt.amtdvi_fiz <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdvi_fiz
                    bxcif.crc = v-crcdvi_fiz
                    bxcif.rem = pakaldvi_fiz + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdvi_fiz,">>>>>"))
                    bxcif.type  = v-commdvi_fiz.
        end.
            if wt.amtdvo <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtdvo
                    bxcif.crc = v-crcdvo
                    bxcif.rem = pakaldvo + " за " + string(g-today) + ". Количество " + trim(string(wt.cntdvo,">>>>>"))
                     bxcif.type  = v-commdvo.
        end.
            if wt.amtcti <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtcti
                    bxcif.crc = v-crccti
                    bxcif.rem = pakalcti + " за " + string(g-today) + ". Количество " + trim(string(wt.cntcti,">>>>>"))
                    bxcif.type  = v-commcti.
        end.
        if wt.amtcto <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtcto
                    bxcif.crc = v-crccto
                    bxcif.rem = pakalcto + " за " + string(g-today) + ". Количество " + trim(string(wt.cntcto,">>>>>"))
                    bxcif.type  = v-commcto.
        end.
            if wt.amtcvi <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtcvi
                    bxcif.crc = v-crccvi
                    bxcif.rem = pakalcvi + " за " + string(g-today) + ". Количество " + trim(string(wt.cntcvi,">>>>>"))
                    bxcif.type  = v-commcvi.
            end.
            if wt.amtcvo <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount =  wt.amtcvo
                    bxcif.crc = v-crccvo
                    bxcif.rem = pakalcvo + " за " + string(g-today) + ". Количество " + trim(string(wt.cntcvo,">>>>>"))
                    bxcif.type  = v-commcvo.
            end.
            if wt.amtv2 <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtv2
                    bxcif.crc = v-crcv2
                    bxcif.rem = pakalv2 + " за " + string(g-today) + ". Количество " + trim(string(wt.cntv2,">>>>>"))
                    bxcif.type  = v-commv2.
            end.
            if wt.amtshc <> 0 then
        do:
                    create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn = g-today
                    bxcif.amount = wt.amtshc
                    bxcif.crc = v-crcshc
                    bxcif.rem = pakalshc + " за " + string(g-today) + ". Количество " + trim(string(wt.cntshc,">>>>>"))
                    bxcif.type  = v-commshc.
            end.

        if wt.amtshc1 <> 0 then
        do:
               create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn        = g-today
                    bxcif.amount     = wt.amtshc1
                    bxcif.crc        = v-crcshc1
                    bxcif.rem        = pakalshc1 + " за " + string(g-today) + ". Количество " + trim(string(wt.cntshc1,">>>>>"))
                    bxcif.type       = v-commshc1.
        end.

        if wt.amtshc2 <> 0 then
        do:
               create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn        = g-today
                    bxcif.amount     = wt.amtshc2
                    bxcif.crc        = v-crcshc2
                    bxcif.rem        = pakalshc2 + " за " + string(g-today) + ". Количество " + trim(string(wt.cntshc2,">>>>>"))
                    bxcif.type       = v-commshc2.
        end.


        if wt.amtv2all <> 0 then
        do:
               create bxcif.
                    assign bxcif.cif = wt.cif
                    bxcif.whn        = g-today
                    bxcif.amount     = wt.amtv2all
                    bxcif.crc        = v-crcv2all
                    bxcif.rem        = pakalv2all + " за " + string(g-today) + ". Количество " + trim(string(wt.cntv2all,">>>>>"))
                    bxcif.type       = v-commv2all.
        end.


end. /* for each wt*/


Procedure perev0.
    def input parameter s-aaa like aaa.aaa .
    def input parameter komis as char format "x(4)".
    def input parameter tcif like cif.cif .

    def output parameter kod11 like rem.crc1.
    def output parameter tproc   like tarif2.proc .
    def output parameter tmin1   as dec decimals 10 .
    def output parameter tmax1   as dec decimals 10 .
    def output parameter tost    as dec decimals 10 .
    def output parameter pakal as char.
    def output parameter v-err as log.

    def var a2 like tarif2.kod.
    def var a1 like tarif2.num.
    def var rr as dec.
    def var sum1 like rem.payment.
    def var sum2 like rem.payment.
    def var sum3 like rem.payment.
    def var v-sumkom as dec.
    def var konts like gl.gl.
    def var avl_sum as deci.
    def var comis as logi.

    def buffer bcif for cif.

      v-err = no.
    tproc = 0.
    tost = 0.

      find first tarif2 where tarif2.str5 = komis
                          and tarif2.stat = 'r' no-lock no-error.

      if available tarif2 then
      do :
           if tcif <> "" then
                find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif
                                     and tarifex.stat = 'r' no-lock no-error .
           if avail tarifex then
           do :
            if s-aaa ne '' then
            find first tarifex2 where tarifex2.aaa = s-aaa and tarifex2.cif = tcif and tarifex2.str5 = tarif2.str5 and tarifex2.stat = 'r' no-lock no-error.
            if avail tarifex2 then do:
               find first crc where crc.crc = tarifex2.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex2.pakal.
                konts = tarifex2.kont .

                /* Проверка на неснижаемый остаток */
                 find bcif where bcif.cif = tcif no-lock no-error.
                 comis = yes. /* commission > 0 */
		         avl_sum = avail_bal(s-aaa).
		         if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
		            if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
		        end.

            	tproc =  if comis then tarifex2.proc else 0 .
	        	tmin1 =  if comis then tarifex2.min1 else 0.
    	        tmax1 =  if comis then tarifex2.max1 else 0.
        	    tost  =  if comis then tarifex2.ost  else 0.

            end.
            else do:
            find first crc where crc.crc = tarifex.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex.pakal.
                konts = tarifex.kont .
                tproc = tarifex.proc .
                tmin1 = tarifex.min1 .
                tmax1 = tarifex.max1 .
                tost  = tarifex.ost .
            end.
           end .
           else
           do :
                find first crc where crc.crc = tarif2.crc no-lock .
                kod11 = crc.crc.
                pakal = tarif2.pakal.
                konts = tarif2.kont .
                tproc = tarif2.proc .
                tmin1 = tarif2.min1 .
                tmax1 = tarif2.max1 .
                tost  = tarif2.ost  .
               end.
     end. /*tarif2*/
     else v-err = yes.
end procedure.



