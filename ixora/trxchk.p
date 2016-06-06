/* trxchk.p
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
        29.07.2002 - BY SASCO - обработка параметров, "b", "s" - средневзв. курсы покупки и продажи налом
        26/11/03 nataly добавлена обработка subledger SCU
        11/01/05 sasco проверка на сумму > 0
        18/04/06 nataly добавлена обработка subledger TSF
        28/12/2012 madiyar - счет ГК 000001 разрешен, заменяется на счет конвертации, соответствующий валюте и стороне проводки
*/

def input parameter hrec as recid.
def input parameter crec as recid.
def input parameter vflag as char.
def output parameter rcode as inte initial 100.
def output parameter rdes as char.
def buffer b-trxtmpl for trxtmpl.
def var vcrc as inte.
def var vgl as inte.
def var vfnd as logi.
def var errlist as char extent 30.

errlist[1]  = "Недопустимый номер линии в ссылке.".
errlist[2]  = "Отрицательная сумма не разрешена.".
errlist[3]  = "Неверная ссылка на линию для автоподсчета суммы.".
errlist[4]  = "Указанная валюта не найдена.".
errlist[5]  = "Валюта не разрешена.".
errlist[6]  = "Валюта сабледжера не соответствует валюте проводки.".
errlist[7]  = "Не найден счет ГК".
errlist[8]  = "Счет ГК итоговый! Проводки запрещены.".
errlist[9]  = "Тип субсчетов указанного счета ГК не соответствует типу, требуемому в проводке.".
errlist[10] = "Указанный тип субсчетов не поддерживается.".
errlist[11] = "Не указан тип субсчетов".
errlist[12] = "Счет не соответствует требуемому типу субсчетов.".
errlist[13] = "Счет не найден.".
errlist[14] = "Валюта счета не соответствует валюте проводки.".
errlist[15] = "Счет не соответствут счету ГК.".
errlist[16] = "Счет закрыт.".
errlist[17] = "Флаг не допустим. Допустимые значения a-auto,d-defined,r-request.".
errlist[21] = "Недопустимый статус проводки.".
errlist[28] = "Счет ГК для указанного уровня не определен.".


find trxhead where recid(trxhead) = hrec no-lock.
find trxtmpl where recid(trxtmpl) = crec no-lock.
find sysc where sysc.sysc = "cashgl" no-lock.

/*0.Flag check*/
if vflag <> "empty" then do:
 if     vflag <> "a " and vflag <> "d " and vflag <> "r "
    and vflag <> "1+" and vflag <> "2+" and vflag <> "3+"
    and vflag <> "4+" and vflag <> "5+" and vflag <> "6+"
    and vflag <> "7+" and vflag <> "8+" and vflag <> "9+"
    and vflag <> "1-" and vflag <> "2-" and vflag <> "3-"
    and vflag <> "4-" and vflag <> "5-" and vflag <> "6-"
    and vflag <> "7-" and vflag <> "8-" and vflag <> "9-"
    and vflag <> "1 " and vflag <> "2 " and vflag <> "3 "
    and vflag <> "4 " and vflag <> "5 " and vflag <> "6 "
    and vflag <> "7 " and vflag <> "8 " and vflag <> "9 "
 /* НацБанк */
    and vflag <> "m "
    and vflag <> "1m" and vflag <> "2m" and vflag <> "3m"
    and vflag <> "4m" and vflag <> "5m" and vflag <> "6m"
    and vflag <> "7m" and vflag <> "8m" and vflag <> "9m"
 /* Наличная валюта - курсы */
    and vflag <> "b "  /* покупки */
    and vflag <> "1b" and vflag <> "2b" and vflag <> "3b"
    and vflag <> "4b" and vflag <> "5b" and vflag <> "6b"
    and vflag <> "7b" and vflag <> "8b" and vflag <> "9b"
    and vflag <> "s " /* продажи */
    and vflag <> "1s" and vflag <> "2s" and vflag <> "3s"
    and vflag <> "4s" and vflag <> "5s" and vflag <> "6s"
    and vflag <> "7s" and vflag <> "8s" and vflag <> "9s"
 /*  дублирование суммы */
    and vflag <> "z "
    and vflag <> "1z" and vflag <> "2z" and vflag <> "3z"
    and vflag <> "4z" and vflag <> "5z" and vflag <> "6z"
    and vflag <> "7z" and vflag <> "8z" and vflag <> "9z"

    then do:
      rcode = 17.
      rdes = errlist[rcode].
      return.
 end.
