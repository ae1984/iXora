/* cashrs.p
 * MODULE
        Касса
 * DESCRIPTION
        Статистика кассиров
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.5
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        19.09.2003 sasco   - поменял в условиях "cashofc.whn eq today" на cashofc.whn eq ddate"
        06.01.2003 nadejda - по заказу Фадеевой разрешила РКО видеть только своих кассиров, ЦО - всех
        23.08.2006 u00124  - оптимизация
        01.08.2011 lyubov - изменила алгоритм подсчета количества документов
*/


{mainhead.i}
{get-dep.i}

def var dest as char.

define variable ddate as date.
define variable dpap as integer initial 0.
define variable cpap as integer initial 0.
define variable dpapi as integer initial 0.
define variable cpapi as integer initial 0.
define variable damt like jl.dam initial 0.
define variable camt like jl.cam initial 0.
define variable damtt like jl.dam initial 0.
define variable camtt like jl.cam initial 0.
def var pudes as char format "x(100)".
def var punum like point.point.
def var v-dep like ppoint.depart.
def var v-depteller like ppoint.depart.

def var m-ln like aal.ln init "0" no-undo.
def var m-dc like jl.dc no-undo.

def var s-ourbank as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define temp-table wrk
    field w_teller like ofc.ofc
    field w_crc like crc.crc
    field w_debet like aal.amt
    field w_credit like aal.amt
    field w_dpap as integer
    field w_cpap as integer
    index main is primary w_teller w_crc.

def var c as integer.
def var cd as integer.

def var count like cashofc.amt.


find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   punum =  ofc.regno / 1000 - 0.5.
   v-dep = ofc.regno mod 1000.
end.


find sysc where sysc.sysc = "CASHGL" no-lock no-error.
c = sysc.inval.
find sysc where sysc.sysc = "RMCHKG" no-lock no-error.
cd = sysc.inval.


dest = "prit".
{cashr8.f}
update vappend dest with frame image1.

ddate = g-today.
if punum = 99 then do:
   update ddate label "ДАТА  " with row 8 side-labels centered no-box frame slo.
   update punum format "zzz9" label "Номер пункта  "
               with overlay row 11 side-labels centered frame sll.
end.
else do:
   update ddate label "ДАТА  " with row 8 no-box side-labels centered.
end.


for each jl where jl.jdt = ddate no-lock use-index jdt:
    if not (jl.gl = c or jl.gl = cd) or trim(jl.teller) = "" or jl.sts < 6 then next.

    v-depteller = get-dep (jl.teller, jl.jdt).

    if (punum = jl.point) and ((v-dep = 1) or (v-dep = v-depteller)) then do:
      find wrk where wrk.w_teller = jl.teller and wrk.w_crc = jl.crc no-error.
      if not avail wrk then do:
        create wrk.
        assign wrk.w_teller = jl.teller
               wrk.w_crc = jl.crc.
      end.

      if jl.dc eq "D" then do:
          wrk.w_debet = wrk.w_debet + jl.dam.
          wrk.w_dpap  = wrk.w_dpap + 1.
              if jl.jh = m-ln and m-dc = jl.dc then do:
              find last compaydoc where compaydoc.jh = jl.jh and compaydoc.txb = s-ourbank no-lock no-error.
              if avail compaydoc then wrk.w_dpap  = wrk.w_dpap - 1.
              end.
      end.

      if jl.dc eq "C" then do:
          wrk.w_credit = wrk.w_credit + jl.cam.
          if jl.jh <> m-ln then wrk.w_cpap = wrk.w_cpap + 1.
          if jl.jh = m-ln and m-dc <> jl.dc then wrk.w_cpap = wrk.w_cpap + 1.
      end.
      m-ln = jl.jh. m-dc = jl.dc.
    end.

end.


damt = 0.
camt = 0.
dpap = 0.
cpap = 0.


for each aal where aal.regdt = ddate and aal.teller <> " "
    no-lock use-index regdt break by aal.teller by aal.crc:

    v-depteller = get-dep (aal.teller, aal.regdt).

    if (punum = aal.point) and ((v-dep = 1) or (v-dep = v-depteller)) then do:

      find first aax where aax.ln eq aal.aax no-lock.

      if aax.dgl eq c then do:
          damtt = damtt + aal.amt.
          dpap = dpap + 1.
      end.
      else if aax.cgl eq c then do:
          camtt = camtt + aal.amt.
          cpap = cpap + 1.
      end.
    end.

    if last-of(aal.crc) and (dpap + cpap > 0) then do:

        create wrk.
        assign wrk.w_teller = aal.teller
               wrk.w_crc = aal.crc
               wrk.w_debet = damtt
               wrk.w_credit = camtt
               wrk.w_dpap = dpap
               wrk.w_cpap = cpap.

        damtt = 0.
        camtt = 0.
        dpap = 0.
        cpap = 0.
    end.
