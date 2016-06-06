/* vov_rep.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        отчет по принятым платежам без открытия счетс с льготной комиссией
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
        меню
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        09/03/2006 u00568 Evgeniy
 * CHANGES
        17/03/2006 u00568 Evgeniy оптимизация по скорости.
                   исправление багов.
                   добавил пенсионные платежи
        27/03/2006 u00568 Evgeniy - прочие платежи номера ветеранов хранят в commonpl.info[5].
        04/05/2006 u00568 Evgeniy - добавил несколько условий по тз328 от 03/05/2006
        04/05/2006 u00568 Evgeniy - переделал интерфейс, исправил ошибки.
        16/05/2006 u00568 Evgeniy - оптимизация по скорости и испраление ошибки
        19/05/2006 u00568 Evgeniy - поправил интерфейс, добавил время работы отчета
        29/06/2006 u00568 Evgeniy - удалил comm.taxnk.txb - всвязи с добавлением индекса, и вообще непонятно зачем это поле в таблице налоговых комитетов
        08/08/2006 u00568 Evgeniy - оптимизация по заданию центра.
                                    результат - то что раньше отрабатывало за 21 сек теперь работает 16 сек
*/


{comm-txb.i}
{getfromrnn.i}

def var seltxb as int no-undo.
seltxb = comm-cod().
def stream st1.

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var temp_str as char no-undo.

def shared var g-today as date.
def var commonpl_grp like commonpl.grp init ? no-undo.
def var tax_rnn_nk like tax.rnn_nk init ? no-undo.
def var v-vov-name as char no-undo.
define buffer btax for tax.


def var combo_speed as char format "x(20)" view-as combo-box LIST-ITEMS "Коротко","Развернуто" no-undo. /*COMBO-BOX для выбора скорости*/
def var speedy as logical init false no-undo.
def var combo_vov as char format "x(20)" view-as combo-box LIST-ITEMS "ВСЕ","ВОВ","не ВОВ" no-undo. /*COMBO-BOX для выбора ВОВ*/
def var onlyvov as logical init false no-undo.
def var vovandall as logical init false no-undo.
def var combo_taxcom as char format "x(20)" view-as combo-box LIST-ITEMS "все платежи","только налоги" no-undo. /*COMBO-BOX для выбора ВОВ*/
def var onlytax as logical init false no-undo.
def var btime as int no-undo.

DEFINE BUTTON btn_go LABEL "Начать".

/* по логину определяет ФИО*/
FUNCTION getnameofr RETURNS char (arg1 as character).
 if not speedy then do:
   find first ofc where ofc.ofc = arg1 no-lock no-error.
   if avail ofc then
     RETURN (ofc.name).
   else
     RETURN ('не найден').
 end.
 else
   RETURN ('есть только логин ').
END FUNCTION.

def frame sf
  skip(1)
  dt1 format '99/99/9999' label "От Даты    " skip
  dt2 format '99/99/9999' label "До Даты    " skip
  combo_speed             label "Тип        " skip
  combo_taxcom            label "НК         " skip
  combo_vov               label "BOB/не ВОВ " skip
  skip(2)
  "          " btn_go
with side-labels row 1 column 2  title "Условия"  centered.

on return of combo_speed
do:
 apply "tab" to combo_speed.
end.

on return of combo_vov
do:
 apply "tab" to combo_vov.
end.

on return of combo_taxcom
do:
 apply "tab" to combo_taxcom.
end.

ON CHOOSE OF btn_go IN FRAME sf
do:
 apply "go" to frame sf.
end.

/*main ----------------------------------------------------*/

dt1 = g-today.
dt2 = g-today.
enable btn_go WITH frame sf.
display
 combo_speed
 combo_taxcom
 combo_vov
WITH FRAME sf.
update
 dt1
 dt2
 combo_speed
 combo_taxcom
 combo_vov
with frame sf.

btime = time.

combo_speed = combo_speed:SCREEN-VALUE.
combo_vov = combo_vov:SCREEN-VALUE.
combo_taxcom = combo_taxcom:SCREEN-VALUE.

