/* trxchk1.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        26/11/03 nataly добавлена обработка subledger SCU
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       16.03.2004 nataly добавила создание записей aad - доп взносы по депозитам
       20.05.2004 nadejda - добавлен параметр номера счета в вызов tdagetrate
                            сообщения переведены на русский язык
       09.08.2004 dpuchkov - Изменил откат процентов в соответствии с текущей % ставкой
       24.08.2004 dpuchkov - поправил поиск групп соответствия
       30.09.2004 dpuchkov - добавил заполнение полей в aad и ограничение на доп доп взнос < 90 дней(по Звезде)
       12.10.2004 dpuchkov - добавил поле sumg в таблицу aad (для хранения сумм остатков при частичн изъятиях)
       26.11.2004 dpuchkov - убрал проверку если дату проводки не совпадает с договорной датой депозита согласно ТЗ
                             дата открытия нового депозита при конвертации должна быть равна дате открытия конвертируемого счёта.
       11/01/05 sasco проверка на сумму > 0
       19.01.2005 dpuchkov - добавил ограничение на пополнение депозитных счетов(по кот не предусмотрены взносы) в течении срока действия депозита.
       13.04.2005 dpuchkov - добавил исключение lgr.feensf = 7
       14.04.2005 dpuchkov - при конвертации отключил проверку на 90 дней до окончания срока т.к конвертация производится в
                             любой период действия депозита.
        18/04/06 nataly добавлена обработка subledger TSF
        13/01/2011 evseev - доп.взносы на депозит Недропользователь 518,519,520
        23/05/2011 evseev - делаем запись по доп взносам в таблицу aad если lgr.feensf = 6
        20.05.2013 evseev - tz1828
        24.05.2013 evseev - tz-1844
        11.06.2013 evseev - tz-1866
        05/07/2013 Sayat(id01143) - ТЗ 1954 от 05/07/2013 разрешить порождение проводок с закрытыми субсчетами LON по уровням провизий (6,36,37,38,39,40,41)
        09.09.2013 evseev - tz-1685
        14/11/2013 Sayat(id01143) - ТЗ 2084 от 10/09/2013 разрешить порождение проводок с закрытыми субсчетами LON по уровням комиисии (42,31)
*/

def shared var g-today as date.
def shared var g-ofc as char.

def output parameter rcode as inte initial 100.
def output parameter rdes as char.
def shared temp-table tmpl like trxtmpl.
def shared temp-table cdf like trxcdf.
def var errlist as char extent 50.
def var vcrc as inte.
def var vgl as inte.
def var vfnd as logi.
def var v-val as char.
def shared var hsts as inte.

def var vrate as decimal.
def var prd as integer.
def var v-tmppri like aaa.pri.
def var l-newlgr as logical init false.
def buffer buflgr FOR lgr.
define buffer sysc-star   for sysc.
define buffer sysc-zvezda for sysc.
define buffer sysc-juldiz for sysc.
find last sysc-star   where sysc-star.sysc   = "STAR"   no-lock no-error.
find last sysc-zvezda where sysc-zvezda.sysc = "ZVEZDA" no-lock no-error.
find last sysc-juldiz where sysc-juldiz.sysc = "JULDIZ" no-lock no-error.

def var i as int.
def var v-countday as int.


find sysc where sysc.sysc = "cashgl" no-lock.
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
errlist[50] = "Неверный код справочника.".



