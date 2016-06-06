/* getGl_txb.p
 * MODULE
        Управленческая отчетность
 * DESCRIPTION
        Управленческая отчетность
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
        17/01/2011 k.gitalov
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


def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   message " There is no record OURBNK in bank.sysc file !!" view-as alert-box.
   return.
end.


if trim(txb.sysc.chval) = "txb00" then return.
s-ourbank = "txb00".



function getKID returns integer (input p-kcode as char).
    find first t-krit where t-krit.kcode = p-kcode no-lock no-error.
    if avail t-krit then return t-krit.kid.
    else return 0.
end function.

function getGL returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:

            if string(p-gl) = "359910" then res1 = txb.glday.bal.
            else res1 = txb.glday.dam - txb.glday.cam.

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
                if txb.gl.totact and p-gr <> "359910" then next.
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

/*
def var v-od1 as deci no-undo extent 3.
def var v-od2 as deci no-undo extent 3.
def var v-od3 as deci no-undo extent 3.
def var v-odpr as deci no-undo extent 3.
def var v-prc as deci no-undo extent 3.
def var v-prcpr as deci no-undo extent 3.
def var v-prov as deci no-undo extent 3.
def var v-pen as deci no-undo extent 3.
def var totals as deci no-undo extent 3.
def var bilance as deci no-undo.
def var v-urfiz as integer no-undo.
def var v-gr as integer no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var v-days as integer no-undo.
def var v-bal as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-ostp as deci no-undo extent 3.
def var predopl as deci no-undo.
def var bil as deci no-undo.
def var v-sum as deci no-undo.
def var dn1 as integer no-undo.
def var dn2 as deci no-undo.
def var v-tiin as deci no-undo.
*/

for each t-period no-lock:
  run setKritVal("SO_Ner_dohod_pred", t-period.pid, - getGroupGL("3580",'',t-period.dte) ).
 /* run setKritVal("SO_Ner_dohod_tekuch", t-period.pid, getGroupGL("359910",'',t-period.dte) ).*/
  run setKritVal("SO_Adjust_provision_account", t-period.pid, - getGroupGL("330",'',t-period.dte) ). /*TZ1120*/
  run setKritVal("SO_Net_profit_loss", t-period.pid, getGroupGL("359910",'',t-period.dte) ). /*TZ1120*/
  run setKritVal("SO_Retained_earnings", t-period.pid, - getGroupGL("359913",'',t-period.dte) ). /*TZ1120*/


  if v-period = "month" then do: /*месячный отчет*/
      if month(t-period.dtb) = 1 then do:
        run setKritVal("com_inexp_val",t-period.pid,abs(getGroupGL("4703","",t-period.dte)) - abs(getGroupGL("5703","",t-period.dte))).
      end.
      else do:
         run setKritVal("com_inexp_val",t-period.pid,
            (
             abs(getGroupGL("4703","",t-period.dte)) - abs(getGroupGL("5703","",t-period.dte))
            )
            -
            (
             abs(getGroupGL("4703","",t-period.dtb - 1)) - abs(getGroupGL("5703","",t-period.dtb - 1))
            )
            ).
      end.



  end.
  else do: /*недельный отчет*/
      if month(t-period.dtb) = 1 and day(t-period.dtb) < 6 then do:
        run setKritVal("com_inexp_val",t-period.pid,abs(getGroupGL("4703","",t-period.dte)) - abs(getGroupGL("5703","",t-period.dte))).
      end.
      else do:
         run setKritVal("com_inexp_val",t-period.pid,
            (
             abs(getGroupGL("4703","",t-period.dte)) - abs(getGroupGL("5703","",t-period.dte))
            )
            -
            (
             abs(getGroupGL("4703","",t-period.dtb - 1)) - abs(getGroupGL("5703","",t-period.dtb - 1))
            )
            ).
      end.


  end.



end.


hide message no-pause.