/*0.1.Reference line check.*/
   if substring(vflag,2,1) = "+" or substring(vflag,2,1) = "-" then do:
     find b-trxtmpl where b-trxtmpl.code = trxtmpl.code
      and b-trxtmpl.ln = integer(substring(vflag,1,1)) no-lock no-error.
     if not available b-trxtmpl
        /*or integer(substring(vflag,1,1)) = trxtmpl.ln*/ then do:
        rcode = 1.
        rdes = errlist[rcode].
        return.
     end.
   end.
end.

/*0.2.Status check*/
if trxhead.sts-f = "d" and (trxhead.sts < 0 or trxhead.sts > 6) then do:
         rcode = 21.
         rdes = errlist[rcode].
         return.
end.

/*2.Amount check*/
if trxtmpl.amt-f = "d" and trxtmpl.amt = 0 then do:
         rcode = 2.
         rdes = errlist[rcode].
         return.
end.
if trxtmpl.amt < 0 then do:
         rcode = 2.
         rdes = errlist[rcode].
         return.
end.

/*3.Currency check*/
if trxtmpl.crc-f = "d" then do:
        find crc where crc.crc = trxtmpl.crc no-lock no-error.
        if not available crc then do:
         rcode = 4.
         rdes = errlist[rcode].
         return.
        end.
        if crc.sts = 9 then do:
         rcode = 5.
         rdes = errlist[rcode].
         return.
        end.
/*crc-dracc check*/
        if trxtmpl.dracc <> "" and trxtmpl.dracc-f = "d" then do:
           run trxcrcchk(trxtmpl.drsub,trxtmpl.dracc,output vcrc).
           if vcrc <> trxtmpl.crc and vcrc <> 0 then do:
             rcode = 6.
             rdes = errlist[rcode] + ": dracc, line " + string(trxtmpl.ln,"9").
             return.
           end.
        end.
/*crc-cracc check*/
        if trxtmpl.cracc <> "" and trxtmpl.cracc-f = "d" then do:
           run trxcrcchk(trxtmpl.crsub,trxtmpl.cracc,output vcrc).
           if vcrc <> trxtmpl.crc and vcrc <> 0 then do:
             rcode = 6.
             rdes = errlist[rcode] + ": cracc, line " + string(trxtmpl.ln,"9").
             return.
           end.
        end.
end.

/*4.Debet GL check*/
if trxtmpl.drgl-f = "d" then do:
    if trxtmpl.drgl = 1 then do:
        /*4.5.GL-drsub check*/
        if trxtmpl.drsub-f = "d" then do:
            if trxtmpl.drsub <> "" then do:
              rcode = 9.
              rdes = errlist[rcode].
              return.
            end.
        end.
    end.
    else do:
        find gl where gl.gl = trxtmpl.drgl no-lock no-error.
        if not available gl then do:
         rcode = 7.
         rdes = errlist[rcode].
         return.
        end.
        if gl.totact = yes then do:
         rcode = 8.
         rdes = errlist[rcode].
         return.
        end.
        /*4.5.GL-drsub check*/
        if trxtmpl.drsub-f = "d" then do:
            if gl.subled <> "" and gl.subled <> trxtmpl.drsub then do:
             rcode = 9.
             rdes = errlist[rcode].
             return.
            end.
        end.
   end.
end.

/*5.Debet subledger type check*/
if trxtmpl.drsub-f = "d" then do:
/*        if     trxtmpl.drsub <> "arp"
           and trxtmpl.drsub <> "ast"
           and trxtmpl.drsub <> "cif"
           and trxtmpl.drsub <> "dfb"
           and trxtmpl.drsub <> "eps"
           and trxtmpl.drsub <> "fun"
           and trxtmpl.drsub <> "lcr"
           and trxtmpl.drsub <> "lon"
           and trxtmpl.drsub <> "ock"
           and trxtmpl.drsub <> "   " then do:*/
   find trxsub where trxsub.subled = trxtmpl.drsub no-lock no-error.
     if not available trxsub and trxtmpl.drsub <> "   " then do:
         rcode = 10.
         rdes = errlist[rcode].
         return.
     end.
end.

