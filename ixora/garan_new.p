/* garan_new.p
 * MODULE
      Операции
 * DESCRIPTION
      Открытие новых гарантий с записью информации по гарантии в отдельную таблицу
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19/05/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        21/05/2010 galina - не позволяем выходить из гарантии, если нет проводки
        02/07/2010 galina - поправила удаление транзакции из garan
        29/06/2010 k.gitalov - добавил поле "Тип гарантии"
        09/09/2010 galina - добавила учет и списание обеспечения
                            поправила комментарии для проводок по выдачи гарантии и по списанию комиссии согласно замечаниям аудиторов
        13/12/2010 madiyar - указал явно ширину фрейма с кнопками
        23/02/2011 evseev - перекомпиляция из-за изменения garan_new.f
        26.05.2011 ruslan - добавил переменные s-aaa, s-cif, а также кнопку "документы" для распечатки распоряжения на выдачу гарантии.
        29/06/2011 id00810 - временно!!! ограничение на операции (nbrk)
        01/07/2011 id00810 - номер гарантии v-nomgar, статус и классификация
        30/09/2011 lyubov - добавила кнопки "выход" и "изм.карточки", кнопка "редактирование" стала доступной после осуществления транзакции
        15/11/2011 lyubov - доступ к "ТРАНЗАКЦИЯ", "УДАЛИТЬ(КОМИССИЯ)" и "УДАЛИТЬ" только у польз-й с пакетами доступа p00167, p00168; убрала вывод сообщения при выходе по F4
        29/11/2011 lyubov - исправила проверку пакетов доступа
        14/12/2011 id00810 - новые правила по учету комиссий при выдаче и гашении
        25/01/2012 id00810 - уточнен алгоритм определения счета доходов при погашении
        01.02.2012 lyubov - изменила символ кассплана (200 на 100)
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        15.06.2012 Lyubov - иземенения по ТЗ №1396
        23/01/2013 Luiza - ТЗ №1666 при редактировании данных гарантии сохранять сумму с амортизированной комиссии
        07/03/2013 sayat(id01143) - ТЗ 1707 от 07/02/2013 добавлено поле "Страна бенефициара"
        12/04/2013 Sayat(id01143) - ТЗ 1762 от 13/03/2013 добавлены поля "N доп.согл.к договору" и "Дата доп.соглашения"
        14/06/2013 galina - ТЗ1552
        18/07/2013 Sayat(id01143) - ТЗ 1637 от 28/12/2012 "Доработка модуля по залогам" добавлена возможность корректировки дат действия залогов
        02/09/2013 galina - ТЗ 1918
        03/08/2013 galina - явно указала ширину фрейма rmzf
        03/08/2013 galina - ТЗ2062 доступ к кнопкам «Погасить», «Требование бенефициара», «Дебиторская задолженность», «Резерв», «Просроченная комиссия» только для пакетов р00168 и р00167
*/

{mainhead.i}

def var s_account_a as char no-undo.
def var s_account_b as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.
def var v_doc as char no-undo.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then c-gl = sysc.inval.
else c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then c-gl1002 = sysc.inval.
else c-gl1002 = 100200.

def var v-yn  as log init false no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err as log init false no-undo. /*получаем признак возникновения ошибки*/

def new shared var s-jh like jh.jh.
def new shared var s-aaa like aaa.aaa.
def new shared var s-cif like cif.cif.
def new shared variable s-lon like lon.lon.
def new shared variable v-cif like cif.cif init "".
def new shared variable s-dt     as date.
/*def var v-cif as char no-undo.*/
def new shared var v-name as char no-undo.
def new shared var v-rnn as char no-undo.

def new shared var vaaa like aaa.aaa.
def new shared var vaaa2 like aaa.aaa.
def var vcif like cif.name.
def var vcif2 like cif.name.
def new shared var vsum as deci no-undo.

def new shared var dfrom as date no-undo.
def new shared var dtdop as date no-undo.
def new shared var dto as date no-undo.
def new shared var v-garan as char no-undo.
def new shared var v-gardop as char no-undo.
def new shared var v-bankben as char no-undo.
def new shared var v-naim as char no-undo.
def new shared var v-address as char no-undo.
def new shared var v-codfr as char no-undo.
def new shared var vobes as char no-undo.
def var v-eknp as char no-undo init '182' .
def var ListType as char format "x(20)" VIEW-AS COMBO-BOX LIST-ITEMS "Конкурсная/Тендерная", "Другое".
def new shared var IntType as int init 2.

def new shared var remark as char.

def new shared var v-fname as char no-undo.
def new shared var v-lname  as char no-undo.
def new shared var v-mname as char no-undo.
def new shared var v-benres as int no-undo.
def new shared var v-benrdes as char no-undo.
def new shared var v-bentdes as char no-undo.
def new shared var v-bentype as int no-undo.

def new shared var v-bencount as char no-undo.
def new shared var v-bencountr as char no-undo.

def var v-new as logi init yes.
def var v-select as integer no-undo.

def var rem1 as char.
def var rem2 as char.
def var rem3 as char.
def var rem4 as char.
def var rem5 as char.

def new shared var sumtreb as decimal .
def new shared var vcrc like crc.crc.

def new shared var vaaa3 like aaa.aaa.
def new shared var vcrc3 like crc.crc.
def new shared var sumkom as decimal no-undo.
def new shared var sumzalog as decimal no-undo.
def new shared var v-crczal like crc.crc.
def var v-ans as logi.
def var vdel as char initial "^".
def var vparam as char.
def var vparam2 as char.
def new shared var v-jh like jh.jh init 0.
def new shared var v-jh2 like jh.jh init 0.
def var rcode as inte.
def var rdes as char.
def var v-crcgar as char.
def var v-zalcrc as char.
def var v-comcrc as char.


def var v-templ as char.

def var ja as log format "да/нет".
def var vou-count as int initial 1.
def var i as int.
def var v-pog as logi init yes no-undo.

def buffer baaa for aaa.
def buffer bcrc for crc.

def var idx as int.
def var id1 as int.

def new shared var v-jdt as date no-undo.
def new shared var v-our as log no-undo.
def new shared var v-lon as log no-undo.
def var v-finish as log no-undo.
def var v-cash as log no-undo.
def var v-cashgl as integer no-undo.
def var v-sts as int no-undo.
def new shared var v-nomgar as char no-undo.

def var v-crcname  as char.
def var v-crc3name as char.
def var v-crczname as char.
def var v-gldoh    as char.
def var v-rem      as char.
def new shared var dcom as date no-undo.

define button b1      label "НОВЫЙ".
define button b2      label "ПОИСК".
define button b-upd   label "РЕДАКТИРОВАТЬ".
define button b-obes  label "ОБЕСПЕЧЕНИЕ".
/*define button b-usl   label "УСЛ.ОБЯЗ-ВА".*/
define button b-trx   label "ТРАНЗАКЦИЯ".
define button b3      label "УДАЛИТЬ КОМ.".
define button b4      label "УДАЛИТЬ".
define button b-pog   label "ПОГАСИТЬ".
define button b-doc   label "ДОКУМЕНТЫ".
define button b-sts   label "СТАТУС".
define button b-klass label "КЛАССИФ.".
define button b-chc   label "ИСТОРИЯ ИЗМ.".
define button b-ext   label "ВЫХОД".
define button b-mon   label "МОНИТОРИНГ".

/*Galina*/
{chk12_innbin.i}
{chkaaa20.i}
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

def var v-select1 as integer.
def new shared var  s-remtrz like remtrz.remtrz.
def new shared var m_pid like bank.que.pid.
def new shared var v-text as char.
def new shared var m_hst as char.
def new shared var m_copy as char.
def new shared var u_pid as cha.


define button b-bentreb label "ТРЕБ.БЕНЕФИЦИАРА".
define button b-debpog label "ДЕБИТ.ЗАДОЛЖЕННОСТЬ".
define button b-rezerv label "РЕЗЕРВ".
define button b-graf label "ГРАФИК КОМИССИИ".
define button b-proscom label "ПРОС.КОМИССИЯ".

def buffer b-jl for jl.
def var v-amttreb as deci.
def var v-amttrebhis as deci.
def var v-title as char.
def var v-validate as char.
def var v-sumgar as deci.
def var v-comsum as deci.
def var v-form as logi.
def var v-amtvalid as deci.
def var v-arp as char.
def var v_swibic as char.
def var v-bbankn as char.
def var v-accben as char.
def var v_kod as char.
def var v_kbe as char.
def var v-benbin as char.
def var v_knp as char.
def var v_nazn1 as char.
def var v_nazn2 as char.
def var v_nazn3 as char.
def var v_nazn4 as char.
def var v_nazn5 as char.
def var v_nazn6 as char.
def var v_nazn as char.
def var v-cover as int.
def var v-smepamt like remtrz.payment.
def var v-naim2 as char.
def var v-covern as char.
def var v_rmzdoc as char.
def var l-ans as logi.
def var v-dtval2 as date.
def var v-sel as char.
def var v-acc as char.

def new shared var v-grcom as logi.
def new shared var v-mcomsum as deci.
def new shared var v-mcom% as deci.
def new shared var v-mlstdate as logi.
def var v-mcom%_old as deci.

def temp-table tmprez1
    field des as char.
    create tmprez1. tmprez1.des = "11-(Центальн Правит/резидент)".
    create tmprez1. tmprez1.des = "12-(Рег и местн орг.управл/резидент)".
    create tmprez1. tmprez1.des = "13-(Центральн нац банки/резидент)".
    create tmprez1. tmprez1.des = "14-(Др.депозит орг/резидент)".
    create tmprez1. tmprez1.des = "15-(Др. финанс орг/резидент)".
    create tmprez1. tmprez1.des = "16-(Гос нефинанс орг/резидент)".
    create tmprez1. tmprez1.des = "17-(Негос нефинанс орг/резидент)".
    create tmprez1. tmprez1.des = "18-(Неком орг., обслуж дом хоз/резидент)".
    create tmprez1. tmprez1.des = "19-(домаш хоз/резидент)".
    create tmprez1. tmprez1.des = "21-(Центальн Правит/нерезидент)".
    create tmprez1. tmprez1.des = "22-(Рег и местн орг.управл/нерезидент)".
    create tmprez1. tmprez1.des = "23-(Центральн нац банки/нерезидент)".
    create tmprez1. tmprez1.des = "24-(Др.депозит орг/нерезидент)".
    create tmprez1. tmprez1.des = "25-(Др. финанс орг/нерезидент)".
    create tmprez1. tmprez1.des = "26-(Гос нефинанс орг/нерезидент)".
    create tmprez1. tmprez1.des = "27-(Негос нефинанс орг/нерезидент)".
    create tmprez1. tmprez1.des = "28-(Неком орг., обслуж дом хоз/нерезидент)".
    create tmprez1. tmprez1.des = "29-(домаш хоз/нерезидент)".


form
v-amttreb label "Сумма" format ">>>>>>>>>>>9.99"
validate (v-amttreb > 0 and v-amttreb <= v-amtvalid, v-validate + trim(string(v-amtvalid,">>>>>>>>>>>9.99")))
with frame summa centered side-label title v-title overlay row 8 .

form
v-acc label "Расчетный счет" format "x(20)"
validate(can-find(aaa where aaa.aaa = v-acc and aaa.cif = v-cif and aaa.crc = vcrc no-lock), " Счет клиента не найден или валюта счета не равна валюте гарантии! ") help "F2 - помощь"
with frame faaa centered side-label title v-title overlay row 8 .

form
v-acc label "Расчетный счет" format "x(20)" validate(can-find(aaa where aaa.aaa = v-acc and aaa.cif = v-cif and aaa.crc = vcrc no-lock), " Счет клиента не найден или валюта счета не равна валюте гарантии! ") help "F2 - помощь" skip
v-comsum label "Сумма комиссии" validate(v-comsum > 0,'Сумма комиссии должна быть больше нуля!')
with frame fcom centered side-label title v-title overlay row 8 .


on help of v-acc in frame faaa do:
    def buffer bbaaa for aaa.
    find first bbaaa where bbaaa.aaa = vaaa2 no-lock no-error.
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 /*use-index aaa-idx1*/ no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "1"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 "
            &findadd = " v-crcname = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crcname = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crcname label 'Валюта' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-acc = aaa.aaa.
        displ v-acc with frame faaa.
    end.
