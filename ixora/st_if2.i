/* st_if2.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        процедура печати выписок по ОТКРЫТЫМ счетам клиентов - с копией на C
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-4-5
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
        02.09.2004 dpuchkov - добавил ограничение доступа на просмотр выписок
        07.03.2012 damir - добавил переменные hronol, dksum.
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

def var v-cifname as char format "x(40)".

s-label[1] = "ОРИГИНАЛ".
s-label[2] = "ДУБЛИКАТ".
s-label[3] = "СПРАВКА".

o-label = s-label[3].
st = "I" .

form
    "Выберите номер выписки "  at row 1 column 1
    "и нажмите <Enter>      "  at row 2 column 1

with overlay no-label no-box at row 2 column 55 frame yy.


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
with no-label no-box at row 5 column 60 frame t.

form
        df
        dt
        st label " Статус"
with side-label row 8 overlay frame opt.


{stnextp.i}

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



  find last cifsec where cifsec.cif = cif.cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = cif.cif
          ciflog.sectime = time
          ciflog.menu = "Выписка по счету".
          return.
     end.
     else
     do:
        create ciflogu.
        assign
          ciflogu.ofc = g-ofc
          ciflogu.jdt = today
          ciflogu.cif = cif.cif
          ciflogu.sectime = time
          ciflogu.menu = "Выписка по счету".
     end.
  end.




   if mode <> "c" and mode <> "i" then do :
     update s-hacc with frame cif.
     in_account = s-hacc.
   end.

   run r-vichk.
   if stat-us then return.
end. /* ... transaction ... */

/* --- Checking Section --- */

if mode = "r" then do:

enable all with frame yy.

run orlist.

disable all with frame yy.
return.

end.

if mode = "rc" then do:

enable all with frame yy.
run orclist.
disable all with frame yy.
return.

end.

if mode = "h" then do:

run hlist.

return.

end.


if mode = "a" then do: /* === Account Mode === */

{stmlist.i}

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

in_acc = s-hacc.

hide frame q1.

end.

if mode = "i" then do: /* === Information By All Accounts */

st = "I".
o-label = s-label[3].
display o-label with frame t.

df = g-today - 1.
dt = g-today - 1.

display st with frame opt.
display df with frame opt.
display dt with frame opt.

repeat:
  update df with frame opt.
  update dt with frame opt.
  if df <= dt then leave.
end.

if keyfunction(lastkey) = "end-error" then return.

for each aaa where aaa.cif = in_cif and aaa.sta <> "C" no-lock:
 find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
 if lgr.led eq "ODA" then next.
    find stmset where stmset.cif = aaa.cif and stmset.aaa = aaa.aaa          exclusive-lock no-error.

    if available stmset then do:
       iseq = stmset.iseq.
       stmset.iseq = stmset.iseq + 1.
    end.

     create stml.
     stml.aaa = aaa.aaa.
     stml.seq = iseq.
     stml.d_from = df.
     stml.d_to   = dt.
     stml.sts    = "INF".
     stml.active = "*".
end.

end.

if mode ="c" then do: /* === CIF Mode === */

dt1 = g-today.         /* --- Synthetic g-today Changing --- */
dt = g-today - 1.

repeat:
update dt with side-label row 7 overlay frame c-opt.
if dt <= dt1 and dt >= a_start then leave.
dt = g-today - 1.
end.

g-today = dt + 1.

{ciflist.i}

g-today = dt1.        /* --- g-today restoring --- */

define variable krja as integer initial 0.
define variable krju as logical initial no.

for each stml.
    krja = krja + 1.
end.

if krja <> 0 then do:
   form
       "Доступно "                                 at row 1 column 1
        krja                        format ">>>>9"  at row 1 column 12
        "выписок по коду. Печатать :"          at row 1 column 20
        krju                        format "да/нет"        at row 1 column 50
   with no-label at row 7 column 20 frame afr.

   display krja with frame afr.
   update krju with frame afr.

   if krju = no  then return.

end.
else do:
  message "Нет доступных выписок".
  pause 10.
end.


end.

/* ===================================================================================== */

/* --- Execution Section --- */

run stgen2(in_cif, in_acc, df, dt, in_format, out_file, out_com, j_stmsts).
if return-value = "1" then do:
  run elog("STGEN","ERR", "Statement Generation not completed. Terminated.").
  return "1".
end.

return.


procedure hlist:
{hilist.i}
end.

procedure orlist:
{orlist.i}
end.

procedure orclist:
{orclist.i}
end.
