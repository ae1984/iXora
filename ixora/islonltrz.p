/* islonltrz.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/* islonltrz.p
   проводка из кредитного модуля - выдача переводом
   изменения от 13.03.2001
   - psrorlon.f
*/
    
 {global.i}
 {lgps.i}
 {s-lonliz.i}

define var v-cashgl like gl.gl.

def shared var s-lon like lon.lon.
def shared var s-remtrz like remtrz.remtrz .
def shared frame remtrz . 
define shared variable s-jh like jh.jh.

def var v-ref as cha format "x(10)". 
def var v-pnp as cha format "x(10)".
def var v-chg as int  .
def var v-reg5  as cha format "x(13)".
def var acode like crc.code . 
def var bcode like crc.code .
def var pakal as cha .
def var v-cash as log.


def var v-param as char.
def var v-templ as char.
def var vdel as char initial "^".
def var v-rcode as int.
def var v-rdes as char. 
def var v-glout like gl.gl.

/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
def var OK as logi initial false.
/*ja - EKNP - 26/03/2002 */

do transaction :
{psrorlon.f}

find sysc where sysc.sysc eq "CASHGL".
v-cashgl = sysc.inval.

find lon where lon.lon = s-lon no-error.


find first remtrz where remtrz.remtrz  = s-remtrz  no-lock .
if remtrz.jh1 ne ?  then do: 
    v-text = remtrz.remtrz +  " 1 TRX = " + string(remtrz.jh1)  +
    " have been already done . " .
    message v-text . pause .
    return .
end .



find first remtrz where remtrz.remtrz = s-remtrz  exclusive-lock .

find sysc where sysc eq "pspygl" no-lock no-error.
if available sysc then do :
    if tcrc eq 1 then do:
        v-glout = integer(sysc.chval) no-error.
        if error-status:error then do:
            message "Error reading psygl".
            pause 5.
            return.
        end.
    end.
    else v-glout = sysc.inval.
end.    
else do:
    message "Not found psygl in sysc".
    pause 5.
    return.
end.


if remtrz.fcr eq remtrz.tcrc then do:
    v-templ = "lon0005".
    v-param = remtrz.remtrz + vdel +
    string(remtrz.amt) + vdel +
    remtrz.dracc + vdel +
    string(v-glout) + vdel +
    s-glremx[1] + vdel + 
    s-glremx[2] + vdel +
    s-glremx[3] + vdel +
    s-glremx[4] + vdel +
    s-glremx[5].

end.
else do :
    v-templ = "lon0006".
    v-param = remtrz.remtrz + vdel +
    string (remtrz.tcrc) + vdel +    
    string(v-glout) + vdel +
    string(remtrz.amt) + vdel +
    remtrz.dracc + vdel +
    s-glremx[1] + vdel +
    s-glremx[2] + vdel +
    s-glremx[3] + vdel +
    s-glremx[4] + vdel +
    s-glremx[5].
end.

/* ja - EKNP - 26/03/2002 --------------------------------------------*/
        run Collect_Undefined_Codes(v-templ).
        run Parametrize_Undefined_Codes(output OK).
        if not OK then do:
           bell.
           message "Не все коды введены! Транзакция не будет создана!"
                   view-as alert-box.
           return "exit".
        end.
            
           run Insert_Codes_Values(v-templ, vdel, input-output v-param).
/* ja - EKNP - 26/03/2002 --------------------------------------------*/

s-jh = 0.
run trxgen (v-templ, vdel, v-param, "lon", lon.lon,
output v-rcode, output v-rdes, input-output s-jh).
                        
if v-rcode ne 0 then do:
    message v-rdes.
    pause.
    undo,next.
end.


if remtrz.svca ne 0  then do:
    if remtrz.svcgl eq v-cashgl then do :
        v-templ = "psy0026".
        v-param = 
        string(remtrz.svca) + vdel +
        string(remtrz.svcrc) + vdel +
        string(remtrz.svccgl) + vdel +
        remtrz.remtrz + " " + remtrz.detpay[1].
        .
    end.
    else do :
        if remtrz.svcaaa eq s-lon then v-templ = "lon0007".
        else v-templ = "psy0025".
        v-param =
        string(remtrz.svca) + vdel +
        remtrz.svcaaa + vdel +
        string(remtrz.svccgl) + vdel +
        remtrz.remtrz + " " + remtrz.detpay[1] .
        .
    end.
     
    run trxgen (v-templ, vdel, v-param, "lon", lon.lon,
    output v-rcode, output v-rdes, input-output s-jh).

    if v-rcode ne 0 then do:
        message v-rdes.
        pause.
        undo,next.
    end.
    find jh where jh.jh = s-jh exclusive-lock .
    jh.party = remtrz.remtrz + "  (" + trim(substr(remtrz.sqn,19)) + ")".

end . /*    end of SERVICE CHARGE  TRX  */

run lonresadd(s-jh).

/* 

 find jh where jh.jh = s-jh exclusive-lock .
 jh.party = remtrz.remtrz + "  (" + trim(substr(remtrz.sqn,19)) + ")".

*/


/*     decrease  nbal  correction    */

    find first nbal where nbal.dfb = remtrz.dracc and
    nbal.plus = remtrz.valdt1 - g-today exclusive-lock no-error .
    if avail nbal then
    do:
        nbal.inwbal = nbal.inwbal - remtrz.amt .
        if nbal.inwbal = 0 and nbal.outbal = 0 then delete nbal .
    end.

