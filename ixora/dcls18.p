/* dcls18.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Комиссия за гросс
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
        01.08.2003 nadejda - небольшая оптимизация циклов убрала условие на ГК 220310, а то с ЧП/ИП комиссия не снимается
        26.05.2004 suchkov - исрпавлен мелкий баг с темповой таблицей wt
        17.11.2004 saltanat - Добавлено снятие комиссии для платежей со штрих-кодами по своим тарифам.
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        11.02.2005 tsoy     - новые тарифы для интернет офиса.
        23.02.2005 tsoy     - изменил g-today на valdt1
        02.03.2005 sasco    - пенсионные и социальные не обрабатываются по гроссу, если платеж < 14-30 по времени
        16.03.2005 tsoy     - убрал return
        17.03.2005 tsoy     - Исключил валютные а также разделил на обработку ЦО и филиалов.
        18.03.2005 tsoy     - изменил временные границы для ЦО
        30.03.2005 tsoy     - изменил put
        09.05.2005 tsoy     - Убрал условие, если платежка до 17.00 но отправили меее по ГРОСУ то снимать комиссию, теперь не снимаем (для Центрального Офиса).
        19.05.2005 tsoy     - изменил определение даты валютирования для интернет платежей
        03.06.2005 tsoy     - добавил условие по срочности платежа
        10.06.2005 tsoy     - добавил no-error и исправил sub-dic на sub-cod.
        15.06.2005 tsoy     - условие срочности для сканированных текущей датой валютирования а не будущей
        21.06.2005 tsoy     - не начисляем гросс на внутренние платежи по Головному филиалу.
        08.08.2005 saltanat - Внесена автоматизация тарифов для физ.лиц по кодам : 214 - 231, 225 - 232, 018 - 230, 019 - 233, 221 - 237, 222 - 235, 017 - 236
        15.08.2005 saltanat - Для физ. лиц убрала снятие комиссий с депозитных счетов.
        16.08.2005 saltanat - Убрала проверку на депозитные счета
        25.08.2005 saltanat - Выборка льгот по счетам.
        02.09.2005 saltanat - В процедуру perev0 передается не aaa.aaa a wt.aaa.
        13.03.2006 sasco    - сумма 5000000 берется из sysc."NETGRO"
        14.08.2006 tsoy     - Для инет  платежей дата первой проводки а не создание платежа
        01.09.2006 tsoy     - теперь для всех работает процедура commCO
        20/09/2013 Luiza   - ТЗ 1916 изменение поиска записи в таблице tarif2


*/
{comm-txb.i}
{global.i}

{curs_conv.i}

def var v-dict as char initial "flg90" no-undo.
def var v-dict2 as char initial "stmt" no-undo.
def var v-amt90 like jl.dam no-undo.
def var v-amt90n like jl.dam no-undo.
def var v-crc like crc.crc initial 1 no-undo.
def var v-f as log no-undo.
def var v-amt like jl.dam no-undo.
def var v-des as char no-undo.

def var v-cbank as char no-undo.
v-cbank = comm-txb ().
def var v-gl like gl.gl no-undo.


def new shared var s-jh like jh.jh no-undo.

def var jparr as char no-undo.
def var vou-count as int no-undo.
def var v-templ as char initial "cif0006" no-undo.
def var v-str as char no-undo.
def var v-balold as dec no-undo.
def var v-intold as dec no-undo.
def var v-rem as char no-undo.

def var vbal like jl.dam no-undo.
def var vavl like jl.dam no-undo.
def var vhbal like jl.dam no-undo.
def var vfbal like jl.dam no-undo.
def var vcrline like jl.dam no-undo.
def var vcrlused like jl.dam no-undo.
def var vooo like aaa.aaa no-undo.


def var kod11 like rem.crc1 no-undo.
def var tproc   like tarif2.proc no-undo.
def var tmin1   as dec decimals 10 no-undo.
def var tmax1   as dec decimals 10 no-undo.
def var tost    as dec decimals 10 no-undo.
def var pakal   as char no-undo.
def var v-err   as log no-undo.

