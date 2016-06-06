/* scr_extract.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Выписка для экрана клиента
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
        --/--/2011 k.gitalov
 * BASES
        BANK
 * CHANGES
        10/07/2012 dmitriy - изменил вывод под новый шаблон
                           - добавил поле conagent в extract_tmp
        12.12.2012 dmitriy - к исходящему остатку добавил обороты за последний день (dt2)
*/

{classes.i}
{to_screen.i}

def temp-table extract_tmp
                    field ind as int
                    field date_doc as date
                    field debit as deci
                    field credit as deci
                    field rem as char
                    field conagent as char.

/***********************************************************************************************************/
function GetClientName returns char (input v-cif as char).
    find cif where cif.cif eq v-cif no-lock no-error.
    if not available cif then
    do:
      message "Не найден клиент " v-cif "в таблице CIF"  view-as alert-box.
      return "".
    end.
    else return  trim(trim(cif.prefix) + " " + trim(cif.name)).
end function.
/***********************************************************************************************************/
function GetCRCFromAAA returns char (input v-acc as char).
  def var code as char format "x(3)".
  def buffer b-crc for crc.
  def buffer b-aaa for aaa.
  find first b-aaa where b-aaa.aaa = v-acc no-lock no-error.
  if not avail b-aaa then return "".
   find b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
  return code.
end function.
/***********************************************************************************************************/

def input param v-Cif as char.
def input param v-Acc as char.
def var dt1 as date.
def var dt2 as date.

def buffer b-jl for jl.
def buffer b-jh for jh.
def var v-rem as char.
def var tmpl as char init "extract".
def var Res as char no-undo.
def var ResDef as char.
def var Pages as char label "страница".
def button prev-button label "Предыдущая".
def button next-button label "Следующая".
def button close-button label "Закрыть".
def var CurPage as int.
def var PosPage as int.
def var MaxPage as int init 0.
def var Pos as int.
def var phand AS handle.
def var i as int.
def var TLSTPAY as char.
def var TSUMMIN as char.
def var TSUMMOUT as char.
def var trecinn as char.
def var v-bal as deci.
def var bankname as char.
def var kod as char.
def var kbe as char.
def var knp as char.
def var v-remkom as char.
def var n as int.
def var v-str as char.
def var v-conag as char.
def var v-dr as deci.
def var v-cr as deci.

    run CreateData.
    find last extract_tmp no-lock no-error.
    if avail extract_tmp then do:
        TLSTPAY = "TLSTPAY=" + string(extract_tmp.date_doc, "99.99.9999").
    end.

    run lonbal3('cif', v-Acc, dt1, "1", yes, output v-bal).
    TSUMMIN = "TSUMMIN=" + string(v-bal,"->>>>>>>>>>>>>>>>9.99").

    run lonbal3('cif', v-Acc, dt2, "1", yes, output v-bal).
    v-dr = 0. v-cr = 0.
    for each jl where jl.jdt = dt2 and jl.acc = v-Acc and jl.lev = 1 no-lock:
        if jl.dc = "D" then v-dr = v-dr + jl.dam.
        if jl.dc = "C" then v-cr = v-cr + jl.cam.
    end.
    TSUMMOUT = "TSUMMOUT=" + string(v-bal + v-cr - v-dr,"->>>>>>>>>>>>>>>>9.99").


    ResDef = "TCIFNAME=" + GetClientName(v-Cif) + "&TAAA=" + v-Acc + "&TCRC=" + GetCRCFromAAA(v-Acc) + "&TDATE1=" + string(dt1, "99.99.9999") + "&TDATE2=" + string(dt2, "99.99.9999") + "&" + TLSTPAY + "&" + TSUMMIN + "&" + TSUMMOUT.
    PosPage = 1.

    find last extract_tmp no-lock no-error.
    if avail extract_tmp then MaxPage = extract_tmp.ind.
    else MaxPage = 1.

    define frame Form1
      Pages skip
      "----------------------------------" skip
      prev-button next-button close-button
     WITH SIDE-LABELS centered overlay row 20 TITLE "Движение по счету".

    ON CHOOSE OF next-button
    DO:
     PosPage = PosPage + 1.
     if PosPage > MaxPage then PosPage = MaxPage.
     Pages = string(PosPage) + " из " + string(MaxPage).
     run LoadData.
     if PosPage = 1 then run to_screen("extract1",ResDef).
     else run to_screen("extract2",Res).
     DISPLAY Pages WITH FRAME Form1.
    END.

    ON CHOOSE OF prev-button
    DO:
      PosPage = PosPage - 1.
      if PosPage <= 0 then PosPage = 1.
      Pages = string(PosPage) + " из " + string(MaxPage).
      run LoadData.
      if PosPage = 1 then run to_screen("extract1",ResDef).
      else run to_screen("extract2",Res).
      DISPLAY Pages WITH FRAME Form1.
    END.

    ON CHOOSE OF close-button
    DO:
      run to_screen( "default","").
      apply "endkey" to frame Form1.
      hide frame Form1.
      return.
    END.

    Pages = string(PosPage) + " из " + string(MaxPage).

    DISPLAY Pages prev-button next-button close-button WITH FRAME Form1.
    ENABLE next-button  prev-button  close-button WITH FRAME Form1.

    run LoadData.
    find first extract_tmp where extract_tmp.debit <> 0 and extract_tmp.credit <> 0 no-lock no-error.
    if not avail extract_tmp then Res = res + "&TREM=За указанный период движения по счету отсутствуют".
    run to_screen("extract1",Res).

    WAIT-FOR endkey of frame Form1.
    hide frame Form1.


