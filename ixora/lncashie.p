/* lncashie.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Оплата кредита через кассу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункет меню
 * AUTHOR
        08/07/2005 madiyar
 * BASES
        BANK COMM CARDS
 * CHANGES
        11/08/2005 madiyar - учет остатка на текущем счете; доделал вывод всех сопровождающих документов (пока проводка и доки закомментированы)
        19/08/2005 madiyar - переделал расчет суммы полного погашения; раскомментировал проводку и сопутствующие доки
        22/08/2005 madiyar - статус транзакции = 5
        23/08/2005 madiyar - исправил ошибку формирования v-param по краткосрочным кредитам
                             символ кассплана проставляется автоматически
                             выключил печать всего, кроме приходно-кассового ордера
        09/09/2005 madiyar - пополнение счета через кассу в пути
        19/09/2005 madiyar - печать ордеров
        22/09/2005 madiyar - поправка для филиалов по комиссиям
                             исправил ошибку определения arp-счета
        05/10/2005 madiyar - непогашенные кредиты - смотрится еще списанный ОД
        07/10/2005 madiyar - проверка, что сумма не >= сумме полного досрочного погашения - только если не последнее погашение по графику
        17/10/2005 madiyar - учел случай, когда срок кредита уже закончился
        31/10/2005 madiyar - когда срок кредита уже закончился - считать все уровни
        06/12/2006 madiyar - смотрим уровни процентов и штрафов тоже
	    23.03.2006 u00121  - Новый алгоритм определения работы по кассе или кассе в пути
	    29/03/2006 madiyar - учитываем уровни внебалансовых процентов и штрафов
	    11/04/2006 madiyar - выдача кредита с биометрическим контролем
	    12/04/2006 madiyar - выдача кредита с биометрическим контролем - пока только в Алматы
	    17/04/2006 madiyar - убрал validate
	    12/05/2006 madiyar - сообщение о возможности рефинансирования
        09/08/06 Natalya D.- добавила "окно оповещение" о наличии ссудной задолженности по кредитной карте.
        25/09/2006 madiyar - сообщение о выпуске карты, определение приоритетности погашения просрочки (по БД или карте)
        24/10/2006 madiyar - не оповещаем клиентов о выпуске карт от 19 и 20 октября 2006 года в связи с переездом на новый процессинг
        09/11/2006 madiyar - не проверяем задолженность по картам в связи с переездом на новый процессинг
        23/11/2006 madiyar - переделал проверку задолженности по платежной карте
        24/11/2006 madiyar - проверка задолженности по платежной карте - выдается сообщение, но позволяет пройти дальше
        28/02/2007 madiyar - убрал лишнее, связанное с картами, третьей схемой и тп; распространил на 4ую схему (ИП)
        02/05/2007 madiyar - подправил расчет комиссии и суммы полного досрочного погашения по 4ой схеме (ИП)
        26/12/2007 madiyar - временно выключил транзакции - погашение и выдача идут через РКЦ
        13/03/2008 madiyar - идет ли выдача-погашение через РКЦ - определяется из справочника rkcout
        27/03/2008 madiyar - 0 - успешная сверка отпечатков
        12/06/2008 madiyar - пересечения с МКО-шными кредитами по номеру ссудного счета, добавил еще проверку на совпадение cif
        18/06/2008 madiyar - валютные кредиты, выключил сообщение о возможности рефинансирования
        29/08/2008 madiyar - исправил мелкую ошибку
        17/02/2009 galina  - выбираем счет для кассы в пути в валюте кредита
        26/02/2008 madiyar - подправил текст в комментариях к проводкам
        10/03/2009 madiyar - подправил расчет суммы досрочного погашения
        09/09/2009 galina  - округлила итоговые суммы
        11/05/2010 madiyar - по всем кредитам с датой выдачи с 06/18/2009 выдается сообщение о необходимости подписания доп. соглашения
        09/04/2011 madiyar - убрал оповещение о доп. соглашении
        05.05.2011 aigul   - добавила возможность просмотра и удаления проводки
        13.01.2012 damir   - добавил keyord.i, printord.p..
        01.02.2012 lyubov  - изменила символ кассплана (150 на 090 и 450 на 290)
        07.03.2012 damir   - добавил входной параметр в printord.p.
        19.07.2012 damir   - поправил сохранение данных по удост.личности в поле joudoc.passp.
        09/11/2011 madiyar - перекомпиляция
        14/01/2013 id01143(sayat) - ТЗ 1652 замена РНН на ИИН
*/

{mainhead.i}
{pk0.i}

{comm-txb.i}
{sysc.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def var s_account_a as char no-undo.
def var s_account_b1 as char no-undo.
def var s_account_b2 as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.
def var v-joudoc as char no-undo.
def var v-chk as logical initial no.
function sumround returns deci (p-sum as deci).
  if p-sum > truncate(p-sum,0) then p-sum = truncate(p-sum,0) + 1.
  return p-sum.
end.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then
	c-gl = sysc.inval.
else
	c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then
	c-gl1002 = sysc.inval.
else
	c-gl1002 = 100200.

/*23.03.2006 u00121**Новый алгоритм определения работы по кассе или кассе в пути***************************************************************************************************************************/
def var v-yn 	as log init false 	no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err	as log init false 	no-undo. /*получаем признак возникновения ошибки*/

/*23.03.2006 u00121****************************************************************************************************************************************************************************************/


def var v-tmpl as char no-undo.

def new shared var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).

