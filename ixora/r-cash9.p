/* r-cash9.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Общий отчет по проведенным кассовым операциям 100100 в разрезе СПФ и доп ARP счетами согласно приложения в ТЗ № 850.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK COMM
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        02.02.2011 Luiza
        15.02.2011 Luiza добавила условие if m-bal <> 1 then do: т.е. в СПФ у которых есть хранилище внебаланс собираться не будет,
                            они будут отражатся в отчете 4.2.14.11.
        20/07/2011 lyubov - изменила алгоритм подсчета документов по дебету
        15.09.2011 Lyubov исправила процедуру addit, а именно cashf.crc = 99, вместо 9
        06.02.2012 lyubov - убрала старые счета СПФ на Розыбакиева и добавила счет для ЦОК на Райымбека
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        24.05.2012 Lyubov - в связи с переходом на раздельное формирование касс. ордеров по комм. платежам, сумму и комиссию считаем за 2 док-та
        09.07.2012 Lyubov - добавлен новый ARP-счет по чековым книжкам для ЦОК на Достык.
        12.07.2012 Lyubov - перекомпиляция
        27.07.2012 Lyubov - перенесла счета для ЦОК из r-cash3
        30.07.2012 Lyubov - исправила ошибку
        31.08.2012 Lyubov - добавила выбор ГК
        19.10.2012 Lyubov - исправила формат вывода числа остатка на начало дня
        30.07.2013 damir - Внедрено Т.З. № 1496.
        02/09/2013 Luiza  - ТЗ 2064 добавила счета для ЦОК Толе-би
        04/09/2013 Luiza  - ТЗ 2075

 * CHANGES
*/
{get-dep.i}.
{nbankBik.i}
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-ln    like aal.ln    no-undo.
def var m-dc    like jl.dc    no-undo.
def var m-bal  as int init 0. /* признак кассы, наличия остатка на начало дня */
def var m-sumd  like aal.amt   no-undo.
def var m-sumk  like aal.amt   no-undo.
def var m-damk  as inte   no-undo.
def var m-camk  as inte   no-undo.
def var m-cashgl like jl.gl    no-undo.
def var v-bnk as char.
def var v-acc1 as char.
def var v_des as char.
def var cbo as char.
def var cbo_dep as int.
def var ll as char no-undo.
def var ll_dep as char no-undo.
def var ll_who as char no-undo.
def var v_dep as int no-undo.
def var v-from as date init today.

define stream rep.

define temp-table wrk1 no-undo
    field gl  like jl.gl
    field jh  like jl.jh
    field dam like jl.dam
    field cam like jl.cam
    field crc like jl.crc
    field who like jl.who
    field tim as char
    field tel like jl.teller
    field rem as char
    field dc  like jl.dc
    field cd  as   inte
    index ind is PRIMARY cd cam dam.

def var s-ourbank as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def var v-select as inte.
def var casgl    as char.
run sel2 (" Выбор ГК ", " 1. 100100 | 2. 100500 ", output v-select).
case v-select:
    when 2 then do: run r-cash91. return. end.
end.

DEFINE VARIABLE cboname AS char FORMAT "x(20)"
       VIEW-AS COMBO-BOX list-items "".

ll = "".
ll_dep = "".
find first ppoint no-lock no-error.
cbo_dep = ppoint.dep.
cbo = entry(1,trim(ppoint.name)).

for each ppoint  no-lock.
    ll = ll + entry(1,trim(ppoint.name)) + ",".
    ll_dep = ll_dep + string(ppoint.dep) + ",".
end.
ll = substring(ll,1,length(ll) - 1).
ll_dep = substring(ll_dep,1,length(ll_dep) - 1).

def temp-table cashf
    field crc like crc.crc
    field des as char
    field bal like glbal.dam
    field dam like glbal.dam
    field damk as inte
    field cam like glbal.cam
    field camk as inte.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    MESSAGE "There is no record OURBNK in bank.sysc file !!" view-as alert-box.
    hide message.
    return.
