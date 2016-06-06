/* lb100s.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Программа формирования файла сообщения по СМЭП при выгрузке
 * RUN

 * CALLER
        lbtos.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19/08/2013 galina ТЗ1871
 * BASES
        BANK
 * CHANGES
 */



def input parameter iddat as date.

def shared var g-today as date .
def shared var g-ofc as cha .
def new shared var v-text as cha .
def shared var vvsum as deci .
def shared var nnsum as int .
def shared var vnum as int .
def shared var mtsize as integer. /* максимальный размер файла сообщения в килобайтах */
def shared var mt102_max as integer.

def var t-summ like remtrz.amt .
def var amttot like remtrz.payment .
def var cnt as int .

def var v-sum as decimal init 0.
def var v-kol as integer init 0.


def new shared temp-table t-docsmep
  field bstr as char
  field rem as char
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  index main sbank sacc rbank racc rem.

v-text = "Контроль! Запуск lb100g " + g-ofc.
run lgps.




find first clrdos where clrdos.rdt = g-today and clrdos.pr = vnum no-lock no-error.
if not  available clrdos then
do:
	Message "There isn't SMEP # " + string(vnum) + " in clrdos file " view-as alert-box.
	pause .
	return .
end.

/* определение переменных из sysc */
/*{lb100s.i "'g'"}*/

for each clrdos where clrdos.rdt = g-today and clrdos.pr = vnum no-lock use-index rdtpr by clrdos.bank by clrdos.amt:

  find first remtrz where remtrz.remtrz = clrdos.rem no-lock no-error.
  if not avail remtrz then next.

  if remtrz.cover <> 6 then next.

  create t-docsmep.
  assign t-docsmep.rem = remtrz.remtrz
         t-docsmep.sbank = remtrz.sbank
         t-docsmep.sacc = remtrz.sacc
         t-docsmep.rbank = remtrz.rbank
         t-docsmep.racc = remtrz.racc.
end.

amttot = 0 .
cnt = 0.

find first t-docsmep no-error.
if avail t-docsmep then

	run lb100smp (iddat, cnt, output v-sum, output v-kol).
	amttot = amttot + v-sum.
	cnt = cnt + v-kol.

/*****************************/

v-text = "EKS Electronic messages as-of " + string(g-today) + " was formed by " + g-ofc .
run lgps .

v-text = "EKS Electronic reestr as-of " + string(g-today) + " have formed by "
	+ g-ofc + " Total docs: " + string(cnt) + " Total amount: " + string(amttot).
run lgps .

if vvsum  = amttot and cnt = cnt then
	Message  " Ok ... " view-as alert-box.
else
	Message " Сумма или кол-во док не равно clrdog ! " .

pause.

pause 0 .


