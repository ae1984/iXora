/* prtppp.p
 * Модуль
        Все модули
 * DESCRIPTION
        Описание - Процедура печати платежных поручений, пенсионных отчислений и отчислений по заработной плате.
 * Применение
        Применяется при печати всех видов п/п поручений
 * Вызов

 * MENU
        Пункт меню - 5.7.2;2.2.5;6.4.1;6.4.2.
 * AUTHOR
        Пропер С.В.
 * BASES
        BANK COMM IB
 * Дата создания:
        17.04.00
 * CHANGES
        19.03.01  исходящий платеж от имени банка (arp)
        05.12.01 sasco  настройка принтера из ofc
        14.05.02 KOVAL вал.контроль для РКО и филиалов, изменение внешнего вида валютных платежей
        21.02.03 nadejda добавлен поиск РНН в простом слиянии строк деталей платежа,
                         поскольку он иногда разносится на 2 строки и тогда не отображается в платежке
        08.07.03 kanat для таможенных платежей в v-m2 проставляется РНН плательщика вместо РНН Банка отправителя
        26.07.03 kanat для налоговых платежей в v-m2 проставляется РНН плательщика вместо РНН Банка отправителя
        31.07.03 sasco для пенсионных ИнтернетОфиса автоматичеки печатается реестр пенс. отчислений (который regs)
        05.11.03 sasco вывод всей МБ информации (rcvinfo)
        08.12.03 sasco МФО берется из таблицы comm.txb
        09.12.03 sasco обработка 71 поля из swbody
        14.03.04 kanat В v-m2 также проставляется РНН плательщика для проичх платежей
        26.04.04 tsoy  Добавил дополнительню информацию в swift для физ лиц.
        04.08.04 kanat Добавил вывод РНН плательщика для пенсионных платежей
        21.09.04 sasco обработка /PSJ/ для поиска РНН
        30.11.04 u00121 Детали платежа теперь выводятся полностью
        23.03.05 sasco Вывод необрезанных деталей платежа
        04.05.05 kanat добавил проверки на АРП районных таможен
        11.05.05 dpuchkov добавил подтверждение на перевод для внутренних переводов физ лиц в Internet Office.
        27.12.05 dpuchkov Изменил содержание записи "Подтверждаю что...." Служебная записка от 27.12.2005
        24.06.2006 tsoy     - Если платеж на АРП картела то показывать реквизиты Картела в АТФ банке
        07/07/2009 galina - добавила распечатку реестра для ИР по ОПВ и СО
        13.04.2010 id00004 добавил вызов скрипта zar2reg для зарплатных платежей интернет банкинга
        28.10.2010 id00004 увлечил длину отображения поля 57: и 59:
        02.06.2011 id00004 в платеже добавил надпись "проведено по ситеме Интернет-банкинга"
        13.06.2011 id00004 в платеже добавил надпись "проведено по ситеме Интернет-банкинга" для валютных платежей
        20.09.2011 dmitriy - в поле "Назначение платежа" поставил trim и добавил наименование КБК
        22.09.2011 dmitriy - добавил if avail budcodes
        27.09.2011 aigul - вывод данных для платежей из ИБ
        28.09.2011 aigul - вывод 56-поля
        06/10/2011 Luiza - добавила условие проверки есть ли remtrz.jh3 при определении РНН плательщика
        20/10/2011 madiyar - поправил для корректного определения РНН и наименования отправителя по платежам Народного банка
        21/10/2011 madiyar - читаем 3 элемент в remtrz.ord только если он есть
        21/10/2011 evseev - повтор от 10/10/2011, т.к. затерли. Переход на ИИН/БИН и правка из-за изменение формата 102
        24/10/2011 evseev - дописал {chbin.i}
        24/10/2011 evseev - сокращение бенефециара до РГКП ГЦВП.
        01.11.2011 aigul - исправила вывод 57-поля для Рублей
        24.11.2011 aigul - исправила вывод 56 поля
        25.11.2011 aigul - справила вывод 57 поля
        06.12.2011 aigul - убрала удаление файла
        22/12/2011 id00004 добавил переменную для перехода на ИИН-БИН для платежей Интернет-банкинга
        11/01/2012 Luiza - если f-gname = "a_kz" то вывод поручения сразу в word
        12/01/2012 Luiza - добавила {mainhead.i}
        17.01.2012 damir - формирование платежного документа в WORD.
        18.01.2012 damir - перекомпиляция в связи с изменением printplat.i
        27.01.2012 aigul - добавила номер счета для 50 поля
        27/01/2012 Luiza - отменила если f-gname = "a_kz" то вывод поручения сразу в word
        28.02.2012 aigul - исправила вывод 57 поля для ИБ
        07.03.2012 damir - печать новых форматов платежных поручений и реестров пенсионных отчислений, keyord.i.
        07.03.2012 damir - добавлено имя руководителя из справочника.
        14.03.2012 damir - перекомпиляция в связи с изменением printplat2.i
        15/03/12 id00810 - добавила v-bankname для печати
        04.04.2012 damir - корректировка по шаблону реестра пенсионных поручений.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        05/05/2012 evseev - при формировании ПП удалять город и при дате до 07/05/2012 использовать МЕТРОКОМ
        07/05/2012 evseev - подключил replacebnk.i
        17/05/2012 evseev - тз1362
        30.05.2012 evseev - убрал trim в bn[]
        14.08.2012 evseev - оnключил replacebnk.i
        05/06/2012 Luiza  - изменила передаваемые параметры для findjh3
        11.09.2012 damir  - Тестирование ИИН/БИН,перекомпиляция в связи с изменениями в printplat2.i,printplat3.i.
        19.12.2012 damir  - Тестирование ИИН/БИН. Подправил в процедуре print_PNJ.
        25.12.2012 Lyubov - исправлена переменная v57, некорректно подтягивались данные
        26.12.2012 damir  - Внедрено Т.З. 1624.Изменение по платежному поручению.printplat2.i.
        02.01.2013 damir  - Переход на ИИН/БИН.
        19.01.2013 damir  - Изменения по форме и выводе данных в WORD пенсионных и социальных отчислений. Добавлена GetRnnRmz.i.
        28.01.2013 damir  - Перекомпиляция в связи с изменением GetRnnRmz.i.
        08.02.2013 evseev - tz-1711
        26.02.2013 damir  - Внедрено Т.З. № 1732.
        26.03.2013 Luiza  - *ТЗ 1714 добавила if avail cif в процедурах - prtppv,prtppvf.
        23.04.2013 damir  - Исправлена техническая ошибка. Вывод <50:> в procedure prtppvnew.
        24/05/2013 Luiza - ТЗ 1719 замена текста РНН на ИИН/БИН
        30.09.2013 damir - Внедрено Т.З. № 1513,1648.
        04.10.2013 damir - Перекомпиляция, связанная с изменениями 30.09.2013.
        01.11.2013 evseev tz926
*/

/*ВНИМАНИЕ!!!*/
/*{printplat2.i} - Платежное поручение WORD, вызывается программами prtppp.p;extract.p*/

{mainhead.i}
{yes-no.i}
{comm-txb.i}
{chbin.i}
{keyord.i} /*Переход на новые и старые форматы*/
{GetRnnRmz.i}

def new shared var V-OFILEINPUT_1 as char init "Orderplat.htm".
def new shared var V-OFILEINPUT_2 as char init "SWTREG.htm".
def new shared var V-OFILEINPUT_3 as char init "Pension.htm".

def new shared var s-Print_1 as logi.
def new shared var s-Print_2 as logi.
def new shared var s-Print_3 as logi.

def shared var s-remtrz like remtrz.remtrz.
define variable seltxb as int.
seltxb = comm-cod().

def stream m-out.
def var v-su        like remtrz.payment.
def var ourbank     like sysc.chval.
def var ourbcode    like sysc.chval.
def var i           as int.
def var j           as int.
def var k           as int.
def var ij          as int.
def var vdatu       as char format 'x(013)'.
def var v-mudate    as char format 'x(070)'. /* v-valdt  */
def var v-mudate2   as char format 'x(016)'. /* v-valdt2 */
def var v-m1        as char format 'x(060)'. /* v-ord    */
def var v-m2        as char format 'x(012)'. /* v-rnn    */
def var v-bm1       as char format 'x(028)'. /* v-ordins */
def var v-bm2       as char format 'x(043)'. /* v-ordins */
def var v-bm3       as char format 'x(043)'. /* v-ordins */
def var v-bbbb      as char format 'x(043)'.
def var v-km        as char format 'x(015)'. /* номер счета плательщика */
def var v-km1       as char format 'x(015)'. /* номер счета плательщика */
def var v-kbm       as char format 'x(009)'. /* код банка плательщика */
def var v-sm        as char format 'x(016)'. /* v-payment */
def var v-s1        as char format 'x(033)'. /* v-bn */
def var v-s2        as char format 'x(043)'. /* v-bn */
def var v-bs1       as char format 'x(028)'. /* v-bb */
def var v-bs2       as char format 'x(043)'. /* v-bb */
def var v-kbs       as char format 'x(009)'. /* код банка получателя */
def var v-ks        as char format 'x(020)'. /* v-ba */
def var v-ks1       as char format 'x(020)'. /* v-ba */
def var v-numurs    as char format 'x(070)'.
def var v-chief     as char format 'x(030)'.
def var v-code      as char format 'x(035)'.
def var v-plars     as char format 'x(002)'.
def var v-polrs     as char format 'x(002)'.
def var v-knp       as char format 'x(003)'.
def var v-knps      as char format 'x(087)'.
def var v-sumt      as char extent 6 format 'x(56)'.
def var v-56        as char extent 4 format 'x(50)'.
def var v-57        as char extent 6 format 'x(50)'.
def var v-72        as char format 'x(50)'.
def var v-strtmp    as char.
def var v-sd        as char.
def var v-ls        as char.
def var v-cif       as char.
def var v-tmp       as char.
def var v-val       as logical init false.
def var v-new       as logical init false.
def var m_pid       like bank.que.pid.
def var v-detch     as char. /*Назначение платежа из RMZ в одну переменную u00121 30/11/2004*/
def var glbuhgalter as char.
def var v-ifileinput as char.
def var v-num       as int.
def var v-addr      as char.
def var v-addr1     as char.
def var v-56chk     as char.
def var v-56chk1    as char.
def var v-56chk2    as char.
def var v-56chk3    as char.
def var v-56chk4    as char.
def var v-56chk5    as char.
def var v-num56     as int.
def var v-acc       as char.
def var v-acc1      as char.
def var v57         as char.
def var v-str as char.
def var v-nameorganization as char init "".
def var v-rnnorgone as char init "".
def var v-kbeorgone as char init "".
def var v-accorgone as char init "".
def var v-bicbnkone as char init "".
def var v-nameorgtiontwo as char init "".
def var v-rnnorgtwo as char init "" .
def var v-accorgtwo as char init "".
def var v-bicbnktwo as char init "".
def var v-mainbk as char.

def var a as inte init 0.
def var b as inte init 0.
def var c as inte init 0.
def var d as inte init 0.
def stream v-out.

def var s-cust-arp  as char.
def var s-toter-arp as char.
def var v-bankname  as char no-undo.
def var v-bnkbin as char.

/*------------------------------------------------*/
def var v-file      as char init "/data/export/pensioncom.htm".
def var v-outfile   as char init "1.htm".
def var v-outfile2  as char init "2.htm".
def var v-outfile3  as char init "3.htm".
def var v-outfile4  as char init "4.htm".

def stream rep.
def stream rep2.
def stream rep3.
def stream rep4.

output stream v-out to value(V-OFILEINPUT_1).
output stream rep2  to value(V-OFILEINPUT_2).
output stream rep4  to value(V-OFILEINPUT_3).
{html-title.i &stream = "stream v-out"}
{html-title.i &stream = "stream rep2"}
{html-title.i &stream = "stream rep4"}

def temp-table t-data
    field num as char
    field sik as char
    field rnnbin as char
    field fio as char
    field fioreg as char
    field birthday as char
    field sum as char.

def temp-table t-temp
    field k as char
    field sik as char
    field fio as char
    field fioreg as char
    field birthday as char
    field rnnbin as char
    field sum as char
    field iik as char.

/*{replacebnk.i}*/

/*------------------------------------------------*/


                    find first sysc where sysc = 'cstarp' no-lock no-error.
                    if avail sysc then do:
                    s-cust-arp = sysc.chval.
                    end.
                    else do:
                    run tb( 'Ошибка', '', 'Отсутствуют данные по АРП счетам таможенных платежей!', '' ).
                    return.
                    end.

                    find first sysc where sysc = 'ttsarp' no-lock no-error.
                    if avail sysc then do:
                    s-toter-arp = sysc.chval.
                    end.
                    else do:
                    run tb( 'Ошибка', '', 'Отсутствуют данные по АРП счету прочих платежей!', '' ).
                    return.
                    end.


find sysc where sysc.sysc = 'CLECOD' no-lock no-error.
if not avail sysc then do:
   run tb( 'Ошибка', '', 'Записи CLECOD нет в файле sysc!', '' ).
   return.
end.
ourbcode = trim( sysc.chval ).

find sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
   run tb( 'Ошибка', '', 'Записи OURBNK нет в файле sysc!', '' ).
   return.
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = 'bnkbin' no-lock no-error.
if avail sysc then v-bnkbin = trim(sysc.chval).

find first sysc where sysc.sysc = "bankname" no-lock no-error.
if not avail sysc or sysc.chval = '' then do:
   run tb( 'Ошибка', '', 'Записи BANKNAME нет в файле sysc!', '' ).
   return.
end.
v-bankname = sysc.chval.

find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if not available remtrz then do:
   run tb( 'Ошибка', '', 'Отсутствует платеж с RMZ ' + s-remtrz + '!', '' ).
   return.
