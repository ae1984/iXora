/* aaa-aasm.p
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
        01.10.2004 sasco Если есть запись в sysc."AASDEL" формат:
                         "профитцентр1:логин,логин,и.т.д.|профитцентр2:логин,логин,и.т.д.|и.т.д."
                         то если профицентр совпал с одним из списка, то удалять могут только
                         перечисленные в списке менеджеры
        06.10.2004 saltanat Если спец.инструкция наложена плат.карточками, то редактируют и удаляют ДПК ЦО.
        27.10.2004 saltanat Проставление признака удаления Платежных карт.
                            (при наличие этого признака спец.инструкция удаляется по истечении 30 кален.дн.)
        11.11.2004 saltanat Добавила проверку на пакет доступа при проставлении признака удаления Платежных карт.
        12.11.2004 saltanat Добавила проставление признака удаления спец.инстр. Департамента Кредитного Администрирования.
        23.11.2004 sasco    Перенес минус/плюс aaa.hbal при редактированиии в postkey в aasfin
        26.04.2005 saltanat Исправила проверку условия проставления признаков.
        10.04.2005 dpuchkov Запретил редактирование и удаление инкассовых распоряжений в данном пункте(только в 1.6.2.4)
        30/12/2009 galina - сохраняем aas.sta в истории aas_hist.sta
        25/02/2011 madiyar - подправил подсказку
        20/03/2012 dmitriy - перекомпиляция (измененил aas1.f)
        02/05/2012 evseev - логирование значения aaa.hbal
        19.06.2012 evseev - добавил mn =  '70000'. вынес save_data в aas2his.i и переименовал в aas2his
*/

{global.i }
{comm-txb.i}

DEFINE BUFFER b-ofc   for ofc.
DEFINE BUFFER b-aash  for aas_hist.
DEFINE BUFFER c-ofc   for ofc.
DEFINE BUFFER pl-ofc  for ofc.
DEFINE BUFFER buf-ofc for ofc.

/* 01.10.2004 sasco проверка прав на удаление */
DEFINE VAR editmes      AS character INIT 'Нельзя редактировать  [ Обратитесь к Директору Операционного Департамента ]'.
DEFINE VAR editothermes AS character INIT 'Нельзя редактировать  [  Установил сотрудник  другого департамента ]'.
DEFINE VAR delmes       AS character INIT 'Нельзя удалить  [ Обратитесь к Директору Операционного Департамента ]'.
DEFINE VAR delothermes  AS character INIT 'Нельзя удалить  [ Установил сотрудник  другого департамента ]'.
DEFINE VAR platmes      AS character INIT 'Для счетов с кредитными картами редактирование/удаление производится сотрудниками ЦО.'.
DEFINE VAR ci           AS integer.
DEFINE VAR cs           AS character.
DEFINE VAR can-del      AS logical   INIT yes.
DEFINE VAR op_kod       AS CHAR FORMAT "x(1)".
DEFINE VAR aas_id       AS INTEGER.
DEFINE VAR c-ofc        AS char.
DEFINE VAR v-prof       AS char.
DEFINE VAR v-profmess   AS char.
DEFINE VAR v-nobranch   AS logical   INIT true.
DEFINE VAR v-specin     AS char      INIT ''.
DEFINE VAR v-speckr     AS char      INIT ''.
DEFINE SHARED VAR s-aaa LIKE aaa.aaa.

{aas2his.i &db = "bank"}

/* 06.10.2004 saltanat Если спец.инструкция наложена плат.карточками, то редактируют и удаляют ДПК ЦО. */

/* Функция возвращает FALSE если пользователь имеет право на удаление и редактирование */
FUNCTION plcarddel return logical (s as logical).
if aas.payee begins 'Кр лимит по п/к' then do:
find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
    if avail pl-ofc then do:
       if pl-ofc.titcd = '104' and ofc.regno = 1001 then return false.
       else return true.
    end.
    else return true.
end.
else return true.
end FUNCTION.

