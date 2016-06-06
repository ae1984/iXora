/* reserv_a.p
 * MODULE
        Монитор
 * DESCRIPTION
        Автоматический расчет МРТ
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
        07/04/06 tsoy
 * CHANGES
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
	19/10/06 u00121 добавил no-undo, no-lock  в поиски по таблицам, убрал global.i вместо явно прописал необходимые глобальные переменные.
			и вообще, массовое использование глобальных переменных введет к нецелесообразному использованию памяти, в global.i и "тучи", здесь используется одна,
			а память выделяется под все. ДОЛОЙ global.i!!!

*/


/* расчет резервных требований */

def input parameter  p-dt as date.

def new shared stream st-out.

def shared var g-today as date.

def new shared var v-gl as char no-undo.
def new shared var s-gl as char no-undo.
def new shared var vasof as date no-undo.
def new shared var v-pass as char no-undo.

def new shared var i as int no-undo.  
def new shared var k as int no-undo.

/*def var sum as decimal.*/
/*def var coef as decimal.*/
/*def var v-tmp as decimal format 'zzzzzzzzz9'.*/




for each sysc field (sysc.chval) where sysc.sysc="SYS1" no-lock.
	v-pass = ENTRY(1,sysc.chval).
end.

def new  shared  temp-table temp   no-undo
  field  kod  as char
  field  gl  as integer   format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 
  
def  temp-table final no-undo  
  field  kod  as char
  field  gl  as integer   format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

define new shared variable dcCash as decimal no-undo.
define new shared variable dcLiab as decimal no-undo.


v-gl = '2201,2202,2203,2204,2205,2209,2211,2221,2222,2225,2226,2227,2228,2229,2250,2301,2303,2552,2870,2855'.
s-gl = '1001,1002,1003,1005,1007,1008'.


vasof = p-dt.


for each comm.txb field (comm.txb.path comm.txb.host comm.txb.service comm.txb.login comm.txb.password) where comm.txb.consolid = true no-lock:
    if connected ("ast") then disconnect "ast". 
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
    run res-prf22.
    if vasof < g-today then 
    	run str5.     
end.

if connected ("ast") then disconnect "ast".

  for each temp where substr(temp.kod,1,1) = '1' no-lock:
      ACCUM temp.val (TOTAL).
  end.

  dcCash = ACCUM TOTAL temp.val.

  for each temp where substr(temp.kod,1,1) = '2' no-lock:
      ACCUM temp.val (TOTAL).
  end.

  dcLiab = ACCUM TOTAL temp.val.

run mrt_a.

pause 0.