Function GetPrlngDate returns date(input dt1 as date, input mon as integer).
  def var dt_prlng as date.
  def var years as inte initial 0.
  def var months as inte initial 0.
  def var days as inte.

  days = day(dt1).
  years = integer(mon / 12 - 0.5).
  months = mon - years * 12.
  months = months + month(dt1).
  if months > 12 then do:
    years = years + 1.
    months = months - 12.
  end.
  if month(dt1) <> month(dt1 + 1) then do:
      months = months + 1.
      if months = 13 then do:
         months = 1.
         years = years + 1.
      end.
      days = 1.
   end.
   /* nataly - если выпадает 29.02.yyyy то дата меняется на 01.03.yyyy */
   if months = 2 and days = 29
      and  (( (year(dt1) + years) - 2000) modulo 4) <> 0 then do:
      months = 3.  days = 1.  end.
   /* nataly ------------------ */
   dt_prlng  = date(months, days, year(dt1) + years).
   if month(dt1) <> month(dt1 + 1) then dt_prlng = dt_prlng - 1.
   return dt_prlng.
End Function.





/*0.2.Status check*/
if hsts < 0 or hsts > 6 then do:
         rcode = 21.
         rdes = errlist[rcode] + ":Стс=" + string(hsts).
         return.
end.

for each tmpl:

/*2.Amount check*/
/*
if tmpl.amt-f = "d" and tmpl.amt = 0 then do:
         rcode = 2.
         rdes = errlist[rcode].
         return.
end.
*/
if tmpl.amt < 0 then do:
         rcode = 2.
         rdes = errlist[rcode].
         return.
end.

/*3.Currency check*/
if tmpl.crc-f = "d" then do:
        find crc where crc.crc = tmpl.crc no-lock no-error.
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
        if tmpl.dracc <> "" and tmpl.dracc-f = "d" then do:
           find gl where gl.gl = tmpl.drgl no-lock.
           run trxcrcchk(tmpl.drsub,tmpl.dracc,output vcrc).
           if
             ( tmpl.dev = 1 and vcrc <> tmpl.crc )
             and gl.subled <> "" and vcrc <> 0 then do:
             rcode = 6.
             rdes = errlist[rcode] + ": счет дебета, линия " + string(tmpl.ln,"99").
             return.
           end.
        end.
/*crc-cracc check*/
        if tmpl.cracc <> "" and tmpl.cracc-f = "d" then do:
           find gl where gl.gl = tmpl.crgl no-lock.
           run trxcrcchk(tmpl.crsub,tmpl.cracc,output vcrc).
           if   ( tmpl.cev = 1 and vcrc <> tmpl.crc )
           and gl.subled <> "" and vcrc <> 0 then do:
             rcode = 6.
             rdes = errlist[rcode] + ": счет кредита, линия " + string(tmpl.ln,"99").
             return.
           end.
        end.
end.

/*4.Debet GL check*/
if tmpl.drgl-f = "d" then do:
        find gl where gl.gl = tmpl.drgl no-lock no-error.
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
        run trxaccchk("gld",tmpl.drgl,tmpl.dev,output vfnd,output vgl).
        if rcode = 16 then return.
/*4.5.GL-drsub check*/
   if tmpl.drsub-f = "d" then do:
        if gl.subled <> "" and gl.subled <> tmpl.drsub then do:
         rcode = 9.
         rdes = errlist[rcode].
         return.
        end.
   end.
end.

/*5.Debet subledger type check*/
if tmpl.drsub-f = "d" then do:
/*        if     tmpl.drsub <> "arp"
           and tmpl.drsub <> "ast"
           and tmpl.drsub <> "cif"
           and tmpl.drsub <> "dfb"
           and tmpl.drsub <> "eps"
           and tmpl.drsub <> "fun"
           and tmpl.drsub <> "lcr"
           and tmpl.drsub <> "lon"
           and tmpl.drsub <> "ock"
           and tmpl.drsub <> "   " then do:*/
   find trxsub where trxsub.subled = tmpl.drsub no-lock no-error.
     if not available trxsub and tmpl.drsub <> "   " then do:
         rcode = 10.
         rdes = errlist[rcode].
         return.
     end.
end.

