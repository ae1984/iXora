/* aas-rpt.p
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
*/

/* aas_rpt.p
   VLAD LEVITSKY, 1997
*/

{mainhead.i CFSIENT}  /*  SPECIAL INSTRUCTION MAINT  */


DEFINE VARIABLE vtitle2 AS CHAR FORMAT "x(132)".

DEFINE VARIABLE dSakDat AS DATE LABEL "За период с".
DEFINE VARIABLE dBeiDat AS DATE LABEL "По         ".
DEFINE VARIABLE s-ofc LIKE aas.who LABEL "Исполнитель".
DEFINE VARIABLE s-aaa LIKE aaa.aaa LABEL "Счет ".
DEFINE VARIABLE s-sic LIKE aas.sic LABEL "Спец.инстр.".

DEFINE VARIABLE sChgOper LIKE aas_hist.chgoper.

/* REPORT SPECIAL INSTRUCTION CREATING */


DEFINE VAR s-datinfo AS CHAR.


FIND FIRST aas_hist USE-INDEX chgdat no-lock no-error.
if not available aas_hist then do:
    message "Не найдено ни одной специальной инструкции.".
    return.
end.

dSakDat = aas_hist.chgdat.
dBeiDat = g-today.



{image1.i rpt.img}
{aas_rpt.f}



UPDATE
   dSakDat
   dBeiDat
   s-aaa
   s-ofc
   s-sic
   WITH CENTERED ROW 8 SIDE-LABEL NO-BOX FRAM aas_parm.


{image2.i}


s-datinfo = "Специальные инструкции с  " + STRING(dSakDat) +
   " по   " + STRING(dBeiDat).

{report1.i 59}


vtitle2 =

"Код кл.       Наименование клиента          Счет#      Линия   Дата     Время
 Спец.инстр.    Сумма        Исполн.".


{report2.i 132 "s-datinfo format ""x(132)""
   vtitle2 fill(""="",132) format ""x(132)"" "}



FOR EACH aas_hist WHERE (aas_hist.chgdat>= dSakDat OR dSakDat= ?) AND
   (aas_hist.chgdat<= dBeiDat OR dBeiDat= ?) AND
   (aas_hist.aaa= s-aaa OR s-aaa= "") AND 
   (UPPER(aas_hist.who)= UPPER(s-ofc) OR s-ofc= "") AND
   (aas_hist.sic= s-sic OR s-sic= "") NO-LOCK use-index aasreport
      BREAK BY aas_hist.cif BY aas_hist.aaa BY aas_hist.ln
         BY aas_hist.chgtime:


      FIND FIRST cif WHERE cif.cif = aas_hist.cif USE-INDEX cif NO-LOCK
         NO-ERROR.
      IF AVAILABLE cif THEN
       DO:
          IF cif.type <> "X" THEN
           DO:
              PUT aas_hist.cif "  " aas_hist.name " "
                 aas_hist.aaa " " aas_hist.ln " " aas_hist.chgoper " "
                 aas_hist.chgdat " " STRING(aas_hist.chgtime, "hh:mm:ss") "   "
                 aas_hist.sic " " aas_hist.chkamt " " aas_hist.who " " SKIP(0).
           END.
              ELSE
           DO:
              PUT aas_hist.cif "  " " " FORMAT "x(31)"
                 aas_hist.aaa " " aas_hist.ln " " aas_hist.chgoper " "
                 aas_hist.chgdat " " STRING(aas_hist.chgtime, "hh:mm:ss") "   "
                 aas_hist.sic " " aas_hist.chkamt " " aas_hist.who " " SKIP(0).
           END.
       END.

END.



{report3.i}
{image3.i}