end.



/* sasco - обработка 71 поля */
find swbody where swbody.rmz = remtrz.remtrz and swbody.swfield = '71' and swbody.type = 'A' no-lock no-error.

if remtrz.rbank = ourbank
then v-ls = trim( if remtrz.racc <> '' then remtrz.racc else remtrz.cracc ).
else v-ls = trim( if remtrz.sacc <> '' then remtrz.sacc else remtrz.dracc ).
if length(v-ls) < 9 then v-ls = fill( '0', 9 - length( v-ls )) + v-ls.

find first cmp no-lock no-error.
if not avail cmp then do:
   run tb( 'Ошибка', '', 'Отсутствуют данные о банке!', '' ).
   return.
end.

find first que where que.remtrz = remtrz.remtrz no-lock no-error.
if not avail que then do:
   run tb( 'Ошибка', '', 'Отсутствует очередь для ' + remtrz.remtrz + '!', '' ).
   return.
end.

m1: do:
   find first aaa where aaa.aaa = v-ls no-lock no-error.
   if avail aaa then do:
      v-cif = aaa.cif.
      leave m1.
   end.

   find first arp where arp.arp = v-ls no-lock no-error.
   if avail arp then do:
      v-cif = arp.cif.          /* Для таможни он пустой */
      leave m1.
   end.

   find first lon where lon.lon = v-ls no-lock no-error.
   if avail lon then do:
      v-cif = lon.cif.
      leave m1.
   end.

   run tb( 'Ошибка', '', 'Отсутствует счет ' + v-ls + '!', '' ).
   if que.pid <> "3G" then return.
end.

if v-cif <> '' then do.
   find first cif where cif.cif = v-cif no-lock no-error.
   if not avail cif then do:
      run tb( 'Ошибка', '', 'Отсутствует клиент ' + v-cif + '!', '' ).
      return.
   end.
end.

find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
if not avail bankl then do:
   run tb( 'Ошибка', '', 'Отсутствует банк ' + remtrz.rbank + '!', '' ).
end.

find first ofc where ofc.ofc = userid('bank') no-lock no-error.
if not avail ofc then do:
   run tb( 'Ошибка', '', 'Отсутствует офицер ' + userid( 'bank' ) + '!', '' ).
   return.
end.

find first crc where crc.crc = remtrz.tcrc no-lock no-error.
if not avail crc then do:
   run tb( 'Ошибка', '',
   'Отсутствует валюта ' + string( remtrz.tcrc ) + '!', '' ).
   return.
end.
if v-cif <> '' then do.
   find first sub-cod where sub-cod.sub   = 'cln'
                        and sub-cod.ccode = 'chief'
                        and sub-cod.acc   = string( cif.cif )
                        no-lock no-error.
   if avail sub-cod then
      v-chief = if remtrz.rbank begins 'TXB' then ''
                else trim( sub-cod.rcode ).
end.
else  v-chief = ''.
 /* do.
   find sysc where sysc.sysc = 'chief' no-lock no-error.
   if not avail sysc or sysc.chval = '' then do:
      run tb( 'Ошибка', '', 'Записи CHIEF нет в файле sysc!', '' ).
      return.
   end.
   v-chief = sysc.chval.
end.    */

/*** KOVAL ***/
if remtrz.tcrc <> 1 then v-val = true. else v-val = false.
if v-val then do:
        find first swout where swout.rmz = remtrz.remtrz and swout.deluid=? no-lock no-error.
        if avail swout then v-new = true. else v-new = false.
end.
/*** KOVAL ***/


if remtrz.source = 'IBH' then do:
   find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
   if not avail netbank then do:
      {conn-ibh.i}
      find first ib.doc where ib.doc.remtrz = remtrz.remtrz no-lock no-error.
      if avail ib.doc then do:
          v-56[1] = trim(ib.doc.ibname[1]).  /* 56: */
          v-56[2] = trim(ib.doc.ibname[2]).
          v-56[3] = trim(ib.doc.ibname[3]).
          v-56[4] = trim(ib.doc.ibname[4]).

          /*57: Номер счета и наименование банка-получателя в банке-корреспонденте:*/
          if v-val then v-tmp = trim(remtrz.actins[1]) + trim(remtrz.actins[2]) + trim(remtrz.actins[3] + trim(remtrz.actins[4])).
                   else v-tmp = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) + trim(remtrz.bb[3]).
          v-57[1] = trim(substring( v-tmp, 001, 80 )).
          v-57[2] = trim(substring( v-tmp, 081, 80 )).
          v-57[3] = trim(substring( v-tmp, 161, 80 )).

          v-tmp   = trim(ib.doc.bbname[1]) + trim(ib.doc.bbname[2]) + trim(ib.doc.bbname[3]) + trim(ib.doc.bbname[4]).
          v-57[4] = trim(substring( v-tmp, 01, 80 )).
          v-57[5] = trim(substring( v-tmp, 81, 80 )).
          v-code  = ib.doc.ibinfo[4].
      end.
   end.
  /*Новый интернет-банкинг*/
   else do:
      v-56[1] = "".  /* 56: */
      v-56[2] = "".
      v-56[3] = "".
      v-56[4] = "".

      /*57: Номер счета и наименование банка-получателя в банке-корреспонденте:*/
      if v-val then v-tmp = trim(remtrz.actins[1]) + trim(remtrz.actins[2]) + trim(remtrz.actins[3] + trim(remtrz.actins[4])).
               else v-tmp = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) + trim(remtrz.bb[3]).
      v-57[1] = trim(substring( v-tmp, 001, 80 )).
      v-57[2] = trim(substring( v-tmp, 081, 80 )).
      v-57[3] = trim(substring( v-tmp, 161, 80 )).

      v-tmp   = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) + trim(remtrz.bb[3]) .
      v-57[4] = trim(substring( v-tmp, 01, 80 )).
      v-57[5] = trim(substring( v-tmp, 81, 80 )).
      v-code  = "".
   end.
end.
else do:
   v-56[1] = if avail bankl then trim(bankl.name) else ''.
   if v-val then v-tmp = trim(remtrz.actins[1]) + trim(remtrz.actins[2]) + trim(remtrz.actins[3] + trim(remtrz.actins[4])).
            else v-tmp = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) + trim(remtrz.bb[3]).
   v-tmp   = trim(remtrz.bb[1]) + trim(remtrz.bb[2]) + trim(remtrz.bb[3]).
   v-57[1] = trim(substring( v-tmp, 001, 80 )).
   v-57[2] = trim(substring( v-tmp, 081, 80 )).
   v-57[3] = trim(substring( v-tmp, 161, 80 )).
   v-57[4] = trim(substring( v-tmp, 241, 80 )).
end.
/*
if error-status:error then do:
   run tb(
   'Внимание!',
   'В базе данных ошибка!',
   'Обратитесь к Администратору...',
   '(prtpp.p:' + v-ls + ')' ).
   return.
end.
*/
v-su     = remtrz.payment.
v-sm     = string( v-su,'>>,>>>,>>>,>>9.99' ).
v-numurs = trim( substring( remtrz.sqn,19,8 )).
v-mudate = string( remtrz.valdt1, '99/99/9999' ).
v-mudate2 = string( remtrz.valdt2, '99/99/9999' ).
v-numurs = if v-numurs = '' then remtrz.remtrz else
v-numurs + ' (' + remtrz.remtrz + ')'.

if remtrz.source = 'IBH'  then do:
   v-numurs = v-numurs + "              Проведено по системе ".
   v-mudate = v-mudate + "                           Internet Banking".
end.

if v-val then do:
    v-m1 = GetNameBenOrd(remtrz.ord).
    v-m2 = GetRnnBenOrd(remtrz.ord).

    /*i = r-index(remtrz.ord, '/RNN/').
    if i <> 0 then do:
       v-m1 = trim( substring( remtrz.ord, 1, i - 1 )).
       v-m2 = trim( substring( remtrz.ord, i + 5, 12 )).
    end.
    else do:
        v-m1 = entry(1, remtrz.ord, "/").
        if num-entries(remtrz.ord,"/") > 2 then v-m2 = "RNN" + entry(3, remtrz.ord, "/").
    end.

    message "v-m1=" v-m1 "v-m2=" v-m2 view-as alert-box.*/
end.
else do:  /* теньговые платежики */
    v-m1 = GetNameBenOrd(remtrz.ord).
    v-m2 = GetRnnBenOrd(remtrz.ord).

    /*v-m1 = trim( remtrz.ord ).
    i = r-index( remtrz.ord, '/RNN/' ).
    if i <> 0 then do:
        v-m1 = trim( substring( remtrz.ord, 1, i - 1 )).
        v-m2 = trim( substring( remtrz.ord, i + 5, 12 )).
    end.
    else do:
        v-m1 = entry(1, remtrz.ord, "/").
        if num-entries(remtrz.ord,"/") > 2 then v-m2 = "RNN" + entry(3, remtrz.ord, "/").
    end.
    message "v-m1=" v-m1 "v-m2=" v-m2 view-as alert-box.*/

    /* Luiza ----проверяем была ли третья проводка, если v-jh3 будет > 0 тогда значение v-m2 рнн не меняем на рнн банка--------*/
    def var v-jh3 as int.
    v-jh3 = remtrz.jh3.
    if (remtrz.jh3 <= 0 or remtrz.jh3 = ?) and remtrz.sqn begins "TXB" then  run findjh3(trim(remtrz.sbank), substring(remtrz.ref,11,10), output v-jh3).
    if v-jh3 <= 0 or v-jh3 = ?  then do:
        if v-cif eq '' and (substr(remtrz.racc,4,3) <> "080") and not (remtrz.rcvinfo[1] begins '/PSJ/')  then do.
            find first depaccnt where lookup(string(depaccnt.acc), v-ls) > 0 no-lock no-error.
            if not avail depaccnt and lookup(v-ls, s-cust-arp) = 0 and v-ls <> s-toter-arp then do:
                if v-bin then do:
                    if remtrz.valdt1 ge v-bin_rnn_dt then v-m2 = v-bnkbin.
                    else v-m2 = trim(cmp.addr[2]).
                end.
                else v-m2 = trim(cmp.addr[2]).
            end.
        end.
    end.
    /*-----------------------------------------------------------------------------------------------*/
end.

v-bm2 = ''.
if remtrz.ptype eq '6' then v-bm2 = trim(cmp.name) + ' ' + trim(cmp.addr[1]).
else do.
   do i = 1 to 4:
      v-bbbb = trim( remtrz.ordins[i] ).
      v-bm2 = v-bm2 + if length( v-bbbb ) = 35 then v-bbbb else v-bbbb + ' '.
   end.
end.

run stl( v-bm2, 1, 55, ' ', output v-bm1, output i ).
run stl( v-bm2, i, 55, ' ', output v-bm2, output i ).

v-bbbb = v-bm1.

/* v-kbm  = if remtrz.sbank begins 'TXB' then ourbcode else remtrz.sbank. */
/*
v-kbm = if remtrz.sbank = "TXB00" then "190501914"
        else if remtrz.sbank = "TXB01" then "195301973"
        else if remtrz.sbank = "TXB02" then "194901964"
        else remtrz.sbank.
*/

/* sasco - поиск МФО */
find first txb where txb.visible and txb.bank = remtrz.sbank and txb.city = txb.txb no-lock no-error.
if available txb then v-kbm = txb.mfo.
                 else v-kbm = remtrz.sbank.

v-km   = trim( if remtrz.sacc <> '' then remtrz.sacc else remtrz.dracc ).
v-km1  = v-km.
if index( v-km1, '/' ) <> 0 then do:
   v-km  = entry( 1,v-km, '/' ).
   v-km1 = entry( 2,v-km1,'/' ).
end.
else do:
   if index( v-km1,' ' ) <> 0 then do:
      v-km  = entry( 1,v-km, ' ' ).
      v-km1 = entry( 2,v-km1,' ' ).
   end.
   else do:
      if length( v-km1 ) > 20 then do:
         v-km1 = substr( v-km1,21,20 ).
         v-km  = substr( v-km,  1,20 ).
      end.
      else v-km1 = ' '.
   end.
end.

if v-val then do:
    v-tmp   = (remtrz.bn[1]) + (remtrz.bn[2]) + (remtrz.bn[3]).
    v-s1 = trim(substring( v-tmp, 001, 80 )).
    v-s2 = trim(substring( v-tmp, 081, 80 )).
end.
else do:
    v-s1 = "".
    do i = 1 to 3:
        v-bbbb = ( remtrz.bn[i] ).
        v-s1   = v-s1 + if length(v-bbbb) = 60 then v-bbbb else v-bbbb + " ".
    end.

    v-bbbb = v-s1.

    v-s1 = GetNameBenOrd(v-bbbb).
    v-s2 = GetRnnBenOrd(v-bbbb).

    /*i = r-index( v-bbbb, "/RNN/" ).
    if i <> 0 then do:
        v-s1 = trim( substring( v-bbbb, 1, i - 1 )).
        v-s2 = trim( substring( v-bbbb, i + 5, 12 )).
    end.
    else do:
        v-bbbb = "".
        do i = 1 to 3:
            v-bbbb = v-bbbb + (remtrz.bn[i]).
        end.
        i = r-index(v-bbbb, "/RNN/").
        if i <> 0 then do:
            v-s1 = trim(substring(v-bbbb, 1, i - 1)).
            v-s2 = trim(substring(v-bbbb, i + 5, 12)).
        end.
    end.
    message "v-s1=" v-s1 "v-s2=" v-s2 view-as alert-box.*/
end.

