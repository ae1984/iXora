/* pkdog-7.p
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
        19/02/07
 * CHANGES
        24/04/2007 madiyar - веб-анкеты
        09/07/07 marinav - v-prem
        24/01/2008 madiyar - добавил шаренную переменную v-effrate
        10/10/2008 alex - добавил наименование организации рефин. кредита
        15/07/2009 madiyar - процент комиссии прописью - на казахском
        02/10/2009 galina - выводим созаемщика
*/

{global.i}
{pk.i}
{pk-sysc.i}

if s-pkankln = 0 then return.

procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
    pkanketh.value1 = p-msg.
    find current pkanketh no-lock.
end procedure.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def shared var v-inet as logi.
def shared var v-toplogo as char.
def shared var v-stamp as char.

if pkanketa.sts < "10" then do:
  if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"pkdog-5 - Некорректный статус!").
  else message skip " Некорректный статус!" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

/* сведения о банке */
def shared var v-bankname as char.
def shared var v-banknamekz as char.
def shared var v-bankadres as char.
def shared var v-bankadreskz as char.
def shared var v-bankiik as char.
def shared var v-bankbik as char.
def shared var v-bankups as char.
def shared var v-bankrnn as char.
def shared var v-bankface as char.
def shared var v-bankfacekz as char.
def shared var v-dol as char.
def shared var v-dolKZ as char.
def shared var v-bankkomupos as char.
def shared var v-bankkomufio as char.
def shared var v-banksuff as char.
def shared var v-bankosn as char.
def shared var v-bankosnkz as char.
def shared var v-bankpodp as char.
def shared var v-bankpodpkz as char.

/* сведения об анкете - общие для всех видов кредитов */
def shared var v-partner as char.
def shared var v-partnername as char.
def shared var v-goal as char.
def shared var v-dognom as char.
def shared var v-zaldognom as char.
def shared var v-city as char.
def shared var v-citykz as char.
def shared var v-datastr as char.
def shared var v-datastrkz as char.
def shared var v-datadoc as char.
def shared var v-billnom as char.
def shared var v-billsum as char.
def shared var v-summa as char.
def shared var v-summawrd as char.
def shared var v-summawrdkz as char.
def shared var v-duedt as char.
def shared var v-prem as char.
def shared var v-premwrd as char.
def shared var v-base as char.
def shared var v-basewrd as char.
def shared var v-name as char.
def shared var v-namefull as char.
def shared var v-nameshort as char.
def shared var v-rnn as char.
def shared var v-sik as char.
def shared var v-srok as char.
def shared var v-docnum as char.
def shared var v-docdt as char.
def shared var v-docvyd as char.
def shared var v-adres as char extent 2.
def shared var v-adresfull as char.
def shared var v-adreslabel as char.
def shared var v-sumq as char.
def shared var v-sumqwrd as char.
def shared var v-predpr as char.
def shared var v-telefon as char.
def shared var v-telefonr as char.
def shared var v-joborg as char.
def shared var v-effrate as char.
def shared var v-credval as char.

def var v-prem1 as deci.

def var v-where as char. /*организация рефинансирования*/

/* дополнительные сведения - для каждого вида кредита свои */
def var v-addnom as char.
def var v-yessuprug as logical.
def var v-suprug as char.
def var v-com as char.
def var v-comwrd as char.
def var v-comwrd_kz as char.
def var v-com1 as char.
def var v-com1wrd as char.

/*galina*/
/* сведения об анкете - общие для всех видов кредитов */
def shared var v-names as char.
def shared var v-rnns as char.
def shared var v-docnums as char.
def shared var v-docdts as char.
def shared var v-adress as char extent 2.
def shared var v-telefons as char.
def shared var v-nameshorts as char.
/**/

v-addnom = entry(3, pkanketa.rescha[1]).

find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
if avail pksysc then v-com = string(pksysc.deval).
run Sm-vrd(v-com, output v-comwrd).
run Sm-vrd-KZ(v-com, 0, output v-comwrd_kz).
find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
if avail pksysc then v-com1 = string(pksysc.deval).
run Sm-vrd(v-com1, output v-com1wrd).



find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
     pkanketh.kritcod = "lnames" no-lock no-error.
v-yessuprug = (avail pkanketh and trim(pkanketh.value1) <> "").
if v-yessuprug then do:
  v-suprug = trim(pkanketh.value1).

  find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "fnames" no-lock no-error.
  if avail pkanketh and trim(pkanketh.value1) <> "" then v-suprug = v-suprug + " " + trim(pkanketh.value1).

  find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "mnames" no-lock no-error.
  if avail pkanketh and trim(pkanketh.value1) <> "" then v-suprug = v-suprug + " " + trim(pkanketh.value1).

  v-suprug = caps(v-suprug).
end.

/* определим какой тип договора выводить - для 3-ей или 4-ой схемы */
def var scheme as int init -1.
if pkanketa.lon <> "" and pkanketa.lon <> " " then do:
  find lon where lon.lon = pkanketa.lon no-lock no-error.
  if avail lon then scheme = lon.plan.
end.
if scheme = -1 then scheme = get-pksysc-int("pkplan").

/* печать договоров */
/* кредитный договор */
/*v-prem = trim(string(pkanketa.rateq / 3)).*/
run Sm-vrd(deci(v-prem), output v-premwrd).
{pkdog-all.i}

/* Подтверждение, Согласие на предоставление информации в бюро, Согласие на выдачу кредитного отчета */
run pksski.

/* Печать договора о замене удостоверения личности в случае необходимости
   29.11.2004 saltanat*/
{pkdogudv.i}

/* печать заявления на досрочное погашение - рефинансирование */
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
     pkanketh.kritcod = "rnn" no-lock no-error.
if avail pkanketh and pkanketh.rescha[1] <> '' and pkanketh.resdec[1] > 0 then run pkrefpog(entry(1,pkanketh.rescha[1])).
