/* pkpartnext.p
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
        31/12/99 pragma
 * CHANGES
*/

/* pkpartnext.p ПотребКредиты
   Ввод реквизитов предприятия-партнера для внешних платежей

   21.04.2003 nadejda
*/            

{global.i}

def input parameter p-cod as char.
def output parameter p-req as char.

def shared var v-codif as char.

find codfr where codfr.codfr = v-codif and codfr.code = p-cod no-lock no-error.
if not avail codfr then return.

def var v-name as char.
def var v-nameplat as char.
def var v-rnn as char.
def var v-irs as integer.
def var v-irsdes as char.
def var v-seco as char.
def var v-secodes as char.
def var v-acc as char.
def var v-mfo as integer.
def var v-bank as char.

v-name = codfr.name[1].

p-req = codfr.name[4].
if codfr.name[4] <> "" then do:
  /* разобрать реквизиты по отдельным данным */
  v-nameplat = entry(1, codfr.name[4], "|").

  if num-entries(codfr.name[4], "|") >= 2 then v-rnn = entry(2, codfr.name[4], "|").
                                          else v-rnn = "".
  if num-entries(codfr.name[4], "|") >= 3 then v-irs = integer(entry(3, codfr.name[4], "|")).
                                          else v-irs = 1.
  if num-entries(codfr.name[4], "|") >= 4 then v-seco = entry(4, codfr.name[4], "|").
                                          else v-seco = "7".
  if num-entries(codfr.name[4], "|") >= 5 then v-acc = entry(5, codfr.name[4], "|").
                                          else v-acc = "".
  if num-entries(codfr.name[4], "|") >= 6 then v-mfo = integer(entry(6, codfr.name[4], "|")).
                                          else v-mfo = 0.
end.
else do:
  v-nameplat = v-name.
  v-rnn = "".
  v-irs = 1.
  v-seco = "7".
  v-acc = p-cod.
  v-mfo = 0.
end.

if v-irs = 1 then v-irsdes = "резидент". else v-irsdes = "нерезидент".

find codfr where codfr.codfr = "secek" and codfr.code = v-seco no-lock no-error.
if avail codfr then v-secodes = codfr.name[1]. else v-secodes = "".

find bankl where bankl.bank = string(v-mfo) no-lock no-error.
if avail bankl then v-bank = bankl.name. else v-bank = "".

function checkacc returns logical (p-val as char).
  def var vp-i as integer.

  if p-val = "" then return false.

  vp-i = integer(p-val) no-error.
  if error-status:error then return false.

  if vp-i < 1000 then return false.

  return true.
end.

function rnncheck returns logical (p-val as char).
  def var l as logical.

  if p-val = "" then return false.

  if length(p-val) <> 12 then return false.

  run rnnchk( p-val, output l).
  if l then return false.

  return true.
end.

form 
  p-cod format "x(9)" label " КОД ПАРТНЕРА " colon 25 skip
  v-name format "x(40)" label " НАИМЕНОВАНИЕ ПАРТНЕРА " colon 25 skip
  v-nameplat format "x(40)" label " НАИМЕНОВАНИЕ ОРГ-ЦИИ " colon 25 help " Наименование организации для печати в платежном поручении" 
    validate(trim(v-nameplat) <> "", " Введите наименование!")
    skip
  v-rnn format "x(12)" label " РНН " colon 25 help " РНН организации" 
    validate(rnncheck(v-rnn), " Неверный РНН!") skip
  v-irs format "9" label " РЕЗИДЕНТСТВО " colon 25 help " 1 - организация-резидент, 2 - нерезидент"
    validate(v-irs = 1 or v-irs = 2, " Неверный код резидентства!")
  v-irsdes format "x(30)" no-label skip
  v-seco format "x" label " СЕКТОР ЭКОНОМИКИ " colon 25 help " Код сектора экономики организации"
    validate(can-find(first codfr where codfr.codfr = "secek" and codfr.code = string(v-seco) no-lock), " Не найден код сектора экономики!")
  v-secodes format "x(30)" no-label skip
  v-acc format "x(9)" label " ТЕК.СЧЕТ " colon 25 help " Текущий счет организации"
    validate(checkacc(v-acc), " Неверный формат номера текущего счета!") skip
  v-mfo format "999999999" label " МФО БАНКА (БИК) " colon 25 
    validate(can-find(first bankl where bankl.bank = string(v-mfo) no-lock), " Банк не найден!")
  v-bank format "x(40)" no-label skip
  with overlay centered side-label row 9 title " РЕКВИЗИТЫ ПРЕДПРИЯТИЯ " frame f-partnext.

on help of v-seco in frame f-partnext do:
  run uni_help1("secek",'*').
end.

on help of v-mfo in frame f-partnext do:
  run help-bank.
end.

pause 0.                    

view frame f-partnext.

displ
  p-cod
  v-name
  v-nameplat
  v-rnn
  v-irs
  v-irsdes
  v-seco
  v-secodes
  v-acc
  v-mfo
  v-bank
  with frame f-partnext.

update v-nameplat v-rnn v-irs with frame f-partnext.
if v-irs = 1 then v-irsdes = "резидент". else v-irsdes = "нерезидент".
displ v-irsdes with frame f-partnext.

update v-seco with frame f-partnext.
find codfr where codfr.codfr = "secek" and codfr.code = v-seco no-lock no-error.
if avail codfr then v-secodes = codfr.name[1]. else v-secodes = "".
displ v-secodes with frame f-partnext.

update v-acc v-mfo with frame f-partnext.
find bankl where bankl.bank = string(v-mfo) no-lock no-error.
if avail bankl then v-bank = bankl.name. else v-bank = "".
displ v-bank with frame f-partnext.

p-req = v-nameplat + "|" + v-rnn + "|" + string(v-irs) + "|" + v-seco + "|" + v-acc + "|" + string(v-mfo).

hide frame f-partnext no-pause.