end.


if vappend then output to rpt.img append.
else output to rpt.img.
{cashr81.f}


find first cmp no-lock no-error.
find first ppoint where ppoint.point = punum and ppoint.depart = v-dep no-lock no-error.


for each wrk break by wrk.w_teller by wrk.w_crc:

    if first-of(wrk.w_teller) then do:
        find ofc where ofc.ofc eq wrk.w_teller no-lock no-error.
        if available ofc then do :
           punum =  ofc.regno / 1000 - 0.5.
           v-dep = ofc.regno mod 1000.
           find first ppoint where ppoint.point = punum and ppoint.depart = v-dep no-lock no-error.
        end.

        put cmp.name format "x(40)" to 75 skip
            cmp.addr[1] format "x(40)" to 75 skip
            ppoint.name format "x(40)" to 75 skip(1).
        put ofc.name skip string (ddate) "       " string(time,"HH:MM:SS") skip.

/*=========================> 10.10.2001, by sasco >========================*/
/*========================= Выписка авансов, подкреплений и расходов ======*/
   put fill ("-", 70) format "x(70)" skip.

   put "Аванс на начало дня" skip.
   for each cashofc no-lock where cashofc.whn eq ddate and
                          cashofc.ofc eq wrk.w_teller and
                          cashofc.sts eq 1 /* avans */
                          by cashofc.crc:

      find crc where crc.crc eq cashofc.crc no-lock no-error.
      if avail crc then
        put "                    " crc.code cashofc.amt skip.
   end.

   put "Подкрепления в течение дня (общая сумма)" skip.
   for each crc no-lock:
   count = 0.0.
   for each cashofc where cashofc.whn eq ddate and
                          cashofc.ofc eq wrk.w_teller and
                          cashofc.sts eq 3 /* podkr */
                          and cashofc.crc eq crc.crc no-lock:
             if avail cashofc then
             count = count + cashofc.amt.
    end.
    if count ne 0.0 then
    put "                    " crc.code count skip.
    end.

    put "Расходы (общая сумма)" skip.
    for each crc no-lock:
    count = 0.0.
        for each cashofc where cashofc.whn eq ddate and
                               cashofc.ofc eq wrk.w_teller and
                               cashofc.sts eq 4 /* return */
                               and cashofc.crc eq crc.crc no-lock:

        if avail cashofc then count = count + cashofc.amt.
        end.
        if count ne 0.0 then
             put "                    " crc.code count skip.
    end.

/*=========================< 10.10.2001, by sasco <========================*/

        put fill ("-", 70) format "x(70)" skip.
        put "Валюта   Кол.докум.      Взнос         Кол.докум.         Выдача  "
        skip.
        put fill ("-", 70) format "x(70)" skip.

      end.

    damt = damt + wrk.w_debet.
    camt = camt + wrk.w_credit.
    dpap = dpap + wrk.w_dpap.
    cpap = cpap + wrk.w_cpap.

    if last-of(wrk.w_crc) then do:
        find crc where crc.crc eq wrk.w_crc no-lock.
        put crc.code dpap "  " damt cpap "  " camt skip.
        dpapi = dpapi + dpap.
        cpapi = cpapi + cpap.
        damt = 0.   camt = 0.   dpap = 0.   cpap = 0.
    end.

    if last-of (wrk.w_teller) then do:
        put skip(1).
        put "Итог" dpapi "                       " cpapi skip(1).
        put fill ("-", 70) format "x(70)" skip.

/*=========================> 10.10.2001, by sasco >=========================*/
        put "Остатки в кассе" skip.
        for each cashofc no-lock where cashofc.whn eq ddate and
                               cashofc.ofc eq wrk.w_teller and
                               cashofc.sts eq 2 /* current */
                               by cashofc.crc:
            find crc where crc.crc eq cashofc.crc no-lock no-error.
            if avail crc then
             put "                    " crc.code cashofc.amt skip.

        end.
        put skip(5).
/*=========================< 10.10.2001, by sasco <=========================*/

        put "Кассир  (подпись )              Контролер   (подпись )" skip.
        put "            Дата              Фамилия  " skip(5).
        dpapi = 0.
        cpapi = 0.
    end.
end.

put skip(10).

output close.
unix  value(dest) rpt.img.
