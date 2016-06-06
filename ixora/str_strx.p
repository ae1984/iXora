/* str_strx.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        счета НДС
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * BASES
        BANK COMM
 * MENU
        1-4-1-6
 * AUTHOR
        07.04.1999 pragma
 * CHANGES
        04.03.2002 ...     - настройка принтера из OFC
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
        02.10.2003 nataly  - была добавлена опция вывода счетов-факутр для для кода кода комисии или для всех кодов ('ALL')
                             также подключен справочник кодов комисиий h-tarif.p
        10.10.2003 nadejda - добавлен поиск кода комиссии в jh.party, если нет joudoc
        14.10.2003 nadejda - разрешена печать документа, если в проводке не найден код комиссии (cocode = "")
        01.01.2004 nadejda - изменила ставку НДС - актуальную брать из sysc, остальные зашиты в зависимости от даты
        14.01.2004 nadejda - добавила к определению НДС по дате поиск текущей ставки тоже
        19.08.2004 dpuchkov - раскомментарил отображение номера счёт фактуры при печати по F1 (до этого работало только по ENTER)
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        21/01/05 sasco поиск свидетельства НДС через sysc."NDSSVI"
        24/01/05 kanat добавил формат на вывод информации по НДС
        12/07/2005 kanat убрал привязку по всем счетам - фактурам к г. Алматы
        14.07.2007 dpuchkov добавил in_account = b-involist.acc строка 766. в мемориальных ордерах проставлялся один и тот же счет
        19/10/2009 madiyar - номер фактуры
        02.02.10   marinav - увеличен формат номера фактуры
        02.02.10 marinav - расширение поля счета до 20 знаков
        15.03.10 marinav - после 15 марта в номер добавлять код филиала
        08.06.10 marinav - в шапку добавлен БИН и счет
        07/06/11 dmitriy - добавлен перевод на казахский язык
                         - изменена форма счет-фактуры
                         - добавлен акт выполненных работ
                         - формирование реестра мемориальных ордеров в отдельном файле
                         - добавлена возможть формирования счет фактуры по счетам с НДС и БЕЗ НДС
        22/07/11 dmitriy - добавил вывод только одного номера СФ за одну дату по счетам с НДС
        25/07/11 dmitriy - убрал из строки с адресом клиента "(KZ)" и ",,"
        28/07/11 dmitriy - для ИП forma-sobstv = ИП, для остальных из справочника
        03/08/11 dmitriy - убрал в html лишнюю "
        26/08/11 dmitriy - расширил формат вывода поля "покупатель" до 110 знаков
        13/09/11 dmitriy - добавил шаблон sf-akt.htm для формирования акта вып.работ
        26/09/11 dmitriy - убрал ограничения по формату на назначение платежа
                         - изменил акт вып.работ, изменил шаблон sf-akt.htm
        04/11/11 dmitriy - изменил поиск имени директора филиала (если вместо директора был и.о., все равно подтягивалось имя директора)
        14/12/11 dmitriy - исправил наименование покупателя (ИП) при формировании СФ для одной транзакции
        06/01/12 dmitriy - исправил имя директора при формировании СФ для одной транзакции
        15/03/12 id00810 - добавила v-bankname для печати
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        04/05/2012 evseev - название филиала из banknameDgv
        07/05/2012 evseev - подключил replacebnk.i
        17/05/2012 evseev - тз1362
        15/06/2012 Luiza  - исправила условие поиска курса в crchis:
                            было - find last crchis where crchis.crc eq involist.crc and crchis.rdt <= involist.jdt no-lock.
                            исправила на find last crchis where crchis.crc eq involist.crc and crchis.rdt < involist.jdt no-lock.
        27/06/2012 dmitriy - добавил новый акт вып.работ только для филиала ВКО, на остальных формируется без изменений
        28/06/2012 dmitriy - для акта по одной операции (на Филиале ВКО) добавил шаблон SFforVKO.htm
        18/10/2012 Luiza  - новая форма счет фактур
        23/10/2012 Luiza  - исправила процедуру копирование логотипа
        28.11.2012 damir - Внедрено Т.З. № 1588.
        26.12.2012 damir - Внедрено Т.З. № 1624.
        02.01.2013 damir - Переход на ИИН/БИН.
        24/05/2013 Luiza - ТЗ 1719 замена текста РНН на ИИН/БИН при просмотре на экране

*/
{mainhead.i}

/* поиск свид-ва НДС */
{ndssvi.i}
{comm-txb.i}
{replacebnk.i}
{chbin.i}

def var v-ln as log .
def var vans as log .
def var v-tmp as cha.

define variable s-hacc like aaa.aaa initial ?.
define variable s-tarif like tarif2.kod initial ?.
def new shared var s-cif like cif.cif.
def new shared var v-point like point.point.
def var v-regno like point.regno.
def var in_cif like cif.cif.
def var in_account like aaa.aaa.
def var v-nazn1 as char /*format 'x(56)'*/.
def var s-sumv like jl.dam.
def var in_command as char init "prit".
def var in_destination as char init "rpt.img".
def var MyMonths as char extent 12
init ["января","февраля","марта","апреля","мая","июня","июля","августа",
"сентября","октября","ноября","декабря"].

def var partkom as char.
def var v-datword as char format "X(30)".
def var v-rate as deci.
def buffer b-jh for jh.
def buffer b-jl for jl.
def buffer c-aaa for aaa.

def var s-jh like jh.jh.
def var s-jl like jl.ln.
def var s-date as date format "99/99/9999".
def var s-jdt as date format "99/99/9999".
def var s-glcom like gl.gl.
def var s-faktur as inte format "999999999".
def var v-sumword as char format "X(60)".
def var sumword1 as char.
def var sumword2 as char.
def var vcrc1 as char. def var vcrc2 as char.
def var v-bankcode as char format "X(9)" init "XXX".
def var v-ordnum as integer.
def var v-fakturnum as integer.
def var v-platcode as char format "X(15)".
def var s-amt like jl.dam.
def var v-amt like jl.dam.
def var s-gl like gl.gl.
def var s-sts as char format "X(3)".
def var m-rtn as log.
def var ipos as integer init 0.
def var cocode like joudoc.comcode.
def var iii as integer.
def var v-sln as char.
def var v-jlln as int.

def var v-cifname as char format "x(40)".
def var v-txb as char.

define variable s-trx like jl.trx.
define variable v-nazn as character /*format 'x(56)'*/.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bankbin = sysc.chval.

def var forma-sobstv as char.
def var ofc-name as char.
def var buh-name as char.
def var director-name as char.
def var sum_sum as decimal.
def var ru_akt as char extent 13.
def var kz_akt as char extent 13.
def var bbin as char.
def var kzname as char.
def var k as integer init 0.
def var sf-nomer as integer format "999999999".
def var dat-pvn as date.
def var cif-addr as char.
def var v-str as CHAR.
def var v-str1 as CHAR.
def var v-ofile as char.
def var v-ifile as char.
def var v-bankname as char format 'x(15)' no-undo.
def var v-operdt as date.
def var v-filname as char.
def var v-jlrem as char.

/*Luiza*/
def var l-cf as char.
def var l-cmp as char.
def var l-rnn as char.
def var vadd1 as char.
def var l-ras as char.
def var l-bb as char.
def var l-cifname as char.
def var hhh1 as char.
def var hhh2 as char.
def var hhh3 as char.
def var l-cifregdt as char.
def var l-table as CHAR .
def var r-table as CHAR .
def var l-cifbin as char.
def var l-naz as char.
def var l-ed as char.
def var cif1 as char.
def var cif2 as char.
def var bank1 as char.
def var bank2 as char.
def var vnds as char.
def var l-kol as int.
def var l-color as int.
def buffer b-kjl for jl.
def var l-cmpcode as int.
find first cmp no-lock.
l-cmpcode = cmp.code.
def var l-client as int.
define stream l-out.
define stream r-out.
define stream l-out2.
define stream h-out.
define var a as int.
def var v-prizn as char.
def var v-txbase as char.

def temp-table t-files
  field name as char format "x(70)"
  field fname as char.

def var v-bnkcmp as char.
def var v-bnkbin as char.
find first cmp no-lock no-error.
if avail cmp then v-bnkcmp = trim(cmp.addr[2]).
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bnkbin = trim(sysc.chval).


function test_email RETURNS logical (input em as char).
def var ret as log init true.
def var err as char init ',~!@#$%^&*()=+\/?|<>:;`'.
def var i as integer.
err = err + "'".
err = err + '"'.

 do i=1 to length(err):
    if index(err,substr(em,i,1)) > 0 then ret = false.
   i = i + 1.
 end.
 return ret.
end.
/*-----------------------------------------------------*/


define stream m-out.
define stream v-out.
define stream s-out.


def var v-gl as int.
{st_chkcif.i}

form
        s-cif  label    "  Код"
          help " Код клиента (F2 - поиск по счету, наименованию и т.д)"
          validate (chkcif (s-cif), v-msgerr)
          skip
        v-cifname label "  Имя" skip
        s-hacc   label  " Счет"
          help " Номер текущего счета клиента (F2 - список счетов)"
          validate (can-find(aaa where (aaa.aaa = s-hacc and aaa.cif = s-cif) no-lock)
                        or s-hacc eq "ALL" or s-hacc eq "", " Нет такого счета !!!")
        s-tarif   label  " Код комиссии"
          help " Код комисии "
          validate (can-find(tarif2 where (tarif2.num + tarif2.kod = s-tarif ) and tarif2.stat = 'r' no-lock)
                        or s-tarif eq "ALL", " Нет такого кода комисии  !!!")
with side-label row 3 centered frame cif.


{involist.i "NEW SHARED"}

def buffer b-involist for involist.
def buffer c-involist for involist.
def var sss1 like jl.dam.
def var sss2 like jl.dam.
def var sss3 like jl.dam.
def var s-num like b-involist.num.
def var s-num1 as int init 1.
def var s-num2 as int init 1.

def var v-nds% as decimal.
def var v-pvn  as logical.
def var v-selpvn as int.

function ddd returns char (input p1 as date).
    def var res as char.
    res = substring(string(p1),1,2).
    if substring(string(p1),4,2) = "01" then res = res + " января " .
    if substring(string(p1),4,2) = "02" then res = res + " февраля " .
    if substring(string(p1),4,2) = "03" then res = res + " марта " .
    if substring(string(p1),4,2) = "04" then res = res + " апреля " .
    if substring(string(p1),4,2) = "05" then res = res + " мая " .
    if substring(string(p1),4,2) = "06" then res = res + " июня " .
    if substring(string(p1),4,2) = "07" then res = res + " июля " .
    if substring(string(p1),4,2) = "08" then res = res + " августа " .
    if substring(string(p1),4,2) = "09" then res = res + " сентября " .
    if substring(string(p1),4,2) = "10" then res = res + " октября " .
    if substring(string(p1),4,2) = "11" then res = res + " ноября " .
    if substring(string(p1),4,2) = "12" then res = res + " декабря " .
    res = res + string(year(p1)).
    return res.
end function.

def frame f-selpvn
v-selpvn label "1 - с НДС, 2 - без НДС, 3 - Все"
with row 15 centered overlay side-labels.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds% = sysc.deval.

find point where point.point eq v-point no-lock no-error.
  if available point then v-regno = point.regno.
  else do:
   find first point no-lock no-error.
   if available point then v-regno = point.regno.
   else v-regno = "".
  end.

do while index("1234567890", substring(v-regno, 1, 1)) eq 0:
v-regno = substring(v-regno, 2).
end.

i = 1.
do while index("1234567890", substring(v-regno, i, 1)) ne 0:
i = i + 1.
end.
v-regno = substring(v-regno, 1, i).

find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
if available sysc then v-bankcode = /*substring(trim(sysc.chval), 7, 3)*/ sysc.chval.

find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

do transaction:
   update s-cif with frame cif.

   find cif where cif.cif = s-cif no-lock no-error.

   display trim(trim(cif.prefix) + " " + trim(cif.name)) @ v-cifname with frame cif.
   pause 0.

   in_cif = s-cif.

   v-platcode = cif.jss.

   s-hacc = "ALL".
   update s-hacc with frame cif.

   in_account = s-hacc.

   s-tarif = "ALL".
   update s-tarif with frame cif.
end.

def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999".
form "Отчетный период с " dat1 " по " dat2 with no-label centered.

do on error undo, retry on endkey undo, return.
   dat1 = g-today .
   dat2 = g-today .
   update dat1 validate(dat1 <= g-today, "Начало периода не может быть позже чем сегодня").
   update dat2 validate(dat2 <= g-today and dat2 >= dat1, "Конец периода не может быть позже чем сегодня/начало периода").
end.

for each involist:
    delete involist.
end.
i = 0.

find first jl no-lock no-error.
if available jl
then start_dt = jl.jdt.
find first arcmap where arcmap.path eq pdbname("bank") no-lock no-error.
if available arcmap
then start_dt = max(arcmap.d_from, start_dt).
else do:   /* start_dt for ignored acrmap mode */
     find sysc where sysc.sysc eq "BEGDAY" no-lock no-error.
     if available sysc and sysc.daval lt start_dt
     then start_dt = sysc.daval.
end.

  if dat1 < start_dt
  then do:
        {strfarc.i}
  end.

/*-------------------Межфилиальные платежи------------------------------*/
{Inter-Branch.i "new"} /*shared parameters*/

run Inter-Branch.
/*----------------------------------------------------------------------*/

FOR EACH C-AAA WHERE C-AAA.CIF EQ S-CIF AND (C-AAA.AAA EQ S-HACC OR
    S-HACC EQ "" OR S-HACC EQ "ALL") NO-LOCK:
    IN_ACCOUNT = C-AAA.AAA.
    for each b-jl where b-jl.acc eq in_account
        and b-jl.jdt >= max(dat1, start_dt)
        and b-jl.jdt <= min(dat2, g-today)  and b-jl.dc = "D"  no-lock:
        find first trxcods where trxcods.trxh eq b-jl.jh and
             trxcods.trxln = b-jl.ln and trxcods.codfr eq "faktura"
             and trxcods.code begins "chg" no-lock no-error .
        if not avail trxcods then next.
        v-tmp = trxcods.code .
        v-ln = false .
        v-sln="".
        v-jlln=0.
        for each trxcods where trxcods.trxh eq b-jl.jh and
                 trxcods.codfr eq "faktura"
                 and trxcods.code = v-tmp no-lock:
          v-sln=v-sln + string(trxcods.trxln) + ",".
        end.

          if  lookup(string(b-jl.ln), v-sln) modulo 2 eq 0
            then v-jlln=integer(entry(lookup(string(b-jl.ln), v-sln) - 1, v-sln)) no-error.
            else v-jlln=integer(entry(lookup(string(b-jl.ln), v-sln) + 1, v-sln)) no-error.
        if error-status:error then v-jlln=0.
        find jl use-index jhln where jl.jh = b-jl.jh and
             jl.ln = v-jlln no-lock no-error.

        if available jl
        then do:
                 cocode = "".
                 find first joudoc where joudoc.jh = jl.jh and joudoc.whn >= dat1 no-lock no-error.
                 if available joudoc then cocode = joudoc.comcode.
                 else do:
                    if jl.who = "BANKADM" then cocode = '106'.
                    else do:
                      find jh where jh.jh = jl.jh no-lock no-error.
                      if jh.party <> "" then cocode = entry(1, jh.party, " ").
                      iii = integer(cocode) no-error.
                      if error-status:error then cocode = "".
                    end.
                 end.

                 find first involist where involist.jh = jl.jh and
                      involist.ln = jl.ln no-lock no-error.
                 if not available involist and
                   ((s-tarif = "ALL") or (cocode = s-tarif))
                 then do:
                      i = i + 1.
                      create involist.
                      involist.amt = abs(jl.dam) + abs(jl.cam).
                      involist.acc = in_account.
                      involist.glcom = jl.gl.
                      involist.dat = g-today.
                      involist.sts = "OOO".
                      involist.who = jl.who.
                      involist.num = i.
                      involist.jh = jl.jh.
                      involist.trx = jl.trx.
                      involist.ln = jl.ln.
                      involist.jdt = jl.jdt.
                      involist.comcode = cocode.
                      involist.crc = jl.crc.
                      involist.rate = 1.
                      if involist.crc ne 1
                      then do:
                           find last crchis where crchis.crc eq involist.crc
                                and crchis.rdt < involist.jdt no-lock.
                           involist.rate = crchis.rate[1] / crchis.rate[9].
                      end.

                      find crc where crc.crc eq involist.crc no-lock.
                      involist.crcode = crc.code.
                      if involist.jdt eq g-today and involist.crc ne 1
                      then do:
                           involist.rate = crc.rate[1] / crc.rate[9].
                      end.

                      involist.amt1 = round(involist.amt * involist.rate, 2).

                      find last fakturis where fakturis.jh eq jl.jh and
                           fakturis.trx = jl.trx and
                           fakturis.ln eq jl.ln  use-index jhtrxln no-lock no-error.
                      if available fakturis
                      then do:
                           involist.sts = fakturis.sts.
                           involist.who = fakturis.who.
                           involist.dat = fakturis.rdt.
                           involist.tim = fakturis.tim.
                           involist.faktura = fakturis.faktura.
                      end.
                 end.
        end.
    end.  /* each b-jl      */