find ofc where ofc.ofc = g-ofc no-lock no-error.
find sysc where sysc.sysc = 'AASDEL' no-lock no-error.
if avail sysc  then if sysc.chval <> '' then do:

   do ci = 1 to num-entries (sysc.chval, "|"):
      cs = trim (entry (ci, sysc.chval, "|")).
      if cs <> "" then do:
         if trim (entry (1, cs, ":")) = ofc.titcd then
           if lookup (g-ofc, entry (2, cs, ":"), ",") = 0 then can-del = no.
      end.
   end.

end.

v-prof = comm-txb().
find txb where txb.bank = v-prof and txb.consolid no-lock no-error.
v-nobranch = (avail txb) and (not txb.is_branch).

{jabrw.i
&start = " find first aaa where aaa.aaa = s-aaa no-lock.
           find first cif where cif.cif = aaa.cif no-lock.
           display cif.cif no-label '   ' trim(trim(cif.prefix) + ' ' + trim(cif.name)) format 'x(60)' no-label with no-box frame
                   cif-info column 1 row 3. "
&head      = "aas"
&headkey   = "aas"
&index     = "aaaln"
&formname  = "aas1"
&framename = "aas1"
&where     = "aas.aaa = s-aaa and aas.ln <> 7777777"
&prechoose = " message 'INS-добавить, RETURN-исправить, CTRL+D-удалить, F4 - выход, TAB - показать все, F1-признак удал.спец.инстр.Плат.Карт., F5-признак удал.спец.инстр.Кред.Адм.'."
&predisplay = "run spinpr. "
&display = " aas.ln aas.sic aas.chkdt aas.chkno aas.chkamt  aas.payee v-specin v-speckr "
&highlight = " aas.ln aas.sic aas.chkdt aas.chkno aas.chkamt aas.payee"
&addcon    = "true"
&deletecon = "true"
&precreate = " find last b-aash where b-aash.aaa = s-aaa use-index aaaln no-lock no-error. "
&postadd   = " if available b-aash then aas.ln = b-aash.ln + 1. else aas.ln = 1.
 display aas.ln with frame aas1. find aaa where aaa.aaa = s-aaa no-lock.
 find lgr where lgr.lgr = aaa.lgr no-lock. update aas.sic validate((can-find(sic where sic.sic = aas.sic)) and
 (not ((aas.sic = 'HB') and (lgr.led = 'ODA'))), 'Kµ­da !') with frame aas1.
 update aas.chkdt with frame aas1. update aas.chkno with frame aas1. aas.mn = '70000'.
 if aas.sic = 'HB' then  update aas.chkamt with frame aas1.
 update aas.payee  with frame aas1. run fill_aas.
 if aas.sic = 'HB' then do:
 find first aaa where aaa.aaa = s-aaa exclusive-lock.
 run savelog('aaahbal', 'aaa-aasm ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal + aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
 aaa.hbal = aaa.hbal + aas.chkamt. end.
 FIND FIRST b-ofc WHERE b-ofc.ofc = g-ofc NO-LOCK.
 aas.point = b-ofc.regno / 1000 - 0.5.
 aas.depart = b-ofc.regno MODULO 1000. op_kod = 'A'.
 RUN aas2his."
&predelete= "if lookup(string(aas.sta), '4,5,15,6,9,15') <> 0 then do: message 'Удаляется в 1.6.2.4'. pause. return. end. FIND FIRST b-ofc WHERE b-ofc.ofc = g-ofc NO-LOCK.
FIND FIRST c-ofc WHERE c-ofc.ofc = aas.who NO-LOCK.
IF (aas.point * 1000 + aas.depart) <> b-ofc.regno and plcarddel(true) THEN DO:
message 'Нельзя удалить  [ Установил пункт ' aas.point '/ департамент ' aas.depart ']'. pause 3. NEXT inner.
END. run chek.
if v-nobranch and c-ofc.titcd <> b-ofc.titcd and plcarddel(true) then do: run profname. message delothermes skip v-profmess.  pause 3. NEXT inner. end.
if can-del = no then do: message delmes skip v-profmess. pause 3. NEXT inner. end.
if b-ofc.regno <> 1001 and aas.payee begins 'Кр лимит по п/к' then do: message platmes.  pause 3. NEXT inner. end."
&prevdelete= " if aas.sic = 'HB' then do:
 find first aaa where aaa.aaa = s-aaa exclusive-lock.
 run savelog('aaahbal', 'aaa-aasm ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal - aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
 aaa.hbal = aaa.hbal - aas.chkamt. end.
 op_kod= 'D'. aas.who = g-ofc. aas.whn = g-today. aas.tim = time. aas.mn = '70009'. RUN aas2his."
&postkey = " else if keyfunction(lastkey) = 'RETURN' then do on error undo, next upper:
if lookup(string(aas.sta), '4,5,15,6,9,15') <> 0 then do: message 'Редактировать запрещено'. pause. return. end.
FIND FIRST b-ofc WHERE b-ofc.ofc = g-ofc NO-LOCK.
FIND FIRST c-ofc WHERE c-ofc.ofc = aas.who NO-LOCK.
IF (aas.point * 1000 + aas.depart) <> b-ofc.regno and plcarddel(true) THEN DO:
    message 'Нельзя редактировать [ Установил пункт ' aas.point '/ департамент ' aas.depart ']'.
    NEXT inner.
END.
run chek.
if v-nobranch and c-ofc <> b-ofc.titcd and plcarddel(true) then do:
    run profname.
    message editothermes skip v-profmess.
    NEXT inner.
end.
 if can-del = no then do:
    message editmes skip v-profmess.
    pause 3.
    NEXT inner.
 end.
 if b-ofc.regno <> 1001 and aas.payee begins 'Кр лимит по п/к' then do:
    message platmes.
    pause 3.
    NEXT inner.
 end.
 find first aaa where aaa.aaa = s-aaa exclusive-lock.
 run aasfin.
end.
else if keyfunction(lastkey) = 'TAB' then do:
      RUN aasall.
      view frame aas1.
end.
else if keyfunction(lastkey) = 'GO' then do:
      RUN specindo.
      displ v-specin with frame aas1.
end.
else if keyfunction(lastkey) = 'GET' then do:
      RUN speckrdo.
      displ v-speckr with frame aas1.
end."
&end = "hide frame aas1."
}

hide message.



PROCEDURE chek.
  def var p-ofc as char.
  /* проверяем департамент по офицеру, делавшему последние изменения */
  FIND last ofcprofit where ofcprofit.ofc = aas.who and ofcprofit.regdt <= aas.whn use-index ofcreg NO-LOCK no-error.
  if available ofcprofit then c-ofc = ofcprofit.profitcn.
  else do:
    FIND first ofcprofit where ofcprofit.ofc = aas.who use-index ofcreg NO-LOCK no-error.
    if available ofcprofit then c-ofc = ofcprofit.profitcn.
    else do:
      find buf-ofc where buf-ofc.ofc = aas.who no-lock no-error.
      c-ofc = buf-ofc.titcd.
    end.
  end.
end PROCEDURE.
PROCEDURE profname.
  find codfr where codfr.codfr = 'sproftcn' and codfr.code = c-ofc no-lock no-error.
  if avail codfr then v-prof = substr(codfr.name[1], 1, 30). else v-prof = ' '.
  v-profmess = "(" +  aas.who + " " + string(aas.whn, "99/99/99") + " " + v-prof + ")".
end PROCEDURE.
PROCEDURE fill_aas.
 aas.aaa = s-aaa.
 aas.who = g-ofc.
 aas.whn = g-today.
 aas.regdt = g-today.
 aas.tim = time.
end PROCEDURE.
PROCEDURE aasfin.
 find aas where recid(aas) = crec exclusive-lock.
 do transaction on endkey undo, return:
    if aas.sic = 'HB' and aas.chkamt > 0 then do:
       run savelog('aaahbal', 'aaa-aasm ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal - aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
       aaa.hbal = aaa.hbal - aas.chkamt.
    end.
    update aas.chkdt aas.chkno with frame aas1.
    if aas.sic = 'HB' then update aas.chkamt aas.payee with frame aas1.
       assign aas.who = g-ofc aas.whn = g-today aas.tim = time.
    IF (aas.sic ENTERED) OR (aas.chkdt ENTERED) OR
       (aas.chkno ENTERED) OR (aas.chkamt ENTERED) OR
       (aas.payee ENTERED) THEN do: op_kod= 'E'. RUN aas2his. end.
    if aas.sic = 'HB' then do:
       run savelog('aaahbal', 'aaa-aasm ; ' + aaa.aaa + ' ; ' + string(aaa.hbal) + ' ; ' + string(aaa.hbal + aas.chkamt) + ' ; ' + string(aas.chkamt)) no-error.
       aaa.hbal = aaa.hbal + aas.chkamt.
    end.
 end.
end PROCEDURE.
/* 27.10.2004 saltanat - Проверка и отображение признака Платежных карт
   12.11.2004 saltanat - Проверка и отображение признака ДКА */
PROCEDURE spinpr.
    if aas.delaas = 'd' then do: v-specin = '*'. v-speckr = ''. end.
    else if aas.delaas = 'k' then do: v-speckr = '*'. v-specin = ''. end.
         else do: v-specin = ''. v-speckr = ''. end.
end PROCEDURE.
PROCEDURE specindo.
    def var pack  as char init ''.
    def var i     as inte init 0.
    def var boole as logi init false.
    def var cha   as char init ''.

     find sysc where sysc.sysc = 'pkcon' no-lock no-error.
     if avail sysc then do:

      /* 11.11.2004 saltanat - Проставление признака Платежных карт с учетом прав доступа !!! на пакеты !!! */
      boole = false.
      find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
      if avail pl-ofc then do:
         if pl-ofc.expr[1] <> '' then do:
            do i = 1 to num-entries(pl-ofc.expr[1]):
               cha = entry(i,pl-ofc.expr[1]).
               if lookup(cha,sysc.chval) > 0 then do:
                  boole = true.
                  leave.
               end.
            end.
         end.
      end.

      if lookup(g-ofc,sysc.chval) > 0 or boole then do:
       find current aas exclusive-lock.
       if aas.delaas = '' then do:
          aas.delaas = 'd'.
          v-specin   = '*'.
       end.
       else do:
          if aas.delaas = 'd' then do:
             aas.delaas = ''.
             v-specin   = ''.
          end.
          else do:
             message 'Стоит признак удаления Департамента Кредитного Администрирования!' view-as alert-box warning buttons ok.
          end.
       end.
      end.
      else message 'У Вас нет прав работы с признаком удаления спец.инструкции Платежных карт! ' view-as alert-box warning buttons ok.
     end.
     else message 'Нет возможности работы с признаком удаления спец.инструкции Платежных карт! 'view-as alert-box warning buttons ok.
     find current aas no-lock.
end PROCEDURE.
PROCEDURE speckrdo.
    def var pack  as char init ''.
    def var i     as inte init 0.
    def var boole as logi init false.
    def var cha   as char init ''.

     find sysc where sysc.sysc = 'dkpriz' no-lock no-error.
     if avail sysc then do:

      boole = false.
      find pl-ofc where pl-ofc.ofc = g-ofc no-lock no-error.
      if avail pl-ofc then do:
         if pl-ofc.expr[1] <> '' then do:
            do i = 1 to num-entries(pl-ofc.expr[1]):
               cha = entry(i,pl-ofc.expr[1]).
               if lookup(cha,sysc.chval) > 0 then do:
                  boole = true.
                  leave.
               end.
            end.
         end.
      end.

      if lookup(g-ofc,sysc.chval) > 0 or boole then do:
       find current aas exclusive-lock.
       if aas.delaas = '' then do:
          aas.delaas = 'k'.
          v-speckr   = '*'.
       end.
       else do:
          if aas.delaas = 'k' then do:
             aas.delaas = ''.
             v-speckr   = ''.
          end.
          else do:
             message 'Стоит признак удаления Департамента Платежных карт!' view-as alert-box warning buttons ok.
          end.
       end.
      end.
      else message 'У Вас нет прав работы с признаком удаления спец.инструкции Кредитного Администрирования! ' view-as alert-box warning buttons ok.
     end.
     else message 'Нет возможности работы с признаком удаления спец.инструкции Кредитного Администрирования! 'view-as alert-box warning buttons ok.
     find current aas no-lock.
end PROCEDURE.