/* v-kbs = if remtrz.rbank begins 'TXB' then ourbcode else remtrz.rbank. */
/*
v-kbs = if remtrz.rbank = "TXB00" then "190501914"
else if remtrz.rbank = "TXB01" then "195301973"
else if remtrz.rbank = "TXB02" then "194901964"
else remtrz.rbank.
*/
/* sasco - поиск МФО */
find first txb where txb.visible and txb.bank = remtrz.rbank no-lock no-error.
if available txb then v-kbs = txb.mfo.
                 else v-kbs = remtrz.rbank.

v-bs2 = ''.
do i = 1 to 3:
   v-bbbb = trim( remtrz.bb[i] ).
   v-bbbb = if substring( v-bbbb, 1, 1 ) = '/' then substring(
   v-bbbb, 2 ) else v-bbbb.
   v-bs2  = v-bs2 + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + ' '.
end.

run stl( v-bs2, 1, 55, ' ', output v-bs1, output i ).
run stl( v-bs2, i, 55, ' ', output v-bs2, output i ).

if substr(remtrz.ba,1,1) = '/' then v-ks = trim(substr(remtrz.ba,2)).
else v-ks = trim(remtrz.ba).

v-ks1 = v-ks.
if index(v-ks1,'/') <> 0 then do:
    v-ks  = substring(v-ks,1,index(v-ks,'/') - 1).
    v-ks1 = substring(v-ks1,index(v-ks1,'/') + 1).
end.
else do:
   if index(v-ks1,' ') <> 0 then do:
      v-ks  = substring(v-ks,1,index(v-ks,' ') - 1).
      v-ks1 = substring(v-ks1,index(v-ks1,' ') + 1).
   end.
   else do:
      if length(v-ks1) > 20 then do:
         v-ks1 = substr(v-ks,21,20).
         v-ks  = substr(v-ks, 1,20).
      end.
      else v-ks1 = ' '.
   end.
end.

   run Sm-vrd( input truncate( v-su,0 ), output v-strtmp ).
   if remtrz.tcrc <> 1 then
      v-strtmp = v-strtmp + ' ' + crc.code + ' ' +
                 string(( v-su - truncate( v-su,0 )) * 100, '99' ) + '.'.
   else
      v-strtmp = v-strtmp + ' тенге '  +
                 string(( v-su - truncate( v-su,0 )) * 100, '99' ) + ' тиын'.
   v-sumt[1] = ''.
   run stl( v-strtmp, 1, 86, ' ', output v-sumt[1], output i ).
   run stl( v-strtmp, i, 86, ' ', output v-sumt[2], output i ).

   /* приоткроем литцо... */
   output stream m-out to rpt.img.
   run stampdatp( output vdatu ).
   put stream m-out
   string( today, '99/99/9999' ) format 'x(10)' ', '
   string( if remtrz.rtim <> 0 then remtrz.rtim else time, 'HH:MM:SS' ) ', '
   cmp.name format "x(90)" skip(1).

   /* ЕКНПуемся... */
   find first sub-cod where
   sub-cod.d-cod = 'eknp' and
   sub-cod.ccode = 'eknp' and
   sub-cod.sub   = 'rmz'  and
   sub-cod.acc   = remtrz.remtrz
   no-lock no-error.
   if avail sub-cod then do:
      v-plars = substring( sub-cod.rcode, 01, 02 ).
      v-polrs = substring( sub-cod.rcode, 04, 02 ).
      v-knp   = substring( sub-cod.rcode, 07, 03 ).
      find first codfr where
      codfr.codfr = 'spnpl' and
      codfr.code  = v-knp no-lock no-error.
      v-knps = if available codfr
      then codfr.name[1] + codfr.name[2] + codfr.name[3]
      else ''.
   end.

    if remtrz.tcrc <> 1 then do:
        if v-cif <> '' then do:
            find first sub-cod where sub-cod.d-cod = 'clnsts' and sub-cod.ccode = '0' and sub-cod.sub   = 'cln' and
            sub-cod.acc   = string( cif.cif ) no-lock no-error.
            if avail sub-cod then if v-new then run prtppvnew. else run prtppv.
            else if v-new then run prtppvnew. else run prtppvf.
        end.
        else if v-new then run prtppvnew. else run prtppv.
    end.
    else do:
        pause 0 before-hide.
        if v-noord = no then run prtppt.
        else do:
            run prtppt.
            run printnewform. /*Платежное-поручение WORD*/
        end.
    end.

    put stream m-out skip(1).
    if index(remtrz.rcvinfo[1],"/PSJINK/") <> 0 then do:
        output stream m-out close.
        run print_PNJINK.
    end.
    else do:
        if remtrz.source = 'IBH' then do:
            output stream m-out close.
            pause 0 before-hide.
            run print_PNJ.
        end.
        else do:
            find first ofc where ofc.ofc = userid('bank') no-lock no-error.
            if avail(ofc) and ofc.mday[2] = 1 then put stream m-out skip(14).
            else put stream m-out skip(1).
            output stream m-out close.
            pause 0 before-hide.
        end.
    end.

    {html-end.i "stream v-out"}
    {html-end.i "stream rep2"}
    {html-end.i "stream rep4"}
    output stream v-out close.
    output stream rep2  close.
    output stream rep4  close.

   if v-noord = no then run menu-prt('rpt.img').
   else run menu-prt2('rpt.img',"").

   pause 0 no-message.
   pause before-hide.


return.


/*
    17.04.2000
    prtppt.p
    Печать платежек: тенге...
    Пропер С.В.
*/
procedure prtppt.
    /*
    v-plars = del_city(v-plars ).
    v-m2    = del_city(v-m2    ).
    v-m1    = del_city(v-m1    ).
    v-km1   = del_city(v-km1   ).
    v-bm1   = del_city(v-bm1   ).
    v-kbm   = del_city(v-kbm   ).
    v-km    = del_city(v-km    ).
    v-polrs = del_city(v-polrs ).
    v-s2    = del_city(v-s2    ).
    v-s1    = del_city(v-s1    ).
    v-sm    = del_city(v-sm    ).
    v-ks1   = del_city(v-ks1   ).
    v-bs1   = del_city(v-bs1   ).
    v-kbs   = del_city(v-kbs   ).
    v-ks    = del_city(v-ks    ).

    v-plars  = replace_bnamebik(v-plars , date(v-mudate)).
    v-m2     = replace_bnamebik(v-m2    , date(v-mudate)).
    v-m1     = replace_bnamebik(v-m1    , date(v-mudate)).
    v-km1    = replace_bnamebik(v-km1   , date(v-mudate)).
    v-bm1    = replace_bnamebik(v-bm1   , date(v-mudate)).
    v-kbm    = replace_bnamebik(v-kbm   , date(v-mudate)).
    v-km     = replace_bnamebik(v-km    , date(v-mudate)).
    v-polrs  = replace_bnamebik(v-polrs , date(v-mudate)).
    v-s2     = replace_bnamebik(v-s2    , date(v-mudate)).
    v-s1     = replace_bnamebik(v-s1    , date(v-mudate)).
    v-sm     = replace_bnamebik(v-sm    , date(v-mudate)).
    v-ks1    = replace_bnamebik(v-ks1   , date(v-mudate)).
    v-bs1    = replace_bnamebik(v-bs1   , date(v-mudate)).
    v-kbs    = replace_bnamebik(v-kbs   , date(v-mudate)).
    v-ks     = replace_bnamebik(v-ks    , date(v-mudate)).
    */


   put stream m-out
   'ПЛАТЕЖНОЕ ПОРУЧЕНИЕ No ' at 34 v-numurs skip
   '------' at 16   'Дата: ' at 46 v-mudate skip

   'Плательщик:    | ' v-plars ' | ' skip
   '---------------------' skip
   '| ' v-m2    ' | ' v-m1 format 'x(57)' 'Дебет' at 76 'Сумма' at 96 skip
   fill( '-', 107 ) format 'x(107)' skip
   'Банк плательщика:'  '|' at 67  '|' at 88 '|' at 107 skip
   ''    format 'x(55)' '-----------|         ' v-km1 format 'x(9)'
   '|' at 88 '|' at 107 skip
   v-bm1 format 'x(55)' '| ' v-kbm '|' v-km  format 'x(20)'  '|' at 88 '|' at 107 skip
   fill( '-', 87 ) format 'x(87)' '|' at 88 '|' at 107 skip

   'Получатель:    | ' v-polrs ' | ' '|' at 88 '|' at 107 skip
   '---------------------' '|' at 88 crc.code at 103 ' |' skip
   '| '       v-s2 format 'x(12)'
   '| ' at 16 v-s1 format 'x(57)' 'Кредит' at 75 '|' at 88
   v-sm format 'x(17)' '|' at 107 skip
   fill( '-', 87 ) format 'x(87)' '|------------------|' at 88 skip

   'Банк получателя:'  '|' at 67   '|' at 88 '|' at 107 skip
   ''    format 'x(55)' '-----------|         ' v-ks1 format 'x(9)'
   '|' at 88 '|' at 107 skip
   v-bs1 format 'x(55)' '| ' v-kbs '|' v-ks  format 'x(20)'  '|' at 88 '|' at 107 skip
   fill( '-', 87 ) format 'x(87)' '|------------------|' at 88 skip.



   /* для пенсионных платежей - банк посредник */
   def var med-bik as char init ''.
   def var med-acc as char init ''.
   def var med-bn as char init ''.

   if remtrz.rcvinfo[1] begins '/PSJ/' then
   do:
      if remtrz.intmed <> '' and (not (remtrz.intmed matches '*-*'))
      and length(trim(remtrz.intmed)) = 9 then med-bik = trim(remtrz.intmed).

      if remtrz.intmedact <> '' and (not (remtrz.intmedact matches '*-*'))
      and length(trim(remtrz.intmedact)) = 9 then med-acc = trim(remtrz.intmedact).

      find first bankl where bankl.bank = med-bik no-lock no-error.
      if avail bankl then med-bn = bankl.name.

      if med-acc <> "" then med-acc = '| Счет No ' + med-acc.
                       else med-acc = '|         '.

      put stream m-out
      "Банк-посредник: "  "|" at 67 '|' at 88 '|' at 107 skip

      ''    format 'x(55)' "-----------|         "  '' /*v-ks1*/ format 'x(9)'
      '|' at 88 '|' at 107 skip

      substring(med-bn,1,55) format 'x(55)' "| " med-bik format 'x(9)'
      med-acc format 'x(20)' '|' at 88 '|' at 107 skip
      fill( '-', 87 ) format 'x(87)' '|------------------|' at 88 skip.
   end.
   /* конец банка-посредника */


   put stream m-out
   'Сумма прописью:'              '| В.о.|            |' at 88 skip
   v-sumt[1]       format 'x(87)' '|-----|------------|' at 88 skip
   v-sumt[2]       format 'x(87)' '| Н.п.| '
   v-ks1           format 'x(10)'                    '|' at 107 skip
   fill( '-', 87 ) format 'x(87)' '|-----|------------|' at 88 skip
   'Назначение платежа, наименование товара, выполненных работ, '
   'оказанных услуг:'             '| С.п.|            |' at 88 skip.
/*
   put stream m-out
   trim( remtrz.detpay[1] ) + trim( remtrz.detpay[2] )
		   format 'x(70)' '|-----|------------|' at 88 skip
   trim( remtrz.detpay[3] ) + trim( remtrz.detpay[4] )
                   format 'x(70)' '| О.п.|            |' at 88 skip.
*/

    find first budcodes where budcodes.code = int(v-ks1) no-lock no-error.
    if avail budcodes then
    v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]) + ' ' + budcodes.name.
    else
    v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]). /*u00121 30/11/2004*/

    find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
    if avail netbank then do:
    v-detch = replace(v-detch, "\n", " ").
    v-detch = replace(v-detch, "\r", "").

    end.
    if  remtrz.racc = "011999832"  and remtrz.rbank = "TXB00" then do:

    v-detch = "Оплата за телефон " + remtrz.detpay[1]  +  " от " + string(remtrz.valdt1) +
    ". Сумма " + string(remtrz.amt)  + " в т.ч. НДС " + string(remtrz.amt * 0.15).

    end.

	DO WHILE v-detch <> '':
        put stream m-out  substr(v-detch,1,70) format 'x(70)' '|     |            |'  at 88 skip.
		v-detch = substr(v-detch,71).

	end.


   put stream m-out
   'Код назначения платежа: '
   v-knp  format 'x(03)'          '|-----|------------|' at 88 skip
   v-knps format 'x(87)'          '| N.б.|            |' at 88 skip
   fill( '-', 87 ) format 'x(87)' '|-----|------------|' at 88 skip
   'Информация банку:'            '| Тип | '             at 88
   if que.pri > 19999 then 'нормальный' else
   if que.pri > 9999 then 'средний' else
   'срочный' format 'x(10)' '|' at 107 skip
/* 'Кодовая фраза:' */
   v-code format 'x(35)'          '|-----|------------|' at 88 skip
   'Дата валютирования: ' v-mudate2
                                  '| Ком.| '             at 88
   if remtrz.bi = 'BEN' then 'получатель' else
   'плательщик' format 'x(10)' '|' at 107
   skip.

   put stream m-out fill('-',107) format 'x(107)' skip
   'М.П.'              at 12
   if v-chief <> '' then 'Подпись клиента'
                    else 'Руководитель   ' format 'x(15)'  at 32
   'Подпись банка'     at 77 skip(1)
   v-chief             at 32
   ofc.name            at 77 skip(1)
   today at 77
   .

return.
end.