/*6.Debet acc check*/
if tmpl.dracc-f = "d" then do:
   if tmpl.drsub-f <> "d" then do:
      rcode = 11.
      rdes = errlist[rcode].
      return.
   end.
   if tmpl.drsub = "" and tmpl.dracc <> "" then do:
      rcode = 12.
      rdes = errlist[rcode].
      return.
   end.
   if tmpl.drsub <> "" then do:
      rcode = 0.
   run trxaccchk(tmpl.drsub,tmpl.dracc,tmpl.dev,output vfnd,output vgl).
   if rcode = 28 or rcode = 16 then return.
   if vfnd = false then do:
      rcode = 13.
      rdes = errlist[rcode] + ": счет дебета = " + tmpl.dracc
           + ",линия " + string(tmpl.ln,"99").
      return.
   end.
   else if vgl <> tmpl.drgl and tmpl.drgl-f = "d" and vgl <> 0 then do:
      rcode = 15.
      rdes = errlist[rcode] + ": счет кредита = " + tmpl.dracc
           + ", счет ГК дебета = " + string(tmpl.drgl,"999999")
           + ",линия " + string(tmpl.ln,"99").
      return.
   end.
   end.
end.

/*4.Credit GL check*/
if tmpl.crgl-f = "d" then do:
        find gl where gl.gl = tmpl.crgl no-lock no-error.
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
      run trxaccchk("gld",tmpl.crgl,tmpl.dev,output vfnd,output vgl).
      if rcode = 16 then return.

/*4.5.GL-crsub check*/
   if tmpl.crsub-f = "d" then do:
        if gl.subled <> "" and gl.subled <> tmpl.crsub then do:
         rcode = 9.
         rdes = errlist[rcode].
         return.
        end.
   end.
end.

/*5.Debet subledger type check*/
if tmpl.crsub-f = "d" then do:
/*        if     tmpl.crsub <> "arp"
           and tmpl.crsub <> "ast"
           and tmpl.crsub <> "cif"
           and tmpl.crsub <> "dfb"
           and tmpl.crsub <> "eps"
           and tmpl.crsub <> "fun"
           and tmpl.crsub <> "lcr"
           and tmpl.crsub <> "lon"
           and tmpl.crsub <> "ock"
           and tmpl.crsub <> "   " then do*/
   find trxsub where trxsub.subled = tmpl.crsub no-lock no-error.
     if not available trxsub and tmpl.crsub <> "   " then do:
         rcode = 10.
         rdes = errlist[rcode].
         return.
     end.
end.

/*9.Credit acc check*/
if tmpl.cracc-f = "d" then do:
   if tmpl.crsub-f <> "d" then do:
      rcode = 11.
      rdes = errlist[rcode].
      return.
   end.
   if tmpl.crsub = "" and tmpl.cracc <> "" then do:
      rcode = 12.
      rdes = errlist[rcode].
      return.
   end.
     rcode = 0.
   if tmpl.crsub <> "" then do:
   run trxaccchk(tmpl.crsub,tmpl.cracc,tmpl.cev,output vfnd,output vgl).
   if rcode = 28 or rcode = 16 then return.
   if vfnd = false then do:
      rcode = 13.
      rdes = errlist[rcode] + ": счет кредита = " + tmpl.cracc
           + ",линия " + string(tmpl.ln,"99").
      return.
   end.
   else if vgl <> tmpl.crgl and tmpl.crgl-f = "d" and vgl <> 0 then do:
      rcode = 15.
      rdes = errlist[rcode] + ": счет кредита = " + tmpl.cracc
           + ", счет ГК кредита = " + string(tmpl.crgl,"999999")
           + ",линия " + string(tmpl.ln,"99").
      return.
   end.
   end.
end.

