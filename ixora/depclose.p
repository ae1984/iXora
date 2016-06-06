/* depclose.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Оплата инкассовых распоряжений
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        При старте платежной системы.
 * AUTHOR
         dpuchkov
 * CHANGES
         02.05.2006 - dpuchkov поправил формирование платежей если закрытие выпадает на выходной день


*/
{global.i}
{comm-txb.i} 
{get-dep.i} 


def var ourcode as integer.
def var vparam2 as char.
def var rcode as inte.
def var rdes as char.
def var vdel as char initial "^".
def var v-jh like jh.jh.
def var d-SumOfPlat as decimal init 0.
def var d-tmpSum as decimal init 0.
def var op_kod AS CHAR format "x(1)".
def var v-usrglacc as char.
def new shared var s-rmzir as char.
def var d_sum as decimal.
def var s-vcourbank as char.
def var d_arsum as decimal decimals 2.
def var d_arsummy as decimal decimals 2.
def var v-opl as char.
def var v-ax1 as integer init 0.
  def buffer bv-aaa for aaa.
  def buffer bv-aas for aas.
def var v_sec as char.
def var r-cover as integer.


def var d_sumFirst as decimal.
def var d_sumNalog as decimal.


ourcode = comm-cod().
d_sum = 0.

def new shared var s_l_inkopl as logical.


/* проверка на оплату только 1 раз в  день */

find sysc where sysc.sysc= "DEPS" exclusive-lock no-error.
if avail sysc then do:
   if g-today = date(sysc.chval) then return.
   else
   sysc.chval = string(g-today).
end.


 for each urpayment /*where urpayment.jdt = g-today*/ exclusive-lock:

     if urpayment.sum <= 0 then next.
     if urpayment.rmz <> "" then next.

     find last aaa where aaa.aaa = urpayment.aaa no-lock no-error.
     find last cif where cif.cif = aaa.cif no-lock no-error.

     if time < 51300 then r-cover = 1. /* SCLEAR00 */
                     else r-cover = 2. /* SGROSS00 */

     find last urdpinfo where urdpinfo.aaa = aaa.aaa  no-lock no-error.
     if avail urdpinfo and urdpinfo.bnfname = "" then next.
     if avail urdpinfo and avail aaa then do:
        run deptax (1,                /* Номер документа  */
                    if g-today = aaa.expdt and aaa.sta = "M" then (urpayment.sum ) + aaa.opnamt  else urpayment.sum,     /* Сумма платежа    */
                    urpayment.aaa,    /* Счет отправителя */
                    string(urdpinfo.bnfbik, "999999999"),   /* Банк получателя */
                    string(urdpinfo.bnfiik, "999999999"),   /* Счет получателя */
                    "",               /* КБК */
                    false,            /* Тип бюджета - проверяется если есть КБК */
                    urdpinfo.bnfname, /* Бенефициар      */
                    urdpinfo.bnfjss,  /* РНН Бенефициара */
                    "",               /* KNP */
                    integer(substr(cif.geo,3,1) + v_sec), /* Kod */
                    /*integer(comm.taxnk.kod) */
                    11                /* integer(comm.taxnk.kbe)*/, /* Kbe */
                    "Перечисление процентов", /* Назначение платежа */
                    "DEP",            /* Код очереди */
                    "0",              /* Кол-во экз. */
                    r-cover,          /* remtrz.cover (для проверки даты валютированият.е. 1-CLEAR00 или 2-SGROSS00) */
                    cif.jss,          /* РНН отправителя */
                    cif.name).        /* s-fiozer        */
       if return-value <> "" then do:
          urpayment.rmz = return-value.
       end.
       else do:

       end.
     end.
 end.
















