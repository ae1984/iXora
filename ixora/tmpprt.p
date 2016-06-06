/* tmpprt.p
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

def  var s-dolamt as dec.
def  var s-dolstr as char extent 2.
def var vamt as dec.
def var vt1 as int.
def var vt2 like vt1.
def var vt3 like vt1.
def var vt4 like vt1.
def var vt5 like vt1.
def var vm1 like vt1.
def var vm2 like vt1.

def var vone as char form "x(5)" extent 9 init
  ["ONE","TWO","THREE","FOUR","FIVE","SIX","SEVEN","EIGHT","NINE"].

def var vten1 as char form "x(9)" extent 9 init
  ["ELEVEN","TWELVE","THIRTEEN","FOURTEEN","FIFTEEN",
   "SIXTEEN","SEVENTEEN","EIGHTEEN","NINETEEN"].

def var vten2 as char form "x(7)" extent 9 init
  ["TEN","TWENTY","THIRTY","FORTY","FIFTY",
   "SIXTY","SEVENTY","EIGHTY","NINETY"].

def var inc as int.
def var vhunmil as int init 100000000.
def var vmil as int init 1000000.
def var vhuntho as int init 100000.
def var vtho as int init 1000.

assign s-dolstr[1] = "" s-dolstr[2] = "".
s-dolamt = 123456789.
vm1 = integer(truncate(s-dolamt / vhunmil, 0)).
  vamt = s-dolamt - vm1 * vhunmil.
vm2 = integer(truncate(vamt / vmil, 0)).
  vamt = vamt - vm2 * vmil.
vt1 = integer(truncate(vamt / vhuntho, 0)).
  vamt = vamt - vt1 * vhuntho.
vt2 = integer(truncate(vamt / vtho, 0)).
  vamt = vamt - vt2 * vtho.
vt3 = integer(truncate(vamt / 100, 0)).
  vamt = vamt - vt3 * 100.
vt4 = integer(truncate(vamt / 1, 0)).
  vamt = vamt - vt4 * 1.
vt5 = vamt * 100. /* cents */

display vm1 vm2 vt1 vt2 vt3 vt4 vt5.
