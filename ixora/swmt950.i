/* swmt950.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        формирование выписки по лоро счетам формата МТ950
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR

 * CHANGES
            18/04/2012 Luiza

*/


{mainhead.i}

define new shared variable s-cif like cif.cif.

define variable df as date label "C ".
define variable dt as date label "По ".
define variable st as character format "x".

def new shared var hronol as logi label "в хронологическом порядке" format "yes/no" init no.
def new shared var dksum  as logi label "Дт/Кт, по суммам" format "yes/no" init no.

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
        df label "За"
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





update df with frame opt.
df1 = df.
dt1 = df.
dt = df.
st = "I".
j_stmsts = "INF".

 o-label = s-label[3].


if keyfunction(lastkey) = "end-error" then return.

in_acc = s-hacc.

hide frame q1.


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


/* --- Execution Section --- */

run swmt950txt(in_cif, in_acc, df, dt, in_format, out_file, out_com, j_stmsts).
if return-value = "1" then do:
  run elog("STGEN","ERR", "Statement Generation not completed. Terminated.").
  return "1".
end.

return.