def new shared var s-credtype as char init '6'.

def temp-table t-ln no-undo
    field code like codfr.code
    field name as char
    index main is primary code.

create t-ln.
t-ln.code = "1".
t-ln.name = "Погашение по графику".
create t-ln.
t-ln.code = "2".
t-ln.name = "Полное досрочное погашение".
create t-ln.
t-ln.code = "3".
t-ln.name = "Выдача займа".

def var v-cif like cif.cif.
def var v-rnn like cif.jss.
def var v-bin like cif.bin.
def var v-fio as char no-undo format "x(60)".
def var v-iik_kzt like aaa.aaa.
def var v-iik_val like aaa.aaa.
def var v-addr1 as char no-undo.
def var v-addr2 as char no-undo.
def var v-job as char no-undo.
def var v-teld as char no-undo.
def var v-tels as char no-undo.
def var v-telr as char no-undo.

def var v-dog as char no-undo format "x(10)".
def var v-crc_kzt as char no-undo format "xxx".
def var v-crc_val as char no-undo format "xxx".
def var v-loncrc as char no-undo format "xxx".
def var v-opnamt as deci no-undo.
def var v-od as deci no-undo.
def var v-ods as deci no-undo.
def var v-prc as deci no-undo.
def var v-corprc as deci no-undo.
def var v-pen as deci no-undo.

def var v-code as integer no-undo init 1.
def var v-codename as char no-undo init "(Погашение по графику)".
def var v-sum_aaa_kzt as deci no-undo.
def var v-sum_aaa_val as deci no-undo.
def var v-sum_kzt as deci no-undo.
def var v-sum_val as deci no-undo.
def var v-sum_pl as deci no-undo.
def var v-sum_kzt_old as deci no-undo.
def var v-sum_val_old as deci no-undo.
def var v-sum_full_val as deci no-undo.
def var v-sum_full_kzt as deci no-undo.

def var v-sum3m as deci no-undo.
def var v-dat3m as date no-undo.

def var v-ja as logi no-undo format "Да/Нет" init no.

def var v-lon like lon.lon.
def var v-adresd as char no-undo extent 2.

def var v-p1 as deci no-undo.
def var v-p2 as deci no-undo.

def var v-bal1 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal2fact as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal_com as deci no-undo.
def var v-bal_compr as deci no-undo.
def var v-rdt as date no-undo init ?. /* дата регистрации анкеты или выдачи кредита (если нет анкеты) */
def var v-datnextpay as date no-undo init ?. /* дата следующего платежа */

def var choice as logical no-undo init no.
def var v-choice as logical no-undo init no.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.

def var v-note as char no-undo.
def var v-resn as char no-undo.
def var v-buff as char no-undo.
def var v-glrem as char no-undo.

def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def new shared var v_doc as char.
def var v-payment as char no-undo.
def var vou-tmp as char no-undo.
def var v-intrate as deci no-undo.
def var i as integer no-undo.
def var dat_wrk as date no-undo.

def var res-compare as integer no-undo.
def var ok as logi no-undo.

def var v-respr as integer no-undo.
def var v-refsum as deci no-undo.
def var v-numpr as integer no-undo.
def var v-maxpr as integer no-undo.

def var v-iik_kzt_lab as char no-undo.
def var v-iik_val_lab as char no-undo.

def var v-sum_val_label as char no-undo.
v-sum_val_label = "Сумма.(вал.кредита)..:".
def button bdel label "Удалить транзакцию".
form
    v-joudoc label "Просмотр документа" format "x(10)" help "F2 - справочник" skip(1)
    v-cif label "Клиент......" validate (can-find(cif where cif.cif = v-cif), "Нет такого клиента!") help "Код клиента; F2-код; F4-вых; F1-далее"
    v-bin at 54 label "ИИН" skip
    /*v-rnn at 54 label "РНН" skip*/
    v-fio label "ФИО........." format "x(80)" skip
    v-iik_val_lab no-label format "x(13)" v-iik_val no-label format "x(9)" v-crc_val no-label
    v-sum_aaa_val label "Тек.остаток." format ">>>,>>>,>>>,>>>,>>9.99" at 54 skip
    v-iik_kzt_lab no-label format "x(13)" v-iik_kzt no-label format "x(9)" v-crc_kzt no-label
    v-sum_aaa_kzt label "Тек.остаток." format ">>>,>>>,>>>,>>>,>>9.99" at 54 skip
    v-addr1 label "Адрес(рег).." format "x(63)"
    v-teld at 80 label "Тел_д" format "x(20)" skip
    v-addr2 label "Адрес(факт)." format "x(63)"
    v-tels at 80 label "Тел_с" format "x(20)" skip
    v-job label "Место раб..." format "x(63)"
    v-telr at 80 label "Тел_р" format "x(20)" skip(1)

    v-dog label "Договор....." format "x(25)"
    v-loncrc at 54 label "Валюта............" skip
    v-opnamt label "Сумма займа." format ">>>,>>>,>>>,>>>,>>9.99"
    v-od at 54 label "Остаток ОД........" format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-prc label "Сумма %....." format ">>>,>>>,>>>,>>>,>>9.99"
    v-pen at 54 label "Сумма неуст.(KZT)." format ">>>,>>>,>>>,>>>,>>9.99" skip(1)

    v-code label "Вид платежа.........." format "9" validate(v-code >= 1 and v-code <= 3, "Неверный вид погашения! См. справочник (F2)") help "F2 - справочник"
    v-codename no-label format "x(30)" skip
    v-sum_val_label format "x(22)" no-label
    v-sum_val no-label format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-sum_kzt label "Сумма.(KZT).........." format ">>>,>>>,>>>,>>>,>>9.99" skip(1)

    v-ja label "Формировать транзакцию?..........." skip(5)

