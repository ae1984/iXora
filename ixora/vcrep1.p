/* vcrep1.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 1 - отчет о платежах по контрактам, где нет рег/свид-ва
 * RUN

 * CALLER
        vcrepa1.p, vcrepp1.p, vcrepk1.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM
 * AUTHOR
        28.04.2008 galina
 * CHANGES
        02/11/2009 galina - изменения по суммам согласно ТЗ 577 от 29/10/2009
        добавила БИН
        02/11/2010 galina - добавила коды новые операции 16 и 17
        добавила столбцы э/и и тип контракта
        26.01.2011 aigul  - сделала отчет консолид.
        24.07.2012 damir  - добавил v-txbbank,input parameter передаваемый в vcrep1out.p.

 */

{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank   as char.
def input parameter p-depart as integer.

def new shared var s-vcourbank  as char.
def new shared var v-god        as integer format "9999".
def new shared var v-month      as integer format "99".
def new shared var v-dtb        as date.
def new shared var v-dte        as date.

def var v-name      as char no-undo.
def var v-depname   as char no-undo.
def var v-ncrccod   like ncrc.code no-undo.
def var v-sum       like vcdocs.sum no-undo.
def var vi          as integer no-undo.
def var v-txbbank   as char.
def var v-reptype   as integer init 1 no-undo.

def new shared temp-table t-docs
  field dndate like vcdocs.dndate
  field docs like vcdocs.docs
  field opertype as char
  field sum like vcdocs.sum
  field name like cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as char
  field rnn as char format "999999999999"
  field secek as char
  field country as char
  field rnnben as char format "999999999999"
  field secekben as char
  field countryben as char
  field strsum as char
  field locat as char
  field locatben as char
  field note as char
  field bin as char
  field expimp as char
  field cttype as char

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

message "  Формируется отчет...".

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

{r-brfilial.i &proc = " vcrep1dat(input txb.bank, p-depart)"}

if p-bank <> "all" then v-name = txb.name.
hide message no-pause.

if avail comm.txb then v-txbbank = comm.txb.bank.
else v-txbbank = "".

if p-bank = "all" then do:
    DEF BUTTON but-htm LABEL "    Просмотр отчета    ".
    DEF BUTTON but-msg LABEL "  Файл для статистики  ".

    def frame butframe
    skip(1)
    but-htm skip
    but-msg skip(1)
    with centered row 6 title "ВЫБЕРИТЕ ВАРИАНТ ОТЧЕТА:".

    ON CHOOSE OF but-htm, but-msg do:
        case self:label :
            when "Просмотр отчета" then v-reptype = 1.
            when "Файл для статистики" then v-reptype = 2.
        end case.
    END.
    enable all with frame butframe.

    WAIT-FOR CHOOSE OF but-htm, but-msg.
    hide frame butframe no-pause.
end.

if v-reptype = 1 then
    run vcrep1out.p ("vcrep1.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true,v-txbbank).
else
    run vcrep1out.p ("vcrep1.htm", false, "", false, "", false,v-txbbank).

pause 0.