speedy = combo_speed  = 'Коротко'.
vovandall = combo_vov = 'ВСЕ'.
onlyvov = combo_vov = 'ВОВ'.
onlytax = combo_taxcom = 'только налоги'.

/*
displ speedy vovandall onlyvov onlytax.
displ combo_speed combo_vov combo_vov combo_taxcom.
*/

/* формируется отчет ---------------------------------------------------------------------------*/



output stream st1 to vov_rep.img.

{html-title.i 
 &stream = " stream st1 "
 &title = " "
 &size-add = "x-"
}

put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Реестр льготных платежей <br> за период с " string(dt1, "99/99/9999") " по " string(dt2, "99/99/9999")skip.

put stream st1 unformatted   "<P align=""center"" style=""font:bold""> Установки " combo_speed " Платежи " combo_vov ", По реестрам " combo_taxcom skip.

put stream st1 unformatted
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>Номер <br> Квитанции</TD>" skip
      "<TD>Дата <br> опер. <br> дня</TD>" skip
      "<TD>Дата <br> принятия <br> платежа</TD>" skip
      "<TD>РНН <br> плательщика</TD>" skip
      "<TD>ФИО <br> плательщика </TD>" skip
      "<TD>Документы <br> основание <br> для льгот </TD>" skip
      "<TD>Сумма <br> платежа </TD>" skip
      "<TD>Комиссия <br> Банка </TD>" skip
      "<TD>Код <br> Комиссии </TD>" skip
      "<TD>Логин <br> Кассира </TD>" skip
      "<TD>Группа <br> платежей </TD>" skip
      "<TD>РНН <br>Бенефициара </TD>" skip
      "<TD>Название <br>Бенефициара</TD>" skip
      "<TD>ФИО кассира</TD>" skip
      /*"<TD>комиссия <br> есть/нет </TD>" skip*/
  "</TR>" skip.

if not onlytax then

for each commonpl where
         dt1 <= commonpl.date and
         commonpl.date <= dt2 and
         /*commonpl.deluid = ? and*/
         commonpl.comsum < 2 and
         seltxb = commonpl.txb and
         not(commonpl.dnum = 0 and commonpl.sum = 0) and
         commonpl.grp <> 11 and
         (vovandall or (onlyvov = (commonpl.comcode = '24')))
         /*and (commonpl.comcode = '24' or commonpl.comcode = ?)*/
         no-lock break by commonpl.grp:
  if   commonpl.deluid = ? /*and
           commonpl.comsum < 2 and
           seltxb = commonpl.txb and
           not(commonpl.dnum = 0 and commonpl.sum = 0) and
           commonpl.grp <> 11 and*/
           /*(vovandall or (onlyvov = (commonpl.comcode = '24')))*/
           /*and (commonpl.comcode = '24' or commonpl.comcode = ?)*/
  then
  do:
    if first-of (commonpl.grp) /*commonpl_grp <> commonpl.grp*/ then do:
      commonpl_grp = commonpl.grp.
      case commonpl.grp:
        WHEN 1 then temp_str = 'Станции диагностики и отделы миграции'.
        WHEN 2 then temp_str = 'Астанаэнергосервис'.
        WHEN 3 then
          do:
            if seltxb = 1 then temp_str = 'АстанаэнергоСбыт'.
              else temp_str = 'Казахтелеком,Астанателеком'.
          end.
        WHEN 4 then temp_str = 'Платежи K''Cell и K-Mobile'.
        WHEN 5 then temp_str = 'Услуги ИВЦ'.
        WHEN 6 then temp_str = 'Услуги Алсеко'.
        WHEN 7 then temp_str = 'Услуги Водоканала'.
        WHEN 8 then temp_str = 'Услуги АПК'.
        WHEN 9 then temp_str = 'Прочие платежи организаций'.
        WHEN 10 then
          if seltxb = 1 then temp_str = 'Казахтелеком,Астанателеком'.
          else temp_str = 'Погашения Недостач ' + string(commonpl.grp).
        WHEN 11 then temp_str = 'Выдачи в подотчет для обменных операций (KZT)'.
        WHEN 13 then temp_str = 'Коммунальные платежи'.
        WHEN 15 then temp_str = 'Социальные отчисления'.
        WHEN 16 then temp_str = 'Выдачи наличных через POS'.
        OTHERWISE temp_str = 'Неизвестный платеж ' + string(commonpl.grp) .
      end case.
      /*put stream st1 unformatted
        "<TR><TD colspan = ""6""><b> Группа платежей: " temp_str  "</TD></tr>" skip.*/
    end.

    v-vov-name = commonpl.info[3].
    if commonpl.grp = 15 then v-vov-name = commonpl.info[2].
    if commonpl.grp = 9 then v-vov-name = commonpl.info[5].

    put stream st1 unformatted
     "<TR><TD> " commonpl.dnum    " </TD>" skip
       "<TD> " commonpl.date      format '99/99/9999'      " </TD>" skip
       "<TD> " commonpl.credate   format '99/99/9999'      " </TD>" skip
       "<TD> [" commonpl.rnn      "]</TD>" skip
       "<TD> " if not speedy then getfio1(commonpl.rnn) else "есть только РНН"  "</TD>" skip
       "<TD> " v-vov-name   "</TD>" skip
       "<TD> " commonpl.sum       "</TD>" skip
       "<TD> " commonpl.comsum    "</TD>" skip
       "<TD> " commonpl.comcode   "</TD>" skip
       "<TD> " commonpl.uid       "</TD>" skip
       "<TD> " temp_str           "</TD>" skip
       "<TD> [" commonpl.rnnbn    "]</TD>" skip
       "<TD> " if not speedy then getfio1(commonpl.rnnbn) else "есть только РНН"    "</TD>" skip
       "<TD> " getnameofr(commonpl.uid) "</TD>" skip
       /*"<TD> " commonpl.com       "</TD>" skip*/
     "</TR>" skip.
  end.