END.   /* FOR EACH C-AAA */

/* ------------------ One Account Browse --------------------- */

define query q-involist for involist.
define browse b-involist query q-involist

display involist.num column-label " N " format "999"
        involist.dat column-label "Дата печ."
        involist.amt column-label "СУММА" format "-z,zzz,zz9.99"
        involist.crcode no-label
        involist.sts column-label "СТС"
        involist.who column-label "Кто"
        involist.comcode column-label "Ком." format "x(3)"
        involist.jdt column-label "Дата опер."
        involist.jh column-label "Проводка" format "99999999"
        involist.ln  column-label "Лин." format "9999"
with 20 down /*separators*/  overlay .

define frame f-involist b-involist with centered row 8 width 85 overlay title
    "Список счетов-фактур: F1 - печать всех, ENTER - печать одного счета".

ON VALUE-CHANGED of b-involist in frame f-involist
DO:
   in_account = involist.acc.
   s-jh = involist.jh.
   s-trx = involist.trx.
   s-jl = involist.ln.
   s-amt = involist.amt1.
   s-sts = involist.sts.
   s-date = involist.dat.
   s-jdt = involist.jdt.
   s-glcom = involist.glcom.
   v-rate = involist.rate.
   v-amt = involist.amt1.
   s-sumv = involist.amt.
   v-prizn = involist.prizn.
   v-txbase = involist.txb.

   find aaa where aaa.aaa eq in_account no-lock.
   hide message no-pause.
   message aaa.gl " : " s-glcom.
END.
ON DEFAULT-ACTION of b-involist in frame f-involist
DO:
      message "Печатать счет-фактуру?" view-as alert-box question buttons Yes-No
           title " ---  Печать счета --- " update vans as log.
   if vans
   then do:

        Run PrintOrder in This-Procedure.
        Run CreateOrderHistory in This-Procedure.
        m-rtn = b-involist:REFRESH() in frame f-involist.

        find current b-involist no-lock no-error.
        if avail b-involist then v-operdt = b-involist.jdt.
   end.
END.

ON GO of frame f-involist
DO:
   Run PrintAllOrg in This-Procedure.
   m-rtn = b-involist:REFRESH() in frame f-involist.
END.

/* --------------- One Account Browse ----------------- */

/* -------------- All Account Browse ------------------ */

define query q-alist for involist.
define browse b-alist query q-alist
display involist.num column-label " N " format "999"
involist.acc column-label "Счет"
involist.amt column-label "СУММА" format "->,>>>,>>9.99"
involist.crcode no-label
involist.sts column-label "СТС"
involist.who column-label "Кто"
involist.comcode column-label "Ком." format "x(3)"
involist.jdt column-label "Дата опер."
involist.jh column-label "Проводка" format "99999999"
involist.ln  column-label "Лин." format "9999"
with 20 down /*separators*/  overlay .

define frame f-alist b-alist with centered row 8 width 95
       title "Список счетов-фактур: F1 - печать всех, ENTER - печать одного счета".

ON VALUE-CHANGED of b-alist in frame f-alist
DO:
  in_account = involist.acc.
  s-jh = involist.jh.
  s-trx = involist.trx.
  s-jl = involist.ln.
  s-amt = involist.amt1.
  s-sts = involist.sts.
  s-date = involist.dat.
  s-jdt = involist.jdt.
  s-glcom = involist.glcom.
  v-rate = involist.rate.
  v-amt = involist.amt1.
  s-sumv = involist.amt.
  v-prizn = involist.prizn.
  v-txbase = involist.txb.

  find aaa where aaa.aaa eq in_account no-lock.
  hide message no-pause. message aaa.gl " : " s-glcom.

END.

ON DEFAULT-ACTION of b-alist in frame f-alist
DO:
  message "Печатать счет-фактуру?" view-as alert-box question buttons Yes-No
          title " ---  Печать счета --- " update vans as log.
  if vans
  then do:
       v-operdt = involist.jdt.
       Run PrintOrder in This-Procedure.
       Run CreateOrderHistory in This-Procedure.
       m-rtn = b-alist:REFRESH() in frame f-alist.
  end.
END.

ON GO of frame f-alist
DO:
  Run PrintAllOrg in This-Procedure.
  m-rtn = b-alist:REFRESH() in frame f-alist.
  in_account = involist.acc.
  s-jh = involist.jh.
  s-trx = involist.trx.
  s-jl = involist.ln.
  s-amt = involist.amt1.
  s-sts = involist.sts.
  s-date = involist.dat.
  s-jdt = involist.jdt.
  s-glcom = involist.glcom.
  v-rate = involist.rate.
  v-amt = involist.amt1.
  s-sumv = involist.amt.
  v-prizn = involist.prizn.
  v-txbase = involist.txb.

  find aaa where aaa.aaa eq in_account no-lock.
  hide message no-pause. message aaa.gl " : " s-glcom.
END.

/* --------------- One Account Browse ----------------- */

if s-hacc eq "ALL" or s-hacc eq "" then do:
     find first involist where substring(involist.sts, 3, 1) = "O"
          no-lock no-error.
     if not available involist then do:
          message "Нет ни одного оригинала" view-as alert-box
                  title "НЕТ ОРИГИНАЛОВ".
          return.
     end.
     open query q-alist for each involist where
          substring(involist.sts, 3, 1) = "O" no-lock.
     enable all with frame f-alist.
     view frame mainhead. view frame cif.
     apply "VALUE-CHANGED" to b-alist in frame f-alist.
            wait-for end-error of frame f-alist /*or go of frame f-alist*/ .
end.
else do:
     find first involist no-lock no-error.
     if not available involist
     then do:
          message "Нет ни одного налогового счета" view-as alert-box
                  title "НЕТ ОПЕРАЦИЙ С НДС".
          return.
     end.
     open query q-involist for each involist no-lock.
     enable all with frame f-involist.
     view frame mainhead. view frame cif.
     apply "VALUE-CHANGED" to b-involist in frame f-involist.
           wait-for end-error of frame f-involist /*or go of frame f-involist*/ .
end.