procedure LoadData:
    Pos = 1.
    Res = "".
    for each extract_tmp where ind = PosPage by date_doc.
     Res = Res + "&TDATE=" + string(extract_tmp.date_doc, "99.99.9999").
     Res = Res + "&TDEB=" + string(extract_tmp.debit,"->>>>>>>>>>>>>>>>9.99").
     Res = Res + "&TCRED=" + string(extract_tmp.credit,"->>>>>>>>>>>>>>>>9.99").
     Res = Res + "&TREM=" + extract_tmp.rem.
     Res = Res + "&TCONAGENT=" + extract_tmp.conagent.
    end.
    Res = ResDef + Res.
end procedure.

procedure CreateData:

    dt1 = g-today.
    dt2 = g-today.

    define frame MainFrame
    dt1 label ' Период с ' format '99/99/9999'
    dt2 label ' по ' format '99/99/9999'
    with side-labels row 13 centered.

    DISPLAY dt1 dt2  WITH FRAME MainFrame.
    update dt1 dt2 WITH FRAME MainFrame.
    hide frame MainFrame.

    PosPage = 2.
    CurPage = 1.
    Pos = 0.

    for each b-jl where b-jl.jdt >= dt1 and b-jl.jdt <= dt2 and b-jl.acc = v-Acc and b-jl.lev = 1 no-lock:
        if b-jl.lev <> 1 then next.
        if b-jl.rem[1] begins "O/D PROTECT" or b-jl.rem[1] begins "O/D PAYMENT" then next.

        create extract_tmp.

        extract_tmp.date_doc  = b-jl.jdt.
        extract_tmp.debit     = b-jl.dam.
        extract_tmp.credit    = b-jl.cam.

        find first jh where jh.jh = b-jl.jh no-lock no-error.
        if avail jh then do:

            find first bankl where bankl.bank = "TXB00" no-lock no-error .
            if avail bankl then bankname = bankl.name.
            find first cmp no-lock no-error.

            if b-jl.jdt < 05/07/2012 then bankname = replace(bankname,'ForteBank','МЕТРОКОМБАНК'). /* Для алматы */

            if substr(jh.ref,1,3) = "jou" then do:
                find first joudoc where joudoc.docnum = entry(1, jh.ref,"/") no-lock no-error.
                if avail joudoc then do:

                    v-rem = joudoc.rem[1] + joudoc.rem[2].
                    find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
                    if avail joudop then do:
                        if num-entries(joudop.patt, '^') = 4 then
                        extract_tmp.conagent  = entry(4,joudop.patt,'^') + "; " + entry(1, joudop.patt,'^') + "; " + entry(2, joudop.patt,'^') + "; " + "Кбе " + entry(3,joudop.patt,'^').
                        if num-entries(joudop.patt, '^') = 3 then
                        extract_tmp.conagent  = entry(1, joudop.patt,'^') + "; " + entry(2, joudop.patt,'^') + "; " + "Кбе " + entry(3,joudop.patt,'^').
                        if num-entries(joudop.patt, '^') = 2 then
                        extract_tmp.conagent  = entry(1, joudop.patt,'^') + "; " + entry(2, joudop.patt,'^') .
                    end.
                end.
                if trim(extract_tmp.conagent)  = "" then do:
                    find first jl where jl.jh = b-jl.jh and jl.ln = b-jl.ln + 1 no-lock no-error.
                    if avail jl then do:
                        run GetEKNP(jl.jh, jl.ln, jl.dc, input-output KOd, input-output KBe, input-output knp).
                        extract_tmp.conagent =  UrlEncode(string(jl.gl) + "; " + bankname + "; РНН " + cmp.addr[2] + "; Кбе " + KBe).
                        if substr(string(jl.gl),1,1) = "4" then v-remkom = "Комиссия ".
                    end.
                end.
            end.
            else if substr(jh.ref,1,3) = "rmz" then do:
                find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
                if avail remtrz then do:

                    v-rem = trim(remtrz.det[1]) + trim(remtrz.det[2]) + trim(remtrz.det[3]) + trim(remtrz.det[4]).

                    if index(remtrz.bn[3], "/RNN/") <= 0 then TRECINN = "TRECINN=" + substring(remtrz.bn[3],1,12).
                    else TRECINN = "TRECINN=" + substring(remtrz.bn[3],index(remtrz.bn[3], "/RNN/") + 5,12).

                    if remtrz.sbank begins "txb" then do:
                        /* ИИК */
                        extract_tmp.conagent = entry(1,remtrz.ba,"/").
                        /* наименование */
                        extract_tmp.conagent = extract_tmp.conagent + "; " + entry(1,remtrz.bn[1],"/").
                        /* РНН */
                        if num-entries(remtrz.bn[3],'/') = 3 then extract_tmp.conagent = extract_tmp.conagent +  "; " + entry(3,remtrz.bn[3],'/') .
                        else extract_tmp.conagent = extract_tmp.conagent + remtrz.bn[3] .
                        /* Кбе */
                        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                        if avail sub-cod then extract_tmp.conagent = extract_tmp.conagent + "; " + "Кбе " + entry(2,sub-cod.rcode,',').
                    end.
                    else do:
                        /* ИИК */
                        extract_tmp.conagent = remtrz.sacc.

                        /* наименование*/
                        if index(remtrz.ord, "/CHIEF/") >= 0 then
                        extract_tmp.conagent = extract_tmp.conagent + "; " + substr(remtrz.ord,1,  index(remtrz.ord, "/CHIEF/")).
                        else
                        extract_tmp.conagent = extract_tmp.conagent + "; " + remtrz.ord.

                        /* РНН */

                        /* Кбе*/
                        find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                        if avail sub-cod then extract_tmp.conagent = extract_tmp.conagent + "; " + "Кбе " + entry(2,sub-cod.rcode,',').
                    end.
                end.
            end.
            else do:
                find first jl where jl.jh = b-jl.jh and jl.ln = b-jl.ln + 1 no-lock no-error.
                if avail jl then do:
                    run GetEKNP(jl.jh, jl.ln, jl.dc, input-output KOd, input-output KBe, input-output knp).
                    extract_tmp.conagent =  UrlEncode(string(jl.gl) + "; " + bankname + "; РНН " + cmp.addr[2] + "; Кбе " + KBe).
                    if substr(string(jl.gl),1,1) = "4" then v-remkom = "Комиссия ".
                end.
            end.

        end.

        /*v-rem = b-jl.rem[1].
        do i = 1 to 5:
            if b-jl.rem[i] <> ? and trim(b-jl.rem[i]) <> '' and trim(b-jl.rem[i]) <> trim(v-rem) then do:
                if v-rem <> '' then v-rem = v-rem + ' '.
                v-rem = v-rem + b-jl.rem[i].
            end.
        end.*/




        v-rem = UrlEncode(v-rem).

        extract_tmp.rem = UrlEncode(v-remkom + v-rem).
        v-remkom = "".
        v-rem = "".

        extract_tmp.ind = PosPage.
        PosPage = PosPage + 1.
        CurPage = CurPage + 1.
    end.