/*        end nbal                */

   /*  End of program body */
    v-text = string(s-jh) + " 1-TRX " + remtrz.remtrz +
    " " + remtrz.dracc + " " + string(remtrz.amt) + " CRC = " +
    string(remtrz.fcrc) + " was made by " + g-ofc .
   
   
   run lgps.
   remtrz.jh1 = s-jh.
   
end.  /*transaction */

/*
run v-rmtrz. /* печать ваучера */
*/

run x-jlvouPl.
pause 0.

v-cash = no.
for each jl where jl.jh eq remtrz.jh1 no-lock.
   if jl.gl eq v-cashgl then v-cash = true.
end.

do transaction: 
    
    
    find que of remtrz no-error.
    if v-cash then que.rcod = '10'.
    else que.rcod  = '0'. 
    v-text = " Send " + remtrz.remtrz + " by route , rcod = " + que.rcod  .
    run lgps.
    que.con = "F".
    que.dp = today.
    que.tp = time.
    release que .
end.    

/*ja - EKNP - 26/03/2002 -------------------------------------------*/
Procedure Collect_Undefined_Codes.

def input parameter c-templ as char.
def var vjj as inte.
def var vkk as inte.
def var ja-name as char.

for each w-cods:
   delete w-cods.
end.

for each trxhead where trxhead.system = substring (c-templ, 1, 3) 
             and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:

    if trxhead.sts-f eq "r" then vjj = vjj + 1.

    if trxhead.party-f eq "r" then vjj = vjj + 1.

    if trxhead.point-f eq "r" then vjj = vjj + 1.

    if trxhead.depart-f eq "r" then vjj = vjj + 1.

    if trxhead.mult-f eq "r" then vjj = vjj + 1.

    if trxhead.opt-f eq "r" then vjj = vjj + 1.

    for each trxtmpl where trxtmpl.code eq c-templ no-lock:
    
        if trxtmpl.amt-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.rate-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.
               
        repeat vkk = 1 to 5:
            if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
        end.
        
        for each trxcdf where trxcdf.trxcode = trxtmpl.code
                          and trxcdf.trxln = trxtmpl.ln:

         if trxcdf.drcod-f eq "r" then do:
             vjj = vjj + 1.
    
             find first trxlabs where trxlabs.code = trxtmpl.code 
                                  and trxlabs.ln = trxtmpl.ln 
                                  and trxlabs.fld = trxcdf.codfr + "_Dr" 
                                                        no-lock no-error. 
             if available trxlabs then ja-name = trxlabs.des.
             else do: 
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.
         
         if trxcdf.crcode-f eq "r" then do:
             vjj = vjj + 1. 
            
             find first trxlabs where trxlabs.code = trxtmpl.code 
                                  and trxlabs.ln = trxtmpl.ln 
                                  and trxlabs.fld = trxcdf.codfr + "_Cr" 
                                                        no-lock no-error. 
             if available trxlabs then ja-name = trxlabs.des.
             else do: 
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.
  end.
    end. /*for each trxtmpl*/
end. /*for each trxhead*/ 

End procedure.

Procedure Parametrize_Undefined_Codes.

  def var ja-nr as inte.
  def output parameter OK as logi initial false.
  def var jrcode as inte.
  def var saved-val as char.

  find first w-cods no-error.
  if not available w-cods then do:
    OK = true.
    return.
  end. 
  
  {jabrew.i
   &start = " on help of w-cods.val in frame lon_cods do:
               if w-cods.codfr = 'spnpl' then run uni_help1(w-cods.codfr,'4*').
                                         else run uni_help1(w-cods.codfr,'*').
              end.
              vkey = 'return'.
              key-i = 0. "    

   &head = "w-cods"
   &headkey = "parnum"
   &where = "true"
   &formname = "lon_cods"
   &framename = "lon_cods"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
   &predisplay = " ja-nr = ja-nr + 1. "
   &display = "ja-nr /*w-cods.codfr*/ w-cods.name /*w-cods.what*/ w-cods.val"
   &highlight = "ja-nr"
   &postkey = "else if vkeyfunction = 'return' then do:
               valid:
               repeat:
                saved-val = w-cods.val.
                update w-cods.val with frame lon_cods. 
                find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                if not available codfr or codfr.code = 'msc' then do:
                   bell.
                   message 'Некорректное значение кода! Введите правильно!'
                           view-as alert-box.
                   w-cods.val = saved-val.
                   display w-cods.val with frame lon_cods.
                   next valid.
                end.
                else leave valid.
               end.
                if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                  key-i = 0.
                  vkey = 'cursor-down^return'.
                end.
               end.
               else if keyfunction(lastkey) = 'GO' then do:
                   jrcode = 0.
                 for each w-cods:
                  find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                  if not available codfr or codfr.code = 'msc' then jrcode = 1.       
                 end.
                 if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                 end.
                 else do: OK = true. leave upper. end.
               end."  
   &end = "hide frame lon_cods.
           hide message."
}

End procedure.

Procedure Insert_Codes_Values.

def input parameter t-template as char.
def input parameter t-delimiter as char.
def input-output parameter t-par-string as char.
def var t-entry as char. 

for each w-cods where w-cods.template = t-template break by w-cods.parnum:
   t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
   if ERROR-STATUS:error then
      t-par-string = t-par-string + t-delimiter + w-cods.val.
   else do:
      entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
      entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
   end.
end.

End procedure.
/*ja - EKNP - 26/03/2002 ------------------------------------------*/