end.
/*
put stream st1 unformatted
    "<TR><TD><b></TD><TD><b></TD><TD></TD>"
        "<TD><b> >>>>>>>>>>></b></TD><TD></TD><TD></TD>" skip
    "</TR>" skip.

*/
/*put stream st1 unformatted "</TABLE>" skip.*/
/*
{html-end.i " stream st1 "}

output stream st1 close.

unix silent cptwin vov_rep.img excel.


*/
/*almatv---------------------------------------------------------------------------*/
/*
output stream st1 to vov_rep1.img.

{html-title.i
 &stream = " stream st1 "
 &title = " "
 &size-add = "x-"
}
*/
/*
put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Реестр льготных платежей АлмаТиВи <br> за период с " string(dt1, "99/99/9999") " по " string(dt2, "99/99/9999")skip.

put stream st1 unformatted
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>Номер <br> Квитанции</TD>" skip
      "<TD>Дата <br> принятия <br> платежа</TD>" skip
      "<TD>РНН <br> плательщика</TD>" skip
      "<TD>ФИО <br> плательщика </TD>" skip
      "<TD>Документы <br> основание <br> для льгот </TD>" skip
      "<TD>Сумма <br> платежа </TD>" skip
      "<TD>Комиссия <br> Банка </TD>" skip
      "<TD>Код <br> Комиссии </TD>" skip
      "<TD>Логин <br> Кассира </TD>" skip
      "<TD>Группа <br> платежей </TD>" skip
  "</TR>" skip.
*/
if not onlytax then
for each almatv where
         dt1 <= almatv.Dtfk and
         almatv.Dtfk <= dt2 and
         seltxb = almatv.txb
         and
         almatv.deluid = ? and
         almatv.cursfk < 2 and
         (vovandall or (onlyvov = (almatv.chval[2] = '24')))
         no-lock:

  /*if almatv.deluid = ? and
         almatv.cursfk < 2 and
         (vovandall or (onlyvov = (almatv.chval[2] = '24')))
       then*/
  do:

    put stream st1 unformatted
     "<TR><TD> " almatv.Ndoc    " </TD>" skip
       "<TD> " almatv.Dtfk format '99/99/9999'      " </TD>" skip
       "<TD> нет </TD>" skip
       "<TD> " 'нет'       "</TD>" skip
       "<TD> " almatv.f ' ' almatv.io "</TD>" skip
       "<TD> " almatv.chval[4]   "</TD>" skip
       "<TD> " almatv.Summfk       "</TD>" skip
       "<TD> " almatv.cursfk    "</TD>" skip
       "<TD> " almatv.chval[2]   "</TD>" skip
       "<TD> " almatv.uid       "</TD>" skip
       "<TD>  АлмаТиВи       </TD>" skip
       "<TD> "      "</TD>" skip
       "<TD> "      "</TD>" skip
       "<TD> " getnameofr(almatv.uid) "</TD>" skip
     "</TR>" skip.
  end.