Procedure PrintOrder:
    l-table = "".
    l-kol = 1.
   find first fakturis where fakturis.jh = s-jh and fakturis.trx = s-trx and
        fakturis.ln = s-jl use-index jhtrxln no-lock no-error.
   if not available fakturis then v-ordnum = next-value(vptrx).  /* Change Sequence */
                             else v-ordnum = fakturis.order.

   output to value(in_destination).
   find first cmp no-lock.

    /*   put skip '"' + trim(cmp.name) + '"' format "X(60)".
       put skip space(30) "МЕМОРИАЛЬНЫЙ ОРДЕР  N " format "X(23)".
       put string(v-ordnum) format "X(15)" space(10) "0401009"  / *string(s-jh)* / .
       put skip space(53) fill("-",15) format "X(15)" space (10)
           fill("-",7) format "X(7)".

       put skip "Плательщик" space(55) "Дебет" space(10) "Сумма".
       put skip space(60) fill("-",33) format "X(33)".
       put skip v-platcode format "X(12)"  " : " + trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(48)" ":"
           space(15) ":" space(15) ":".

       put skip fill("-",60) format "X(60)" ":" space(15) ":" space(15) ":".
       put skip "Банк плательщика" format "X(60)" ":" space(15) ":" space(15) ":".
       put skip space(50) "----------" ":" space(15) ":" space(15) ":".
       put skip cmp.name format "X(50)" ":" v-bankcode format "X(9)"
                ":сч.N " in_account format "X(10)" ":"
                string(s-sumv,"->>>,>>>,>>9.99") format "X(15)" ":".
       put skip fill("-",76) format "X(76)" ":" space(15) ":".

       put skip "Получатель" format "X(60)" "     Кредит     " ":" space(15) ":".
       put skip string(v-regno) format "X(15)" ":" cmp.name format "X(44)" ":"
                space(15) ":" space(15) ":".
       put skip fill("-",60) format "X(60)" ":" space(15) ":" space(15) ":".

       put skip "Банк получателя" format "X(50)" "----------"
           ":" space(15) ":" space(15) ":".
       put skip cmp.name format "X(50)" ":" v-bankcode format "X(9)"
           ":сч.N " if s-glcom ne 0 then string(s-glcom) else "" format "X(10)"
           ":" space(15) ":".
    */

   v-sumword = ''.
   find aaa where aaa.aaa eq in_account no-lock.

   if aaa.crc eq 1 then do:
        vcrc1 = " " + "тенге" + " ".
        vcrc2 = " " + "тиын".
   end.
   else do:
        find crc where crc.crc eq aaa.crc no-lock.
        vcrc1 = " " + crc.code + " ".
        vcrc2 = "".
   end.

   v-nazn = "Назначение платежа: ".

    if v-prizn eq 'FILPAYMENT' then do:
        run CheckFilPay(yes,yes).
    end.
    else do:
        find jh where jh.jh = s-jh no-lock.
        find first jl where jl.jh = s-jh and jl.ln = s-jl no-lock no-error .
        if not avail jl then do:
            message " JL " + string(s-jh) + " Ln= " + string(s-jl) + " не найдена " .
            pause .
            return .
        end.

        if trim(jl.rem[1]) begins "409 -" or trim(jl.rem[1]) begins "419 -"
        or trim(jl.rem[1]) begins "429 -" or trim(jl.rem[1]) begins "430 -" then do:
            v-nazn = v-nazn + jl.rem[1].
        end.
        else if jh.sub = "JOU" then do:
            find first joudoc where jh.ref  = joudoc.docnum no-lock no-error .
            if avail joudoc then
            find tarif2 where tarif2.str5 = joudoc.comcode and tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.
            if not available tarif2 then v-nazn = v-nazn + jl.rem[5].
                            else v-nazn = v-nazn + tarif2.pakalp.
        end.
        else if jh.sub = "RMZ" then do:
            find first remtrz where jh.ref = remtrz.remtrz no-lock no-error .
            if avail remtrz then
            find tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.kont = jl.gl
            and tarif2.stat = 'r' no-lock no-error.
            if not available tarif2 then v-nazn = v-nazn + jl.rem[5].
                            else v-nazn = v-nazn + tarif2.pakalp.
        end.
        else
        v-nazn = v-nazn + jl.rem[5].

        if v-nazn matches "*долг*" then v-nazn1  = substr(v-nazn, 21 + 5) .
                      else v-nazn1  = substr(v-nazn, 21) .

        if trim(v-nazn1) = '' then v-nazn1 = jl.rem[1].

        v-operdt = jl.jdt.
    end.

   if involist.crc > 1 then v-nazn = v-nazn + " курс-"  + string(v-rate).

   if not available fakturis or fakturis.faktura = 0 then v-fakturnum = integer(substring(string(year(g-today), "9999"),3,2) + string(month(g-today),"99") + string(v-ordnum, "99999")).
   else v-fakturnum = integer(string(fakturis.faktura, "999999999")).
   /*после 15 марта в номер добавлять код филиала*/
   if s-jdt > 03/15/2010 then v-txb = substr(comm-txb(),4,2).
                         else v-txb = "  ".

   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'lnopf' no-lock no-error.
   if avail sub-cod then do:
        find first codfr where codfr.codfr = 'lnopf' and codfr.code = sub-cod.ccode no-lock no-error.
           forma-sobstv = /*sub-cod.ccode + " - " +*/ trim(codfr.name[1])/* + " " + trim(cif.name))*/.
   end.
   else  forma-sobstv = trim(cif.prefix) /* + " " + trim(cif.name))*/.
   if trim(cif.prefix) = "ИП" then forma-sobstv = cif.prefix.

   /*find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
   if avail sysc then bbin = sysc.chval.*/

    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc then do:
          kzname = entry(14, sysc.chval, "|") no-error.
        end.

    cif-addr = replace(cif.addr[1], ",,",",").
    cif-addr = replace(cif-addr, "(KZ)","").
                                   /* Change Sequence !!! */

   /*put skip(1) "Согласовано" space(82) "Приложение 2".
   put skip "Министр финансов Республики Казахстан" space(50) "к приказу Министра".
   put skip "____________________М.Есенбаев " space(51) "государственных доходов".
   put skip "'___' ______________2000 г." space(58) "Республики Казахстан".
   put skip space(79) "от '___' __________2000 г.".
   put skip "Председатель Агентства" space(74) "N _______".
   put skip "Республики Казахстан по статистике".
   put skip "____________________А.Смаилов".
   put skip "'___' ______________2000 г.".*/

   put skip(2) space(35) " ШОТ-ФАКТУРА / СЧЕТ-ФАКТУРА N " + string(v-fakturnum, ">99999999") + v-txb format "x(50)".
   put skip space(50) /*s-jdt*/ dat2 format "99/99/9999".
   put skip(1).
   put skip "Жеткізуші / Поставщик : " + trim(cmp.name) format "x(90)".
   put skip "Жеткізушініѕ  тїрєан жерініѕ мекенжайы / адрес места нахождения поставщика: ".
   put skip trim(cmp.addr[1]) format "x(90)".
   put skip "БСН/БИН  " v-bankbin format "X(12)".
   put skip "ЌЌС бойынша есепке ќою туралы кујлік / Свидетельство о постановке на учет по НДС".
   put skip "серия " ndssvi format "x(35)" "г.".
   put skip "Жеткізушініѕ есеп айырысу шоты / Расчетный счет поставщика : " .
       if comm-txb() = 'TXB00' then put " ИИК KZ98125KZT1001300600 ".
                               else put " ИИК KZ33470142860A019800 ".
   if comm-txb() = 'TXB00' then put skip "в ГУ 'Национальный банк РК' БИК NBRKKZKX".
                           else put skip "в АО " replace_bnamebik(v-bankname, dat2) format "x(15)" " БИК " replace_bnamebik(v-bankcode, dat2).
   put skip "Тауарларды (жўмыстарды, ќызметтерді) жеткізу шарты (келісімшарты) / Договор(контракт) на поставку".
   put skip "товаров(работ,услуг) N   б/н , "  cif.regdt format "99/99/9999".
   put skip "Шарт (келісімшарт) бойынша тґлем жасау талаптары / Условия оплаты по договору(контракту) :  безналичный" .
   put skip "Жґнелтетін тауарларды (жўмыстарды, ќызметтерді) жеткізу орны / Пункт назначения поставляемых ".
   put skip "товаров(работ,услуг) " + trim(cif-addr) format "X(110)".
   put skip "                     (мемлекет, аймаќ, облыс, ќала, аудан)/(гос-во,регион,область,город,район)".
   put skip "Сенімхат бойынша жеткізілді / Поставка товаров осуществлена по доверенности N         от ".
   put skip "Жґнелту тјсілі / Способ отправления ".
   put skip "Тауар-кґлік жїк ќўжаты / Товарно-транспортная накладная N           от ".
   put skip "Жїк жґнелтуші / Грузоотправитель ______________________________________________________________".
   put skip "                             (ЖСН/БСН, атауы жјне мекен - жайы)/(ИИН/БИН, наименование и адрес)".
   put skip "Жїк алушы / Грузополучатель _______________________________________________________________ ".
   put skip "                         (ЖСН/БСН, атауы жјне мекен - жайы)/(ИИН/БИН, наименование и адрес)".
   put skip "Алушы / Получатель: " /*trim(trim(cif.prefix) + " " + trim(cif.name))*/ forma-sobstv  + " " + trim(cif.name) format "X(110)".
   put skip "Алушыныѕ тїрєан жерініѕ мекенжайы / адрес места нахождения получателя: ".
   put skip trim(cif-addr) format "X(110)"/* + trim(cif.addr[2])*/  .
   put skip "ЖСН/БСН / ИИН/БИН  " cif.bin format "X(12)".
   put skip "Алушыныѕ есеп айырысу шоты / Расчетный счет получателя N " in_account format "X(20)" " в " + trim(cmp.name) format "X(110)" /*АО " v-bankname*/.
   put skip fill("-", 93) format "X(93)".
   put skip "Р/т:   Тауарлардыѕ   :Ґлшем: Саны  :   Баєасы   :Тауарлардыѕ :  ЌЌС / НДС      :   Барлыќ   : " format "x(93)".
   put skip " № :    (жўмыстыѕ,   :бір- :(кґле- :            :(жўмыстыѕ,  :                 :  сатылым   :" format "x(93)".
   put skip "   :    ќызметтіѕ)   :лігі :  мі)  :            : ќызметтіѕ) : Мґл- :  Сомасы  :    ќўны,   :" format "x(93)".
   put skip "   :      атауы      :     :       :            : ќўны, ЌЌС  :шерле-:          :  теѕгемен  :" format "x(93)".
   put skip "   :                 :     :       :            :жоќ,теѕгемен: месі :          :            :" format "x(93)".

   put skip "/N : / Наименование  :/ Ед.:/ К-во :  / Цена    :/ Стоимость :  /   :     /    : / Всего    :" format "x(93)".
   put skip "   :    товаров      : изм :(объем):            :  товаров   :ставка:   сумма  : cтоимость  :" format "x(93)".
   put skip "п/п:  (работ,услуг)  :     :       :            :(работ,усл) :      :          : реализации,:" format "x(93)".
   put skip "   :                 :     :       :            :  без НДС,  :      :          :   тенге    :" format "x(93)".
   put skip "   :                 :     :       :            :   тенге    :      :          :            :" format "x(93)".


   put skip fill("-", 93) format "X(93)".
   put skip " 1 :         2       :  3  :   4   :      5     :     6      :   7  :    8     :      9     :" format "x(93)".
   put skip fill("-", 93) format "x(93)".

       /* Luiza */
    vnds = "".
    l-cf = string(v-fakturnum, ">999999999") + v-txb.
    l-cmp = trim(cmp.name).
    l-rnn = cmp.addr[2].
    vadd1 = trim(cmp.addr[1]).
    if comm-txb() = 'TXB00' then l-ras = " ИИК KZ98125KZT1001300600 ".
    else l-ras = " ИИК KZ33470142860A019800 ".
    if comm-txb() = 'TXB00' then l-bb = "в ГУ 'Национальный банк РК' БИК NBRKKZKX".
    else l-bb =  "в АО " + replace_bnamebik(v-bankname, dat2) + "    БИК   " + replace_bnamebik(v-bankcode, dat2).
    l-cifname = forma-sobstv + " " + trim(cif.name).
    hhh1 = substring(trim(cif-addr),1,53).
    hhh2 = substring(trim(cif-addr),54,length(trim(cif-addr)) - 53).
    hhh3 = trim(cif-addr).
    l-cifregdt = string(cif.regdt, "99/99/9999").
    l-cifbin  = cif.bin.
    l-table = "".
    /*--------------------------------------------------*/
   if v-prizn eq 'FILPAYMENT' then do:
        if t-InterBrh.gl = 287082 then v-gl = 460828.
        else v-gl = t-InterBrh.gl.
   end.
   else do:
        if jl.gl = 287082 then v-gl = 460828.
        else v-gl = jl.gl.
   end.
   find first sub-cod where sub-cod.d-cod = "ndcgl" and sub-cod.ccode = "01" and sub-cod.sub = "gld" and
         sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
   if avail sub-cod then do:
     v-jlrem = v-nazn1.

     put unformatted skip
        " 1 :" + substr(string(v-nazn1), 1, 17)  format "x(21)" ":".
       if s-jdt < 01/01/2009 then v-nds% = 0.13.
       else do:
         find sysc where sysc = "nds" no-lock no-error.
         if avail sysc then v-nds% = sysc.deval. else v-nds% = 0.12.
       end.
     v-nazn1 = substr(v-nazn1,18).

        DO WHILE v-nazn1 <> '':
            if length(v-nazn1) > 17 then do:
                put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
            end.
            else do:
                put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
            end.
            v-nazn1 = substr(v-nazn1,18).
        end.
     /*put unformatted skip "   :" + substr(string(v-nazn1), 18, 17) format "x(21)" ":  шт      1   ".*/
        l-table = l-table + "<tr> <font size = 1 face='Calibri'>" + "<td align=center>" + "1" + "</td>".
        if  trim(v-jlrem) <> "" then l-table = l-table + "<td> " +  v-jlrem + "</td>".
        else do:
            if v-prizn = "FILPAYMENT" then l-table = l-table + "<td> " + trim(t-InterBrh.rem[5]) + "</td>".
            else l-table = l-table + "<td> " + trim(jl.rem[5]) + "</td>".
        end.
        l-table = l-table + "<td align=center> шт</td>".
        l-table = l-table + "<td align=center> 1</td>".

    sss1 = v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2).
    sss2 = v-amt * v-nds% / (1 + v-nds%).
    sss3 = v-amt.

    /*if cmp.code = 14 then run oneSF-VKO in this-procedure.*/

     put string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)" space(1)
         string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)".
     put "    " v-nds% * 100 format "z9" "%" format "x".
     put string(v-amt * v-nds% / (1 + v-nds%), ">,>>>,>>9.99")   format "X(12)".
     put string(v-amt, ">,>>>,>>9.99")               format "X(12)".
     put space(20).
     put skip fill("-", 93) format "x(93)".

     l-table = l-table + "<td align=right> " + string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2),">>>>>>>>>9.99") + "</td>".
     l-table = l-table + "<td align=right> " + string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2),">>>>>>>>>9.99") + "</td>".
     l-table = l-table + "<td> " + string(v-nds% * 100) + "%</td>".
     vnds = string(v-nds% * 100) + "%".
     l-table = l-table + "<td align=right> " + string(round((v-amt * v-nds%) / (1 + v-nds%),2),">>>>>>>>>9.99") + "</td>".
     l-table = l-table + "<td align=right> " + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>".
     /*l-table = l-table + "<tr> <font size = 1 face='Calibri'>" + "<td align=center>" + " " + "</td></font></tr>".*/
     put skip "Есепшот бойынша барлыєы/Всего по счету" format "X(38)" space(11).
     put string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99")
         format "X(12)" "    " v-nds% * 100 format "z9" "%" format "x"
         string(v-amt * v-nds% / (1 + v-nds%), ">,>>>,>>9.99") format "X(12)"
         string(v-amt, ">,>>>,>>9.99") format "X(12)".
     sum_sum = v-amt.
   end.
   else do:
        v-jlrem = v-nazn1.

     put unformatted skip
         " 1 :" + substr(string(v-nazn1), 1, 17)  format "x(21)" ":".
     v-nazn1 = substr(v-nazn1,18).

        DO WHILE v-nazn1 <> '':
            if length(v-nazn1) > 17 then do:
                put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
            end.
            else do:
                put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
            end.
            v-nazn1 = substr(v-nazn1,18).
        end.

     /*put unformatted skip "   :" + substr(string(v-nazn1), 18, 17) format "x(21)" ":  шт      1   ".*/
         l-table = l-table + "<tr> <font size = 1 face='Calibri'>" + "<td align=center>" + "1" + "</td>".
        if  trim(v-jlrem) <> "" then l-table = l-table + "<td> " +  v-jlrem + "</td>".
        else do:
            if v-prizn = "FILPAYMENT" then l-table = l-table + "<td> " + trim(t-InterBrh.rem[5]) + "</td>".
            else l-table = l-table + "<td> " + trim(jl.rem[5]) + "</td>".
        end.

         l-table = l-table + "<td align=center>шт</td>".
         l-table = l-table + "<td align=center>1</td>".

        sss1 = v-amt.
        sss2 = 0.
        sss3 = v-amt.
       /*if cmp.code = 14 then run oneSF-VKO in this-procedure.*/

     put string(v-amt, ">,>>>,>>9.99") format "X(12)" space(1). /*Дублирование для цены*/
     put string(v-amt, ">,>>>,>>9.99") format "X(12)" space(19) string(v-amt, ">,>>>,>>9.99") format "X(12)" space(20).
     put skip fill("-", 93) format "x(93)".
     l-table = l-table + "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td>".
     l-table = l-table + "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td>".
     l-table = l-table + "<td>" + "" + "</td>".
     l-table = l-table + "<td align=right>" + "" + "</td>".
     l-table = l-table + "<td valign=""middle"" align=""right"">" + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>".
     /*l-table = l-table + "<tr> <font size = 1 face='Calibri'>" + "<td align=center>" + " " + "</td></font></tr>".*/

     put skip "Есепшот бойынша барлыєы / Всего по счету :" format "X(49)".
     put string(v-amt, ">,>>>,>>9.99")  format "X(12)" space(19) string(v-amt, ">,>>>,>>9.99")  format "X(12)" space(20).
     sum_sum = v-amt.
   end.

   find ofc where ofc.ofc = g-ofc no-lock no-error.
       if avail ofc then ofc-name = ofc.name.

    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
        if avail sysc then director-name = sysc.chval.

   find codfr where codfr.codfr = 'DKPODP' and codfr.code = '2' no-lock.
       if avail codfr then buh-name = codfr.name[1].

   put skip fill("-", 93) format "x(93)".
   put skip(1) "    Мекеменіѕ басшысы" space(34) "Берген (жеткізушініѕ жауапты тўлєасы)".
   put skip "/Руководитель организации" space(29) "/ВЫДАЛ (ответственное лицо поставщика)".
   put skip space(3) director-name format "X(21)" space(30) "_____________________________________".

   put skip "(аты-жґні, ќолы)/(Ф.И.О., подпись)" space(22) "(лауазымы)/(должность)".
   put skip space(30) "М.П." space(24) ofc-name format "X(37)".
   put skip "    Мекеменіѕ бас бухгалтеры " space(27) "(аты-жґні, ќолы)/(Ф.И.О., подпись)".
   put skip "/Главный бухгалтер организации".
   put skip space(3) buh-name format "X(29)".
   put skip "(аты-жґні, ќолы)/(Ф.И.О., подпись)".

   put skip fill("=", 93) format "X(93)".

   output close.

   if opsys <> "UNIX" then return "0".

   if in_command <> ? then do:
        partkom = in_command + " " + in_destination.
   end.
   else do:
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        if available ofc and ofc.expr[3] <> "" then do:
             partkom = ofc.expr[3] + " " + in_destination.
        end.
        else return "0".
   end.

  if not g-batch then do:
    pause 0.
   /* прогонка принтера, чтобы бумагу не выкручивать вручную */
    output to rpt.img append.
    find first ofc where ofc.ofc = g-ofc no-lock.
    if ofc.mday[2] = 1 then put skip(14).
    else put skip(1).
    output close.
    run menu-prt3("rpt.img").
  end.

  /*if cmp.code <> 14 then Run PrintAkt in This-Procedure.*/

End Procedure.

Procedure CreateOrderHistory:
   do transaction:
       find first fakturis where fakturis.jh = s-jh and fakturis.trx = s-trx and
            fakturis.ln = s-jl use-index jhtrxln exclusive-lock no-error.
       if not available fakturis
       then do:
            create fakturis.
            fakturis.jdt     = s-jdt.
            fakturis.jh      = s-jh.
            fakturis.trx     = s-trx.
            fakturis.ln      = s-jl.
            fakturis.sts     = "OOO".
            fakturis.who     = g-ofc.
            fakturis.rdt     = g-today.
            fakturis.tim     = time.
            fakturis.cif     = s-cif.
            fakturis.acc     = in_account.
            fakturis.amt     = v-amt.
            fakturis.pvn     = v-amt / (1 + v-nds%) * v-nds%.
            fakturis.neto    = v-amt - fakturis.pvn.
            fakturis.order   = v-ordnum.
            fakturis.faktura = v-fakturnum.
            fakturis.info[1] = v-prizn.
            fakturis.info[2] = v-txbase.
       end.
       fakturis.sts = "FO" + substring(fakturis.sts, 3, 1).

       find first c-involist where c-involist.jh eq fakturis.jh and
                            c-involist.trx = fakturis.trx and
                            c-involist.ln  eq fakturis.ln and
                            c-involist.amt1 eq fakturis.amt exclusive-lock no-error.
       if avail c-involist then do:
        c-involist.sts = fakturis.sts.
        c-involist.who = fakturis.who.
        c-involist.tim = fakturis.tim.
        c-involist.dat = g-today.
        find current c-involist no-lock.
       end.
    end.
End Procedure.

Procedure FindGlComJl:  /* јe ispoµzujetsja  */
  s-glcom = 0.
  if v-prizn = "FILPAYMENT" then do:
      for each b-InterBrh where b-InterBrh.jh = s-jh and b-InterBrh.txb = v-txbase no-lock:
          find gl where gl.gl eq b-InterBrh.gl no-lock no-error.
          if available gl and gl.type eq "R"
          then s-glcom = b-InterBrh.gl.
      end.
  end.
  else do:
      for each b-jl where b-jl.jh = s-jh no-lock:
          find gl where gl.gl eq b-jl.gl no-lock no-error.
          if available gl and gl.type eq "R"
          then s-glcom = b-jl.gl.
      end.
  end.
End Procedure.

Procedure FindGlCom:  /* not active */
    find aaa where aaa.aaa eq in_account no-lock.
    find gl where gl.gl eq aaa.gl no-lock.
    find trxlevgl where trxlevgl.gl eq aaa.gl and trxlevgl.subled eq "CIF"
    and trxlevgl.level = 3 no-lock no-error.
    if available trxlevgl then s-glcom = trxlevgl.glr. else s-glcom = 0.
End Procedure.

