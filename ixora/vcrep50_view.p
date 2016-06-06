/* vcrep50_view.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Отчет по физ. лицам для НБ РК
 * RUN

 * CALLER
        vcrepp50.p
 * SCRIPT

 * INHERIT

 * MENU
        10.4.1.10
 * AUTHOR
        13.12.2010 aigul - на основе vcrep50
 * BASES
        BANK
 * CHANGES

*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank as char.
def input parameter p-depart as integer.

def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date format "99/99/9999".
def new shared var v-dte as date format "99/99/9999".
def new shared var v-pay as integer init 1.
def var v-name as char no-undo.

def new shared var v-amtusd as deci.
def new shared var v-sum as deci.

def new shared var v-sum1 as deci.

def new shared var v-rnn    as char.
def new shared var v-fio    as char.
def new shared var v-bank   as char.
def var i as integer.
/*def var v-depname as char no-undo.*/
/*def var v-ncrccod like ncrc.code.*/

def new shared temp-table rmztmp
    field rmz       as char
    field rmztmp_aaa       as char
    field rmztmp_cif       as char
    field rmztmp_fio       as char
    field rmztmp_rez1      as char
    field rmztmp_rnn       as char
    field rmztmp_tranz     as char
    field rmztmp_tranzK    as char
    field rmztmp_knp       as char
    field rmztmp_knpK       as char /*КНП*/
    field rmztmp_dt        as date
    field rmztmp_bc        as char /*ї банковского счета*/
    field rmztmp_st        as char /*страна получения/отправления*/
    field rmztmp_stch      as char
    field rmztmp_stK       as char /*код страны получения/отправления*/
    field rmztmp_rez2      as char
    field rmztmp_sec       as char
    field rmztmp_secK      as char /*код сектор экономики*/
    field rmztmp_bn        as char /*наименование отправителя/получателя 28.02.2006*/
    field rmztmp_crc       like ncrc.code       /*валюта*/
    field rmztmp_crcK      like ncrc.stn   /*код валюты*/
    field rmztmp_camt      as deci
    field rmztmp_uamt      as deci
    field rmztmp_bin       as char
    field rmztmp_bank       as char.

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

 form
   skip
   " ПЕРИОД ОТЧЕТА: " skip
   v-month label "     Месяц " skip
   v-god label   "       Год " skip
   " ТИП ПЛАТЕЖА: " skip
   v-pay label "1)Исходящие 2)Входящие " format "9"
   validate(index("12", v-pay) > 0, "Неверный тип платежа !") skip
   with side-label centered row 5 title " ВВЕДИТЕ ПАРАМЕТРЫ ОТЧЕТА : " frame fparam.

update v-month v-god v-pay with frame fparam.

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then i = 31.
  when 4 or when 6 or when 9 or when 11 then i = 30.
  when 2 then do:
    if v-god mod 4 = 0 then i = 29.
    else i = 28.
  end.
end case.

v-dte = date(v-month, i, v-god).

v-name = "".



{r-brfilial.i &proc = "vcrep50dat_view"}
run vcrep50out ("vcrep50.htm", (p-bank <> "all"), v-name, /*(p-depart <> 0), v-depname,*/ true).
pause 0.