end.
/*
put stream st1 unformatted
    "<TR><TD><b></TD><TD><b></TD><TD></TD>"
        "<TD><b> >>>>>>>>>>></b></TD><TD></TD><TD></TD>" skip
    "</TR>" skip.
*/
/*
put stream st1 unformatted "</TABLE>" skip.
*/
/*
{html-end.i " stream st1 "}

output stream st1 close.

unix silent cptwin vov_rep1.img excel.

*/

/*tax---------------------------------------------------------------------------*/
/*
output stream st1 to vov_rep2.img.

{html-title.i
 &stream = " stream st1 "
 &title = " "
 &size-add = "x-"
}
*/
/*
put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Реестр льготных НАЛОГОВЫХ платежей <br> за период с " string(dt1, "99/99/9999") " по " string(dt2, "99/99/9999")skip.

put stream st1 unformatted
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>Номер <br> Квитанции</TD>" skip
      "<TD>Дата <br> принятия <br> платежа</TD>" skip
      "<TD>РНН <br> плательщика</TD>" skip
      "<TD>ФИО <br> плательщика </TD>" skip
      "<TD>Документы <br> основание <br> для льгот </TD>" skip
      "<TD>Сумма <br> платежа </TD>" skip
      "<TD>Комиссия <br> Банка </TD>" skip
      "<TD>Код <br> Комиссии </TD>" skip
      "<TD>Логин <br> Кассира </TD>" skip
  "</TR>" skip.
 */
for each tax where
         dt1 <= tax.date and
         tax.date <= dt2 and
         tax.duid = ? and
         tax.comsum < 2 and
         seltxb = tax.txb and
         (vovandall or (onlyvov = (tax.comcode = '24')))
         no-lock break by tax.rnn_nk:
  /*if  tax.comsum < 2 and
     (vovandall or (onlyvov = (tax.comcode = '24')))
  then*/
  do:
    if not can-find( first btax where btax.uid = tax.uid and btax.cdate = tax.cdate and tax.duid = ? and seltxb = btax.txb and btax.date = tax.date and btax.dnum = tax.dnum and btax.comsum <> 0 no-lock) then do:
      if not speedy then do:
        if tax_rnn_nk <> tax.rnn_nk then do:
          release comm.taxnk.
          find first comm.taxnk where comm.taxnk.rnn = tax.rnn_nk no-lock no-error.
        end.
      end.
      put stream st1 unformatted
       "<TR><TD> " tax.dnum    " </TD>" skip
         "<TD> " tax.date format '99/99/9999'      " </TD>" skip
         "<TD> " tax.cdate format '99/99/9999'      " </TD>" skip
         "<TD> [" tax.rnn       "]</TD>" skip
         "<TD> " if not speedy then getfio1(tax.rnn) else "есть только РНН"  "</TD>" skip
         "<TD> " tax.chval[2]   "</TD>" skip
         "<TD> " tax.sum       "</TD>" skip
         "<TD> " tax.comsum    "</TD>" skip
         "<TD> " tax.comcode   "</TD>" skip
         "<TD> " tax.uid       "</TD>" skip
         "<TD> налоговые платежи </TD>" skip
         "<TD> [" tax.rnn_nk "] </TD>" skip
         "<TD> " if avail comm.taxnk then comm.taxnk.name else "" " </TD>" skip
         "<TD> " getnameofr(tax.uid) "</TD>" skip

       "</TR>" skip.
    end.
  end.