def var v-crca like crc.crc no-undo.
def var v-crcd like crc.crc no-undo.
def var v-crcc like crc.crc no-undo.

def var v-amta as dec no-undo.
def var v-amtd as dec no-undo.
def var v-amtc as dec no-undo.

def var maxcoms as int init 26 no-undo.
def var v-comm  as char extent 26 no-undo.
def var v-commd as char no-undo.
def var v-commc as char no-undo.

def var i as inte init 0 no-undo.
def var j as inte init 0 no-undo.
def var v-branch as char no-undo.
def var v-jurfiz as char no-undo.

def temp-table wt no-undo
field cif    like cif.cif
field aaa    like aaa.aaa
field cnt    as   int extent 26
index wt is unique cif.

def var v-payout as log no-undo.

def var v-arp as char no-undo.
def var v-aaa as char no-undo.

find sysc where sysc = "ourbnk" no-lock no-error. /* Код банка,принятый в Прагме */
 if avail sysc then v-branch = sysc.chval. /*TXB00, TXB01 и т.д.*/

find sysc where sysc  = "arpdt" no-lock no-error .  /* Счет-искл (ARP) для плат карт */
 if available sysc then v-arp = sysc.chval.

find sysc where sysc = "aaact" no-lock no-error.   /* Счет-искл (CIF) для плат карт  */
if available sysc then v-aaa = sysc.chval.

def var netgro as decimal.
netgro = 5000000.
find sysc where sysc.sysc = "NETGRO" no-lock no-error.
if avail sysc then netgro = sysc.deval.

def buffer bjl for jl.

v-comm[1]  = "214".
v-comm[2]  = "220".

v-comm[3]  = "016".  /* Деб.опер.тенге внутр.Internet  будущь дата валютирования 135  */
v-comm[4]  = "017".  /* Деб.опер.тенге внеш.Internet   будущь дата валютирования 135  */
v-comm[5]  = "221".  /* За пл.по грос.Internet б\НДС          170 */

v-comm[6]  = "018".  /* Деб.оп.тенге внутр.Inter.опер         145 */
v-comm[7]  = "019".  /* Деб.оп.тенге внеш.Inter.опер          145 */
v-comm[8]  = "222".  /* За плат.после 17-00 Internet          855 */
v-comm[9]  = "223".  /* за пл. гросс штрих в след оперю день  170 */
v-comm[10] = "215".  /* за пл. гросс в след оперю день        170 */

v-comm[11] = "224".  /* за пл. гросс 16.00 - 17.30 штрих день 845 */
v-comm[12] = "225".  /* за пл. гросс 16.00 - 17.30            835 */

v-comm[13]  = "231". /* 214 - 231 для физ.лиц */
v-comm[14]  = "232". /* 225 - 232 для физ.лиц */
v-comm[15]  = "230". /* 018 - 230 для физ.лиц */
v-comm[16]  = "233". /* 019 - 233 для физ.лиц */
v-comm[17]  = "234". /* 221 - 234 для физ.лиц */
v-comm[18]  = "235". /* 222 - 235 для физ.лиц */
v-comm[19]  = "236". /* 017 - 236 для физ.лиц */
v-comm[20]  = "237". /* 221 - 237 для физ.лиц */

v-comm[21] = "257". /* для юр  лиц с 12-30 до 16-00 бумажные */
v-comm[22] = "258". /* для физ лиц с 12-30 до 16-00 бумажные */

v-comm[23] = "260". /* для юр  лиц с 14-00 до 17-00 интернет */
v-comm[24] = "261". /* для физ лиц с 14-00 до 17-00 интернет */

v-comm[25] = "259". /* для юр лиц с 14-00 до 16-00 сканер */

v-comm[26] = "246". /* для юр лиц свыше 5000000 интернет c датой валютирования */

def var ijh-dt1 as date init today.
def var ijh-rtim as integer.

def var v-is-urgency as logical no-undo.

procedure commCO.

