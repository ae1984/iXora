/* compay.p
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
        26/03/09 id00205
        13.10.2010 k.gitalov перекомпиляция
 * CHANGES
        07.11.2012 damir - Внедрено Т.З. № 1365,1481,1538.

*/



{classes.i}


def var Doc as class COMPAYDOCClass.  /* Класс документов коммунальных платежей*/
def var SP  as class SUPPCOMClass.    /* Класс данных поставщиков */
def new shared var s-jh like jh.jh.   /* Номер проводки */
def var rez as log.                   /* Значение возврата функций*/
def var pos as int init 1.

/***********************************************************************************************************/

      REPEAT on ENDKEY UNDO  , leave :
        CASE pos:

          WHEN 1 THEN
          DO:    /* Выбор из списка поставщиков услуг */
                 Doc = NEW COMPAYDOCClass(Base).
                 Doc:AddData().
                 SP  = NEW SUPPCOMClass(Base).
                 run help-suppay(SP,"pay").
                 if SP:supp_id = ? then
                 do:
                    run yn("","Выйти из программы?","","", output rez).
                    if rez then  LEAVE.
                    else do: pos = 1. undo. end.
                 end.
                 else do:
                    Doc:SetSuppData(SP).
                    DELETE OBJECT SP NO-ERROR .
                    pos = 2.
                 end.
          END.
          WHEN 2 THEN
          DO:
                 case Doc:type:
                    when 1 then run compay1(Doc,output rez). /*Казахтелеком*/
                    when 2 then run compay2(Doc,output rez). /*Dalacom, Pathword, NEO, City | Alma TV, Digital TV, ICON*/
                    when 3 then run compay3(Doc,output rez). /*Алсеко ИВЦ*/
                    when 5 then run compay5(Doc,output rez). /*Нурсат,ШыгысЭнергоТрейд*/
                 end case.
                 /* if not rez then ошибка! */
                 DELETE OBJECT Doc NO-ERROR.
                 pos = 1.
          END.
        END CASE.

      END. /*REPEAT*/

/***********************************************************************************************************/

  if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
  if VALID-OBJECT(SP)   then DELETE OBJECT SP  NO-ERROR .

/***********************************************************************************************************/