procedure printnewform:
    find first budcodes where budcodes.code = int(v-ks1) no-lock no-error.
    if avail budcodes then v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]) + ' ' + budcodes.name.
    else v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]). /*u00121 30/11/2004*/
    find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
    if avail netbank then do:
        v-detch = replace(v-detch, "\n", " ").
        v-detch = replace(v-detch, "\r", "").
    end.
    if remtrz.racc = "011999832"  and remtrz.rbank = "TXB00" then do:
        v-detch = "Оплата за телефон " + remtrz.detpay[1]  +  " от " + string(remtrz.valdt1) +
        ". Сумма " + string(remtrz.amt)  + " в т.ч. НДС " + string(remtrz.amt * 0.15).
    end.

    if remtrz.dracc <> "" then do:
        find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
        if avail aaa then do:
            find first cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then do:
                find first sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnchfd1" and sub-cod.acc = cif.cif and sub-cod.ccode <> "msc" no-lock no-error.
                if avail sub-cod then glbuhgalter = sub-cod.rcode.
            end.
        end.
    end.
    {printplat2.i} /*Новый формат платежного поручения*/
    s-Print_1 = true.
end.


/*
    17.04.2000
    prtppv.p
    Печать платежек: валюта, юрлица...
    Пропер С.В.
*/
procedure prtppv.
   v-acc = "/" + remtrz.sacc.
   v-acc1 = "/" + remtrz.ba.
   if avail cif then v-num = num-entries(cif.addr[1]).
   if v-num < 7 then do:
        if avail cif then v-addr = cif.addr[1].
        v-addr1 = "".
   end.
   else do:
        if avail cif then do:
            v-addr = entry(4,cif.addr[1],",") + " " + entry(5,cif.addr[1],",") + " " + entry(6,cif.addr[1],",") + " " + entry(7,cif.addr[1],",").
            v-addr1 = entry(3,cif.addr[1],",") + " " + entry(1,cif.addr[1],",").
        end.
   end.
   if v-cif = '' then v-addr = cmp.addr[1].

   if remtrz.intmed = ? or remtrz.intmed = "" then v-56chk = "".
   else do:
        v-56chk = entry(1,remtrz.intmed," ").
        v-num56 = num-entries(remtrz.intmed," ").
        if v-num56 > 1 then v-56chk2 = entry(2,remtrz.intmed," ").
        if v-num56 > 2 then do:
            do k = 3 to v-num56:
                if v-56chk3 = " " then v-56chk3 = entry(k,remtrz.intmed," ").
                else v-56chk3 = v-56chk3 + " "  + entry(k,remtrz.intmed," ").
            end.
        end.
   end.
    if remtrz.source = 'IBH'  then do:
       v-mudate = replace(v-mudate, "Интернет - Банкинг", "         Internet Banking").
    end.
   run savelog("prtppp", "977. " + s-remtrz).
   put stream m-out
   'ЗАЯВЛЕНИЕ НА ПЕРЕВОД No ' at 05 v-numurs skip
   'Дата: ' at 05 v-mudate
   skip(1)

   '    Код валюты: ' crc.code skip

   '32: Сумма и валюта (цифрами и прописью): '
   v-sm        format 'x(17)' ' ' crc.code skip
   v-sumt[1]   format 'x(87)'  at 05 skip
   v-sumt[2]   format 'x(87)'  at 05
   skip(1)

   '50: Наименование отправителя (ИИН/БИН, адрес, телефон):' skip
   v-acc       format 'x(103)' at 05 skip
   v-m1        format 'x(103)' at 05 skip
   v-m2        format 'x(103)' at 05 skip
   v-addr      format 'x(103)'at 05 skip
   v-addr1     format 'x(103)'at 05 skip
   /*if v-cif <> '' then cif.addr[1]
                  else cmp.addr[1] format 'x(103)'at 05 skip
   if v-cif <> '' then cif.tel
                  else cmp.addr[3] format 'x(103)' at 05 skip(1)*/

   '    КОд отправителя денег: ' v-plars
   skip(1).
   if v-56chk <> "" then
        put stream m-out
        '56: Наименование банка-корреспондента: ' skip
        /*remtrz.intmed*/ v-56chk + " " + v-56chk2 format 'x(103)' at 05 skip.
        if v-56chk3 <> "" then  put stream m-out v-56chk3 format 'x(103)' at 05 skip.
        if v-56[1] + v-56[2] <> "" then
        put stream m-out v-56[1] + v-56[2] format 'x(103)' at 05 skip.
        if v-56[3] + v-56[4] <> "" then
        put stream m-out v-56[3] + v-56[4] format 'x(103)' at 05 skip(1).
        else  put stream m-out skip(1).

   put stream m-out
   '57: Номер счета и наименование банка-получателя в банке-корреспонденте: '.

   /*if entry(5,remtrz.bb[1]," ") <> " " then
   v57 = entry(3,remtrz.bb[1]," ") + " " + entry(4,remtrz.bb[1]," ") + " " + entry(5,remtrz.bb[1]," ").
   else v57 = entry(3,remtrz.bb[1]," ") + " " + entry(4,remtrz.bb[1]," ").*/

   v57 = trim(substr(remtrz.bb[1],(length(entry(1,remtrz.bb[1]," ") + entry(2,remtrz.bb[1]," "))) + 2) + remtrz.bb[2]).


   /*if remtrz.fcrc = 4 then v57 = entry(4,remtrz.bb[1]," ") + " " + entry(5,remtrz.bb[1]," ").*/

   /*v-57[1] format 'x(103)' at 05 skip
   v-57[2] format 'x(103)' at 05 skip
   v-57[3] format 'x(103)' at 05 skip
   v-57[4] format 'x(103)' at 05 skip
   v-57[5] format 'x(103)' at 05 skip*/
   if remtrz.fcrc <> 4 then
   put stream m-out entry(1,remtrz.bb[1]," ") + " " + entry(2,remtrz.bb[1]," ") format 'x(103)' at 05 skip
   v57 format 'x(103)' at 05 skip(1).

   if remtrz.fcrc = 4 then
   put stream m-out entry(1,remtrz.bb[1]," ") + entry(2,remtrz.bb[1]," ") + "." + entry(3,remtrz.bb[1]," ") format 'x(103)' at 05 skip
   v57 format 'x(103)' at 05 skip(1).

   put stream m-out
   '59: Номер счета получателя в банке получателя: ' skip
   v-acc1 format 'x(60)' at 05 skip
   '    Наименование получателя:' skip.
   if v-s1 <> "" then put stream m-out
   entry(1,v-s1,"/RNN/") format 'x(103)' at 05 skip.
   /*v-s2        format 'x(103)' at 05
   skip*/
   put stream m-out '    КБе:' v-polrs
   skip(1)

   '70: Детали платежа:'.
    /*
       remtrz.detpay[1]      at 05 skip
       remtrz.detpay[2]      at 05 skip
       remtrz.detpay[3]      at 05 skip
       remtrz.detpay[4]      at 05 skip
    */
	v-detch = remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4]. /*u00121 30/11/2004*/
	DO WHILE v-detch <> '':
		put stream m-out  substr(v-detch,1,70) format 'x(70)' at 05 skip.
		v-detch = substr(v-detch,71).
	end.

   put stream m-out  /*u00121 30/11/2004*/
   v-code format 'x(35)' at 05
   skip(1)

   '    Код назначения платежа: ' v-knp
   skip

   '71: Оплату за услуги зарубежных банков снимите с: <'
    /*
       if remtrz.bi = 'BEN' then 'получателя>' else 'плательщика>' format 'x(12)'
    */
   (if available swbody then (if swbody.content[1] = 'BEN' then 'получателя>' else 'плательщика>') else
     if remtrz.bi = 'BEN' then 'получателя>' else 'плательщика>') format 'x(12)'
   skip
   '    Оплату за услуги снимите со счета No ' remtrz.svcaaa format "x(20)" skip(1)
   '    Информация банку: ' skip
   '    Срочность платежа: <'
   if que.pri > 19999 then 'нормальный' else
   if que.pri > 9999 then 'ускоренный' else
   'срочный' format 'x(10)' '>'
   skip(1)

   '72: ' remtrz.rcvinfo[1] at 05
   remtrz.rcvinfo[2] at 05
   if trim (remtrz.rcvinfo[3]) <> "" then remtrz.rcvinfo[3] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[4]) <> "" then remtrz.rcvinfo[4] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[5]) <> "" then remtrz.rcvinfo[5] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[6]) <> "" then remtrz.rcvinfo[6] + chr(10) else '' format 'x(70)' at 05
   skip(1).


   /*tsoy */
   /* Если физ лицо  */
   find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
   if avail aaa then do:
      find first cif where cif.cif = aaa.cif and cif.type = "p" no-lock no-error.
          if avail cif then do:


                    put stream m-out "  Подтверждаю, что данный перевод не связан с предпринимательской деятельностью," skip
                    "  осуществлением мною валютных операций, требующих получения лицензии, " skip
                    "  регистрационного свидетельства, свидетельства об уведомлении, " skip
                    "  оформления паспорта сделки " skip

                    "  Herewith I testify that this payment does not caused by any kind of business or " skip
                    "  foreign currency operations requiring license, certificate of registration, " skip
                    "  certificate of notification, registration of the passport deal. " skip.



    /*
     старая запись
                    put stream m-out "  Подтверждаю, что данный платеж не связан с предпринимательской деятельностью," skip
                    "  осуществлением инвестиций, приобретением прав на недвижимость или иными " skip
                    "  опреациям, связанные с движением капитала, а также оплатой конрактов между " skip
                    "  юридическими лицами в качестве третьего лица." skip

                    "  Hereby I confirm that this transfer is not connected with any commercial or " skip
                    "  investment activities, ecqusition of property rights or any other operations, " skip
                    "  connected with capital flow and neither with the contractual payments performed by " skip
                    "  the third party behaly of the legal entities " skip.
    */

                    find first sub-cod where sub-cod.sub       = 'rmz'
                                             and sub-cod.acc   = remtrz.remtrz
                                             and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.

                    if avail sub-cod then do:
                                     find first sub-cod where sub-cod.sub       = 'rmz'
                                                              and sub-cod.acc   = remtrz.remtrz
                                                              and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                                     if avail sub-cod then do:
                                        if sub-cod.ccod = "1" then


                                        put stream m-out skip (1)  "  Я, согласен с предоставлением информации о данном переводе денег в " skip
                                                                   "  правоохранительные органы и Национальный Банк по их требованию. " skip
                                                                   "  I agree that the information on this payment may be released " skip
                                                                   "  to the Authorities and National bank at their request " skip.


    /*                                      put stream m-out skip (1)  "  Я разрешаю предоставить информацию обо мне и о проведенном платеже " skip
                                                                   "  в правоохранительные огрганы и в Национальный Банк по их требованию." skip
                                                                   "  I, hereby, permit the disclosure of my personal information and information on the " skip
                                                                   "  payment I made to the law-enforcement authorities and to the National Bank of the " skip
                                                                   "  Republic of Kazakhstan upon request of such. " skip. */





                                     end.
                    end.
           end.
    end.
   /*tsoy*/


   put stream m-out skip(1)
   '    Подпись клиента: ' v-chief  at 30 skip
   '    Подпись банка:   ' ofc.name at 30 skip.

   /*** KOVAL begin exchange controls ***/
   if trim(remtrz.info[7]) <> '' then
   put stream m-out "    Валютный контроль:   " + remtrz.info[7] format 'x(103)' skip.
   /*** KOVAL end exchange controls ***/

    return.