do i = 1 to maxcoms :
/*find tarif2 where tarif2.num eq trim(substring(v-comm[i],1,1))
              and tarif2.kod eq trim(substring(v-comm[i],2,2))
              and tarif2.stat = 'r' no-lock no-error.*/

find first tarif2 where  tarif2.str5 = trim(v-comm[i]) and tarif2.stat = 'r' no-lock no-error.

if available tarif2 then v-crc = tarif2.crc.
else do:
    message "Не найден тариф " v-comm[i].
    pause 100.
end.
end.

output to value("18dcls" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".log").

find crc where crc.crc eq v-crc no-lock no-error.

for each jh where jh.jdt eq g-today no-lock :
    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
    /* проверим платеж по проводке */
    if avail remtrz and remtrz.jh2 = jh.jh  then do:


         /* tsoy 02.06.05 Определяем срочность платежа */
         v-is-urgency = false.

         find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "urgency" no-lock no-error.
         if avail sub-cod then do:
             if sub-cod.ccode = 's' then v-is-urgency = true.
         end.

        /* Интерент платежи будем обрабатывать отдельно */
        if remtrz.source = "IBH" then next.

        if remtrz.ptype = "M" then next.

        /* пенсионные (и социальные) до 14-20 не обрабатываем по гроссу */
        if remtrz.source = "PNJ" and remtrz.rtim <= (14 * 3600 + 20 * 60 ) then next.

        find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
        if available aaa then do:

            if aaa.crc <> 1 then next.

            find sub-cod where sub-cod.sub eq "cif" and sub-cod.d-cod eq "flg90" and sub-cod.acc eq aaa.aaa
                 no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "no" then next.
            find sub-cod where sub-cod.sub eq "cln" and sub-cod.acc eq aaa.cif and
                 sub-cod.d-cod eq "clnsts" no-lock no-error.
            if available sub-cod then do : /* Убрала проверку на юр лицо - and sub-cod.ccode <> "0"*/
                 v-jurfiz = sub-cod.ccode. /* Запоминаем статус клиента */

			    /* 15.08.2005 saltanat - если физ лицо и счет депозитный, то комиссии не снимаем */
			 /*   if v-jurfiz = '1' then do:
			       find lgr where lgr.lgr = aaa.lgr no-lock no-error.
			       if avail lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') then next.
			    end.*/

                find wt where wt.cif eq aaa.cif no-error.
                if not available wt then do:
                    create wt.
                    wt.cif    = aaa.cif.
                    wt.aaa    = aaa.aaa.
                end.

                i = 0.

                if remtrz.source = 'SCN' then do: /* СКАНЕР > */

                      if v-jurfiz ne "0" then next. /* только юр лица */

                      /* свыше 5 млн след. опердень потому что до 5 млн будет клиринг */
                      if (remtrz.valdt2 > remtrz.valdt1 and remtrz.valdt2 = g-today and remtrz.payment >= netgro) then do:

                            i = 9.  /* 223 */
                            put string(v-comm[i]) " " string(i) " " wt.cif " " remtrz.remtrz skip.

                      end.

                      if remtrz.valdt2 = g-today and remtrz.valdt2 = remtrz.valdt1 then do: /* сканер текущим днем */

                          /*  15.06.2005 tsoy     - условие срочности для сканированных текущей датой валютирования а не будущей */

                         if (remtrz.rtim <= 14 * 3600 and (remtrz.payment >= netgro or v-is-urgency))  /* до 14-00 (свыше 5 млн или срочный) сканер */
                         then do:

                            i = 2. /* 220 */
                            put string(v-comm[i]) " " string(i) " "  wt.cif " " remtrz.remtrz skip.

                         end.

                         if  (remtrz.rtim > 14 * 3600 and remtrz.rtim <= 16 * 3600)  /* до 14-00 до 16-00 сканер */
                         then do:

                            i = 25. /* 259 */
                            put string(v-comm[i]) " " string(i) " "  wt.cif " " remtrz.remtrz skip.

                         end.

                         if  remtrz.rtim >  ( 16 * 3600 ) then do: /* свыше 16-00 */

                            i = 11.  /* 224 */
                            put string(v-comm[i]) " " string(i) " " wt.cif " " remtrz.remtrz skip.

                         end.

                      end.

                end. /* < СКАНЕР */
                else do: /* ОБЫЧНЫЕ > */

                   if remtrz.valdt2 = g-today and remtrz.valdt2 > remtrz.valdt1 and remtrz.payment >= netgro and v-jurfiz = "0" then do: /* дата валютирования */
                        i = 10.
                        put string(v-comm[i]) " " string(i) " "  wt.cif " " remtrz.remtrz skip.

                   end.

                   if remtrz.valdt2 = remtrz.valdt1 then do: /* текущий опердень */

                      /* 24.02.2006 sasco поменял время с 16-15 на 16-00 и 12-45 на 12-30 */

                      if (remtrz.rtim <= (12 * 3600 + 30 * 60) and (remtrz.payment >= netgro or v-is-urgency))  /* до 12-30 (свыше 5 млн или срочные) */
                      then do:
                         if v-jurfiz = "0" then i = 1.  /* 214 */
                                           else i = 13. /* 231 */
                         put string(v-comm[i]) " " string(i) " "  wt.cif " " remtrz.remtrz skip.
                      end.

                      if (remtrz.rtim > (12 * 3600 + 30 * 60) and remtrz.rtim <= (16 * 3600))  /* c 12-30 до 16-00 */
                      then do:
                         if v-jurfiz = "0" then i = 21. /* 257 */
                                           else i = 22. /* 258 */
                         put string(v-comm[i]) " " string(i) " "  wt.cif " " remtrz.remtrz skip.
                      end.

                      if (remtrz.rtim > (16 * 3600 /*+ 15 * 60*/ )) then do: /* ГРОСС после 16-15 */

                         if v-jurfiz = "0" then i = 12. /* 225 */
                                           else i = 14. /* 232 */

                         put string(v-comm[i]) " " string(i) " " wt.cif " " remtrz.remtrz skip.

                      end.

                   end. /* ТЕКУЩИЙ ДЕНЬ */

                end. /* ОБЫЧНЫЕ  */

                if i = 0 then next.
                wt.cnt[i] = wt.cnt[i] + 1.

            end. /* avail sub-cod */
        end. /* avail aaa */
    end. /* avail remtrz */