/*6.Acc check*/
if trxtmpl.dracc-f = "d" then do:
   if trxtmpl.drsub-f <> "d" then do:
      rcode = 11.
      rdes = errlist[rcode].
      return.
   end.
   if trxtmpl.drsub = "" and trxtmpl.dracc <> "" then do:
      rcode = 12.
      rdes = errlist[rcode].
      return.
   end.
   if trxtmpl.drsub <> "" then do:
      rcode = 0.
   run trxaccchk(trxtmpl.drsub,trxtmpl.dracc,trxtmpl.dev,output vfnd,output vgl).
   if rcode = 28 then return.
   if vfnd = false then do:
      rcode = 13.
      rdes = errlist[rcode] + ": dracc = " + trxtmpl.dracc
           + ",line " + string(trxtmpl.ln,"9").
      return.
   end.
   else if vgl <> trxtmpl.drgl and trxtmpl.drgl-f = "d" then do:
      rcode = 15.
      rdes = errlist[rcode] + ": dracc = " + trxtmpl.dracc
           + ", drgl = " + string(trxtmpl.drgl,"999999")
           + ",line " + string(trxtmpl.ln,"9").
      return.
   end.
   end.
end.

/*7.Credit GL check*/
if trxtmpl.crgl-f = "d" then do:
    if trxtmpl.crgl = 1 then do:
        /*4.5.GL-drsub check*/
        if trxtmpl.crsub-f = "d" then do:
            if trxtmpl.crsub <> "" then do:
              rcode = 9.
              rdes = errlist[rcode].
              return.
            end.
        end.
    end.
    else do:
        find gl where gl.gl = trxtmpl.crgl no-lock no-error.
        if not available gl then do:
         rcode = 7.
         rdes = errlist[rcode].
         return.
        end.
        if gl.totact = yes then do:
         rcode = 8.
         rdes = errlist[rcode].
         return.
        end.
       /*4.5.GL-crsub check*/
       if trxtmpl.crsub-f = "d" then do:
            if gl.subled <> "" and gl.subled <> trxtmpl.crsub then do:
             rcode = 9.
             rdes = errlist[rcode].
             return.
            end.
       end.
   end.
end.

/*8.Debet subledger type check*/
if trxtmpl.crsub-f = "d" then do:
/*        if     trxtmpl.crsub <> "arp"
           and trxtmpl.crsub <> "ast"
           and trxtmpl.crsub <> "cif"
           and trxtmpl.crsub <> "dfb"
           and trxtmpl.crsub <> "eps"
           and trxtmpl.crsub <> "fun"
           and trxtmpl.crsub <> "lcr"
           and trxtmpl.crsub <> "lon"
           and trxtmpl.crsub <> "ock"
           and trxtmpl.crsub <> "   " then do:*/
   find trxsub where trxsub.subled = trxtmpl.crsub no-lock no-error.
     if not available trxsub and trxtmpl.crsub <> "   " then do:
         rcode = 10.
         rdes = errlist[rcode].
         return.
     end.
end.

/*9.Acc check*/
if trxtmpl.cracc-f = "d" then do:
   if trxtmpl.crsub-f <> "d" then do:
      rcode = 11.
      rdes = errlist[rcode].
      return.
   end.
   if trxtmpl.crsub = "" and trxtmpl.cracc <> "" then do:
      rcode = 12.
      rdes = errlist[rcode].
      return.
   end.
   if trxtmpl.crsub <> "" then do:
      rcode = 0.
   run trxaccchk(trxtmpl.crsub,trxtmpl.cracc,trxtmpl.cev,output vfnd,output vgl).
   if rcode = 28 then return.
   if vfnd = false then do:
      rcode = 13.
      rdes = errlist[rcode] + ": cracc = " + trxtmpl.cracc
           + ",line " + string(trxtmpl.ln,"9").
      return.
   end.
   else if vgl <> trxtmpl.crgl and trxtmpl.crgl-f = "d" then do:
      rcode = 15.
      rdes = errlist[rcode] + ": cracc = " + trxtmpl.cracc
           + ", crgl = " + string(trxtmpl.crgl,"999999")
           + ", line " + string(trxtmpl.ln,"9").
      return.
   end.
   end.
end.

rcode = 0.
rdes = "".

/*************************Procedures***************************/
/**************************************************************/
PROCEDURE trxcrcchk.
def input parameter vsub as char.
def input parameter vacc as char.
def output parameter vcrc as inte initial 0.
if vsub = "arp" then do: /*1)*/
   find arp where arp.arp = vacc no-lock no-error.
   if available arp then vcrc = arp.crc.
end.
else if vsub = "ast" then do: /*2)*/
   find ast where ast.ast = vacc no-lock no-error.
   if available ast then vcrc = ast.crc.
end.
else if vsub = "cif" then do: /*3)*/
   find aaa where aaa.aaa = vacc no-lock no-error.
   if available aaa then vcrc = aaa.crc.