/*10.TDA Accounts Special Check */
if tmpl.crsub = "cif" and tmpl.cev = 1
   and not (tmpl.drsub = "cif" and tmpl.cracc = tmpl.dracc) then do:
   find aaa where aaa.aaa = tmpl.cracc no-lock.
   find lgr where lgr.lgr = aaa.lgr no-lock.
   if lgr.led = "CDA" then do:
      if g-today <> aaa.regdt then do:
      if lookup(lgr.lgr, "478,479,480,481,482,483,484,485,486,487,488,489,518,519,520,B01,B02,B03,B04,B05,B06,B07,B08,B09,B10,B11,B15,B16,B17,B18,B19,B20") <> 0 then do:
          v-countday = 3.
          do i = 1 to 3:
            if weekday(aaa.regdt + i) = 1 then v-countday = v-countday + 1.
            if weekday(aaa.regdt + i) = 7 then v-countday = v-countday + 1.
            find first hol where hol.hol = aaa.regdt + i no-lock no-error.
            if avail hol then v-countday = v-countday + 1.
          end.
          if g-today - aaa.regdt > v-countday then do:
              if lookup(lgr.lgr, "478,479,480,481,482,483") <> 0 then do:
                 rcode = 66.
                 rdes = "Дополнительные взносы на счета срочных депозитов группы " + lgr.lgr + " не предусмотрены.".
                 return.
              end.
              if lookup(lgr.lgr, "B01,B02,B03,B04,B05,B06,B07,B08") <> 0 then do:
                 rcode = 66.
                 rdes = "Дополнительные взносы на счета депозитов Forte Profitable группы " + lgr.lgr + " не предусмотрены.".
                 return.
              end.
              if lookup(lgr.lgr, "B15,B16,B17,B18,B19,B20") <> 0 then do:
                 rcode = 66.
                 rdes = "Дополнительные взносы на счета депозитов Forte Maximum группы " + lgr.lgr + " не предусмотрены.".
                 return.
              end.
          end.

          find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
          if not avail acvolt then do:
             rcode = 18.
             rdes = "Депозит открыт с ошибками: Взносы запрещены".
             return.
          end.

           /*        if aaa.expdt - g-today < 31 then do: */
          if date(acvolt.x3) - g-today < 31 then do:
             rcode = 18.
             rdes = "До окончания срока депозита осталось менее 30 дней".
             return.
          end.


             create aad.
             assign aad.aaa = aaa.aaa
                    aad.gl = aaa.gl
                    aad.lgr = aaa.lgr
                    aad.crc = aaa.crc
                    aad.regdt = g-today
                    aad.cam = tmpl.amt.
                    aad.who = g-ofc.
                    aad.rem = 'true'.
                    aad.sum = tmpl.amt.
                    aad.sumg = tmpl.amt.
                    aad.pri = lgr.pri.
                    aad.k = 0.

                    prd = truncate(((aaa.expdt - g-today) / 30), 0).

                    aad.rate = aaa.rate.


        end.
      end.
   end.

   if lgr.led = "TDA" then do:
      find crc where crc.crc = aaa.crc no-lock.

      if aaa.cr[1] = 0 and tmpl.amt > 0 then do:
       /*if g-today <> aaa.regdt  and tmpl.amt > 0 then do: */

        /*  if aaa.opnamt <> tmpl.amt then do:
            rcode = 64.
            rdes = "Договорная сумма срочного депозита " + tmpl.cracc
                  + " не равна сумме проводки. Проводка невозможна.".
            return.
         end. */
        /* else*/
          /*
          if g-today <> aaa.lstmdt then do:
            rcode = 65.
            rdes = "Дата проводки не совпадает с договорной датой начала "
                 + "срочного депозита " + tmpl.cracc + ".".
            return.
         end.
         */
      end.
      else do:
            if g-today <> aaa.regdt then do:
              if lgr.tlimit[2] = 0 then do:
                 rcode = 66.
                 rdes = "Дополнительные взносы на счета срочных депозитов группы "
                      + lgr.lgr + " не предусмотрены.".
                 return.
              end.
              else
                if tmpl.amt < lgr.tlimit[2] then do:
                    rcode = 67.
                    rdes = "Сумма дополнительных взносов на счета срочных депозитов группы "
                         + lgr.lgr + " должна быть не менее "
                         + trim(string(lgr.tlimit[2],">>>>>>.99"))
                         + " " + crc.code + ".".
                    return.
                end.
            end.
      end. /*else*/
    /*делаем запись по доп взносам в таблицу aad*/

    def buffer bfsumjl for jl.
    def var d_opnamtd as decimal.
    def var i_mk as integer.

      if (lgr.feensf = 2 or lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 5 or lgr.feensf = 7  or lgr.feensf = 6 or lookup(lgr.lgr, "A38,A39,A40") > 0) and g-today <> aaa.regdt then do:
        if tmpl.amt <> 0 then do:
             find last t-cnv where t-cnv.aaa = aaa.aaa no-lock no-error.
             if lgr.feensf = 2 and aaa.expdt - g-today < 93 and not avail t-cnv then do:
                 rcode = 18.
                 rdes = "До окончания срока депозита осталось менее 3 месяцев".
                 return.
             end.

             if (lgr.feensf = 3 or lgr.feensf = 5 or lgr.feensf = 6 or lookup(lgr.lgr, "A38,A39,A40") > 0) and not avail t-cnv then do:
                find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                if not avail acvolt then do:
                   rcode = 18.
                   rdes = "Депозит открыт с ошибками: Взносы запрещены!".
                   return.
                end. else do:
                    run Get_Month_End(date(acvolt.x1), g-today, date(acvolt.x3),  output i_mk).
                    if i_mk = 0 then do:
                       rcode = 18.
                       rdes = "До окончания срока депозита осталось меньше 1 месяца".
                       return.
                    end.
                end.
             end.


             if (lgr.feensf = 2) and not avail t-cnv then do:
                find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
                if not avail acvolt then do:
                   rcode = 18.
                   rdes = "Депозит открыт с ошибками: Взносы запрещены!".
                   return.
                end.
                else do:
                    run Get_Month_End(date(acvolt.x1), g-today, date(acvolt.x3),  output i_mk).
                    if i_mk = 2 then do:
                       rcode = 18.
                       rdes = "До окончания срока депозита осталось меньше 3 месяцев!".
                       return.
                    end.
                end.
             end.


             create aad.
             assign aad.aaa = aaa.aaa
                    aad.gl = aaa.gl
                    aad.lgr = aaa.lgr
                    aad.crc = aaa.crc
                    aad.regdt = g-today
                    aad.cam = tmpl.amt.
                    aad.who = g-ofc.
                    aad.rem = 'true'.
                    aad.sum = tmpl.amt.
                    aad.sumg = tmpl.amt.
                    aad.pri = lgr.pri.
                    aad.k = (truncate(((aaa.expdt - aaa.regdt + 1) / 30),0) * 30) / (aaa.expdt - aaa.regdt).

               prd = truncate(((aaa.expdt - g-today) / 30), 0).

              /*
                if l-newlgr then
                   run tdagetrate(aaa.aaa, buflgr.pri, prd, g-today, tmpl.amt, output vrate).
                else
                   run tdagetrate(aaa.aaa, aaa.pri, prd, g-today, tmpl.amt, output vrate).
                aad.rate = vrate. */
                aad.rate = aaa.rate.

                l-newlgr = False.
         end.
      end.
   end. /* TDA         */