end.   /* each jh */


/* Обработка Интернет платежей */

for each jl where jl.jdt eq g-today and jl.sub eq "CIF" and jl.lev eq 1 no-lock use-index jdtlevsub:
    v-f = yes.

    find jh where jh.jh = jl.jh no-lock no-error.

    find first remtrz where remtrz.remtrz = jh.ref and remtrz.jh1 = jh.jh no-lock no-error.

    if not avail  remtrz then next.

    /* Только интернет платежи */
    if remtrz.source <> 'IBH' then next.

    ijh-dt1 = jh.jdt no-error.

    if remtrz.ptype = "M" then next.


    /* Комиссия с палтежей зарплатных проектов снимается в другом месте */

    if remtrz.rcvinfo[1] = "\/CRDS\/" then next.
    v-payout = remtrz.ptype <> "M".  /* YES = платеж внешний */

    /* tsoy 02.06.05 Определяем срочность платежа */
    v-is-urgency = false.

    find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "urgency" no-lock no-error.
    if avail sub-cod then do:
        if sub-cod.ccode = 's' then v-is-urgency = true.
    end.

    if lookup(string(jl.gl),v-aaa) > 0 then
    do: /*если счет принадлежит к счету исключения для клиентов и снятия идут с льготного АРП-счета - например, карточники переводы делают коммерсантам */
        find bjl where bjl.jh = jl.jh and bjl.sub = "ARP" and bjl.lev = 1  and lookup(string(bjl.gl),v-arp) > 0 and bjl.dc = (if jl.dc = "c" then "d" else "c")  no-lock no-error.
        if available bjl then v-f = no.
    end.

    find trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.trxt = 0 and trxcods.codfr = v-dict no-lock no-error.
        if available trxcods then
    do:
            if trxcods.code eq "no" then v-f = no.
    end.


    find trxcods where trxcods.trxh eq jl.jh and trxcods.trxln eq jl.ln and trxcods.trxt eq 0 and trxcods.codfr eq v-dict2 no-lock no-error.
        if available trxcods then
    do:
            if trxcods.code begins "chg" then v-f = no.
    end.


    if jl.rem[1] begins "Storno" or jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then v-f = no.

    if not v-f then next.


    find aaa where aaa.aaa = jl.acc no-lock no-error.
    if not available aaa then next. /*если не найден то переходим на следующую проводку */

    find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" no-lock no-error. /*if not available sub-cod or sub-cod.ccode <> "0" then next.*/ /*если это не юр лицо то выходим*/
    if not available sub-cod then next. /* Убрала проверку на юр лиц в Алмате, т.к. берем комиссии для физ лиц тоже. */
    v-jurfiz = sub-cod.ccode. /* Запоминаем статус клиента */

    /* 15.08.2005 saltanat - если физ лицо и счет депозитный, то комиссии не снимаем */
  /*  if v-jurfiz = '1' then do:
       find lgr where lgr.lgr = aaa.lgr no-lock no-error.
       if avail lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') then next.
    end. */

    find sub-cod where sub-cod.sub = "cif" and sub-cod.d-cod = "flg90" and sub-cod.acc = aaa.aaa no-lock no-error. /*льготный счет ?*/
    if available sub-cod and sub-cod.ccode = "no" then next. /*счет льготный, выходим*/


     find wt where wt.cif = aaa.cif no-error.
     if not available wt then do:
        create wt.
        wt.cif = aaa.cif.
        wt.aaa = aaa.aaa.
     end.

     if jl.dc = "D" then
     do:
         if jl.crc = 1 then
         do:   /* Дебетовый теньговый */

              if ijh-dt1 = remtrz.valdt2 then do: /* ТЕКУЩИЙ ОПЕРДЕНЬ */

                  /*  Если платеж был с будущей датой а его провели на след день то время ьберем время первой проводки*/

                  if  remtrz.valdt1 <> remtrz.valdt2 then
                     ijh-rtim = jh.tim .
                  else
                     ijh-rtim = remtrz.rtim .

                  if v-payout then do: /* ВНЕШНИЙ */

                         if v-jurfiz = "0" then j = 7.  /* 019 */
                                           else j = 16. /* 233 */

                         wt.cnt[j] = wt.cnt[j] + 1.   /* Деб.оп.тенге внеш.Inter.опер   145 (018)*/

                         put string(v-comm[j]) " " string(j) " " wt.cif " " remtrz.remtrz skip.

                  end.
                  else   do: /* ВНУТРЕННИЙ */


                         if v-jurfiz = "0" then j = 6.  /* 018 */
                                           else j = 15. /* 230 */

                         wt.cnt[j] = wt.cnt[j] + 1.   /* Деб.оп.тенге внутр.Inter.опер  145 (019)*/

                         put string(v-comm[j]) " " string(j) " " wt.cif " " remtrz.remtrz skip.

                  end.

                 /* ********** ОБРАБОТКА ИНТЕРНЕТ ГРОСС *************** */

                  if (ijh-rtim <= (14 * 3600) and (remtrz.payment >= netgro or v-is-urgency))  /* до 14-00 (свыше 5 млн или срочные) */
                  then do:

                     if v-jurfiz = "0" then j = 5.  /* 221 */
                                       else j = 17. /* 234 */

                     wt.cnt[j] = wt.cnt[j] + 1.

                     put string(v-comm[j]) " " string(j) " "  wt.cif " " remtrz.remtrz skip.

                  end.

                  if (ijh-rtim > (14 * 3600) and ijh-rtim <= (17 * 3600))  /* c 14-00 до 17-00 любая сумма */
                  then do:

                     if v-jurfiz = "0" then j = 23.  /* 260 */
                                       else j = 24.  /* 261 */

                     wt.cnt[j] = wt.cnt[j] + 1.

                     put string(v-comm[j]) " " string(j) " "  wt.cif " " remtrz.remtrz skip.

                  end.

                  if ijh-rtim >  17 * 3600 then do: /* после 17-00 */

                              if v-jurfiz = "0" then j = 8. /* 222 */
                                                else j = 18. /* 235 */

                              wt.cnt[j] = wt.cnt[j] + 1.   /* За плат.после 17-00 Internet   855 (222)*/

                              put string(v-comm[j]) " " string(j) " " wt.cif " " remtrz.remtrz skip.

                  end.

              end. /* ТЕКУЩИЙ ОПЕРДЕНЬ */

              else /* ijh-dt1 = remtrz.valdt2 */ do: /* С ДАТОЙ ВАЛЮТИРОВАНИЯ */


                  /* ************** КЛИРИНГОВАЯ ЧАСТЬ ИНТЕРНЕТ **************** */


                  if v-payout then do: /* ВНЕШНИЙ ДАТА ВАЛ */

                         if v-jurfiz = "0" then j = 4.  /* 017 */
                                           else j = 19. /* 236 */

                         wt.cnt[j] = wt.cnt[j] + 1.   /* Деб.опер.тенге внеш.Internet будущь дата валютирования 135 (017)  */

                         put string(v-comm[j]) " " string(j) " " wt.cif " " remtrz.remtrz skip.

                  end.
                  else do: /* ВНУТРЕННИЙ ДАТА ВАЛ */

                       if v-jurfiz = "0" then do: /* только юр лица  */

                         j = 3. /* 016 */
                         wt.cnt[j] = wt.cnt[j] + 1.   /* Деб.опер.тенге внутр.Internet будущь дата валютирования 135 (016) */

                         put string(v-comm[3]) " " string(3) " " wt.cif " " remtrz.remtrz skip.

                       end.

                  end.

                  /* ************** ГРОССОВАЯ ЧАСТЬ ИНТЕРНЕТ **************** */

                  if remtrz.payment >= netgro then do:

                         if v-jurfiz = "0" then j = 26. /* 246 */
                                           else j = 20. /* 237 */

                         wt.cnt[j] = wt.cnt[j] + 1.   /* За пл.по грос.Internet б\НДС   170 (221)*/

                         put string(v-comm[j]) " " string(j) " " wt.cif " " remtrz.remtrz skip.

                  end. /* >= netgro */

              end. /* дата вал */

         end. /* тенговые */
     end.  /* jl.dc */