Procedure PrintAllOrg:
   l-table = "".
    l-kol = 2.
   def var j as integer init 0.
   j = 0.
   for each b-involist where substring(b-involist.sts, 3, 1) = "O" no-lock:
       j = j + 1.
   end.

   message "Всего " j " счетов-оригиналов" skip "       Печатать?"
           view-as alert-box question buttons Yes-No
   title " Печатать все оригиналы? " update vans as log.

   update v-selpvn with frame f-selpvn.
   hide frame f-selpvn.

   if vans then
   do:

        for each b-involist where substring(b-involist.sts, 3, 1) = "O" no-lock:
            if b-involist.prizn = "FILPAYMENT" then do:
                find first t-InterBrh where t-InterBrh.jh = b-involist.jh and t-InterBrh.ln = b-involist.ln and
                t-InterBrh.txb = b-involist.txb no-lock no-error .
                if t-InterBrh.gl = 287082 then v-gl = 460828.
                else v-gl = t-InterBrh.gl.
            end.
            else do:
                find first jl where jl.jh = b-involist.jh and jl.ln = b-involist.ln no-lock no-error .
                if jl.gl = 287082 then v-gl = 460828.
                else v-gl = jl.gl.
            end.
            find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
            if avail sub-cod then do:
                sf-nomer = b-involist.faktura.
                leave.
            end.
        end.

        Run PrintSvodN in This-Procedure.

        for each b-involist where substring(b-involist.sts, 3, 1) = "O" no-lock:
            s-jh    = b-involist.jh.
            s-trx   = b-involist.trx.
            s-jl    = b-involist.ln.
            s-amt   = b-involist.amt1.
            v-amt   = b-involist.amt1.
            s-sts   = b-involist.sts.
            s-date  = b-involist.dat.
            s-jdt   = b-involist.jdt.
            s-glcom = b-involist.glcom.
            s-sumv  = b-involist.amt.
            s-num   = b-involist.num.
            v-prizn = b-involist.prizn.
            v-txbase = b-involist.txb.

            if s-jdt ne g-today then
            Run PrintSvodS in This-Procedure.
    /*            Run PrintOrder in This-Procedure. */
            Run CreateOrderHistory in This-Procedure.

        end.

        /*put stream l-out unformatted "<tr> <font size = 1 face='Calibri'>" + "<td align=center>" + " " + "</td></font></tr>"  skip.*/
        /*if cmp.code = 14 then run aktVKO-end in This-Procedure.*/
        output close.
          find ofc where ofc.ofc = g-ofc no-lock no-error.
          if avail ofc then ofc-name = ofc.name.

          find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
          if avail sysc then director-name = sysc.chval.

          find codfr where codfr.codfr = 'DKPODP' and codfr.code = '2' no-lock.
          if avail codfr then buh-name = codfr.name[1].

          Run PrintSvodK in This-Procedure.
          /*Run PrintSvodMn in This-Procedure.

          i = 0.
          for each b-involist where substring(b-involist.sts, 3, 1) = "O" no-lock:
            s-jh    = b-involist.jh.
            s-trx   = b-involist.trx.
            s-jl    = b-involist.ln.
            s-amt   = b-involist.amt1.
            v-amt   = b-involist.amt1.
            s-sts   = b-involist.sts.
            s-date  = b-involist.dat.
            s-jdt   = b-involist.jdt.
            s-glcom = b-involist.glcom.
            s-sumv  = b-involist.amt.
            s-num   = b-involist.num.
            s-faktur= b-involist.faktura.
            in_account = b-involist.acc.

            if s-jdt ne g-today then
            Run PrintSvodMem in This-Procedure.

          end.
          Run PrintSvodMk in This-Procedure.*/
          /*if cmp.code <> 14 then Run PrintAkt in This-Procedure.*/
        if not g-batch then do:
           pause 0.
          /* прогонка принтера, чтобы бумагу не выкручивать вручную */
          output to rpt.img append.
          find first ofc where ofc.ofc = g-ofc no-lock.
          if ofc.mday[2] = 1 then put skip(14).
          else put skip(1).
          output close.

          run menu-prt3( 'rpt.img' ).
        end.
   end.
End Procedure.
Procedure PrintSvodN:
   output stream l-out close.
   output stream s-out close.
   output stream s-out to "aktvko.html".
   output stream l-out to "aktvko1.html".
   sss1 = 0.0.
   sss2 = 0.0.
   sss3 = 0.0.
   find first fakturis where fakturis.jh = s-jh and fakturis.trx = s-trx and
        fakturis.ln = s-jl use-index jhtrxln no-lock no-error.
   if not available fakturis
        then  v-ordnum = next-value(vptrx).  /* Change Sequence */
        else v-ordnum = fakturis.order.
   output to value(in_destination).
   find first cmp no-lock.
      if not available fakturis or fakturis.faktura = 0 then v-fakturnum = integer(substring(string(year(g-today), "9999"),3,2) + string(month(g-today),"99") + string(v-ordnum, "99999")).
      else v-fakturnum = integer(string(fakturis.faktura, "999999999")).
   /*после 15 марта в номер добавлять код филиала*/
   if s-jdt > 03/15/2010 then v-txb = substr(comm-txb(),4,2).
                         else v-txb = "  ".

   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'lnopf' no-lock no-error.
   if avail sub-cod then do:
        find first codfr where codfr.codfr = 'lnopf' and codfr.code = sub-cod.ccode no-lock no-error.
           forma-sobstv = /*sub-cod.ccode + " - " +*/ trim(codfr.name[1])/* + " " + trim(cif.name))*/.
   end.
   else  forma-sobstv = trim(cif.prefix)/* + " " + trim(cif.name))*/.
   if trim(cif.prefix) = "ИП" then forma-sobstv = cif.prefix.

   /*find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
   if avail sysc then bbin = sysc.chval.*/

    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc then do:
          kzname = entry(14, sysc.chval, "|") no-error.
        end.

    cif-addr = replace(cif.addr[1], ",,",",").
    cif-addr = replace(cif-addr, "(KZ)","").


    /*put skip(1) "Согласовано" space(82) "Приложение 2".
    put skip "Министр финансов Республики Казахстан" space(50) "к приказу Министра".
    put skip "____________________М.Есенбаев " space(51) "государственных доходов".
    put skip "'___' ______________2000 г." space(58) "Республики Казахстан".
    put skip space(79) "от '___' __________2000 г.".
    put skip "Председатель Агентства" space(74) "N _______".
    put skip "Республики Казахстан по статистике".
    put skip "____________________А.Смаилов".
    put skip "'___' ______________2000 г.".*/

   if v-selpvn = 1 then put skip(2) space(35) " ШОТ-ФАКТУРА / СЧЕТ-ФАКТУРА N " + string(sf-nomer, ">99999999") + v-txb format "x(50)".
   else put skip(2) space(35) " ШОТ-ФАКТУРА / СЧЕТ-ФАКТУРА N " + string(v-fakturnum, ">99999999") + v-txb format "x(50)".
   if dat2 eq g-today then do:
      find last cls no-lock.
      dat2 = cls.cls.
   end.
   put skip space(50) /*s-jdt*/ dat2 format "99/99/9999".
   put skip(1).
   put skip "Жеткізуші / Поставщик : " + trim(cmp.name) format "x(90)".
   put skip "Жеткізушініѕ тїрєан жерініѕ мекенжайы / адрес места нахождения поставщика : " /*" БИН " v-bankbin format "X(12)"*/ " ,".
   put skip trim(cmp.addr[1]) format "x(90)".
   put skip "БСН/БИН  " v-bankbin format "X(12)".
   put skip "ЌЌС бойынша есепке ќою туралы кујлік / Свидетельство о постановке на учет по НДС".
   put skip "серия " ndssvi format "x(35)" "г.".
   put skip "Жеткізушініѕ есеп айырысу шоты / Расчетный счет поставщика : " .
       if comm-txb() = 'TXB00' then put " ИИК KZ98125KZT1001300600 ".
                               else put " ИИК KZ33470142860A019800 ".
   if comm-txb() = 'TXB00' then put skip "в ГУ 'Национальный банк РК' БИК NBRKKZKX".
                           else put skip "в АО " replace_bnamebik(v-bankname, dat2) format "x(15)" " БИК " replace_bnamebik(v-bankcode, dat2).
   put skip "Тауарларды (жўмыстарды, ќызметтерді) жеткізу шарты (келісімшарты) / Договор(контракт) на поставку".
   put skip "товаров(работ,услуг) N   б/н , "  cif.regdt format "99/99/9999".
   put skip "Шарт (келісімшарт) бойынша тґлем жасау талаптары / Условия оплаты по договору(контракту) :  безналичный" .
   put skip "Жґнелтетін тауарларды (жўмыстарды, ќызметтерді) жеткізу орны / Пункт назначения поставляемых ".
   put skip "товаров(работ,услуг) " + trim(cif-addr) format "X(110)".
   put skip "                     (мемлекет, аймаќ, облыс, ќала, аудан)/(гос-во,регион,область,город,район)".
   put skip "Сенімхат бойынша жеткізілді / Поставка товаров осуществлена по доверенности N         от ".
   put skip "Жґнелту тјсілі / Способ отправления ".
   put skip "Тауар-кґлік жїк ќўжаты / Товарно-транспортная накладная N           от ".
   put skip "Жїк жґнелтуші / Грузоотправитель ______________________________________________________________".
   put skip "                             (ЖСН/БСН, атауы жјне мекен - жайы)/(ИИН/БИН, наименование и адрес)".
   put skip "Жїк алушы / Грузополучатель _______________________________________________________________ ".
   put skip "                         (ЖСН/БСН, атауы жјне мекен - жайы)/(ИИН/БИН, наименование и адрес)".
   put skip "Алушы / Получатель: " /*trim(trim(cif.prefix) + " " + trim(cif.name))*/ forma-sobstv + " " + trim(cif.name) format "X(110)".
   put skip "Алушыныѕ тїрєан жерініѕ мекенжайы /адрес места нахождения получателя: " .
   put skip trim(cif-addr) /* + trim(cif.addr[2])*/ format "x(110)" .
   put skip "ЖСН/БСН / ИИН/БИН  " cif.bin format "X(12)".
   put skip "Алушыныѕ есеп айырысу шоты / Расчетный счет получателя N " in_account format "X(20)" " в "  + trim(cmp.name) format "X(110)" .
   put skip fill("-", 93) format "X(93)".
   put skip "Р/т:   Тауарлардыѕ   :Ґлшем: Саны  :   Баєасы   :Тауарлардыѕ :  ЌЌС / НДС      :   Барлыќ   :" format "x(93)".
   put skip " № :    (жўмыстыѕ,   :бір- :(кґле- :            :(жўмыстыѕ,  :                 :  сатылым   :" format "x(93)".
   put skip "   :    ќызметтіѕ)   :лігі :  мі)  :            : ќызметтіѕ) : Мґл- :  Сомасы  :    ќўны,   :" format "x(93)".
   put skip "   :      атауы      :     :       :            : ќўны, ЌЌС  :шерле-:          :  теѕгемен  :" format "x(93)".
   put skip "   :                 :     :       :            :жоќ,теѕгемен: месі :          :            :" format "x(93)".

   put skip "/N : / Наименование  :/ Ед.:/ К-во :  / Цена    :/ Стоимость :  /   :     /    : / Всего    :" format "x(93)".
   put skip "   :    товаров      : изм :(объем):            :  товаров   :ставка:   сумма  : cтоимость  :" format "x(93)".
   put skip "п/п:  (работ,услуг)  :     :       :            :(работ,усл) :      :          : реализации,:" format "x(93)".
   put skip "   :                 :     :       :            :  без НДС,  :      :          :   тенге    :" format "x(93)".
   put skip "   :                 :     :       :            :   тенге    :      :          :            :" format "x(93)".


   put skip fill("-", 93) format "X(93)".
   put skip " 1 :         2       :  3  :   4   :      5     :     6      :   7  :    8     :      9     :" format "x(93)".
   put skip fill("-", 93) format "x(93)" .
    /* Luiza */
    if v-selpvn = 1 then l-cf = string(sf-nomer, ">999999999") + v-txb.
    else l-cf = string(v-fakturnum, ">999999999") + v-txb.
    l-cmp = trim(cmp.name).
    l-rnn = cmp.addr[2].
    vadd1 = trim(cmp.addr[1]).
    if comm-txb() = 'TXB00' then l-ras = " ИИК KZ98125KZT1001300600 ".
    else l-ras = " ИИК KZ33470142860A019800 ".
    if comm-txb() = 'TXB00' then l-bb = "в ГУ 'Национальный банк РК' БИК NBRKKZKX".
    else l-bb =  "в АО " + replace_bnamebik(v-bankname, dat2) + "    БИК   " + replace_bnamebik(v-bankcode, dat2).
    l-cifname = forma-sobstv + " " + trim(cif.name).
    hhh1 = substring(trim(cif-addr),1,53).
    hhh2 = substring(trim(cif-addr),54,length(trim(cif-addr)) - 53).
    hhh3 = trim(cif-addr).
    l-cifregdt = string(cif.regdt, "99/99/9999").
    l-cifbin  = cif.bin.
    /*--------------------------------------------------*/

 output close.

    /*if cmp.code = 14 then run akt-VKO in this-procedure.*/

End Procedure.

