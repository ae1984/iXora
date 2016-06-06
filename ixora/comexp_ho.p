/* comexp_ho.p
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
        10/06/2011 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
*/


def input param v-period as char.

def shared temp-table t-period no-undo
    field pid as integer
    field dtb as date
    field dte as date
    index idx is primary dtb.

def shared temp-table t-krit no-undo
    field kid as integer
    field kcode as char
    field bold_code as log
    field color_code as log
    field des_en as char
    field des_ru as char
    field level as integer
    index idx is primary kid
    index idx2 kcode.

def shared temp-table t-kritval no-undo
    field bank as char
    field kid as integer
    field pid as integer
    field sum as deci
    index idx is primary bank kid pid.

def shared var g-today as date.
def var dtm_prev as date no-undo.
def var dtm_before_prev as date no-undo.


def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   message " There is no record OURBNK in bank.sysc file !!" view-as alert-box.
   return.
end.

if trim(txb.sysc.chval) <> "txb00" then return.
s-ourbank = "txb00".


function getGL returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:
            res1 = txb.glday.dam - txb.glday.cam.
            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.

function getGLcrc returns deci (input p-gl as integer, input p-dt as date, input crc as integer).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    find first txb.crc where txb.crc.crc = crc no-lock no-error.
    if avail txb.crc then do:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:
            res1 = txb.glday.dam - txb.glday.cam.
            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.

function str2GL returns integer (input p-glstr as char, input p-gltype as char).
    def var res as integer no-undo.
    res = 0.
    def var v-i as integer no-undo.
    v-i = ?.
    def var v-c as char no-undo.
    v-c = ''.
    p-glstr = trim(p-glstr).
    if (p-gltype = "start") or (p-gltype = "end") then do:
        if p-gltype = "start" then v-c = '0'. else v-c = '9'.
        if (p-glstr <> '') and length(p-glstr) <= 6 then do:
            v-i = integer(p-glstr) no-error.
            if (v-i <> ?) and (v-i > 0) then do:
                res = integer(p-glstr + fill(v-c,6 - length(p-glstr))).
            end.
        end.
    end.
    return res.
end function.




function getGroupGL returns deci (input p-gr as char, input p-ex as char, input p-dt as date).
    def var res as deci no-undo.
    def var v-i as integer no-undo.
    def var v-j as integer no-undo.
    def var gr as char no-undo.
    p-gr = trim(p-gr).
    p-ex = trim(p-ex).
    res = 0.
    if p-gr <> '' then do:
        do v-i = 1 to num-entries(p-gr):
            gr = entry(v-i,p-gr).
         g: for each txb.gl where txb.gl.gl >= str2GL(gr,"start") and txb.gl.gl <= str2GL(gr,"end") no-lock:
                /* gl.totact = no gl.totlev = 1 */
                if gl.totact then next.
                if p-ex <> '' then do:
                    do v-j = 1 to num-entries(p-ex):
                        if substring(string(txb.gl.gl),1,length(entry(v-j,p-ex))) = entry(v-j,p-ex) then next g.
                    end.
                end.
                res = res + getGL(txb.gl.gl,p-dt).


            end.
        end. /* do v-i */
    end. /* if p-gr <> '' */
    return res.
end function.

function days_in_month returns integer (input p-m as integer, input p-y as integer).
    def var res as integer no-undo.
    def var mm as integer no-undo.
    def var yy as integer no-undo.
    yy = p-y.
    mm = p-m + 1.
    if mm = 13 then assign mm = 1 yy = yy + 1.
    res = day(date(mm,1,yy) - 1).
    return res.
end function.

function getGLTurnover returns decimal (input p-gr as char, p-ex as char, input p-dt as date):
    def var res as deci no-undo.
    def var dt1 as date no-undo.
    def var dt2 as date no-undo.
    def var mm as integer no-undo.
    def var yy as integer no-undo.
    dt1 = date(month(p-dt),1,year(p-dt)) - 1.
    yy = year(p-dt).
    mm = month(p-dt) + 1.
    if mm = 13 then assign yy = yy + 1 mm = 1.
    dt2 = date(mm,1,yy) - 1.
    res = getGroupGL(p-gr,p-ex,dt2) - getGroupGL(p-gr,p-ex,dt1).
    return res.
end function.

function getKID returns integer (input p-kcode as char).
    find first t-krit where t-krit.kcode = p-kcode no-lock no-error.
    if avail t-krit then return t-krit.kid.
    else return 0.
end function.