with side-label no-hide column 1 row 3 width 110 frame pkcas.

def frame fr1 skip
     bdel
with width 110  COLUMN 3 no-label  row 31 /*centered overlay row 5 top-only*/.
on help of v-joudoc in frame pkcas do:
    run help-joudoc.
end.
on help of v-code in frame pkcas do:

    for each t-ln: delete t-ln. end.

    create t-ln.
    t-ln.code = "1".
    t-ln.name = "Погашение по графику".
    create t-ln.
    t-ln.code = "2".
    t-ln.name = "Полное досрочное погашение".
    /*
    Выдачу выключаем - в данный момент не используется
    create t-ln.
    t-ln.code = "3".
    t-ln.name = "Выдача займа".
    */

    {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'КОД' format 'x(3)'
                    t-ln.name label 'НАЗВАНИЕ' format 'x(30)'
                   "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
    }
    v-code = integer(t-ln.code).
    displ v-code with frame pkcas.
end.


form
    "ЗАПРОС:" DCOLOR 2 v-note no-label at 10 view-as editor size 60 by 4 skip
    "ОТВЕТ :" DCOLOR 2 v-resn no-label at 10 view-as editor size 60 by 7 help "Введите данные и нажмите F1"
with side-label overlay /*no-hide 4 columns column 1 no-box*/ row 6 centered title " ОПОВЕЩЕНИЕ " frame omkq.


/*
displ v-cif v-rnn v-fio v-addr1 v-teld v-addr2 v-tels v-job v-telr v-dog v-crc_val v-opnamt v-od v-prc v-pen v-code v-codename v-sum_val v-sum_kzt v-ja with frame pkcas.
*/
displ v-sum_val_label with frame pkcas.


update v-joudoc with frame pkcas.
if v-joudoc <> "" then do:
    find first joudoc where joudoc.docnum = v-joudoc  no-lock no-error.
    if not avail joudoc then do:
        message "Нет такого документа!" view-as alert-box.
        leave.
    end.
end.
find first joudoc where joudoc.docnum = v-joudoc  no-lock no-error.
if avail joudoc and joudoc.rescha[1] = "3-2-1-6" then do:
    if joudoc.crcur <> 1 then v-sum_val = joudoc.cramt.
    if joudoc.crcur = 1 then v-sum_kzt = joudoc.cramt.
    find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
    if avail aaa then v-cif = aaa.cif.
end.
if avail joudoc and joudoc.rescha[1] <> "3-2-1-6" then do:
    message "Данная проводка не относится к пункту 3-2-1-6!" view-as alert-box.
    leave.
end.
if v-joudoc <> "" then do:
    on choose of bdel in frame fr1 do:
        find first joudoc where joudoc.docnum = v-joudoc no-lock no-error.
        if avail joudoc then do:
            if joudoc.jh = ? then do:
                message "Данная проводка была удалена!" view-as alert-box.
                return.
            end.
            else do:
                message "Удалить транзакцию?" view-as alert-box QUESTION BUTTONS YES-NO
                TITLE "Внимание!" UPDATE v-chk AS LOGICAL.
                if v-chk then do:
                    find first jh where jh.jh = joudoc.jh and jh.sts <> 6 no-lock no-error.
                    if avail jh then do:
                        run trxsts (input joudoc.jh, input 0, output rcode, output rdes).
                        if rcode ne 0 then
                        do:
                            message rdes.
                            return.
                        end.
                    end.
                    run trxdel (input joudoc.jh, input true, output rcode, output rdes).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 1000.
                        next.
                    end.
                    else do:
                        for each joudoc where joudoc.docnum = v-joudoc exclusive-lock:
                        joudoc.jh = ?.
                        end.
                        message "Проводка удалена!" view-as alert-box.
                        leave.
                    end.
                end.
            end.
        end.
    end.
end.

if v-cif = "" then
update v-cif with frame pkcas.

v-lon = ''.
for each lon where lon.cif = v-cif no-lock:
    if lon.opnamt <= 0 then next.
    if not(lon.grp = 90 or lon.grp = 92) then next.
    run lonbal('lon',lon.lon,g-today,"1,7,2,9,16,4,5",yes,output v-od).
    run lonbalcrc('lon',lon.lon,g-today,"13,14,30",yes,lon.crc,output v-ods).
    if v-od + v-ods <= 0 then next.
    v-lon = lon.lon. leave.
