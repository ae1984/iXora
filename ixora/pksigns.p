/* pksigns.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Образец подписи
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
        27/07/2005 madiyar
 * BASES
        bank, comm
 * CHANGES
        21/12/2005 madiyar - электронная печать
        12/09/2006 madiyar - электронная печать - все филиалы
        19/12/2008 Levin V.E. - переработано формирование файла на шаблон
        24/03/2009 madiyar - в анкетах формировался некорректно, подправил
        19/01/2010 galina - добавила ИИН
        08/11/2010 madiyar - два адреса, каждый в своей строке
*/

{global.i}
{pk.i}
{pk-sysc.i}
if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.
def input param v-log as logical.
def var v-docdt as char.
def var v-cif as char.
def var v-adres as char extent 2.
def var v-adresd as char extent 2.
def var v-telefonr as char.
def var v-aaa as char.
def new shared var pass as char.
def new shared var v-tel as char.
def new shared var v-work as char.
def new shared var v-rnn as char.
def new shared var v-name as char.
def new shared var v-addr1 as char.
def new shared var v-addr2 as char.
def new shared var v-iik as char.
def new shared var my-log as char.
def new shared var v-ofile as char.
def new shared var s-yur as logical init no.
def new shared var v-pref as char.
def new shared var s-yurhand as logical init no.
def new shared var yur as logical init no.
def new shared var v-iin as char.
v-ofile = "sign.htm".

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
pass = pkanketa.docnum.
v-aaa = pkanketa.aaa.
v-cif = pkanketa.cif.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "iin" no-lock no-error.
if avail pkanketh then v-iin = pkanketh.value1.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
  else v-docdt = string(pkanketh.value1, "99/99/9999").
end.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
if avail pkanketh then v-tel = trim(pkanketh.value1).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel2" no-lock no-error.
if avail pkanketh then v-telefonr = trim(pkanketh.value1).

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
if avail pkanketh then v-work = trim(pkanketh.value1).

run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).

my-log = v-cif.
pass = pass + trim(string(v-docdt)).

if v-log then v-addr1 = v-adres[1].
else assign v-addr1 = '' v-tel = ''.

v-work = v-work + v-telefonr.
run Form-k.