end.
else if vsub = "dfb" then do: /*4)*/
   find dfb where dfb.dfb = vacc no-lock no-error.
   if available dfb then vcrc = dfb.crc.
end.
else if vsub = "eps" then do: /*5)*/
   find eps where eps.eps = vacc no-lock no-error.
   if available eps then vcrc = eps.crc.
end.
else if vsub = "fun" then do: /*6)*/
   find fun where fun.fun = vacc no-lock no-error.
   if available fun then vcrc = fun.crc.
end.
else if vsub = "scu" then do: /*6)*/ /*26/11/03 nataly*/
   find scu where scu.scu = vacc no-lock no-error.
   if available scu then vcrc = scu.crc.
end.                                /*26/11/03 nataly*/
else if vsub = "tsf" then do: /*6)*/ /*18/04/06 nataly*/
   find tsf where tsf.tsf = vacc no-lock no-error.
   if available tsf then vcrc = tsf.crc.
end.                                /*18/04/06 nataly*/
else if vsub = "lcr" then do: /*7)*/
   find lcr where lcr.lcr = vacc no-lock no-error.
   if available lcr then vcrc = lcr.crc.
end.
else if vsub = "lon" then do: /*8)*/
   find lon where lon.lon = vacc no-lock no-error.
   if available lon then vcrc = lon.crc.
end.
else if vsub = "ock" then do: /*9)*/
   find ock where ock.ock = vacc no-lock no-error.
   if available ock then vcrc = ock.crc.
end.
else if vsub = "pcr" then do: /*9)*/
   vcrc = 0.
end.
END procedure.

PROCEDURE trxaccchk.
def input parameter vsub as char.
def input parameter vacc as char.
def input parameter vlev as inte.
def output parameter vfnd as logi initial false.
def output parameter vgl as inte initial 0.
if vsub = "arp" then do: /*9)*/
   find arp where arp.arp = vacc no-lock no-error.
   if available arp then do:
    if vlev = 1 then vgl = arp.gl.
    else do:
     find trxlevgl where trxlevgl.gl = arp.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(arp.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "ast" then do: /*2)*/
   find ast where ast.ast = vacc no-lock no-error.
   if available ast then vgl = ast.gl.
   else return.
end.
else if vsub = "cif" then do: /*9)*/
   find aaa where aaa.aaa = vacc no-lock no-error.
   if available aaa then do:
    if aaa.sta = "C" then return.
    if vlev = 1 then vgl = aaa.gl.
    else do:
     find trxlevgl where trxlevgl.gl = aaa.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(aaa.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "dfb" then do: /*4)*/
   find dfb where dfb.dfb = vacc no-lock no-error.
   if available dfb then vgl = dfb.gl.
   else return.
end.
else if vsub = "eps" then do: /*9)*/
   find eps where eps.eps = vacc no-lock no-error.
   if available eps then do:
    if vlev = 1 then vgl = eps.gl.
    else do:
     find trxlevgl where trxlevgl.gl = eps.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(eps.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "fun" then do: /*9)*/
   find fun where fun.fun = vacc no-lock no-error.
   if available fun then do:
    if vlev = 1 then vgl = fun.gl.
    else do:
     find trxlevgl where trxlevgl.gl = fun.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(fun.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "scu" then do: /*9)*/ /*26/11/02 nataly*/
   find scu where scu.scu = vacc no-lock no-error.
   if available scu then do:
    if vlev = 1 then vgl = scu.gl.
    else do:
     find trxlevgl where trxlevgl.gl = scu.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(scu.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "tsf" then do: /*9)*/ /*18/04/06 nataly*/
   find tsf where tsf.tsf = vacc no-lock no-error.
   if available tsf then do:
    if vlev = 1 then vgl = tsf.gl.
    else do:
     find trxlevgl where trxlevgl.gl = tsf.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(tsf.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.                                /*18/04/06 nataly*/
else if vsub = "lcr" then do: /*7)*/
   find lcr where lcr.lcr = vacc no-lock no-error.
   if available lcr then vgl = lcr.gl.
   else return.
end.
else if vsub = "lon" then do: /*8)*/
   find lon where lon.lon = vacc no-lock no-error.
   if available lon then vgl = lon.gl.
   else return.
end.
else if vsub = "ock" then do: /*9)*/
   find ock where ock.ock = vacc no-lock no-error.
   if available ock then do:
    if vlev = 1 then vgl = ock.gl.
    else do:
     find trxlevgl where trxlevgl.gl = ock.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; Г/К(1) = " + string(ock.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "pcr" then do: /*8)*/
     vgl = 0.
end.
vfnd = true.
END.