end.    /* main circle */

/*11.Check Codes*/
for each cdf where cdf.trxln = tmpl.ln:
  if cdf.drcod-f = "d" then do:
    if cdf.drcod = "" or cdf.drcod = ? or cdf.drcod = "msc" then do:
      rcode = 50.
      rdes = errlist[rcode] + ": Справочник=" + cdf.codfr + ", код дебета ="
                            + cdf.drcod + ", линия=" + string(tmpl.ln,"99").
      return.
    end.
    else do:
      find codfr where codfr.codfr = cdf.codfr
                   and codfr.code = cdf.drcod no-lock no-error.
      if not available codfr then do:
        rcode = 50.
        rdes = errlist[rcode] + ": Справочник=" + cdf.codfr + ", код дебета ="
                              + cdf.drcod + ", линия=" + string(tmpl.ln,"99").
        return.
      end.
    end.
  end.
  if cdf.crcode-f = "d" then do:
    if cdf.crcod = "" or cdf.crcod = ? or cdf.crcod = "msc" then do:
      rcode = 50.
      rdes = errlist[rcode] + ": Справочник=" + cdf.codfr + ", код кредита ="
                            + cdf.drcod + ", линия=" + string(tmpl.ln,"99").
      return.
    end.
    else do:
      find codfr where codfr.codfr = cdf.codfr
                   and codfr.code = cdf.crcod no-lock no-error.
      if not available codfr then do:
        rcode = 50.
        rdes = errlist[rcode] + ": Справочник=" + cdf.codfr + ", код кредита ="
                              + cdf.drcod + ", линия=" + string(tmpl.ln,"99").
        return.
      end.
    end.
  end.