end procedure.

procedure lonbal3.

    define input  parameter p-sub like trxbal.subled.
    define input  parameter p-acc as char.
    define input  parameter p-dt like jl.jdt.
    define input  parameter p-lvls as char.
    define input  parameter p-includetoday as logi.
    define output parameter t-res as decimal.

    def var i as integer.
    def buffer b-aaa for aaa.

    t-res = 0.

    if p-dt > g-today then p-dt = g-today. /*return.*/

    if p-includetoday then do: /* за дату */
      if p-dt = g-today then do:
         for each trxbal where trxbal.subled = p-sub and trxbal.acc = p-acc no-lock:
             if lookup(string(trxbal.level), p-lvls) > 0 then do:

                find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                if not avail b-aaa then return.

            find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                                and trxlevgl.subled eq p-sub
                                and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
                if not avail trxlevgl then return.

            find gl where gl.gl eq trxlevgl.glr no-lock no-error.
            if not avail gl then return.

            if gl.type eq "A" or gl.type eq "E" then t-res = t-res + trxbal.dam - trxbal.cam.
            else t-res = t-res + trxbal.cam - trxbal.dam.

            find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
                           and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "01" then t-res = - t-res.

            /* ------------------------------------------------------------ */
            for each jl where jl.acc = p-acc
                              and jl.jdt >= p-dt
                              and jl.lev = 1 no-lock:
            if gl.type eq "A" or gl.type eq "E" then t-res = t-res - jl.dam + jl.cam.
                else t-res = t-res + jl.dam - jl.cam.
                end.

             end.
         end.
      end.
      else do:
         do i = 1 to num-entries(p-lvls):
            find last histrxbal where histrxbal.subled = p-sub
                                  and histrxbal.acc = p-acc
                                  and histrxbal.level = integer(entry(i, p-lvls))
                                  and histrxbal.dt <= p-dt no-lock no-error.
            if avail histrxbal then do:
                find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                if not avail b-aaa then return.

            find trxlevgl where trxlevgl.gl     eq b-aaa.gl
                                and trxlevgl.subled eq p-sub
                                and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
                if not avail trxlevgl then return.

            find gl where gl.gl eq trxlevgl.glr no-lock no-error.
            if not avail gl then return.

            if gl.type eq "A" or gl.type eq "E" then t-res = t-res + histrxbal.dam - histrxbal.cam.
            else t-res = t-res + histrxbal.cam - histrxbal.dam.

            find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
                           and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "01" then t-res = - t-res.

            end.
         end.
      end.
    end. /* if p-includetoday */
    else do: /* на дату */
       do i = 1 to num-entries(p-lvls):
           find last histrxbal where histrxbal.subled = p-sub and histrxbal.acc = p-acc and histrxbal.level = integer(entry(i, p-lvls))
                                     and histrxbal.dt < p-dt no-lock no-error.
           if avail histrxbal then do:
                find b-aaa where b-aaa.aaa = p-acc no-lock no-error.
                if not avail b-aaa then return.

            find trxlevgl where trxlevgl.gl eq b-aaa.gl
                                and trxlevgl.subled eq p-sub
                                and lookup(string(trxlevgl.level), p-lvls) > 0 no-lock no-error.
                if not avail trxlevgl then return.

            find gl where gl.gl eq trxlevgl.glr no-lock no-error.
            if not avail gl then return.

            if gl.type eq "A" or gl.type eq "E" then t-res = t-res + histrxbal.dam - histrxbal.cam.
            else t-res = t-res + histrxbal.cam - histrxbal.dam.

            find sub-cod where sub-cod.sub eq "gld" and sub-cod.d-cod eq "gldic"
                           and sub-cod.acc eq string(trxlevgl.glr) no-lock no-error.
            if available sub-cod and sub-cod.ccode eq "01" then t-res = - t-res.

           end.
       end.
    end.
end procedure.