function getKritVal returns deci (input p-kcode as char, input p-pid as integer).
    def var v-res as deci no-undo.
    v-res = 0.
    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-lock no-error.
        if avail t-kritval then v-res = t-kritval.sum.
    end.
    return v-res.
end function.

procedure setKritVal.
    def input parameter p-kcode as char no-undo.
    def input parameter p-pid as integer no-undo.
    def input parameter p-sum as deci no-undo.

    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-error.
        if not avail t-kritval then do:
            create t-kritval.
            assign t-kritval.bank = s-ourbank
                   t-kritval.kid = v-kid
                   t-kritval.pid = p-pid.
        end.
        t-kritval.sum = t-kritval.sum + p-sum.
    end.
end procedure.

procedure setKritVal2.
    def input parameter p-kcode as char no-undo.
    def input parameter p-pid as integer no-undo.
    def input parameter p-sum as deci no-undo.

    def var v-kid as integer no-undo.
    v-kid = getKID(p-kcode).
    if v-kid > 0 then do:
        find first t-kritval where t-kritval.bank = s-ourbank and t-kritval.kid = v-kid and t-kritval.pid = p-pid no-error.
        if not avail t-kritval then do:
            message "Не найден параметр " p-kcode view-as alert-box.
        end.
        t-kritval.sum = p-sum.
    end.
end procedure.


function GetExpense returns deci ( input p-dt as date, input ext_cod as log , input s-code as char , input v-gl as char).
  def var res as deci init 0 .
  def var i as int init 0 .
  def var i2 as int init 0 .
  def var iret as log init false .
  def var jhs-code as char  no-undo.
  def var is-cod as char no-undo.
  def var v-rate as deci no-undo.
  def var summ as deci no-undo.
  def var v-date as date no-undo.
  def var v-date2 as date no-undo.
  def var mm as integer no-undo.
  def var yy as integer no-undo.
  DEFINE BUFFER b-gl FOR txb.gl.
  DEFINE VARIABLE qh AS HANDLE.
  DEFINE VARIABLE ListGL AS CHAR INIT "".
  CREATE QUERY qh.
  qh:SET-BUFFERS("b-gl").

  v-date = date(month(p-dt),1,year(p-dt)).
  yy = year(p-dt).
  mm = month(p-dt) + 1.
  if mm = 13 then assign yy = yy + 1 mm = 1.
  v-date2 = date(mm,1,yy) - 1.

  do i = 1 to num-entries(v-gl,","):
   if ListGL <> "" then ListGL = ListGL + " or ".
   ListGL = ListGL + " string(b-gl.gl) begins '" + entry(i,v-gl,",") + "'".
  end.

        qh:QUERY-CLOSE().
        qh:QUERY-PREPARE("for each b-gl where " + ListGL ).
        qh:QUERY-OPEN.
        qh:GET-FIRST().


        if avail b-gl then
        do:



          REPEAT:
           IF qh:QUERY-OFF-END THEN LEAVE.
             for each txb.jl  no-lock where txb.jl.jdt >= v-date  and txb.jl.jdt <= v-date2 and txb.jl.gl = b-gl.gl.
              if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
              if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

              find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx  no-lock no-error.
              if not avail txb.trxcods then next.
              for each txb.trxcods no-lock where txb.trxcods.trxh = txb.jl.jh  and txb.trxcods.trxln = txb.jl.ln and  txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx .

               find last txb.crchis where txb.crchis.crc = txb.jl.crc
                   and txb.crchis.rdt <= txb.jl.jdt  use-index crcrdt no-lock no-error.
               if not available txb.crchis then do:
                 message 'Не задан курс для валюты ' txb.jl.crc .
                 v-rate =  1.
               end.
               else do:
                 v-rate =  txb.crchis.rate[1].
                end.

                jhs-code = substr(txb.trxcods.code,1,7).
                iret = false.

                if s-code = "" then assign iret = yes ext_cod = yes.
                else iret = (lookup(jhs-code,s-code) > 0).

                if (ext_cod and iret) or ((not ext_cod) and (not iret)) then /*только по коду s-code*/
                do:

                    summ = 0.

                    if txb.jl.dam <> 0 then  summ = txb.jl.dam * v-rate . else summ = - (txb.jl.cam * v-rate).
                    res = res + summ.

                end.

              end.
             end.
           qh:GET-NEXT().
          END.
        end. /*gl*/

  return res.