end.

if v-lon = '' then do:
    message "У данного клиента нет действующих кредитов БД" view-as alert-box buttons ok title " Внимание! ".
    return.
end.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = v-lon and pkanketa.cif = v-cif no-lock no-error.

if avail pkanketa then do:

    v-rdt = pkanketa.docdt.
    v-rnn = pkanketa.rnn.
    v-fio = pkanketa.name.

    run pkdefadres (pkanketa.ln, yes, output v-addr1, output v-addr2, output v-adresd[1], output v-adresd[2]).

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
    if avail pkanketh then v-teld = trim(pkanketh.value1).

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
    if avail pkanketh then v-job = trim(pkanketh.value1).

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel2" no-lock no-error.
    if avail pkanketh then v-telr = trim(pkanketh.value1).

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel3" no-lock no-error.
    if avail pkanketh then v-tels = trim(pkanketh.value1).

end.
else do:
    message " Не найдена анкета, связанная с кредитом! " view-as alert-box error.
    return.
    /*
    v-rdt = lon.rdt.
    find cif where cif.cif = v-cif no-lock no-error.
    v-rnn = cif.jss.
    v-fio = trim(cif.name).
    v-addr1 = trim(cif.addr[2]).
    v-addr2 = trim(cif.addr[2]).
    v-job = trim(cif.ref[8]).
    v-teld = trim(cif.tel).
    v-telr = trim(cif.tlx).
    v-tels = trim(cif.fax).
    */
end.

find first cif where cif.cif = v-cif no-lock no-error.
if avail cif then v-bin = cif.bin.

find first lon where lon.lon = v-lon no-lock no-error.
find first loncon where loncon.lon = lon.lon no-lock no-error.
if avail loncon then v-dog = loncon.lcnt.
find first crc where crc.crc = lon.crc no-lock no-error.
if avail crc then v-crc_val = crc.code.
else do:
    message "Ошибка определения валюты кредита" view-as alert-box error.
    return.
end.
if lon.crc = 1 then v-sum_val_label = "Сумма.(вал.кредита)..:".
else v-sum_val_label = "Сумма.(" + v-crc_val + ")..........:".
v-loncrc = crc.code.
v-opnamt = lon.opnamt.
v-iik_val = lon.aaa.
v-iik_val_lab = "ИИК.........:".



if lon.crc <> 1 then do:
  /*счет кассы в пути для погашения кредита в валюте кредита*/
  run get100200arp(input g-ofc, input lon.crc, output v-yn, output s_account_b1, output v-err).
  if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
  do:
    v-err = not v-err.
	message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
		"произошла ошибка!" view-as alert-box error.
    return.
  end.

  if v-yn then do /*касса в пути*/:
	s_account_a = "".
  end.
  else /*касса*/
  do:
	s_account_a = string(c-gl).
	s_account_b1 = "".
  end.

 /*счет кассы в пути для пени в тенге*/
  run get100200arp(input g-ofc, input 1, output v-yn, output s_account_b2, output v-err).

  if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
  do:
    v-err = not v-err.
	message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
		"произошла ошибка!" view-as alert-box error.
    return.
  end.

  if not v-yn then	s_account_b2 = "".

end.
else do:
  run get100200arp(input g-ofc, input 1, output v-yn, output s_account_b2, output v-err).
  if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
  do:
    v-err = not v-err.
	message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
		"произошла ошибка!" view-as alert-box error.
    return.
  end.

  if v-yn then do /*касса в пути*/:
	s_account_a = "".
	s_account_b1 = s_account_b2.
  end.
  else /*касса*/
  do:
	s_account_a = string(c-gl).
	s_account_b2 = "".
	s_account_b1 = "".
  end.
end.

run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-od).
run lonbalcrc('lon',lon.lon,g-today,"2,4,9",yes,lon.crc,output v-prc).
run lonbalcrc('lon',lon.lon,g-today,"5,16",yes,1,output v-pen).
run lonbalcrc('cif',v-iik_val,g-today,"1",yes,lon.crc,output v-sum_aaa_val).
v-sum_aaa_val = - v-sum_aaa_val.

if lon.crc <> 1 then do:
    v-iik_kzt = pkanketa.aaa.
    v-iik_kzt_lab = "ИИК.........:".
    v-crc_kzt = "KZT".
    run lonbalcrc('cif',v-iik_kzt,g-today,"1",yes,1,output v-sum_aaa_kzt).
    v-sum_aaa_kzt = - v-sum_aaa_kzt.
end.

find last ln%his where ln%his.lon  = lon.lon and ln%his.intrate > 0 no-lock no-error.
if avail ln%his then v-intrate = ln%his.intrate.
                else v-intrate = lon.prem.