end.
v-bnk = trim(sysc.chval).

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:
    m-cashgl = sysc.inval.

    def frame opt
        v-from label "  Дата отчета"  help " Задайте дату отчета" skip(1)
        cboname label "  СПФ " help " Выберите СПФ, для вывода списка стрелка вниз, для выбора ENTER" skip
    with side-labels centered row 7 title "Параметры отчета".

    cboname:LIST-ITEMS IN FRAME opt = ll.
    ON VALUE-CHANGED OF cboname
    DO:
        cbo = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE),ll).
    END.

    on end-error of cboname in frame opt do:
        hide frame opt.
        undo, return.
    end.
    on end-error of v-from in frame opt do:
    end.

    on return of cboname in frame opt do:
        empty temp-table cashf.
        for each crc where crc.sts <> 9 no-lock:
            create cashf.
            cashf.crc = crc.crc.
            cashf.des = "".
            cashf.bal = 0.
            cashf.dam = 0.
            cashf.damk = 0.
            cashf.cam = 0.
            cashf.camk = 0.
        end.
        m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
        cbo_dep = integer(entry(lookup(cbo,ll),ll_dep)).
        find first ppoint where ppoint.dep = cbo_dep no-lock no-error.
        if ppoint.info[1] = 'cash' then m-bal = 1.
        else m-bal = 0.

        find first jl where jl.jdt = v-from no-lock no-error.
        if available jl then do:
            for each jl  where jl.jdt = v-from no-lock break by jl.crc by jl.jh by jl.ln :
                if first-of(jl.crc) then do:
                    find crc where crc.crc = jl.crc no-lock no-error.
                    m-sumd = 0. m-damk = 0.
                    m-sumk = 0. m-camk = 0.
                    m-ln = 0.
                    empty temp-table wrk1.
                end.
                if jl.gl = m-cashgl then do:
                    ll_who = jl.who.
                    v_dep = get-dep (ll_who, v-from).
                    if cbo_dep = v_dep then do:
                        if not (jl.rem[1] + jl.rem[2] matches "*обмен валюты*") then
                        find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and not (wrk1.rem matches "*обмен валюты*")  no-error.
                        else
                        find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and wrk1.rem matches "*обмен валюты*"  no-error.
                        if not available wrk1 then do:
                            create wrk1.
                            wrk1.jh = jl.jh.
                            wrk1.crc = jl.crc.
                            wrk1.dam = jl.dam.
                            wrk1.cam = jl.cam.
                            wrk1.dc = jl.dc.
                            wrk1.cd = if wrk1.dc = 'D' then 1 else 2.
                        end.
                        else do:
                            wrk1.dam = wrk1.dam + jl.dam.
                            wrk1.cam = wrk1.cam + jl.cam.
                        end.
                        if jl.dc eq "D" then m-sumd = m-sumd + jl.dam.
                        else m-sumk = m-sumk + jl.cam.
                        m-ln = jl.jh.
                        m-dc = jl.dc.
                    end.
                end.
                if last-of(jl.crc) then do:
                    for each wrk1 exclusive-lock:
                        if wrk1.cd = 1 then m-damk = m-damk + 1.
                        if wrk1.cd = 2 then m-camk = m-camk + 1.
                    end.

                    find first cashf where cashf.crc = jl.crc.
                    cashf.dam  = cashf.dam  + m-sumd .
                    cashf.cam  = cashf.cam  + m-sumk .
                    cashf.damk = cashf.damk + m-damk .
                    cashf.camk = cashf.camk + m-camk .
                end.
            end. /* end  for each jl  where jl.jdt  */
        end.
        m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.

        /******************************************************/
        if m-bal <> 1 then do:
        case v-bnk:
            when "TXB16" then do:  /* Almaty*/
                case cbo_dep:
                    when 1 then do:  /*Калдаякова*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ47470147339A026416  */
                        v-acc1 = "KZ47470147339A026416".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733910 Прочие ценности ПК к выдаче ЦОК на Калдаякова KZ41470147339A039716  */
                        v-acc1 = "KZ41470147339A039716".
                        v_des = "ГК 733910 <br> Прочие ценности <br> ПК к выдаче ЦОК на Калдаякова <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ46470147339A017316  */
                        v-acc1 = "KZ46470147339A017316".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ30470147339A017216 */
                        v-acc1 = "KZ30470147339A017216".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Бланки гарантии </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 2 then do:  /*ЦОК г.Алматы ул. Фурманова*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ96470147339A026116  */
                        v-acc1 = "KZ96470147339A026116".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ62470147339A017416  */
                        v-acc1 = "KZ62470147339A017416".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 5 then do:  /*ЦОК г.Алматы пр-т Абая*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ15470147339A026216  */
                        v-acc1 = "KZ15470147339A026216".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733910 Прочие ценности ПК к выдаче ЦОК на Манаса KZ25470147339A039616  */
                        v-acc1 = "KZ25470147339A039616".
                        v_des = "ГК 733910 <br> Прочие ценности <br> ПК к выдаче ЦОК на Манаса <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ78470147339A017516  */
                        v-acc1 = "KZ78470147339A017516".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 9 then do:  /*ЦОК г.Алматы пр-т Достык*/
                        /* ГК 733910 Прочие ценности ПК к выдаче ЦОК на Достык KZ57470147339A039816  */
                        v-acc1 = "KZ57470147339A039816".
                        v_des = "ГК 733910 <br> Прочие ценности <br> ПК к выдаче ЦОК на Достык <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ59470147339A038616  */
                        v-acc1 = "KZ59470147339A038616".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 12 then do:  /*ЦОК на Райымбека*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ31470147339A026316  */
                        /*v-acc1 = "KZ31470147339A026316".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                        run addit (v-acc1, v_des).*/

                        /* ГК 733910 Прочие ценности ПК к выдаче ЦОК на Райымбека KZ09470147339A039516 */
                        v-acc1 = "KZ09470147339A039516".
                        v_des = "ГК 733910 <br> Прочие ценности <br> ПК к выдаче ЦОК на Райымбека <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ94470147339A017616  */
                        v-acc1 = "KZ84470147339A033316".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 11 then do:  /*СП4 */
                        /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ96470147342A027716 */
                        v-acc1 = "KZ96470147342A027716".
                        v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733910 Прочие ценности Депозитные книги  KZ97470147339A025516  */
                        v-acc1 = "KZ97470147339A025516".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                        /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ16470147339A025616  */
                        v-acc1 = "KZ16470147339A025616".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733910 Прочие ценности Дубликаты ключей KZ81470147339A025416  */
                        v-acc1 = "KZ81470147339A025416".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                        run addit (v-acc1, v_des).
                        /* ГК 733920 Досье клиентов  Досье на балансе  KZ32470147339A025716 */
                        v-acc1 = "KZ32470147339A025716".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе АФ <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733920 Досье клиентов  Досье за  балансом АФ  KZ64470147339A025916 */
                        v-acc1 = "KZ64470147339A025916".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом АФ <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733920 Досье клиентов  Досье на балансе ЦО  KZ48470147339A025816 */
                        v-acc1 = "KZ48470147339A025816".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе ЦО <br> ".
                        run addit (v-acc1, v_des).
                        /* ГК 733920 Досье клиентов  Досье за балансом ЦО  KZ80470147339A026016 */
                        v-acc1 = "KZ80470147339A026016".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом ЦО <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ08470147339A020716  */
                        v-acc1 = "KZ08470147339A020716".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ89470147339A020616 */
                        v-acc1 = "KZ89470147339A020616".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Бланки гарантии </b> <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733970 Гарантии Принятые гарантии KZ63470147339A026516 */
                        v-acc1 = "KZ63470147339A026516".
                        v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733970 Гарантии Выданные  гарантии KZ79470147339A026616 */
                        v-acc1 = "KZ79470147339A026616".
                        v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                        run addit (v-acc1, v_des).

                    end.
                    when 13 then do:  /*ЦОК на Толе-би*/
                        /* ГК 733910 Прочие ценности KZ14470147339A046216 */
                        v-acc1 = "KZ95470147339A046116".
                        v_des = "ГК 733910 <br> Прочие ценности <br> ПК к выдаче ЦОК на Толеби <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733940 Бланки строгой отчетности  KZ95470147339A046116  */
                        v-acc1 = "KZ14470147339A046216".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> <b> Чековые книжки </b> <br> ".
                        run addit (v-acc1, v_des).

                    end.
                end case.
            end.
            when "TXB01" then do: /* Aktobe*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ17470147339A015801  */
                    v-acc1 = "KZ17470147339A015801".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ33470147339A015901  */
                    v-acc1 = "KZ33470147339A015901".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ98470147339A015701  */
                    v-acc1 = "KZ98470147339A015701".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ49470147339A016001 */
                    v-acc1 = "KZ49470147339A016001".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом Ф  KZ65470147339A016101 */
                    v-acc1 = "KZ65470147339A016101".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ81470147339A016201 */
                    v-acc1 = "KZ81470147339A016201".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ97470147339A016301 */
                    v-acc1 = "KZ97470147339A016301".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ87470147339A012601*/
                    v-acc1 = "KZ87470147339A012601".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ06470147339A012701 */
                    v-acc1 = "KZ06470147339A012701".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ22470147339A012801*/
                    v-acc1 = "KZ22470147339A012801".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ17470147342A017401 */
                    v-acc1 = "KZ17470147342A017401".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.

            when "TXB02" then do: /* Kostanay*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ56470147339A015002  */
                    v-acc1 = "KZ56470147339A015002".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ72470147339A015102  */
                    v-acc1 = "KZ72470147339A015102".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ40470147339A014902  */
                    v-acc1 = "KZ40470147339A014902".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ88470147339A015202 */
                    v-acc1 = "KZ88470147339A015202".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом Ф  KZ07470147339A015302 */
                    v-acc1 = "KZ07470147339A015302".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ23470147339A015402 */
                    v-acc1 = "KZ23470147339A015402".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ39470147339A015502 */
                    v-acc1 = "KZ39470147339A015502".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ29470147339A011802*/
                    v-acc1 = "KZ29470147339A011802".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ61470147339A012002   */
                    v-acc1 = "KZ61470147339A012002".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ45470147339A011902  */
                    v-acc1 = "KZ45470147339A011902".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ40470147342A016502 */
                    v-acc1 = "KZ40470147342A016502".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB04" then do: /* Uralsk*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ04470147339A013804  */
                    v-acc1 = "KZ04470147339A013804".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ20470147339A013904  */
                    v-acc1 = "KZ20470147339A013904".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ85470147339A013704  */
                    v-acc1 = "KZ85470147339A013704".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ36470147339A014004 */
                    v-acc1 = "KZ36470147339A014004".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом Ф  KZ52470147339A014104 */
                    v-acc1 = "KZ52470147339A014104".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ68470147339A014204 */
                    v-acc1 = "KZ68470147339A014204".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ84470147339A014304 */
                    v-acc1 = "KZ84470147339A014304".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ90470147339A010704  */
                    v-acc1 = "KZ90470147339A010704".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ25470147339A010904   */
                    v-acc1 = "KZ25470147339A010904".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ09470147339A010804  */
                    v-acc1 = "KZ09470147339A010804".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ04470147342A015404 */
                    v-acc1 = "KZ04470147342A015404".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB03" then do: /* Taraz*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ30470147339A014403  */
                    v-acc1 = "KZ30470147339A014403".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ46470147339A014503  */
                    v-acc1 = "KZ46470147339A014503".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ14470147339A014303  */
                    v-acc1 = "KZ14470147339A014303".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ62470147339A014603 */
                    v-acc1 = "KZ62470147339A014603".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом Ф  KZ78470147339A014703 */
                    v-acc1 = "KZ78470147339A014703".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ94470147339A014803 */
                    v-acc1 = "KZ94470147339A014803".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ13470147339A014903 */
                    v-acc1 = "KZ13470147339A014903".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ84470147339A011103  */
                    v-acc1 = "KZ84470147339A011103".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ03470147339A011203   */
                    v-acc1 = "KZ03470147339A011203".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ19470147339A011303  */
                    v-acc1 = "KZ19470147339A011303".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ30470147342A016003 */
                    v-acc1 = "KZ30470147342A016003".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB05" then do: /* Karaganda*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ88470147339A015105  */
                    v-acc1 = "KZ88470147339A015105".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ07470147339A015205  */
                    v-acc1 = "KZ07470147339A015205".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ72470147339A015005  */
                    v-acc1 = "KZ72470147339A015005".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ23470147339A015305 */
                    v-acc1 = "KZ23470147339A015305".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ39470147339A015405 */
                    v-acc1 = "KZ39470147339A015405".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ55470147339A015505 */
                    v-acc1 = "KZ55470147339A015505".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ71470147339A015605 */
                    v-acc1 = "KZ71470147339A015605".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ77470147339A012005  */
                    v-acc1 = "KZ77470147339A012005".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ45470147339A011805   */
                    v-acc1 = "KZ45470147339A011805".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ61470147339A011905  */
                    v-acc1 = "KZ61470147339A011905".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ88470147342A016705 */
                    v-acc1 = "KZ88470147342A016705".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB06" then do: /* Semey*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ94470147339A014706  */
                    v-acc1 = "KZ94470147339A014706".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ13470147339A014806  */
                    v-acc1 = "KZ13470147339A014806".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ78470147339A014606  */
                    v-acc1 = "KZ78470147339A014606".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ29470147339A014906 */
                    v-acc1 = "KZ29470147339A014906".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ45470147339A015006 */
                    v-acc1 = "KZ45470147339A015006".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ61470147339A015106 */
                    v-acc1 = "KZ61470147339A015106".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ77470147339A015206 */
                    v-acc1 = "KZ77470147339A015206".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ52470147339A010806  */
                    v-acc1 = "KZ52470147339A010806".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ68470147339A010906   */
                    v-acc1 = "KZ68470147339A010906".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ36470147339A010706  */
                    v-acc1 = "KZ36470147339A010706".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ94470147342A016306 */
                    v-acc1 = "KZ94470147342A016306".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB07" then do: /* Kokshetay*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ19470147339A014407  */
                    v-acc1 = "KZ19470147339A014407".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ35470147339A014507  */
                    v-acc1 = "KZ35470147339A014507".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ03470147339A014307  */
                    v-acc1 = "KZ03470147339A014307".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ51470147339A014607 */
                    v-acc1 = "KZ51470147339A014607".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ67470147339A014707 */
                    v-acc1 = "KZ67470147339A014707".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ83470147339A014807 */
                    v-acc1 = "KZ83470147339A014807".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ02470147339A014907 */
                    v-acc1 = "KZ02470147339A014907".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ40470147339A011507  */
                    v-acc1 = "KZ40470147339A011507".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ24470147339A011407   */
                    v-acc1 = "KZ24470147339A011407".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ08470147339A011307  */
                    v-acc1 = "KZ08470147339A011307".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ19470147342A016007 */
                    v-acc1 = "KZ19470147342A016007".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB08" then do: /* Astana*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ22470147339A015808  */
                    v-acc1 = "KZ22470147339A015808".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ38470147339A015908  */
                    v-acc1 = "KZ38470147339A015908".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ06470147339A015708  */
                    v-acc1 = "KZ06470147339A015708".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ54470147339A016008 */
                    v-acc1 = "KZ54470147339A016008".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ70470147339A016108 */
                    v-acc1 = "KZ70470147339A016108".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ86470147339A016208 */
                    v-acc1 = "KZ86470147339A016208".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ05470147339A016308 */
                    v-acc1 = "KZ05470147339A016308".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ76470147339A012508  */
                    v-acc1 = "KZ76470147339A012508".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ92470147339A012608   */
                    v-acc1 = "KZ92470147339A012608".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ11470147339A012708  */
                    v-acc1 = "KZ11470147339A012708".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ22470147342A017408 */
                    v-acc1 = "KZ22470147342A017408".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB09" then do: /* Pavlodar*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ13470147339A014709  */
                    v-acc1 = "KZ13470147339A014709".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ29470147339A014809  */
                    v-acc1 = "KZ29470147339A014809".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ94470147339A014609  */
                    v-acc1 = "KZ94470147339A014609".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ45470147339A014909 */
                    v-acc1 = "KZ45470147339A014909".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ61470147339A015009 */
                    v-acc1 = "KZ61470147339A015009".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ77470147339A015109 */
                    v-acc1 = "KZ77470147339A015109".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ93470147339A015209 */
                    v-acc1 = "KZ93470147339A015209".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ83470147339A011509  */
                    v-acc1 = "KZ83470147339A011509".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ02470147339A011609   */
                    v-acc1 = "KZ02470147339A011609".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ18470147339A011709  */
                    v-acc1 = "KZ18470147339A011709".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ13470147342A016309 */
                    v-acc1 = "KZ13470147342A016309".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB10" then do: /* Petropavlovsk*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ66470147339A015210  */
                    v-acc1 = "KZ66470147339A015210".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ82470147339A015310  */
                    v-acc1 = "KZ82470147339A015310".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ50470147339A015110  */
                    v-acc1 = "KZ50470147339A015110".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ98470147339A015410 */
                    v-acc1 = "KZ98470147339A015410".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ17470147339A015510 */
                    v-acc1 = "KZ17470147339A015510".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ33470147339A015610 */
                    v-acc1 = "KZ33470147339A015610".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ49470147339A015710 */
                    v-acc1 = "KZ49470147339A015710".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ40470147339A011410  */
                    v-acc1 = "KZ40470147339A011410".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ72470147339A011610   */
                    v-acc1 = "KZ72470147339A011610".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ56470147339A011510  */
                    v-acc1 = "KZ56470147339A011510".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ66470147342A016810 */
                    v-acc1 = "KZ66470147342A016810".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB11" then do: /* Atyrau*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ24470147339A014511  */
                    v-acc1 = "KZ24470147339A014511".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ40470147339A014611  */
                    v-acc1 = "KZ40470147339A014611".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ08470147339A014411  */
                    v-acc1 = "KZ08470147339A014411".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ56470147339A014711 */
                    v-acc1 = "KZ56470147339A014711".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ72470147339A014811 */
                    v-acc1 = "KZ72470147339A014811".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ88470147339A014911 */
                    v-acc1 = "KZ88470147339A014911".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ07470147339A015011 */
                    v-acc1 = "KZ07470147339A015011".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ29470147339A011511  */
                    v-acc1 = "KZ29470147339A011511".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ13470147339A011411   */
                    v-acc1 = "KZ13470147339A011411".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ94470147339A011311  */
                    v-acc1 = "KZ94470147339A011311".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ24470147342A016111 */
                    v-acc1 = "KZ24470147342A016111".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB12" then do: /* Aktau*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ13470147339A014612  */
                    v-acc1 = "KZ13470147339A014612".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ29470147339A014712  */
                    v-acc1 = "KZ29470147339A014712".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ94470147339A014512  */
                    v-acc1 = "KZ94470147339A014512".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ45470147339A014812 */
                    v-acc1 = "KZ45470147339A014812".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ61470147339A014912 */
                    v-acc1 = "KZ61470147339A014912".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ77470147339A015012 */
                    v-acc1 = "KZ77470147339A015012".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ93470147339A015112 */
                    v-acc1 = "KZ93470147339A015112".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ02470147339A011512  */
                    v-acc1 = "KZ02470147339A011512".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ83470147339A011412   */
                    v-acc1 = "KZ83470147339A011412".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ18470147339A011612  */
                    v-acc1 = "KZ18470147339A011612".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ13470147342A016212 */
                    v-acc1 = "KZ13470147342A016212".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB13" then do: /* Jezkazgan*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ67470147339A014513  */
                    v-acc1 = "KZ67470147339A014513".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ83470147339A014613  */
                    v-acc1 = "KZ83470147339A014613".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ51470147339A014413  */
                    v-acc1 = "KZ51470147339A014413".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ02470147339A014713 */
                    v-acc1 = "KZ02470147339A014713".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ18470147339A014813 */
                    v-acc1 = "KZ18470147339A014813".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ34470147339A014913 */
                    v-acc1 = "KZ34470147339A014913".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ50470147339A015013 */
                    v-acc1 = "KZ50470147339A015013".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ72470147339A011513  */
                    v-acc1 = "KZ72470147339A011513".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ40470147339A011313   */
                    v-acc1 = "KZ40470147339A011313".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ56470147339A011413  */
                    v-acc1 = "KZ56470147339A011413".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ26470147342A011613 */
                    v-acc1 = "KZ26470147342A011613".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.
            when "TXB14" then do: /* Ust-Kamenogorsk*/
                case cbo_dep:
                    when 1 then do:
                    /* ГК 733910 Прочие ценности Депозитные книги  KZ85470147339A016614  */
                    v-acc1 = "KZ85470147339A016614".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ04470147339A016714  */
                    v-acc1 = "KZ04470147339A016714".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733910 Прочие ценности Дубликаты ключей KZ69470147339A016514  */
                    v-acc1 = "KZ69470147339A016514".
                    v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье на балансе  KZ20470147339A016814 */
                    v-acc1 = "KZ20470147339A016814".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733920 Досье клиентов  Досье за  балансом KZ36470147339A016914 */
                    v-acc1 = "KZ36470147339A016914".
                    v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Принятые гарантии KZ52470147339A017014 */
                    v-acc1 = "KZ52470147339A017014".
                    v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733970 Гарантии Выданные  гарантии KZ68470147339A017114 */
                    v-acc1 = "KZ68470147339A017114".
                    v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ12470147339A011914  */
                    v-acc1 = "KZ12470147339A011914".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ28470147339A012014   */
                    v-acc1 = "KZ28470147339A012014".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                    run addit (v-acc1, v_des).

                    /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ93470147339A011814  */
                    v-acc1 = "KZ93470147339A011814".
                    v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                    run addit (v-acc1, v_des).
                    /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ53470147342A018014 */
                    v-acc1 = "KZ53470147342A018014".
                    v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                    run addit (v-acc1, v_des).
                end.
                end case.
            end.

            when "TXB15" then do: /* Shimkent*/
                case cbo_dep:
                    when 2 then do: /* СП1 Турестан*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ59470147339A016015  */
                        v-acc1 = "KZ59470147339A016015".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 3 then do:  /* СП2 Карасу*/
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ75470147339A016115  */
                        v-acc1 = "KZ75470147339A016115".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                    end.
                     when 1 then do:
                        /* ГК 733910 Прочие ценности Депозитные книги  KZ43470147339A015915  */
                        v-acc1 = "KZ43470147339A015915".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                        /* ГК 733910 Прочие ценности Прочие ценные пакеты  KZ27470147339A015815  */
                        v-acc1 = "KZ27470147339A015815".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Прочие ценные пакеты <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733910 Прочие ценности Дубликаты ключей KZ11470147339A015715  */
                        v-acc1 = "KZ11470147339A015715".
                        v_des = "ГК 733910 <br> Прочие ценности <br> Дубликаты ключей <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733920 Досье клиентов  Досье на балансе  KZ91470147339A016215 */
                        v-acc1 = "KZ91470147339A016215".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье на балансе <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733920 Досье клиентов  Досье за  балансом KZ10470147339A016315 */
                        v-acc1 = "KZ10470147339A016315".
                        v_des = "ГК 733920 <br> Досье клиентов <br> Досье за балансом <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733970 Гарантии Принятые гарантии KZ26470147339A016415 */
                        v-acc1 = "KZ26470147339A016415".
                        v_des = "ГК 733970 <br> Гарантии <br> Принятые гарантии <br> ".
                        run addit (v-acc1, v_des).

                        /* ГК 733970 Гарантии Выданные  гарантии KZ42470147339A016515 */
                        v-acc1 = "KZ42470147339A016515".
                        v_des = "ГК 733970 <br> Гарантии <br> Выданные  гарантии <br> ".
                        run addit (v-acc1, v_des).
                    end.
                end.

                case cbo_dep:
                    when 2 then do: /* СП1 Турестан*/
                        /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ30470147339A014015  */
                        v-acc1 = "KZ30470147339A014015".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 3 then do: /* СП2 Карасу*/
                        /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ78470147339A014315  */
                        v-acc1 = "KZ78470147339A014315".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 1 then do:
                        /* ГК 733940 Бланки строгой отчетности  Бланки гарантии KZ18470147339A011515  */
                        v-acc1 = "KZ18470147339A011515".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Бланки гарантии <br> ".
                        run addit (v-acc1, v_des).
                    end.
                end.
                case cbo_dep:
                    when 2 then do: /* СП1 Турестан*/
                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ95470147339A013815   */
                        v-acc1 = "KZ95470147339A013815".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 3 then do: /* СП2 Карасу*/
                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ46470147339A014115   */
                        v-acc1 = "KZ46470147339A014115".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 1 then do:
                        /* ГК 733940 Бланки строгой отчетности Чековые книжки KZ34470147339A011615   */
                        v-acc1 = "KZ34470147339A011615".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Чековые книжки <br> ".
                        run addit (v-acc1, v_des).
                    end.
                end.
                case cbo_dep:
                    when 2 then do: /* СП1 Турестан*/
                        /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ14470147339A013915  */
                        v-acc1 = "KZ14470147339A013915".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 3 then do: /* СП2 Карасу*/
                        /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ62470147339A014215  */
                        v-acc1 = "KZ62470147339A014215".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                    end.
                    when 1 then do:
                        /* ГК 733940 Бланки строгой отчетности Депозитные книги  KZ02470147339A011415  */
                        v-acc1 = "KZ02470147339A011415".
                        v_des = "ГК 733940 <br> Бланки строгой отчетности <br> Депозитные книги <br> ".
                        run addit (v-acc1, v_des).
                        /* ГК 734200 Разные ценности и документы, отосланные и выданные под отчет KZ59470147342A017615 */
                        v-acc1 = "KZ59470147342A017615".
                        v_des = "ГК 734200 <br> Разные ценности и документы, <br> отосланные и выданные под отчет <br> ".
                        run addit (v-acc1, v_des).
                    end.
                end.
            end.
        end case.
        end. /*  end if m-bal <> 1....*/

        /******************************************************/

        find first ppoint where ppoint.dep = cbo_dep no-lock no-error.
        find first cmp no-lock.

        output stream rep to cas.htm.


        put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.



        for each crc where crc.sts ne 9 no-lock:
           put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr style=""font:bold"" >"
                      "<td align=""center"" >" cmp.name    format 'x(79)' "</td></tr>"
                      "<tr></tr>"
                       skip.
           put stream rep "</table>" skip.
           put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr>"
                      "<td align=""center"" >" ppoint.name    format 'x(79)' "</td></tr>"
                      "<tr></tr>"
                      "<tr> <td>  </td> </tr>"
                       skip.
           put stream rep "</table>" skip.
           put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

           put stream rep unformatted "<tr style=""font:bold"" ><td align=""center"" >Сводная справка о кассовых оборотах за день <BR>".
           put stream rep unformatted "</td></tr>" skip.
           put stream rep unformatted "<tr style=""font:bold"" >"
                                      "<td align=""center"" > за " string(v-from) " г. </td></tr>"  skip.
           put stream rep "</table>" skip.

           put stream rep unformatted "<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td align=""center"" rowspan=2>Наименование <br> ценностей</td>"
                  "<td align=""center"" rowspan=2>Код <br> вал</td>"
                  "<td rowspan=2>Остаток на <br> начало дня</td>"
                  "<td colspan=2>Приход</td>"
                  "<td colspan=2>Расход</td>"
                  "<td rowspan=2>Остаток на <br> конец дня</td>"
                  "</tr>"
                   skip.

           put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "</tr>"
                   skip.

            find first cashf where cashf.crc = crc.crc no-lock no-error.
            if v-bnk = "TXB15" then do:  /* для Чимкента остаток на начало дня берем из bank.caspoint */
                find last bank.caspoint where  bank.caspoint.depart = cbo_dep and bank.caspoint.rdt < v-from and bank.caspoint.crc = crc.crc and bank.caspoint.info[1] = string(m-cashgl) no-lock no-error.
                if available bank.caspoint then
                   put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                           "<td align=""center"">" crc.code "</td></b>"
                           "<td align=""center"">" crc.crc "</td>"
                           "<td>" bank.caspoint.amount format "->>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.damk "</td>"
                           "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.camk "</td>"
                           "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" (bank.caspoint.amount + (cashf.dam - cashf.cam)) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                           "</tr>".

                else
                       put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                               "<td align=""center"">" crc.code "</td></b>"
                               "<td align=""center"">" crc.crc "</td>"
                               "<td>" 0.00 format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.damk "</td>"
                               "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.camk "</td>"
                               "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td>" (cashf.dam - cashf.cam) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                               "</tr>".

            end. /* end if v-bnk = "TXB15"  */
            else do:
                if m-bal = 1 then do: /* есть хранилище, есть остаток в glday*/
                    find last glday where glday.gl = m-cashgl and glday.crc = crc.crc and glday.gdt < v-from no-lock no-error.
                    if available glday then
                       put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                               "<td align=""center"">" crc.code "</td></b>"
                               "<td align=""center"">" crc.crc "</td>"
                               "<td>" glday.bal format "->>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.damk "</td>"
                               "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.camk "</td>"
                               "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td>" (glday.bal + (cashf.dam - cashf.cam)) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                               "</tr>".

                    else
                     put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">"
                               "<td>" crc.code "</td>"
                               "<td></td>" skip
                               "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td></td>" skip
                               "</tr>".
                end.
                else do:  /* у СПФ нет хранилища остаток на начало = 0 */
                       put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                               "<td align=""center"">" crc.code "</td></b>"
                               "<td align=""center"">" crc.crc "</td>"
                               "<td>" 0.00 format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.damk "</td>"
                               "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td align=""center"">" cashf.camk "</td>"
                               "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                               "<td>" (cashf.dam - cashf.cam) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                               "</tr>".
                end.
            end. /* end else do  */

            if crc.crc = 1 then do:
                for each cashf where cashf.crc = 99 no-lock.
                    if cashf.des matches "*Бланки строгой отчетности*"
                          then put stream rep unformatted "<tr align=""right"" style=""font-size:8.0pt"">".
                          else put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">".
                          put stream rep unformatted
                              "<td align=""center"">" cashf.des "</td>"
                              "<td align=""center"">" crc.crc "</td>"
                              "<td>" cashf.bal format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td align=""center"">" cashf.damk "</td>"
                              "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td align=""center"">" cashf.camk "</td>"
                              "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td>" (cashf.bal + (cashf.dam - cashf.cam)) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                              "</tr>".
                end.
            end.
            put stream rep "</table>" skip.

            put stream rep unformatted "<br><br><table width=100% cellpadding=""7"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                      "<tr >"
                      "<td colspan=3>Заведующий кассой ______________</td><td ></td><td colspan=3>Обороты сверены с балансовыми <br> данными (лицевым счетом)</td>"
                      "</tr>"
                      "<tr >"
                      "<td align=""center"" colspan=3>(подпись)</td><td ></td><td colspan=3>______________________</td>"
                      "</tr>"
                      "<tr >"
                      "<td colspan=3></td><td ></td><td colspan=3>(подпись бухгалтера)</td>"
                      "</tr></table>"
                      skip.

            put stream rep "<br clear=all style='page-break-before:always'>" skip.
        end.

        put stream rep "</body></html>" skip.
        output stream rep close.

        unix silent cptwin cas.htm winword.
    end. /* end on return of cboname */

    update  v-from with frame opt.
    cboname = cbo.
    update  cboname FORMAT "x(30)" with frame opt.

    /*hide frame  opt.*/