end function.
/**************************************************************************************/
function AccrualMethod returns decimal (input p as date, input t as date, input S0 as deci, input S1 as deci, input S2 as deci):
    def var res as deci no-undo.
    def var mm as integer.
    def var yy as integer.
    p = p - 1.
    if year(t) = year(p) and month(t) = month(p) then res = S1 * (t - p) / days_in_month(month(t),year(t)).
    else do:
        if day(t) = days_in_month(month(t),year(t)) then res = S2 - (S1 * day(p)) / days_in_month(month(t),year(t)).
        else do:
            yy = year(t).
            mm = month(t) - 1.
            if mm = 0 then assign mm = 12 yy = yy - 1.
            res = S1 - S0 * day(p) / days_in_month(mm,yy) + S1 * day(t) / days_in_month(month(t),year(t)).
        end.
    end.
    return res.
end function.

/* Сохранить значение для использования в других отчетах */
procedure setStoredKritVal.
    def input parameter p-bank as char no-undo.
    def input parameter p-kcode as char no-undo.
    def input parameter p-dtb as date no-undo.
    def input parameter p-sum as deci no-undo.

    def var c-pref as char init ''.
    if v-period = "month" then c-pref = "fact_" + p-kcode.
    else c-pref = p-kcode.

    do transaction:
        find first uprdata where uprdata.bank = p-bank and uprdata.kcode = c-pref and uprdata.dtb = p-dtb exclusive-lock no-error.
        if not avail uprdata then do:
            create uprdata.
            assign uprdata.bank = p-bank
                   uprdata.kcode = c-pref
                   uprdata.dtb = p-dtb.
        end.
        uprdata.kvalue = p-sum.
        find current uprdata no-lock.
    end. /* transaction */
end procedure.