end.

on help of v-acc in frame fcom do:
    def buffer bbaaa for aaa.
    find first bbaaa where bbaaa.aaa = vaaa2 no-lock no-error.
    find first aaa where aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = bbaaa.crc and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 /*use-index aaa-idx1*/ no-lock no-error.
    if avail aaa then do:
        {itemlist.i
            &set = "1"
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.crc = 1 and lookup(substr(string(aaa.gl),1,4),'2203,2204') > 0 "
            &findadd = " v-crcname = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crcname = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crcname label 'Валюта' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-acc = aaa.aaa.
        displ v-acc with frame fcom.
    end.
end.
on "end-error" of frame fcom do:
   hide frame fcom no-pause.
end.

form
     v-name label    'Отправитель        ' format "x(60)"
     cif.bin label   'БИН/ИИН отправителя' format "x(12)" skip
     v_kod label     'КОД                ' format "x(2)"  skip
     v-arp     label 'Транзитный счет' format "x(20)" skip
     v-amttreb label 'Сумма              ' format ">>>>>>>>>>>9.99" validate (v-amttreb > 0 and v-amttreb <= v-amtvalid, v-validate + trim(string(v-amtvalid,">>>>>>>>>>>9.99"))) v-crcname no-label format 'x(3)' skip
     v-naim2 label    'Получатель         ' format "x(60)" skip
     v-benbin label  'ИИН/БИН получателя ' format "x(12)" validate(chk12_innbin(v-benbin), " Неверный ИИН/БИН бенефециара! ") skip
     v_swibic label  'БИК банка          '  format "x(11)" validate(can-find(bankl where bankl.bank = v_swibic no-lock),'Неверный БИК, F2-помощь') v-bbankn no-label format 'x(40)' skip
     /*v-bncount label 'Страна резидентства' format "x(2)" validate(can-find(first codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" and  codfr.code = v-bncount no-lock), "Нет такого кода страны! F2-помощь") v-bncountn no-label format 'x(20)' skip*/
     v-accben  label 'Cчет получателя    ' format "x(20)" validate( length(trim(v-accben)) = 20 and chkaaa20 (trim(v-accben)), "Введите счет верно !") skip
     v_kbe     label 'КБе                ' format "x(2)" validate((int(v_kbe) >= 11 and int(v_kbe) <= 19) or (int(v_kbe) >= 21 and int(v_kbe) <= 29), "Неверный КБе, F2-помощь")
     v_knp     label '   КНП' format "x(3)" validate(trim(v_knp) <> "", " КНП обязателено для заполнения! F2-помощь")
     v-cover   label '   Транспорт' format "9" v-covern no-label format "x(8)" skip
     v-dtval2  label 'Дата валютрования  ' format "99/99/9999" validate (v-dtval2 <> ? and v-dtval2 >= today,'Неверная дата валютирования!') skip
     v_nazn1   label 'Назначение платежа ' format "x(68)" skip
     v_nazn2   label 'Назначение платежа ' format "x(68)" skip
     v_nazn3   label 'Назначение платежа '  format "x(68)" skip
     v_nazn4   label 'Назначение платежа '  format "x(68)" skip
     v_nazn5   label 'Назначение платежа '  format "x(68)" skip
     v_nazn6   label 'Назначение платежа '  format "x(68)" skip
     with side-label frame rmzf column 2 row 8 centered overlay  title "ДАННЫЕ ПЕРЕВОДА" width 100.



on help of v_swibic in frame rmzf do:
{itemlist.i
       &file = "bankl"
       &where = "not bankl.bank begins 'txb'"
       &form = "bankl.bank bankl.name form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "bankl.bank bankl.name"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
  v_swibic = frame-value.
  find first bankl where bankl.bank = v_swibic no-lock no-error.
  if avail bankl then v-bbankn = bankl.name.
  displ v_swibic v-bbankn with frame rmzf.
end.

DEFINE QUERY q-knp FOR codfr.
DEFINE BROWSE b-knp QUERY q-knp
       DISPLAY codfr.code label "Код " format "x(3)" codfr.name[1] + codfr.name[2] + codfr.name[3] label "Наименование " format "x(60)"  WITH  15 DOWN.
DEFINE FRAME f-knp b-knp  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 20 width 80 NO-BOX.

on help of v_knp in frame rmzf do:
    OPEN QUERY  q-knp FOR each codfr where codfr.codfr = "spnpl" use-index cdco_idx no-lock.
    ENABLE ALL WITH FRAME f-knp.
    wait-for return of frame f-knp
    FOCUS b-knp IN FRAME f-knp.
    v_knp = codfr.code.
    displ v_knp with frame rmzf.
    hide FRAME f-knp.

end.


DEFINE QUERY q-rez1 FOR tmprez1.
DEFINE BROWSE b-rez1 QUERY q-rez1
       DISPLAY tmprez1.des label "Резидентство " format "x(35)" WITH  20 DOWN.
DEFINE FRAME f-rez1 b-rez1  WITH overlay 1 COLUMN SIDE-LABELS row 9 COLUMN 55 width 45 NO-BOX.



on help of v_kbe in frame rmzf do:
    OPEN QUERY  q-rez1 FOR EACH tmprez1 no-lock.
    ENABLE ALL WITH FRAME f-rez1.
    wait-for return of frame f-rez1
    FOCUS b-rez1 IN FRAME f-rez1.
    v_kbe = substring(tmprez1.des,1,2).
    hide frame f-rez1.
    displ v_kbe with frame rmzf.
end.


function get_amt returns deci (p-acc as char, p-gl as integer, p-lev as integer, p-dt as date, p-sub as char, p-crc as integer).
  def var v-amt as deci.
  v-amt = 0.
  if p-dt < g-today then do:
    find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = p-lev and histrxbal.crc = p-crc and histrxbal.dt <= p-dt  no-lock no-error.
    if avail histrxbal then do:
      find first trxlevgl where trxlevgl.gl  = p-gl and trxlevgl.level = p-lev no-lock no-error.
      if avail trxlevgl then do:
          find first gl where gl.gl = trxlevgl.glr no-lock no-error.
          if avail gl then do:
              if gl.type eq "A" or gl.type eq "E" then
                   v-amt = histrxbal.dam - histrxbal.cam.
              else v-amt = histrxbal.cam - histrxbal.dam.
          end.
      end.
    end.

  end.
  if p-dt = g-today then do:
    find first trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc and trxbal.level = p-lev and trxbal.crc = p-crc no-lock no-error.
    if avail trxbal then do:
      find first trxlevgl where trxlevgl.gl = p-gl and trxlevgl.level = p-lev no-lock no-error.
      if avail trxlevgl then do:
          find gl where gl.gl  = trxlevgl.glr no-lock no-error.
          if avail gl then do:
              if gl.type eq "A" or gl.type eq "E" then
                   v-amt = trxbal.dam - trxbal.cam.
              else v-amt = trxbal.cam - trxbal.dam.
          end.
      end.
    end.

  end.
  return v-amt.
end.
/*galina*/
def var lvr as logi.
def var old_sumcom as decimal.


old_sumcom = 0.

find first sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then v-cashgl = sysc.inval.
else v-cashgl = 100100.

define frame a2
    b1 b2 b-upd b-obes /*b-usl*/ b-trx b3 b4 b-pog b-doc b-sts b-klass b-chc b-mon b-bentreb b-debpog b-rezerv b-graf b-proscom b-ext
    with width 110 side-labels row 3 no-box.
{garan_new.f}

ON VALUE-CHANGED OF ListType
DO:
   IntType = SELF:LOOKUP(SELF:SCREEN-VALUE) no-error.
   APPLY "GO" TO ListType IN FRAME garan0.
END.

lvr = false.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
    idx = index(ofc.expr[1], 'p00168').
    id1 = index(ofc.expr[1], 'p00167').
    if idx <> 0 or id1 <> 0 then
    lvr = false. else lvr = true.
end.

/* редактировать */
on choose of b-upd in frame a2 do:
    repeat:
        /*if g-ofc begins 'nbrk' then do:
            message "У вас нет прав на операцию редактирования гарантии!" view-as alert-box title "ВНИМАНИЕ".
            return.
        end.*/
        run updgaran.
        v-select = 0.
        run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ ПО ГАРАНТИИ :"," 1. Сохранить гарантию и выйти | 2. Не сохранять гарантию и выйти | 3. Вернуться к редактированию гарантии ", output v-select).
        if v-select = 1 or v-select = 2 then leave.
    end.  /*repeat*/
        /*создаем запись в гарантиях*/
    run savegaran.
end.

/* новый */
on choose of b1 in frame a2 do:

    assign v-cif     = ''
           v-name    = ''
           v-rnn     = ''
           v-jh      = 0
           vaaa2     = ''
           vsum      = 0
           v-garan   = ''
           v-gardop  = ''
           v-nomgar  = ''
           vaaa      = ''
           dfrom     = ?
           dtdop     = ?
           dto       = ?
           v-codfr   = ''
           vobes     = ''
           sumzalog  = 0
           v-crczal  = 0
           sumtreb   = 0
           vcrc      = 0
           vaaa3     = ''
           v-jh2     = 0
           vcrc3     = 0
           sumkom    = 0
           dcom      = g-today
           v-bankben = ''
           v-naim    = ''
           v-address = ''
           v-fname   = ''
           v-lname   = ''
           v-mname   = ''
           v-benres  = 0
           v-benrdes = '' /*'резидент'*/
           v-bentdes = '' /*'Юридическое лицо'*/
           v-bentype = 0
           v-bencount = ''
           v-bencountr = ''
           s-lon     = ''.
           v-grcom = no.
           v-mcomsum = 0.
           v-mcom% = 0.
           v-mlstdate = no.
           /*v-mdate = ?.*/
           run showinfo.

    repeat:
        update v-cif with frame garan0.
        find cif where cif.cif = v-cif no-lock no-error.
        if avail cif then do:
            v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
            v-rnn = cif.jss.
            display v-name with frame garan0.
        end.

        /*счет депозит-гарантия*/
        update vaaa2 with frame garan0.

        find baaa where baaa.aaa = vaaa2 no-lock no-error.
        if not available baaa then do:
            message "Счет " + vaaa2 + " не существует!" view-as alert-box title 'ВНИМАНИЕ!'.
            pause.
            next.
        end.

        if baaa.sta = "C" or baaa.sta = "E" then do:
            message "Счет " + vaaa2 + " закрыт!" view-as alert-box title 'ВНИМАНИЕ!'.
            pause.
            next.
        end.

        if substr(string(baaa.gl),1,4) ne '2240' then do:
            message "Счет должен быть открыт на балансовом счете 2240!" view-as alert-box title 'ВНИМАНИЕ!'.
            pause.
            next.
        end.

        find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
        if avail garan then do:
            message 'Гарантия уже существует!' view-as alert-box title 'ВНИМАНИЕ!'.
            return.
        end.
        vcrc = baaa.crc.
        find first crc where crc.crc = vcrc no-lock no-error.
        if avail crc then v-crcname = crc.code.
        displ vcrc v-crcname with frame garan0.
        run updgaran.

        v-select = 0.
        run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ ПО ГАРАНТИИ :"," 1. Сохранить гарантию и выйти | 2. Не сохранять гарантию и выйти | 3. Вернуться к редактированию гарантии ", output v-select).
        if v-select = 1 or v-select = 2 then leave.
    end.  /*repeat*/
    /*создаем запись в гарантиях*/
    run savegaran.

    find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
    if avail garan then disable b1 b2  with frame a2.

    enable b-upd with frame a2.

end. /* b2 new */

/* выход */
ON CHOOSE OF b-ext IN FRAME a2 do:
    apply "window-close" to CURRENT-WINDOW.
end.

/* история изм.карточки */
ON CHOOSE OF b-chc IN FRAME a2 do:
    run ch_card.
end.

/* транзакция */
on choose of b-trx in frame a2 do:
    /*repeat:*/
    /* верменно для теста*/ if lvr = true then do:
        message "У вас нет прав на выполнение транзакции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    /*if g-ofc begins 'nbrk' then do:
        message "У вас нет прав на выполнение транзакции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.*/
    if trim(v-address) = '' then do:
        message "Гарантия не оформлена до конца!" view-as alert-box title "ВНИМАНИЕ".
        run updgaran.
    end.
    /*else leave.
    end.*/
    else do:
        message "Вы действительно хотите сделать транзакцию по выдаче гарантии? " view-as alert-box question buttons yes-no title "" update v-ans.
        if not v-ans then return.

        if v-jh <> 0 then do:
            message 'Проводка уже создана! N транзакции ' string(v-jh) view-as alert-box title "ВНИМАНИЕ".
            return.
            /*enable b-upd with frame a2.*/
        end.
        else do:
            v-templ = /*"dcl0010"*/ if dcom = g-today then 'dcl0016' else 'dcl0017'.
            rem1 = 'Договор гарантии № ' + trim(v-garan)  + ' от ' + string(dfrom).
            if dto <> ? then  rem1 = rem1  + ' до ' + string(dto).
            rem1 = rem1 + ' ' + v-name.
            if vsum > 0 then do:
                find first crc where crc.crc = vcrc no-lock no-error.
                if avail crc then v-crcgar = crc.des.
                rem2 = 'Cумма покрытия: ' + string(vsum) + ' ' + v-crcgar + ' '.
            end.
            find first crc where crc.crc = v-crczal no-lock no-error.
            if avail crc then v-zalcrc = crc.des.

            if sumzalog > 0 then rem2 = rem2 + 'Вид залога: ' + v-codfr + ' ' + vobes + ' Сумма ' + string(sumzalog) + ' ' + v-zalcrc.
            if vaaa3 <> '' then do:
                find first crc where crc.crc = vcrc3 no-lock no-error.
                if avail crc then v-comcrc = crc.des.
                rem3 = if dcom = g-today then 'Признание обязательства на сумму комиссионного вознаграждения за выпуск гарантии: '
                                         else 'Признание обязательства / дебиторской задолженности по комиссионному вознаграждению за выпуск гарантии: '.
                rem3 = rem3 + string(sumkom) + ' ' + v-comcrc.
            end.
            rem4 = 'Банк бенеф: '   +  v-bankben + ' '.

            if v-bentype = 1 then rem4 = rem4 + 'Наимен бенеф: ' +  v-naim.
            if v-bentype > 1 then rem4 = rem4 + 'Наимен бенеф: ' +  v-fname + ' ' + v-lname + ' ' + v-mname.
            rem5 = 'Адрес бенеф: '  +  v-address.
            if vsum > 0 then vparam = string(vsum) + vdel + vaaa.
            else vparam = string(0) + vdel + vaaa2. /* сумма нулевая, проводка не будет сделана, поэтому неважно, какой передается номер счета */

            vparam = vparam + vdel + vaaa2 + vdel + v-eknp + vdel +
                string(sumtreb) + vdel + string(vcrc) + vdel + rem1 + vdel + rem2 + vdel + rem3 + vdel + rem4 + vdel + rem5.

            if vaaa3 <> '' then do:
                if dcom = g-today then vparam = vparam + vdel + string(sumkom) + vdel + string(vcrc3) + vdel + vaaa3 + vdel + vaaa2.
                else vparam = vparam + vdel + string(sumkom) + vdel + string(vcrc3) + vdel + vaaa2 + vdel + vaaa2.
            end.
            else do:
                /* сумма нулевая, проводка не будет сделана, поэтому неважно, какой передается номер счета */
                find first aaa where aaa.aaa = vaaa2 no-lock no-error.
                if dcom = g-today then vparam = vparam + vdel + string(0) + vdel + string(aaa.crc) + vdel + vaaa2 + vdel + vaaa2.
                else vparam = vparam + vdel + string(0) + vdel + string(aaa.crc) + vdel + vaaa2 + vdel + vaaa2.
            end.
            vparam = vparam + vdel + string(sumzalog) + vdel + string(v-crczal).
            run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output v-jh).

            if rcode ne 0 then do:
                message v-templ ' ' rdes.
                pause.
                return.
            end.

            if v-jh > 0 then do:
                displ v-jh with frame garan0.
                find first jh where jh.jh = v-jh exclusive-lock.
                if jh.sts < 5 then jh.sts = 5.
                for each jl of jh:
                    if jl.sts < 5 then jl.sts = 5.
                end.
                find current jh no-lock.
            end.
        end.
        s-jh = v-jh.
        run vou_bank(2).
        /*enable b-upd with frame a2.*/

        if v-jh <> 0 then do:
            find first garan where garan.garan = vaaa2 and garan.cif = v-cif exclusive-lock no-error.
            if avail garan then garan.jh = v-jh.
            if vaaa3 = '' then do /*transaction*/:
                    /* счет кассы в пути в валюте vcrc3 */
                    run get100200arp(input g-ofc, input vcrc3, output v-yn, output s_account_b, output v-err).
                    if v-err then do:
                        /*если ошибка имела место, то еще раз скажем об этом пользователю*/
                        v-err = not v-err.
                        message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
                            "произошла ошибка!" view-as alert-box error.
                        return.
                    end.

                    if v-yn then s_account_a = "". /*касса в пути*/
                    else do:
                        /*касса*/
                        s_account_a = string(c-gl).
                        s_account_b = "".
                    end.
                /*do transaction:*/
                    v-jh2 = 0.
                    if s_account_a = string(c-gl) and s_account_b = '' then do:
                        /* 100100 */
                        v-templ = "vnb0003".
                        rem1 = 'Комиссия за выпуск гарантии ' + v-name + ' на сумму ' + string(sumtreb)+ ' ' + v-crcgar + ' по Договору выдачи гарантии №' +  trim(v-garan)  + ' от ' + string(dfrom).
                        if dto <> ? then  rem1 = rem1  + ' до ' + string(dto).

                        vparam = string(sumkom) + vdel + string(vcrc3) + vdel + "460610" + vdel + rem1 + vdel.
                    end.
                    else do:
                        /* 100200 */
                        v-templ = "vnb0001".
                        vparam = string(sumkom) + vdel + string(vcrc3) + vdel + s_account_b + vdel + "460610" + vdel + rem1 /*"Комиссия за выдачу гарантии "*/ + vdel.
                    end.

                    run trxgen (v-templ, vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh2).
                    if rcode ne 0 then do:
                        message 'Комиссия: ' + rdes.
                        pause.
                        undo,retry.
                    end.

                    if v-jh2 > 0 then do:
                        displ v-jh2 with frame garan0.

                        s-jh = v-jh2.
                        run jou. /* создадим jou-документ */
                        v_doc = return-value.

                        find first jh where jh.jh = v-jh2 exclusive-lock.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                        jh.party = v_doc.
                        find current jh no-lock.

                        run setcsymb (v-jh2, 100). /* проставим символ кассплана */

                        find first jh where jh.jh = v-jh exclusive-lock.
                        jh.tty = v-jh2.
                        find current jh no-lock.

                        find first garan where garan.garan = vaaa2 and garan.cif = v-cif exclusive-lock no-error.
                        if avail garan then garan.jh2 = v-jh2.


                        find first joudoc where joudoc.docnum = v_doc exclusive-lock no-error.
                        if avail joudoc then do:
                            joudoc.info = v-name. joudoc.passp = ''. joudoc.perkod = v-rnn.
                        end.
                    end.
                /*end.*/ /* transaction */
                run vou_bank(2).
                /*enable b-upd with frame a2.*/
            end.
        end.
        if v-jh2 > 0 then enable b3 b-pog b-doc /*b-upd*/ with frame a2.
        if v-jh > 0 then do:
            enable b4 b-bentreb b-debpog b-rezerv b-proscom with frame a2.
            message "Транзакция по выдаче гарантии N " + string(v-jh) + " передана на акцепт контролеру!" view-as alert-box.
        end.
    end.
end.

/*on "end-error" of frame a2 do:
   find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
   if avail garan and v-jh = 0 then do:
      if not g-ofc begins 'nbrk' then do:
      message "Необходимо сделать проводку!" view-as alert-box title 'ВНИМАНИЕ'.
      disable b1 b2 with frame a2.
      return no-apply.
      end.
   end.
end.*/


/* поиск  */
on choose of b2 in frame a2 do:
    assign v-cif      = ''
           v-name     = ''
           v-rnn      = ''
           v-jh       = 0
           vaaa2      = ''
           v-crcname  = ''
           vsum       = 0
           v-garan    = ''
           v-gardop   = ''
           v-nomgar   = ''
           vaaa       = ''
           dfrom      = ?
           dtdop      = ?
           dto        = ?
           v-codfr    = ''
           vobes      = ''
           sumzalog   = 0
           v-crczal   = 0
           v-crczname = ''
           sumtreb    = 0
           vcrc       = 0
           vaaa3      = ''
           v-jh2      = 0
           vcrc3      = 0
           v-crc3name = ''
           sumkom     = 0
           dcom       = ?
           v-bankben  = ''
           v-naim     = ''
           v-address  = ''
           v-fname    = ''
           v-lname    = ''
           v-mname    = ''
           v-benres   = 0
           v-benrdes  = '' /*'резидент'*/
           v-bentdes  = '' /*'Юридическое лицо'*/
           v-bentype  = 0
           v-bencount = ''
           v-bencountr = ''.
           v-grcom = no.
           v-mcomsum = 0.
           v-mcom% = 0.
           v-mlstdate = no.
           /*v-mdate = ?.*/
           run showinfo.


    update v-cif with frame garan0.
    find cif where cif.cif = v-cif no-lock no-error.
    if avail cif then do:
        v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
        v-rnn = cif.jss.
        display v-name with frame garan0.
    end.

    update vaaa2 with frame garan0.

    find baaa where baaa.aaa = vaaa2 no-lock no-error.
    if not available baaa then do:
        message "Счет " + vaaa2 + " не существует" view-as alert-box title "".
        pause.
        next.
    end.

    s-aaa = vaaa2.
    s-cif = v-cif.

    find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
    if not avail garan then do:
        message ' Гарантия не найдена !' view-as alert-box.
        undo,retry.
    end.

    run fill_form.
    view frame garan0.
    run showinfo.

    if v-jh = 0 then do:
        repeat:
            run updgaran.
                v-select = 0.
                run sel2 ("ВЫБЕРИТЕ РЕШЕНИЕ ПО ГАРАНТИИ :"," 1. Сохранить гарантию и выйти | 2. Не сохранять гарантию и выйти | 3. Вернуться к редактированию гарантии ", output v-select).
                if v-select = 1 or v-select = 2 then leave.
        end.  /*repeat*/
        /*создаем запись в гарантиях*/
        run savegaran.

        enable b-upd with frame a2.

        find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
        if avail garan then disable b1 b2 with frame a2.
    end.
    else disable b-upd with frame a2.
    s-lon = garan.garan.
    /*message '111' s-lon view-as alert-box.*/
    if v-jh > 0 then
    enable b-trx b3 b4 b-obes /*b-usl*/ b-pog b-doc b-sts b-klass b-chc  b-mon /**/ /*b-upd*/ b-bentreb b-debpog b-rezerv b-graf b-proscom /**/ b-ext with frame a2.
    else
    enable b-trx b3 b4 b-obes /*b-usl*/ b-pog b-doc b-sts b-klass b-chc b-mon b-graf b-ext with frame a2.
end. /* on choose of b2 */

/* delete */
on choose of b3 in frame a2 do:
    if lvr = true then do:
        message "У вас нет прав на операцию удаления комиссии!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if g-ofc begins 'nbrk' then do:
        message "У вас нет прав на операцию удаления комиссии!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if v-jh2 > 0 then do:
        find first jl where jl.jh = v-jh2 no-lock no-error.
        if avail jl then do transaction:
            ja = no.
            message "Удалить проводку-комиссию?" update ja.
            if ja then do:
                run del_trx(v-jh2).
                /*find first garan where garan.garan = vaaa2 and garan.cif = v-cif exclusive-lock no-error.
                if avail garan then garan.jh2 = 0.*/
            end.
        end.
        else do:
            message "Проводка не была создана или уже удалена!" view-as alert-box.
            return.
        end.
    end.
    else do:
        message "Проводка не была создана или уже удалена!" view-as alert-box.
        return.
    end.
end. /* on choose of b3 */

on choose of b4 in frame a2 do:
    def var v-comdel as logi no-undo.
    if lvr = true then do:
        message "У вас нет прав на операцию удаления гарантии!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if g-ofc begins 'nbrk' then do:
        message "У вас нет прав на операцию удаления гарантии!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if v-jh > 0 then do:
        find first jl where jl.jh = v-jh no-lock no-error.
        if avail jl then do:
            v-comdel = no.
            if v-jh2 = 0 then v-comdel = yes.
            else do:
                find first jl where jl.jh = v-jh2 no-lock no-error.
                if not avail jl then v-comdel = yes.
            end.
            if v-comdel then do transaction:
                ja = no.
                message "Удалить проводку по выдаче гарантии?" update ja.
                if ja then do:
                    run del_trx(v-jh).
                    /*find first garan where garan.garan = vaaa2 and garan.cif = v-cif exclusive-lock no-error.
                    if avail garan then garan.jh = 0.*/
                end.
            end.
            else do:
                message "Сначала удалите проводку-комиссию!" view-as alert-box title "ВНИМАНИЕ".
                return.
            end.
        end.
        else do:
            message "Проводка не была создана или уже удалена!" view-as alert-box title "ВНИМАНИЕ".
            return.
        end.
    end.
    else do:
        message "Проводка не была создана или уже удалена!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
end. /* on choose of b4 */

/* погасить */
on choose of b-pog in frame a2 do:
    /*if g-ofc begins 'nbrk' then do:
        message "У вас нет прав на операцию гашения!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.*/
    if lvr = true then do:
        message "У вас нет прав на выполнение данной операции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.

    find first aaa where aaa.aaa = garan.garan no-lock no-error.
    if get_amt(garan.garan,aaa.gl,7,g-today, "cif", garan.crc) = 0 then do:
        message  'Гарантия уже погашена!' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    if get_amt(garan.garan,aaa.gl,26,g-today, "cif", garan.crc) > 0 then do:
        message  'Перед погашением гарантии необходимо погасить дебиторскую задолженность.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    if get_amt(garan.garan,aaa.gl,31,g-today, "cif", garan.crc) > 0 then do:
        message  'Перед погашением гарантии необходимо погасить просроченную комиссионную задолженность.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.

    message 'Гарантия погашается в полном объеме?' view-as alert-box question buttons yes-no update v-pog.
    if v-pog = ? then return.

    rem1 = 'Погашение гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
    vparam = ''.
    if v-pog then do:
        vparam = string(vsum) + vdel + vaaa2.
        if vsum = 0 then vparam = vparam + vdel + vaaa2.
        else vparam = vparam + vdel + vaaa.
        vparam = vparam + vdel + v-eknp + vdel + string(sumtreb) + vdel + string(vcrc) + vdel + rem1 + vdel  + string(sumzalog) + vdel + string(v-crczal).
    end.
    else do:

        v-amttrebhis = 0.
        v-amttreb = 0.

        if trim(v-codfr) = '3' then v-amttrebhis = get_amt(garan.garan,aaa.gl,1,g-today, "cif", garan.crc).

        vparam = string(v-amttrebhis) + vdel + vaaa2.
        if v-amttrebhis <= 0 then vparam = vparam + vdel + vaaa2.
        else vparam = vparam + vdel + vaaa.
        v-amttreb = get_amt(garan.garan,aaa.gl,7,g-today, "cif", garan.crc).
        vparam = vparam + vdel + v-eknp + vdel + string(v-amttreb) + vdel + string(vcrc) + vdel + rem1 + vdel  + string(sumzalog) + vdel + string(v-crczal).
    end.

    if deci(garan.info[3]) > 0 then do:
        assign v-gldoh = if lookup(trim(v-codfr),'3,5') > 0 then '460610' else '460620'
               v-rem   = 'Несамортизированное ком.вознаграждение за выпуск гарантии по договору № ' + trim(v-garan)  + ' от ' + string(dfrom,'99/99/9999') + 'г. в связи с погашением'.

        if get_amt(garan.garan,aaa.gl,30,g-today, "cif", garan.crc) = 0 then do:
            if vcrc3 = 1 then vparam = vparam + vdel + garan.info[3] + vdel + v-gldoh + vdel + v-rem + vdel + '0' + vdel + '2' + vdel + ' ' + vdel + v-gldoh.
            else vparam = vparam + vdel + '0' + vdel + '' + vdel + '' + vdel +  garan.info[3] + vdel + string(vcrc3) + vdel + v-rem + vdel + v-gldoh.
            vparam = vparam + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + v-gldoh + vdel + v-rem
                     + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + vaaa2 + vdel + v-rem.
        end.
        else do:
            if vcrc3 = 1 then vparam = vparam + vdel + '0' + vdel + v-gldoh + vdel + v-rem + vdel + '0' + vdel + '2' + vdel + ' ' + vdel + v-gldoh.
            else vparam = vparam + vdel + '0' + vdel + '' + vdel + '' + vdel +  '0' + vdel + string(vcrc3) + vdel + v-rem + vdel + v-gldoh.

            if v-grcom then vparam = vparam + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + v-gldoh + vdel + v-rem + vdel + string(get_amt(garan.garan,aaa.gl,30,g-today, "cif", garan.crc)) + vdel + string(garan.crc) + vdel + vaaa2 + vdel + vaaa2 + vdel + v-rem.
            else vparam = vparam + vdel + string(get_amt(garan.garan,aaa.gl,30,g-today, "cif", garan.crc)) + vdel + string(garan.crc) + vdel + vaaa2 + vdel + v-gldoh + vdel + v-rem + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + vaaa2 + vdel + v-rem.
        end.
    end.
    else vparam = vparam + vdel + '0' + vdel + '' + vdel + '' + vdel + '0' + vdel + '2' + vdel + ' ' + vdel + '' + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + v-gldoh + vdel + v-rem + vdel + '0' + vdel + string(garan.crc) + vdel + vaaa2 + vdel + vaaa2 + vdel + v-rem.
    s-jh = 0.
    v-templ = 'uni0058'.
    run trxgen (v-templ, vdel, vparam, "CIF", vaaa, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do:
        message v-templ ' ' rdes.
        pause.
        return.
    end.
    message  'Гарантия погашена. Номер проводки погашения ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
    do transaction:
        find first aaa where aaa.aaa = vaaa2 exclusive-lock no-error.
        if avail aaa then do:
            aaa.sta = 'C'.
            aaa.cltdt = g-today.
            aaa.whn = g-today.
            aaa.who = g-ofc.

            find first sub-cod where sub-cod.sub = 'cif' and sub-cod.acc = aaa.aaa and sub-cod.d-cod = 'clsa' exclusive-lock no-error.
            if avail sub-cod then do:
               sub-cod.rdt = g-today.
               sub-cod.ccode = '10'.
            end.
            else do:
                create sub-cod.
                assign sub-cod.sub = 'cif'
                       sub-cod.acc = aaa.aaa
                       sub-cod.d-cod = 'clsa'
                       sub-cod.rdt = g-today
                       sub-cod.ccode = '10'.
            end.
            find current aaa no-lock no-error.
        end.
        if deci(garan.info[3]) > 0 then do:
            find current garan exclusive-lock no-error.
            if avail garan then garan.info[3] = ''.
            find current garan no-lock no-error.
        end.
    end.
    run vou_bank(2).

end.

/* документы */
on choose of b-doc in frame a2 do:
    run s-garan.
end.
/* статус */
on choose of b-sts in frame a2 do:
    run s-lonharg.
    frame a2:visible = yes.
end.
/* классификация */
on choose of b-klass in frame a2 do:
    run lnklassg.
    frame a2:visible = yes.
    view frame garan0.
    run showinfo.
end.
/* обеспечение */
on choose of b-obes in frame a2 do:
    frame a2:visible = no.
    v-select1 = 0.
    run sel2 ("ВЫБЕРИТЕ ДЕЙСТВИЕ :"," 1. ВВОД(только актуальные) | 2. КОРРЕКТИРОВКА(все) ", output v-select1).
    if v-select1 = 1 then run garanobesp(vaaa2).
    else run garanobesp1s(vaaa2).
    frame a2:visible = yes.
end.
/* усл.обязательства */
/*on choose of b-usl in frame a2 do:
    frame a2:visible = no.
    run garanusl(vaaa2).
    frame a2:visible = yes.
end.*/
/*мониторинг*/
ON CHOOSE OF b-mon IN FRAME a2 do:
    run chk-clnd.
end.
/*требования бенефициара*/


ON CHOOSE OF b-bentreb IN FRAME a2 do:
    if lvr = true then do:
        message "У вас нет прав на выполнение данной операции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if v-jh = ? then do:
        message  'Требования по данной гарантии не могут быть исполнены. Гарантия не выдана.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.

    if dto < g-today then do:
         v-form = yes.
         message  'Срок действия ганатии истек. Исполнить требования?' view-as alert-box question buttons yes-no update v-form.
         if v-form = no then return.
         else do:
             v-form = yes.
             message  'Создать проводку по списанию дополнительной комиссии?' view-as alert-box question buttons yes-no update v-form.
             if v-form = yes then do:
                v-acc = ''.
                update v-acc v-comsum with frame fcom.
                hide frame fcom.
                vparam = ''.
                v-gldoh = ''.
                v-gldoh     = if lookup(trim(garan.obesp),'3,5') > 0 then '460610' else '460620'.
                rem1 = 'Оплата дополнительной комиссии по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                rem2 = 'Дополнительный комиссионный доход по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                rem3 = ''.
                vparam = string(v-comsum) + vdel + string(1) + vdel + v-acc + vdel + '30' + vdel + vaaa2 + vdel + rem1 +
                        vdel + string(v-comsum) + vdel + string(vcrc) + vdel + '30' + vdel + vaaa2 + vdel +  v-gldoh + vdel + rem2 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '830300' + vdel + '28' + vdel + vaaa2 + vdel + rem3 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '813000' + vdel + '713013' + vdel + rem2 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem1.

                s-jh = 0.
                rcode = 0.
                v-templ = 'cif0028'.
                run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    message v-templ ' ' rdes.
                    pause.
                    return.
                end.
                message  'Проводка по списанию дополнительной комиссии создана. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
             end.

         end.
    end.
    /*провериь досрочное погашение гарантии*/
    v-sumgar = 0.
    run lonbalcrc('cif',vaaa2,g-today,"7",yes,vcrc,output v-sumgar).
    if v-sumgar = 0 then do:
       message "Требования по данной гарантии не могут быть исполнены. Гарантия погашена." view-as alert-box.
       return.
    end.

    v-amttreb = 0.
    v-amtvalid = 0.
    v-title = ''.
    v-validate = ''.
    v-sel = ''.


    run sel2 (" Выбор: ", " 1. Формирование резервов (провизий) | 2. Уменьшение резерва | 3. Исполнение требований бенефициара | 4. Выход ", output v-sel).
    if keyfunction (lastkey) = "end-error" then do:
       hide frame summa.
       hide frame fcom.
    end.

    if v-sel = '1' or v-sel = '2' then do:
        if trim(v-codfr) = '3' then do:
            message  'По гарантиям обеспеченным деньгами НЕ формируются/уменьшаются резервы' view-as alert-box title 'ВНИМАНИЕ'.
            return.
        end.
        v-amttrebhis = 0.
        find first jh where jh.jh = v-jh no-lock no-error.
        for each jl where jl.jdt >= jh.jdt and jl.dc = 'D' and jl.acc = vaaa2 and jl.lev = 26 no-lock:
            if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 then next.
            find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'C' and b-jl.ln = jl.ln + 1 no-lock no-error.
            if avail b-jl and b-jl.gl = 495800 then v-amttrebhis = v-amttrebhis + jl.dam.

        end.
        for each jl where jl.jdt >= jh.jdt and jl.dc = 'C' and jl.acc = vaaa2 and jl.lev = 26 no-lock:
            if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 then next.
            find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'D' and b-jl.ln = jl.ln - 1 no-lock no-error.
            if avail b-jl and b-jl.gl = 495800 then v-amttrebhis = v-amttrebhis - jl.cam.
        end.

        if v-sel = '1' then do:
            if v-amttrebhis >= sumtreb then do:
               message  'Резерв по гарантии уже сформирован.' view-as alert-box title 'ВНИМАНИЕ'.
               return.
            end.
            else assign v-amttreb = sumtreb - v-amttrebhis v-amtvalid = sumtreb - v-amttrebhis.
        end.
        else do:
            if v-amttrebhis > 0 then assign v-amttreb = v-amttrebhis v-amtvalid = v-amttrebhis.
            else do:
               message  'Резерв по гарантии не может быть уменьшен, т.к. он ранее не был сформирован.' view-as alert-box title 'ВНИМАНИЕ'.
               return.
            end.
        end.
        v-title = 'РЕЗЕРВ'.
        v-validate = 'Сумма резерва должна быть больше нуля и меньше или равна  '.
    end.
    if v-sel = '3' then do:
        v-title = 'ТРЕБОВАНИЯ'.
        v-amttrebhis = 0.
        v-amtvalid = 0.
        if trim(garan.obesp) <> '3' then do:
            find first jh where jh.jh = v-jh no-lock no-error.
            for each jl where jl.jdt >= jh.jdt and jl.dc = 'D' and jl.acc = vaaa2 and jl.lev = 27 no-lock:
                if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 then next.
                find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'C' and b-jl.ln = jl.ln + 1 no-lock no-error.
                if avail b-jl then do:
                   find first gl where gl.gl = b-jl.gl no-lock no-error.
                   if avail gl and gl.sub = 'arp' then v-amttrebhis = v-amttrebhis + jl.dam.
                end.
            end.

            if v-amttrebhis >= sumtreb then do:
                message  'Требования по гарантии выполнены.' view-as alert-box title 'ВНИМАНИЕ'.
                return.
            end.
            else do:
                find first aaa where aaa.aaa = garan.garan no-lock no-error.
                if avail aaa then v-amttreb = get_amt(garan.garan,aaa.gl,27,g-today, "cif", garan.crc).
                v-amtvalid = v-amttreb.
                v-validate = 'Сумма требований должна быть больше нуля и меньше или равна  '.
                if v-amttreb = 0 then do:
                    message  'Не сформирован резерв для исполнения требований.' view-as alert-box title 'ВНИМАНИЕ'.
                    return.

                end.
            end.
        end.
        else do:
             find first aaa where aaa.aaa = garan.garan no-lock no-error.
             if avail aaa then v-amttreb = get_amt(aaa.aaa,aaa.gl,7,g-today, "cif", garan.crc).
             if v-amttreb = 0 then do:
                 message  'Требования по гарантии выполнены.' view-as alert-box title 'ВНИМАНИЕ'.
                 return.
             end.
             v-amtvalid = v-amttreb.
        end.
    end.
    if (v-sel = '1' or v-sel = '2') and keyfunction (lastkey) <> "end-error" then do:
        update v-amttreb  with frame summa.
        hide frame summa.
    end.

    case v-sel:
        when '1' or when '2' then do:
           v-form = yes.
           if v-sel = '1' then message 'Сформировать резерв?' view-as alert-box question buttons yes-no update v-form.
           else message 'Уменьшить резерв?' view-as alert-box question buttons yes-no update v-form.
           if not v-form then return.

           vparam = ''.
           rem1 = ''.
           if v-sel = '1' then rem1 = 'Формирование резерва гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
           else rem1 = 'Уменьшение ранее признанного возмещения гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
           rem2 = ''.
           if v-sel = '1' then rem2 = 'Возмещение суммы гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
           else rem2 = 'Уменьшение резерва гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.

           if v-sel = '1' then vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + '546500' + vdel + '27' + vdel + vaaa2 + vdel + rem1 + vdel + string(v-amttreb) + vdel + '26' + vdel + vaaa2 + vdel + '495800' + vdel + rem2.
           else vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + '495800' + vdel + '26' + vdel + vaaa2 + vdel + rem1 + vdel + string(v-amttreb) + vdel + '27' + vdel + vaaa2 + vdel + '495800' + vdel + rem2.
           s-jh = 0.
           rcode = 0.
           v-templ = 'cif0026'.
           run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

           if rcode ne 0 then do:
               message v-templ ' ' rdes.
               pause.
               return.
           end.
           if v-sel = '1' then message  'Резерв по гарантии сформирован. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
           if v-sel = '2' then message  'Резерв по гарантии уменьшен. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
           run vou_bank(2).
        end.
        when '3' then do:
             v-form = yes.
             message 'Исполнить требования бенефициара?' view-as alert-box question buttons yes-no update v-form.
             if not v-form then return.

             if  trim(v-codfr) <> '3' then do: /*гарантия НЕ под залог денег*/
                 Find first sysc where sysc.sysc = "gararp" no-lock no-error.
                 if not avail sysc and sysc.chval = '' then do:
                    message "Не найдена настройка gararp в sysc!" view-as alert-box.
                    return.
                 end.
                 find first arp where arp.arp = sysc.chval no-lock no-error.
                 if not avail arp then do:
                    message "Не найден транзитный счет "  + sysc.chval view-as alert-box.
                    return.
                 end.
                 v-arp = sysc.chval.
             end.
             else do:
                 find first arp where arp.crc = vcrc and arp.gl = 186110 no-lock no-error.
                 if avail arp then do:
                     find first sub-cod where sub-cod.sub = 'arp' and sub-cod.acc = arp.arp and sub-cod.d-cod = 'clsa' no-lock  no-error.
                     if avail sub-cod and sub-cod.ccod <> 'msc' then do:
                          message "Транзитный счет  "  + arp.arp + " закрыт" view-as alert-box.
                          return.
                     end.
                     v-arp = arp.arp.
                 end.
                 else do:
                    message "Не транзитный счет по ГК 186110, валюте "  + string(vcrc) view-as alert-box.
                    return.
                 end.
             end.


                /****внешний платеж******/

             find first cif where cif.cif = v-cif no-lock no-error.
             if substr(cif.geo,3,1) <> "1" then v_kod = '2'.
             else v_kod = '1'.
             find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" use-index dcod no-lock no-error .
             if avail sub-cod then v_kod = v_kod + sub-cod.ccod.
             if  garan.naim = '' then do:
                 v-naim2 = v-fname + ' ' + v-lname.
                 if v-mname <> '' then v-naim2 = v-naim2 + ' ' + v-mname.
             end.
             else  v-naim2 = garan.naim.
             v-dtval2 = today.
             display  v-name cif.bin v_kod v-arp v-amttreb  v-naim2 v-benbin v_kbe v_knp v-cover v-dtval2 with frame rmzf.
             update v-amttreb with frame rmzf.
             update v-benbin with frame rmzf.

             update v_swibic with frame rmzf.
             find first bankl where bankl.bank = v_swibic no-lock no-error.
             find sysc where sysc.sysc = "netgro" no-lock no-error.
             if time >= 52000 or sysc.deval <= v-amttreb then v-cover = 1.
             else do:
                 if bankl.crbank = 'clear' then v-cover = 2.
                 else v-cover = 1.
             end.
             v-bbankn = bankl.name.
             if v-cover = 1 then v-covern = 'Гросс'.
             else v-covern = 'Клиринг'.
             display v-cover v-bbankn v-covern with frame rmzf.



             update v-accben   with frame rmzf.
             update v_kbe with frame rmzf.
             update v_knp with frame rmzf.
             update v-dtval2 with frame rmzf.
             update v_nazn1 v_nazn2 v_nazn3 v_nazn4 v_nazn5 v_nazn6  with frame rmzf.

             if trim(v_nazn1) <> '' then v_nazn = trim(v_nazn1).
             if trim(v_nazn2) <> '' then v_nazn = trim(v_nazn) + ' ' + trim(v_nazn2).
             if trim(v_nazn3) <> '' then v_nazn = trim(v_nazn) + ' ' + trim(v_nazn3).
             if trim(v_nazn4) <> '' then v_nazn = trim(v_nazn) + ' ' + trim(v_nazn4).
             if trim(v_nazn5) <> '' then v_nazn = trim(v_nazn) + ' ' + trim(v_nazn5).
             if trim(v_nazn6) <> '' then v_nazn = trim(v_nazn) + ' ' + trim(v_nazn6).


                /* создаем rmz документ*/
             v_rmzdoc = ''.
             run rmzcre(1, v-amttreb, v-arp, cif.bin, v-name,v_swibic,v-accben, v-naim, v-benbin,' ', no, v_knp, v_kod, v_kbe, v_nazn, 'P', 1, v-cover, g-today).
             v_rmzdoc = return-value.
             if v_rmzdoc = '' then do:
                  message "Внешний платеж не создан!" view-as alert-box.
                  return.
             end.


             find first remtrz where remtrz.remtrz = v_rmzdoc exclusive-lock no-error.
             if avail remtrz then do:
                 find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
                 if avail sysc and sysc.chval <> '' then remtrz.scbank = sysc.chval.
                 remtrz.ba = v-accben.
                 remtrz.kfmcif = garan.cif.
                 remtrz.svccgr = 302. /*без комиссии*/
                 remtrz.info[9] = string(g-today).
                 remtrz.valdt2 = v-dtval2.
                 remtrz.source = "P". /* код создания платежа*/
             end.
             find first remtrz no-lock.

             s-remtrz = v_rmzdoc.
             run rmzque .

             if substring(v_kod,1,1) <> "1" or substring(string(v_kbe),1,1) <> "1" then do:
                    l-ans = no.
                    run yn(""," Есть Документ Основание ? ","","", output l-ans).
                    if l-ans then do:
                       /* Автоматически проставим признак */
                       find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc   = v_rmzdoc and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
                       if avail sub-cod then do:
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zdcavail'.
                            sub-cod.ccode    = string(1).
                            sub-cod.rdt      = g-today.
                       end.
                       else do:
                            create sub-cod.
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zdcavail'.
                            sub-cod.ccode    = string(1).
                            sub-cod.rdt      = g-today.
                       end.
                        find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                        if avail sub-cod then do:
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zsgavail'.
                            sub-cod.ccode    = string(2).
                            sub-cod.rdt      = g-today.
                        end.
                        else do:
                            create sub-cod.
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zsgavail'.
                            sub-cod.ccode    = string(2).
                            sub-cod.rdt      = g-today.
                        end.
                       find first sub-cod no-lock  no-error.
                       release sub-cod.
                    end. /*l-ans = true*/
                    else do:
                       find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc   = v_rmzdoc and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
                       if avail sub-cod then do:
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zdcavail'.
                            sub-cod.ccode    = string(2).
                            sub-cod.rdt      = g-today.
                       end.
                       else do:
                            create sub-cod.
                            sub-cod.acc      = v_rmzdoc.
                            sub-cod.sub      = 'rmz'.
                            sub-cod.d-cod    = 'zdcavail'.
                            sub-cod.ccode    = string(2).
                            sub-cod.rdt      = g-today.
                       end.
                        l-ans = no.
                        run yn(""," Есть запись разрешающая предоставлять информацию в правоохранительные органы","","", output l-ans).
                        if l-ans then do:
                            /* Автоматически проставим признак */
                            find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = v_rmzdoc and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                            if avail sub-cod then do:
                                sub-cod.acc      = v_rmzdoc.
                                sub-cod.sub      = 'rmz'.
                                sub-cod.d-cod    = 'zsgavail'.
                                sub-cod.ccode    = string(1).
                                sub-cod.rdt      = g-today.
                            end.
                            else do:
                                create sub-cod.
                                sub-cod.acc      = v_rmzdoc.
                                sub-cod.sub      = 'rmz'.
                                sub-cod.d-cod    = 'zsgavail'.
                                sub-cod.ccode    = string(1).
                                sub-cod.rdt      = g-today.
                            end.
                            find first sub-cod no-lock  no-error.
                            release sub-cod.
                        end.
                        else undo, return.
                    end.
             end.
             message 'Создан внешний перевод ' + v_rmzdoc view-as alert-box.

             if  trim(v-codfr) <> '3' then do: /*гарантия НЕ под залог денег*/
                /*****перевод на транзитный счет*****/

                rem1 = 'Перевод суммы требований на транзитный счет по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + '27' + vdel + vaaa2 + vdel + v-arp + vdel + rem1 + vdel + v_knp.
                s-jh = 0.
                rcode = 0.
                v-templ = 'uni0118'.
                run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                   message v-templ ' ' rdes.
                   pause.
                   return.
                end.
                message  'Перевод суммы требований на транзитный счет сформирован. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
                run vou_bank(2).
             end.

             if trim(v-codfr) <> '3' then do:
                 /*увеличение обязательств клиента*/
                 vparam = ''.
                 rem1 = ''.
                 rem2 = ''.
                 rem1 = 'Уменьшение условных обязательств банка по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                 rem2 = 'Исполнение банком требования бенефициара по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.

                 vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + '655500' + vdel + '7' + vdel + vaaa2 + vdel + rem1 + vdel + string(v-amttreb) + vdel + '28' + vdel + vaaa2 + vdel + '830300' + vdel + rem2.


                 s-jh = 0.
                 rcode = 0.
                 v-templ = 'cif0026'.

                 run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

                 if rcode ne 0 then do:
                     message v-templ ' ' rdes.
                     pause.
                     return.
                 end.
                 message  'Уменьшение обязательств банка. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
                 run vou_bank(2).
                 /********/
             end.


            if trim(v-codfr) = '3' then do:

                /*возмещение суммы исполненного банком обязательства*/

                vparam = ''.
                rem1 = ''.
                rem2 = ''.
                rem1 = 'Возмещение суммы исполненного банком обязательства по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                rem2 = 'Исполнение банком требования бенефициара по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
                vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + vaaa2 + vdel + v-arp + vdel + rem1 + vdel + string(v-amttreb) + vdel + string(vcrc) + vdel + '655500' + vdel + '7' + vdel + vaaa2 + vdel + rem2.

                s-jh = 0.
                rcode = 0.
                v-templ = 'cif0027'.
                run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

                if rcode ne 0 then do:
                    message v-templ ' ' rdes.
                    pause.
                    return.
                end.
                message  'Возмещение суммы исполненного банком обязательства. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
                run vou_bank(2).

            end.
           hide frame rmzf no-pause.
        end.
        otherwise return.
    end case.
end.
/****погашение/списание дебиторской задодженности*****/
ON CHOOSE OF b-debpog IN FRAME a2 do:
    if lvr = true then do:
        message "У вас нет прав на выполнение данной операции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    v-amttreb = 0.
    v-amtvalid = 0.
    v-title = ''.
    v-validate = ''.

    find first aaa where aaa.aaa = garan.garan no-lock no-error.
    v-amttreb = get_amt(garan.garan,aaa.gl,28,g-today, "cif", garan.crc).
    v-amttreb = v-amttreb + get_amt(garan.garan,aaa.gl,26,g-today, "cif", garan.crc).
    if trim(v-codfr) = '3' or v-amttreb <= 0 then do:
        message  'По гарантии нет дебиторской задолженности.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.

    v-sel = ''.
    run sel2 (" Выбор: ", " 1. Погашение дебиторской задолженности | 2. Списание за баланс дебиторской задолженности | 3. Погашение списанной за баланс дебиторской  задолженности| 4. Выход ", output v-sel).
    if keyfunction (lastkey) = "end-error" then do:
        hide frame summa.
        hide frame faaa.

    end.

    v-amttreb = 0.
    if v-sel = '1' or v-sel = '2' then do:
       v-amttreb = get_amt(garan.garan,aaa.gl,26,g-today, "cif", garan.crc).
       if v-amttreb <= 0 then do:
            message  'Вся дебиторская задолженность списана с баланса.' view-as alert-box title 'ВНИМАНИЕ'.
            return.
       end.
    end.

    if v-sel = '3' then v-amttreb = get_amt(garan.garan,aaa.gl,28,g-today, "cif", garan.crc).

    if v-sel <> '4' and keyfunction (lastkey) <> "end-error" then do:
        v-amtvalid = v-amttreb.
        v-validate = 'Сумма задолженности дожна быть больше нуля и меньше или равна '.
        v-title = 'Сумма задолженности'.
        update v-amttreb with frame summa.
        hide frame summa no-pause.
    end.


    if v-sel = '1' or v-sel = '2' or v-sel = '3' then do:
        v-form = yes.
        if v-sel = '1' then message 'Погасить дебиторскую задолженность?' view-as alert-box question buttons yes-no update v-form.
        if v-sel = '2' then message 'Списать дебиторскую задолженность за баланс?' view-as alert-box question buttons yes-no update v-form.
        if v-sel = '3' then message 'Погасить списаную с баланса дебиторскую задолженность?' view-as alert-box question buttons yes-no update v-form.
        if not v-form then return.
        if v-sel = '1' or v-sel = '3' then do:
           update v-acc with frame faaa.
           hide frame faaa no-pause.
        end.
    end.

    vparam = ''.
    rem1 = ''.
    rem2 = ''.
    /*rem3 = ''.*/
    if v-sel = '1' then do:
        rem1 = 'Возмещение суммы, выплаченной по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        rem2 = 'Уменьшение суммы исполненных требований по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г. в связи с оплатой'.

        vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + v-acc + vdel + '26' + vdel + vaaa2 + vdel + rem1 +
                        vdel + string(0) + vdel + string(vcrc) + vdel + '1' + vdel + vaaa2 + vdel +  '830300' + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '830300' + vdel + '28' + vdel + vaaa2 + vdel + rem2 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '825000' + vdel + '7250030' + vdel + 'нет' + /*нулевая сумма - параметры не важны*/
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem1.
                        /*vdel + string(garan.sumzalog) + vdel + string(v-crczal) + vdel + '825000' + vdel + '21' + vdel + vaaa2 + vdel + rem3.*/
    end.

    if v-sel = '2' then do:
        rem1 = 'Создание резервов на покрытие убытков по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        rem2 = 'Списание с баланса дебиторской задолженности по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        rem3 = 'Приход списанной суммы дебиторской задолженности на счет меморандума по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        vparam = string(0) + vdel + string(vcrc) + vdel + vaaa2 + vdel + '26' + vdel + vaaa2 + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                  vdel + string(0) + vdel + string(vcrc) + vdel + '1' + vdel +  vaaa2 + vdel +  '830300' + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                  vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '187730' + vdel + '26' + vdel + vaaa2 + vdel + rem2 +
                  vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '545300' + vdel + '187730' + vdel + rem1 +
                  vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem3.
                  /*vdel + string(garan.sumzalog) + vdel + string(v-crczal) + vdel + '825000' + vdel + '21' + vdel + vaaa2 + vdel + rem3.*/
    end.

    if v-sel = '3' then do:
        rem1 = 'Погашение просроченной дебиторской задолженности по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        rem2 = 'Расход со счета меморандума списанной дебиторской задолженности по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        rem3 = 'Уменьшение суммы исполненных требований по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        /*rem4 = 'по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.*/
        vparam = string(0) + vdel + string(vcrc) + vdel + vaaa2 + vdel + '28' + vdel + vaaa2 + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(v-amttreb) + vdel + string(vcrc) + vdel + '1' + vdel + v-acc + vdel +  '495300' + vdel + rem1 +
                        vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '830300' + vdel + '28' + vdel + vaaa2 + vdel + rem3 +
                        vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '813000' + vdel + '713013' + vdel + rem2 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem1.
                        /*vdel + string(garan.sumzalog) + vdel + string(v-crczal) + vdel + '825000' + vdel + '21' + vdel + vaaa2 + vdel + rem4.*/
    end.

    if (v-sel = '1' or v-sel = '2' or v-sel = '3') and keyfunction (lastkey) <> "end-error" then do:
        s-jh = 0.
        rcode = 0.
        v-templ = 'cif0028'.
        run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message v-templ ' ' rdes.
            pause.
            return.
        end.

    end.
    if keyfunction (lastkey) <> "end-error" then do:
        if v-sel = '1' then message  'Дебеторская задолженность погашена. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        if v-sel = '2' then message  'Дебеторская задолженность списана с баланса. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        if v-sel = '3' then message  'Списаная с баланса дебеторская задолженность погашена. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        if v-sel <> '4' then run vou_bank(2).
        if v-sel = '4' then do:
            hide frame summa no-pause.
            hide frame faaa no-pause.
           return.
         end.
    end.
    hide frame summa no-pause.
    hide frame faaa no-pause.


end.
/******формирование резервов********/
on choose of b-rezerv in frame a2 do:
    if lvr = true then do:
        message "У вас нет прав на выполнение данной операции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if v-jh = ? then do:
        message  'Резерв по гарантии не может быть сформирован/уменьшен. Гарантия не выдана.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    if dto < g-today then do:
        message  'Резерв по гарантии не может быть сформирован/уменьшен. Срок действия ганатии истек.' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    /*провериь досрочное погашение гарантии*/
    v-sumgar = 0.
    run lonbalcrc('cif',vaaa2,g-today,"7",yes,vcrc,output v-sumgar).
    if v-sumgar = 0 then do:
       message "Резерв по гарантии не может быть сформирован/уменьшен. Гарантия погашена." view-as alert-box.
       return.
    end.

    v-amttreb = 0.
    v-amtvalid = 0.
    v-title = ''.
    v-validate = ''.
    v-sel = ''.


    run sel2 (" Выбор: ", " 1. Создание резерва | 2. Уменьшении ранее признанного резерва | 3. Выход ", output v-sel).
    if keyfunction (lastkey) = "end-error" then hide frame summa.


    if v-sel = '1' or v-sel = '2' then do:
        if trim(v-codfr) = '3' then do:
            message  'По гарантиям обеспеченным деньгами НЕ формируются/уменьшаются резервы' view-as alert-box title 'ВНИМАНИЕ'.
            return.
        end.
        v-amttrebhis = 0.
        find first jh where jh.jh = v-jh no-lock no-error.
        for each jl where jl.jdt >= jh.jdt and jl.dc = 'C' and jl.acc = vaaa2 and jl.lev = 27 no-lock:
            if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 then next.


            find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'D' and b-jl.ln = jl.ln - 1 no-lock no-error.
           if avail b-jl and b-jl.gl = 546500 then v-amttrebhis = v-amttrebhis + jl.cam.

        end.

        for each jl where jl.jdt >= jh.jdt and jl.dc = 'D' and jl.acc = vaaa2 and jl.lev = 27 no-lock:
            if index(jl.rem[1],'сторно') <> 0 or index(jl.rem[2],'сторно') <> 0 then next.
            find first b-jl where b-jl.jh = jl.jh and b-jl.dc = 'C' and b-jl.ln = jl.ln + 1 no-lock no-error.
            if avail b-jl and b-jl.gl = 495800 then v-amttrebhis = v-amttrebhis - jl.dam.
        end.

        if v-sel = '1' then do:
            if v-amttrebhis >= sumtreb then do:
               message  'Резерв по гарантии уже сформирован.' view-as alert-box title 'ВНИМАНИЕ'.
               return.
            end.
            else assign v-amttreb = sumtreb - v-amttrebhis v-amtvalid = sumtreb - v-amttrebhis.
        end.
        else do:
            if v-amttrebhis > 0 then assign v-amttreb = v-amttrebhis v-amtvalid = v-amttrebhis.
            else do:
               message  'Резерв по гарантии не может быть уменьшен, т.к. он ранее не был сформирован.' view-as alert-box title 'ВНИМАНИЕ'.
               return.
            end.
        end.
        v-title = 'РЕЗЕРВ'.
        v-validate = 'Сумма резерва должна быть больше нуля и меньше или равна  '.
    end.

    if (v-sel = '1' or v-sel = '2') and keyfunction (lastkey) <> "end-error" then do:
        update v-amttreb  with frame summa.
        hide frame summa.
    end.

    if v-sel = '1' or v-sel = '2' then do:
       v-form = yes.
       if v-sel = '1' then message 'Сформировать резерв?' view-as alert-box question buttons yes-no update v-form.
       else message 'Уменьшить резерв?' view-as alert-box question buttons yes-no update v-form.
       if not v-form then return.

       vparam = ''.
       rem1 = ''.
       rem2 = ''.
       if v-sel = '1' then rem1 = 'Формирование резерва гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
       else rem1 = 'Уменьшение ранее признанного резерва гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.

       if v-sel = '1' then vparam = string(v-amttreb) + vdel + string(vcrc) + vdel + '546500' + vdel + '27' + vdel + vaaa2 + vdel + rem1 + vdel + string(0) + vdel + '26' + vdel + vaaa2 + vdel + '495800' + vdel + rem2.
       else vparam = string(0) + vdel + string(vcrc) + vdel + '495800' + vdel + '26' + vdel + vaaa2 + vdel + rem1 + vdel + string(v-amttreb) + vdel + '27' + vdel + vaaa2 + vdel + '495800' + vdel + rem2.
       s-jh = 0.
       rcode = 0.
       v-templ = 'cif0026'.
       run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

       if rcode ne 0 then do:
           message v-templ ' ' rdes.
           pause.
           return.
       end.
       if v-sel = '1' then message  'Резерв по гарантии сформирован. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
       if v-sel = '2' then message  'Резерв по гарантии уменьшен. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
       run vou_bank(2).
    end.
end.
/*******выводим сохраненный график************/
on choose of b-graf in frame a2 do:
    run garangrfprint(vaaa2).

end.
/*****погашение/списане просроченной комиссии*******/
on choose of b-proscom in frame a2 do:
    if lvr = true then do:
        message "У вас нет прав на выполнение данной операции!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    find first aaa where aaa.aaa = garan.garan no-lock no-error.
    v-amttreb = get_amt(garan.garan,aaa.gl,31,g-today, "cif", garan.crc).
    v-amttreb = v-amttreb + get_amt(garan.garan,aaa.gl,32,g-today, "cif", garan.crc).
    if v-amttreb = 0 then do:
        message "По данной гарантии нет просроченной комиссии!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.

    v-amttreb = 0.
    v-amtvalid = 0.
    v-title = 'Сумма комиссии'.
    v-validate = 'Сумма комиссии должна быть больше нуля и меньше или равна  '.
    v-sel = ''.


    run sel2 (" Выбор: ", " 1. Погашение пророченной комиссии | 2. Списание просроч. комиссии с баланса | 3. Погашение спис. проcроч. комиссии | 4. Выход ", output v-sel).
    if v-sel = '1' or v-sel = '2' then assign v-amttreb = get_amt(garan.garan,aaa.gl,31,g-today, "cif", garan.crc)
                               v-amtvalid = get_amt(garan.garan,aaa.gl,31,g-today, "cif", garan.crc).
    if v-sel = '3' then assign v-amttreb = get_amt(garan.garan,aaa.gl,32,g-today, "cif", garan.crc)
                               v-amtvalid = get_amt(garan.garan,aaa.gl,32,g-today, "cif", garan.crc).

    if keyfunction (lastkey) = "end-error" then hide frame summa.
    if (v-sel = '1' or v-sel = '2' or v-sel = '3') and keyfunction (lastkey) <> "end-error" then do:
        if v-sel <> '2' then update v-amttreb  with frame summa.
        /*else display v-amttreb  with frame summa.*/
        hide frame summa.
    end.

    v-form = yes.
    if v-sel = '1' then message 'Погасить просроченную комиссию?' view-as alert-box question buttons yes-no update v-form.
    if v-sel = '2' then message 'Списать просроченную комиссию с баланса?' view-as alert-box question buttons yes-no update v-form.
    if v-sel = '3' then message 'Погасить списанную с баланса просроченную комиссию?' view-as alert-box question buttons yes-no update v-form.
    if not v-form then return.


    vparam = ''.
    rem1 = ''.
    v-gldoh = ''.
    v-gldoh = if lookup(trim(garan.obesp),'3,5') > 0 then '460610' else '460620'.
    if v-sel = '1' then do:
        rem1 = 'Оплата просроченной комиссии по гарантии № ' + garan.garnum + ' от ' + string(garan.dtfrom,'99/99/9999') + 'г.'.

        vparam = string(v-amttreb) + vdel + string(garan.crc) + vdel + '1' + vdel + vaaa3 + vdel + '31' + vdel + garan.garan + vdel + rem1
                 + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + vaaa3 + vdel + '29' + vdel + garan.garan + vdel + rem2
                 + vdel + string(0) + vdel + string(garan.crc) + vdel + '1' + vdel + vaaa3 + vdel + '29' + vdel + garan.garan + vdel + rem3.
        v-templ = 'cif0029'.
    end.
    if v-sel = '2' then do:
        v-templ = 'cif0028'.
        rem1 = 'Списание с баланса просроченной комиссии по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        vparam = string(0) + vdel + string(vcrc) + vdel + vaaa2 + vdel + '1' + vdel + vaaa2 + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(v-amttreb) + vdel + string(vcrc) + vdel + '32' + vdel + vaaa2 + vdel +  '813000' + vdel + rem1 +
                        vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + v-gldoh + vdel + '31' + vdel + vaaa2 + vdel + rem1 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '813000' + vdel + '713013' + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem1. /*нулевая сумма - параметры не важны*/

    end.
    if v-sel = '3' then do:
        v-templ = 'cif0028'.
        rem1 = 'Оплата списаной с баланса просроченной комиссии по гарантии № ' + v-garan + ' от ' + string(dfrom,'99/99/9999') + 'г.'.
        vparam = string(0) + vdel + string(vcrc) + vdel + vaaa2 + vdel + '28' + vdel + vaaa2 + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(v-amttreb) + vdel + string(vcrc) + vdel + '1' + vdel + vaaa3 + vdel +  v-gldoh + vdel + rem1 +
                        vdel + string(v-amttreb) + vdel +  string(vcrc) + vdel + '813000' + vdel + '32' + vdel + vaaa2 + vdel + rem1 +
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '813000' + vdel + '713013' + vdel + rem1 + /*нулевая сумма - параметры не важны*/
                        vdel + string(0) + vdel +  string(vcrc) + vdel + '713013' + vdel + '813000' + vdel + rem1. /*нулевая сумма - параметры не важны*/

    end.
    if v-sel  = '1' or v-sel  = '2' or v-sel  = '3' then do:
        s-jh = 0.
        rcode = 0.
        run trxgen (v-templ, vdel, vparam, "CIF", vaaa2, output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
            message v-templ ' ' rdes.
            pause.
            return.
        end.
        if v-sel = '1' then message  'Просроченная комиссия погашена. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        if v-sel = '2' then message  'Просроченная комиссия списана с баланса. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        if v-sel = '3' then message  'Списанная с баланса просроченная комиссия погашена. Номер проводки ' + string(s-jh) view-as alert-box title 'ВНИМАНИЕ'.
        run vou_bank(2).
    end.
end.

enable b1 b2 b-ext /*all*/ with frame a2.
wait-for window-close of current-window.

procedure showinfo.
    ListType:SCREEN-VALUE IN frame garan0 = ListType:ENTRY(IntType).
    displ v-cif v-name v-jh vaaa2 vcrc v-crcname vaaa vsum v-garan v-gardop v-nomgar ListType dfrom dtdop dto v-codfr vobes sumzalog v-crczal v-crczname sumtreb /*vcrc*/ vaaa3 v-jh2 sumkom vcrc3 v-crc3name dcom
          v-bankben v-naim v-address v-fname v-lname v-mname v-benres v-benrdes v-bentdes v-bentype v-bencount v-bencountr  v-grcom v-mcomsum v-mcom% v-mlstdate /*v-mdate*/ with frame garan0.
end procedure.

procedure fill_form.
    find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
    if avail garan then do:
        assign v-cif     = garan.cif
               vaaa2     = garan.garan
               vsum      = garan.sum
               v-garan   = garan.garnum
               v-gardop  = garan.dopnum
               v-nomgar  = garan.info[1]
               vaaa      = garan.aaa2
               dfrom     = garan.dtfrom
               dtdop     = garan.dtdop
               dto       = garan.dtto
               v-codfr   = garan.obes
               sumzalog  = garan.sumzalog
               v-crczal  = garan.crczal
               sumtreb   = garan.sumtreb
               vcrc      = garan.crc
               vcrc3     = garan.crc2
               sumkom    = garan.sumkom
               dcom      = date(garan.info[2])
               vaaa3     = garan.aaa3
               v-bankben = garan.bankben
               v-benres  = garan.benres
               v-bentype = garan.bentype
               v-naim    = garan.naim
               v-fname   = garan.fname
               v-lname   = garan.lname
               v-mname   = garan.mname
               v-address = garan.address
               v-jh      = garan.jh
               v-jh2     = garan.jh2
               IntType   = garan.gtype
               v-crcname = ''
               vobes     = ''
               v-bencount = garan.bencountry.
               v-grcom = garan.grafcom.
               v-mcomsum = garan.mcomsum.
               v-mcom% = garan.mcom%.
               v-mlstdate = garan.mlastday.
               /*v-mdate = garan.mdtcom.*/

        find cif where cif.cif = v-cif no-lock no-error.
        if avail cif then assign v-name = trim(trim(cif.prefix) + " " + trim(cif.name))
                                 v-rnn  = cif.jss.

        find first crc where crc.crc = vcrc no-lock no-error.
        if avail crc then v-crcname = crc.code.

        find first lonsec where lonsec.lonsec = integer(trim(v-codfr)) no-lock no-error.
        if avail lonsec then vobes = lonsec.des.

        if v-benres = 1 then v-benrdes = 'резидент'.
        else v-benrdes = 'нерезидент'.

        find first crc where crc.crc = vcrc3 no-lock no-error.
        if avail crc then v-crc3name = crc.code.

        find first crc where crc.crc = v-crczal no-lock no-error.
        if avail crc then v-crczname = crc.code.

        v-bentdes = if v-bentype = 1 then 'Юридическое лицо' else if v-bentype = 2 then 'Физическое лицо' else 'Индивидуальный предприниматель'.

        find first codfr where codfr.codfr = 'countnum' and codfr.code = v-bencount no-lock no-error.
        if avail codfr then v-bencountr = codfr.name[1].

        ListType:SCREEN-VALUE IN frame garan0 = ListType:ENTRY(IntType).

    end.

end procedure.

procedure del_trx.
    def input parameter p-jh as integer no-undo.
    v-jdt = g-today.
    v-our = yes.
    v-finish = no.
    v-cash = no.
    for each jl where jl.jh eq p-jh no-lock:
        if jl.sts eq 6 then v-finish = yes.
        if jl.gl eq v-cashgl then v-cash = yes.
        if jl.jdt ne g-today then v-jdt = jl.jdt.
        if jl.who ne g-ofc then v-our = no.
    end.
    find jh where jh.jh eq p-jh no-lock no-error.
    if not v-our then do:
        message "Вы не можете удалить чужую транзакцию." view-as alert-box information buttons ok.
        return.
    end.
    if v-finish and v-cash then do:
        message "Вы не можете удалить выполненную кассовую транзакцию (" + string(p-jh) + ")." view-as alert-box information buttons ok.
        return.
    end.

    ja = no.
    if v-jdt ne g-today then do:
        message "Транзакция " + string(p-jh) + " не текущего дня. Выполнить сторно?" view-as alert-box question buttons yes-no update ja.
        if not ja then return.
    end.
    if v-jdt eq g-today then do:
        v-sts = 0.
        run trxsts(input p-jh, input v-sts, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.
        run trxdel(input p-jh, input true, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.
        else do:
            message 'Транзакция ' + string(p-jh) + ' была успешно удалена'.
            pause 20.
            find first garan where garan.garan = vaaa2 and garan.cif = v-cif exclusive-lock no-error.
            if avail garan then do:
                if  garan.jh = p-jh then do:
                    garan.jh = 0.
                    v-jh = 0.
                    display v-jh with frame garan0.
                end.
                if  garan.jh2 = p-jh then do:
                    garan.jh2 = 0.
                    v-jh2 = 0.
                    display v-jh2 with frame garan0.
                end.
            end.
        end.
    end.  /* nataly v-jdt eq g-today - транзакция сегодня */
    else do:
        v-sts = 0. s-jh = 0.
        run trxstor(input p-jh, input v-sts, output s-jh, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes view-as alert-box.
            return.
        end.

        /* pechat vauchera */
        ja = no.
        vou-count = 1. /* kolichestvo vaucherov */
        find jh where jh.jh eq s-jh no-lock no-error.
        do on endkey undo:
            message "Печатать ваучер ? " + string(s-jh) view-as alert-box
            buttons yes-no update ja.
            if ja then do:
                message "Сколько ?" update vou-count.
                if vou-count > 0 and vou-count < 10 then do:
                    find first jl where jl.jh = s-jh no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jh.
                        do i = 1 to vou-count: run x-jlvou. end.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5 then jl.sts = 5.
                        end.
                    end. /* if available jl */
                    else do:
                        message "Can't find transaction " s-jh view-as alert-box.
                        return.
                    end.
                end.  /* if vou-count > 0 */
            end. /* if ja */
            pause 0.
        end.
        pause 0.
    end.
end procedure.

procedure updgaran.
    update vsum     with frame garan0.
        find first aaa where aaa.aaa = vaaa2 no-lock no-error.
        if (aaa.gl = 224011 or aaa.gl = 224021) and vsum = 0 then do:
            if lookup(aaa.lgr,'455,456,457,466,467,468,469,494,495,496') > 0 then do:
                ja = no.
                message ' Вы не указали сумму покрытия! Продолжить? ' update ja.
                if not ja then return.
            end.
            else do:
                message 'Гаратия обеспечена деньгами. Введите сумму покрытия!' view-as alert-box.
                return.
             end.
        end.

        if (aaa.gl = 224013 or aaa.gl = 224023) and vsum > 0 then do:
            message 'Гарантия необеспеченная. Сумма покрытия должна быть = 0!' view-as alert-box.
            return.
        end.

    update v-garan  with frame garan0.
    update v-gardop  with frame garan0.
    update v-nomgar with frame garan0.
    update ListType with frame garan0.

    if vsum > 0 then do:
        update vaaa with frame garan0.

        find first aaa where aaa.aaa = vaaa no-lock no-error.
        if not available aaa then do:
            message "Счет " + vaaa + " не существует!" view-as alert-box title " Внимание! ".
            pause.
            next.
        end.

        if aaa.sta = "C" or aaa.sta = "E" then do:
            message "Счет " + vaaa + " закрыт!" view-as alert-box title  " Внимание! ".
            pause.
            next.
        end.
        if lookup(substr(string(aaa.gl),1,4),'2203,2204') = 0 then do:
            message "Счет должен быть открыт на балансовом счете 2203 или 2204!" view-as alert-box title 'ВНИМАНИЕ!'.
            pause.
            next.
        end.
    end.
    else vaaa = ''.

    update dfrom   with frame garan0.
    update dtdop   with frame garan0.
    update dto     with frame garan0.
    update v-codfr with frame garan0.

    find first lonsec where lonsec.lonsec = integer(trim(v-codfr)) no-lock no-error.
    if avail lonsec then vobes = lonsec.des.
    displ vobes with frame garan0.

    if trim(v-codfr) <> '1' then update sumzalog with frame garan0.
    if sumzalog > 0 then do:
        update v-crczal with frame garan0.
        find first crc where crc.crc = v-crczal no-lock no-error.
        if avail crc then v-crczname = crc.code.
        displ v-crczname with frame garan0.
    end.


    update sumtreb with frame garan0.
    if sumtreb <> vsum then do:
        ja = no.
        message ' Сумма гарантии не равна сумме покрытия! Продолжить? ' update ja.
        if not ja then return.
    end.

    /*03.11.03 nataly*/
    /*update vcrc with frame garan0.
    find bcrc where bcrc.crc = baaa.crc no-lock no-error.
    /* 26/09/05 nataly */
    if bcrc.crc <> vcrc then do:
        message 'Валюта депозита-гарантии ' + string(bcrc.crc) + ' не соответствует валюте гарантии ' + string(vcrc) + '!'.
        pause 5.
        next. /* upper.*/
    end.
    /* 26/09/05 nataly */
    */
    /*****galina - построение графика**/
    if v-jh = 0 then do:
        v-mcom%_old =  v-mcom%.
        update v-grcom with frame garan0.

        if v-grcom then do:
            sumkom = 0.
            display sumkom dcom with frame garan0.
            update v-mcom%  with frame garan0.
            if v-mcom% <> v-mcom%_old then v-mcomsum = ((sumtreb * v-mcom% / 100) / 360) * 30.
            update v-mcomsum with frame garan0.
            update v-mlstdate with frame garan0.
            if v-mlstdate then dcom = date(month(get-date(dfrom,1)),1,year(get-date(dfrom,1))) - 1.
            else if dcom = g-today then dcom = get-date(dfrom,1).
            update dcom with frame garan0.
            run garangrfcre(vaaa2,dfrom,dto,/*v-mdate*/ dcom,v-mcomsum, output sumkom).
            display sumkom dcom with frame garan0.
            repeat:
                update vaaa3  with frame garan0.
                if vaaa3 <> '' then leave.
                else message 'Введите расчетный счет для оплаты комиссии!' view-as alert-box.
            end.
            update vcrc3  with frame garan0.
            find first crc where crc.crc = vcrc3 no-lock no-error.
            if avail crc then v-crc3name = crc.code.
            displ v-crc3name with frame garan0.
        end.
        else do:

            find first garancomgraf where garancomgraf.garan = vaaa2 no-lock no-error.
            if avail garancomgraf then do:

                for each garancomgraf where garancomgraf.garan = vaaa2 exclusive-lock:
                     delete garancomgraf.

                end.
            end.
            v-mlstdate = no.
            v-mcomsum = 0.
            dcom = g-today.
            display v-mlstdate v-mcomsum dcom with frame garan0.
            /*тут надо решить что делать*/
            old_sumcom = sumkom.
            repeat:
               update sumkom with frame garan0.
               if sumkom >= old_sumcom  then leave.
               sumkom = old_sumcom.
               message "Нелья уменьшать сумму комиссии!" view-as alert-box warning.
            end.

            update vcrc3  with frame garan0.
            find first crc where crc.crc = vcrc3 no-lock no-error.
            if avail crc then v-crc3name = crc.code.
            displ v-crc3name with frame garan0.

            update dcom   with frame garan0.
            update vaaa3  with frame garan0.

            if vaaa3 = '' then message "Комиссия будет оплачена через кассу!" view-as alert-box warning.

            if vaaa3 = '' then do:
                /* счет кассы в пути в валюте vcrc3 */
                run get100200arp(input g-ofc, input vcrc3, output v-yn, output s_account_b, output v-err).
                if v-err then do:
                    /*если ошибка имела место, то еще раз скажем об этом пользователю*/
                    v-err = not v-err.
                    message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip
                        "произошла ошибка!" view-as alert-box error.
                    return.
                end.

                if v-yn then s_account_a = "". /*касса в пути*/
                else do:
                    /*касса*/
                    s_account_a = string(c-gl).
                    s_account_b = "".
                end.
            end.

        end.



    end.



    update v-bankben with frame garan0.
    update v-benres  with frame garan0.

    if v-benres = 1 then v-benrdes = 'резидент'.
    else  v-benrdes = 'нерезидент'.
    display v-benrdes with frame garan0.

    if v-benres = 1 then v-bencount = '398'.
    else update v-bencount with frame garan0.
    find first codfr where codfr.codfr = 'countnum' and codfr.code = v-bencount no-lock no-error.
    if avail codfr then v-bencountr = codfr.name[1].
    display v-bencount v-bencountr with frame garan0.

    update v-bentype  with frame garan0.
    if v-bentype = 1 then v-bentdes = 'Юридическое лицо'.
    if v-bentype = 2 then v-bentdes = 'Физическое лицо'.
    if v-bentype = 3 then v-bentdes = 'Индивидуальный предприниматель'.
    display v-bentdes with frame garan0.

    if v-bentype = 1 then update v-naim with frame garan0.
    else update v-fname v-lname v-mname with frame garan0.

    update v-address with frame garan0.

end procedure.

procedure savegaran.
  if v-select = 1 then do transaction:
        find first garan where garan.garan = vaaa2 and garan.cif = v-cif no-lock no-error.
        if not avail garan then do:
            create garan.
            assign garan.whn = g-today
                   garan.who = g-ofc
                   garan.cif = v-cif
                   garan.garan = vaaa2.
            /*s-lon = garan.garan.*/
        end.
        else find current garan exclusive-lock no-error.
        /* Luiza запоминаем старые значения суммы комиссии и сумму с амортизированной комиссии*/
        old_sumcom = garan.sumkom.
        /*------------------------------*/
        assign garan.sum      = vsum
               garan.garnum   = v-garan
               garan.dopnum   = v-gardop
               garan.info[1]  = v-nomgar
               garan.aaa2     = vaaa
               garan.dtfrom   = dfrom
               garan.dtdop    = dtdop
               garan.dtto     = dto
               garan.obes     = v-codfr
               garan.sumzalog = sumzalog
               garan.crczal   = v-crczal
               garan.sumtreb  = sumtreb
               garan.crc      = vcrc
               garan.crc2     = vcrc3
               garan.sumkom   = sumkom
               garan.info[2]  = string(dcom,'99/99/9999')
                  /*string(sumkom)*/
               garan.aaa3     = vaaa3
               garan.bankben  = v-bankben
               garan.benres   = v-benres
               garan.bentype  = v-bentype
               garan.naim     = v-naim
               garan.fname    = v-fname
               garan.lname    = v-lname
               garan.mname    = v-mname
               garan.address  = v-address
               garan.gtype    = IntType
               garan.grafcom = v-grcom
               garan.mcomsum = v-mcomsum
               garan.mcom% = v-mcom%
               garan.mlastday = v-mlstdate.
               if v-jh = 0 then garan.info[3]  = string(decimal(garan.info[3]) + sumkom - old_sumcom).
            s-lon = garan.garan.
            v-cif = garan.cif.
            garan.bencountry = v-bencount.

/* 30.09.2011 lyubov */
        run garan_rem.
        create gar%his.
            assign gar%his.whn      = g-today
                   gar%his.who      = g-ofc
                   gar%his.cif      = v-cif
                   gar%his.garan    = vaaa2
                   gar%his.sum      = vsum
                   gar%his.garnum   = v-garan
                   gar%his.dopnum   = v-gardop
                   gar%his.info[1]  = v-nomgar
                   gar%his.aaa2     = vaaa
                   gar%his.dtfrom   = dfrom
                   gar%his.dtdop    = dtdop
                   gar%his.dtto     = dto
                   gar%his.obes     = v-codfr
                   gar%his.sumzalog = sumzalog
                   gar%his.crczal   = v-crczal
                   gar%his.sumtreb  = sumtreb
                   gar%his.crc      = vcrc
                   gar%his.crc2     = vcrc3
                   gar%his.sumkom   = sumkom
                   gar%his.info[2]  = string(dcom,'99/99/9999')
                   /*gar%his.info[3]  = string(decimal(garan.info[3]) + sumkom - old_sumcom) */  /*string(sumkom)*/
                   gar%his.aaa3     = vaaa3
                   gar%his.bankben  = v-bankben
                   gar%his.benres   = v-benres
                   gar%his.bentype  = v-bentype
                   gar%his.naim     = v-naim
                   gar%his.fname    = v-fname
                   gar%his.lname    = v-lname
                   gar%his.mname    = v-mname
                   gar%his.address  = v-address
                   gar%his.gtype    = IntType
                   gar%his.rem      = remark
                   gar%his.bencountry = v-bencount
                   gar%his.grafcom = v-grcom
                   gar%his.mcomsum = v-mcomsum
                   gar%his.mcom% = v-mcom%
                   gar%his.mlastday = v-mlstdate.

                   if v-jh = 0 then gar%his.info[3]  = string(decimal(garan.info[3]) + sumkom - old_sumcom).
                   if not v-grcom then do:

                        find first garancomgraf where garancomgraf.garan = vaaa2 no-lock no-error.
                        if avail garancomgraf then do:

                            for each garancomgraf where garancomgraf.garan = vaaa2 exclusive-lock:
                                 delete garancomgraf.

                            end.
                        end.

                   end.
/* 30.09.2011 lyubov */

  end.
  enable b-trx b-obes /*b-usl*/ b-doc b-sts b-klass b-chc b-graf b-ext  with frame a2.

end procedure.