end. /* jl */

end. /* procedure  commCO */

procedure commFill.

for each jh where jh.jdt eq g-today no-lock :
    find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.

    /* проверим платеж по проводке */
    if avail remtrz and remtrz.jh2 = jh.jh and remtrz.cover = 2 then do:
        find aaa where aaa.aaa eq remtrz.dracc /*and aaa.gl = 220310 01.08.2003 nadejda */ no-lock no-error.
        if available aaa then do:
            find sub-cod where sub-cod.sub eq "cif" and sub-cod.d-cod eq "flg90" and sub-cod.acc eq aaa.aaa
                 no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "no" then next.
            find sub-cod where sub-cod.sub eq "cln" and sub-cod.acc eq aaa.cif and
                 sub-cod.d-cod eq "clnsts" no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "0" then do :
                find wt where wt.cif eq aaa.cif no-error.
                if not available wt then do:
                    create wt.
                    wt.cif    = aaa.cif.
                    wt.aaa    = aaa.aaa.
                end.
                if remtrz.source = 'SCN' then i = 2.
                else i = 1.
                wt.cnt[i] = wt.cnt[i] + 1.
            end.
        end.
    end.
end.

end.   /* procedure  commFill */


run commCO.
/*
if v-cbank = "TXB00" then do:
     run commCO.   /* Снимаем комиссию с учетом времени регистрации платежей в прагме */