Procedure PrintSvodS:
  v-nazn = "Назначение платежа: ".

  if v-prizn = "FILPAYMENT" then do:
        run CheckFilPay(no,yes).
  end.
  else do:
        find jh where jh.jh = s-jh no-lock.
        find first jl where jl.jh = s-jh and jl.ln = s-jl no-lock no-error .
        if not avail jl then do:
           message " JL " + string(s-jh) + " Ln= " +
           string(s-jl) + " не найдена " .
           pause .
           return .
        end.

        if trim(jl.rem[1]) begins "409 -" or trim(jl.rem[1]) begins "419 -"
        then do:
           v-nazn = v-nazn + jl.rem[1].
        end.
        else if jh.sub = "JOU"
           then do:
             find first joudoc where jh.ref  = joudoc.docnum no-lock no-error .
             if avail joudoc then
                find tarif2 where tarif2.str5 = joudoc.comcode
                              and tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.
             if not available tarif2
                then v-nazn = v-nazn + jl.rem[5].
             else v-nazn = v-nazn + tarif2.pakalp.
           end.
        else if jh.sub = "RMZ"
        then do:
           find first remtrz where jh.ref = remtrz.remtrz no-lock
           no-error .
           if avail remtrz then
              find tarif2 where tarif2.str5 = string(remtrz.svccgr)
                            and tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.
              if not available tarif2
                 then v-nazn = v-nazn + jl.rem[5].
              else v-nazn = v-nazn + tarif2.pakalp.
        end.
        else
         v-nazn = v-nazn + jl.rem[5].
          if v-nazn matches "*долг*" then
          v-nazn1  = substr(v-nazn, 21 + 5) .
           else   v-nazn1  = substr(v-nazn, 21) .
        if trim(v-nazn1) = '' then v-nazn1 = jl.rem[1].
        v-operdt = jl.jdt.
    end.

    /*  v-nazn = v-nazn + string(jl.rem[5],"x(37)").
    v-nazn1  = substr(v-nazn,21) .  */

   output to value(in_destination) append.

   if v-selpvn = 3 then do:
        if v-prizn = "FILPAYMENT" then do:
            if t-InterBrh.gl = 287082 then v-gl = 460828.
            else v-gl = t-InterBrh.gl.
        end.
        else do:
            if jl.gl = 287082 then v-gl = 460828.
            else v-gl = jl.gl.
        end.
       find first sub-cod where sub-cod.d-cod = "ndcgl" and
            sub-cod.ccode = "01" and sub-cod.sub = "gld" and
            sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
       if avail sub-cod then do:
             if s-jdt < 01/01/2009 then v-nds% = 0.13.

             put stream s-out unformatted "<tr>" "<td>" string(s-num,"zz9") "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-nazn1 "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>шт</td>". /* акт для ско */
             put stream s-out unformatted  "<td>1</td>". /* акт для ско */
             put stream l-out unformatted "<tr> <font size = 1 face='Calibri'>" + "<td>" + string(s-num,"zz9") + "</td>"  skip.
             put stream l-out unformatted "<td>" +  v-nazn1 + "</td>"  skip.
             put stream l-out unformatted "<td> шт </td>"  skip.
             put stream l-out unformatted "<td> 1 </td>"  skip.

             put skip(1).
             put unformatted string(s-num,"zz9") + ":"
                    + substr(string(v-nazn1),1,17)  format "x(21)" ":".
             v-nazn1 = substr(v-nazn1,18).


                DO WHILE v-nazn1 <> '':
                    if length(v-nazn1) > 17 then do:
                        put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
                    end.
                    else do:
                        put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
                    end.
                    v-nazn1 = substr(v-nazn1,18).
                end.


             /*put unformatted skip "   :" + substr(string(v-nazn1),18,17) format "x(21)" ":  шт      1   ".*/

             put stream s-out unformatted  "<td>" v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" (v-amt * v-nds%) / (1 + v-nds%) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream l-out unformatted "<td align=right>" + string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right>" + string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td>" + string(v-nds% * 100) + "%</td>"  skip.
             put stream l-out unformatted "<td align=right>" + string(round((v-amt * v-nds%) / (1 + v-nds%),2),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>"  skip.

             put string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)"
                 space(1) string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)".
             sss1 = sss1 + (v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2)).
             put space(3) v-nds% * 100 format "z9" "%" format "x".
             put string(v-amt * v-nds% / (1 + v-nds%), ">,>>>,>>9.99")   format "X(12)".
             sss2 = sss2 + (v-amt * v-nds% / (1 + v-nds%)).
             put " " string(v-amt, ">,>>>,>>9.99")               format "X(12)".
             put space(20).
             sss3 = sss3 + v-amt.

       end.
       else do:
             put stream s-out unformatted "<tr>" "<td>" string(s-num,"zz9") "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-nazn1 "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>шт</td>". /* акт для ско */
             put stream s-out unformatted  "<td>1</td>". /* акт для ско */
             put stream l-out unformatted "<tr> <font size = 1 face='Calibri'>" + "<td>" + string(s-num,"zz9") + "</td>"  skip.
             put stream l-out unformatted "<td>" + v-nazn1 + "</td>"  skip.
             put stream l-out unformatted "<td>шт</td>"  skip.
             put stream l-out unformatted "<td>1</td>"  skip.

             put skip(1).
             put unformatted skip string(s-num,"zz9") + ":"
                    + substr(string(v-nazn1), 1, 17)  format "x(21)" ":".
             v-nazn1 = substr(v-nazn1,18).



                DO WHILE v-nazn1 <> '':
                    if length(v-nazn1) > 17 then do:
                        put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
                    end.
                    else do:
                        put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
                    end.
                    v-nazn1 = substr(v-nazn1,18).
                end.

             /*put unformatted skip "   :" + substr(string(v-nazn1), 18, 17) format "x(21)" ":  шт      1   " .*/
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>Без НДС</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream l-out unformatted "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td>" + " " + "</td>"  skip.
             put stream l-out unformatted "<td align=right> Без НДС</td>"  skip.
             put stream l-out unformatted "<td align=right>" + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>"  skip.

             put string(v-amt, ">,>>>,>>9.99") format "X(12)" space(1) string(v-amt, ">,>>>,>>9.99") format "X(12)"space(10) "Без НДС" space(2) string(v-amt, ">,>>>,>>9.99") format "X(12)" space(20).
             sss1 = sss1 + v-amt.
             sss3 = sss3 + v-amt.
       end.
   end.

   if v-selpvn = 1 then do:
        if v-prizn = "FILPAYMENT" then do:
            if t-InterBrh.gl = 287082 then v-gl = 460828.
            else v-gl = t-InterBrh.gl.
        end.
        else do:
            if jl.gl = 287082 then v-gl = 460828.
            else v-gl = jl.gl.
        end.
       find first sub-cod where sub-cod.d-cod = "ndcgl" and
            sub-cod.ccode = "01" and sub-cod.sub = "gld" and
            sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
       if avail sub-cod then do:
             if s-jdt < 01/01/2009 then v-nds% = 0.13.
             put skip(1).

             put stream s-out unformatted "<tr>" "<td>" string(s-num,"zz9") "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-nazn1 "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>шт</td>". /* акт для ско */
             put stream s-out unformatted  "<td>1</td>". /* акт для ско */
             put stream l-out unformatted "<tr> <font size = 1 face='Calibri'>" + "<td>" + string(s-num,"zz9") + "</td>"  skip.
             put stream l-out unformatted "<td> " + v-nazn1 + "</td>"  skip.
             put stream l-out unformatted "<td> шт</td>"  skip.
             put stream l-out unformatted "<td> 1</td>"  skip.

             put unformatted string(s-num1,"zz9") + ":"
                    + substr(string(v-nazn1),1,17)  format "x(21)" ":".
             v-nazn1 = substr(v-nazn1,18).

                DO WHILE v-nazn1 <> '':
                    if length(v-nazn1) > 17 then do:
                        put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
                    end.
                    else do:
                        put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
                    end.
                    v-nazn1 = substr(v-nazn1,18).
                end.

             put stream s-out unformatted  "<td>" v-amt - round( (v-amt * v-nds%) / (1 + v-nds%) , 2 ) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt - round( (v-amt * v-nds%) / (1 + v-nds%) , 2 ) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" (v-amt * v-nds%) / (1 + v-nds%) format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream l-out unformatted "<td align=right> " + string(v-amt - round( (v-amt * v-nds%) / (1 + v-nds%) , 2 ),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right> " + string(v-amt - round( (v-amt * v-nds%) / (1 + v-nds%) , 2),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td> " + string(v-nds% * 100) + "%</td>"  skip.
             put stream l-out unformatted "<td align=right> " + string(round((v-amt * v-nds%) / (1 + v-nds%),2),">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right> " + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>"  skip.

             /*put unformatted skip "   :" + substr(string(v-nazn1),18,17) format "x(21)" ":  шт      1   ".*/
             put string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)"
                 space(1) string(v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2), ">,>>>,>>9.99") format "x(12)".
             sss1 = sss1 + (v-amt - round(v-amt * v-nds% / (1 + v-nds%), 2)).
             put space(3) v-nds% * 100 format "z9" "%" format "x".
             put string(v-amt * v-nds% / (1 + v-nds%), ">,>>>,>>9.99")   format "X(12)".
             sss2 = sss2 + (v-amt * v-nds% / (1 + v-nds%)).
             put " " string(v-amt, ">,>>>,>>9.99")               format "X(12)".
             put space(20).
             sss3 = sss3 + v-amt.
             s-num1 = s-num1 + 1.
       end.
   end.

   if v-selpvn = 2 then do:
        if v-prizn = "FILPAYMENT" then do:
            if t-InterBrh.gl = 287082 then v-gl = 460828.
            else v-gl = t-InterBrh.gl.
        end.
        else do:
            if jl.gl = 287082 then v-gl = 460828.
            else v-gl = jl.gl.
        end.
          find first sub-cod where sub-cod.d-cod = "ndcgl" and
            sub-cod.ccode = "01" and sub-cod.sub = "gld" and
            sub-cod.acc =/* string(jl.gl)*/ string(v-gl) no-lock no-error .
       if avail sub-cod then next.
       else do:
             put skip(1).

             put stream s-out unformatted "<tr>" "<td>" string(s-num,"zz9") "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-nazn1 "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>шт</td>". /* акт для ско */
             put stream s-out unformatted  "<td>1</td>". /* акт для ско */
             put stream l-out unformatted "<tr> <font size = 1 face='Calibri'>" + "<td>" + string(s-num,"zz9") + "</td>"  skip.
             put stream l-out unformatted "<td> " + v-nazn1 + "</td>"  skip.
             put stream l-out unformatted "<td> шт</td>"  skip.
             put stream l-out unformatted "<td> 1</td>"  skip.

             put unformatted skip string(s-num2,"zz9") + ":"
                    + substr(string(v-nazn1), 1, 17)  format "x(21)" ":".
             v-nazn1 = substr(v-nazn1,18).

                DO WHILE v-nazn1 <> '':
                    if length(v-nazn1) > 17 then do:
                        put unformatted skip  "   :" + substr(v-nazn1,1,17) format "x(21)" ":              ".
                    end.
                    else do:
                        put unformatted skip "   :" + substr(string(v-nazn1),1,17) format "x(21)" ":  шт      1   ".
                    end.
                    v-nazn1 = substr(v-nazn1,18).
                end.

             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream s-out unformatted  "<td>Без НДС</td>". /* акт для ско */
             put stream s-out unformatted  "<td>" v-amt format ">>>>>>>>>9.99" "</td>". /* акт для ско */
             put stream l-out unformatted "<td align=right> " + string(v-amt,">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td align=right> " + string(v-amt,">>>>>>>>>9.99") + "</td>"  skip.
             put stream l-out unformatted "<td> " + " " + "</td>"  skip.
             put stream l-out unformatted "<td align=right> Без НДС</td>"  skip.
             put stream l-out unformatted "<td align=right> " + string(v-amt,">>>>>>>>>9.99") + "</td></font></tr>"  skip.

             /*put unformatted skip "   :" + substr(string(v-nazn1), 18, 17) format "x(21)" ":  шт      1   " .*/
             put string(v-amt, ">,>>>,>>9.99") format "X(12)" space(1) string(v-amt, ">,>>>,>>9.99") format "X(12)"space(10) "Без НДС" space(2) string(v-amt, ">,>>>,>>9.99") format "X(12)" space(20).
             sss1 = sss1 + v-amt.
             sss3 = sss3 + v-amt.
             s-num2 = s-num2 + 1.
        end.
   end.

   output close.
   sum_sum = sss3.
End Procedure.

Procedure PrintSvodMn:
   /*output to value(in_destination) append.
   put skip(4).
   put skip space(25) "Реестр мемориальных ордеров" format "x(55)".
   put skip(1).
   put skip fill("-",110) format "x(110)".
   put skip "   Дата   : N сч-ф   :       Дебет         :Кредит:   Сумма   :    Назначение платежа    " format "x(110)".
   put skip fill("-",110) format "x(110)".
   output close.*/

      output stream m-out to sfreestr.html.

      put stream m-out "<html><head><title>Metrocombank</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream m-out  unformatted "<img src='c://tmp/sf1.jpg'>" skip.

      put stream m-out  unformatted "<hr size=3 width='100%' align=center>" skip.
      put stream m-out  unformatted "<p>" skip.

      put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"" >"
                     skip.
      put stream m-out  unformatted "<tr align=left > <font color=""#986008f"" size = 6 face='Calibri'> <td> Реестр мемориальных ордеров </font></td></tr>".

      put stream m-out unformatted
                      "<br><tr></tr><table border=""1"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse"" font size = 3>" skip
                      "<tr style=""font:bold"" BGCOLOR=""#986008f""><b>"
                      "<td style=""font:bold"" align=""Center"" color:""white"" >Дата</td>"
                      "<td style=""font:bold"" align=""Center"" color:'white' >№ сч-ф</td>"
                      "<td style=""font:bold"" align=""Center"" color:'white' >Дебет</td>"
                      "<td style=""font:bold"" align=""Center"" color:'white' >Кредит</td>"
                      "<td style=""font:bold"" align=""Center"" color:'white' >Сумма</td>"
                      "<td style=""font:bold"" align=""Center"" color:'white' >Назначение платежа</td>"
                      "</b></tr>".

End Procedure.

Procedure PrintSvodMem:
  v-nazn = "Назначение платежа: ".

  if v-prizn = "FILPAYMENT" then do:
        run CheckFilPay(no,no).
  end.
  else do:
        find jh where jh.jh = s-jh no-lock.
        find first jl where jl.jh = s-jh and jl.ln = s-jl no-lock no-error .


        def buffer b-kjl for jl.
        find first b-kjl where b-kjl.jh = s-jh and jl.ln = 1 no-lock no-error .
        if avail b-kjl then do:
        in_account = b-kjl.acc.
        end.


        if not avail jl then do:
         message " JL " + string(s-jh) + " Ln= " +
         string(s-jl) + " не найдена " .
         pause .
         return .
        end.

        if trim(jl.rem[1]) begins "409 -" or trim(jl.rem[1]) begins "419 -"
        then do:
           v-nazn = v-nazn + jl.rem[1].
        end.
        else if jh.sub = "JOU"
        then do:
          find first joudoc where jh.ref  = joudoc.docnum
             no-lock no-error .
          if avail joudoc then
             find tarif2 where tarif2.str5 = joudoc.comcode
                           and tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.
             if not available tarif2
                then v-nazn = v-nazn + jl.rem[5].
                else v-nazn = v-nazn + tarif2.pakalp.
                if joudoc.comcode = "057" then v-nazn = v-nazn + jl.rem[1].
        end.
        else if jh.sub = "RMZ"
        then do:
          find first remtrz where jh.ref = remtrz.remtrz no-lock
             no-error .
          if avail remtrz then
             find tarif2 where tarif2.str5 = string(remtrz.svccgr)
                           and tarif2.kont = jl.gl
                           and tarif2.stat = 'r' no-lock no-error.
             if not available tarif2
                then v-nazn = v-nazn + jl.rem[5].
                else v-nazn = v-nazn + tarif2.pakalp.
        end.
        else
        v-nazn = v-nazn + jl.rem[5].
        if v-nazn matches "*долг*" then
        v-nazn1  = substr(v-nazn,21 + 5) .
        else      v-nazn1  = substr(v-nazn,21) .
        if trim(v-nazn1) = '' then v-nazn1 = jl.rem[1].
    end.
    /*      v-nazn = v-nazn + string(jl.rem[5],"x(37)").
        v-nazn1  = substr(v-nazn,21) .  */

      /*output to value(in_destination) append.
      put skip(1).
      put skip s-jdt space(1).
      put s-faktur format "999999999"  v-txb format "x(2)" space(2) in_account format "X(21)"
          s-glcom format "zzzzz9"
          string(v-amt,">,>>>,>>9.99") format "X(12)"
          space(1) v-nazn1 format "x(60)".
      output close.*/


      if v-selpvn = 1 then do:
          if k > 0 and dat-pvn = s-jdt then do:

              /*if v-nazn1 matches "*с НДС*" then do:*/
              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if avail sub-cod then do:

              put stream m-out
                  "<tr>"
                      "<td align=""Left"">" s-jdt "</td>"
                      "<td align=""Left"">" sf-nomer v-txb "</td>"
                      "<td align=""Left"">" in_account "</td>"
                      "<td align=""Left"">" s-glcom "</td>"
                      "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                      "<td align=""Left"">" v-nazn1 format "X(110)" "</td>"
                  "</tr>".
              end.
          end.
          else do:
              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if avail sub-cod then do:
              k = 0.
              dat-pvn = s-jdt.
              sf-nomer = s-faktur.
              put stream m-out
                  "<tr>"
                      "<td align=""Left"">" s-jdt "</td>"
                      "<td align=""Left"">" s-faktur v-txb "</td>"
                      "<td align=""Left"">" in_account "</td>"
                      "<td align=""Left"">" s-glcom "</td>"
                      "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                      "<td align=""Left"">" v-nazn1  format "X(110)" "</td>"
                  "</tr>".
              end.
              k = k + 1.
          end.

      end.





      if v-selpvn = 2 then do:
          /*if not v-nazn1 matches "*с НДС*" then do:*/
              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if avail sub-cod then next.
           else do:
          put stream m-out
              "<tr>"
                  "<td align=""Left"">" s-jdt "</td>"
                  "<td align=""Left"">" s-faktur v-txb "</td>"
                  "<td align=""Left"">" in_account "</td>"
                  "<td align=""Left"">" s-glcom "</td>"
                  "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                  "<td align=""Left"">" v-nazn1  format "X(110)" "</td>"
              "</tr>".
          end.
      end.

      if v-selpvn = 3 then do:
              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if not avail sub-cod then do:
                  put stream m-out
                      "<tr>"
                          "<td align=""Left"">" s-jdt "</td>"
                          "<td align=""Left"">" s-faktur v-txb "</td>"
                          "<td align=""Left"">" in_account "</td>"
                          "<td align=""Left"">" s-glcom "</td>"
                          "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                          "<td align=""Left"">" v-nazn1  format "X(110)" "</td>"
                      "</tr>".
           end.
           else do:
          if k > 0 and dat-pvn = s-jdt then do:

              /*if v-nazn1 matches "*с НДС*" then do:*/
              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if avail sub-cod then do:

              put stream m-out
                  "<tr>"
                      "<td align=""Left"">" s-jdt "</td>"
                      "<td align=""Left"">" sf-nomer v-txb "</td>"
                      "<td align=""Left"">" in_account "</td>"
                      "<td align=""Left"">" s-glcom "</td>"
                      "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                      "<td align=""Left"">" v-nazn1 format "X(110)" "</td>"
                  "</tr>".
              end.
          end.
          else do:

              if v-prizn = "FILPAYMENT" then do:
                  if t-InterBrh.gl = 287082 then v-gl = 460828.
                  else v-gl = t-InterBrh.gl.
              end.
              else do:
                  if jl.gl = 287082 then v-gl = 460828.
                  else v-gl = jl.gl.
              end.
           find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
           if avail sub-cod then do:
              k = 0.
              dat-pvn = s-jdt.
              sf-nomer = s-faktur.

              put stream m-out
                  "<tr>"
                      "<td align=""Left"">" s-jdt "</td>"
                      "<td align=""Left"">" s-faktur v-txb "</td>"
                      "<td align=""Left"">" in_account "</td>"
                      "<td align=""Left"">" s-glcom "</td>"
                      "<td align=""Left"">" v-amt format ">>>>>>>>>9.99" "</td>"
                      "<td align=""Left"">" v-nazn1  format "X(110)" "</td>"
                  "</tr>".
              end.
              k = k + 1.
          end.
           end.
      end.

End Procedure.

Procedure PrintSvodMk:
   /*output to value(in_destination) append.
   put skip(1).
   put skip fill("-",110) format "x(110)".
   put skip "  Итого   :" space(40) string(sss3,">,>>>,>>9.99") format "X(12)".
   put skip fill("-",110) format "x(110)".
   output close.*/

  put stream m-out
  "<tr>"
      "<td>Итого:</td>"
      "<td></td>"
      "<td></td>"
      "<td></td>"
      "<td align=""Right"">" sss3 format ">>>>>>>>>9.99" "</td>"
      "<td></td>"
  "</tr>".

     put stream m-out "</table>" skip.

     put stream m-out "</body></html>" skip.

     output stream m-out close.
     unix silent cptwin sfreestr.html winword.exe.
     unix silent rm sfreestr.html.


End Procedure.

Procedure PrintSvodK:
   output to value(in_destination) append.
   put skip(1).
   put skip fill("-",93) format "x(93)".
   put skip "Есепшот бойынша барлыєы / Всего по счету" format "X(47)".
   put string(sss1,">>>,>>>,>>9.99") format "X(14)" space(4)
     string(sss2,">>>,>>>,>>9.99") format "X(14)" space(1)
     string(sss3,">>>,>>>,>>9.99") format "X(14)".
   put skip fill("-",93) format "x(93)".
   put skip(1) "    Мекеменіѕ басшысы" space(34) "Берген (жеткізушініѕ жауапты тўлєасы)".
   put skip "/Руководитель организации" space(29) "/ВЫДАЛ (ответственное лицо поставщика)".
   put skip space(3) director-name format "X(21)" space(30) "_____________________________________".

   put skip "(аты-жґні, ќолы)/(Ф.И.О., подпись)" space(22) "(лауазымы)/(должность)".
   put skip space(30) "М.П." space(24) ofc-name format "X(37)".
   put skip "    Мекеменіѕ бас бухгалтеры " space(27) "(аты-жґні, ќолы)/(Ф.И.О., подпись)".
   put skip "/Главный бухгалтер организации".
   put skip space(3) buh-name format "X(29)".
   put skip "(аты-жґні, ќолы)/(Ф.И.О., подпись)".

   put skip fill("=",93) format "X(93)".

   output close.
End Procedure.

Procedure PrintAkt:
    v-ifile = "/data/docs/sfakt.htm".
    v-ofile = "sfakt.htm" .

   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*date*" then do:
              v-str = replace (v-str, "date", ddd(dat2)).
              next.
           end.
           if cmp.code <> 0 then do:
               if v-str matches "*br-name-ru*" then do:
                  v-str = replace (v-str, "br-name-ru", "(" + cmp.name + ")").
                  next.
               end.
               if v-str matches "*br-name-kz*" then do:
                  v-str = replace (v-str, "br-name-kz", "(" + kzname + ")").
                  next.
               end.
           end.
           if cmp.code = 0 then do:
               if v-str matches "*br-name-ru*" then do:
                  v-str = replace (v-str, "br-name-ru", "").
                  next.
               end.
               if v-str matches "*br-name-kz*" then do:
                  v-str = replace (v-str, "br-name-kz", "").
                  next.
               end.
           end.
           if forma-sobstv <> 'Остальные' then do:
               if v-str matches "*prefix-ru*" then do:
                  v-str = replace (v-str, "prefix-ru", forma-sobstv).
                  next.
               end.
           end.
           if forma-sobstv = 'Остальные' then do:
               if v-str matches "*prefix-ru*" then do:
                  v-str = replace (v-str, "prefix-ru", "").
                  next.
               end.
           end.

           if forma-sobstv <> 'Остальные' then do:
               if v-str matches "*prefix-kz*" then do:
                  v-str = replace (v-str, "prefix-kz", 'Жауапкершілігі шектеулі серіктестік').
                  next.
               end.
           end.
           if forma-sobstv = 'Остальные' then do:
               if v-str matches "*prefix-kz*" then do:
                  v-str = replace (v-str, "prefix-kz", "").
                  next.
               end.
           end.

           if v-str matches "*prefix-short*" then do:
              v-str = replace (v-str, "prefix-short", cif.prefix).
              next.
           end.

           if v-str matches "*cif-name*" then do:
              v-str = replace (v-str, "cif-name", cif.name).
              next.
           end.
           if v-str matches "*sum*" then do:
              v-str = replace (v-str, "sum", string(sum_sum)).
              next.
           end.
           if v-str matches "*bankname*" then do:
              v-str = replace (v-str, "bankname", v-bankname ).
              next.
           end.
           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.
   unix silent cptwin value(v-ofile) winword.

End Procedure.


procedure akt-VKO:
    if v-operdt < 05/17/12 then v-filname = "Филиал АО ""Метрокомбанк"" по Восточно-Казахстанской области".
    else  v-filname = cmp.name.

      put stream s-out "<html><head><title>ForteBank</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

      put stream s-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"" >"
                     skip.

      put stream s-out unformatted
                      "<table border=""0"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse"">" skip
                      "<tr>"
                          "<td align=""left"" valign=""bottom"">Покупатель: <u>"  forma-sobstv + " " + cif.name "</u></td>"
                          "<td align=""left"" valign=""bottom"">Поставщик: <u>" v-filname /*cmp.name*/ "</u></td>"
                      "</tr>"
                      "<tr>"
                          "<td align=""left"" >РНН <u>" v-platcode "</u></td>"
                          "<td align=""left"" >РНН <u>" cmp.addr[2] "</u></td>"
                      "</tr>"
                      "<tr>"
                          "<td align=""left"" >БИН <u>" cif.bin "</u></td>"
                          "<td align=""left"" >БИН <u>" v-bankbin "</u></td>"
                      "</tr>"
                      "<tr>"
                          "<td></td>"
                          "<td align=""left"" >Условия оплаты   <u>Безналичный</u></td>"
                      "</tr>".
      put stream s-out "</table>" skip.

      put stream s-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                     style=""border-collapse: collapse"" >"
                     skip.

      put stream s-out unformatted
                      "<table width=""100%"" border=""0"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse"">" skip
                      "<tr>"
                          "<td align=""right"" >Акт №  <u>" v-fakturnum "</u></td>"
                          "<td align=""left"" >от  <u>" string(/*dat2*/ v-operdt, "99.99.9999") "</u></td>
                          </tr></table>"

                      "<table>"
                      "<tr><td align=""left"" >оказанных услуг на сторону за <u>" string(/*dat2*/ v-operdt, "99.99.9999") "</u></td></tr>"
                      "<tr><td align=""left"" >Основание:   Договор № <u>б/н</u> от <u>" string(cif.regdt, "99.99.9999") "</u></td></tr>".
    put stream s-out "<tr></tr><tr></tr></table>" skip.

    put stream s-out unformatted
                      "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse"">" skip
                      "<tr>"
                      "<td align=""left"" >№ п/п</td>"
                      "<td align=""left"" >Наименование работ, услуг</td>"
                      "<td align=""left"" >Ед.изм</td>"
                      "<td align=""left"" >Кол-во <br> (объем)</td>"
                      "<td align=""left"" >Цена без НДС, <br> тенге</td>"
                      "<td align=""left"" >Ст-ть без НДС, <br> тенге</td>"
                      "<td align=""left"" >НДС 12%, <br> тенге</td>"
                      "<td align=""left"" >Всего с НДС, <br> тенге</td>"
                      "</tr>".

end procedure.


procedure aktVKO-end:
    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then director-name = sysc.chval.

    put stream s-out
    "</tr>"
    "<tr>"
        "<td colspan = ""5"" align=""right"" >Всего по акту: </td>"
        "<td align=""left"" >" sss1 format ">>>>>>>>>9.99" "</td>"
        "<td align=""left"" >" sss2 format ">>>>>>>>>9.99" "</td>"
        "<td align=""left"" >" sss3 format ">>>>>>>>>9.99" "</td>
    </tr>"

    "</table>" skip.

    put stream s-out unformatted
                      "<table border=""0"" cellpadding=""10"" cellspacing=""0""
                      style=""border-collapse: collapse"">" skip
                      "<tr>"
                      "<tr></tr><tr></tr>"
                      "<tr>"
                      "<td align=""left"" valign=""top"" >Покупатель: </td>"
                      "<td><u>" forma-sobstv + " " + cif.name  "</u></td>"
                      "<td align=""left"" valign=""top"" >Поставщик: </td>"
                      "<td><u>" v-filname "</u></td>"
                      "</tr>"
                      "<tr>"
                      "<td align=""left"" >М.П.   </td>"
                      "<td align=""left"" > _______________________________ </td>"
                      "<td align=""left"" >М.П.   </td>"
                      "<td align=""left"" ><u> Руководитель организации</u> </td>"
                      "</tr>"

                      "<tr>"
                      "<td align=""left"" ></td>"
                      "<td align=""left"" valign = ""bottom"" >(должность)</td>"
                      "<td align=""left"" ></td>"
                      "<td align=""left"" valign = ""bottom"" >(должность)</td>"
                      "</tr>"

                      "<tr>"
                      "<td></td>"
                      "<td>_____________________________________</td>"
                      "<td></td>"
                      "<td align=""left"" ><u>" director-name "</u>&nbsp&nbsp&nbsp&nbsp&nbsp_____________</td>"
                      "</tr>
                      <tr>"
                      "<td></td>"
                      "<td valign = ""bottom"">(ФИО)&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(подпись)</td>"
                      "<td></td>"
                      "<td valign = ""bottom"">(ФИО)&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp(подпись)</td>"


                      "</tr>
                      </table>".

     output stream s-out close.
     unix silent cptwin akt-VKO.html winword.exe.
     unix silent rm akt-VKO.html.
end procedure.

procedure oneSF-VKO:
    if v-operdt < 05/17/12 then v-filname = "Филиал АО ""Метрокомбанк"" по Восточно-Казахстанской области".
    else  v-filname = cmp.name.

    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then director-name = sysc.chval.

    v-ifile = "/data/docs/sfaktvko.htm".
    v-ofile = "sfaktvko.htm" .
    cif1 = substring(forma-sobstv + " " + trim(cif.name),1,27).
    cif2 = substring(forma-sobstv + " " + trim(cif.name),28,length(forma-sobstv + " " + trim(cif.name)) - 27).

    bank1 = substring(trim(v-filname),1,25).
    bank2 = substring(trim(v-filname),26,length(trim(v-filname)) - 25).

   output stream s-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*cif1*" then do:
              v-str = replace (v-str, "cif1", cif1).
              next.
           end.
           if v-str matches "*cif2*" then do:
              v-str = replace (v-str, "cif2", cif2).
              next.
           end.
           if v-str matches "*bin1*" then do:
              v-str = replace (v-str, "bin1", cif.bin).
              next.
           end.
           if v-str matches "*bank1*" then do:
              v-str = replace (v-str, "bank1", bank1).
              next.
           end.
           if v-str matches "*bank2*" then do:
              v-str = replace (v-str, "bank2", bank2).
              next.
           end.
           if v-str matches "*bin2*" then do:
              v-str = replace (v-str, "bin2", v-bankbin).
              next.
           end.
           if v-str matches "*aktnum*" then do:
              v-str = replace (v-str, "aktnum", string(v-fakturnum)).
              next.
           end.
           if v-str matches "*aktdt*" then do:
              v-str = replace (v-str, "aktdt", string(v-operdt, "99.99.9999")).
              next.
           end.
           if v-str matches "*cifdt*" then do:
              v-str = replace (v-str, "cifdt", string(cif.regdt, "99.99.9999")).
              next.
           end.
           if v-str matches "*bankdir*" then do:
              v-str = replace (v-str, "bankdir", director-name).
              next.
           end.
           if v-str matches "*rem*" then do:
              v-str = replace (v-str, "rem", v-jlrem).
              next.
           end.
           if v-str matches "*price1*" then do:
              v-str = replace (v-str, "price1", string(sss1, ">>>>>>>>>9.99")).
              next.
           end.
           if sss2 > 0 then do:
               if v-str matches "*nds1*" then do:
                  v-str = replace (v-str, "nds1", string(sss2, ">>>>>>>>>9.99")).
                  next.
               end.
           end.
           else do:
               if v-str matches "*nds1*" then do:
                  v-str = replace (v-str, "nds1", "Без НДС").
                  next.
               end.
           end.
           if v-str matches "*pricends*" then do:
              v-str = replace (v-str, "pricends", string(sss3, ">>>>>>>>>9.99")).
              next.
           end.
           if v-str matches "*pricesum*" then do:
              v-str = replace (v-str, "pricesum", string(sss1, ">>>>>>>>>9.99")).
              next.
           end.
           if v-str matches "*ndssum*" then do:
              v-str = replace (v-str, "ndssum", string(sss2, ">>>>>>>>>9.99")).
              next.
           end.
           if v-str matches "*allsum*" then do:
              v-str = replace (v-str, "allsum", string(sss3, ">>>>>>>>>9.99")).
              next.
           end.
           if v-str matches "*oskd1*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"oskd1","").
                    else v-str = replace (v-str,"oskd1",v-platcode).
                end.
                else v-str = replace (v-str,"oskd1",v-platcode).
                next.
           end.
           if v-str matches "*heht2*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"heht2","").
                    else v-str = replace (v-str,"heht2",cmp.addr[2]).
                end.
                else v-str = replace (v-str,"heht2",cmp.addr[2]).
                next.
           end.
            if v-str matches "*KDG*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"KDG","").
                    else v-str = replace (v-str,"KDG","РНН").
                end.
                else v-str = replace (v-str,"KDG","РНН").
                next.
            end.

           leave.
         end.

      put stream s-out unformatted v-str skip.
      end.
   input close.
   output stream s-out close.
   unix silent cptwin value(v-ofile) winword.

end procedure.

procedure chetfact1:
    v-str = "".
    vnds = "".
    a = 1.
    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then director-name = sysc.chval.

    v-ifile = "ttt.htm" .
    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
    if avail pksysc then v-ifile = pksysc.chval + v-ifile.
    v-ofile = "ttt.htm" .
    output stream l-out to value(v-ofile).
    input from value(v-ifile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*l-cf*" then do:
                v-str = replace (v-str, "l-cf", l-cf ).
                next.
            end.
            if v-str matches "*dat2*" then do:
                v-str = replace (v-str, "dat2", ddd(dat2)).
                next.
            end.
            if v-str matches "*lkwrlkh*" then do:
                v-str = replace (v-str, "lkwrlkh", l-cmp).
                next.
            end.
            if v-str matches "*v-bankbin*" then do:
                v-str = replace (v-str, "v-bankbin", v-bankbin).
                next.
            end.
            if v-str matches "*vadd1*" then do:
                v-str = replace (v-str, "vadd1", vadd1).
                next.
            end.
            if v-str matches "*ndssvi*" then do:
                v-str = replace (v-str, "ndssvi", ndssvi).
                next.
            end.
            if v-str matches "*l-bb*" then do:
                v-str = replace (v-str, "l-bb", l-bb).
                next.
            end.
            if v-str matches "*kalhnadj*" then do:
                v-str = replace (v-str, "kalhnadj", l-ras).
                next.
            end.
            if v-str matches "*l-cifregdt*" then do:
                v-str = replace (v-str, "l-cifregdt", l-cifregdt).
                next.
            end.
            if v-str matches "*hhh1*" then do:
                v-str = replace (v-str, "hhh1", hhh1).
                next.
            end.
            if v-str matches "*hhh2*" then do:
                v-str = replace (v-str, "hhh2", hhh2).
                next.
            end.
            if v-str matches "*hhh3*" then do:
                v-str = replace (v-str, "hhh3", hhh3).
                next.
            end.
            if v-str matches "*ksdjhfghr*" then do:
                v-str = replace (v-str, "ksdjhfghr", l-cifbin).
                next.
            end.
            if v-str matches "*l-cifname*" then do:
                v-str = replace (v-str, "l-cifname", l-cifname).
                next.
            end.
            if v-str matches "*in_account*" then do:
                v-str = replace (v-str, "in_account", in_account).
                next.
            end.

            if v-str matches "*l-table*" and a = 1 then do:
                input stream h-out from "aktvko1.html".
                    v-str1 = substring(v-str,1,index(v-str, "l-table") - 1).
                    put stream l-out unformatted v-str1 skip.

                repeat:
                    import stream h-out unformatted v-str1.
                    put stream l-out unformatted v-str1 skip.
                end.
                if index(v-str, "l-table") > 0 then v-str = substring(v-str,index(v-str, "l-table") + 7,length(v-str) - index(v-str, "l-table") - 6).
                put stream l-out unformatted v-str skip.
                a = 2.
                next.
            end.
            if v-str matches "*sss1*" then do:
                v-str = replace (v-str, "sss1", string(sss1,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*vnds*" then do:
                v-str = replace (v-str, "vnds", vnds).
                next.
            end.
            if v-str matches "*sss2*" then do:
                v-str = replace (v-str, "sss2", string(sss2,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*sss3*" then do:
                v-str = replace (v-str, "sss3", string(sss3,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*director-name*" then do:
                v-str = replace (v-str, "director-name", director-name).
                next.
            end.
            if v-str matches "*buh-name*" then do:
                v-str = replace (v-str, "buh-name", buh-name).
                next.
            end.
            if v-str matches "*ofc-name*" then do:
                v-str = replace (v-str, "ofc-name", ofc-name).
                next.
            end.
            if v-str matches "*RNNSTN*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"RNNSTN","").
                    else v-str = replace (v-str,"RNNSTN","СТН/РНН").
                end.
                else v-str = replace (v-str,"RNNSTN","СТН/РНН").
                next.
            end.
            if v-str matches "*l-rnn*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"l-rnn","").
                    else v-str = replace (v-str,"l-rnn",l-rnn).
                end.
                else v-str = replace (v-str,"l-rnn",l-rnn).
                next.
            end.
            if v-str matches "*v-platcode*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"v-platcode","").
                    else v-str = replace (v-str, "v-platcode",v-platcode).
                end.
                else v-str = replace (v-str, "v-platcode",v-platcode).
                next.
            end.
            if v-str matches "*KDT*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"KDT","БСН").
                    else v-str = replace (v-str,"KDT","СТН").
                end.
                else v-str = replace (v-str,"KDT","СТН").
                next.
            end.
            if v-str matches "*RWT*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"RWT","БИН").
                    else v-str = replace (v-str,"RWT","РНН").
                end.
                else v-str = replace (v-str,"RWT","РНН").
                next.
            end.
            leave.
        end.

        put stream l-out unformatted v-str skip.
    end.
    input close.
    output stream l-out close.
    unix silent cptwin value(v-ofile) winword.
    /*unix silent rm ttt.htm.*/
end procedure.

procedure chetfact:
    v-str = "".
    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then director-name = sysc.chval.

    v-ifile = "ttt.htm" .
    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
    if avail pksysc then v-ifile = pksysc.chval + v-ifile.
    v-ofile = "ttt.htm" .
    output stream l-out to value(v-ofile).
    input from value(v-ifile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*l-cf*" then do:
                v-str = replace (v-str, "l-cf", l-cf ).
                next.
            end.
            if v-str matches "*dat2*" then do:
                v-str = replace (v-str, "dat2", ddd(dat2)).
                next.
            end.
            if v-str matches "*lkwrlkh*" then do:
                v-str = replace (v-str, "lkwrlkh", l-cmp).
                next.
            end.
            if v-str matches "*vadd1*" then do:
                v-str = replace (v-str, "vadd1", vadd1).
                next.
            end.
            if v-str matches "*v-bankbin*" then do:
                v-str = replace (v-str, "v-bankbin", v-bankbin).
                next.
            end.
            if v-str matches "*ndssvi*" then do:
                v-str = replace (v-str, "ndssvi", ndssvi).
                next.
            end.
            if v-str matches "*l-bb*" then do:
                v-str = replace (v-str, "l-bb", l-bb).
                next.
            end.
            if v-str matches "*kalhnadj*" then do:
                v-str = replace (v-str, "kalhnadj", l-ras).
                next.
            end.
            if v-str matches "*l-cifregdt*" then do:
                v-str = replace (v-str, "l-cifregdt", l-cifregdt).
                next.
            end.
            if v-str matches "*hhh1*" then do:
                v-str = replace (v-str, "hhh1", hhh1).
                next.
            end.
            if v-str matches "*hhh2*" then do:
                v-str = replace (v-str, "hhh2", hhh2).
                next.
            end.
            if v-str matches "*l-cifname*" then do:
                v-str = replace (v-str, "l-cifname", l-cifname).
                next.
            end.
            if v-str matches "*ksdjhfghr*" then do:
                v-str = replace (v-str, "ksdjhfghr", l-cifbin).
                next.
            end.
            if v-str matches "*hhh3*" then do:
                v-str = replace (v-str, "hhh3", hhh3).
                next.
            end.
            if v-str matches "*in_account*" then do:
                v-str = replace (v-str, "in_account", in_account).
                next.
            end.
            if v-str matches "*l-table*" then do:
                v-str = replace (v-str, "l-table", l-table).
                next.
            end.
            if v-str matches "*sss1*" then do:
                v-str = replace (v-str, "sss1", string(sss1,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*vnds*" then do:
                v-str = replace (v-str, "vnds", vnds).
                next.
            end.
            if v-str matches "*sss2*" then do:
                v-str = replace (v-str, "sss2", string(sss2,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*sss3*" then do:
                v-str = replace (v-str, "sss3", string(sss3,">>>>>>>>>9.99")).
                next.
            end.
            if v-str matches "*director-name*" then do:
                v-str = replace (v-str, "director-name", director-name).
                next.
            end.
            if v-str matches "*buh-name*" then do:
                v-str = replace (v-str, "buh-name", buh-name).
                next.
            end.
            if v-str matches "*ofc-name*" then do:
                v-str = replace (v-str, "ofc-name", ofc-name).
                next.
            end.
            if v-str matches "*RNNSTN*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"RNNSTN","").
                    else v-str = replace (v-str,"RNNSTN","СТН/РНН").
                end.
                else v-str = replace (v-str,"RNNSTN","СТН/РНН").
                next.
            end.
            if v-str matches "*l-rnn*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"l-rnn","").
                    else v-str = replace (v-str,"l-rnn",l-rnn).
                end.
                else v-str = replace (v-str,"l-rnn",l-rnn).
                next.
            end.
            if v-str matches "*v-platcode*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"v-platcode","").
                    else v-str = replace (v-str, "v-platcode",v-platcode).
                end.
                else v-str = replace (v-str, "v-platcode",v-platcode).
                next.
            end.
            if v-str matches "*KDT*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"KDT","БСН").
                    else v-str = replace (v-str,"KDT","СТН").
                end.
                else v-str = replace (v-str,"KDT","СТН").
                next.
            end.
            if v-str matches "*RWT*" then do:
                if v-bin then do:
                    if dat2 ge v-bin_rnn_dt then v-str = replace (v-str,"RWT","БИН").
                    else v-str = replace (v-str,"RWT","РНН").
                end.
                else v-str = replace (v-str,"RWT","РНН").
                next.
            end.
            leave.
        end.
        put stream l-out unformatted v-str skip.
    end.
    input close.
    output stream l-out close.
    unix silent cptwin value(v-ofile) winword.
    /*unix silent rm ttt.htm.*/
end procedure.


procedure reestr:
    output stream r-out to "rrr.html".

    for each b-involist where substring(b-involist.sts, 3, 1) = "O" no-lock:
        s-jh    = b-involist.jh.
        s-trx   = b-involist.trx.
        s-jl    = b-involist.ln.
        s-amt   = b-involist.amt1.
        v-amt   = b-involist.amt1.
        s-sts   = b-involist.sts.
        s-date  = b-involist.dat.
        s-jdt   = b-involist.jdt.
        s-glcom = b-involist.glcom.
        s-sumv  = b-involist.amt.
        s-num   = b-involist.num.
        s-faktur= b-involist.faktura.
        in_account = b-involist.acc.

        if s-jdt ne g-today then do:

            v-nazn = "Назначение платежа: ".

            if v-prizn = "FILPAYMENT" then do:
                find first comm.filpayment where comm.filpayment.jhcom = s-jh and comm.filpayment.bankfrom = v-txbase no-lock no-error.
                if avail comm.filpayment then in_account = comm.filpayment.iik.

                run CheckFilPay(no,no).
            end.
            else do:

                find jh where jh.jh = s-jh no-lock.
                find first jl where jl.jh = s-jh and jl.ln = s-jl no-lock no-error .


                def buffer b-kjl for jl.
                find first b-kjl where b-kjl.jh = s-jh and jl.ln = 1 no-lock no-error .
                if avail b-kjl then do:
                    in_account = b-kjl.acc.
                end.


                if not avail jl then do:
                    message " JL " + string(s-jh) + " Ln= " +
                    string(s-jl) + " не найдена " .
                    pause .
                    return .
                end.

                if trim(jl.rem[1]) begins "409 -" or trim(jl.rem[1]) begins "419 -"
                then do:
                   v-nazn = v-nazn + jl.rem[1].
                end.
                else if jh.sub = "JOU"
                then do:
                  find first joudoc where jh.ref  = joudoc.docnum
                     no-lock no-error .
                  if avail joudoc then
                     find tarif2 where tarif2.str5 = joudoc.comcode
                                   and tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.
                     if not available tarif2
                        then v-nazn = v-nazn + jl.rem[5].
                        else v-nazn = v-nazn + tarif2.pakalp.
                        if joudoc.comcode = "057" then v-nazn = v-nazn + jl.rem[1].
                end.
                else if jh.sub = "RMZ"
                then do:
                  find first remtrz where jh.ref = remtrz.remtrz no-lock
                     no-error .
                  if avail remtrz then
                     find tarif2 where tarif2.str5 = string(remtrz.svccgr)
                                   and tarif2.kont = jl.gl
                                   and tarif2.stat = 'r' no-lock no-error.
                     if not available tarif2
                        then v-nazn = v-nazn + jl.rem[5].
                        else v-nazn = v-nazn + tarif2.pakalp.
                end.
                else
                v-nazn = v-nazn + jl.rem[5].
                if v-nazn matches "*долг*" then
                v-nazn1  = substr(v-nazn,21 + 5) .
                else      v-nazn1  = substr(v-nazn,21) .
                if trim(v-nazn1) = '' then v-nazn1 = jl.rem[1].
            end.

            if v-selpvn = 1 then do:
                if k > 0 and dat-pvn = s-jdt then do:
                    if v-prizn = "FILPAYMENT" then do:
                        if t-InterBrh.gl = 287082 then v-gl = 460828.
                        else v-gl = t-InterBrh.gl.
                    end.
                    else do:
                        if jl.gl = 287082 then v-gl = 460828.
                        else v-gl = jl.gl.
                    end.
                    find first sub-cod where sub-cod.d-cod = "ndcgl" and
                    sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                    sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
                    if avail sub-cod then do:
                        put stream r-out unformatted "<tr><font size = 2 face='Calibri'><td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                        put stream r-out unformatted "<td>" + string(sf-nomer) + v-txb + "</td>"  skip.
                        put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                        put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                        put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                        put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
                    end.
                end.
                else do:
                    if v-prizn = "FILPAYMENT" then do:
                        if t-InterBrh.gl = 287082 then v-gl = 460828.
                        else v-gl = t-InterBrh.gl.
                    end.
                    else do:
                        if jl.gl = 287082 then v-gl = 460828.
                        else v-gl = jl.gl.
                    end.
                    find first sub-cod where sub-cod.d-cod = "ndcgl" and
                    sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                    sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
                    if avail sub-cod then do:
                        k = 0.
                        dat-pvn = s-jdt.
                        sf-nomer = s-faktur.
                        put stream r-out unformatted "<tr><font size = 2 face='Calibri'><td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                        put stream r-out unformatted "<td>" + string(s-faktur) + v-txb + "</td>"  skip.
                        put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                        put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                        put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                        put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
                    end.
                    k = k + 1.
                end.
            end.

          if v-selpvn = 2 then do:
              /*if not v-nazn1 matches "*с НДС*" then do:*/
                if v-prizn = "FILPAYMENT" then do:
                    if t-InterBrh.gl = 287082 then v-gl = 460828.
                    else v-gl = t-InterBrh.gl.
                end.
                else do:
                    if jl.gl = 287082 then v-gl = 460828.
                    else v-gl = jl.gl.
                end.
               find first sub-cod where sub-cod.d-cod = "ndcgl" and
                    sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                    sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
               if avail sub-cod then next.
               else do:
                    put stream r-out unformatted "<tr><font size = 2 face='Calibri'><td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                    put stream r-out unformatted "<td>" + string(s-faktur) + v-txb + "</td>"  skip.
                    put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                    put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                    put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                    put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
              end.
          end.

          if v-selpvn = 3 then do:
                if v-prizn = "FILPAYMENT" then do:
                    if t-InterBrh.gl = 287082 then v-gl = 460828.
                    else v-gl = t-InterBrh.gl.
                end.
                else do:
                    if jl.gl = 287082 then v-gl = 460828.
                    else v-gl = jl.gl.
                end.
                find first sub-cod where sub-cod.d-cod = "ndcgl" and
                sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
                if not avail sub-cod then do:
                    put stream r-out unformatted "<tr><font size = 2 face='Calibri'><td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                    put stream r-out unformatted "<td>" + string(s-faktur) + v-txb + "</td>"  skip.
                    put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                    put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                    put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                    put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
                end.
                else do:
                    if k > 0 and dat-pvn = s-jdt then do:

                        if v-prizn = "FILPAYMENT" then do:
                            if t-InterBrh.gl = 287082 then v-gl = 460828.
                            else v-gl = t-InterBrh.gl.
                        end.
                        else do:
                            if jl.gl = 287082 then v-gl = 460828.
                            else v-gl = jl.gl.
                        end.
                        find first sub-cod where sub-cod.d-cod = "ndcgl" and
                        sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                        sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
                        if avail sub-cod then do:

                            put stream r-out unformatted "<tr><font size = 2 face='Calibri'> <td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                            put stream r-out unformatted "<td>" + string(sf-nomer) + v-txb + "</td>"  skip.
                            put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                            put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                            put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                            put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
                        end.
                    end.
                    else do:
                        if v-prizn = "FILPAYMENT" then do:
                            if t-InterBrh.gl = 287082 then v-gl = 460828.
                            else v-gl = t-InterBrh.gl.
                        end.
                        else do:
                            if jl.gl = 287082 then v-gl = 460828.
                            else v-gl = jl.gl.
                        end.
                        find first sub-cod where sub-cod.d-cod = "ndcgl" and
                        sub-cod.ccode = "01" and sub-cod.sub = "gld" and
                        sub-cod.acc = /*string(jl.gl)*/ string(v-gl) no-lock no-error .
                        if avail sub-cod then do:
                            k = 0.
                            dat-pvn = s-jdt.
                            sf-nomer = s-faktur.

                            put stream r-out unformatted "<tr><font size = 2 face='Calibri'> <td>" + string(s-jdt, '99/99/9999') + "</td>"  skip.
                            put stream r-out unformatted "<td>" + string(s-faktur) + v-txb + "</td>"  skip.
                            put stream r-out unformatted "<td>" + in_account + "</td>"  skip.
                            put stream r-out unformatted "<td>" + string(s-glcom) + "</td>"  skip.
                            put stream r-out unformatted "<td align=Right>" + string(v-amt, ">>>>>>>>>9.99") + "</td>"  skip.
                            put stream r-out unformatted "<td>" + v-nazn1 + "</td></tr>"  skip.
                        end.
                        k = k + 1.
                    end.
                end.
          end.
        end. /* end if */
    end. /* for */

    a = 1.
    find sysc where sysc.sysc = 'DKPODP' no-lock no-error.
    if avail sysc then director-name = sysc.chval.

    v-ifile = "Reestr.htm" .
    find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
    if avail pksysc then v-ifile = pksysc.chval + v-ifile.
    v-ofile = "Reestr.htm" .
    output stream r-out to value(v-ofile).
    input from value(v-ifile).

    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*r-table*" and a = 1 then do:
                v-str1 = substring(v-str,1,index(v-str, "r-table") - 1).
                put stream r-out unformatted v-str1 skip.
                input stream h-out from "rrr.html".
                repeat:
                    import stream h-out unformatted v-str1.
                    put stream r-out unformatted v-str1 skip.
                end.
                if index(v-str, "r-table") > 0 then v-str = substring(v-str,index(v-str, "r-table") + 7,length(v-str) - index(v-str, "r-table") - 6).
                put stream r-out unformatted v-str skip.
                a = 2.
                next.
            end.
            if v-str matches "*sss3*" then do:
                v-str = replace (v-str, "sss3", string(sss3,">>>>>>>>>9.99")).
                next.
            end.

            leave.
        end.

        put stream r-out unformatted v-str skip.
     end.
     input close.
     output stream r-out close.
     unix silent cptwin Reestr.htm winword.exe.
     unix silent rm Reestr.htm.

end procedure.


procedure menu-prt3:
    DEFINE INPUT PARAMETER cFile AS char.
    DEFINE VARIABLE msg  AS CHARACTER EXTENT 8.
    DEFINE VARIABLE i    AS INTEGER INITIAL 1.
    DEFINE VARIABLE ikey AS INTEGER INITIAL 1.
    DEFINE VARIABLE newi AS INTEGER INITIAL 1.
    DEFINE VARIABLE ret  AS logical init false.

    DISPLAY SKIP(1)
    '[Просмотр]'  @ msg[1] ATTR-SPACE format 'x(8)'
    '[Печать]'    @ msg[2] ATTR-SPACE format 'x(6)'
    '[Реестр]'    @ msg[3] ATTR-SPACE format 'x(7)'
    '[Акт]'       @ msg[4] ATTR-SPACE format 'x(4)'
    '[ЛОГОТИП]'   @ msg[5] ATTR-SPACE format 'x(4)'
    '[Email]'     @ msg[6] ATTR-SPACE format 'x(3)'
    '[Выход]'     @ msg[7] ATTR-SPACE format 'x(5)'
    WITH CENTERED FRAME menu ROW 05 NO-LABELS
    TITLE '[ Документ сформирован! Выберите: ]' overlay.

    REPEAT WITH FRAME menu:
        REPEAT:
            COLOR DISPLAY MESSAGES msg[i] WITH FRAME menu.
            READKEY.
            CASE KEYFUNCTION(LASTKEY):
                WHEN 'CURSOR-RIGHT' THEN
                    DO:
                        newi = i + 1.
                        IF newi > 7 THEN newi = 1.
                    END.
                WHEN 'CURSOR-LEFT' THEN
                    DO:
                        newi = i - 1.
                        IF newi < 1 THEN newi = 7.
                    END.
                WHEN 'RETURN'    THEN LEAVE.
                WHEN 'GO'        THEN LEAVE.
                WHEN 'END-ERROR' THEN do: HIDE FRAME menu no-pause. return. end.
                WHEN 'ENDKEY'    THEN do: HIDE FRAME menu no-pause. return. end.
            END CASE.

            IF i <> newi THEN COLOR DISPLAY NORMAL msg[i] WITH FRAME menu.
            i = newi.
        END.

        CASE i:
            WHEN 1 THEN unix value( 'joe -rdonly ' + cFile ).
            WHEN 2 THEN if l-kol = 1 then run chetfact. else run chetfact1.
            WHEN 3 THEN if l-kol = 2 then run reestr.
            WHEN 4 THEN if cmp.code = 14 then run oneSF-VKO in this-procedure. else run PrintAkt.
            WHEN 5 THEN  run logt.
            WHEN 6 THEN run email-prt(cFile).
            WHEN 7 THEN DO: HIDE FRAME menu no-pause. return. end.
            Otherwise leave.
        END CASE.

    END.

    HIDE FRAME menu no-pause.
end procedure.


procedure logt:
    displ skip(1) "    Ждите...   " skip(1) with row 8 centered overlay frame f-wait.

    def var v-dcpath as char.
    def var v-dcsign as char.
    def var v as char.
    def var v-str2 as char.
    def var s-tempfolder as char.

    /* определение каталога для копий файлов на локальной машине юзера */
    input through localtemp.
    repeat:
      import s-tempfolder.
    end.
    input close.
    pause 5 no-message.
    if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

    v-dcpath = "/data/docs/".

    create t-files.
    t-files.name = v-dcpath + "sf.jpg".
    t-files.fname = "sf.jpg".
    create t-files.
    t-files.name = v-dcpath + "sf1.jpg".
    t-files.fname = "sf1.jpg".
    for each t-files.
        /* копируем файл */
        v-str2 = "".
        input through value("cpy -put " + t-files.name + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
        repeat:
            import v.
        end.
        input close.
        pause 3 no-message.

        if v <> "0" then do:
            if v-str2 <> "" then v-str2 = v-str2 + "; ".
            v-str2 = v-str2 + t-files.fname.
        end.

        hide frame f-wait no-pause.
        if v-str2 <> "" then do:
          message skip " Во время копирование логотипа произошла ошибка !"
                  skip " Файлы :" v-str2
                  skip(1) " Обратитесь к системному администратору !"
                  skip(1) view-as alert-box title " ОШИБКА ! ".
            return.
        end.
    end.
   message skip " Копирование логотипа завершено !" skip(1) view-as alert-box title "".
   return.

end procedure.

procedure email-prt.
 DEFINE INPUT PARAMETER cFile AS char.
 def var ourdomen as char init '@metrocombank.kz'.
 def var email    as char init '' format "x(14)".
 unix SILENT value('cat ' + cFile + ' | koi2win  > tmp.txt; mv -f tmp.txt ' + 'mail-' + trim(cFile) ).

 update "Введите емайл" email validate(test_email(email),"Вы ввели недопустимые символы !") no-label
        "@metrocombank.kz" with overlay centered frame email title " Введите email ".

 run mail(email + "@metrocombank.kz", userid("bank") + "@metrocombank.kz",
          "You have mail from " + userid("bank") + " (" + string(time,"HH:MM:SS") + " " +
          string(day(today),'99.') + string(month(today),'99.') + string(year(today),'9999') + ")",
          "", "", "", 'mail-' + trim(cFile)).

 run savelog("email", "menu-prt " + userid("bank") + " " + cFile + " " + email).
 unix SILENT value('rm -f mail-' + trim(cFile)).
 hide frame email.
 pause 0.
end.

/*--------------------------------------------------------------------------------------------------------------------------------*/

procedure Inter-Branch:
    def var qh as handle.

    def buffer b-filpayment for comm.filpayment.

    CREATE QUERY qh.
    qh:SET-BUFFERS('b-filpayment').

    empty temp-table t-InterBrh.
    empty temp-table t-work.

    v_TXB = ''.

    qh:QUERY-CLOSE().
    qh:QUERY-PREPARE("for each b-filpayment where b-filpayment.cif eq '" + s-cif + "' and (b-filpayment.iik eq '" + s-hacc
                      + "' or '" + s-hacc + "' eq '' or '" + s-hacc + "' eq 'ALL') no-lock").
    qh:QUERY-OPEN().
    qh:GET-FIRST().

    if avail b-filpayment then do:
        qh:GET-FIRST().
        repeat:
            if lookup(trim(b-filpayment.bankfrom),trim(v_TXB)) = 0 then do:
                if v_TXB <> "" then v_TXB = v_TXB + ',' + trim(b-filpayment.bankfrom).
                else v_TXB = trim(b-filpayment.bankfrom).
            end.

            create t-work.
            t-work.txb = trim(b-filpayment.bankfrom).
            t-work.docnum = trim(b-filpayment.jou).
            t-work.jh = b-filpayment.jhcom.

            qh:GET-NEXT().
            if qh:QUERY-OFF-END then leave.
        end.
    end.
    else do:
        message "Межфилиальных платежей по этому клиенту не найдено!".
        pause 0.
    end.

    qh:QUERY-CLOSE().

    /*-----Сбор данных в филиалах, в которых были межфилиальные операции------*/

    {r-branchSEL.i &proc = "str_strx_txb"}

    /*------------------------------------------------------------------------*/

    qh:QUERY-OPEN().
    qh:GET-FIRST().
    if avail b-filpayment then do:
        qh:GET-FIRST().
        repeat:
            if b-filpayment.whn ge dat1 and b-filpayment.whn le dat2 then do:
                find first t-InterBrh where t-InterBrh.jh = b-filpayment.jhcom and trim(t-InterBrh.txb) = trim(b-filpayment.bankfrom) no-lock no-error.
                if avail t-InterBrh then do:
                    cocode = "".
                    if t-InterBrh.comcode ne "" then cocode = t-InterBrh.comcode.
                    else if t-InterBrh.who eq "BANKADM" then cocode = '106'.
                    else do:
                        if t-InterBrh.party ne "" then cocode = entry(1,t-InterBrh.party," ").
                        iii = integer(cocode) no-error.
                        if error-status:error then cocode = "".
                    end.

                    find first involist where involist.jh = b-filpayment.jhcom and involist.ln = t-InterBrh.ln no-lock no-error.
                    if not available involist and ((s-tarif = "ALL") or (cocode = s-tarif)) then do:
                        i = i + 1.
                        create involist.
                        involist.amt = b-filpayment.amountcom.
                        involist.acc = b-filpayment.iik.
                        involist.glcom = t-InterBrh.gl.
                        involist.dat = g-today.
                        involist.sts = "OOO".
                        involist.who = t-InterBrh.who.
                        involist.num = i.
                        involist.jh = b-filpayment.jhcom.
                        involist.trx = t-InterBrh.trx.
                        involist.ln = t-InterBrh.ln.
                        involist.jdt = t-InterBrh.jdt.
                        involist.comcode = cocode.
                        involist.crc = t-InterBrh.crc.
                        involist.rate = 1.
                        if involist.crc ne 1 then do:
                           find last crchis where crchis.crc eq involist.crc and crchis.rdt < involist.jdt no-lock no-error.
                           involist.rate = crchis.rate[1] / crchis.rate[9].
                        end.

                        find crc where crc.crc eq involist.crc no-lock no-error.
                        involist.crcode = crc.code.
                        if involist.jdt eq g-today and involist.crc ne 1 then do:
                           involist.rate = crc.rate[1] / crc.rate[9].
                        end.

                        involist.amt1 = round(involist.amt * involist.rate,2).
                        involist.prizn = "FILPAYMENT".
                        involist.txb = t-InterBrh.txb.

                        find last fakturis where fakturis.jh eq b-filpayment.jhcom and fakturis.trx = t-InterBrh.trx and
                        fakturis.ln eq t-InterBrh.ln use-index jhtrxln no-lock no-error.
                        if available fakturis then do:
                           involist.sts = fakturis.sts.
                           involist.who = fakturis.who.
                           involist.dat = fakturis.rdt.
                           involist.tim = fakturis.tim.
                           involist.faktura = fakturis.faktura.
                        end.
                    end.
                end.
                /*else do:
                    message "Не найдена проводка " b-filpayment.jhcom " в филиале!" view-as alert-box.
                    return.
                end.*/
            end.
            qh:GET-NEXT().
            if qh:QUERY-OFF-END then leave.
        end.
    end.
    qh:QUERY-CLOSE().
    DELETE OBJECT qh.
end procedure.
/*-------------------------------------------------------------------------------------------------------------------------------*/
procedure CheckFilPay:
    def input parameter p-input1 as logi.
    def input parameter p-input2 as logi.

    find t-InterBrh where t-InterBrh.jh = s-jh and t-InterBrh.ln = s-jl and t-InterBrh.txb = v-txbase no-lock no-error.
    if not avail t-InterBrh then do:
        message " t-InterBrh " + string(s-jh) + " Ln= " + string(s-jl) + " не найдена " view-as alert-box.
        pause .
        return .
    end.
    if p-input1 then    if trim(t-InterBrh.rem[1]) begins "409 -" or trim(t-InterBrh.rem[1]) begins "419 -"
                        or trim(t-InterBrh.rem[1]) begins "429 -" or trim(t-InterBrh.rem[1]) begins "430 -"
                        then v-nazn = v-nazn + t-InterBrh.rem[1].
    else    if trim(t-InterBrh.rem[1]) begins "409 -" or trim(t-InterBrh.rem[1]) begins "419 -"
            then v-nazn = v-nazn + t-InterBrh.rem[1].

    else if t-InterBrh.sub = "JOU" then do:
        if t-InterBrh.ref  = t-InterBrh.docnum then do:
            find tarif2 where tarif2.str5 = t-InterBrh.comcode and tarif2.kont = t-InterBrh.gl and tarif2.stat = 'r' no-lock no-error.
            if not available tarif2 then v-nazn = v-nazn + t-InterBrh.rem[5].
                                    else v-nazn = v-nazn + tarif2.pakalp.
        end.
    end.
    else if t-InterBrh.sub = "RMZ" then do:
        if t-InterBrh.ref = t-InterBrh.remtrz then do:
            find tarif2 where tarif2.str5 = string(t-InterBrh.svccgr) and tarif2.kont = t-InterBrh.gl and tarif2.stat = 'r' no-lock no-error.
            if not available tarif2 then v-nazn = v-nazn + t-InterBrh.rem[5].
                                    else v-nazn = v-nazn + tarif2.pakalp.
        end.
    end.
    else v-nazn = v-nazn + t-InterBrh.rem[5].

    if v-nazn matches "*долг*"  then v-nazn1 = substr(v-nazn, 21 + 5).
                                else v-nazn1 = substr(v-nazn, 21).

    if trim(v-nazn1) = '' then v-nazn1 = t-InterBrh.rem[1].

    if p-input2 then v-operdt = t-InterBrh.jdt.
end procedure.

/*--------------------------------------------------------------------------------------------------------------------------------*/

