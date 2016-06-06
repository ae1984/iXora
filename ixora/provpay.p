/* provpay.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        27/01/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}


def temp-table wrk no-undo
  field ap_code as int
  field ap_type as int
  field sp_name as char
  field pay_summ as deci
  field pay_count as int.

procedure setKritVal.
    def input parameter ap-code as int no-undo.
    def input parameter ap-type as integer no-undo.
    def input parameter ap-count as int no-undo.

    find first wrk where wrk.ap_code = ap-code and wrk.ap_type = ap-type no-lock no-error.
    if not avail wrk then do:
      find first comm.suppcom where comm.suppcom.ap_code = ap-code and comm.suppcom.ap_type = ap-type no-lock.

      create wrk.
      assign wrk.ap_code = ap-code
             wrk.ap_type = ap-type
             wrk.pay_summ = comm.suppcom.supcod
             wrk.sp_name = comm.suppcom.name.
    end.
    wrk.pay_count = wrk.pay_count  + ap-count.
end procedure.

def var dt1 as date no-undo.
def var dt2 as date no-undo.

dt2 = g-today.
dt1 = dt2.

def frame dat dt1 label " С " format "99/99/9999" validate( dt1 <= g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate( dt2 >= dt1, "Некорректная дата!") skip
with side-label centered row 15 title "Параметры отбора" VIEW-AS DIALOG-BOX.

displ dt1 dt2 with frame dat.

/*
ON END-ERROR OF dt1 , dt2 in frame dat
do:
  leave.
end.
*/
update dt1 with frame dat.
update dt2 with frame dat.



def stream rep.
output stream rep to value("rpt_aplat.htm").

 put stream rep "<html><head><title>Платежи Авангард-Plat</title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
put stream rep unformatted "<tr>" skip.
       put stream rep unformatted "<td> Комисия провайдерам C " string(dt1,"99/99/9999") " По " string(dt2,"99/99/9999") "</td>" skip.
       put stream rep unformatted "</tr>" skip.



for each comm.compaydoc where comm.compaydoc.whn_cr >= dt1 and comm.compaydoc.whn_cr <= dt2 and comm.compaydoc.state = 2 no-lock:
  find first comm.suppcom where comm.suppcom.supp_id = comm.compaydoc.supp_id no-lock.
  if avail comm.suppcom and comm.suppcom.supcod > 0 then
  do:
    run setKritVal (comm.suppcom.ap_code,comm.suppcom.ap_type,1).
  end.
end.


put stream rep unformatted
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td width=60> № </td>" skip
            "<td width=200> Провайдер </td>" skip
            "<td width=100> Кол-во </td>" skip
            "<td width=100> Сумма </td>" skip.
put stream rep unformatted "</tr>" skip.

def var iCount as int init 1.
def var iAllCount as int init 0.
def var dSumm as deci.
 for each wrk  no-lock by  wrk.sp_name:
            put stream rep unformatted "<tr>" skip.
                      put stream rep unformatted "<td>" iCount "</td>" skip.
                      put stream rep unformatted "<td>" wrk.sp_name "</td>" skip.
                      put stream rep unformatted "<td>" string(wrk.pay_count) "</td>" skip.
                      put stream rep unformatted "<td>" string(wrk.pay_count * wrk.pay_summ ,">>>,>>>,>>>,>>>.99") "</td>" skip.
                      put stream rep unformatted "</tr>" skip.
     iCount = iCount + 1.
     dSumm = dSumm + ( wrk.pay_count * wrk.pay_summ ).
     iAllCount = iAllCount + wrk.pay_count.
 end.

 put stream rep unformatted "<tr>" skip.
                      put stream rep unformatted "<td> </td>" skip.
                      put stream rep unformatted "<td> Итого:</td>" skip.
                      put stream rep unformatted "<td>" string(iAllCount) "</td>" skip.
                      put stream rep unformatted "<td>" string(dSumm ,">>>,>>>,>>>,>>>.99") "</td>" skip.
                      put stream rep unformatted "</tr>" skip.

put stream rep unformatted "</table></body></html>" skip.
output stream rep close.
unix silent value("cptwin rpt_aplat.htm excel").