end. else do:
     run commFill. /* Время не учитывается для филиалов */
end.
*/

for each wt :

if wt.cnt[1] > 0 then do:
    find cif where cif.cif eq wt.cif no-lock no-error.
    v-err = no.
    run perev0(wt.aaa, v-comm[1] , wt.cif, output v-crca, output tproc,
    output tmin1, output tmax1, output v-amta, output pakal, output v-err).
    if v-err then do:
        message "Не найдена комиссия с кодом " v-comm[1].
        return.
    end.

    v-amt90n = (wt.cnt[1]) * v-amta.
    if v-amt90n > 0 then do:

        create bxcif.
        assign bxcif.cif = wt.cif
               bxcif.whn = g-today
               bxcif.amount = v-amt90n
               bxcif.crc = v-crca
               bxcif.rem = pakal + " за " +
                 string(g-today) +
                 ". Количество " + trim(string((wt.cnt[1]),">>>>>"))
               bxcif.type  = v-comm[1].
    end.
end.

if wt.cnt[2] > 0 then do:
    find cif where cif.cif eq wt.cif no-lock no-error.
    v-err = no.
    run perev0(wt.aaa, v-comm[2] , wt.cif, output v-crca, output tproc,
     output tmin1, output tmax1, output v-amta, output pakal, output v-err).
    if v-err then do:
        message "Не найдена комиссия с кодом " v-comm[2].
        pause 1000.
    end.

    v-amt90n = (wt.cnt[2]) * v-amta.
    if v-amt90n > 0 then do:


        create bxcif.
        assign bxcif.cif = wt.cif
               bxcif.whn = g-today
               bxcif.amount = v-amt90n
               bxcif.crc = v-crca
               bxcif.rem = pakal + " за " +
                 string(g-today) +
                 ". Количество " + trim(string((wt.cnt[2]),">>>>>"))
               bxcif.type  = v-comm[2].

    end.
