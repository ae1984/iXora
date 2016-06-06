/* vcrepthird.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок  для конракта типа 9
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        28.05.2008 galina
 * CHANGES
        26.01.2011 aigul - сделала отчет консолид
        16.07.2012 damir - добавил input parameter v-txbbank; bin,iin,binben,iinben в temp-table.

 */


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank as char.
def input parameter p-depart as integer.

def new shared var s-vcourbank as char.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.

def var v-name      as char no-undo.
def var v-depname   as char no-undo.
def var v-ncrccod   like ncrc.code no-undo.
def var v-sum       like vcdocs.sum no-undo.
def var vi          as integer no-undo.
def var v-txbbank   as char.

def new shared temp-table t-docs
  field psdate      as date
  field psnum       as char
  field name        like cif.name
  field okpo        as char format "999999999999"
  field rnn         as char format "999999999999"
  field clntype     as char
  field country     as char
  field region      as char
  field locat       as char
  field partner     like vcpartners.name
  field rnnben      as char format "999999999999"
  field okpoben     as char format "999999999999"
  field typeben     as char
  field countryben  as char
  field regionben   as char
  field locatben    as char
  field dnnum       as char
  field dndate      like vcdocs.dndate
  field docs        like vcdocs.docs
  field sum         like vcdocs.sum
  field strsum      as char
  field codval      as char
  field ctformrs    as char
  field inout       as char
  field note        as char
  field bin         as char
  field iin         as char
  field binben      as char
  field iinben      as char
  index main is primary dndate sum docs.

s-vcourbank = comm-txb().

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

update skip(1)
   v-month label "     Месяц " skip
   v-god label   "       Год " skip(1)
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

/*if p-option = 'rep' then**/ message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).


if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
  p-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = p-depart no-lock no-error.
  v-depname = ppoint.name.
end.
v-name = "".

{r-brfilial.i &proc = " vcrepthirddat(input txb.bank, p-depart)"}

if p-bank <> "all" then v-name = txb.name.
hide message no-pause.

def var v-reptype as integer init 1 no-undo.

if avail comm.txb then v-txbbank = comm.txb.bank.
else v-txbbank = "".

/*if v-reptype = 1 then*/
    run vcrepthirdout ("vcrep4.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true,v-txbbank).
/*else
    run vcrepthirdout ("vcrep4.htm", false, "", false, "", false,v-txbbank).*/

pause 0.