end.
/*
    17.04.2000
    prtppvf.p
    Печать платежек: валюта, физлица...
    Пропер С.В.
*/
procedure prtppvf.
   run savelog("prtppp", "1179. " + s-remtrz).

   if avail cif then v-num = num-entries(cif.addr[1]).
   if v-num < 7 then do:
        if avail cif then v-addr = cif.addr[1].
        v-addr1 = "".
   end.
   else do:
        if avail cif then do:
            v-addr = entry(6,cif.addr[1],",") + " " + entry(5,cif.addr[1],",") + " " + entry(4,cif.addr[1],",").
            v-addr1 = entry(3,cif.addr[1],",") + " " + entry(1,cif.addr[1],",").
        end.
   end.
   put stream m-out
   'ЗАЯВЛЕНИЕ НА ПЕРЕВОД No ' at 05 v-numurs skip
   'Дата: ' at 05 v-mudate
   skip(1)

   '    Код валюты: ' crc.code skip

   '32: Сумма и валюта (цифрами и прописью): '
   v-sm        format 'x(17)' ' ' crc.code skip
   v-sumt[1]   format 'x(87)'  at 05 skip
   v-sumt[2]   format 'x(87)'  at 05
   skip(1)

   '50: ФИО, адрес, телефон: '       skip
   v-m1        format 'x(103)' at 05 skip
   v-addr /*cif.addr[1]*/ format 'x(103)' at 05 skip
   v-addr1  format 'x(103)' at 05
   /*cif.tel     format 'x(103)' at 05*/
   skip(1)

   '    Документ удостоверяющий личность (номер, серия, кем и когда выдан):'
   skip
   cif.pss     format 'x(103)' at 05
   skip(1)

   '    ИИН/БИН:' skip
   v-m2        format 'x(103)' at 05
   skip(1)

   '    КОд отправителя денег: ' v-plars
      skip(1)

   '56: Наименование банка-корреспондента: ' skip
   remtrz.intmed format "x(60)" skip
   v-56[1] + v-56[2] format 'x(103)' at 05 skip
   v-56[3] + v-56[4] format 'x(103)' at 05
   skip(1)

   '57: Номер счета и наименование банка-получателя в банке-корреспонденте: '
   v-57[1] format 'x(103)' at 05 skip
   v-57[2] format 'x(103)' at 05 skip
   v-57[3] format 'x(103)' at 05 skip
   v-57[4] format 'x(103)' at 05 skip
   v-57[5] format 'x(103)' at 05 skip

   '59: Номер счета получателя в банке получателя: '
   remtrz.ba format 'x(60)' skip
   '    Наименование получателя:' skip
   v-s1        format 'x(103)' at 05
   v-s2        format 'x(103)' at 05
   skip(1)

   '    КБе:' v-polrs
   skip(1)

   '70: Детали платежа:'.
    /*
       remtrz.detpay[1] at 05 skip
       remtrz.detpay[2] at 05 skip
       remtrz.detpay[3] at 05 skip
       remtrz.detpay[4] at 05
    */
	v-detch = remtrz.det[1] + remtrz.det[2] + remtrz.det[3] + remtrz.det[4]. /*u00121 30/11/2004*/
	DO WHILE v-detch <> '':
		put stream m-out  substr(v-detch,1,70) format 'x(70)' at 05 skip.
		v-detch = substr(v-detch,71).
	end.

   put stream m-out
   v-code format 'x(35)'
   skip(1)

   '    Код назначения платежа: ' v-knp
   skip
   '71: Оплату за услуги зарубежных банков снимите с: <'
    /*
       if remtrz.bi = 'BEN' then 'получателя>' else 'плательщика>' format 'x(12)'
    */
   (if available swbody then (if swbody.content[1] = 'BEN' then 'получателя>' else 'плательщика>') else
     if remtrz.bi = 'BEN' then 'получателя>' else 'плательщика>') format 'x(12)'
   skip
   '    Оплату за услуги снимите со счета No ' remtrz.svcaaa skip(1)
   '    Информация банку: ' skip
   '    Срочность платежа: <'
   if que.pri > 19999 then 'нормальный' else
   if que.pri > 9999 then 'ускоренный' else
   'срочный' format 'x(10)' '>'
   skip(1)

   '72: ' remtrz.rcvinfo[1] at 05 skip
   remtrz.rcvinfo[2] at 05 skip
   if trim (remtrz.rcvinfo[3]) <> "" then remtrz.rcvinfo[3] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[4]) <> "" then remtrz.rcvinfo[4] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[5]) <> "" then remtrz.rcvinfo[5] + chr(10) else '' format 'x(70)' at 05
   if trim (remtrz.rcvinfo[6]) <> "" then remtrz.rcvinfo[6] + chr(10) else '' format 'x(70)' at 05
   skip(1).


   /*tsoy */
   /* Если физ лицо  */
   find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
   if avail aaa then do:
      find first cif where cif.cif = aaa.cif and cif.type = "p" no-lock no-error.
          if avail cif then do:

                    put stream m-out "  Подтверждаю, что данный платеж не связан с предпринимательской деятельностью," skip
                    "  осуществлением инвестиций, приобретением прав на недвижимость или иными " skip
                    "  опреациям, связанные с движением капитала, а также оплатой конрактов между " skip
                    "  юридическими лицами в качестве третьего лица." skip

                    "  Hereby I confirm that this transfer is not connected with any commercial or " skip
                    "  investment activities, ecqusition of property rights or any other operations, " skip
                    "  connected with capital flow and neither with the contractual payments performed by " skip
                    "  the third party behaly of the legal entities " skip.

                    find first sub-cod where sub-cod.sub       = 'rmz'
                                             and sub-cod.acc   = remtrz.remtrz
                                             and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.

                    if avail sub-cod then do:
                                     find first sub-cod where sub-cod.sub       = 'rmz'
                                                              and sub-cod.acc   = remtrz.remtrz
                                                              and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                                     if avail sub-cod then do:
                                        if sub-cod.ccod = "1" then
                                        put stream m-out skip (1)  "  Я разрешаю предоставить информацию обо мне и о проведенном платеже " skip
                                                                   "  в правоохранительные огрганы и в Национальный Банк по их требованию." skip
                                                                   "  I, hereby, permit the disclosure of my personal information and information on the " skip
                                                                   "  payment I made to the law-enforcement authorities and to the National Bank of the " skip
                                                                   "  Republic of Kazakhstan upon request of such. " skip.





                                     end.
                    end.
           end.
    end.
   /*tsoy*/


   put stream m-out skip(1)
   '    Подпись клиента: ' v-chief  at 30 skip
   '    Подпись банка:   ' ofc.name at 30 skip.

   /*** KOVAL begin exchange controls ***/
   if trim(remtrz.info[7]) <> '' then
   put stream m-out "    Валютный контроль:   " + remtrz.info[7] format 'x(103)' skip.
   /*** KOVAL end exchange controls ***/

    return.
end.
/***/


/*** KOVAL печать новых Swift - платежек ***/
procedure prtppvnew.
    run savelog("prtppp", "1348. " + s-remtrz).
    if remtrz.source = 'IBH'  then do:
       v-mudate = replace(v-mudate, "Интернет - Банкинг", "         Internet Banking").
    end.

   put stream m-out
   'ЗАЯВЛЕНИЕ НА ПЕРЕВОД No ' at 05 v-numurs skip
   'Дата: ' at 05 v-mudate
   skip(1)

   '    Код валюты: ' crc.code skip(1).

   put stream m-out
   '20: Референс Отправителя: ' skip
   s-remtrz  at 05 skip(1)
   '23B: Код банковской операции : ' skip
   "CRED" at 05 skip(1).
   put stream m-out
   '32A: Дата валютирования/Валюта/Сумма: '
   v-sm        format 'x(17)' ' ' crc.code skip
   v-sumt[1]   format 'x(87)'  at 05 skip
   v-sumt[2]   format 'x(87)'  at 05
   skip(1).


    find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '50' no-lock no-error.
    if avail swbody then do:
        put stream m-out unformatted '50' + swbody.type + ': Плательщик: ' skip.
        put stream m-out unformatted swbody.content[1] format "x(35)" at 5 skip.
        put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
    end.
   put stream m-out unformatted '    КОд отправителя денег: ' v-plars skip(1).

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '53' no-lock no-error.
   if avail swbody then do:
        put stream m-out '53N: Корреспондент Отправителя: ' skip.
        put stream m-out unformatted swbody.content[1] format "x(35)" at 5 skip.
        if swbody.content[2] <> "" then put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        if swbody.content[3] <> "" then put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        if swbody.content[4] <> "" then put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
   end.

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '56' no-lock no-error.
   if avail swbody then do:
        put stream m-out '56' + swbody.type + ': Банк-корреспондент: ' format "x(35)" skip.
        put stream m-out unformatted swbody.content[1] format "x(35)"  at 5 skip.
        if swbody.content[2] <> "" then put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        if swbody.content[3] <> "" then put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        if swbody.content[4] <> "" then put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
   end.
   put stream m-out unformatted skip(1).

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '57' no-lock no-error.
   if avail swbody then do:
        put stream m-out unformatted '57' + swbody.type + ': Банк Бенефициара: ' skip.
        put stream m-out unformatted swbody.content[1] format "x(35)" at 5 skip.
        if swbody.content[2] <> "" then put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        if swbody.content[3] <> "" then put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        if swbody.content[4] <> "" then put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
   end.
   put stream m-out unformatted skip(1).

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '59' no-lock no-error.
   if avail swbody then do:
        put stream m-out unformatted '59: Бенефициар: ' skip.
        put stream m-out unformatted swbody.content[1] format "x(35)" at 5 skip.
        if swbody.content[2] <> "" then put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        if swbody.content[3] <> "" then put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        if swbody.content[4] <> "" then put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
   end.
   put stream m-out unformatted '    КБе:' v-polrs skip(1).

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '70' no-lock no-error.
   if avail swbody then do:
        put stream m-out unformatted '70: Информация о платеже:' skip.
        put stream m-out unformatted swbody.content[1] format "x(35)" at 5 skip.
        if swbody.content[2] <> "" then put stream m-out unformatted swbody.content[2] format "x(35)" at 5 skip.
        if swbody.content[3] <> "" then put stream m-out unformatted swbody.content[3] format "x(35)" at 5 skip.
        if swbody.content[4] <> "" then put stream m-out unformatted swbody.content[4] format "x(35)" at 5 skip.
        if swbody.content[5] <> "" then put stream m-out unformatted swbody.content[5] format "x(35)" at 5 skip.
        if swbody.content[6] <> "" then put stream m-out unformatted swbody.content[6] format "x(35)" at 5 skip.
   end.

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '71' and swbody.type = 'A' no-lock no-error.

   put stream m-out  unformatted v-code '    Код назначения платежа: ' v-knp skip(1)

   '71A: Оплату за услуги зарубежных банков снимите с: <'
   (if available swbody then (if swbody.content[1] = 'BEN' then 'получателя>' else 'плательщика>') else
     if remtrz.bi = 'BEN' then 'получателя>' else 'плательщика>') format 'x(12)'
   skip
   '    Оплату за услуги снимите со счета No ' remtrz.svcaaa skip(1)
   '    Информация банку: ' skip
   '    Срочность платежа: <'
   if que.pri > 19999 then 'нормальный' else
   if que.pri > 9999 then 'ускоренный' else
   'срочный' format 'x(10)' '>'
   skip(1).

   find first swbody where swbody.rmz = s-remtrz and swbody.swfield = '72' no-lock no-error.
   if avail swbody then do:
           put stream m-out unformatted '72:' + swbody.type + ' Номер счета и наименование банка-получателя в банке-корреспонденте: ' skip.

           repeat i=1 to 6:                     /* content[3-6] */
             if trim(swbody.content[i]) ne "" then put stream m-out unformatted swbody.content[i] format "x(35)" at 5 skip.
           end.
   end.
   /*tsoy */
   /* Если физ лицо  */
   find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
   if avail aaa then do:
      find first cif where cif.cif = aaa.cif and cif.type = "p" no-lock no-error.
          if avail cif then do:

                    put stream m-out skip (1)  "  Подтверждаю, что данный платеж не связан с предпринимательской деятельностью," skip
                    "  осуществлением инвестиций, приобретением прав на недвижимость или иными " skip
                    "  опреациям, связанные с движением капитала, а также оплатой конрактов между " skip
                    "  юридическими лицами в качестве третьего лица." skip

                    "  Hereby I confirm that this transfer is not connected with any commercial or " skip
                    "  investment activities, ecqusition of property rights or any other operations, " skip
                    "  connected with capital flow and neither with the contractual payments performed by " skip
                    "  the third party behaly of the legal entities " skip.

                    find first sub-cod where sub-cod.sub       = 'rmz'
                                             and sub-cod.acc   = remtrz.remtrz
                                             and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.

                    if avail sub-cod then do:
                                     find first sub-cod where sub-cod.sub       = 'rmz'
                                                              and sub-cod.acc   = remtrz.remtrz
                                                              and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                                     if avail sub-cod then do:
                                        if sub-cod.ccod = "1" then
                                        put stream m-out skip (1)  "  Я разрешаю предоставить информацию обо мне и о проведенном платеже " skip
                                                                   "  в правоохранительные огрганы и в Национальный Банк по их требованию." skip
                                                                   "  I, hereby, permit the disclosure of my personal information and information on the " skip
                                                                   "  payment I made to the law-enforcement authorities and to the National Bank of the " skip
                                                                   "  Republic of Kazakhstan upon request of such. " skip.





                                     end.
                    end.
           end.
    end.
   /*tsoy */

   put stream m-out unformatted skip(1)

   '    Подпись клиента: ' v-chief  at 30 skip
   '    Подпись банка:   ' ofc.name at 30 skip.

   /*** KOVAL begin exchange controls ***/
   if trim(remtrz.info[7]) <> '' then
   put stream m-out "    Валютный контроль:   " + remtrz.info[7] format 'x(103)' skip.
   /*** KOVAL end exchange controls ***/
   return.
end.