end. /*for each cdf*/

end. /*for each tmpl*/

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
else if vsub = "scu" then do: /*7)*/  /*26/11/03 nataly*/
   find scu where scu.scu = vacc no-lock no-error.
   if available scu then vcrc = scu.crc.
end. /*26/11/03 nataly*/
else if vsub = "tsf" then do: /*7)*/  /*18/04/06 nataly*/
   find tsf where tsf.tsf = vacc no-lock no-error.
   if available tsf then vcrc = tsf.crc.
end. /*18/04/06 nataly*/
else if vsub = "lcr" then do: /*8)*/
   find lcr where lcr.lcr = vacc no-lock no-error.
   if available lcr then vcrc = lcr.crc.
end.
else if vsub = "lon" then do: /*9)*/
   find lon where lon.lon = vacc no-lock no-error.
   if available lon then vcrc = lon.crc.
end.
else if vsub = "ock" then do: /*10)*/
   find ock where ock.ock = vacc no-lock no-error.
   if available ock then vcrc = ock.crc.
end.
else if vsub = "pcr" then do: /*11)*/
   vcrc = 0.
end.
END procedure.

PROCEDURE trxaccchk.
def input parameter vsub as char.
def input parameter vacc as char.
def input parameter vlev as inte.
def output parameter vfnd as logi initial false.
def output parameter vgl as inte.
/*Sayat*/
def var v-iskl as logi initial false.
if vsub = 'lon' and lookup(string(vlev),'6,36,37,38,39,40,41,42,31') <> 0 then v-iskl = true.
/*Sayat*/
find first sub-cod where sub-cod.sub = vsub and sub-cod.acc = vacc
 and sub-cod.d-cod = "clsa" and ccode ne "msc" and not(v-iskl) no-lock no-error . /*Sayat*/
  if avail sub-cod then do:
    find first codfr where codfr.codfr = sub-cod.d-cod and
      codfr.code = sub-cod.ccode no-lock no-error .
      if avail codfr then do:
        rcode = 16.
        rdes = errlist[rcode] + " Тип субсчетов = " + vsub +
         " счет = " + vacc + ", " + codfr.name[1] .
        vfnd = true.
        return.
      end.
  end.
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(arp.gl,"999999") + ".".      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "ast" then do: /*2)*/
   find ast where ast.ast = vacc no-lock no-error.
   if available ast then do:
       if vlev = 1 then vgl = ast.gl .
    else do:
     find trxlevgl where trxlevgl.gl = ast.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
      + string(vlev,"z9") + "; счет ГК (1) = " + string(ast.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return .
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(aaa.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "dfb" then do: /*4)*/
   find dfb where dfb.dfb = vacc no-lock no-error.
   if available dfb then do:
       if vlev = 1 then vgl = dfb.gl.
     else do:
     find trxlevgl where trxlevgl.gl = dfb.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
       + string(vlev,"z9") + "; счет ГК (1) = " + string(dfb.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return .
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(eps.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "lcr" then do: /*7)*/
   find lcr where lcr.lcr = vacc no-lock no-error.
   if available lcr then vgl = lcr.gl.
   else return.
end.
else if vsub = "lon" then do: /*8)*/
   find lon where lon.lon = vacc no-lock no-error.
   if available lon then do:
     if vlev = 1 then vgl = lon.gl.
    else do:
     find trxlevgl where trxlevgl.gl = lon.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
       + string(vlev,"z9") + "; счет ГК (1) = " + string(lon.gl,"999999") + ".".      vfnd = true.
      return.
     end.
    end.
   end.
   else return .
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(ock.gl,"999999") + ".".
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(fun.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.
else if vsub = "scu" then do: /*9)*/ /*26/11/03 nataly*/
   find scu where scu.scu = vacc no-lock no-error.
   if available scu then do:
    if vlev = 1 then vgl = scu.gl.
    else do:
     find trxlevgl where trxlevgl.gl = scu.gl
                     and trxlevgl.level = vlev no-lock no-error.
     if available trxlevgl then vgl = trxlevgl.glr.
     else do:
      rcode = 28.
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(scu.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.                               /*26/11/03 nataly*/
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
      rdes = errlist[rcode] + " Тип субсчетов = " + vsub + "; уровень = "
           + string(vlev,"z9") + "; счет ГК (1) = " + string(tsf.gl,"999999") + ".".
      vfnd = true.
      return.
     end.
    end.
   end.
   else return.
end.                               /*18/04/06 nataly*/
else if vsub = "pcr" then do: /*8)*/
     vgl = 0.
end.
vfnd = true.
END procedure.






Procedure Get_Month_End.

   def input parameter a_start as date.
   def input parameter a_now as date.
   def input parameter e_date as date.
   def output parameter out_month as integer.


   def var vterm as inte.
   def var e_refdate as date.
   def var e_displdate as date.
   def var t_date as date.
   def var years as inte initial 0.
   def var months as inte initial 0.
   def var days as inte initial 0.

   def var t-years as inte initial 0.
   def var t-months as inte initial 0.
   def var t-days as inte initial 0.

   def var i as integer init -1.


     vterm = 1.
     t_date = a_start.


if a_start = a_now then i = 0.

     repeat:

       days = day(a_start).
       years = integer(vterm / 12 - 0.5).
       months = vterm - years * 12.
       months = months + month(t_date).
       if months > 12 then do:
         years = years + 1.
         months = months - 12.
       end.
       /*Если счет открыт в последний день месяца но не в феврале*/
       if (month(a_start) <> month(a_start + 1)) and month(a_start) <> 2 then do:
          t-years = years.
          t-months = months + 1.
          if t-months = 13 then do:
             t-months = 1.
             t-years = years + 1.
          end.
          t-days = 1.

          if months <> 2 then do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years) - 2.
          end.
          else do:
             e_displdate = date(t-months, t-days, year(t_date) + t-years).
          end.
       end.

       else
       /*Если счет открыт 1-го числа*/
       if day(a_start) = 1 then do: /*Если Дата открытия 1 числа*/
          if months <> 3 then
             e_displdate = date(months, days, year(t_date) + years) - 1.
          else
             e_displdate = date(months, days, year(t_date) + years).
       end.
       else
       /*Если счет открыт не первого и не последнего */
       do: /*обычная дата*/
          if months = 2 and (days = 29 or days = 30 or days = 31) then
          do:
             months = 3. days = 2.
          end.

          days = days - 1.
          e_displdate = date(months, days, year(t_date) + years).
       end.


       if e_displdate > e_date then do:
          if i < 0 then  i = 0.
          out_month = i.
          return.
       end.

      if e_displdate + 1 >= a_now then do: /*начало отсчета*/
         i = i + 1.
      end.





       t_date = date(months, 15, year(t_date) + years).
     end.  /*repeat*/


End procedure.