end. /* end  if available sysc then do */
else do:
    message "Нет записи CASHGL в sysc".
end.


procedure addit:
    def input parameter v_acc1 as char.
    def input parameter v_des as char.
    m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
    for each jl  where jl.jdt = v-from and jl.acc = v-acc1 no-lock  break by jl.jh by jl.ln :
        if jl.dc eq "D" then do:
            m-sumd = m-sumd + jl.dam.
            if jl.jh ne m-ln then m-damk = m-damk + 1.
        end.
        else do:
            m-sumk = m-sumk + jl.cam.
            if jl.jh ne m-ln then m-camk = m-camk + 1.
        end.
        m-ln = jl.jh.
    end.
    find last histrxbal where histrxbal.sub = 'arp' and histrxbal.acc = v-acc1 and histrxbal.level = 1 and histrxbal.crc = 1 and histrxbal.dt < v-from no-lock no-error.
    create cashf.
    cashf.crc = 99.
    cashf.des = v_des + v-acc1.
    if avail histrxbal then do:
        cashf.bal = histrxbal.dam - histrxbal.cam.
    end.
        cashf.dam  = cashf.dam  + m-sumd .
        cashf.cam  = cashf.cam  + m-sumk .
        cashf.damk = cashf.damk + m-damk .
        cashf.camk = cashf.camk + m-camk .
end procedure.


