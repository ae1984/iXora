/* st_clif.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        общая процедура печати выписок по ЗАКРЫТЫМ счетам клиентов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-4-х
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
        16.03.2012 damir - добавил переменные hronol, dksum.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/


{mainhead.i}


define new shared variable s-cif like cif.cif.

define variable df as date label "C ".
define variable dt as date label "По ".
define variable st as character format "x".

def new shared var hronol as logi label "в хронологическом порядке" format "да/нет" init no.
def new shared var dksum  as logi label "Дт/Кт, по суммам" format "да/нет" init no.

define variable df1 as date label "С ".
define variable dt1 as date label "По ".

define variable nane  as character.
define new shared variable stat-us as log init false. /* true - не пpошел пpовеpки */
define variable s-hacc like aaa.aaa initial ?.
define variable s-cacc like aaa.aaa initial ?.
define variable tmp_date as date.
define variable in_cif  like cif.cif.
define variable in_acc  like aaa.aaa initial ?.
define variable j_stmsts as character initial ?.
define variable pers as integer.
define variable labels        as character.

define variable s-label as character extent 3.
define variable o-label as character format "x(11)".

define variable cpy  as logical.
define variable org  as logical.

define variable iseq        as decimal.
define variable periods        as integer.

define variable start_date as date.
define variable end_date   as date.
define variable f_date           as date.
define variable t_date           as date.
define variable a_date           as date.
define variable first_date as date.
define variable in_account like aaa.aaa.
define variable ch_date   as date.     /* New Period Date */
define variable ch_period as integer.  /* New Period */

define buffer b-st for stgenhi.
define buffer a_hi for stgenhi.

define variable clo          as logical initial false.
define variable clo_date as date.

def var v-cifname as char format "x(40)".



s-label[1] = "ОРИГИНАЛ".
s-label[2] = "ДУБЛИКАТ".
s-label[3] = "СПРАВКА".

o-label = s-label[3].
st = "I" .

{st_chkcif.i}

form
        s-cif  label    "  Код"
          help " Код клиента (F2 - поиск по счету, наименованию и т.д)"
          validate (chkcif (s-cif), v-msgerr)
          skip
        v-cifname label "  Имя" skip
        s-hacc   label  " Счет"
          help " Номер текущего счета клиента (F2 - список счетов)"
          validate (can-find (aaa where aaa.aaa = s-hacc and aaa.cif = s-cif no-lock), " Счет не найден или принадлежит другому клиенту!")
with side-label row 3 frame cif.


form
    o-label format "x(11)"
with no-label no-box at row 3 column 60 frame t.

form
        df
        dt
        st label " Статус"
with side-label row 8 overlay frame opt.

{stnextp_c.i}

if keyfunction(lastkey) <> "end-error" then do:

{header-t.i "new shared" }
{wkdef.i    "new shared" }
{stlist.i   "new shared" }

end.

/* --------------------------------------------------------------------------------- */

do transaction:

/* ===== Transaction for data request ===== */

   update s-cif with frame cif.

   find cif where cif.cif = s-cif no-lock no-error.

   display trim(trim(cif.prefix) + " " + trim(cif.name)) @ v-cifname with frame cif.
   pause 0.

   in_cif = s-cif.

   update s-cacc with frame cif.
   in_account = s-cacc.

   run r-vichk.
   if stat-us then return.

end. /* ... transaction ... */

/* --- Checking Section --- */

if mode = "ac" then do: /* === Account Mode === */

s-hacc = s-cacc.

find first aaa where aaa.aaa = s-hacc no-lock no-error.

if aaa.sta = "C" then do:
   clo = yes.
   clo_date = aaa.whn.
end.

{stmclist.i}

if df = ? or dt = ? then do:
        df = date(month(g-today),day(g-today),year(g-today)) - 1.
        dt = date(month(g-today),day(g-today),year(g-today)) - 1.
        j_stmsts = "INF".
end.

df1 = df.
dt1 = dt.

st  = substring(j_stmsts,1,1).

display
        df
        dt
        st
with frame opt.

case st:
    when "O" then o-label = s-label[1].
    when "C" then o-label = s-label[2].
    when "I" then o-label = s-label[3].
end.

if o-label <> "" then display o-label with frame t.

/* ===================================================================== */
/* ===================================================================== */

repeat:

update df with frame opt.

if df1 <> df then do:
   hide frame t.
   st = "I".
   o-label = s-label[3].
   display o-label with frame t.
   display st with frame opt.
end.

update dt with frame opt.

if dt1 <> dt and periods <> 0  then do:
   hide frame t.
   st = "I".
   o-label = s-label[3].
   display o-label with frame t.
   display st with frame opt.
end.

if df1 = df and ( ( periods = 0 ) or ( periods <> 0 and dt1 = dt ) ) then do:  /* -- Manual Status Change MODE -- */

 display "<И> - Tолько справка " at row 1 column 2 with no-label at row 15 column 2 frame ttt2.

  repeat:
   update st with frame opt.
   st = caps(st).
   if st = "И" then st = "I".


      if j_stmsts = "ORG" and st = "O" or
         j_stmsts = "ORG" and st = "I" or
         j_stmsts = "CPY" and st = "C" or
         j_stmsts = "CPY" and st = "I" or
         j_stmsts = "INF" then leave.

  end.

   if st = "O" then j_stmsts = "ORG".
   if st = "C" then j_stmsts = "CPY".
   if st = "I" then j_stmsts = "INF".
   if st = "A" then j_stmsts = "ALL".
end.
 else do:
   st = "I".
   j_stmsts = "INF".
 end.

display st with frame opt.

  case st:
    when "O" then o-label = s-label[1].
    when "C" then o-label = s-label[2].
    when "I" then o-label = s-label[3].
  end.

  if o-label <> "" then display o-label with frame t.


display df dt with frame opt.

if dt >= df and df >= a_start  then leave.
if df < a_start then do:
   df = a_start.
   dt = df.
end.

end.  /* ---------------------------------------- */

if keyfunction(lastkey) = "end-error" then return.

in_acc = s-cacc.

hide frame q1.

end.

/* ===================================================================================== */

/* --- Execution Section --- */

run stgen(in_cif, in_acc, df, dt, in_format, out_file, out_com, j_stmsts).

if return-value = "1" then do:
  run elog("STGEN","ERR", "Statement Generation not completed. Terminated.").
  return "1".
end.

return.