end.

do i = 3 to maxcoms:

       if wt.cnt[i] > 0 then do:

           find cif where cif.cif eq wt.cif no-lock no-error.
           v-err = no.
           run perev0(wt.aaa, v-comm[i] , wt.cif, output v-crca, output tproc,
           output tmin1, output tmax1, output v-amta, output pakal, output v-err).
           if v-err then do:
               message "Не найдена комиссия с кодом " v-comm[i].
               pause 1000.

           end.

           v-amt90n = (wt.cnt[i]) * v-amta.

           if v-amt90n > 0 then do:

               create bxcif.
               assign bxcif.cif = wt.cif
                      bxcif.whn = g-today
                      bxcif.amount = v-amt90n
                      bxcif.crc = v-crca
                      bxcif.rem = pakal + " за " +
                        string(g-today) +
                        ". Количество " + trim(string((wt.cnt[i]),">>>>>"))
                      bxcif.type  = v-comm[i].

           end.
       end.
end.

end. /* for each wt */

output close.

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
  /*a1 = trim(substring(komis,1,1)).
  a2 = trim(substring(komis,2,2)).
  find first tarif2 where  tarif2.num  = a1
                      and  tarif2.kod  = a2
                      and  tarif2.stat = 'r' no-lock no-error.*/

  find first tarif2 where  tarif2.str5 = trim(komis) and tarif2.stat = 'r' no-lock no-error.
  if available tarif2 then  do :
   if tcif <> "" then
    find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif
                         and tarifex.stat = 'r' no-lock no-error.
   if avail tarifex then do :
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

         		tproc = if comis then tarifex2.proc else 0.
	            tmin1 = if comis then tarifex2.min1 else 0.
    	        tmax1 = if comis then tarifex2.max1 else 0.
        	    tost  = if comis then tarifex2.ost else 0.

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
   else do :
    find first crc where crc.crc = tarif2.crc no-lock .
    kod11 = crc.crc.
    pakal = tarif2.pakal.
    konts = tarif2.kont .
    tproc = tarif2.proc .
    tmin1 = tarif2.min1 .
    tmax1 = tarif2.max1 .
    tost  = tarif2.ost  .
   end .
  end. /*tarif2*/
  else v-err = yes.
end procedure.