/* sasco : процедура печати реестра пенсионных отчислений */
procedure print_PNJ.
    def var v-pension as logi init false.
    def var v-salary as logi init false.
    define variable pf_file as char.
    define variable tempstr as char.

    find first sysc where sysc.sysc = "PSJIN" no-lock.
    if avail sysc then pf_file = trim(sysc.chval).
    else do:
        MESSAGE "Не настроен SYSC для каталога входящих пенсионных файлов.~nПараметр PSJIN отсутствует !"
        VIEW-AS ALERT-BOX QUESTION BUTTONS OK TITLE "Внимание".
        return.
    end.

    pf_file = pf_file + s-remtrz.
    input through value( ' test -f ' + pf_file + ' && echo yes ').
    repeat:
        import tempstr.
    end.
    input close.

    v-pension = false.
    v-salary = false.
    if tempstr = "yes" then do:
        output to value ('rpt.img') append.
        put unformatted skip(5).
        output close.

        if v-bin then do:
            if remtrz.rcvinfo[1] = "/PSJ/" and remtrz.source = 'IBH' and lookup(v-kbs,"GCVPKZ2A") = 0 then do:
                v-salary = true.
                unix silent value('zar2regbin ' + s-remtrz + ' ' + pf_file). /*Список отчислений по заработной плате*/
            end.
            else do:
                v-pension = true.
                unix silent value('swt2regbin ' + s-remtrz + ' ' + pf_file). /*Список пенсионных и социальных отчислений*/
            end.
        end.
        else do:
            if remtrz.rcvinfo[1] = "/PSJ/" and remtrz.source = 'IBH' and lookup(v-kbs,"GCVPKZ2A") = 0 then do:
                v-salary = true.
                unix silent value('zar2reg ' + s-remtrz + ' ' + pf_file).
            end.
            else do:
                v-pension = true.
                unix silent value('swt2reg ' + s-remtrz + ' ' + pf_file).
            end.
        end.

        find first ofc where ofc.ofc = userid('bank') no-lock no-error.

        unix silent value ("cat " + s-remtrz + ".txt >> " + 'rpt.img').

        /*------------------Новый формат WORD----------------------------------------------------------------------------------------*/
        output stream rep to value(v-outfile).
        {html-title.i &stream = "stream rep"}

        def var v-str as char.
        a = 0. b = 0.
        input from value(pf_file).
        repeat:
            v-str = "".
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*/NAME/*" then do:
                    a = a + 1.
                    if a = 1 then v-nameorganization = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                    if a = 2 then v-nameorgtiontwo   = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                end.
                if v-bin then do:
                    if v-str matches "*/IDN/*" then do:
                        b = b + 1.
                        if b = 1 then v-rnnorgone = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                        if b = 2 then v-rnnorgtwo = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                    end.
                end.
                else do:
                    if v-str matches "*/RNN/*" then do:
                        b = b + 1.
                        if b = 1 then v-rnnorgone = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                        if b = 2 then v-rnnorgtwo = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                    end.
                end.
                if v-str matches "*:52B:*" then do:
                    v-bicbnkone = trim(substr(v-str,r-index(v-str,":") + 1,length(v-str))).
                end.
                if v-str matches "*:57B:*" then do:
                    v-bicbnktwo = trim(substr(v-str,r-index(v-str,":") + 1,length(v-str))).
                end.
                if v-str matches "*:50:/D/*" then do:
                    v-accorgone = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                end.
                if v-str matches "*:59:*" then do:
                    v-accorgtwo = trim(substr(v-str,r-index(v-str,":") + 1,length(v-str))).
                end.
                if v-str matches "*/MAINBK/*" then do:
                    v-mainbk = trim(substr(v-str,r-index(v-str,"/") + 1,length(v-str))).
                end.
                leave.
            end.
        end.
        empty temp-table t-temp.

        /*Список отчислений по заработной плате*/
        if v-salary then do:
            input from value(s-remtrz + ".txt").
            repeat while not (v-str begins "Главный бухгалтер"):
                import unformatted v-str.
                v-str = trim(v-str).
                if v-bin then do:
                    if num-entries(v-str,"|") = 7 then do:
                        if v-str begins "N" or v-str begins "п/п" or v-str matches "*указывать,если изменялись*" or v-str = "" then next.
                        if length(trim(entry(1,v-str,"|"))) > 0 then do:
                            create t-temp.
                            t-temp.k = trim(entry(1,v-str,"|")).
                            t-temp.iik = trim(entry(2,v-str,"|")).
                            t-temp.fio = trim(entry(3,v-str,"|")).
                            t-temp.rnnbin = trim(entry(6,v-str,"|")).
                            t-temp.sum = trim(entry(7,v-str,"|")).
                        end.
                        else do:
                            find last t-temp no-error.
                            if avail t-temp then t-temp.fio = t-temp.fio + " " + trim(entry(3,v-str,"|")).
                        end.
                    end.
                end.
            end.
            v-file = "/data/export/saldoc.htm".
            input from value(v-file).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*numdoc*" then do:
                        v-str = replace(v-str,"numdoc",if avail remtrz then trim(substr(remtrz.sqn,19,8)) else '' ).
                        next.
                    end.
                    if v-str matches "*dtdoc*" then do:
                        v-str = replace(v-str,"dtdoc",if avail remtrz then string(remtrz.valdt1,'99/99/9999') else '' ).
                        next.
                    end.
                    if v-str matches "*naimenovanieotprav*" then do:
                        v-str = replace(v-str,"naimenovanieotprav",v-nameorganization).
                        next.
                    end.
                    if v-str matches "*iinotprav*" then do:
                        v-str = replace(v-str,"iinotprav",v-rnnorgone).
                        next.
                    end.
                    if v-str matches "*accfrom*" then do:
                        v-str = replace(v-str,"accfrom",v-accorgone).
                        next.
                    end.
                    if v-str matches "*naimenovaniepoluchat*" then do:
                        v-str = replace(v-str,"naimenovaniepoluchat",v-nameorgtiontwo).
                        next.
                    end.
                    if v-str matches "*iinpoluchat*" then do:
                        v-str = replace(v-str,"iinpoluchat",v-rnnorgtwo).
                        next.
                    end.
                    if v-str matches "*accto*" then do:
                        v-str = replace(v-str,"accto",v-accorgtwo).
                        next.
                    end.
                    leave.
                end.
                put stream rep unformatted v-str skip.
            end.
            input close.

            put stream rep unformatted
                "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

            put stream rep unformatted
                "<tr align=center style='font-size:10pt;font:bold;font-family:Calibri'>" skip
                "<td>№</td>" skip
                "<td>№ счета</td>" skip
                "<td>Фамилия Имя Отчество</td>" skip
                "<td>ИИН получателя</td>" skip
                "<td>Сумма</td>" skip
                "</tr>" skip.

            for each t-temp no-lock:
                put stream rep unformatted
                    "<tr align=center style='font-size:10pt;font-family:Calibri'>" skip
                    "<td>" string(t-temp.k) "</td>" skip
                    "<td>" t-temp.iik "</td>" skip
                    "<td>" t-temp.fio "</td>" skip
                    "<td>" t-temp.rnnbin "</td>" skip
                    "<td>" t-temp.sum "</td>" skip
                    "</tr>" skip.
            end.
            put stream rep unformatted
                "</TABLE>" skip.

            put stream rep unformatted
                "<TABLE rules=groups width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
            put stream rep unformatted
                "<tr><td colspan=5 height=""30""></tr>" skip
                "<tr><td colspan=5 height=""30""></tr>" skip
                "<tr><td colspan=5 height=""30""></tr>" skip.
            put stream rep unformatted
                "</TABLE>" skip.
            put stream rep unformatted
                "<TABLE rules=groups width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            put stream rep unformatted
                "<tr style='font-size:10pt;font-family:Calibri'>" skip
                "<td>М.П.</td>" skip
                "<td colspan=2>Подпись клиента</td>" skip
                "<td colspan=2>Подпись банка</td>" skip
                "</tr>" skip
                "<tr style='font-size:10pt;font-family:Calibri'>" skip
                "<td></td>" skip
                "<td colspan=2>Руководитель " trim(v-chief) "</td>" skip
                "<td colspan=2>" trim(ofc.name) "</td>" skip
                "</tr>" skip
                "<tr style='font-size:10pt;font-family:Calibri'>" skip
                "<td></td>" skip
                "<td colspan=2>Главный бухгалтер " trim(v-mainbk) "</td>" skip
                "<td colspan=2></td>" skip
                "</tr>" skip.

            put stream rep unformatted
                "</TABLE>" skip.

            {html-end.i "stream rep"}
            output stream rep close.

            input from value(v-outfile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream rep2 unformatted v-str skip.
            end.
            input close.
            s-Print_2 = true.
        end.
        /*Список пенсионных и социальных отчислений*/
        if v-pension then do:
            input from value(s-remtrz + ".txt").
            repeat while not (v-str begins "Главный бухгалтер"):
                import unformatted v-str.
                v-str = trim(v-str).
                if v-bin then do:
                    if num-entries(v-str,"|") = 6 then do:
                        if v-str begins "N" or v-str begins "п/п" or v-str matches "*указывать,если изменялись*" or v-str = "" then next.
                        create t-temp.
                        t-temp.k = trim(entry(1,v-str,"|")).
                        t-temp.fio = trim(entry(2,v-str,"|")).
                        t-temp.fioreg = trim(entry(3,v-str,"|")).
                        t-temp.birthday = trim(entry(4,v-str,"|")).
                        t-temp.rnnbin = trim(entry(5,v-str,"|")).
                        t-temp.sum = trim(entry(6,v-str,"|")).
                    end.
                end.
                else do:
                    if num-entries(v-str,"|") = 7 then do:
                        if (v-str begins "N") or (v-str begins "п/п") or (v-str matches "*СИК (указывать,если изменялись)*") then next.
                        create t-temp.
                        t-temp.k = entry(1,v-str,"|").
                        t-temp.sik = entry(2,v-str,"|").
                        t-temp.fio = entry(3,v-str,"|").
                        t-temp.fioreg = entry(4,v-str,"|").
                        t-temp.birthday = entry(5,v-str,"|").
                        t-temp.rnnbin = entry(6,v-str,"|").
                        t-temp.sum = entry(7,v-str,"|").
                    end.
                end.
            end.
            input close.

            v-file = "/data/export/pensioncom.htm".
            input from value(v-file).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*nameorganization*" then do:
                        if v-nameorganization <> "" then v-str = replace(v-str,"nameorganization",trim(v-nameorganization)).
                        else v-str = replace(v-str,"nameorganization","").
                        next.
                    end.
                    if v-str matches "*rnnorgone*" then do:
                        if v-rnnorgone <> "" then v-str = replace(v-str,"rnnorgone",trim(v-rnnorgone)).
                        else v-str = replace(v-str,"rnnorgone","").
                        next.
                    end.
                    if v-str matches "*kbeorgone*" then do:
                        v-str = replace(v-str,"kbeorgone","").
                        next.
                    end.
                    if v-str matches "*accorgone*" then do:
                        if v-accorgone <> "" then v-str = replace(v-str,"accorgone",trim(v-accorgone)).
                        else v-str = replace(v-str,"accorgone","").
                        next.
                    end.
                    if v-str matches "*bicbnkone*" then do:
                        if v-bicbnkone <> "" then v-str = replace(v-str,"bicbnkone",trim(v-bicbnkone)).
                        else v-str = replace(v-str,"bicbnkone","").
                    end.
                    if v-str matches "*nameorgtiontwo*" then do:
                        if v-nameorgtiontwo <> "" then v-str = replace(v-str,"nameorgtiontwo",trim(v-nameorgtiontwo)).
                        else v-str = replace(v-str,"nameorgtiontwo","").
                        next.
                    end.
                    if v-str matches "*rnnorgtwo*" then do:
                        if v-rnnorgtwo <> "" then v-str = replace(v-str,"rnnorgtwo",trim(v-rnnorgtwo)).
                        else v-str = replace(v-str,"rnnorgtwo","").
                        next.
                    end.
                    if v-str matches "*accorgtwo*" then do:
                        if v-accorgtwo <> "" then v-str = replace(v-str,"accorgtwo",trim(v-accorgtwo)).
                        else v-str = replace(v-str,"accorgtwo","").
                        next.
                    end.
                    if v-str matches "*bicbnktwo*" then do:
                        if v-bicbnktwo <> "" then v-str = replace(v-str,"bicbnktwo",trim(v-bicbnktwo)).
                        else v-str = replace(v-str,"bicbnktwo","").
                        next.
                    end.
                    if v-str matches "*docnumber*" then do:
                        if avail remtrz then v-str = replace(v-str,"docnumber",trim(remtrz.remtrz)).
                        else v-str = replace(v-str,"docnumber","").
                        next.
                    end.
                    if v-str matches "*createdate*" then do:
                        if avail remtrz then v-str = replace(v-str,"createdate",string(remtrz.rdt,"99/99/9999")).
                        else v-str = replace(v-str,"createdate","").
                        next.
                    end.
                    if v-str matches "*numplat*" then do:
                        if avail remtrz then v-str = replace(v-str,"numplat",trim(substr(remtrz.sqn,19,8))).
                        else v-str = replace(v-str,"numplat","").
                        next.
                    end.
                    if v-str matches "*datepldoc*" then do:
                        if avail remtrz then v-str = replace(v-str,"datepldoc",string(remtrz.valdt1,'99/99/9999')).
                        else v-str = replace(v-str,"datepldoc","").
                        next.
                    end.
                    if v-str matches "*dtbegin*" then do:
                        v-str = replace(v-str,"dtbegin","").
                        next.
                    end.
                    if v-str matches "*dtend*" then do:
                        v-str = replace(v-str,"dtend","").
                        next.
                    end.
                    if v-str matches "*bankname*" then do:
                        if v-bankname <> "" then v-str = replace(v-str,"bankname",replace(trim(v-bankname),'"','')).
                        else v-str = replace(v-str,"bankname","").
                        next.
                    end.
                    if v-str matches "*RNBNIN*" then do:
                        if v-bin then do:
                            if avail remtrz and remtrz.valdt1 ge v-bin_rnn_dt then v-str = replace(v-str,"RNBNIN","ИИН/БИН").
                            else v-str = replace(v-str,"RNBNIN","РНН").
                        end.
                        else v-str = replace(v-str,"RNBNIN","РНН").
                    end.
                    leave.
                end.
                put stream rep unformatted v-str skip.
            end.
            input close.

            put stream rep unformatted
                "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

            put stream rep unformatted
                "<tr align=center style='font-size:10pt;font:bold;font-family:Calibri'>" skip
            /*1*/ "<td>№</td>" skip.
            if not v-bin then put stream rep unformatted
            /*2*/ "<td>СИК</td>" skip.
            put stream rep unformatted
            /*3*/ "<td>Фамилия<br>Имя, Отчество</td>" skip.
            if not v-bin then put stream rep unformatted
            /*4*/ "<td>ФИО(при регистрации)</td>" skip.
            put stream rep unformatted
            /*5*/ "<td>Дата рождения</td>" skip.
            if v-bin then put stream rep unformatted
            /*6*/ "<td>ИИН</td>" skip.
            else put stream rep unformatted
            /*6*/ "<td>РНН</td>" skip.
            put stream rep unformatted
            /*7*/ "<td>Сумма взноса</td>" skip
                "</tr>" skip.

            for each t-temp no-lock:
                put stream rep unformatted
                    "<tr align=center style='font-size:10pt;font-family:Calibri'>" skip
                /*1*/ "<td>" t-temp.k "</td>" skip.
                if not v-bin then put stream rep unformatted
                /*2*/ "<td>" t-temp.sik "</td>" skip.
                put stream rep unformatted
                /*3*/ "<td>" t-temp.fio "</td>" skip.
                if not v-bin then put stream rep unformatted
                /*4*/ "<td>" t-temp.fioreg "</td>" skip.
                put stream rep unformatted
                /*5*/ "<td>" t-temp.birthday "</td>" skip
                /*6*/ "<td>" t-temp.rnnbin "</td>" skip
                /*7*/ "<td>" t-temp.sum "</td>" skip
                    "</tr>" skip.
            end.
            put stream rep unformatted
                "</TABLE>" skip.

            put stream rep unformatted
                "<TABLE rules=groups width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
            put stream rep unformatted
                "<tr><td colspan=7 height=""30""></tr>" skip
                "<tr><td colspan=7 height=""30""></tr>" skip
                "<tr><td colspan=7 height=""30""></tr>" skip.
            put stream rep unformatted
                "</TABLE>" skip.
            put stream rep unformatted
                "<TABLE rules=groups width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
            find first ofc where ofc.ofc = g-ofc no-lock no-error.
            put stream rep unformatted
                "<tr style='font-size:10pt;font-family:Calibri'>" skip
                "<td colspan=2>М.П.</td>" skip
                "<td colspan=2>Подпись клиента</td>" skip
                "<td colspan=3>Подпись банка</td>" skip
                "</tr>" skip
                "<tr style='font-size:10pt;font-family:Calibri'>" skip
                "<td colspan=2></td>" skip
                "<td colspan=2>" trim(v-chief)  "</td>" skip
                "<td colspan=3>" trim(ofc.name) "</td>" skip
                "</tr>" skip.

            put stream rep unformatted
                "</TABLE>" skip.

            {html-end.i "stream rep"}
            output stream rep close.

            input from value(v-outfile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream rep2 unformatted v-str skip.
            end.
            input close.
            s-Print_2 = true.
        end.
/*----------------------------------------------------------------------------------------------------------------------------*/

        unix silent value('rm -f ' + s-remtrz + ".txt").
    end.

    if ofc.mday[2] = 1 then do:
        output to value ('rpt.img') append.
        put unformatted skip(14).
        output close.
    end.
end procedure.


/*для инкассовых ОПВ и СО*/
   def stream r-in.
   def stream r-out.
procedure print_PNJINK.
    define variable pf_file as char.
    define variable tempstr as char.
    def var v-txt as char no-undo.
    def var v-21 as integer no-undo.
    def var i as integer no-undo.
    def var v-nm as char no-undo.
    def var v-nm2 as char no-undo.
    def var v-fm as char no-undo.
    def var v-fm2 as char no-undo.
    def var v-ft as char no-undo.
    def var v-ft2 as char no-undo.
    def var v-sic as char no-undo.
    def var v-rnn as char no-undo.
    def var v-dt as char no-undo.
    def var v-21t as char no-undo.
    def var v-sum as char no-undo.
    def var v-bnf as char no-undo.

    find first aaar where aaar.a1 = s-remtrz no-lock no-error.
    if not avail aaar then return.

    find first inc100 where inc100.iik = aaar.a5 and inc100.num = int(aaar.a2) no-lock no-error.
    if not avail inc100 then return.
    if inc100.reschar[1] = '' then return.
    v-txt = inc100.reschar[1].
    do i = 1 to num-entries(v-txt,'^'):
        if entry (i,v-txt, '^') begins ':21:' then do:
            v-21 = v-21 + 1.
            entry (i,v-txt, '^') = ':21:' + string(v-21).
        end.
    end.

    output to value ('rpt.img') append.
    put unformatted skip(5).

    put unformatted remtrz.remtrz skip.


    if inc100.vo = '07' then put unformatted '                СПИСОК НА ПЕРЕЧИСЛЕНИЕ ОБЯЗАТЕЛЬНЫХ ПЕНСИОННЫХ ОТЧИСЛЕНИЙ' skip.
    else put unformatted '                СПИСОК НА ПЕРЕЧИСЛЕНИЕ ОБЯЗАТЕЛЬНЫХ СОЦИАЛЬНЫХ ОТЧИСЛЕНИЙ' skip.
    put unformatted '              К платежному поручению N ' + trim( substring( remtrz.sqn,19,8 ))  + ' от ' string(remtrz.rdt,'99/99/9999')  skip.
    put unformatted inc100.name skip.
    if v-bin then do:
    put unformatted inc100.bin skip.
    end. else do:
        put unformatted inc100.jss skip.
    end.
    put unformatted 'Счет N ' inc100.iik ' в АО ' v-bankname skip.
    put unformatted 'МФО ' inc100.mfo skip.
    v-bnf = inc100.bnf.
    if v-bnf matches '*Республиканское государственное казенное предприятие "Госуда*' then v-bnf = "РГКП ГЦВП".
    put unformatted v-bnf skip.
    if v-bin then do:
    put unformatted inc100.nkbin skip.
    end. else do:
        put unformatted inc100.dpname skip.
    end.
    put unformatted 'Счет N ' inc100.reschar[2] ' в ДМО НБ РК' skip.
    put unformatted 'МФО ' inc100.reschar[3] skip.

    put unformatted fill('-',126) skip.
    if v-bin then do:
        put unformatted '  N  |            Фамилия             |   Дата   |    ИИН     |             ' skip.
        put unformatted ' п/п |         Имя, Отчество          | pождения | получателя |        Сумма' skip.
        put unformatted '     |                                |          |   пенсии   |             ' skip.
    end.
    else do:
        put unformatted '  N  |      СИК       |            Фамилия             | Фамилия, Имя, Отчество         |   Дата   |    РНН' skip.
        put unformatted ' п/п |                |         Имя, Отчество          | в рег. карточке для получения  | pождения | получателя|        Сумма' skip.
        put unformatted '     |                |                                | СИК (указывать,если изменялись)|          |   пенсии' skip.
    end.
    put unformatted fill('-',126) skip.

    v-fm = ''.
    v-nm = ''.
    v-ft = ''.
    v-fm2 = ''.
    v-nm2 = ''.
    v-ft2 = ''.

    v-sic = ''.
    v-dt = ''.
    v-21t = ''.
    v-rnn = ''.
    v-sum = ''.
    def var v-str1 as char.
    if v-bin then do:
        if v-txt matches '*^//FM*' then do:
            do i = 1 to num-entries(v-txt,'^'):
                if entry (i,v-txt, '^') begins ':21:' then do:
                    if v-21t <> '' then v-21t = v-21t + ','.
                    v-21t = v-21t + entry(3,entry(i, v-txt, "^"),':').
                end.

                if entry (i,v-txt, '^') begins ':70:/OPV/' then do:
                    if v-sic <> '' then v-sic = v-sic + ','.
                    v-sic = v-sic + substr(entry(3,entry(i, v-txt, "^"),'/'),1,1).
                end.

                if entry (i,v-txt, '^') begins '//FM/' then do:
                    if v-fm <> '' then v-fm = v-fm + ','.
                    v-fm = v-fm + entry(4,entry(i, v-txt, "^"),'/').
                    /*if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-fm2 <> '' then v-fm2 = v-fm2 + ','.
                    v-fm2 = v-fm2 + entry(5,entry(i, v-txt, "^"),'/').
                    end.*/
                end.

                if entry (i,v-txt, '^') begins '//NM/' then do:
                    if v-nm <> '' then v-nm = v-nm + ','.
                    v-nm = v-nm + entry(4,entry(i, v-txt, "^"),'/').
                    /*if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-nm2 <> '' then v-nm2 = v-nm2 + ','.
                    v-nm2 = v-nm2 + entry(5,entry(i, v-txt, "^"),'/').
                    end.*/
                end.

                if entry (i,v-txt, '^') begins '//FT/' then do:
                    if v-ft <> '' then v-ft = v-ft + ','.
                    v-ft = v-ft + entry(4,entry(i, v-txt, "^"),'/').
                    /*if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-ft2 <> '' then v-ft2 = v-ft2 + ','.
                    v-ft2 = v-ft2 + entry(5,entry(i, v-txt, "^"),'/').
                    end.*/
                end.

                if entry (i,v-txt, '^') begins '//DT/' then do:
                    if v-dt <> '' then v-dt = v-dt + ','.
                    v-dt = v-dt + entry(4,entry(i, v-txt, "^"),'/').
                end.

                if entry (i,v-txt, '^') begins '//RNN/' then do:
                    if v-rnn <> '' then v-rnn = v-rnn + ','.
                    v-str1 = entry(4,entry(i, v-txt, "^"),'/').
                    find first rnn where rnn.trn = v-str1 no-lock no-error.
                    if avail rnn then do:
                        v-str1 = rnn.bin.
                    end.
                    else do:
                        find first rnnu where rnnu.trn = v-str1 no-lock no-error.
                        if avail rnnu then do:
                            v-str1 = rnnu.bin.
                        end.
                        else do:
                            v-str1 = '-'.
                        end.
                    end.
                    v-rnn = v-rnn + v-str1.
                end.

                if entry (i,v-txt, '^') begins ':32B:' then do:
                    if v-sum <> '' then v-sum = v-sum + ';'.
                    v-sum = v-sum + substr(entry(3,entry(i, v-txt, "^"),':'),4 ,length(entry(3,entry(i, v-txt, "^"),':'))).
                end.
            end.
        end. /*if v-txt matches '*^//FM*'*/
        else do:
            do i = 1 to num-entries(v-txt,'^'):
                if entry (i,v-txt, '^') begins ':21:' then do:
                    if v-21t <> '' then v-21t = v-21t + ','.
                    v-21t = v-21t + entry(3,entry(i, v-txt, "^"),':').
                end.

                if entry (i,v-txt, '^') begins '/OPV/' then do:
                    if v-sic <> '' then v-sic = v-sic + ','.
                    v-sic = v-sic + substr(entry(3,entry(i, v-txt, "^"),'/'),1,1).
                end.

                if entry (i,v-txt, '^') begins '/FM/' then do:
                    if v-fm <> '' then v-fm = v-fm + ','.
                    v-fm = v-fm + entry(3,entry(i, v-txt, "^"),'/').
                    if num-entries(entry (i,v-txt, '^'),'/') > 3 then do:
                        if v-fm2 <> '' then v-fm2 = v-fm2 + ','.
                        v-fm2 = v-fm2 + entry(4,entry(i, v-txt, "^"),'/').
                    end.
                end.

                if entry (i,v-txt, '^') begins '/NM/' then do:
                    if v-nm <> '' then v-nm = v-nm + ','.
                    v-nm = v-nm + entry(3,entry(i, v-txt, "^"),'/').
                    if num-entries(entry (i,v-txt, '^'),'/') > 3 then do:
                        if v-nm2 <> '' then v-nm2 = v-nm2 + ','.
                        v-nm2 = v-nm2 + entry(4,entry(i, v-txt, "^"),'/').
                    end.
                end.

                if entry (i,v-txt, '^') begins '/FT/' then do:
                    if v-ft <> '' then v-ft = v-ft + ','.
                    v-ft = v-ft + entry(3,entry(i, v-txt, "^"),'/').
                    if num-entries(entry (i,v-txt, '^'),'/') > 3 then do:
                        if v-ft2 <> '' then v-ft2 = v-ft2 + ','.
                        v-ft2 = v-ft2 + entry(4,entry(i, v-txt, "^"),'/').
                    end.
                end.

                if entry (i,v-txt, '^') begins '/DT/' then do:
                    if v-dt <> '' then v-dt = v-dt + ','.
                    v-dt = v-dt + entry(3,entry(i, v-txt, "^"),'/').
                end.

                if entry (i,v-txt, '^') begins '/IDN/' then do:
                    if v-rnn <> '' then v-rnn = v-rnn + ','.
                    v-rnn = v-rnn + entry(3,entry(i, v-txt, "^"),'/').
                end.

                if entry (i,v-txt, '^') begins ':32B:' then do:
                    if v-sum <> '' then v-sum = v-sum + ';'.
                    v-sum = v-sum + substr(entry(3,entry(i, v-txt, "^"),':'),4 ,length(entry(3,entry(i, v-txt, "^"),':'))).
                end.
            end.
        end.
    end. /*if v-bin*/
    else do:
        do i = 1 to num-entries(v-txt,'^'):
            if entry (i,v-txt, '^') begins ':21:' then do:
                if v-21t <> '' then v-21t = v-21t + ','.
                v-21t = v-21t + entry(3,entry(i, v-txt, "^"),':').
            end.

            if entry (i,v-txt, '^') begins ':70:/OPV/' then do:
                if v-sic <> '' then v-sic = v-sic + ','.
                v-sic = v-sic + substr(entry(3,entry(i, v-txt, "^"),'/'),2,16).
            end.

            if entry (i,v-txt, '^') begins '//FM/' then do:
                if v-fm <> '' then v-fm = v-fm + ','.
                v-fm = v-fm + entry(4,entry(i, v-txt, "^"),'/').
                if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-fm2 <> '' then v-fm2 = v-fm2 + ','.
                    v-fm2 = v-fm2 + entry(5,entry(i, v-txt, "^"),'/').
                end.
            end.

            if entry (i,v-txt, '^') begins '//NM/' then do:
                if v-nm <> '' then v-nm = v-nm + ','.
                v-nm = v-nm + entry(4,entry(i, v-txt, "^"),'/').
                if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-nm2 <> '' then v-nm2 = v-nm2 + ','.
                    v-nm2 = v-nm2 + entry(5,entry(i, v-txt, "^"),'/').
                end.
            end.

            if entry (i,v-txt, '^') begins '//FT/' then do:
                if v-ft <> '' then v-ft = v-ft + ','.
                v-ft = v-ft + entry(4,entry(i, v-txt, "^"),'/').
                if num-entries(entry (i,v-txt, '^'),'/') > 4 then do:
                    if v-ft2 <> '' then v-ft2 = v-ft2 + ','.
                    v-ft2 = v-ft2 + entry(5,entry(i, v-txt, "^"),'/').
                end.
            end.

            if entry (i,v-txt, '^') begins '//DT/' then do:
                if v-dt <> '' then v-dt = v-dt + ','.
                v-dt = v-dt + entry(4,entry(i, v-txt, "^"),'/').
            end.

            if entry (i,v-txt, '^') begins '//RNN/' then do:
                if v-rnn <> '' then v-rnn = v-rnn + ','.
                v-rnn = v-rnn + entry(4,entry(i, v-txt, "^"),'/').
            end.

            if entry (i,v-txt, '^') begins ':32B:' then do:
                if v-sum <> '' then v-sum = v-sum + ';'.
                v-sum = v-sum + substr(entry(3,entry(i, v-txt, "^"),':'),4 ,length(entry(3,entry(i, v-txt, "^"),':'))).
            end.
        end.
    end.
    empty temp-table t-data.
    if v-bin then do:
        do i = 1 to v-21:
            put unformatted fill(' ', 5 - length(entry(i,v-21t))) + entry(i,v-21t) +  '|'.

            if length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft)) < 32 then do:
                put unformatted fill(' ',32 - length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft))) + entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft) + '|' .
            end.
            else do:
                put unformatted fill(' ',32 - length(entry(i,v-fm))) + entry(i,v-fm) + '|'.
            end.
            put unformatted substr(entry(i,v-dt),7,2) + '.' + substr(entry(i,v-dt),5,2) + '.' + substr(entry(i,v-dt),1,4) + '|'  + fill(' ',12 - length(entry(i,v-rnn))) + entry(i,v-rnn).

            if length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft)) > 32 then do:
                put unformatted fill(' ',5) + '|' + fill(' ',16) + '|' + fill(' ',32 - length(entry(i,v-nm))) + entry(i,v-nm) + '|'.
                put unformatted skip fill(' ',5) + '|' + fill(' ',16) + '|' + fill(' ',32 - length(entry(i,v-ft))) + entry(i,v-ft) + '|'.
                put unformatted skip.
            end.
            put unformatted '|' + entry(i,v-sum,';') skip.

            create t-data.
            t-data.num = trim(entry(i,v-21t)).
            t-data.fio = entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft).
            t-data.birthday = substr(entry(i,v-dt),7,2) + '.' + substr(entry(i,v-dt),5,2) + '.' + substr(entry(i,v-dt),1,4).
            t-data.rnn = entry(i,v-rnn).
            t-data.sum = entry(i,v-sum,';').
        end.
        put unformatted fill('-',126) skip.
        put unformatted 'Всего записей:           ' + string(v-21) skip.
        put unformatted 'Общая сумма:                          ' + replace(string(remtrz.amt,'>>,>>>,>>>,>>9.99'),'.',',') skip.
        put unformatted 'Руководитель:' skip.
        put unformatted 'Главный бухгалтер:' skip(3).
        put unformatted fill('-',126) skip.
    end. /*if v-bin*/
    else do:
        do i = 1 to v-21:
            put unformatted fill(' ', 5 - length(entry(i,v-21t))) + entry(i,v-21t) +  '|' + entry(i,v-sic) + '|'.

            if length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft)) < 32 then do:
                put unformatted fill(' ',32 - length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft))) + entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft) + '|' .
                if v-fm2 <> '' and v-nm2 <> '' and v-ft2 <> '' and (entry(i,v-fm2) + ' ' + entry(i,v-nm2) + ' ' + entry(i,v-ft2) <> '') then put unformatted fill(' ',32 - length(entry(i,v-fm2) + ' ' + entry(i,v-nm2) + ' ' + entry(i,v-ft2))) + entry(i,v-fm2) + ' ' + entry(i,v-nm2) + ' ' + entry(i,v-ft2) + '|'.
                else put unformatted fill(' ',32).
            end.
            else do:
                put unformatted fill(' ',32 - length(entry(i,v-fm))) + entry(i,v-fm) + '|'.
                if v-fm2 <> '' and entry(i,v-fm2) <> '' then put unformatted fill(' ',32 - length(entry(i,v-fm2))) + entry(i,v-fm2) + '|'.
                else put unformatted fill(' ',32).
            end.

            put unformatted substr(entry(i,v-dt),7,2) + '.' + substr(entry(i,v-dt),5,2) + '.' + substr(entry(i,v-dt),1,4) + '|'  + entry(i,v-rnn).

            if length(entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft)) > 32 then do:
                put unformatted fill(' ',5) + '|' + fill(' ',16) + '|' + fill(' ',32 - length(entry(i,v-nm))) + entry(i,v-nm) + '|'.
                if v-nm2 <> '' and entry(i,v-nm2) <> '' then put unformatted fill(' ',32 - length(entry(i,v-nm2))) + entry(i,v-nm2) + '|' + fill(' ',10) + '|' + fill(' ',12).
                else put unformatted fill(' ',32).

                put unformatted skip fill(' ',5) + '|' + fill(' ',16) + '|' + fill(' ',32 - length(entry(i,v-ft))) + entry(i,v-ft) + '|'.
                if v-ft2 <> '' and entry(i,v-ft2) <> '' then put unformatted fill(' ',32 - length(entry(i,v-ft2))) + entry(i,v-ft2) + '|' + fill(' ',10) + '|' + fill(' ',12).
                else put unformatted fill(' ',32).
                put unformatted skip.
            end.
            put unformatted '|' + entry(i,v-sum,';') skip.

            create t-data.
            t-data.num = trim(entry(i,v-21t)).
            t-data.sik = trim(entry(i,v-sic)).
            t-data.fio = entry(i,v-fm) + ' ' + entry(i,v-nm) + ' ' + entry(i,v-ft).
            if v-fm2 <> '' and v-nm2 <> '' and v-ft2 <> '' and (entry(i,v-fm2) + ' ' + entry(i,v-nm2) + ' ' +
            entry(i,v-ft2) <> '') then t-data.fioreg = entry(i,v-fm2) + ' ' + entry(i,v-nm2) + ' ' + entry(i,v-ft2).
            t-data.birthday = substr(entry(i,v-dt),7,2) + '.' + substr(entry(i,v-dt),5,2) + '.' + substr(entry(i,v-dt),1,4).
            t-data.rnn = entry(i,v-rnn).
            t-data.sum = entry(i,v-sum,';').
        end. /*do i = 1 to v-21*/

        put unformatted fill('-',126) skip.
        put unformatted 'Всего записей:           ' + string(v-21) skip.
        put unformatted 'Общая сумма:                          ' + replace(string(remtrz.amt,'>>,>>>,>>>,>>9.99'),'.',',') skip.
        put unformatted 'Руководитель:' skip.
        put unformatted 'Главный бухгалтер:' skip(3).
        put unformatted fill('-',126) skip.
    end.
    output close.

    /*---------------------------------------------------------------------------------------------------------------------------------*/
    output stream rep3 to value(v-outfile3).
    {html-title.i &stream = "stream rep3"}

    v-ifileinput = "/data/export/pensioncom.htm".
    input from value(v-ifileinput).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*nameorganization*" then do:
                if inc100.name <> "" then v-str = replace (v-str,"nameorganization",trim(inc100.name)).
                else v-str = replace (v-str,"nameorganization","").
                next.
            end.
            if v-str matches "*docnumber*" then do:
                if trim(remtrz.remtrz) <> "" then v-str = replace (v-str,"docnumber",trim(remtrz.remtrz)).
                else v-str = replace (v-str,"docnumber","").
                next.
            end.
            if v-str matches "*createdate*" then do:
                if remtrz.rdt <> ? then v-str = replace (v-str,"createdate",string(remtrz.rdt,"99/99/9999")).
                else v-str = replace (v-str,"createdate","").
                next.
            end.
            if v-str matches "*numplat*" then do:
                if substring(remtrz.sqn,19,8) <> "" then v-str = replace (v-str,"numplat",substring(remtrz.sqn,19,8)).
                else v-str = replace (v-str,"numplat","").
                next.
            end.
            if v-str matches "*datepldoc*" then do:
                if remtrz.rdt <> ? then v-str = replace (v-str,"datepldoc",string(remtrz.rdt,'99/99/9999')).
                else v-str = replace (v-str,"datepldoc","").
                next.
            end.
            if v-str matches "*dtbegin*" then do:
                v-str = replace (v-str,"dtbegin","").
                next.
            end.
            if v-str matches "*dtend*" then do:
                v-str = replace (v-str,"dtend","").
                next.
            end.
            if v-str matches "*rnnorgone*" then do:
                if v-bin then v-str = replace (v-str,"rnnorgone",trim(inc100.bin)).
                else v-str = replace (v-str,"rnnorgone",trim(inc100.jss)).
                next.
            end.
            if v-str matches "*kbeorgone*" then do:
                v-str = replace (v-str,"kbeorgone","").
                next.
            end.
            if v-str matches "*accorgone*" then do:
                if inc100.iik <> "" then v-str = replace (v-str,"accorgone",trim(inc100.iik)).
                else v-str = replace (v-str,"accorgone","").
                next.
            end.
            if v-str matches "*bicbnkone*" then do:
                v-str = replace (v-str,"bicbnkone","FOBAKZKA").
                next.
            end.
            if v-str matches "*nameorgtiontwo*" then do:
                if v-bnf <> "" then v-str = replace (v-str,"nameorgtiontwo",trim(v-bnf)).
                else v-str = replace (v-str,"nameorgtiontwo","").
                next.
            end.
            if v-str matches "*rnnorgtwo*" then do:
                if v-bin then v-str = replace (v-str,"rnnorgtwo",trim(inc100.nkbin)).
                else v-str = replace (v-str,"rnnorgtwo",inc100.dpname).
                next.
            end.
            if v-str matches "*accorgtwo*" then do:
                if inc100.reschar[2] <> "" then v-str = replace (v-str,"accorgtwo",trim(inc100.reschar[2])).
                else v-str = replace (v-str,"accorgtwo","").
                next.
            end.
            if v-str matches "*bicbnktwo*" then do:
                if inc100.reschar[3] <> "" then v-str = replace (v-str,"bicbnktwo",trim(inc100.reschar[3])).
                else v-str = replace (v-str,"bicbnktwo","").
                next.
            end.
            if v-str matches "*bankname*" then do:
                if v-bankname <> "" then v-str = replace (v-str,"bankname",replace(trim(v-bankname),'"','')).
                else v-str = replace (v-str,"bankname","").
                next.
            end.
            if v-str matches "*RNBNIN*" then do:
                if v-bin then v-str = replace (v-str,"RNBNIN","ИИН/БИН").
                else v-str = replace (v-str,"RNBNIN","РНН").
            end.
            leave.
        end.
        put stream rep3 unformatted v-str skip.
    end.
    input close.

    put stream rep3 unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream rep3 unformatted
        "<tr align=center style='font-size:10pt;font:bold;font-family:Calibri'>" skip
    /*1*/   "<td>№</td>" skip.
    if not v-bin then put stream rep3 unformatted
    /*2*/   "<td>СИК</td>" skip.
    put stream rep3 unformatted
    /*3*/   "<td>Фамилия<br>Имя, Отчество</td>" skip.
    if not v-bin then put stream rep3 unformatted
    /*4*/   "<td>ФИО(при регистрации)</td>" skip.
    put stream rep3 unformatted
    /*5*/   "<td>Дата рождения</td>" skip.
    if v-bin then put stream rep3 unformatted
    /*6*/   "<td>ИИН</td>" skip.
    else put stream rep3 unformatted
    /*6*/   "<td>РНН</td>" skip.
    put stream rep3 unformatted
    /*7*/   "<td>Сумма взноса</td>" skip
        "</tr>" skip.

    i = 0.
    for each t-data no-lock:
        i = i + 1.
        put stream rep3 unformatted
            "<tr align=center style='font-size:10pt;font-family:Calibri'>" skip
    /*1*/   "<td>" string(i) "</td>" skip.
        if not v-bin then put stream rep3 unformatted
    /*2*/   "<td>" t-data.sik "</td>" skip.
        put stream rep3 unformatted
    /*3*/   "<td>" t-data.fio "</td>" skip.
        if not v-bin then put stream rep3 unformatted
    /*4*/   "<td>" t-data.fioreg "</td>" skip.
        put stream rep3 unformatted
    /*5*/   "<td>" t-data.birthday "</td>" skip
    /*6*/   "<td>" t-data.rnnbin "</td>" skip
    /*7*/   "<td>" t-data.sum "</td>" skip
            "</tr>" skip.
    end.

    put stream rep3 unformatted
        "</TABLE>" skip.

    put stream rep3 unformatted
        "<TABLE rules=groups width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.

    put stream rep3 unformatted
        "<tr><td height=30></td></tr>" skip.

    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    put stream rep3 unformatted
        "<tr style='font-size:10pt;font-family:Calibri'>" skip
        "<td colspan=2>М.П.</td>" skip
        "<td colspan=2>Подпись клиента</td>" skip
        "<td colspan=3>Подпись банка</td>" skip
        "</tr>" skip
        "<tr style='font-size:10pt;font-family:Calibri'>" skip
        "<td colspan=2></td>" skip
        "<td colspan=2>" trim(v-chief)  "</td>" skip
        "<td colspan=3>" trim(ofc.name) "</td>" skip
        "</tr>" skip.

    put stream rep3 unformatted
        "</TABLE>" skip.

    {html-end.i "stream rep3"}
    output stream rep3 close.

    input from value(v-outfile3).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*</body>*" then do:
                v-str = replace(v-str,"</body>","").
            end.
            if v-str matches "*</html>*" then do:
                v-str = replace(v-str,"</html>","").
            end.
            else v-str = trim(v-str).
            leave.
        end.
        put stream rep4 unformatted v-str skip.
    end.
    input close.
    s-Print_3 = true.
    /*---------------------------------------------------------------------------------------------------------------------------------*/

    find first ofc where ofc.ofc = userid('bank').
    if ofc.mday[2] = 1 then do:
        output to value ('rpt.img') append.
        put unformatted skip(14).
        output close.
    end.
end procedure.