/*операционные расходы*/
for each t-period no-lock:

 if v-period = "month" then do: /*месячный отчет*/

    run setKritVal("com_socpay",t-period.pid,GetExpense( t-period.dtb ,no,"","572940,5721")).
    /*TZ972*/
    run setKritVal("com_bon",t-period.pid,GetExpense( t-period.dtb ,no,"","572910,572930")).

    run setKritVal("com_trip",t-period.pid,GetExpense( t-period.dtb ,no,"","5749")).
    run setKritVal("com_renpay",t-period.pid,GetExpense( t-period.dtb ,no,"","5923")).
    run setKritVal("com_renpay",t-period.pid,GetExpense( t-period.dtb ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748")).
    run setKritVal("com_amort",t-period.pid,GetExpense( t-period.dtb ,no,"","578")).
    run setKritVal("com_taxgov",t-period.pid,GetExpense( t-period.dtb ,no,"","576,5722")).
    run setKritVal("com_mark",t-period.pid,GetExpense( t-period.dtb ,no,"","5745")).
    run setKritVal("com_call",t-period.pid,GetExpense( t-period.dtb ,no,"","5753")).
    run setKritVal("com_secur",t-period.pid,GetExpense( t-period.dtb ,no,"","5746")).
    run setKritVal("com_admin",t-period.pid,GetExpense( t-period.dtb ,no,"","5742")).
    run setKritVal("com_audit",t-period.pid,GetExpense( t-period.dtb ,no,"","5750")).
    /*TZ972*/
    run setKritVal("com_other",t-period.pid,GetExpense( t-period.dtb ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( t-period.dtb ,no,"","4852, 4853") ) ).

    run setKritVal("com_other",t-period.pid,GetExpense( t-period.dtb ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748")).
    run setKritVal("com_exp_all",t-period.pid, getKritVal("com_socpay",t-period.pid) +
                                               getKritVal("com_bon",t-period.pid) +
                                               getKritVal("com_trip",t-period.pid) +
                                               getKritVal("com_renpay",t-period.pid) +
                                               getKritVal("com_amort",t-period.pid) +
                                               getKritVal("com_taxgov",t-period.pid) +
                                               getKritVal("com_mark",t-period.pid) +
                                               getKritVal("com_call",t-period.pid) +
                                               getKritVal("com_admin",t-period.pid) +
                                               getKritVal("com_audit",t-period.pid) +
                                               getKritVal("com_secur",t-period.pid) +
                                               getKritVal("com_other",t-period.pid)).


  end.
  else do:
    dtm_prev = date(month(t-period.dte),1,year(t-period.dte)) - 1.
    dtm_before_prev = date(month(dtm_prev),1,year(dtm_prev)) - 1.

 /*  message "Зарплата и социальные платежи~n S0 =" string(GetExpense( dtm_before_prev ,no,"","5721")) "~n S1 =" string(GetExpense( dtm_prev ,no,"","5721")) "~n S2 =" string(GetExpense( t-period.dte ,no,"","5721")) "~n X = " string(AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5721"),GetExpense( dtm_prev ,no,"","5721"), GetExpense( t-period.dte ,no,"","5721")),">>>>>>>>>>>.99-") view-as alert-box.*/

    run setKritVal("com_socpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","572940,5721"),GetExpense( dtm_prev ,no,"","572940,5721"), GetExpense( t-period.dte ,no,"","572940,5721"))).
    /*TZ972*/
    run setKritVal("com_bon",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","572910,572930"),GetExpense( dtm_prev ,no,"","572910,572930"), GetExpense( t-period.dte ,no,"","572910,572930"))).

    run setKritVal("com_trip",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5749"),GetExpense( dtm_prev ,no,"","5749"), GetExpense( t-period.dte ,no,"","5749"))).
    run setKritVal("com_renpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5923"),GetExpense( dtm_prev ,no,"","5923"), GetExpense( t-period.dte ,no,"","5923"))).
    run setKritVal("com_renpay",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"),GetExpense( dtm_prev ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"), GetExpense( t-period.dte ,yes,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"))).
    run setKritVal("com_amort",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","578"),GetExpense( dtm_prev ,no,"","578"), GetExpense( t-period.dte ,no,"","578"))).
    run setKritVal("com_taxgov",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","576,5722"),GetExpense( dtm_prev ,no,"","576,5722"), GetExpense( t-period.dte ,no,"","576,5722"))).
    run setKritVal("com_mark",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5745"),GetExpense( dtm_prev ,no,"","5745"), GetExpense( t-period.dte ,no,"","5745"))).
    run setKritVal("com_call",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5753"),GetExpense( dtm_prev ,no,"","5753"), GetExpense( t-period.dte ,no,"","5753"))).
    run setKritVal("com_secur",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5746"),GetExpense( dtm_prev ,no,"","5746"), GetExpense( t-period.dte ,no,"","5746"))).
    run setKritVal("com_admin",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5742"),GetExpense( dtm_prev ,no,"","5742"), GetExpense( t-period.dte ,no,"","5742"))).
    run setKritVal("com_audit",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"","5750"),GetExpense( dtm_prev ,no,"","5750"), GetExpense( t-period.dte ,no,"","5750"))).
    /*TZ972*/
    run setKritVal("com_other",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,
                      GetExpense( dtm_before_prev ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( dtm_before_prev ,no,"","4852, 4853") ),
                      GetExpense( dtm_prev ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( dtm_prev ,no,"","4852, 4853") ),
                      GetExpense( t-period.dte ,no,"","5741,5743,5744,5747,5752,5852,5853,5922") - abs( GetExpense( t-period.dte ,no,"","4852, 4853") )
                      )).

    run setKritVal("com_other",t-period.pid,AccrualMethod(t-period.dtb,t-period.dte,GetExpense( dtm_before_prev ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"),GetExpense( dtm_prev ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"), GetExpense( t-period.dte ,no,"3020101,3020102,3020103,3020104,3020105,3020106,3020107","5748"))).
    run setKritVal("com_exp_all",t-period.pid, getKritVal("com_socpay",t-period.pid) +
                                               getKritVal("com_bon",t-period.pid) +
                                               getKritVal("com_trip",t-period.pid) +
                                               getKritVal("com_renpay",t-period.pid) +
                                               getKritVal("com_amort",t-period.pid) +
                                               getKritVal("com_taxgov",t-period.pid) +
                                               getKritVal("com_mark",t-period.pid) +
                                               getKritVal("com_call",t-period.pid) +
                                               getKritVal("com_admin",t-period.pid) +
                                               getKritVal("com_audit",t-period.pid) +
                                               getKritVal("com_secur",t-period.pid) +
                                               getKritVal("com_other",t-period.pid)).
  end.

end.



for each t-period no-lock:
  run setStoredKritVal( "txb00" , "com_exp_all" , t-period.dtb ,getKritVal("com_exp_all",t-period.pid)).
  run setKritVal2("com_socpay",t-period.pid,0).
  run setKritVal2("com_bon",t-period.pid,0).
  run setKritVal2("com_trip",t-period.pid,0).
  run setKritVal2("com_renpay",t-period.pid,0).
  run setKritVal2("com_amort",t-period.pid,0).
  run setKritVal2("com_taxgov",t-period.pid,0).
  run setKritVal2("com_mark",t-period.pid,0).
  run setKritVal2("com_call",t-period.pid,0).
  run setKritVal2("com_secur",t-period.pid,0).
  run setKritVal2("com_admin",t-period.pid,0).
  run setKritVal2("com_audit",t-period.pid,0).
  run setKritVal2("com_other",t-period.pid,0).
  run setKritVal2("com_exp_all",t-period.pid,0).
end.