displ v-cif /*v-rnn*/ v-bin v-fio v-iik_val_lab v-iik_kzt_lab v-iik_val v-iik_kzt v-sum_aaa_val v-sum_aaa_kzt v-addr1 v-teld v-addr2 v-tels v-job v-telr v-dog v-crc_val v-crc_kzt v-loncrc v-opnamt v-od v-prc v-pen v-code v-codename v-sum_val_label v-sum_val v-sum_kzt v-ja with frame pkcas.
/* pause 0. */

find cif where cif.cif = v-cif no-lock no-error.
if (num-entries(cif.dnb,'|') = 3) or (num-entries(cif.dnb,'|') > 3 and trim(entry(4,cif.dnb,'|')) = '') then do:
    if trim(entry(3,cif.dnb,'|')) <> '' then do:
        v-buff = cif.dnb.
        v-note = trim(entry(3,cif.dnb,'|')).
        v-resn = ''.
        displ v-note with frame omkq.
        update v-resn with frame omkq.
        do transaction:
            find current cif exclusive-lock.
            cif.dnb = entry(1,v-buff,'|') + '|' + entry(2,v-buff,'|') + '|' + entry(3,v-buff,'|') + "|(" + g-ofc + ') ' + v-resn.
            find current cif no-lock.
            hide frame omkq.
        end.
    end.
end.

/*
if lon.rdt >= 06/18/2009 then
    message skip "Обратитесь к менеджеру для подписания доп. соглашения!" skip(1) view-as alert-box information.
*/
if v-joudoc <> "" then do:
enable all with frame fr1 centered overlay top-only.
wait-for window-close of frame fr1.
hide frame fr1.
end.
update v-code with frame pkcas.
find first t-ln where t-ln.code = string(v-code) no-lock no-error.
if avail t-ln then v-codename = "(" + t-ln.name + ")".
displ v-codename with frame pkcas.