end.
/*
put stream st1 unformatted
    "<TR><TD><b></TD><TD><b></TD><TD></TD>"
        "<TD><b> >>>>>>>>>>></b></TD><TD></TD><TD></TD>" skip
    "</TR>" skip.
*/
/*put stream st1 unformatted "</TABLE>" skip.
*/
/*p_f_payment---------------------------------------------------------------------------*/
/*
put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Реестр льготных ПЕНСИОННЫХ платежей <br> за период с " string(dt1, "99/99/9999") " по " string(dt2, "99/99/9999")skip.

put stream st1 unformatted
  "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
    "<TR align=""center"" style=""font:bold"">" skip
      "<TD>Номер <br> Квитанции</TD>" skip
      "<TD>Дата <br> принятия <br> платежа</TD>" skip
      "<TD>РНН <br> плательщика</TD>" skip
      "<TD>ФИО <br> плательщика </TD>" skip
      "<TD>Удостоверение Инсп. НК <br> и номер акта.   </TD>" skip
      "<TD>Сумма <br> платежа </TD>" skip
      "<TD>Комиссия <br> Банка </TD>" skip
      "<TD>Код <br> Комиссии </TD>" skip
      "<TD>Логин <br> Кассира </TD>" skip
  "</TR>" skip.
*/
if not onlytax then
for each p_f_payment where
         dt1 <= p_f_payment.date and
         p_f_payment.date <= dt2 and
         p_f_payment.deluid = ? and
         seltxb = p_f_payment.txb and
         p_f_payment.comiss < 2 and
         (vovandall or (onlyvov = (p_f_payment.diskont = '24')))
         no-lock:
  /*if p_f_payment.comiss < 2 and
     (vovandall or (onlyvov = (p_f_payment.diskont = '24')))
  then*/
  do:
      put stream st1 unformatted
       "<TR><TD> " p_f_payment.dnum    " </TD>" skip
         "<TD> " p_f_payment.date format '99/99/9999'      " </TD>" skip
         "<TD> нет  </TD>" skip
         "<TD> [" p_f_payment.rnn       "]</TD>" skip
         "<TD> " p_f_payment.name "</TD>" skip
         "<TD> ИНСП:" p_f_payment.inspektor_NK '. Ном. акта:' p_f_payment.act_withdrawal   "</TD>" skip
         "<TD> " p_f_payment.amt       "</TD>" skip
         "<TD> " p_f_payment.comiss    "</TD>" skip
         "<TD> " p_f_payment.diskont   "</TD>" skip
         "<TD> " p_f_payment.uid       "</TD>" skip
         "<TD> ПЕНСИОННЫЕ платежи </TD>" skip
         "<TD> [" p_f_payment.distr     "]</TD>" skip
         "<TD> " if not speedy then getfio1(p_f_payment.distr) else "есть только РНН"  "</TD>" skip
         "<TD> " getnameofr(p_f_payment.uid) "</TD>" skip
       "</TR>" skip.
  end.
end.
/*
put stream st1 unformatted
    "<TR><TD><b></TD><TD><b></TD><TD></TD>"
        "<TD><b> >>>>>>>>>>></b></TD><TD></TD><TD></TD>" skip
    "</TR>" skip.
*/

/*message "время работы отчета ~n" + string(time - btime) view-as alert-box title "!!!".*/
displ ("время работы") format "x(15)" skip.
displ ("отчета " + string(time - btime) + ' сек.') format "x(15)" skip.

/*--------------------------------------------------------------*/
put stream st1 unformatted "</TABLE>" skip.

{html-end.i " stream st1 "}

output stream st1 close.

/*unix silent cptwin vov_rep2.img excel.*/
unix silent cptwin vov_rep.img excel.
