/* out_O_ps.p
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
        21.02.2005 tsoy     - добавил время создания платежа.
        15.07.2005 saltanat - добавила переменные s-cif, s-rnn для psror-2.f
        25.01.2006 suchkov  - перекомпиляция
        06.04.2006 dpuchkov - перекомпиляция
        17.11.09 marinav v-pnp as cha format "x(20)"
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        03.09.2012 evseev - иин/бин
*/

{mainhead.i OUTRMZ}
{chk12_innbin.i}
def new shared var v-ref as cha format "x(10)".
def new shared var v-pnp as cha format "x(20)" .
def new shared var v-reg5 as cha .
def new shared var v-bin5 as cha .
def new shared var pakal as cha .
def new shared var v-chg  as int .
def new shared var remtrz like remtrz.remtrz.
def new shared var v-option as cha .

def buffer tgl for gl.

def var acode like crc.code no-undo.
def var bcode like crc.code no-undo.
def var t-pay like remtrz.amt no-undo.

def var ourbank like bankl.bank no-undo.
def var  v-priory as  cha no-undo.
def var s-cif as char no-undo.
def var s-rnn as char no-undo.

{lgps.i "new"}
m_pid = "O" .
u_pid = "out_O_ps" .
v-option = "remsubo".
find last sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Запись OURBNK отсутствует в файле sysc  !!".
   pause .
     undo .
    return .
   end.
 ourbank = sysc.chval.


{main_ps.i
 &head = remtrz
 &headkey = remtrz
 &framename = remtrz
 &option = REMTRZ
 &formname = psror-2
 &findcon = true
 &addcon = true
 &numprg = "n-remtrz"
 &keytype = string
 &nmbrcode = remtrz
 &subprg = s-rotrz
 &clearframe = " "
 &viewframe = " "
 &postfind = "{posfnd.i}"
 &preadd = " "
 &postadd = " remtrz.rwho   = g-ofc .
              remtrz.source = m_pid .
              remtrz.sbank  = ourbank.
              remtrz.scbank = ourbank.
              remtrz.rtim = time.
              run psroup-2 . s-newrec = false .
 if keyfunction(lastkey) = ""end-error""
   then do :
   delete remtrz .
   return .
  end . "
 &end = " "
}