if v-code = 1 or v-code = 2 then do:

    /***************************** ПОГАШЕНИЕ **************************************************************/

    run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
    run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
    run lonbalcrc('lon',lon.lon,g-today,"4,9",yes,lon.crc,output v-bal9).
    run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2fact).

    find last cls where cls.whn < g-today and cls.del no-lock no-error. /* последний рабочий день перед g-today */
    dat_wrk = cls.whn.

    if g-today > lon.duedt then do:
        v-sum_val = v-bal1 + v-bal7 + v-bal2fact + v-bal9.
        v-sum_kzt = v-pen.

        for each bxcif where bxcif.cif = v-cif no-lock:
            v-sum_val = v-sum_val + bxcif.amount.
        end.
    end.
    else do: /* -------------------- стандартный расчет ------------------ */

        v-datnextpay = ?.
        find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > dat_wrk no-lock no-error.
        if avail lnsch then do:
            v-p1 = lnsch.stval.
            v-datnextpay = lnsch.stdat.
        end.

        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
        if avail lnsci then do:
            if v-datnextpay <> ? then do:
                if lnsci.idat < v-datnextpay then do:
                    v-p1 = 0.
                    v-datnextpay = lnsci.idat.
                end.
            end.
            else v-datnextpay = lnsci.idat.

            if lnsci.idat > v-datnextpay then v-p2 = 0.
            else v-p2 = lnsci.iv-sc.
        end.

        if v-datnextpay = ? then do:
            message " Не найдена следующая запись по графику выплат! " view-as alert-box error.
            return.
        end.

        v-bal_com = 0. v-bal_compr = 0.
        if lon.plan = 5 or (lon.plan = 4 and v-p1 > 0) then do:
	        find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = v-cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
	        if avail tarifex2 then v-bal_com = tarifex2.ost.
	    end.
        for each bxcif where bxcif.cif = v-cif no-lock:
            v-bal_compr = v-bal_compr + bxcif.amount.
        end.

        v-sum_val = v-bal7 + v-bal9 + v-bal_compr.
        v-sum_kzt = v-pen.

        /* рассчитаем сумму полного досрочного погашения */
        /*marinav - 7 уровень учитывался дважды*/
        v-sum_full_val = v-sum_val.
        v-sum_full_kzt = v-sum_kzt.

        if lon.duedt >= g-today then do: /* если срок кредита еще не закончился */

            if lon.plan = 5 then do:
	            find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
	            if avail lnsci then do:
	                v-sum_full_val = v-sum_full_val + v-bal1 + lnsci.iv-sc + v-bal_com.
	                v-dat3m = lnsci.idat.
	                /* учет 3-хмесячного моратория */
	                find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
	                if avail lnsci and lnsci.idat > v-dat3m then v-sum_full_val = v-sum_full_val + lnsci.iv-sc + v-bal_com.
	                find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
	                if avail lnsci and lnsci.idat > v-dat3m then v-sum_full_val = v-sum_full_val + lnsci.iv-sc + v-bal_com.
	                find next lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock no-error.
	                if avail lnsci and lnsci.idat > v-dat3m then v-sum_full_val = v-sum_full_val + lnsci.iv-sc + v-bal_com.
	            end.
	        end.
	        else if lon.plan = 4 then do:
	            find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
	            if avail lnsci then v-sum_full_val = v-sum_full_val + v-bal1 + lnsci.iv-sc.
	            else v-sum_full_val = v-sum_full_val + v-bal1 + v-bal_com.
	        end.

        end.
        /* конец расчета суммы полного досрочного погашения */

        if v-code = 1 then do:

            if lon.prem = 0 then do:
                choice = no.
                message "По данному кредиту приостановлено начисление процентов.~nОбратитесь в Отдел Мониторинга Кредитов.~nПродолжить?"
                        view-as alert-box question buttons yes-no title " Внимание! " update choice.
                if not choice then return.
            end.

            v-sum_pl = v-p1 + v-p2 + v-bal_com.
            if v-sum_val = 0 then do: /* просрочки нет */
                v-sum_val = v-sum_pl.
            end.
            else do: /* просрочка есть */
                if v-datnextpay <= g-today then v-sum_val = v-sum_val + v-sum_pl.
                else
                if v-datnextpay - g-today <= 3 then do:
                    choice = yes.
                    message "Дата ближайшего погашения по графику " + string(v-datnextpay,"99/99/9999") + ".~nЖелаете оплатить следующую сумму по графику?"
                            view-as alert-box question buttons yes-no title " Внимание! " update choice.
                    if choice then v-sum_val = v-sum_val + v-sum_pl.
                end.
            end.

        end. /* if v-code = 1 */

        if v-code = 2 then do:

            v-choice = no.
            if lon.prem = 0 then do:
                choice = no.
                message "По данному кредиту приостановлено начисление процентов.~nОбратитесь в Отдел Мониторинга Кредитов.~nПродолжить?"
                        view-as alert-box question buttons yes-no title " Внимание! " update choice.
                v-choice = choice.
                if not choice then return.
            end.

            v-sum_val = v-sum_full_val.

        end. /* if v-code = 2 */

    end. /* конец стандартного расчета */

    if lon.crc = 1 then assign v-sum_val = v-sum_val + v-sum_kzt
                               v-sum_kzt = 0.

    if v-sum_val + v-sum_kzt <= 0 then do:
        message "Ошибка определения суммы к оплате.~nОбратитесь пожалуйста в Отдел Мониторинга Кредитов." view-as alert-box buttons ok title " Ошибка! ".
        return.
    end.
    else do:
        if v-sum_aaa_val + v-sum_aaa_kzt > 1 then do:
            choice = yes.
            message "Учесть остаток на текущем счету?" view-as alert-box question buttons yes-no title " Внимание! " update choice.
            if choice then do:
                if v-sum_aaa_val >= v-sum_val and v-sum_aaa_kzt >= v-sum_kzt then do:
                    message "Остаток на текущем счете больше суммы платежа." view-as alert-box buttons ok title " Внимание! ".
                    return.
                end.
                else do:
                    if v-sum_aaa_val < v-sum_val then v-sum_val = v-sum_val - v-sum_aaa_val. else v-sum_val = 0.
                    if v-sum_aaa_kzt < v-sum_kzt then v-sum_kzt = v-sum_kzt - v-sum_aaa_kzt. else v-sum_kzt = 0.
                end.
            end.
        end.
    end.

    v-sum_val_old = v-sum_val.
    v-sum_kzt_old = v-sum_kzt.

    v-sum_val = sumround(v-sum_val).
    v-sum_kzt = sumround(v-sum_kzt).
    displ v-sum_val with frame pkcas.
    if lon.crc <> 1 then displ v-sum_kzt with frame pkcas.

    /* позволить редактировать сумму только если это погашение очередного платежа или полное досрочное погашение при нулевой ставке */
    /*if (v-code = 1) or (v-code = 2 and lon.prem = 0 and v-choice) then*/
    update v-sum_val with frame pkcas.
    if lon.crc <> 1 then update v-sum_kzt with frame pkcas.

    /* проверим, если погашение по графику и сумма больше суммы полного досрочного погашения */
    if v-datnextpay < lon.duedt then do: /* если не последнее погашение */
        if v-code = 1 and v-sum_val >= v-sum_full_val then do:
            message "Введенная сумма больше или равна сумме полного досрочного погашения" view-as alert-box buttons ok title " Внимание! ".
            return.
        end.
    end.

    v-ja = no.
    update v-ja with frame pkcas.

    if v-ja then do:

        find first sysc where sysc.sysc = "rkcout" no-lock no-error.
        if not avail sysc then do:
            message "Не определен справочник rkcout~nТранзакция не проведена" view-as alert-box warning.
            return.
        end.
        else
        if sysc.loval then do:
            message "Погашение кредитов производится через кассу РКЦ~nТранзакция не проведена" view-as alert-box warning.
            return.
        end.

        do transaction:

            if v-code = 1 then do:
                if v-sum_val_old = v-sum_val then v-glrem = "Оплата ежемесячного платежа по Договору займа N " + v-dog.
                if v-sum_val_old > v-sum_val then v-glrem = "Частичная оплата ежемесячного платежа по Договору займа N " + v-dog.
                if v-sum_val_old < v-sum_val then v-glrem = "Ежемес. платеж на сумму " + trim(string(v-sum_val_old,">>>,>>>,>>>,>>9.99")) + " " + v-crc_val + " и оплата в счет следующих погашений на сумму " + trim(string(v-sum_val - v-sum_val_old,">>>,>>>,>>>,>>9.99")) + " " + v-crc_val + " по Договору займа N " + v-dog.
            end.

            if v-code = 2 then v-glrem = "Досрочное погашение по Договору займа N " + v-dog.

            if v-sum_val > 0 then do:
                if s_account_a = string(c-gl) and s_account_b1 = '' then do:
                    v-tmpl = "jou0004".
                    v-param = "" + vdel +
                              string(v-sum_val) + vdel +
                              string(lon.crc) + vdel + /* валюта */
                              v-iik_val + vdel +
                              v-glrem + vdel +
                              "1" + vdel + /* резидент */
                              "9" + vdel + /* сектор экономики - домашнее хоз-во */
                              if lon.gl = 141120 then "421" else "423". /* код назначения платежа */
                    v-param = v-param + vdel + string(v-sum_val).
                end.
                else do:
                    v-tmpl = "jou0020".
                    v-param = "" + vdel +
                              string(v-sum_val) + vdel +
                              string(lon.crc) + vdel + /* валюта */
                              s_account_b1 + vdel +
                              v-iik_val + vdel +
                              v-glrem + vdel +
                              "1" + vdel + /* резидент */
                              "9" + vdel + /* сектор экономики - домашнее хоз-во */
                              if lon.gl = 141120 then "421" else "423". /* код назначения платежа */
                    v-param = v-param + vdel + string(v-sum_val).
                end.

                s-jh = 0.
                run trxgen (v-tmpl, vdel, v-param, "cif", v-iik_val, output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    message rdes.
                    pause 1000.
                    next.
                end.

                run jou. /* создадим jou-документ */
                v_doc = return-value.
                find first jh where jh.jh = s-jh exclusive-lock.
                jh.party = v_doc.

                if jh.sts < 5 then jh.sts = 5.
                for each jl of jh:
                    if jl.sts < 5 then jl.sts = 5.
                end.
                find current jh no-lock.

                run setcsymb (s-jh, 090). /* проставим символ кассплана */

                find first joudoc where joudoc.docnum = v_doc no-error.
                if avail joudoc then do:
                   joudoc.info = v-fio .
                   if num-entries(trim(cif.pss),",") > 1 or num-entries(trim(cif.pss)," ") <= 1 then joudoc.passp = trim(cif.pss).
                   else joudoc.passp = entry(1,trim(cif.pss)," ") + "," + substring(trim(cif.pss),index(trim(cif.pss)," "), length(cif.pss)).
                   /*joudoc.perkod = v-rnn.*/
                   joudoc.perkod = v-bin.
                   joudoc.rescha[1] = "3-2-1-6".
                end.

                /* message " jh=" jh.jh " jou=" jh.party " " view-as alert-box buttons ok. */

                if v-noord = no then run vou_bank(0).
                else run printord(s-jh,"").

            end.

            if v-sum_kzt > 0 then do:
                v-glrem = "Оплата пени по Договору займа N " + v-dog.
                if s_account_a = string(c-gl) and s_account_b2 = '' then do:
                    v-tmpl = "jou0004".
                    v-param = "" + vdel +
                              string(v-sum_kzt) + vdel +
                              "1" + vdel + /* валюта */
                              v-iik_kzt + vdel +
                              v-glrem + vdel +
                              "1" + vdel + /* резидент */
                              "9" + vdel + /* сектор экономики - домашнее хоз-во */
                              if lon.gl = 141120 then "421" else "423". /* код назначения платежа */
                    v-param = v-param + vdel + string(v-sum_kzt).
                end.
                else do:
                    v-tmpl = "jou0020".
                    v-param = "" + vdel +
                              string(v-sum_kzt) + vdel +
                              "1" + vdel + /* валюта */
                              s_account_b2 + vdel +
                              v-iik_kzt + vdel +
                              v-glrem + vdel +
                              "1" + vdel + /* резидент */
                              "9" + vdel + /* сектор экономики - домашнее хоз-во */
                              if lon.gl = 141120 then "421" else "423". /* код назначения платежа */
                    v-param = v-param + vdel + string(v-sum_kzt).
                end.
                s-jh = 0.
                run trxgen (v-tmpl, vdel, v-param, "cif", v-iik_kzt, output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    message rdes.
                    pause 1000.
                    next.
                end.

                run jou. /* создадим jou-документ */
                v_doc = return-value.
                find first jh where jh.jh = s-jh exclusive-lock.
                jh.party = v_doc.

                if jh.sts < 5 then jh.sts = 5.
                for each jl of jh:
                    if jl.sts < 5 then jl.sts = 5.
                end.
                find current jh no-lock.

                run setcsymb (s-jh, 090). /* проставим символ кассплана */

                find first joudoc where joudoc.docnum = v_doc no-error.
                if avail joudoc then do:
                   joudoc.info = v-fio .
                   if num-entries(trim(cif.pss),",") > 1 or num-entries(trim(cif.pss)," ") <= 1 then joudoc.passp = trim(cif.pss).
                   else joudoc.passp = entry(1,trim(cif.pss)," ") + "," + substring(trim(cif.pss),index(trim(cif.pss)," "), length(cif.pss)).
                   /*joudoc.perkod = v-rnn.*/
                   joudoc.perkod = v-bin.
                   joudoc.rescha[1] = "3-2-1-6".
                end.

                if v-noord = no then run vou_bank(0).
                else run printord(s-jh,"").

            end.

        end. /* transaction */

        /*
        возможность рефинансирования
        run pkrefin(v-rnn, v-lon, -1, output v-respr, output v-refsum, output v-numpr, output v-maxpr).
        if v-respr = 0 then message " Возможно рефинансирование кредита ~n Сумма рефинансирования KZT " + trim(string(v-refsum,">>>,>>>,>>>,>>9.99")) view-as alert-box information.
        */

    end. /* if v-ja */

    /***************************** ПОГАШЕНИЕ end ***********************************************************/

end. /* if v-code = 1 or v-code = 2 */
else do:

    /***************************** ВЫДАЧА ******************************************************************/
    if not avail pkanketa then do:
        message " Не найдена анкета БД! " view-as alert-box buttons ok title " Ошибка! ".
        return.
    end.

    if s-ourbank <> "txb00" then do:
        message " На данный момент выдачи в этом пункте производятся только в Алматы! " view-as alert-box error buttons ok.
        return.
    end.

    v-sum_val = pkanketa.sumq.
    if v-sum_val <= 0 then do:
        message " Ошибка определения суммы к выдаче! " view-as alert-box buttons ok title " Ошибка! ".
        return.
    end.
    if v-sum_aaa_val < v-sum_val then do:
        message " На текущем счете нехватка средств для выдачи кредита! " view-as alert-box buttons ok title " Ошибка! ".
        return.
    end.

    displ v-sum_val with frame pkcas.
    do transaction:
        update v-sum_val with frame pkcas.
        if v-sum_val > pkanketa.sumq then do:
            message " Введенная сумма превышает сумму к выдаче! ".
            undo, retry.
        end.
    end.


    /* биометрия */
    message " Сейчас будет произведена сверка отпечатков пальцев! " view-as alert-box buttons ok title " Внимание! ".
    run fngrcompare(pkanketa.cif,"clnchf",output res-compare).
    case res-compare:
        when 1 then do:
            message " Сверка не прошла " view-as alert-box error.
            return.
        end.
        when 0 then message " Сверка прошла успешно " view-as alert-box information.
        when 2 then do:
            message " Произошла неопределенная ошибка сверки отпечатков пальцев, " skip " либо сканирование было принудительно прекращено! " view-as alert-box.
            return.
        end.
    end case.
    run biosaveres(pkanketa.cif,"clnchf",res-compare,no).
    /* биометрия - end */

    v-ja = no.
    update v-ja with frame pkcas.

    if v-ja then do:

        find first sysc where sysc.sysc = "rkcout" no-lock no-error.
        if not avail sysc then do:
            message "Не определен справочник rkcout~nТранзакция не проведена" view-as alert-box warning.
            return.
        end.
        else
        if sysc.loval then do:
            message "Выдача кредитов производится через кассу РКЦ~nТранзакция не проведена" view-as alert-box warning.
            return.
        end.

        do transaction:

            v-glrem = "Выплата по Договору займа N " + v-dog.

            if s_account_a = string(c-gl) and s_account_b1 = '' then do:
                /* счет -> касса */
                v-tmpl = "jou0016".
                v-param = "" + vdel +
                          string(v-sum_val) + vdel +
                          string(lon.crc) + vdel + /* валюта */
                          v-iik_val + vdel +
                          v-glrem + vdel +
                          "321" + vdel + /* код назначения платежа */
                          string(0) + vdel + /* сумма с 9го уровня */
                          "1". /* валюта */.
            end.
            else do:
                v-tmpl = "jou0028".
                v-param = "" + vdel +
                          string(v-sum_val) + vdel +
                          string(lon.crc) + vdel + /* валюта */
                          v-iik_val + vdel +
                          s_account_b1 + vdel +
                          v-glrem + vdel +
                          "321". /* код назначения платежа */
                /* v-param = v-param + vdel + string(v-sum) + vdel + "1". */
            end.

            s-jh = 0.
            run trxgen (v-tmpl, vdel, v-param, "cif", v-iik_val, output rcode, output rdes, input-output s-jh).

            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                next.
            end.

            /* message s-jh view-as alert-box buttons ok. */

            run jou. /* создадим jou-документ */
            v_doc = return-value.
            find first jh where jh.jh = s-jh exclusive-lock.
            jh.party = v_doc.

            if jh.sts < 5 then jh.sts = 5.
            for each jl of jh:
                if jl.sts < 5 then jl.sts = 5.
            end.
            find current jh no-lock.

            run setcsymb (s-jh, 290). /* проставим символ кассплана */

            /* message " jh=" jh.jh " jou=" jh.party " " view-as alert-box buttons ok. */

        end. /* transaction */

        if v-noord = no then run vou_bank(0).
        else run printord(s-jh,"").

    end. /* if v-ja */

    /***************************** ВЫДАЧА end **************************************************************/

end.


